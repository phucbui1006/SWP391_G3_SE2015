package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.Random;
import util.EmailService;

@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/ForgotPassword"})
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/forget-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email!");
            request.getRequestDispatcher("/views/forget-password.jsp").forward(request, response);
            return;
        }

        email = email.trim();

        UserDAO userDAO = new UserDAO();
        if (!userDAO.checkEmailExist(email)) {
            request.setAttribute("error", "Email không tồn tại trong hệ thống!");
            request.getRequestDispatcher("/views/forget-password.jsp").forward(request, response);
            return;
        }

        String otp = String.format("%06d", new Random().nextInt(1000000));

        HttpSession session = request.getSession();
        session.setAttribute("resetEmail", email);
        session.setAttribute("resetOtp", otp);
        session.setAttribute("otpExpiredTime", System.currentTimeMillis() + 5 * 60 * 1000);

        System.out.println("OTP tao ra la: " + otp);

        boolean sent = EmailService.sendOtpEmail(email, otp);

        if (sent) {
            response.sendRedirect(request.getContextPath() + "/VerifyOtp");
        } else {
            request.setAttribute("error", "Không gửi được email. Kiểm tra App Password hoặc cấu hình Gmail!");
            request.getRequestDispatcher("/views/forget-password.jsp").forward(request, response);
        }
    }
}
