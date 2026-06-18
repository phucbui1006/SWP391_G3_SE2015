package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "VerifyRegisterOtpServlet", urlPatterns = {"/VerifyRegisterOtp"})
public class VerifyRegisterOtpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/verify-register-otp.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String inputOtp = request.getParameter("otp");

        HttpSession session = request.getSession();

        String regOtp = (String) session.getAttribute("regOtp");
        Long expiredTime = (Long) session.getAttribute("regOtpExpiredTime");

        if (regOtp == null || expiredTime == null) {
            response.sendRedirect(request.getContextPath() + "/Register");
            return;
        }

        if (System.currentTimeMillis() > expiredTime) {
            request.setAttribute("error", "Mã OTP đã hết hạn!");
            request.getRequestDispatcher("/views/verify-register-otp.jsp").forward(request, response);
            return;
        }

        if (!regOtp.equals(inputOtp)) {
            request.setAttribute("error", "Mã OTP không đúng!");
            request.getRequestDispatcher("/views/verify-register-otp.jsp").forward(request, response);
            return;
        }

        // OTP is correct, process registration
        String fullName = (String) session.getAttribute("regFullName");
        String email = (String) session.getAttribute("regEmail");
        String password = (String) session.getAttribute("regPassword");

        UserDAO dao = new UserDAO();
        boolean success = dao.registerCustomer(fullName, email, password);

        if (success) {
            // Clear session attributes
            session.removeAttribute("regOtp");
            session.removeAttribute("regOtpExpiredTime");
            session.removeAttribute("regFullName");
            session.removeAttribute("regEmail");
            session.removeAttribute("regPassword");
            
            response.sendRedirect(request.getContextPath() + "/Login");
        } else {
            request.setAttribute("error", "Đăng ký thất bại!");
            request.getRequestDispatcher("/views/verify-register-otp.jsp").forward(request, response);
        }
    }
}
