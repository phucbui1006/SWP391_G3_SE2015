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

    private static final int PAGE_SIZE = 10;
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

        String keyword = normalizeText(request.getParameter("keyword"));
        Integer roleId = parseId(request.getParameter("roleId"));
        String status = normalizeStatus(request.getParameter("status"));
        int page = parsePositiveInt(request.getParameter("page"), 1);

        int totalUsers = userDAO.countUsers(keyword, roleId, status);
        int totalPages = Math.max(1, (int) Math.ceil(totalUsers / (double) PAGE_SIZE));

        if (page > totalPages) {
            page = totalPages;
        }

        List<User> users = userDAO.getUsers(keyword, roleId, status, page, PAGE_SIZE);
        List<Role> roles = userDAO.getRoles();

        request.setAttribute("users", users);
        request.setAttribute("roles", roles);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedRoleId", roleId);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("totalPages", totalPages);

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
        Integer userId = parseId(request.getParameter("userId"));
        User currentAdmin = (User) session.getAttribute("account");

        if (userId == null) {
            session.setAttribute("accountError", "Tài khoản cần cập nhật không hợp lệ.");
        } else if ("updateRole".equals(action)) {
            updateRole(request, session, currentAdmin, userId);
        } else if ("updateStatus".equals(action)) {
            updateStatus(request, session, currentAdmin, userId);
        } else {
            session.setAttribute("accountError", "Thao tác không hợp lệ.");
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

    private void updateRole(HttpServletRequest request, HttpSession session, User currentAdmin, int userId) {
        Integer roleId = parseId(request.getParameter("roleId"));

        if (roleId == null) {
            session.setAttribute("accountError", "Vai trò cập nhật không hợp lệ.");
            return;
        }

        if (currentAdmin != null && currentAdmin.getUserId() == userId) {
            session.setAttribute("accountError", "Không thể đổi vai trò của chính tài khoản đang đăng nhập.");
            return;
        }

        if (userDAO.updateUserRole(userId, roleId)) {
            session.setAttribute("accountSuccess", "Cập nhật vai trò tài khoản thành công.");
        } else {
            session.setAttribute("accountError", "Không thể cập nhật vai trò tài khoản.");
        }
    }

    private void updateStatus(HttpServletRequest request, HttpSession session, User currentAdmin, int userId) {
        String status = normalizeStatus(request.getParameter("status"));

        if (status == null) {
            session.setAttribute("accountError", "Trạng thái cập nhật không hợp lệ.");
            return;
        }

        User targetUser = userDAO.getUserById(userId);
        if (targetUser == null) {
            session.setAttribute("accountError", "Không tìm thấy tài khoản cần cập nhật.");
            return;
        }

        if (currentAdmin != null && currentAdmin.getUserId() == userId) {
            session.setAttribute("accountError", "Không thể khóa chính tài khoản đang đăng nhập.");
            return;
        }

        if ("ADMIN".equalsIgnoreCase(targetUser.getRoleName()) && "BANNED".equals(status)) {
            session.setAttribute("accountError", "Không thể khóa tài khoản Admin.");
            return;
        }

        if (userDAO.updateUserStatus(userId, status)) {
            session.setAttribute("accountSuccess", "Cập nhật trạng thái tài khoản thành công.");
        } else {
            session.setAttribute("accountError", "Không thể cập nhật trạng thái tài khoản.");
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
        if ("ACTIVE".equals(status) || "BANNED".equals(status)) {
            return status;
        }

        return null;
    }
}
