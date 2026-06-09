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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        List<CartItem> cartItems = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        int cartItemCount = 0;

        if (account != null) {
            CartDAO cartDAO = new CartDAO();
            cartItems = cartDAO.getCartItemsByUserId(account.getUserId());
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

        Integer cartItemId = parsePositiveInteger(request.getParameter("cartItemId"));
        Integer requestedQuantity = parsePositiveInteger(request.getParameter("quantity"));

        if (cartItemId == null || requestedQuantity == null) {
            writeJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST,
                    "{\"success\":false,\"message\":\"So luong cap nhat khong hop le.\"}");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        List<CartItem> cartItems = cartDAO.getCartItemsByUserId(account.getUserId());
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

        List<CartItem> refreshedCartItems = cartDAO.getCartItemsByUserId(account.getUserId());
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

        if (account == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_UNAUTHORIZED,
                        "{\"success\":false,\"message\":\"Vui long dang nhap de them san pham vao gio hang.\"}");
            } else {
                response.sendRedirect(request.getContextPath() + "/Login");
            }
            return;
        }

        Integer productId = parsePositiveInteger(request.getParameter("productId"));
        Integer requestedQuantity = parsePositiveInteger(request.getParameter("quantity"));

        if (productId == null || requestedQuantity == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_BAD_REQUEST,
                        "{\"success\":false,\"message\":\"Thong tin san pham khong hop le.\"}");
            } else {
                response.sendRedirect(resolveReturnUrl(request));
            }
            return;
        }

        ProductDAO productDAO = new ProductDAO();
        Product product = productDAO.getProductById(productId);

        if (product == null) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_NOT_FOUND,
                        "{\"success\":false,\"message\":\"San pham khong ton tai.\"}");
            } else {
                response.sendRedirect(resolveReturnUrl(request));
            }
            return;
        }

        if (product.getQuantity() <= 0) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_CONFLICT,
                        "{\"success\":false,\"message\":\"San pham hien da het hang.\"}");
            } else {
                response.sendRedirect(resolveReturnUrl(request));
            }
            return;
        }

        CartDAO cartDAO = new CartDAO();
        List<CartItem> cartItems = cartDAO.getCartItemsByUserId(account.getUserId());

        CartItem existingItem = findCartItemByProductId(cartItems, productId);
        int desiredQuantity = requestedQuantity;

        if (existingItem != null) {
            desiredQuantity = existingItem.getQuantity() + requestedQuantity;
        }

        if (desiredQuantity > product.getQuantity()) {
            desiredQuantity = product.getQuantity();
        }

        if (existingItem != null && desiredQuantity == existingItem.getQuantity()) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_CONFLICT,
                        "{\"success\":false,\"message\":\"San pham da dat so luong toi da trong gio hang.\"}");
            } else {
                response.sendRedirect(resolveReturnUrl(request));
            }
            return;
        }

        boolean updateSuccess;
        if (existingItem != null) {
            updateSuccess = cartDAO.updateCartItemQuantity(existingItem.getCartItemId(), desiredQuantity);
        } else {
            updateSuccess = cartDAO.addCartItemForUser(account.getUserId(), productId, desiredQuantity) > 0;
        }

        if (!updateSuccess) {
            if (ajaxRequest) {
                writeJsonResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "{\"success\":false,\"message\":\"Khong the them san pham vao gio hang luc nay.\"}");
            } else {
                response.sendRedirect(resolveReturnUrl(request));
            }
            return;
        }

        List<CartItem> refreshedCartItems = cartDAO.getCartItemsByUserId(account.getUserId());
        int cartItemCount = calculateCartItemCount(refreshedCartItems);
        session.setAttribute(SESSION_CART_ITEM_COUNT, cartItemCount);
        session.removeAttribute(LEGACY_SESSION_CART_QUANTITIES);

        if (ajaxRequest) {
            writeJsonResponse(response, HttpServletResponse.SC_OK,
                    "{\"success\":true,\"message\":\"Da them san pham vao gio hang.\",\"cartItemCount\":" + cartItemCount + "}");
            return;
        }

        response.sendRedirect(resolveReturnUrl(request));
    }

    private void handleRemoveCartItem(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        Integer cartItemId = parsePositiveInteger(request.getParameter("cartItemId"));
        if (cartItemId == null) {
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        cartDAO.removeCartItemByUserId(account.getUserId(), cartItemId);

        List<CartItem> remainingCartItems = cartDAO.getCartItemsByUserId(account.getUserId());
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
}
