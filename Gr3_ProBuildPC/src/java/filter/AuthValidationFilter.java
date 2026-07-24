package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import util.ValidatorUtil;

@WebFilter(filterName = "AuthValidationFilter", urlPatterns = {
    "/Register",
    "/ForgotPassword",
    "/VerifyOtp",
    "/VerifyRegisterOtp",
    "/ResetPassword",
    "/ForceChangePassword",
    "/Login"
})
public class AuthValidationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        // Only validate POST requests
        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        boolean isValid = true;

        if ("/Register".equalsIgnoreCase(path)) {
            isValid = validateRegister(req, res);
        } else if ("/ForgotPassword".equalsIgnoreCase(path)) {
            isValid = validateForgotPassword(req, res);
        } else if ("/VerifyOtp".equalsIgnoreCase(path) || "/VerifyRegisterOtp".equalsIgnoreCase(path)) {
            isValid = validateOtp(req, res, path);
        } else if ("/ResetPassword".equalsIgnoreCase(path)) {
            isValid = validateResetPassword(req, res);
        } else if ("/ForceChangePassword".equalsIgnoreCase(path)) {
            isValid = validateForceChangePassword(req, res);
        } else if ("/Login".equalsIgnoreCase(path)) {
            isValid = validateLogin(req, res);
        }

        if (isValid) {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {}

    private boolean validateLogin(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        
        if (!ValidatorUtil.isValidEmail(email) || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email hoặc mật khẩu không hợp lệ!");
            req.getRequestDispatcher("/views/login.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateRegister(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (!ValidatorUtil.isValidName(fullName)) {
            error = "Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.";
        } else if (!ValidatorUtil.isValidEmail(email)) {
            error = "Định dạng email không hợp lệ (tối đa 100 ký tự).";
        } else if (!ValidatorUtil.isValidPassword(password)) {
            error = "Mật khẩu từ 8-31 ký tự, không chứa tiếng Việt có dấu, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.";
        } else if (confirmPassword == null || !confirmPassword.equals(password)) {
            error = "Mật khẩu xác nhận không khớp!";
        }

        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/views/register.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateForgotPassword(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String email = req.getParameter("email");

        if (!ValidatorUtil.isValidEmail(email)) {
            req.setAttribute("error", "Định dạng email không hợp lệ (tối đa 100 ký tự).");
            req.getRequestDispatcher("/views/forget-password.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateOtp(HttpServletRequest req, HttpServletResponse res, String path) throws ServletException, IOException {
        String otp = req.getParameter("otp");

        if (!ValidatorUtil.isValidOtpCode(otp)) {
            req.setAttribute("error", "Mã OTP phải gồm đúng 6 chữ số.");
            String targetJsp = "/VerifyOtp".equalsIgnoreCase(path) ? "/views/verify-otp.jsp" : "/views/verify-register-otp.jsp";
            req.getRequestDispatcher(targetJsp).forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateResetPassword(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (!ValidatorUtil.isValidPassword(password)) {
            error = "Mật khẩu từ 8-31 ký tự, không chứa tiếng Việt có dấu, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.";
        } else if (confirmPassword == null || !confirmPassword.equals(password)) {
            error = "Mật khẩu xác nhận không khớp!";
        }

        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/views/reset-password.jsp").forward(req, res);
            return false;
        }
        return true;
    }

    private boolean validateForceChangePassword(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        String error = null;
        if (!ValidatorUtil.isValidPassword(newPassword)) {
            error = "Mật khẩu từ 8-31 ký tự, không chứa tiếng Việt có dấu, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.";
        } else if (confirmPassword == null || !confirmPassword.equals(newPassword)) {
            error = "Mật khẩu xác nhận không khớp!";
        }

        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/views/force-change-password.jsp").forward(req, res);
            return false;
        }
        return true;
    }
}
