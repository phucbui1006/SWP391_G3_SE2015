package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "ForceChangePasswordServlet", urlPatterns = {"/ForceChangePassword"})
public class ForceChangePasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("tempAccount") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        request.getRequestDispatcher("/views/force-change-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("tempAccount") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User tempAccount = (User) session.getAttribute("tempAccount");

        String newPassword = request.getParameter("newPassword");

        UserDAO userDAO = new UserDAO();
        if (userDAO.updatePassword(tempAccount.getEmail(), newPassword)) {
            // Success
            tempAccount.setPassword(newPassword); // remove !FIRST! from session object too
            session.removeAttribute("tempAccount");
            session.setAttribute("account", tempAccount);
            
            // Redirect to dashboard
            response.sendRedirect(request.getContextPath() + "/Dashboard");
        } else {
            request.setAttribute("error", "Đổi mật khẩu thất bại. Vui lòng thử lại!");
            request.getRequestDispatcher("/views/force-change-password.jsp").forward(request, response);
        }
    }
}
