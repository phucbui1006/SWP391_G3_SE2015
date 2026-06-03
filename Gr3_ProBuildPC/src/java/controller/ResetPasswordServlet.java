package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "ResetPasswordServlet", urlPatterns = {"/ResetPassword"})
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();

        Boolean otpVerified = (Boolean) session.getAttribute("otpVerified");

        if (otpVerified == null || !otpVerified) {
            response.sendRedirect(request.getContextPath() + "/ForgotPassword");
            return;
        }

        request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        Boolean otpVerified = (Boolean) session.getAttribute("otpVerified");
        String resetEmail = (String) session.getAttribute("resetEmail");

        if (otpVerified == null || !otpVerified || resetEmail == null) {
            response.sendRedirect(request.getContextPath() + "/ForgotPassword");
            return;
        }

        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
            return;
        }

        UserDAO dao = new UserDAO();

        boolean success = dao.updatePassword(resetEmail, password);

        if (success) {
            session.removeAttribute("resetEmail");
            session.removeAttribute("resetOtp");
            session.removeAttribute("otpExpiredTime");
            session.removeAttribute("otpVerified");

            response.sendRedirect(request.getContextPath() + "/Login");
        } else {
            request.setAttribute("error", "Cập nhật mật khẩu thất bại!");
            request.getRequestDispatcher("/views/reset-password.jsp").forward(request, response);
        }
    }
}