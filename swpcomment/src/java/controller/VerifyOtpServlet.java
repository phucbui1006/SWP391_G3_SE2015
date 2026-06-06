package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "VerifyOtpServlet", urlPatterns = {"/VerifyOtp"})
public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/verify-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String inputOtp = request.getParameter("otp");

        HttpSession session = request.getSession();

        String resetOtp = (String) session.getAttribute("resetOtp");
        Long expiredTime = (Long) session.getAttribute("otpExpiredTime");

        if (resetOtp == null || expiredTime == null) {
            response.sendRedirect(request.getContextPath() + "/ForgotPassword");
            return;
        }

        if (System.currentTimeMillis() > expiredTime) {
            request.setAttribute("error", "Mã OTP đã hết hạn!");
            request.getRequestDispatcher("/views/verify-otp.jsp").forward(request, response);
            return;
        }

        if (!resetOtp.equals(inputOtp)) {
            request.setAttribute("error", "Mã OTP không đúng!");
            request.getRequestDispatcher("/views/verify-otp.jsp").forward(request, response);
            return;
        }

        session.setAttribute("otpVerified", true);

        response.sendRedirect(request.getContextPath() + "/ResetPassword");
    }
}
