package controller;

import dal.CartDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.User;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");
        List<CartItem> cartItems = new ArrayList<>();
        BigDecimal subtotal = BigDecimal.ZERO;
        int cartItemCount = 0;

        if (account != null) {
            CartDAO cartDAO = new CartDAO();
            cartItems = cartDAO.getCartItemsByUserId(account.getUserId());
            subtotal = cartDAO.calculateSubtotal(cartItems);
            cartItemCount = cartDAO.getCartItemCountByUserId(account.getUserId());
        }

        request.setAttribute("cartItems", cartItems);
        request.setAttribute("cartSubtotal", subtotal);
        request.setAttribute("cartTotal", subtotal);
        request.setAttribute("cartItemCount", cartItemCount);
        request.getRequestDispatcher("/views/cart.jsp").forward(request, response);
    }
}
