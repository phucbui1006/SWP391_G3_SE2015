package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;
import util.ValidatorUtil;

@WebFilter(filterName = "AccountValidationFilter", urlPatterns = {
    "/updateProfile",
    "/shipping-address"
})
public class AccountValidationFilter implements Filter {

    private static final String FIXED_ADDRESS_SUFFIX = "Xã Hòa Lạc, Hà Nội";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        boolean isValid = true;

        if ("/updateProfile".equalsIgnoreCase(path)) {
            isValid = validateUpdateProfile(req, res);
        } else if ("/shipping-address".equalsIgnoreCase(path)) {
            isValid = validateShippingAddress(req, res);
        }

        if (isValid) {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {}

    private boolean validateUpdateProfile(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (!ValidatorUtil.isValidName(fullName)) {
            error = "Tên người dùng từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.";
        } else {
            boolean hasCurrent = currentPassword != null && !currentPassword.trim().isEmpty();
            boolean hasNew = newPassword != null && !newPassword.trim().isEmpty();
            boolean hasConfirm = confirmPassword != null && !confirmPassword.trim().isEmpty();
            
            if (hasCurrent || hasNew || hasConfirm) {
                if (!hasCurrent) {
                    error = "Vui lòng nhập mật khẩu cũ để xác nhận thay đổi!";
                } else if (!hasNew) {
                    error = "Vui lòng nhập mật khẩu mới!";
                } else if (!ValidatorUtil.isValidPassword(newPassword)) {
                    error = "Mật khẩu mới từ 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.";
                } else if (confirmPassword == null || !confirmPassword.equals(newPassword)) {
                    error = "Xác nhận mật khẩu mới không khớp!";
                }
            }
        }

        if (error != null) {
            req.setAttribute("errorMsg", error);
            req.setAttribute("enteredFullName", fullName);
            req.setAttribute("enteredCurrentPassword", currentPassword);
            req.setAttribute("enteredNewPassword", newPassword);
            req.setAttribute("enteredConfirmPassword", confirmPassword);
            req.getRequestDispatcher("/views/profile.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateShippingAddress(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            return true;
        }

        String recipientName = req.getParameter("recipientName");
        String phoneNumber = req.getParameter("phoneNumber");
        String addressDetail = req.getParameter("addressDetail");
        String addressDetailPart = extractAddressDetailPart(addressDetail);

        String error = null;
        if (recipientName == null || recipientName.trim().isEmpty() || 
            phoneNumber == null || phoneNumber.trim().isEmpty() || 
            addressDetail == null || addressDetail.trim().isEmpty()) {
            error = "Vui lòng nhập đầy đủ tên người nhận, số điện thoại và địa chỉ.";
        } else if (!ValidatorUtil.isValidName(recipientName)) {
            error = "Tên người nhận từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.";
        } else if (!ValidatorUtil.isValidPhone(phoneNumber)) {
            error = "Số điện thoại không hợp lệ (Phải là số di động VN gồm 10 chữ số).";
        } else {
            String detailVal = addressDetailPart.trim();
            if (detailVal.length() < 5 || detailVal.length() > 255) {
                error = "Địa chỉ chi tiết phải từ 5 đến 255 ký tự.";
            }
        }

        if (error != null) {
            HttpSession session = req.getSession(false);
            User account = session != null ? (User) session.getAttribute("account") : null;
            if (account != null) {
                dal.AddressDAO addressDAO = new dal.AddressDAO();
                dal.CartDAO cartDAO = new dal.CartDAO();
                
                String addressIdStr = req.getParameter("addressId");
                Integer addressId = null;
                try {
                    if (addressIdStr != null && !addressIdStr.isEmpty()) {
                        addressId = Integer.parseInt(addressIdStr);
                    }
                } catch (NumberFormatException e) {}

                req.setAttribute("formAction", "update".equalsIgnoreCase(action) ? "update" : "create");
                req.setAttribute("formAddressId", addressId != null ? String.valueOf(addressId) : "");
                req.setAttribute("formRecipientName", recipientName == null ? "" : recipientName.trim());
                req.setAttribute("formPhoneNumber", phoneNumber == null ? "" : phoneNumber.trim());
                req.setAttribute("formAddressDetail", addressDetailPart);
                req.setAttribute("activeAddressId", addressId);
                req.setAttribute("fixedAddressSuffix", FIXED_ADDRESS_SUFFIX);
                req.setAttribute("errorMsg", error);
                
                req.setAttribute("addresses", addressDAO.getAddressesByCustomerId(account.getCustomerId()));
                req.setAttribute("cartItemCount", cartDAO.getCartItemCountByCustomerId(account.getCustomerId()));
                req.getRequestDispatcher("/views/shipping-address.jsp").forward(req, res);
                return false;
            }
        }
        return true;
    }

    private String extractAddressDetailPart(String rawAddress) {
        String value = rawAddress == null ? "" : rawAddress.trim();
        if (value.isEmpty()) {
            return "";
        }

        String normalizedSuffix = FIXED_ADDRESS_SUFFIX.toLowerCase();
        String normalizedValue = value.toLowerCase();
        if (normalizedValue.endsWith(normalizedSuffix)) {
            value = value.substring(0, value.length() - FIXED_ADDRESS_SUFFIX.length()).trim();
        }

        while (value.endsWith(",")) {
            value = value.substring(0, value.length() - 1).trim();
        }

        return value;
    }
}
