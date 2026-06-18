package controller;

import dal.CartDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.User;

@WebServlet(name = "BuildPCServlet", urlPatterns = {"/build-pc", "/BuildPC"})
public class BuildPCServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        User account = (User) request.getSession().getAttribute("account");
        if (account != null && account.isCustomer()) {
            CartDAO cartDAO = new CartDAO();
            request.setAttribute("cartItemCount", cartDAO.getCartItemCountByCustomerId(account.getCustomerId()));
        }

        request.getRequestDispatcher("/views/build-pc.jsp").forward(request, response);
    }
}
