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
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        // Tạo một biến tạm để giữ mật khẩu cũ/mới trong quá trình xử lý logic
        String currentPasswordInSession = account.getPassword();
        String passwordToUpdate = currentPasswordInSession;
        boolean isChangingPassword = false;

        try {
            // Tình huống 1: Người dùng có điền vào ô đổi mật khẩu
            if (oldPassword != null && !oldPassword.trim().isEmpty()) {
                oldPassword = oldPassword.trim();

                // KIỂM TRA ĐIỀU KIỆN 1: Mật khẩu cũ nhập vào phải trùng với mật khẩu hiện tại
                if (!oldPassword.equals(currentPasswordInSession)) {
                    request.setAttribute("errorMsg", "Mật khẩu cũ không chính xác!");
                    request.getRequestDispatcher("views/profile.jsp").forward(request, response);
                    return;
                }

                // KIỂM TRA ĐIỀU KIỆN 2: Mật khẩu mới không được rỗng và phải khớp với Confirm
                if (newPassword == null || newPassword.trim().isEmpty()) {
                    request.setAttribute("errorMsg", "Vui lòng nhập mật khẩu mới!");
                    request.getRequestDispatcher("views/profile.jsp").forward(request, response);
                    return;
                }

                newPassword = newPassword.trim();
                confirmPassword = confirmPassword.trim();

                if (!newPassword.equals(confirmPassword)) {
                    request.setAttribute("errorMsg", "Xác nhận mật khẩu mới không trùng khớp!");
                    request.getRequestDispatcher("views/profile.jsp").forward(request, response);
                    return;
                }

                // Đạt điều kiện đổi mật khẩu
                passwordToUpdate = newPassword;
                isChangingPassword = true;
            }

            // 2. Khởi tạo đối tượng DAL kết nối cơ sở dữ liệu thực tế
            UserDAO userDAO = new UserDAO();

            // Thực hiện gọi hàm update dưới Database của bạn 
            // Truyền các tham số: email (lấy từ session làm điều kiện WHERE), fullName mới, password mới
            boolean isUpdated = userDAO.updateProfile(account.getEmail(), fullName, passwordToUpdate);

            if (isUpdated) {
                // 1. Cập nhật họ tên mới vào đối tượng account hiện tại
                account.setFullName(fullName);

                // 2. Nếu người dùng có đổi mật khẩu, phải ghi đè mật khẩu mới vào đối tượng account
                if (isChangingPassword) {
                    account.setPassword(passwordToUpdate); // passwordToUpdate chính là newPassword lúc này
                }

                // 3. Quan trọng nhất: Ghi đè lại đối tượng account đã sửa vào Session
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
