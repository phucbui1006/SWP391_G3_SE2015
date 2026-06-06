package controller;

import dal.UserDAO; // Mở comment và import đúng package chứa UserDAO của bạn
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

@WebServlet("/updateProfile")
public class UpdateProfileServlet extends HttpServlet {

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
        String fullName = request.getParameter("fullName").trim();
        String oldPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Tạo một biến tạm để giữ mật khẩu cũ/mới trong quá trình xử lý logic
        String currentPasswordInSession = account.getPassword();
        String passwordToUpdate = currentPasswordInSession;
        boolean isChangingPassword = false;

        try {
            if (fullName == null || fullName.trim().isEmpty()) {
                request.setAttribute("errorMsg", "Họ và tên không được để trống!");
                request.getRequestDispatcher("views/profile.jsp").forward(request, response);
                return; // Dừng xử lý các logic phía sau
            }
            fullName = fullName.trim();
            // ĐỔI LOGIC KIỂM TRA: Check xem người dùng có muốn đổi mật khẩu hay không (dựa vào 2 ô mật khẩu mới)
            boolean hasNewPassword = (newPassword != null && !newPassword.trim().isEmpty());
            boolean hasConfirmPassword = (confirmPassword != null && !confirmPassword.trim().isEmpty());

            if (hasNewPassword || hasConfirmPassword) {
                // ĐIỀU KIỆN 1: Nếu đã muốn đổi mật khẩu mới thì ô Mật khẩu cũ BẮT BUỘC không được để trống
                if (oldPassword == null || oldPassword.trim().isEmpty()) {
                    request.setAttribute("errorMsg", "Vui lòng nhập mật khẩu cũ để xác nhận thay đổi!");
                    request.getRequestDispatcher("views/profile.jsp").forward(request, response);
                    return;
                }

                oldPassword = oldPassword.trim();
                newPassword = hasNewPassword ? newPassword.trim() : "";
                confirmPassword = hasConfirmPassword ? confirmPassword.trim() : "";

                // ĐIỀU KIỆN 2: Mật khẩu cũ nhập vào phải trùng khớp với mật khẩu hiện tại trong Session
                if (!oldPassword.equals(currentPasswordInSession)) {
                    request.setAttribute("errorMsg", "Mật khẩu cũ không chính xác!");
                    request.getRequestDispatcher("views/profile.jsp").forward(request, response);
                    return;
                }

                // ĐIỀU KIỆN 3: Cả hai ô mật khẩu mới và xác nhận mật khẩu mới không được để trống ô nào
                if (newPassword.isEmpty() || confirmPassword.isEmpty()) {
                    request.setAttribute("errorMsg", "Vui lòng điền đầy đủ cả hai ô Mật khẩu mới và Xác nhận!");
                    request.getRequestDispatcher("views/profile.jsp").forward(request, response);
                    return;
                }

                // ĐIỀU KIỆN 4: Mật khẩu mới và Xác nhận mật khẩu mới phải giống nhau từng ký tự
                if (!newPassword.equals(confirmPassword)) {
                    request.setAttribute("errorMsg", "Xác nhận mật khẩu mới không trùng khớp!");
                    request.getRequestDispatcher("views/profile.jsp").forward(request, response);
                    return;
                }

                // Nếu vượt qua tất cả 4 điều kiện ngặt nghèo trên -> Cho phép lấy mật khẩu mới để update
                passwordToUpdate = newPassword;
                isChangingPassword = true;
            }

            // 2. Khởi tạo đối tượng DAL kết nối cơ sở dữ liệu thực tế
            UserDAO userDAO = new UserDAO();
            boolean isUpdated = userDAO.updateProfile(account.getEmail(), fullName, passwordToUpdate);

            if (isUpdated) {
                account.setFullName(fullName);
                if (isChangingPassword) {
                    account.setPassword(passwordToUpdate);
                }
                session.setAttribute("account", account);
                request.setAttribute("successMsg", "Lưu thành công!");
            } else {
                request.setAttribute("errorMsg", "Lưu thất bại! Đã xảy ra lỗi ở tầng cơ sở dữ liệu.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "Lỗi hệ thống cục bộ: " + e.getMessage());
        }

        // Trả kết quả kèm các thông điệp phản hồi về trang profile.jsp hiển thị
        request.getRequestDispatcher("views/profile.jsp").forward(request, response);
    }
}
