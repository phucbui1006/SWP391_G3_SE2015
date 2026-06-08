<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Role" %>
<%@ page import="model.User" %>
<%
    if (request.getAttribute("users") == null) {
        response.sendRedirect(request.getContextPath() + "/account-manager");
        return;
    }

    List<User> users = (List<User>) request.getAttribute("users");
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    String keyword = (String) request.getAttribute("keyword");
    Integer selectedRoleId = (Integer) request.getAttribute("selectedRoleId");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    Integer currentPageValue = (Integer) request.getAttribute("currentPage");
    Integer totalPagesValue = (Integer) request.getAttribute("totalPages");
    Integer totalUsersValue = (Integer) request.getAttribute("totalUsers");
    Integer startUserIndexValue = (Integer) request.getAttribute("startUserIndex");
    Integer endUserIndexValue = (Integer) request.getAttribute("endUserIndex");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    if (users == null) {
        users = Collections.emptyList();
    }

    if (roles == null) {
        roles = Collections.emptyList();
    }

    int currentPage = currentPageValue == null ? 1 : currentPageValue;
    int totalPages = totalPagesValue == null ? 1 : totalPagesValue;
    int totalUsers = totalUsersValue == null ? 0 : totalUsersValue;
    int startUserIndex = startUserIndexValue == null ? 0 : startUserIndexValue;
    int endUserIndex = endUserIndexValue == null ? 0 : endUserIndexValue;
%>
<%!
    private String h(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String displayRoleName(String roleName) {
        if (roleName == null) {
            return "User";
        }

        String normalizedRole = roleName.trim().toUpperCase();

        if ("ADMIN".equals(normalizedRole)) {
            return "Admin";
        }

        if ("EMPLOYEE".equals(normalizedRole)) {
            return "Employee";
        }

        if ("SHIPMENT".equals(normalizedRole)) {
            return "Shipment";
        }

        if ("CUSTOMER".equals(normalizedRole)) {
            return "User";
        }

        return roleName;
    }

    private String displayStatus(String status) {
        return "ACTIVE".equalsIgnoreCase(status) ? "Hoạt động" : "Bị cấm";
    }

    private boolean isAdminRole(String roleName) {
        return roleName != null && "ADMIN".equalsIgnoreCase(roleName.trim());
    }

    private String buildPageUrl(String contextPath, String keyword, Integer roleId, String status, int page) {
        StringBuilder url = new StringBuilder(contextPath).append("/account-manager?page=").append(page);

        if (keyword != null && !keyword.isEmpty()) {
            url.append("&keyword=").append(URLEncoder.encode(keyword, StandardCharsets.UTF_8));
        }

        if (roleId != null) {
            url.append("&roleId=").append(roleId);
        }

        if (status != null && !status.isEmpty()) {
            url.append("&status=").append(URLEncoder.encode(status, StandardCharsets.UTF_8));
        }

        return url.toString();
    }
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC - Account Management</title>

        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body class="dashboard-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="dashboard-container">
            <form id="accountFilterForm" action="${pageContext.request.contextPath}/account-manager" method="get">
                <section class="filter-section">
                    <div class="search-box-wrapper">
                        <label class="filter-label">Tìm kiếm</label>
                        <div class="search-input-group">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm kiếm người dùng..">
                        </div>
                    </div>

                    <div class="filter-group-right">
                        <div class="filter-box-wrapper">
                            <label class="filter-label">Lọc bởi vai trò</label>
                            <select class="filter-select" name="roleId" onchange="document.getElementById('accountFilterForm').submit()">
                                <option value="">Tất cả vai trò</option>
                                <% for (Role role : roles) { %>
                                <option value="<%= role.getRoleId() %>" <%= selectedRoleId != null && selectedRoleId == role.getRoleId() ? "selected" : "" %>>
                                    <%= h(displayRoleName(role.getRoleName())) %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                        <div class="filter-box-wrapper">
                            <label class="filter-label">Lọc bởi trạng thái</label>
                            <select class="filter-select" name="status" onchange="document.getElementById('accountFilterForm').submit()">
                                <option value="">Tất cả trạng thái</option>
                                <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Hoạt động</option>
                                <option value="BANNED" <%= "BANNED".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Bị cấm</option>
                            </select>
                        </div>
                    </div>
                </section>
            </form>

            <section class="management-card">
                <div class="card-header-title">Quản lí người dùng</div>

                <% if (success != null && !success.isEmpty()) { %>
                <div class="brand-alert success"><%= h(success) %></div>
                <% } %>

                <% if (error != null && !error.isEmpty()) { %>
                <div class="brand-alert error"><%= h(error) %></div>
                <% } %>

                <table class="user-table">
                    <thead>
                        <tr>
                            <th style="width: 5%">#</th>
                            <th style="width: 25%">Tên</th>
                            <th style="width: 25%">Email</th>
                            <th style="width: 15%">Vai trò</th>
                            <th style="width: 12%">Trạng thái</th>
                            <th style="width: 18%">Hoạt động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (users.isEmpty()) { %>
                        <tr>
                            <td colspan="6" class="action-cell-text">Không tìm thấy người dùng phù hợp.</td>
                        </tr>
                        <% } %>

                        <% for (int index = 0; index < users.size(); index++) {
                                User user = users.get(index);
                                boolean adminRole = isAdminRole(user.getRoleName());
                                boolean activeStatus = "ACTIVE".equalsIgnoreCase(user.getStatus());
                        %>
                        <tr>
                            <td><%= startUserIndex + index %></td>
                            <td>
                                <div class="user-info-cell">
                                    <img src="https://i.imgur.com/6VBx3io.png" class="table-avatar" alt="avatar">
                                    <span><%= h(user.getFullName()) %></span>
                                </div>
                            </td>
                            <td><%= h(user.getEmail()) %></td>
                            <td>
                                <% if (adminRole) { %>
                                <select class="table-role-select" disabled>
                                    <option selected><%= h(displayRoleName(user.getRoleName())) %></option>
                                </select>
                                <% } else { %>
                                <form action="${pageContext.request.contextPath}/account-manager" method="post" style="margin: 0;">
                                    <input type="hidden" name="action" value="changeRole">
                                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                    <input type="hidden" name="selectedRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                    <input type="hidden" name="selectedStatus" value="<%= h(selectedStatus) %>">
                                    <input type="hidden" name="page" value="<%= currentPage %>">
                                    <select class="table-role-select" name="roleId" onchange="this.form.submit()">
                                        <% for (Role role : roles) { %>
                                        <option value="<%= role.getRoleId() %>" <%= user.getRoleId() == role.getRoleId() ? "selected" : "" %>>
                                            <%= h(displayRoleName(role.getRoleName())) %>
                                        </option>
                                        <% } %>
                                    </select>
                                </form>
                                <% } %>
                            </td>
                            <td>
                                <span class="status-badge <%= activeStatus ? "active" : "banned" %>">
                                    <%= displayStatus(user.getStatus()) %>
                                </span>
                            </td>
                            <td>
                                <% if (adminRole) { %>
                                <div class="action-cell-text">Không thể cập nhật Admin</div>
                                <% } else { %>
                                <form action="${pageContext.request.contextPath}/account-manager" method="post" style="margin: 0;">
                                    <input type="hidden" name="action" value="changeStatus">
                                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                    <input type="hidden" name="selectedRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                    <input type="hidden" name="selectedStatus" value="<%= h(selectedStatus) %>">
                                    <input type="hidden" name="page" value="<%= currentPage %>">
                                    <div class="action-btn-group">
                                        <button type="submit" class="btn-action btn-active" name="targetStatus" value="ACTIVE" <%= activeStatus ? "disabled" : "" %>>
                                            <i class="fa-solid fa-check"></i> Hoạt động
                                        </button>
                                        <button type="submit" class="btn-action btn-ban" name="targetStatus" value="BANNED" <%= activeStatus ? "" : "disabled" %>>
                                            <i class="fa-solid fa-ban"></i> Bị cấm
                                        </button>
                                    </div>
                                </form>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>

                <div class="table-footer">
                    <div><%= startUserIndex %> to <%= endUserIndex %> of <%= totalUsers %> users</div>

                    <ul class="pagination">
                        <% if (totalUsers > 0) {
                                String contextPath = request.getContextPath();
                                int startPage = Math.max(1, currentPage - 1);
                                int endPage = Math.min(totalPages, currentPage + 1);
                        %>
                        <li>
                            <% if (currentPage > 1) { %>
                            <a href="<%= buildPageUrl(contextPath, keyword, selectedRoleId, selectedStatus, currentPage - 1) %>" class="pagination-link">
                                <i class="fa-solid fa-chevron-left"></i>
                            </a>
                            <% } else { %>
                            <span class="pagination-link disabled"><i class="fa-solid fa-chevron-left"></i></span>
                            <% } %>
                        </li>

                        <% if (startPage > 1) { %>
                        <li><a href="<%= buildPageUrl(contextPath, keyword, selectedRoleId, selectedStatus, 1) %>" class="pagination-link">1</a></li>
                        <% if (startPage > 2) { %>
                        <li><span style="padding: 0 5px;">...</span></li>
                        <% } %>
                        <% } %>

                        <% for (int pageNumber = startPage; pageNumber <= endPage; pageNumber++) { %>
                        <li>
                            <a href="<%= buildPageUrl(contextPath, keyword, selectedRoleId, selectedStatus, pageNumber) %>" class="pagination-link <%= pageNumber == currentPage ? "active" : "" %>">
                                <%= pageNumber %>
                            </a>
                        </li>
                        <% } %>

                        <% if (endPage < totalPages) { %>
                        <% if (endPage < totalPages - 1) { %>
                        <li><span style="padding: 0 5px;">...</span></li>
                        <% } %>
                        <li><a href="<%= buildPageUrl(contextPath, keyword, selectedRoleId, selectedStatus, totalPages) %>" class="pagination-link"><%= totalPages %></a></li>
                        <% } %>

                        <li>
                            <% if (currentPage < totalPages) { %>
                            <a href="<%= buildPageUrl(contextPath, keyword, selectedRoleId, selectedStatus, currentPage + 1) %>" class="pagination-link">
                                <i class="fa-solid fa-chevron-right"></i>
                            </a>
                            <% } else { %>
                            <span class="pagination-link disabled"><i class="fa-solid fa-chevron-right"></i></span>
                            <% } %>
                        </li>
                        <% } %>
                    </ul>
                </div>
            </section>
        </main>

    </body>
</html>
