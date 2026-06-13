<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    // 1. Lấy thông tin tài khoản đang đăng nhập từ Session
    User account = (User) session.getAttribute("account");
    
    // Kiểm tra nếu session trống (chưa đăng nhập hoặc hết hạn) thì đá về trang Login
    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/Login");
        return;
    }
    
    // 2. Trích xuất thông tin động từ đối tượng account để điền vào Form
    // Đảm bảo các hàm getName(), getEmail() khớp với thuộc tính trong class model.User của bạn
    String emailDynamic = account.getEmail() != null ? account.getEmail() : "";
    String fullNameDynamic = account.getFullName() != null ? account.getFullName() : "";
    
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC - My Profile</title>

        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">

        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body class="profile-body">
        <div class="home-navigation">
            <a style="color: black" href="${pageContext.request.contextPath}/home" class="home-link">Home</a>
        </div>

        <div class="profile-container">

            <div class="profile-left">
                <div class="overlay-text">
                    <h2>ProBuild PC</h2>
                    <p>Cập nhật hồ sơ để bảo mật tài khoản và quản lý đơn hàng của bạn tốt hơn.</p>
                </div>
            </div>

            <div class="profile-right">
                <h2 class="profile-title">Thông tin cá nhân</h2>
                <% if (request.getAttribute("successMsg") != null) { %>
                <div class="alert-message alert-success">
                    🎉 <%= request.getAttribute("successMsg") %>
                </div>
                <% } %>

                <% if (request.getAttribute("errorMsg") != null) { %>
                <div class="alert-message alert-danger">
                    ⚠️ <%= request.getAttribute("errorMsg") %>
                </div>
                <% } %>
                <form action="${pageContext.request.contextPath}/updateProfile" method="POST" class="profile-form" onsubmit="return validateForm()">

                    <div class="profile-form-group">
                        <label class="profile-label">Email</label>
                        <div class="profile-input-wrapper">
                            <input type="email" name="email" value="${sessionScope.account.email}" readonly>                            <i class="fa-solid fa-lock lock-icon"></i>
                        </div>
                    </div>

                    <div class="profile-form-group">
                        <label class="profile-label" for="fullName">Họ tên</label>
                        <div class="profile-input-wrapper">
                            <input type="text" id="fullName" name="fullName" value="<%= fullNameDynamic %>" required minlength="2" maxlength="50" pattern="^[^0-9\[\]!@#$%^&*()_+={}|\\:;\'&quot;<>,.?/-]+$" title="Họ và tên từ 2 đến 50 ký tự, không được chứa số hoặc ký tự đặc biệt">
                        </div>
                    </div>

                    <div class="profile-form-group">
                        <label class="profile-label" for="oldPassword">Mật khẩu cũ</label>
                        <div class="profile-input-wrapper">
                            <input type="password" id="currentPassword" name="currentPassword" placeholder="•••••••••" minlength="6" maxlength="32">                        
                            <i class="fa-regular fa-eye toggle-eye" onclick="toggleProfilePass('currentPassword', this)"></i>
                        </div>
                    </div>

                    <div class="profile-form-group">
                        <label class="profile-label" for="newPassword">Mật khẩu mới</label>
                        <div class="profile-input-wrapper">
                            <input type="password" id="newPassword" name="newPassword" placeholder="Nhập mật khẩu mới" autocomplete="new-password" minlength="6" maxlength="32">
                            <i class="fa-regular fa-eye toggle-eye" onclick="toggleProfilePass('newPassword', this)"></i>
                        </div>
                    </div>

                    <div class="profile-form-group">
                        <label class="profile-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                        <div class="profile-input-wrapper">
                            <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Xác nhận mật khẩu mới" autocomplete="new-password" minlength="6" maxlength="32">
                            <i class="fa-regular fa-eye toggle-eye" onclick="toggleProfilePass('confirmPassword', this)"></i>
                        </div>
                        <small id="passwordError" style="color: red; display: none; margin-top: 5px; font-weight: 500;">Mật khẩu xác nhận không khớp!</small>
                    </div>
                    <br/>

                    <div class="profile-action-row">
                        <button type="submit" class="profile-btn-save">Lưu thay đổi</button>
                    </div>

                </form>

            </div>

        </div>

        <script>
            function validateForm() {
                var fullNameInput = document.getElementById("fullName");
                if (fullNameInput) {
                    fullNameInput.value = fullNameInput.value.trim();
                }

                var newPassword = document.getElementById("newPassword").value;
                var confirmPassword = document.getElementById("confirmPassword").value;
                var errorMsg = document.getElementById("passwordError");

                if (newPassword !== confirmPassword) {
                    errorMsg.style.display = "block";
                    return false;
                }
                errorMsg.style.display = "none";
                return true;
            }

            function toggleProfilePass(inputId, icon) {
                const inputField = document.getElementById(inputId);
                if (inputField.type === "password") {
                    inputField.type = "text";
                    icon.classList.remove("fa-eye");
                    icon.classList.add("fa-eye-slash");
                } else {
                    inputField.type = "password";
                    icon.classList.remove("fa-eye-slash");
                    icon.classList.add("fa-eye");
                }
            }
        </script>
    </body>
</html>