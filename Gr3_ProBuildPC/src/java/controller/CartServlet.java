package controller;

import dal.CartDAO;
import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.Product;
import model.User;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private static final String LEGACY_SESSION_CART_QUANTITIES = "sessionCartQuantities";
    private static final String SESSION_CART_ITEM_COUNT = "sessionCartItemCount";
    private static final String CART_SUCCESS_FLASH = "cartSuccessMsg";
    private static final String CART_ERROR_FLASH = "cartErrorMsg";
    private static final String PRODUCT_DETAIL_CART_MESSAGE = "cartMessage";
    private static final String PRODUCT_DETAIL_CART_MESSAGE_TYPE = "cartMessageType";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        List<CartItem> cartItems = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        int cartItemCount = 0;

        if (account != null) {
            Integer customerId = getCustomerId(account);
            if (customerId == null) {
                response.sendRedirect(request.getContextPath() + "/Dashboard");
                return;
            }

            CartDAO cartDAO = new CartDAO();
            cartItems = cartDAO.getCartItemsByCustomerId(customerId);
            subtotal = cartDAO.calculateSubtotal(cartItems);
            cartItemCount = calculateCartItemCount(cartItems);
            session.setAttribute(SESSION_CART_ITEM_COUNT, cartItemCount);
            session.removeAttribute(LEGACY_SESSION_CART_QUANTITIES);
        } else {
            session.removeAttribute(LEGACY_SESSION_CART_QUANTITIES);
            session.removeAttribute(SESSION_CART_ITEM_COUNT);
        }

        moveFlashMessage(session, request, CART_SUCCESS_FLASH, "cartSuccessMsg");
        moveFlashMessage(session, request, CART_ERROR_FLASH, "cartErrorMsg");
        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartSubtotal", subtotal);
        request.setAttribute("cartTotal", subtotal);
        request.setAttribute("cartItemCount", cartItemCount);
        request.getRequestDispatcher("/views/cart.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("updateCartQuantity".equals(action) || "updateSessionQuantity".equals(action)) {
            handleCartQuantityUpdate(request, response);
            return;
        }
        if ("addToCart".equals(action) || request.getParameter("productId") != null) {
            handleAddToCart(request, response);
            return;
        }
        if ("removeCartItem".equals(action)) {
            handleRemoveCartItem(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void handleCartQuantityUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        boolean ajaxRequest = isAjaxRequest(request);

        if (account == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED,
                        "{\"success\":false,\"message\":\"Vui long dang nhap de cap nhat gio hang.\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/Login");
            }
            return;
        }

        Integer customerId = getCustomerId(account);
        if (customerId == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_FORBIDDEN,
                        "{\"success\":false,\"message\":\"Tai khoan nhan vien khong the cap nhat gio hang.\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/Dashboard");
            }
            return;
        }

        Integer cartItemId = parsePositiveInteger(request.getParameter("cartItemId"));
        Integer requestedQuantity = parsePositiveInteger(request.getParameter("quantity"));

        if (cartItemId == null || requestedQuantity == null) {
            writeJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST,
                    "{\"success\":false,\"message\":\"So luong cap nhat khong hop le.\"}");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        List<CartItem> cartItems = cartDAO.getCartItemsByCustomerId(customerId);
        CartItem targetItem = findCartItem(cartItems, cartItemId);

        if (targetItem == null) {
            writeJsonResponse(response, HttpServletResponse.SC_NOT_FOUND,
                    "{\"success\":false,\"message\":\"Khong tim thay san pham trong gio hang.\"}");
            return;
        }

        int availableStock = 0;
        if (targetItem.getProduct() != null) {
            availableStock = targetItem.getProduct().getQuantity();
        }

        if (targetItem.getProduct() == null || !targetItem.getProduct().isAvailableForSale()) {
            writeJsonResponse(response, HttpServletResponse.SC_CONFLICT,
                    "{\"success\":false,\"message\":\"San pham hien khong con kinh doanh.\"}");
            return;
        }

        if (availableStock <= 0) {
            writeJsonResponse(response, HttpServletResponse.SC_CONFLICT,
                    "{\"success\":false,\"message\":\"San pham hien da het hang.\"}");
            return;
        }

        int appliedQuantity = Math.min(requestedQuantity, availableStock);
        boolean updateSuccess = cartDAO.updateCartItemQuantity(cartItemId, appliedQuantity);

        if (!updateSuccess) {
            writeJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "{\"success\":false,\"message\":\"Khong the cap nhat so luong san pham luc nay.\"}");
            return;
        }

        List<CartItem> refreshedCartItems = cartDAO.getCartItemsByCustomerId(customerId);
        int cartItemCount = calculateCartItemCount(refreshedCartItems);
        session.setAttribute(SESSION_CART_ITEM_COUNT, cartItemCount);
        session.removeAttribute(LEGACY_SESSION_CART_QUANTITIES);

        String message = appliedQuantity < requestedQuantity
                ? "So luong vuot ton kho. Da cap nhat muc toi da co the mua."
                : "Da cap nhat so luong san pham.";

        writeJsonResponse(response, HttpServletResponse.SC_OK,
                "{\"success\":true,\"message\":\"" + message + "\",\"cartItemCount\":" + cartItemCount
                + ",\"quantity\":" + appliedQuantity + "}");
    }

    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        boolean ajaxRequest = isAjaxRequest(request);
        String returnUrl = resolveReturnUrl(request);

        if (account == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED,
                        "{\"success\":false,\"message\":\"Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.\"}");
            } else {
                setProductDetailFlash(session,
                        "Bạn cần đăng nhập để thêm sản phẩm vào giỏ hàng.",
                        "error");
                response.sendRedirect(request.getContextPath() + "/Login");
            }
            return;
        }

        Integer customerId = getCustomerId(account);
        if (customerId == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_FORBIDDEN,
                        "{\"success\":false,\"message\":\"Tài khoản nhân viên không thể thêm sản phẩm vào giỏ hàng.\"}");
            } else {
                setProductDetailFlash(session,
                        "Tài khoản nhân viên không thể thêm sản phẩm vào giỏ hàng.",
                        "error");
                response.sendRedirect(request.getContextPath() + "/Dashboard");
            }
            return;
        }

        Integer productId = parsePositiveInteger(request.getParameter("productId"));
        Integer requestedQuantity = parsePositiveInteger(request.getParameter("quantity"));

        if (productId == null || requestedQuantity == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST,
                        "{\"success\":false,\"message\":\"Thông tin sản phẩm không hợp lệ.\"}");
            } else {
                setProductDetailFlash(session,
                        "Thông tin sản phẩm không hợp lệ.",
                        "error");
                response.sendRedirect(returnUrl);
            }
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        Product product = productDAO.getProductById(productId);

        if (product == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_NOT_FOUND,
                        "{\"success\":false,\"message\":\"Sản phẩm không tồn tại.\"}");
            } else {
                setProductDetailFlash(session,
                        "Sản phẩm không tồn tại.",
                        "error");
                response.sendRedirect(returnUrl);
            }
            return;
        }

        if (!product.isAvailableForSale()) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_CONFLICT,
                        "{\"success\":false,\"message\":\"Sản phẩm hiện không còn kinh doanh.\"}");
            } else {
                setProductDetailFlash(session,
                        "Sản phẩm hiện không còn kinh doanh.",
                        "error");
                response.sendRedirect(returnUrl);
            }
            return;
        }

        int stockQuantity = product.getQuantity();

        if (stockQuantity <= 0) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_CONFLICT,
                        "{\"success\":false,\"message\":\"Sản phẩm hiện đã hết hàng.\"}");
            } else {
                setProductDetailFlash(session,
                        "Sản phẩm hiện đã hết hàng.",
                        "error");
                response.sendRedirect(returnUrl);
            }
            return;
        }

        CartDAO cartDAO = new CartDAO();
        List<CartItem> cartItems = cartDAO.getCartItemsByCustomerId(customerId);

        CartItem existingItem = findCartItemByProductId(cartItems, productId);

        int currentCartQuantity = 0;
        if (existingItem != null) {
            currentCartQuantity = existingItem.getQuantity();
        }

        if (currentCartQuantity >= stockQuantity) {
            String message = "Số lượng sản phẩm trong giỏ hàng hiện đang bằng số lượng sản phẩm trong kho, không thể thêm sản phẩm vào giỏ hàng.";

            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_CONFLICT,
                        "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}");
            } else {
                setProductDetailFlash(session, message, "error");
                response.sendRedirect(returnUrl);
            }
            return;
        }

        if (currentCartQuantity + requestedQuantity > stockQuantity) {
            int canAddMore = stockQuantity - currentCartQuantity;

            String message = "Số lượng muốn thêm vượt quá số lượng trong kho. Bạn chỉ có thể thêm tối đa "
                    + canAddMore + " sản phẩm nữa.";

            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_CONFLICT,
                        "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}");
            } else {
                setProductDetailFlash(session, message, "error");
                response.sendRedirect(returnUrl);
            }
            return;
        }

        boolean updateSuccess;

        if (existingItem != null) {
            int newQuantity = currentCartQuantity + requestedQuantity;
            updateSuccess = cartDAO.updateCartItemQuantity(existingItem.getCartItemId(), newQuantity);
        } else {
            updateSuccess = cartDAO.addCartItemForCustomer(customerId, productId, requestedQuantity) > 0;
        }

        if (!updateSuccess) {
            String message = "Không thể thêm sản phẩm vào giỏ hàng lúc này.";

            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}");
            } else {
                setProductDetailFlash(session, message, "error");
                response.sendRedirect(returnUrl);
            }
            return;
        }

        List<CartItem> refreshedCartItems = cartDAO.getCartItemsByCustomerId(customerId);
        int cartItemCount = calculateCartItemCount(refreshedCartItems);

        session.setAttribute(SESSION_CART_ITEM_COUNT, cartItemCount);
        session.removeAttribute(LEGACY_SESSION_CART_QUANTITIES);

        String successMessage = "Thêm vào giỏ hàng thành công.";

        if (ajaxRequest) {
            writeJsonResponse(response, HttpServletResponse.SC_OK,
                    "{\"success\":true,\"message\":\"" + escapeJson(successMessage)
                    + "\",\"cartItemCount\":" + cartItemCount + "}");
            return;
        }

        setProductDetailFlash(session, successMessage, "success");
        response.sendRedirect(returnUrl);
    }

    private void handleRemoveCartItem(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        Integer customerId = getCustomerId(account);
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return;
        }

        Integer cartItemId = parsePositiveInteger(request.getParameter("cartItemId"));
        if (cartItemId == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        cartDAO.removeCartItemByCustomerId(customerId, cartItemId);

        List<CartItem> remainingCartItems = cartDAO.getCartItemsByCustomerId(customerId);
        session.setAttribute(SESSION_CART_ITEM_COUNT, calculateCartItemCount(remainingCartItems));
        session.removeAttribute(LEGACY_SESSION_CART_QUANTITIES);

        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private int calculateCartItemCount(List<CartItem> cartItems) {
        int totalCount = 0;

        for (CartItem item : cartItems) {
            totalCount += item.getQuantity();
        }

        return totalCount;
    }

    private CartItem findCartItem(List<CartItem> cartItems, int cartItemId) {
        for (CartItem item : cartItems) {
            if (item.getCartItemId() == cartItemId) {
                return item;
            }
        }

        return null;
    }

    private Integer getCustomerId(User account) {
        return account != null && account.isCustomer() ? account.getCustomerId() : null;
    }

    private CartItem findCartItemByProductId(List<CartItem> cartItems, int productId) {
        for (CartItem item : cartItems) {
            if (item.getProductId() == productId) {
                return item;
            }
        }

        return null;
    }

    private Integer parsePositiveInteger(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        return "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
    }

    private String resolveReturnUrl(HttpServletRequest request) {
        String redirect = request.getParameter("redirect");

        if (redirect != null && !redirect.trim().isEmpty()) {
            return redirect;
        }

        String referer = request.getHeader("Referer");

        if (referer != null && !referer.trim().isEmpty()) {
            return referer;
        }

        return request.getContextPath() + "/cart";
    }

    private void writeJsonResponse(HttpServletResponse response, int status, String jsonBody)
            throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(jsonBody);
    }

    private void moveFlashMessage(HttpSession session, HttpServletRequest request, String sessionKey, String requestKey) {
        if (session == null) {
            return;
        }

        Object flashMessage = session.getAttribute(sessionKey);
        if (flashMessage == null) {
            return;
        }

        request.setAttribute(requestKey, flashMessage);
        session.removeAttribute(sessionKey);
    }

    private void setProductDetailFlash(HttpSession session, String message, String type) {
        session.setAttribute("cartMessage", message);
        session.setAttribute("cartMessageType", type);
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
