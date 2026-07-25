package controller;

import dal.UserDAO; // Mở comment và import đúng package chứa UserDAO của bạn
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/updateProfile"})
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User account = session == null ? null : (User) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }
        request.getRequestDispatcher("/views/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Thiết lập bộ mã hóa tiếng Việt tránh lỗi font chữ Họ tên khi nhận từ Form
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        // Kiểm tra an toàn bảo mật phiên đăng nhập
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        // Đọc tham số đầu vào từ Form gửi lên
        String fullName = request.getParameter("fullName") == null ? "" : request.getParameter("fullName").trim();
        String oldPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Tạo một biến tạm để giữ mật khẩu cũ/mới trong quá trình xử lý logic
        String currentPasswordInSession = account.getPassword();
        String passwordToUpdate = currentPasswordInSession;
        boolean isChangingPassword = false;

        try {
            boolean hasNewPassword = (newPassword != null && !newPassword.trim().isEmpty());

            if (hasNewPassword) {
                oldPassword = oldPassword.trim();
                newPassword = newPassword.trim();

                // ĐIỀU KIỆN: Mật khẩu cũ nhập vào phải trùng khớp với mật khẩu hiện tại trong Session
                String targetHash = currentPasswordInSession;
                if (currentPasswordInSession != null && currentPasswordInSession.startsWith("!FIRST!")) {
                    targetHash = currentPasswordInSession.substring("!FIRST!".length());
                }

                if (!PasswordUtil.verify(oldPassword, targetHash)) {
                    request.setAttribute("errorMsg", "Mật khẩu cũ không chính xác!");
                    request.setAttribute("enteredFullName", fullName);
                    request.setAttribute("enteredCurrentPassword", oldPassword);
                    request.setAttribute("enteredNewPassword", newPassword);
                    request.setAttribute("enteredConfirmPassword", confirmPassword);
                    request.getRequestDispatcher("/views/profile.jsp").forward(request, response);
                    return;
                }

                passwordToUpdate = newPassword;
                isChangingPassword = true;
            }

            // 2. Khởi tạo đối tượng DAL kết nối cơ sở dữ liệu thực tế
            UserDAO userDAO = new UserDAO();
            boolean isUpdated = userDAO.updateProfile(account.getEmail(), fullName, passwordToUpdate);

            if (isUpdated) {
                account.setFullName(fullName);
                if (isChangingPassword) {
                    account.setPassword(PasswordUtil.hash(passwordToUpdate));
                }
                session.setAttribute("account", account);
                request.setAttribute("successMsg", "Lưu thành công!");
            } else {
                request.setAttribute("errorMsg", "Lưu thất bại! Đã xảy ra lỗi ở tầng cơ sở dữ liệu.");
                request.setAttribute("enteredFullName", fullName);
                request.setAttribute("enteredCurrentPassword", oldPassword);
                request.setAttribute("enteredNewPassword", newPassword);
                request.setAttribute("enteredConfirmPassword", confirmPassword);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "Lỗi hệ thống cục bộ: " + e.getMessage());
        }

        // Trả kết quả kèm các thông điệp phản hồi về trang profile.jsp hiển thị
        request.getRequestDispatcher("/views/profile.jsp").forward(request, response);
    }
}
