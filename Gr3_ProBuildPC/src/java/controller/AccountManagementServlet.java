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

@WebServlet(name = "AccountManagementServlet", urlPatterns = {"/account-manager"})
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

        String keyword = normalizeKeyword(request.getParameter("keyword"));
        String selectedStatus = normalizeStatus(request.getParameter("status"));
        Integer selectedRoleId = parsePositiveInt(request.getParameter("roleId"));
        int currentPage = parsePage(request.getParameter("page"));

        List<Role> roles = userDAO.getRoles();
        if (!containsRoleId(roles, selectedRoleId)) {
            selectedRoleId = null;
        }

        int totalUsers = userDAO.countUsers(keyword, selectedRoleId, selectedStatus);
        int totalPages = totalUsers == 0 ? 1 : (int) Math.ceil((double) totalUsers / PAGE_SIZE);

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int offset = (currentPage - 1) * PAGE_SIZE;
        List<User> users = userDAO.getUsers(keyword, selectedRoleId, selectedStatus, offset, PAGE_SIZE);
        int startUserIndex = totalUsers == 0 ? 0 : offset + 1;
        int endUserIndex = totalUsers == 0 ? 0 : offset + users.size();

        moveFlashMessage(session, request, "accountManagerSuccess", "success");
        moveFlashMessage(session, request, "accountManagerError", "error");

        request.setAttribute("activeMenu", "accounts");
        request.setAttribute("users", users);
        request.setAttribute("roles", roles);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedRoleId", selectedRoleId);
        request.setAttribute("selectedStatus", selectedStatus);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("startUserIndex", startUserIndex);
        request.setAttribute("endUserIndex", endUserIndex);

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

        if ("changeRole".equals(action)) {
            changeRole(request, session);
        } else if ("changeStatus".equals(action)) {
            changeStatus(request, session);
        } else {
            session.setAttribute("accountManagerError", "Thao tác không hợp lệ.");
        }

        response.sendRedirect(buildRedirectUrl(request));
    }

    private void changeRole(HttpServletRequest request, HttpSession session) {
        Integer userId = parsePositiveInt(request.getParameter("userId"));
        Integer roleId = parsePositiveInt(request.getParameter("roleId"));

        if (userId == null || roleId == null) {
            session.setAttribute("accountManagerError", "Thông tin cập nhật vai trò không hợp lệ.");
            return;
        }

        if (userDAO.updateUserRole(userId, roleId)) {
            session.setAttribute("accountManagerSuccess", "Cập nhật vai trò người dùng thành công.");
        } else {
            session.setAttribute("accountManagerError", "Không thể cập nhật vai trò cho tài khoản này.");
        }
    }

    private void changeStatus(HttpServletRequest request, HttpSession session) {
        Integer userId = parsePositiveInt(request.getParameter("userId"));
        String targetStatus = normalizeStatus(request.getParameter("targetStatus"));

        if (userId == null || targetStatus == null) {
            session.setAttribute("accountManagerError", "Thông tin cập nhật trạng thái không hợp lệ.");
            return;
        }

        if (userDAO.updateUserStatus(userId, targetStatus)) {
            String message = "ACTIVE".equals(targetStatus)
                    ? "Kích hoạt tài khoản thành công."
                    : "Đã cấm tài khoản thành công.";
            session.setAttribute("accountManagerSuccess", message);
        } else {
            session.setAttribute("accountManagerError", "Không thể cập nhật trạng thái cho tài khoản này.");
        }
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

    private void moveFlashMessage(HttpSession session, HttpServletRequest request, String sessionKey, String requestKey) {
        String value = (String) session.getAttribute(sessionKey);

        if (value != null) {
            request.setAttribute(requestKey, value);
            session.removeAttribute(sessionKey);
        }
    }

    private Integer parsePositiveInt(String value) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parsePage(String value) {
        Integer page = parsePositiveInt(value);
        return page == null ? 1 : page;
    }

    private String normalizeKeyword(String value) {
        if (value == null) {
            return null;
        }

        String normalized = value.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private String normalizeStatus(String value) {
        if (value == null) {
            return null;
        }

        String normalized = value.trim().toUpperCase();

        if ("ACTIVE".equals(normalized) || "BANNED".equals(normalized)) {
            return normalized;
        }

        return null;
    }

    private boolean containsRoleId(List<Role> roles, Integer roleId) {
        if (roleId == null) {
            return false;
        }

        for (Role role : roles) {
            if (role.getRoleId() == roleId) {
                return true;
            }
        }

        return false;
    }

    private String buildRedirectUrl(HttpServletRequest request) {
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath()).append("/account-manager");
        String keyword = normalizeKeyword(request.getParameter("keyword"));
        Integer roleId = parsePositiveInt(request.getParameter("selectedRoleId"));
        String status = normalizeStatus(request.getParameter("selectedStatus"));
        Integer page = parsePositiveInt(request.getParameter("page"));
        String queryPrefix = "?";

        if (keyword != null) {
            redirectUrl.append(queryPrefix)
                    .append("keyword=")
                    .append(URLEncoder.encode(keyword, StandardCharsets.UTF_8));
            queryPrefix = "&";
        }

        if (roleId != null) {
            redirectUrl.append(queryPrefix)
                    .append("roleId=")
                    .append(roleId);
            queryPrefix = "&";
        }

        if (status != null) {
            redirectUrl.append(queryPrefix)
                    .append("status=")
                    .append(status);
            queryPrefix = "&";
        }

        if (page != null) {
            redirectUrl.append(queryPrefix)
                    .append("page=")
                    .append(page);
        }

        return redirectUrl.toString();
    }
}
