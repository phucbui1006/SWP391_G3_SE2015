package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.User;

@WebServlet(name = "LoginServlet", urlPatterns = {"/Login"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Lấy session hiện tại mà không tạo mới (nếu không tồn tại trả về null)
        HttpSession session = request.getSession(false);
        
        // Nếu người dùng đã đăng nhập trước đó rồi (Session còn hạn và tồn tại "account")
        if (session != null && session.getAttribute("account") != null) {
            // Tự động chuyển hướng thẳng về trang chủ, không bắt họ đăng nhập lại
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        // Nếu chưa đăng nhập, hiển thị giao diện đăng nhập bình thường
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Thiết lập mã hóa dữ liệu đầu vào tránh lỗi font tiếng Việt (nếu có)
        request.setCharacterEncoding("UTF-8");

        // 1. Lấy tham số và xóa khoảng trắng thừa ở đầu/cuối chuỗi bằng .trim()
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email != null) email = email.trim();
        if (password != null) password = password.trim();

        // Kiểm tra dữ liệu rỗng nhanh trước khi gọi Database
        if (email == null || email.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Email và mật khẩu không được để trống!");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        // 2. Gọi tầng DAL để xác thực tài khoản từ database
        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);
        if (user != null) {
    HttpSession session = request.getSession();
    session.setAttribute("account", user); // Lưu đối tượng user vào session với key là "account"
}

        // Trường hợp đăng nhập thất bại (Sai tài khoản hoặc mật khẩu)
        if (user == null) {
            request.setAttribute("error", "Email hoặc mật khẩu không đúng!");
            // Giữ lại email người dùng vừa nhập trong ô input để họ không phải gõ lại
            request.setAttribute("enteredEmail", email); 
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        // Trường hợp tài khoản bị khóa (Banned) - Nghiệp vụ kiểm tra trạng thái
        if (user.getStatus() != null && "BANNED".equalsIgnoreCase(user.getStatus().trim())) {
            request.setAttribute("error", "Tài khoản của bạn đã bị khóa khỏi hệ thống!");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        // 3. Đăng nhập thành công -> Khởi tạo Session và lưu trữ đối tượng User
        HttpSession session = request.getSession(true); // Đảm bảo tạo mới hoặc lấy session hợp lệ
        session.setAttribute("account", user);

        // 4. Chuẩn hóa chuỗi Quyền (Role) để ép về chữ IN HOA, loại bỏ khoảng trắng thừa
        String roleName = user.getRoleName();
        if (roleName != null) {
            roleName = roleName.trim().toUpperCase();
        } else {
            roleName = "";
        }

        // 5. Điều hướng phân quyền màn hình chính xác sau đăng nhập
        switch (roleName) {
            case "ADMIN":
                response.sendRedirect(request.getContextPath() + "/Dashboard");
                break;

            case "CUSTOMER":
                response.sendRedirect(request.getContextPath() + "/home");
                break;

            case "EMPLOYEE":
                response.sendRedirect(request.getContextPath() + "/Dashboard");
                break;

            case "SHIPMENT":
                response.sendRedirect(request.getContextPath() + "/Dashboard");
                break;

            default:
                // Nếu dính lỗi Role lạ hoặc lỗi dữ liệu trống, đá ngược lại trang Login kèm cảnh báo
                session.removeAttribute("account"); // Hủy session lỗi vừa tạo
                request.setAttribute("error", "Tài khoản chưa được cấp quyền truy cập hợp lệ!");
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
                break;
        }
    }
}