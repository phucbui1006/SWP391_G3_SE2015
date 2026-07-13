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

    private String buildUrl(String ctx, String type, String keyword, Integer roleId, String status, int page) {
        StringBuilder url = new StringBuilder(ctx).append("/AccountManagement?page=").append(page);
        if (type != null) url.append("&type=").append(type);
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
    String type = (String) request.getAttribute("type");
    if (type == null) type = "user";
    boolean isStaffType = "staff".equals(type);

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
        <title><%= isStaffType ? "Quản lý tài khoản nhân viên" : "Quản lý tài khoản khách hàng" %></title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>
    <body class="dashboard-body admin-brand-body" style="padding-bottom: 0px">

        <jsp:include page="/includes/header.jsp" />
        <main class="admin-brand-page">

            <section class="admin-page-heading">
                <h1><%= isStaffType ? "Quản lý tài khoản nhân viên" : "Quản lý tài khoản khách hàng" %></h1>
                <div class="admin-breadcrumb">
                    <a href="<%= ctx %>/Dashboard">Dashboard</a>
                    <span>›</span>
                    <strong><%= isStaffType ? "Tài khoản nhân viên" : "Tài khoản khách hàng" %></strong>
                </div>
            </section>

            <% if (success != null && !success.isEmpty()) { %>
            <div class="brand-alert success"><%= h(success) %></div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="brand-alert error"><%= h(error) %></div>
            <% } %>

            <section class="brand-management-layout">
                <div class="brand-table-panel">
                    <div class="brand-toolbar">
                        <form class="brand-search-form" action="<%= ctx %>/AccountManagement" method="get">
                            <input type="hidden" name="type" value="<%= h(type) %>">
                            <input type="text" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm kiếm tên hoặc email...">

                            <% if (isStaffType) { %>
                            <select name="roleId" onchange="this.form.submit()">
                                <option value="">Tất cả vai trò</option>
                                <% if (roles != null) { %>
                                    <% for (Role role : roles) { %>
                                        <option value="<%= role.getRoleId() %>" <%= selectedRoleId != null && selectedRoleId == role.getRoleId() ? "selected" : "" %>>
                                            <%= h(roleLabel(role.getRoleName())) %>
                                        </option>
                                    <% } %>
                                <% } %>
                            </select>
                            <% } %>

                            <select name="status" onchange="this.form.submit()">
                                <option value="">Tất cả trạng thái</option>
                                <option value="ACTIVE" <%= "ACTIVE".equals(selectedStatus) ? "selected" : "" %>>ACTIVE</option>
                                <option value="INACTIVE" <%= "INACTIVE".equals(selectedStatus) ? "selected" : "" %>>INACTIVE</option>
                            </select>

                            <button type="submit">Tìm kiếm</button>
                        </form>

                        <% if (isStaffType) { %>
                        <a class="brand-add-button" href="#add-staff-modal">+ Tạo nhân viên</a>
                        <% } %>
                    </div>

                    <div class="brand-table-wrap">
                        <table class="brand-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Người dùng</th>
                                    <th>Email</th>
                                    <th>Vai trò</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (users == null || users.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="brand-empty-state">Không tìm thấy tài khoản phù hợp.</td>
                                </tr>
                                <% } else { %>
                                <% for (int i = 0; i < users.size(); i++) {
                                    User user = users.get(i);
                                    boolean isAdmin = user.getRoleName() != null && "ADMIN".equalsIgnoreCase(user.getRoleName().trim());
                                    boolean isStaff = user.isStaff();
                                    boolean isCurrentAccount = account.getUserId() == user.getUserId();
                                    String status = user.getStatus() == null ? "" : user.getStatus().trim().toUpperCase();
                                %>
                                <tr>
                                    <td><%= startItem + i %></td>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 10px;">
                                            <div style="text-align: left;">
                                                <strong><%= h(user.getFullName()) %></strong><br>
                                                <small style="color: #6c757d;">User ID: #<%= user.getUserId() %></small>
                                            </div>
                                        </div>
                                    </td>
                                    <td><%= h(user.getEmail()) %></td>
                                    <td>
                                        <% if (!isStaff || isAdmin) { %>
                                            <span style="font-weight: 500; color: <%= isAdmin ? "#dc3545" : "#28a745" %>;">
                                                <%= h(roleLabel(user.getRoleName())) %>
                                            </span>
                                        <% } else { %>
                                            <form action="<%= ctx %>/AccountManagement" method="post" style="margin: 0;">
                                                <input type="hidden" name="action" value="updateRole">
                                                <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                                <input type="hidden" name="type" value="<%= h(type) %>">
                                                <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                                <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                                <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                                <input type="hidden" name="page" value="<%= pageNumber %>">

                                                <select name="roleId" onchange="this.form.submit()" <%= isCurrentAccount ? "disabled" : "" %> style="padding: 4px; border: 1px solid #ced4da; border-radius: 4px;">
                                                    <% if (roles != null) { %>
                                                        <% for (Role role : roles) { %>
                                                            <% if (role.getRoleId() != 1 && !"ADMIN".equalsIgnoreCase(role.getRoleName())) { %>
                                                                <option value="<%= role.getRoleId() %>" <%= user.getRoleId() == role.getRoleId() ? "selected" : "" %>>
                                                                    <%= h(roleLabel(role.getRoleName())) %>
                                                                </option>
                                                            <% } %>
                                                        <% } %>
                                                    <% } %>
                                                </select>
                                            </form>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span style="padding: 4px 8px; border-radius: 4px; font-size: 0.85rem; font-weight: bold; <%= "INACTIVE".equals(status) ? "background-color: #f8d7da; color: #721c24;" : "background-color: #d4edda; color: #155724;" %>">
                                            <%= "INACTIVE".equals(status) ? "Ban" : "Active" %>
                                        </span>
                                    </td>
                                    <td>
                                        <% if (isAdmin) { %>
                                            <span style="color: #6c757d; font-size: 0.9rem;">Không thể khóa</span>
                                        <% } else { %>
                                            <div class="brand-actions" style="justify-content: center;">
                                                <form action="<%= ctx %>/AccountManagement" method="post" style="margin: 0;">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                                    <input type="hidden" name="status" value="<%= "ACTIVE".equals(status) ? "INACTIVE" : "ACTIVE" %>">
                                                    <input type="hidden" name="type" value="<%= h(type) %>">
                                                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                                    <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                                    <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                                    <input type="hidden" name="page" value="<%= pageNumber %>">
                                                    <button class="brand-action delete" type="submit" aria-label="Đổi trạng thái" style="<%= "ACTIVE".equals(status) ? "" : "background: #28a745; color: white;" %>">
                                                        <%= "ACTIVE".equals(status) ? "Ban" : "Active" %>
                                                    </button>
                                                </form>

                                                <% if (isStaff && !isCurrentAccount) { %>
                                                    <form action="<%= ctx %>/AccountManagement" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn reset mật khẩu cho nhân viên này?');" style="margin: 0;">
                                                        <input type="hidden" name="action" value="resetPassword">
                                                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                                        <input type="hidden" name="type" value="<%= h(type) %>">
                                                        <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                                        <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                                                        <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                                                        <input type="hidden" name="page" value="<%= pageNumber %>">
                                                        <button class="brand-action" type="submit" style="background-color: #ffc107; color: #000; border-color: #ffc107; white-space: nowrap;">
                                                            Reset MK
                                                        </button>
                                                    </form>
                                                <% } %>
                                            </div>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; padding: 15px;">
                        <span style="color: #6c757d;">
                            <%= startItem %> đến <%= endItem %> / <%= totalUsers %> tài khoản
                        </span>
                        
                        <nav aria-label="Account pagination">
                            <ul class="account-v2-pagination" style="display: flex; list-style: none; padding: 0; margin: 0; gap: 5px;">
                                <li>
                                    <% if (pageNumber > 1) { %>
                                        <a href="<%= buildUrl(ctx, type, keyword, selectedRoleId, selectedStatus, pageNumber - 1) %>" style="padding: 5px 10px; border: 1px solid #ced4da; text-decoration: none; border-radius: 4px;">‹</a>
                                    <% } else { %>
                                        <span style="padding: 5px 10px; border: 1px solid #ced4da; background-color: #e9ecef; color: #6c757d; border-radius: 4px;">‹</span>
                                    <% } %>
                                </li>
                                <%
                                    int fromPage = Math.max(2, pageNumber - 2);
                                    int toPage = Math.min(totalPages - 1, pageNumber + 2);
                                    if (pageNumber <= 4) {
                                        fromPage = 2;
                                        toPage = Math.min(totalPages - 1, 5);
                                    } else if (pageNumber >= totalPages - 3) {
                                        fromPage = Math.max(2, totalPages - 4);
                                        toPage = totalPages - 1;
                                    }
                                %>
                                    <li>
                                        <a href="<%= buildUrl(ctx, type, keyword, selectedRoleId, selectedStatus, 1) %>" style="padding: 5px 10px; border: 1px solid #ced4da; text-decoration: none; border-radius: 4px; <%= pageNumber == 1 ? "background-color: #0d6efd; color: white;" : "color: #0d6efd;" %>">
                                            1
                                        </a>
                                    </li>
                                <% if (fromPage > 2) { %>
                                    <li><span style="padding: 5px 10px; color: #6c757d;">...</span></li>
                                <% } %>
                                <% for (int p = fromPage; p <= toPage; p++) { %>
                                    <li>
                                        <a href="<%= buildUrl(ctx, type, keyword, selectedRoleId, selectedStatus, p) %>" style="padding: 5px 10px; border: 1px solid #ced4da; text-decoration: none; border-radius: 4px; <%= p == pageNumber ? "background-color: #0d6efd; color: white;" : "color: #0d6efd;" %>">
                                            <%= p %>
                                        </a>
                                    </li>
                                <% } %>
                                <% if (toPage < totalPages - 1) { %>
                                    <li><span style="padding: 5px 10px; color: #6c757d;">...</span></li>
                                <% } %>
                                <% if (totalPages > 1) { %>
                                    <li>
                                        <a href="<%= buildUrl(ctx, type, keyword, selectedRoleId, selectedStatus, totalPages) %>" style="padding: 5px 10px; border: 1px solid #ced4da; text-decoration: none; border-radius: 4px; <%= pageNumber == totalPages ? "background-color: #0d6efd; color: white;" : "color: #0d6efd;" %>">
                                            <%= totalPages %>
                                        </a>
                                    </li>
                                <% } %>
                                <li>
                                    <% if (pageNumber < totalPages) { %>
                                        <a href="<%= buildUrl(ctx, type, keyword, selectedRoleId, selectedStatus, pageNumber + 1) %>" style="padding: 5px 10px; border: 1px solid #ced4da; text-decoration: none; border-radius: 4px;">›</a>
                                    <% } else { %>
                                        <span style="padding: 5px 10px; border: 1px solid #ced4da; background-color: #e9ecef; color: #6c757d; border-radius: 4px;">›</span>
                                    <% } %>
                                </li>
                            </ul>
                        </nav>
                    </div>

                </div>
            </section>
        </main>

        <% if (isStaffType) { %>
        <div class="brand-modal-overlay" id="add-staff-modal">
            <section class="brand-modal" role="dialog" aria-modal="true" aria-labelledby="staffModalTitle">
                <div class="brand-form-header">
                    <h2 id="staffModalTitle">Thêm nhân viên</h2>
                    <a href="#" aria-label="Đóng" style="text-decoration: none; font-size: 24px; color: #6c757d;">×</a>
                </div>

                <form action="<%= ctx %>/AccountManagement" method="post" class="brand-modal-form" onsubmit="return validateCreateStaffForm()">
                    <input type="hidden" name="action" value="createStaff">
                    <input type="hidden" name="type" value="<%= h(type) %>">
                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                    <input type="hidden" name="filterRoleId" value="<%= selectedRoleId == null ? "" : selectedRoleId %>">
                    <input type="hidden" name="filterStatus" value="<%= h(selectedStatus) %>">
                    <input type="hidden" name="page" value="<%= pageNumber %>">

                    <label for="newStaffName">Họ và tên <span>*</span></label>
                    <input id="newStaffName" name="fullName" type="text" placeholder="Ví dụ: Nguyễn Văn A" required>
                    <small id="newStaffNameErr" style="color: red; display: none;">Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.</small>

                    <label for="newStaffEmail" style="margin-top: 10px;">Email <span>*</span></label>
                    <input id="newStaffEmail" name="email" type="email" placeholder="staff@example.com" autocomplete="off" required>
                    <small id="newStaffEmailErr" style="color: red; display: none;">Định dạng email không hợp lệ.</small>

                    <label for="newStaffRole" style="margin-top: 10px;">Vai trò <span>*</span></label>
                    <select id="newStaffRole" name="roleId" required style="padding: 10px; border: 1px solid #ced4da; border-radius: 4px; width: 100%; box-sizing: border-box; margin-bottom: 20px;">
                        <% if (roles != null) { %>
                            <% for (Role role : roles) { %>
                                <% if (role.getRoleId() != 1 && !"ADMIN".equalsIgnoreCase(role.getRoleName())) { %>
                                    <option value="<%= role.getRoleId() %>">
                                        <%= h(roleLabel(role.getRoleName())) %>
                                    </option>
                                <% } %>
                            <% } %>
                        <% } %>
                    </select>

                    <div class="brand-form-actions">
                        <a class="brand-secondary-button" href="#">Hủy</a>
                        <button class="brand-primary-button" type="submit">Lưu</button>
                    </div>
                </form>
            </section>
        </div>
        <script>
            document.addEventListener("DOMContentLoaded", function() {
                if (window.Validator) {
                    Validator.setupRealTimeValidation([
                        {
                            selector: '#newStaffName',
                            validateFn: (val) => Validator.validateName(val),
                            getErrorMsg: () => 'Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.'
                        },
                        {
                            selector: '#newStaffEmail',
                            validateFn: (val) => Validator.validateEmail(val),
                            getErrorMsg: () => 'Định dạng email không hợp lệ.'
                        }
                    ]);
                }
            });

            function validateCreateStaffForm() {
                if (!window.Validator) return true;
                const nameInput = document.getElementById("newStaffName");
                const emailInput = document.getElementById("newStaffEmail");

                const isNameValid = Validator.validateName(nameInput.value);
                const isEmailValid = Validator.validateEmail(emailInput.value);
                
                document.getElementById('newStaffNameErr').style.display = isNameValid ? 'none' : 'block';
                document.getElementById('newStaffEmailErr').style.display = isEmailValid ? 'none' : 'block';

                return isNameValid && isEmailValid;
            }
        </script>
        <% } %>

        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
