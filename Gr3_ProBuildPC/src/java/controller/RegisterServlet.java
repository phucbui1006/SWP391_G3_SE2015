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
        if (dao.checkEmailExist(email)) {
            request.setAttribute("error", "Email đã tồn tại!");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
            return;
        }

        jakarta.servlet.http.HttpSession session = request.getSession();
        Long expiredTime = (Long) session.getAttribute("regOtpExpiredTime");
        String currentEmail = (String) session.getAttribute("regEmail");

        if (expiredTime != null && currentEmail != null && currentEmail.equals(email)) {
            long remainingTime = expiredTime - System.currentTimeMillis();
            if (remainingTime > 0) {
                long minutes = remainingTime / 60000;
                long seconds = (remainingTime % 60000) / 1000;
                request.setAttribute("error", String.format("Mã OTP đã được gửi. Vui lòng kiểm tra hòm thư hoặc thử lại sau %d phút %d giây.", minutes, seconds));
                request.getRequestDispatcher("/views/register.jsp").forward(request, response);
                return;
            }
        }

        // Generate OTP
        //String otp = String.format("%06d", new java.util.Random().nextInt(1000000));
        //String otp = RandomStringUtils.randomAlphanumeric(6);
        // Generate OTP using Generex
        com.mifmif.common.regex.Generex generex = new com.mifmif.common.regex.Generex("[0-9]{6}");
        String otp = generex.random();

        session.setAttribute("regFullName", fullName);
        session.setAttribute("regEmail", email);
        session.setAttribute("regPassword", password);
        session.setAttribute("regOtp", otp);
        session.setAttribute("regOtpExpiredTime", System.currentTimeMillis() + 2 * 60 * 1000);

        System.out.println("Register OTP tạo ra là: " + otp);

        boolean sent = util.EmailService.sendOtpEmail(email, otp);

        if (sent) {
            response.sendRedirect(request.getContextPath() + "/VerifyRegisterOtp");
        } else {
            request.setAttribute("error", "Không gửi được email mã OTP. Vui lòng thử lại!");
            request.getRequestDispatcher("/views/register.jsp").forward(request, response);
        }
    }

    private String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }
}
