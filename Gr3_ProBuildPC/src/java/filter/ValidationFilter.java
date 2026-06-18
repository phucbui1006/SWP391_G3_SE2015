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
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.regex.Pattern;
import model.User;

@WebFilter(filterName = "ValidationFilter", urlPatterns = {
    "/Register",
    "/updateProfile",
    "/ForgotPassword",
    "/VerifyOtp",
    "/VerifyRegisterOtp",
    "/ResetPassword",
    "/ForceChangePassword",
    "/shipping-address",
    "/AdminBrands"
})
public class ValidationFilter implements Filter {

    private static final long MAX_BRAND_IMAGE_SIZE = 2 * 1024 * 1024;
    private static final String BRAND_IMAGE_ADD_ERROR = "Vui lòng chọn logo PNG, JPG, JPEG hoặc WEBP, tối đa 2MB.";
    private static final String BRAND_IMAGE_UPDATE_ERROR = "Logo chỉ chấp nhận PNG, JPG, JPEG hoặc WEBP và tối đa 2MB.";
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^(0[35789])[0-9]{8}$");
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,31}$");
    private static final Pattern NAME_PATTERN = Pattern.compile("^[\\p{L}\\s]+$");
    private static final Pattern OTP_PATTERN = Pattern.compile("^\\d{6}$");
    
    private static final String FIXED_ADDRESS_SUFFIX = "Xã Hòa Lạc, Hà Nội";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Only validate POST requests
        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        boolean isValid = true;

        if ("/Register".equalsIgnoreCase(path)) {
            isValid = validateRegister(req, res);
        } else if ("/updateProfile".equalsIgnoreCase(path)) {
            isValid = validateUpdateProfile(req, res);
        } else if ("/ForgotPassword".equalsIgnoreCase(path)) {
            isValid = validateForgotPassword(req, res);
        } else if ("/VerifyOtp".equalsIgnoreCase(path) || "/VerifyRegisterOtp".equalsIgnoreCase(path)) {
            isValid = validateOtp(req, res, path);
        } else if ("/ResetPassword".equalsIgnoreCase(path)) {
            isValid = validateResetPassword(req, res);
        } else if ("/ForceChangePassword".equalsIgnoreCase(path)) {
            isValid = validateForceChangePassword(req, res);
        } else if ("/shipping-address".equalsIgnoreCase(path)) {
            isValid = validateShippingAddress(req, res);
        } else if ("/AdminBrands".equalsIgnoreCase(path)) {
            isValid = validateBrand(req, res);
        }

        if (isValid) {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {
    }

    // Helper validation predicates
    private boolean isValidEmail(String email) {
        if (email == null) return false;
        String trimmed = email.trim();
        return trimmed.length() <= 100 && EMAIL_PATTERN.matcher(trimmed).matches();
    }

    private boolean isValidPhone(String phone) {
        if (phone == null) return false;
        String trimmed = phone.trim();
        return PHONE_PATTERN.matcher(trimmed).matches();
    }

    private boolean isValidPassword(String password) {
        if (password == null) return false;
        return PASSWORD_PATTERN.matcher(password).matches();
    }

    private boolean isValidName(String name) {
        if (name == null) return false;
        String trimmed = name.trim();
        return trimmed.length() >= 2 && trimmed.length() <= 50 && NAME_PATTERN.matcher(trimmed).matches();
    }

    private boolean isValidOtpCode(String otp) {
        if (otp == null) return false;
        String trimmed = otp.trim();
        return OTP_PATTERN.matcher(trimmed).matches();
    }

    private boolean isValidBrandName(String brandName) {
        if (brandName == null) return false;
        int length = brandName.trim().length();
        return length >= 2 && length < 20;
    }

    private boolean isAllowedBrandImage(Part filePart, boolean required) {
        if (filePart == null || filePart.getSize() == 0) {
            return !required;
        }

        if (filePart.getSize() > MAX_BRAND_IMAGE_SIZE) {
            return false;
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return false;
        }

        String fileName = Paths.get(submittedName).getFileName().toString();
        String lowerName = fileName.toLowerCase(Locale.ROOT);

        return lowerName.endsWith(".png")
                || lowerName.endsWith(".jpg")
                || lowerName.endsWith(".jpeg")
                || lowerName.endsWith(".webp");
    }

    // Specific Path Validators
    private boolean validateRegister(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (!isValidName(fullName)) {
            error = "Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.";
        } else if (!isValidEmail(email)) {
            error = "Định dạng email không hợp lệ (tối đa 100 ký tự).";
        } else if (!isValidPassword(password)) {
            error = "Mật khẩu 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.";
        } else if (confirmPassword == null || !confirmPassword.equals(password)) {
            error = "Mật khẩu xác nhận không khớp!";
        }

        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/views/register.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateUpdateProfile(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String currentPassword = req.getParameter("currentPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (!isValidName(fullName)) {
            error = "Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.";
        } else {
            boolean hasCurrent = currentPassword != null && !currentPassword.trim().isEmpty();
            boolean hasNew = newPassword != null && !newPassword.trim().isEmpty();
            boolean hasConfirm = confirmPassword != null && !confirmPassword.trim().isEmpty();
            
            if (hasCurrent || hasNew || hasConfirm) {
                if (!hasCurrent) {
                    error = "Vui lòng nhập mật khẩu cũ để xác nhận thay đổi!";
                } else if (!hasNew) {
                    error = "Vui lòng nhập mật khẩu mới!";
                } else if (!isValidPassword(newPassword)) {
                    error = "Mật khẩu mới từ 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.";
                } else if (confirmPassword == null || !confirmPassword.equals(newPassword)) {
                    error = "Xác nhận mật khẩu mới không khớp!";
                }
            }
        }

        if (error != null) {
            req.setAttribute("errorMsg", error);
            req.getRequestDispatcher("views/profile.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateForgotPassword(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String email = req.getParameter("email");

        if (!isValidEmail(email)) {
            req.setAttribute("error", "Định dạng email không hợp lệ (tối đa 100 ký tự).");
            req.getRequestDispatcher("/views/forget-password.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateOtp(HttpServletRequest req, HttpServletResponse res, String path) throws ServletException, IOException {
        String otp = req.getParameter("otp");

        if (!isValidOtpCode(otp)) {
            req.setAttribute("error", "Mã OTP phải gồm đúng 6 chữ số.");
            String targetJsp = "/VerifyOtp".equalsIgnoreCase(path) ? "/views/verify-otp.jsp" : "/views/verify-register-otp.jsp";
            req.getRequestDispatcher(targetJsp).forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateResetPassword(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (!isValidPassword(password)) {
            error = "Mật khẩu từ 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.";
        } else if (confirmPassword == null || !confirmPassword.equals(password)) {
            error = "Mật khẩu xác nhận không khớp!";
        }

        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateForceChangePassword(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (!isValidPassword(newPassword)) {
            error = "Mật khẩu từ 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.";
        } else if (confirmPassword == null || !confirmPassword.equals(newPassword)) {
            error = "Mật khẩu xác nhận không khớp!";
        }

        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/views/force-change-password.jsp").forward(req, res);
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
        } else if (!isValidName(recipientName)) {
            error = "Tên người nhận từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.";
        } else if (!isValidPhone(phoneNumber)) {
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

    private boolean validateBrand(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (!"add".equalsIgnoreCase(action) && !"update".equalsIgnoreCase(action)) {
            return true;
        }

        String error = null;
        if (!isValidBrandName(req.getParameter("brandName"))) {
            error = "Tên thương hiệu chứa từu 2-20 kí tự.";
        } else {
            boolean imageRequired = "add".equalsIgnoreCase(action);
            try {
                Part imagePart = getUploadedPart(req, "imgFile");
                if (!isAllowedBrandImage(imagePart, imageRequired)) {
                    error = getBrandImageError(imageRequired);
                }
            } catch (IllegalStateException e) {
                error = getBrandImageError(imageRequired);
            }
        }

        if (error == null) {
            return true;
        }

        req.getSession().setAttribute("brandError", error);
        res.sendRedirect(req.getContextPath() + "/AdminBrands");
        return false;
    }

    private Part getUploadedPart(HttpServletRequest req, String name) throws ServletException, IOException {
        return req.getPart(name);
    }

    private String getBrandImageError(boolean imageRequired) {
        return imageRequired ? BRAND_IMAGE_ADD_ERROR : BRAND_IMAGE_UPDATE_ERROR;
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
