package controller;

import dal.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import model.Role;
import model.User;

@WebServlet(name = "AccountManagementServlet", urlPatterns = {"/AccountManagement"})
public class AccountManagementServlet extends HttpServlet {

    private static final int PAGE_SIZE = 5;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = requireAdmin(request, response);
        if (session == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String type = request.getParameter("type");
        if (type == null || (!type.equals("user") && !type.equals("staff"))) {
            type = "user";
        }
        String accountType = type.equals("staff") ? "STAFF" : "CUSTOMER";

        String keyword = normalizeText(request.getParameter("keyword"));
        Integer roleId = parseId(request.getParameter("roleId"));
        String status = normalizeStatus(request.getParameter("status"));
        int page = parsePositiveInt(request.getParameter("page"), 1);

        int totalUsers = userDAO.countUsers(keyword, roleId, status, accountType);
        int totalPages = Math.max(1, (int) Math.ceil(totalUsers / (double) PAGE_SIZE));

        if (page > totalPages) {
            page = totalPages;
        }

        List<User> users = userDAO.getUsers(keyword, roleId, status, accountType, page, PAGE_SIZE);
        List<Role> roles = userDAO.getRoles();

        int offset = (page - 1) * PAGE_SIZE;
        int startItem = totalUsers == 0 ? 0 : offset + 1;
        int endItem = Math.min(page * PAGE_SIZE, totalUsers);

        request.setAttribute("type", type);
        request.setAttribute("users", users);
        request.setAttribute("roles", roles);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedRoleId", roleId);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);

        moveFlashToRequest(session, request, "accountSuccess", "success");
        moveFlashToRequest(session, request, "accountError", "error");

        request.getRequestDispatcher("/views/account-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = requireAdmin(request, response);
        if (session == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");
        User currentAdmin = (User) session.getAttribute("account");

        if ("createStaff".equals(action)) {
            createStaff(request, session);
            response.sendRedirect(request.getContextPath() + "/AccountManagement" + buildQueryString(request));
            return;
        } else if ("resetPassword".equals(action)) {
            Integer targetUserId = parseId(request.getParameter("userId"));
            if (targetUserId != null) {
                resetPassword(request, session, currentAdmin, targetUserId);
            } else {
                session.setAttribute("accountError", "Tài khoản cần reset không hợp lệ.");
            }
            response.sendRedirect(request.getContextPath() + "/AccountManagement" + buildQueryString(request));
            return;
        }

        Integer userId = parseId(request.getParameter("userId"));

        if (userId == null) {
            session.setAttribute("accountError", "Tai khoan can cap nhat khong hop le.");
        } else if ("updateRole".equals(action)) {
            updateRole(request, session, currentAdmin, userId);
        } else if ("updateStatus".equals(action)) {
            updateStatus(request, session, currentAdmin, userId);
        } else {
            session.setAttribute("accountError", "Thao tac khong hop le.");
        }

        response.sendRedirect(request.getContextPath() + "/AccountManagement" + buildQueryString(request));
    }

    private HttpSession requireAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return null;
        }

        User user = (User) session.getAttribute("account");
        String roleName = user.getRoleName();
        if (roleName == null || !"ADMIN".equals(roleName.trim().toUpperCase())) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return null;
        }

        return session;
    }

    private void createStaff(HttpServletRequest request, HttpSession session) {
        String fullName = normalizeText(request.getParameter("fullName"));
        String email = normalizeText(request.getParameter("email"));
        Integer roleId = parseId(request.getParameter("roleId"));

        if (fullName == null || email == null || roleId == null) {
            session.setAttribute("accountError", "Vui long nhap day du thong tin nhan vien.");
            return;
        }

        if (roleId == 1) {
            session.setAttribute("accountError", "Không thể tạo tài khoản quản trị viên mới.");
            return;
        }

        if (userDAO.checkEmailExist(email)) {
            session.setAttribute("accountError", "Email nay da ton tai trong he thong.");
            return;
        }

        // Generate random 8-character password
        String randomPassword = java.util.UUID.randomUUID().toString().substring(0, 8);

        // Add prefix to force password change on first login only for Employee (2) and Shipment (3)
        String initialPassword = randomPassword;
        if (roleId == 2 || roleId == 3) {
            initialPassword = "!FIRST!" + randomPassword;
        }

        // Send email first to verify email exists (if SMTP fails, we don't create account)
        // Note: This relies on SMTP throwing an error if email is malformed or rejected synchronously.
        boolean emailSent = util.EmailService.sendStaffWelcomeEmail(email, randomPassword);
        
        if (!emailSent) {
            session.setAttribute("accountError", "Không thể gửi email đến địa chỉ này. Vui lòng kiểm tra lại email!");
            return;
        }

        if (userDAO.createStaff(fullName, email, initialPassword, roleId)) {
            session.setAttribute("accountSuccess", "Tạo tài khoản nhân viên thành công. Mật khẩu đã được gửi vào email.");
        } else {
            session.setAttribute("accountError", "Không thể tạo nhân viên.");
        }
    }

    private void resetPassword(HttpServletRequest request, HttpSession session, User currentAdmin, int targetUserId) {
        if (currentAdmin.getUserId() == targetUserId) {
            session.setAttribute("accountError", "Bạn không thể tự reset mật khẩu của chính mình.");
            return;
        }

        User targetUser = userDAO.getUserById(targetUserId);
        if (targetUser == null) {
            session.setAttribute("accountError", "Tài khoản không tồn tại.");
            return;
        }

        if (!targetUser.isStaff()) {
            session.setAttribute("accountError", "Chỉ có thể đặt lại mật khẩu của nhân viên.");
            return;
        }

        String randomPassword = java.util.UUID.randomUUID().toString().substring(0, 8);
        String initialPassword = randomPassword;

        if (targetUser.getRoleId() == 2 || targetUser.getRoleId() == 3) {
            initialPassword = "!FIRST!" + randomPassword;
        }

        // Send the reset password email directly to the staff's email
        boolean emailSent = util.EmailService.sendAdminResetPasswordEmail(targetUser.getEmail(), randomPassword);
        
        if (!emailSent) {
            session.setAttribute("accountError", "Không thể gửi email reset mật khẩu đến email của nhân viên.");
            return;
        }

        if (userDAO.updatePassword(targetUser.getEmail(), initialPassword)) {
            session.setAttribute("accountSuccess", "Reset mật khẩu thành công. Mật khẩu mới của nhân viên đã được gửi đến email của họ.");
        } else {
            session.setAttribute("accountError", "Reset mật khẩu thất bại do lỗi Database.");
        }
    }

private void updateRole(HttpServletRequest request, HttpSession session, User currentAdmin, int userId) {
    Integer roleId = parseId(request.getParameter("roleId"));

    // BỔ SUNG ĐIỀU KIỆN: Chặn không cho phép đổi vai trò nhân viên thành Customer (-1)
    if (roleId == null || roleId == -1) {
        session.setAttribute("accountError", "Vai tro cap nhat khong hop le.");
        return;
    }

    if (roleId == 1) {
        session.setAttribute("accountError", "Không thể thay đổi vai trò thành quản trị viên.");
        return;
    }

    User targetUser = userDAO.getUserById(userId);
    if (targetUser == null) {
        session.setAttribute("accountError", "Khong tim thay tai khoan can cap nhat.");
        return;
    }

    if (!targetUser.isStaff()) {
        session.setAttribute("accountError", "Khach hang khong su dung vai tro nhan vien.");
        return;
    }

    if (currentAdmin != null && currentAdmin.getUserId() == userId) {
        session.setAttribute("accountError", "Khong the doi vai tro cua chinh tai khoan dang dang nhap.");
        return;
    }

    if (userDAO.updateUserRole(userId, roleId)) {
        session.setAttribute("accountSuccess", "Cap nhat vai tro tai khoan thanh cong.");
    } else {
        session.setAttribute("accountError", "Khong the cap nhat vai tro tai khoan.");
    }
}

    private void updateStatus(HttpServletRequest request, HttpSession session, User currentAdmin, int userId) {
        String status = normalizeStatus(request.getParameter("status"));

        if (status == null) {
            session.setAttribute("accountError", "Trang thai cap nhat khong hop le.");
            return;
        }

        User targetUser = userDAO.getUserById(userId);
        if (targetUser == null) {
            session.setAttribute("accountError", "Khong tim thay tai khoan can cap nhat.");
            return;
        }

        if (currentAdmin != null && currentAdmin.getUserId() == userId) {
            session.setAttribute("accountError", "Khong the khoa chinh tai khoan dang dang nhap.");
            return;
        }

        if ("ADMIN".equalsIgnoreCase(targetUser.getRoleName()) && "INACTIVE".equals(status)) {
            session.setAttribute("accountError", "Không thể khóa tài khoản quản trị viên.");
            return;
        }

        if (userDAO.updateUserStatus(userId, status)) {
            session.setAttribute("accountSuccess", "Cap nhat trang thai tai khoan thanh cong.");
        } else {
            session.setAttribute("accountError", "Khong the cap nhat trang thai tai khoan.");
        }
    }

    private void moveFlashToRequest(HttpSession session, HttpServletRequest request, String sessionKey, String requestKey) {
        String value = (String) session.getAttribute(sessionKey);

        if (value != null) {
            request.setAttribute(requestKey, value);
            session.removeAttribute(sessionKey);
        }
    }

    private String buildQueryString(HttpServletRequest request) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "type", request.getParameter("type") != null ? request.getParameter("type") : "user");
        appendQueryParam(query, "keyword", normalizeText(request.getParameter("keyword")));
        appendQueryParam(query, "roleId", request.getParameter("filterRoleId"));
        appendQueryParam(query, "status", request.getParameter("filterStatus"));
        appendQueryParam(query, "page", request.getParameter("page"));

        if (query.length() == 0) {
            return "";
        }

        return "?" + query.toString();
    }

    private void appendQueryParam(StringBuilder query, String name, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        if (query.length() > 0) {
            query.append("&");
        }

        query.append(name)
                .append("=")
                .append(URLEncoder.encode(value.trim(), StandardCharsets.UTF_8));
    }

    private Integer parseId(String value) {
        try {
            if (value == null || value.trim().isEmpty()) {
                return null;
            }

            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : defaultValue;
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private String normalizeText(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        return value.trim();
    }

    private String normalizeStatus(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        String status = value.trim().toUpperCase();
        if ("ACTIVE".equals(status) || "INACTIVE".equals(status)) {
            return status;
        }

        return null;
    }
}
