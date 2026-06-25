<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>

<%
    User account = (User) session.getAttribute("account");

    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/Login");
        return;
    }

    String fullNameDynamic = account.getFullName() != null ? account.getFullName() : "";
    String ctx = request.getContextPath();

    String homeUrl = ctx + "/home";
    if (account.getAccountType() != null 
            && !"CUSTOMER".equalsIgnoreCase(account.getAccountType())) {
        homeUrl = ctx + "/Dashboard";
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thông tin cá nhân - ProBuild PC</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    <script src="${pageContext.request.contextPath}/js/profile.js"></script>
</head>

<body class="profile-page-body">

    <a href="<%= homeUrl %>" class="profile-back-link">
        <i class="fa-solid fa-arrow-left"></i> Home
    </a>

    <div class="profile-page-wrapper">

        <div class="profile-card">

            <div class="profile-banner">
                <div class="profile-banner-content">
                    <h1>ProBuild PC</h1>
                    <p>Quản lý thông tin cá nhân, bảo mật tài khoản và cập nhật hồ sơ của bạn.</p>
                </div>
            </div>

            <div class="profile-form-section">

                <h2>Thông tin cá nhân</h2>
                <p class="profile-subtitle">Cập nhật họ tên hoặc thay đổi mật khẩu khi cần.</p>

                <div class="profile-alert-placeholder" style="min-height: 68px;">
                    <% if (request.getAttribute("successMsg") != null) { %>
                        <div class="profile-alert success">
                            <i class="fa-solid fa-circle-check"></i>
                            <%= request.getAttribute("successMsg") %>
                        </div>
                    <% } %>

                    <% if (request.getAttribute("errorMsg") != null) { %>
                        <div class="profile-alert error">
                            <i class="fa-solid fa-triangle-exclamation"></i>
                            <%= request.getAttribute("errorMsg") %>
                        </div>
                    <% } %>
                </div>

                <form action="${pageContext.request.contextPath}/updateProfile"
                      method="POST"
                      class="profile-form"
                      onsubmit="return validateForm()">

                    <div class="profile-group">
                        <label>Email</label>
                        <div class="profile-input-box readonly">
                            <input type="email" name="email"
                                   value="${sessionScope.account.email}" readonly>
                            <i class="fa-solid fa-lock"></i>
                        </div>
                    </div>

                    <div class="profile-group">
                        <label for="fullName">Họ tên</label>
                        <div class="profile-input-box">
                            <input type="text" id="fullName" name="fullName"
                                   value="<%= fullNameDynamic %>" required>
                            <i class="fa-solid fa-user"></i>
                        </div>
                    </div>

                    <div class="profile-group">
                        <label for="currentPassword">Mật khẩu cũ</label>
                        <div class="profile-input-box">
                            <input type="password" id="currentPassword" name="currentPassword"
                                   placeholder="Nhập mật khẩu hiện tại">
                            <i class="fa-regular fa-eye profile-eye"
                               onclick="toggleProfilePass('currentPassword', this)"></i>
                        </div>
                    </div>

                    <div class="profile-group">
                        <label for="newPassword">Mật khẩu mới</label>
                        <div class="profile-input-box">
                            <input type="password" id="newPassword" name="newPassword"
                                   placeholder="8-31 ký tự, có chữ hoa, thường và số"
                                   autocomplete="new-password">
                            <i class="fa-regular fa-eye profile-eye"
                               onclick="toggleProfilePass('newPassword', this)"></i>
                        </div>
                    </div>

                    <div class="profile-group">
                        <label for="confirmPassword">Xác nhận mật khẩu mới</label>
                        <div class="profile-input-box">
                            <input type="password" id="confirmPassword" name="confirmPassword"
                                   placeholder="Nhập lại mật khẩu mới"
                                   autocomplete="new-password">
                            <i class="fa-regular fa-eye profile-eye"
                               onclick="toggleProfilePass('confirmPassword', this)"></i>
                        </div>
                    </div>

                    <button type="submit" class="profile-save-btn">
                        <i class="fa-solid fa-floppy-disk"></i>
                        Lưu thay đổi
                    </button>

                </form>
            </div>
        </div>
    </div>

</body>
</html>
