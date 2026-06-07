package controller;

import dal.AddressDAO;
import dal.CartDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Address;
import model.User;

@WebServlet(name = "ShippingAddressServlet", urlPatterns = {"/shipping-address"})
public class ShippingAddressServlet extends HttpServlet {

    private static final String VIEW_PATH = "/views/shipping-address.jsp";
    private static final String FLASH_SUCCESS = "shippingAddressSuccess";
    private static final String FLASH_ERROR = "shippingAddressError";

    private final AddressDAO addressDAO = new AddressDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = requireLogin(request, response);
        if (account == null) {
            return;
        }

        moveFlashMessage(request);
        prepareDefaultFormState(request, account);
        renderPage(request, response, account);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User account = requireLogin(request, response);
        if (account == null) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));

        if ("delete".equalsIgnoreCase(action)) {
            handleDelete(request, response, account);
            return;
        }

        handleSave(request, response, account, "update".equalsIgnoreCase(action));
    }

    private void handleSave(HttpServletRequest request, HttpServletResponse response, User account, boolean updateMode)
            throws ServletException, IOException {
        String recipientName = safeTrim(request.getParameter("recipientName"));
        String phoneNumber = safeTrim(request.getParameter("phoneNumber"));
        String addressDetail = safeTrim(request.getParameter("addressDetail"));
        Integer addressId = parsePositiveInteger(request.getParameter("addressId"));

        request.setAttribute("formAction", updateMode ? "update" : "create");
        request.setAttribute("formAddressId", addressId != null ? String.valueOf(addressId) : "");
        request.setAttribute("formRecipientName", recipientName);
        request.setAttribute("formPhoneNumber", phoneNumber);
        request.setAttribute("formAddressDetail", addressDetail);
        request.setAttribute("activeAddressId", addressId);

        if (recipientName.isEmpty() || phoneNumber.isEmpty() || addressDetail.isEmpty()) {
            request.setAttribute("errorMsg", "Vui long nhap day du ten nguoi nhan, so dien thoai va dia chi.");
            renderPage(request, response, account);
            return;
        }

        if (updateMode) {
            if (addressId == null) {
                request.setAttribute("errorMsg", "Khong tim thay dia chi can cap nhat.");
                renderPage(request, response, account);
                return;
            }

            Address currentAddress = addressDAO.getAddressByIdAndUserId(addressId, account.getUserId());
            if (currentAddress == null) {
                request.setAttribute("errorMsg", "Dia chi khong ton tai hoac khong thuoc tai khoan nay.");
                renderPage(request, response, account);
                return;
            }
        }

        Address address = new Address();
        address.setAddressId(addressId != null ? addressId : 0);
        address.setUserId(account.getUserId());
        address.setRecipientName(recipientName);
        address.setPhoneNumber(phoneNumber);
        address.setAddressDetail(addressDetail);

        boolean saved = updateMode ? addressDAO.updateAddress(address) : addressDAO.addAddress(address);
        if (saved) {
            setFlashMessage(request.getSession(), FLASH_SUCCESS,
                    updateMode ? "Da luu thay doi dia chi giao hang." : "Da them dia chi giao hang moi.");
            response.sendRedirect(request.getContextPath() + "/shipping-address");
            return;
        }

        request.setAttribute("errorMsg",
                updateMode
                        ? "Khong the luu thay doi dia chi luc nay. Vui long thu lai."
                        : "Khong the them dia chi moi luc nay. Vui long thu lai.");
        renderPage(request, response, account);
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, User account)
            throws IOException {
        Integer addressId = parsePositiveInteger(request.getParameter("addressId"));

        if (addressId == null) {
            setFlashMessage(request.getSession(), FLASH_ERROR, "Dia chi can xoa khong hop le.");
            response.sendRedirect(request.getContextPath() + "/shipping-address");
            return;
        }

        boolean deleted = addressDAO.deleteAddress(addressId, account.getUserId());
        if (deleted) {
            setFlashMessage(request.getSession(), FLASH_SUCCESS, "Da xoa dia chi giao hang.");
        } else {
            setFlashMessage(request.getSession(), FLASH_ERROR, "Khong the xoa dia chi nay.");
        }

        response.sendRedirect(request.getContextPath() + "/shipping-address");
    }

    private void renderPage(HttpServletRequest request, HttpServletResponse response, User account)
            throws ServletException, IOException {
        List<Address> addresses = addressDAO.getAddressesByUserId(account.getUserId());
        request.setAttribute("addresses", addresses);

        CartDAO cartDAO = new CartDAO();
        request.setAttribute("cartItemCount", cartDAO.getCartItemCountByUserId(account.getUserId()));

        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    private void prepareDefaultFormState(HttpServletRequest request, User account) {
        if (request.getAttribute("formAction") != null) {
            return;
        }

        Integer editId = parsePositiveInteger(request.getParameter("editId"));
        if (editId != null) {
            Address editingAddress = addressDAO.getAddressByIdAndUserId(editId, account.getUserId());
            if (editingAddress != null) {
                request.setAttribute("formAction", "update");
                request.setAttribute("formAddressId", String.valueOf(editingAddress.getAddressId()));
                request.setAttribute("formRecipientName", safeTrim(editingAddress.getRecipientName()));
                request.setAttribute("formPhoneNumber", safeTrim(editingAddress.getPhoneNumber()));
                request.setAttribute("formAddressDetail", safeTrim(editingAddress.getAddressDetail()));
                request.setAttribute("activeAddressId", editingAddress.getAddressId());
                return;
            }
        }

        request.setAttribute("formAction", "create");
        request.setAttribute("formAddressId", "");
        request.setAttribute("formRecipientName", safeTrim(account.getFullName()));
        request.setAttribute("formPhoneNumber", "");
        request.setAttribute("formAddressDetail", "");
    }

    private void moveFlashMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }

        Object success = session.getAttribute(FLASH_SUCCESS);
        if (success != null) {
            request.setAttribute("successMsg", success);
            session.removeAttribute(FLASH_SUCCESS);
        }

        Object error = session.getAttribute(FLASH_ERROR);
        if (error != null) {
            request.setAttribute("errorMsg", error);
            session.removeAttribute(FLASH_ERROR);
        }
    }

    private void setFlashMessage(HttpSession session, String key, String message) {
        session.setAttribute(key, message);
    }

    private User requireLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
        }

        return account;
    }

    private Integer parsePositiveInteger(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }
}
