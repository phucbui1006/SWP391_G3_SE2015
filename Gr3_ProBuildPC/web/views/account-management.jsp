<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Role" %>
<%@ page import="model.User" %>

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

    private String roleLabel(String roleName) {
        if (roleName == null) {
            return "Chưa phân quyền";
        }

        switch (roleName.trim().toUpperCase()) {
            case "ADMIN":
                return "Admin";
            case "EMPLOYEE":
                return "Employee";
            case "SHIPMENT":
                return "Shipment";
            case "CUSTOMER":
                return "Customer";
            default:
                return roleName;
        }
    }

    private String buildUrl(String ctx, String keyword, Integer roleId, String status, int page) {
        StringBuilder url = new StringBuilder(ctx).append("/AccountManagement?page=").append(page);

        if (keyword != null && !keyword.trim().isEmpty()) {
            url.append("&keyword=").append(java.net.URLEncoder.encode(keyword.trim(), java.nio.charset.StandardCharsets.UTF_8));
        }

        if (roleId != null) {
            url.append("&roleId=").append(roleId);
        }

        if (status != null && !status.trim().isEmpty()) {
            url.append("&status=").append(java.net.URLEncoder.encode(status.trim(), java.nio.charset.StandardCharsets.UTF_8));
        }

        return url.toString();
    }
%>

<%
    User account = (User) session.getAttribute("account");

    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/Login");
        return;
    }

    String accountRole = account.getRoleName();
    accountRole = accountRole == null ? "" : accountRole.trim().toUpperCase();

    if (!"ADMIN".equals(accountRole)) {
        response.sendRedirect(request.getContextPath() + "/Dashboard");
        return;
    }

    String ctx = request.getContextPath();
    List<User> users = (List<User>) request.getAttribute("users");
    List<Role> roles = (List<Role>) request.getAttribute("roles");
    String keyword = (String) request.getAttribute("keyword");
    Integer selectedRoleId = (Integer) request.getAttribute("selectedRoleId");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    int pageNumber = request.getAttribute("page") == null ? 1 : (Integer) request.getAttribute("page");
    int pageSize = request.getAttribute("pageSize") == null ? 10 : (Integer) request.getAttribute("pageSize");
    int totalUsers = request.getAttribute("totalUsers") == null ? 0 : (Integer) request.getAttribute("totalUsers");
    int totalPages = request.getAttribute("totalPages") == null ? 1 : (Integer) request.getAttribute("totalPages");
    int startItem = totalUsers == 0 ? 0 : ((pageNumber - 1) * pageSize) + 1;
    int endItem = Math.min(pageNumber * pageSize, totalUsers);
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý tài khoản người dùng</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body class="dashboard-body account-management-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="dashboard-container account-management-page">
            <section class="filter-section account-filter-section">
                <form class="account-filter-form" action="<%= ctx %>/AccountManagement" method="get">
                    <div class="search-box-wrapper">
                        <label class="filter-label" for="accountKeyword">Tìm kiếm</label>
                        <div class="search-input-group">
                            <i>⌕</i>
                            <input id="accountKeyword" type="text" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm kiếm người dùng..">
                        </div>
                    </div>

                    <div class="filter-group-right">
                        <div class="filter-box-wrapper">
                            <label class="filter-label" for="roleFilter">Vai trò</label>
                            <select id="roleFilter" class="filter-select" name="roleId">
                                <option value="">Tất cả vai trò</option>
                                <option value="-1" <%= selectedRoleId != null && selectedRoleId == -1 ? "selected" : "" %>>Customer</option>
                                <% if (roles != null) { %>
                                <% for (Role role : roles) { %>
                                <option value="<%= role.getRoleId() %>" <%= selectedRoleId != null && selectedRoleId == role.getRoleId() ? "selected" : "" %>>
                                    <%= h(roleLabel(role.getRoleName())) %>
                                </option>
                                <% } %>
                                <% } %>
                            </select>
                        </div>

                        <div class="filter-box-wrapper">
                            <label class="filter-label" for="statusFilter">Trạng thái</label>
                            <select id="statusFilter" class="filter-select" name="status">
                                <option value="">Tất cả trạng thái</option>
                                <option value="ACTIVE" <%= "ACTIVE".equals(selectedStatus) ? "selected" : "" %>>Active</option>
                                <option value="BANNED" <%= "BANNED".equals(selectedStatus) ? "selected" : "" %>>Banned</option>
                            </select>
                        </div>

                        <button class="account-search-button" type="submit">Tìm kiếm</button>
                    </div>
                </form>
            </section>

            <% if (success != null && !success.isEmpty()) { %>
            <div class="account-alert success"><%= h(success) %></div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="account-alert error"><%= h(error) %></div>
            <% } %>

            <section class="management-card account-management-card">
                <h1 class="card-header-title">Tạo tài khoản nhân viên</h1>
                <form class="account-filter-form" action="<%= ctx %>/AccountManagement" method="post">
                    <input type="hidden" name="action" value="createStaff">
                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                    <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                    <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                    <input type="hidden" name="page" value="<%= pageNumber %>">

                    <div class="search-box-wrapper">
                        <label class="filter-label" for="newStaffName">Tên</label>
                        <div class="search-input-group">
                            <input id="newStaffName" type="text" name="fullName" placeholder="Staff full name" required>
                        </div>
                    </div>

                    <div class="search-box-wrapper">
                        <label class="filter-label" for="newStaffEmail">Email</label>
                        <div class="search-input-group">
                            <input id="newStaffEmail" type="email" name="email" placeholder="staff@example.com" autocomplete="none" required>
                        </div>
                    </div>

                    <div class="search-box-wrapper">
                        <label class="filter-label" for="newStaffPassword">Mật khẩu</label>
                        <div class="search-input-group">
                            <input id="newStaffPassword" type="password" name="password" placeholder="Mật khẩu" autocomplete="new-password" required>
                        </div>
                    </div>

                    <div class="filter-group-right">
                        <div class="filter-box-wrapper">
                            <label class="filter-label" for="newStaffRole">Vai trò</label>
                            <select id="newStaffRole" class="filter-select" name="roleId" required>
                                <% if (roles != null) { %>
                                <% for (Role role : roles) { %>
                                <option value="<%= role.getRoleId() %>"><%= h(roleLabel(role.getRoleName())) %></option>
                                <% } %>
                                <% } %>
                            </select>
                        </div>
                        <button class="account-search-button" type="submit">Tạo nhân viên</button>
                    </div>
                </form>
            </section>

            <section class="management-card account-management-card">
                <h1 class="card-header-title">Quản lí người dùng</h1>

                <table class="user-table">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Tên</th>
                            <th>Email</th>
                            <th>Vai trò</th>
                            <th>Trạng thái</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (users == null || users.isEmpty()) { %>
                        <tr>
                            <td class="account-empty-state" colspan="6">Không tìm thấy tài khoản phù hợp.</td>
                        </tr>
                        <% } else { %>
                        <% for (int i = 0; i < users.size(); i++) {
                                User user = users.get(i);
                                boolean isAdmin = user.getRoleName() != null && "ADMIN".equalsIgnoreCase(user.getRoleName().trim());
                                boolean isStaff = user.isStaff();
                                boolean isCurrentAccount = account.getUserId() == user.getUserId();
                                String status = user.getStatus() == null ? "" : user.getStatus().trim().toUpperCase();
                                String avatarText = user.getFullName() == null || user.getFullName().trim().isEmpty()
                                        ? "U"
                                        : user.getFullName().trim().substring(0, 1).toUpperCase();
                        %>
                        <tr>
                            <td><%= startItem + i %></td>
                            <td>
                                <div class="user-info-cell">
                                    <span class="table-avatar account-avatar"><%= h(avatarText) %></span>
                                    <strong><%= h(user.getFullName()) %></strong>
                                </div>
                            </td>
                            <td><%= h(user.getEmail()) %></td>
                            <td>
                                <% if (!isStaff) { %>
                                <span class="status-badge active"><%= h(roleLabel(user.getRoleName())) %></span>
                                <% } else { %>
                                <form action="<%= ctx %>/AccountManagement" method="post" class="account-inline-form">
                                    <input type="hidden" name="action" value="updateRole">
                                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                    <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                    <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                    <input type="hidden" name="page" value="<%= pageNumber %>">
                                    <select class="table-role-select" name="roleId" onchange="this.form.submit()" <%= isCurrentAccount ? "disabled" : "" %>>
                                        <% if (roles != null) { %>
                                        <% for (Role role : roles) { %>
                                        <option value="<%= role.getRoleId() %>" <%= user.getRoleId() == role.getRoleId() ? "selected" : "" %>>
                                            <%= h(roleLabel(role.getRoleName())) %>
                                        </option>
                                        <% } %>
                                        <% } %>
                                    </select>
                                </form>
                                <% } %>
                            </td>
                            <td>
                                <span class="status-badge <%= "BANNED".equals(status) ? "banned" : "active" %>">
                                    <%= "BANNED".equals(status) ? "Banned" : "Active" %>
                                </span>
                            </td>
                            <td>
                                <% if (isAdmin) { %>
                                <span class="action-cell-text">Can not ban Admin</span>
                                <% } else { %>
                                <div class="action-btn-group">
                                    <form action="<%= ctx %>/AccountManagement" method="post">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                        <input type="hidden" name="status" value="ACTIVE">
                                        <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                        <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                        <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                        <input type="hidden" name="page" value="<%= pageNumber %>">
                                        <button class="btn-action btn-active" type="submit" <%= "ACTIVE".equals(status) ? "disabled" : "" %>>✓ Active</button>
                                    </form>

                                    <form action="<%= ctx %>/AccountManagement" method="post">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                        <input type="hidden" name="status" value="BANNED">
                                        <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                        <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                        <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                        <input type="hidden" name="page" value="<%= pageNumber %>">
                                        <button class="btn-action btn-ban" type="submit" <%= "BANNED".equals(status) ? "disabled" : "" %>>⊘ Ban</button>
                                    </form>
                                </div>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                        <% } %>
                    </tbody>
                </table>

                <div class="table-footer">
                    <span><%= startItem %> to <%= endItem %> of <%= totalUsers %> users</span>
                    <nav aria-label="Account pagination">
                        <ul class="pagination">
                            <li>
                                <% if (pageNumber > 1) { %>
                                <a class="pagination-link" href="<%= buildUrl(ctx, keyword, selectedRoleId, selectedStatus, pageNumber - 1) %>">‹</a>
                                <% } else { %>
                                <span class="pagination-link disabled">‹</span>
                                <% } %>
                            </li>

                            <% int fromPage = Math.max(1, pageNumber - 2);
                               int toPage = Math.min(totalPages, pageNumber + 2);
                               for (int p = fromPage; p <= toPage; p++) { %>
                            <li>
                                <a class="pagination-link <%= p == pageNumber ? "active" : "" %>" href="<%= buildUrl(ctx, keyword, selectedRoleId, selectedStatus, p) %>"><%= p %></a>
                            </li>
                            <% } %>

                            <% if (toPage < totalPages) { %>
                            <li><span class="pagination-link disabled">...</span></li>
                            <% } %>

                            <li>
                                <% if (pageNumber < totalPages) { %>
                                <a class="pagination-link" href="<%= buildUrl(ctx, keyword, selectedRoleId, selectedStatus, pageNumber + 1) %>">›</a>
                                <% } else { %>
                                <span class="pagination-link disabled">›</span>
                                <% } %>
                            </li>
                        </ul>
                    </nav>
                </div>
            </section>
        </main>

        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
