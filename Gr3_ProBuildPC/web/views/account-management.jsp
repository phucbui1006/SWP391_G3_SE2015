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
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>
    <body class="dashboard-body account-management-body">

        <jsp:include page="/includes/header.jsp" />
<main class="account-v2-page">

    <section class="account-v2-hero">
        <div>
            <span class="account-v2-label">ADMIN PANEL</span>
            <h1>👥 Tài khoản người dùng</h1>
            <p>Quản lý tài khoản khách hàng, nhân viên, vai trò và trạng thái hoạt động trong hệ thống.</p>
        </div>

        <div class="account-v2-summary">
            <div>
                <strong><%= totalUsers %></strong>
                <span>Tổng tài khoản</span>
            </div>
            <div>
                <strong><%= pageNumber %>/<%= totalPages %></strong>
                <span>Trang hiện tại</span>
            </div>
        </div>
    </section>

    <% if (success != null && !success.isEmpty()) { %>
        <div class="account-v2-alert success"><%= h(success) %></div>
    <% } %>

    <% if (error != null && !error.isEmpty()) { %>
        <div class="account-v2-alert error"><%= h(error) %></div>
    <% } %>

    <!-- BỘ LỌC -->
    <section class="account-v2-card account-v2-filter-card">
        <div class="account-v2-card-header">
            <div>
                <h2>Bộ lọc tài khoản</h2>
                <p>Tìm kiếm theo tên, email, vai trò hoặc trạng thái.</p>
            </div>
        </div>

        <form class="account-v2-filter-form" action="<%= ctx %>/AccountManagement" method="get">

            <div class="account-v2-field account-v2-search-field">
                <label for="accountKeyword">Tìm kiếm</label>
                <div class="account-v2-input-icon">
                    <span>⌕</span>
                    <input id="accountKeyword"
                           type="text"
                           name="keyword"
                           value="<%= h(keyword) %>"
                           placeholder="Nhập tên hoặc email người dùng...">
                </div>
            </div>

            <div class="account-v2-field">
                <label for="roleFilter">Vai trò</label>
                <select id="roleFilter" name="roleId">
                    <option value="">Tất cả vai trò</option>
                    <option value="-1" <%= selectedRoleId != null && selectedRoleId == -1 ? "selected" : "" %>>
                        Customer
                    </option>

                    <% if (roles != null) { %>
                        <% for (Role role : roles) { %>
                            <option value="<%= role.getRoleId() %>"
                                <%= selectedRoleId != null && selectedRoleId == role.getRoleId() ? "selected" : "" %>>
                                <%= h(roleLabel(role.getRoleName())) %>
                            </option>
                        <% } %>
                    <% } %>
                </select>
            </div>

            <div class="account-v2-field">
                <label for="statusFilter">Trạng thái</label>
                <select id="statusFilter" name="status">
                    <option value="">Tất cả trạng thái</option>
                    <option value="ACTIVE" <%= "ACTIVE".equals(selectedStatus) ? "selected" : "" %>>Active</option>
                    <option value="BANNED" <%= "BANNED".equals(selectedStatus) ? "selected" : "" %>>Banned</option>
                </select>
            </div>

            <div class="account-v2-filter-actions">
                <button type="submit" class="account-v2-btn primary">Tìm kiếm</button>
                <a href="<%= ctx %>/AccountManagement" class="account-v2-btn light">Làm mới</a>
            </div>

        </form>
    </section>

    <!-- TẠO TÀI KHOẢN NHÂN VIÊN -->
    <section class="account-v2-card">
        <div class="account-v2-card-header">
            <div>
                <h2>➕ Tạo tài khoản nhân viên</h2>
                <p>Admin có thể tạo tài khoản cho Employee hoặc Shipment.</p>
            </div>
        </div>

        <form id="createStaffForm"
              class="account-v2-create-form"
              action="<%= ctx %>/AccountManagement"
              method="post"
              onsubmit="return validateCreateStaffForm()">

            <input type="hidden" name="action" value="createStaff">
            <input type="hidden" name="keyword" value="<%= h(keyword) %>">
            <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
            <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
            <input type="hidden" name="page" value="<%= pageNumber %>">

            <div class="account-v2-field">
                <label for="newStaffName">Họ và tên</label>
                <input id="newStaffName"
                       type="text"
                       name="fullName"
                       placeholder="Ví dụ: Nguyễn Văn A"
                       required>
            </div>

            <div class="account-v2-field">
                <label for="newStaffEmail">Email</label>
                <input id="newStaffEmail"
                       type="email"
                       name="email"
                       placeholder="staff@example.com"
                       autocomplete="none"
                       required>
            </div>

            <div class="account-v2-field">
                <label for="newStaffPassword">Mật khẩu</label>
                <input id="newStaffPassword"
                       type="password"
                       name="password"
                       placeholder="8-31 ký tự, có hoa, thường và số"
                       autocomplete="new-password"
                       required>
            </div>

            <div class="account-v2-field">
                <label for="newStaffRole">Vai trò</label>
                <select id="newStaffRole" name="roleId" required>
                    <% if (roles != null) { %>
                        <% for (Role role : roles) { %>
                            <option value="<%= role.getRoleId() %>">
                                <%= h(roleLabel(role.getRoleName())) %>
                            </option>
                        <% } %>
                    <% } %>
                </select>
            </div>

            <div class="account-v2-create-actions">
                <button type="submit" class="account-v2-btn primary">Tạo nhân viên</button>
            </div>
        </form>
    </section>

    <!-- DANH SÁCH NGƯỜI DÙNG -->
    <section class="account-v2-card">
        <div class="account-v2-card-header">
            <div>
                <h2>Danh sách tài khoản</h2>
                <p>Hiển thị <%= startItem %> - <%= endItem %> trong tổng số <%= totalUsers %> tài khoản.</p>
            </div>
        </div>

        <div class="account-v2-table-wrapper">
            <table class="account-v2-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Người dùng</th>
                        <th>Email</th>
                        <th>Vai trò</th>
                        <th>Trạng thái</th>
                        <th>Hành động</th>
                    </tr>
                </thead>

                <tbody>
                    <% if (users == null || users.isEmpty()) { %>
                        <tr>
                            <td colspan="6" class="account-v2-empty">
                                Không tìm thấy tài khoản phù hợp.
                            </td>
                        </tr>
                    <% } else { %>

                        <% for (int i = 0; i < users.size(); i++) {
                            User user = users.get(i);

                            boolean isAdmin = user.getRoleName() != null
                                    && "ADMIN".equalsIgnoreCase(user.getRoleName().trim());

                            boolean isStaff = user.isStaff();
                            boolean isCurrentAccount = account.getUserId() == user.getUserId();

                            String status = user.getStatus() == null
                                    ? ""
                                    : user.getStatus().trim().toUpperCase();

                            String avatarText = user.getFullName() == null || user.getFullName().trim().isEmpty()
                                    ? "U"
                                    : user.getFullName().trim().substring(0, 1).toUpperCase();
                        %>

                        <tr>
                            <td class="account-v2-index"><%= startItem + i %></td>

                            <td>
                                <div class="account-v2-user-cell">
                                    <span class="account-v2-avatar"><%= h(avatarText) %></span>
                                    <div>
                                        <strong><%= h(user.getFullName()) %></strong>
                                        <small>User ID: #<%= user.getUserId() %></small>
                                    </div>
                                </div>
                            </td>

                            <td class="account-v2-email"><%= h(user.getEmail()) %></td>

                            <td>
                                <% if (!isStaff) { %>
                                    <span class="account-v2-role customer">
                                        <%= h(roleLabel(user.getRoleName())) %>
                                    </span>
                                <% } else { %>
                                    <form action="<%= ctx %>/AccountManagement"
                                          method="post"
                                          class="account-v2-inline-form">

                                        <input type="hidden" name="action" value="updateRole">
                                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                        <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                        <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                        <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                        <input type="hidden" name="page" value="<%= pageNumber %>">

                                        <select class="account-v2-role-select"
                                                name="roleId"
                                                onchange="this.form.submit()"
                                                <%= isCurrentAccount ? "disabled" : "" %>>

                                            <% if (roles != null) { %>
                                                <% for (Role role : roles) { %>
                                                    <option value="<%= role.getRoleId() %>"
                                                        <%= user.getRoleId() == role.getRoleId() ? "selected" : "" %>>
                                                        <%= h(roleLabel(role.getRoleName())) %>
                                                    </option>
                                                <% } %>
                                            <% } %>

                                        </select>
                                    </form>
                                <% } %>
                            </td>

                            <td>
                                <span class="account-v2-status <%= "BANNED".equals(status) ? "banned" : "active" %>">
                                    <%= "BANNED".equals(status) ? "Banned" : "Active" %>
                                </span>
                            </td>

                            <td>
                                <% if (isAdmin) { %>
                                    <span class="account-v2-note">Không thể khóa Admin</span>
                                <% } else { %>
                                    <div class="account-v2-action-group">
                                        <form action="<%= ctx %>/AccountManagement" method="post">
                                            <input type="hidden" name="action" value="updateStatus">
                                            <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                            <input type="hidden" name="status" value="ACTIVE">
                                            <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                            <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                            <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                            <input type="hidden" name="page" value="<%= pageNumber %>">

                                            <button class="account-v2-action active"
                                                    type="submit"
                                                    <%= "ACTIVE".equals(status) ? "disabled" : "" %>>
                                                ✓ Active
                                            </button>
                                        </form>

                                        <form action="<%= ctx %>/AccountManagement" method="post">
                                            <input type="hidden" name="action" value="updateStatus">
                                            <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                            <input type="hidden" name="status" value="BANNED">
                                            <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                            <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                            <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                            <input type="hidden" name="page" value="<%= pageNumber %>">

                                            <button class="account-v2-action ban"
                                                    type="submit"
                                                    <%= "BANNED".equals(status) ? "disabled" : "" %>>
                                                ⊘ Ban
                                            </button>
                                        </form>
                                    </div>
                                <% } %>
                            </td>
                        </tr>

                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>

        <div class="account-v2-footer">
            <span>
                <%= startItem %> đến <%= endItem %> / <%= totalUsers %> tài khoản
            </span>

            <nav aria-label="Account pagination">
                <ul class="account-v2-pagination">
                    <li>
                        <% if (pageNumber > 1) { %>
                            <a href="<%= buildUrl(ctx, keyword, selectedRoleId, selectedStatus, pageNumber - 1) %>">‹</a>
                        <% } else { %>
                            <span class="disabled">‹</span>
                        <% } %>
                    </li>

                    <%
                        int fromPage = Math.max(1, pageNumber - 2);
                        int toPage = Math.min(totalPages, pageNumber + 2);

                        for (int p = fromPage; p <= toPage; p++) {
                    %>
                        <li>
                            <a class="<%= p == pageNumber ? "active" : "" %>"
                               href="<%= buildUrl(ctx, keyword, selectedRoleId, selectedStatus, p) %>">
                                <%= p %>
                            </a>
                        </li>
                    <% } %>

                    <% if (toPage < totalPages) { %>
                        <li><span class="disabled">...</span></li>
                    <% } %>

                    <li>
                        <% if (pageNumber < totalPages) { %>
                            <a href="<%= buildUrl(ctx, keyword, selectedRoleId, selectedStatus, pageNumber + 1) %>">›</a>
                        <% } else { %>
                            <span class="disabled">›</span>
                        <% } %>
                    </li>
                </ul>
            </nav>
        </div>
    </section>

</main>

        <jsp:include page="/includes/footer.jsp" />
        <script>
            document.addEventListener("DOMContentLoaded", function() {
                Validator.setupRealTimeValidation([
                    {
                        selector: '#newStaffName',
                        validateFn: (val) => Validator.validateName(val),
                        getErrorMsg: () => 'Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.'
                    },
                    {
                        selector: '#newStaffEmail',
                        validateFn: (val) => Validator.validateEmail(val),
                        getErrorMsg: () => 'Định dạng email không hợp lệ (tối đa 100 ký tự).'
                    },
                    {
                        selector: '#newStaffPassword',
                        validateFn: (val) => Validator.validatePassword(val),
                        getErrorMsg: () => 'Mật khẩu 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.'
                    }
                ]);
            });

            function validateCreateStaffForm() {
                const nameInput = document.getElementById("newStaffName");
                const emailInput = document.getElementById("newStaffEmail");
                const passwordInput = document.getElementById("newStaffPassword");

                const isNameValid = Validator.validateName(nameInput.value);
                Validator.showFeedback(nameInput, isNameValid, 'Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.');

                const isEmailValid = Validator.validateEmail(emailInput.value);
                Validator.showFeedback(emailInput, isEmailValid, 'Định dạng email không hợp lệ (tối đa 100 ký tự).');

                const isPasswordValid = Validator.validatePassword(passwordInput.value);
                Validator.showFeedback(passwordInput, isPasswordValid, 'Mật khẩu 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.');

                return isNameValid && isEmailValid && isPasswordValid;
            }
        </script>
    </body>
</html>
