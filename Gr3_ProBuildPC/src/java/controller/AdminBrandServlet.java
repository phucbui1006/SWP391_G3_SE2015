package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "AdminBrandServlet", urlPatterns = {"/AdminBrands"})
public class AdminBrandServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User user = (User) session.getAttribute("account");
        String roleName = user.getRoleName();
        if (roleName == null || !"ADMIN".equals(roleName.trim().toUpperCase())) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return;
        }

        request.getRequestDispatcher("/views/admin-brands.jsp").forward(request, response);
    }
}
