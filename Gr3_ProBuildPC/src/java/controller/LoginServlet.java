package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

@WebServlet(name = "LoginServlet", urlPatterns = {"/Login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);

        if (user == null) {
            request.setAttribute("error", "Email hoặc mật khẩu không đúng!");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("account", user);

        switch (user.getRoleName()) {
            case "ADMIN":
                response.sendRedirect(request.getContextPath() + "/Dashboard");
                break;

            case "CUSTOMER":
                response.sendRedirect(request.getContextPath() + "/Dashboard");
                break;

            case "EMPLOYEE":
                response.sendRedirect(request.getContextPath() + "/Dashboard");
                break;

            case "SHIPMENT":
                response.sendRedirect(request.getContextPath() + "/Dashboard");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/Login");
                break;
        }
    }
}
