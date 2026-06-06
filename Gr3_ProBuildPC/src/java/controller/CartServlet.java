package controller;

import dal.CartDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.CartItem;
import model.User;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private static final String SESSION_CART_QUANTITIES = "sessionCartQuantities";
    private static final String SESSION_CART_ITEM_COUNT = "sessionCartItemCount";

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
            applySessionQuantities(cartItems, getSessionCartQuantities(session));
            subtotal = cartDAO.calculateSubtotal(cartItems);
            cartItemCount = calculateCartItemCount(cartItems);
            session.setAttribute(SESSION_CART_ITEM_COUNT, cartItemCount);
        } else {
            session.removeAttribute(SESSION_CART_QUANTITIES);
            session.removeAttribute(SESSION_CART_ITEM_COUNT);
        }

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
        if ("updateSessionQuantity".equals(action)) {
            handleSessionQuantityUpdate(request, response);
            return;
        }
        if ("removeCartItem".equals(action)) {
            handleRemoveCartItem(request, response);
            return;
        }

        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void handleSessionQuantityUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        Integer cartItemId = parsePositiveInteger(request.getParameter("cartItemId"));
        Integer quantity = parsePositiveInteger(request.getParameter("quantity"));

        if (cartItemId == null || quantity == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        CartDAO cartDAO = new CartDAO();
        List<CartItem> cartItems = cartDAO.getCartItemsByUserId(account.getUserId());
        CartItem targetItem = findCartItem(cartItems, cartItemId);

        if (targetItem == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Map<Integer, Integer> sessionQuantities = getSessionCartQuantities(session);
        if (quantity.intValue() == targetItem.getQuantity()) {
            sessionQuantities.remove(cartItemId);
        } else {
            sessionQuantities.put(cartItemId, quantity);
        }

        if (sessionQuantities.isEmpty()) {
            session.removeAttribute(SESSION_CART_QUANTITIES);
        } else {
            session.setAttribute(SESSION_CART_QUANTITIES, sessionQuantities);
        }

        applySessionQuantities(cartItems, sessionQuantities);
        int cartItemCount = calculateCartItemCount(cartItems);
        session.setAttribute(SESSION_CART_ITEM_COUNT, cartItemCount);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write("{\"success\":true,\"cartItemCount\":" + cartItemCount + "}");
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

        Map<Integer, Integer> sessionQuantities = getSessionCartQuantities(session);
        sessionQuantities.remove(cartItemId);

        if (sessionQuantities.isEmpty()) {
            session.removeAttribute(SESSION_CART_QUANTITIES);
        } else {
            session.setAttribute(SESSION_CART_QUANTITIES, sessionQuantities);
        }

        List<CartItem> remainingCartItems = cartDAO.getCartItemsByUserId(account.getUserId());
        applySessionQuantities(remainingCartItems, sessionQuantities);
        session.setAttribute(SESSION_CART_ITEM_COUNT, calculateCartItemCount(remainingCartItems));

        response.sendRedirect(request.getContextPath() + "/cart");
    }

    private void applySessionQuantities(List<CartItem> cartItems, Map<Integer, Integer> sessionQuantities) {
        if (sessionQuantities == null || sessionQuantities.isEmpty()) {
            return;
        }

        for (CartItem item : cartItems) {
            Integer overriddenQuantity = sessionQuantities.get(item.getCartItemId());
            if (overriddenQuantity != null && overriddenQuantity > 0) {
                item.setQuantity(overriddenQuantity);
            }
        }
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

    private Integer parsePositiveInteger(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    @SuppressWarnings("unchecked")
    private Map<Integer, Integer> getSessionCartQuantities(HttpSession session) {
        Object rawSessionQuantities = session.getAttribute(SESSION_CART_QUANTITIES);
        if (rawSessionQuantities instanceof Map) {
            return (Map<Integer, Integer>) rawSessionQuantities;
        }

        Map<Integer, Integer> sessionQuantities = new HashMap<>();
        session.setAttribute(SESSION_CART_QUANTITIES, sessionQuantities);
        return sessionQuantities;
    }
}
