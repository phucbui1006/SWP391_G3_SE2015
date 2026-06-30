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

@WebServlet(name = "LoginServlet", urlPatterns = {"/Login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        if (account != null) {
            redirectAfterLogin(request, response, account);
            return;
        }

        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = safeTrim(request.getParameter("email"));
        String password = request.getParameter("password");

        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);

        if (user == null) {
            request.setAttribute("error", "Email hoac mat khau khong dung!");
            request.setAttribute("enteredEmail", email);
            request.setAttribute("enteredPassword", password);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        if (!"ACTIVE".equalsIgnoreCase(safeTrim(user.getStatus()))) {
            request.setAttribute("error", "Tai khoan cua ban da bi khoa hoac chua duoc kich hoat!");
            request.setAttribute("enteredEmail", email);
            request.setAttribute("enteredPassword", password);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        if (!isValidAccountShape(user)) {
            request.setAttribute("error", "Tai khoan chua duoc cau hinh dung loai truy cap!");
            request.setAttribute("enteredEmail", email);
            request.setAttribute("enteredPassword", password);
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession(true);

        if (user.isStaff() && user.getPassword() != null && user.getPassword().startsWith("!FIRST!")) {
            session.setAttribute("tempAccount", user);
            response.sendRedirect(request.getContextPath() + "/ForceChangePassword");
            return;
        }

        session.setAttribute("account", user);
        redirectAfterLogin(request, response, user);
    }

    private void redirectAfterLogin(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        if (user.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if (user.isStaff()) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/Login");
    }

    private boolean isValidAccountShape(User user) {
        if (user == null) {
            return false;
        }

        if (user.isCustomer()) {
            return "CUSTOMER".equalsIgnoreCase(user.getRoleName());
        }

        if (user.isStaff()) {
            String roleName = safeTrim(user.getRoleName()).toUpperCase();
            return "ADMIN".equals(roleName) || "EMPLOYEE".equals(roleName) || "SHIPMENT".equals(roleName);
        }

        return false;
    }

    private String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }
}
