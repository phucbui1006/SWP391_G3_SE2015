package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/Register"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = safeTrim(request.getParameter("fullName"));
        String email = safeTrim(request.getParameter("email"));
        String password = safeTrim(request.getParameter("password"));
        String confirmPassword = safeTrim(request.getParameter("confirmPassword"));

        UserDAO dao = new UserDAO();
        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Mật khẩu không được để trống hoặc chỉ chứa dấu cách!");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }
        // Chuỗi Regex định dạng cấu trúc Email tiêu chuẩn
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";

        if (email == null || !email.matches(emailRegex)) {
            request.setAttribute("error", "Định dạng Email không hợp lệ! Vui lòng kiểm tra lại.");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        if (fullName.isEmpty() || email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty()) {
            request.setAttribute("error", "Vui long nhap day du thong tin dang ky!");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mat khau xac nhan khong khop!");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        if (dao.checkEmailExist(email)) {
            request.setAttribute("error", "Email da ton tai!");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        boolean success = dao.registerCustomer(fullName, email, password);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/Login");
        } else {
            request.setAttribute("error", "Dang ky that bai!");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
        }
    }

    private String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }
}
