<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC - Register</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>

    <body>
        <div class="home-navigation">
            <a href="${pageContext.request.contextPath}/" class="home-link">Home</a>
        </div>

        <div class="card-container">
            <h2 class="card-title">Đăng ký tài khoản</h2>

            <form action="${pageContext.request.contextPath}/Register" method="POST" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="fullName">Họ và tên</label>
                    <div class="input-group">
                        <i class="fa-regular fa-user left-icon"></i>
                        <input type="text" id="fullName" name="fullName" placeholder="Nhập tên.." 
                               minlength="2" maxlength="50" pattern="^[^0-9\[\]!@#$%^&*()_+={}|\\:;\'&quot;<>,.?/-]+$"
                               title="Họ và tên từ 2 đến 50 ký tự, không được chứa số hoặc ký tự đặc biệt"
                               value="${param.fullName != null ? param.fullName : ''}" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="email">Email</label>
                    <div class="input-group">
                        <i class="fa-regular fa-envelope left-icon"></i>
                        <input type="email" id="email" name="email" placeholder="Nhập email.." 
                               autocomplete="none" maxlength="100"
                               value="${param.email != null ? param.email : ''}" required
                               pattern="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"
                               title="Vui lòng nhập đúng định dạng email (Ví dụ: abc@gmail.com) và không vượt quá 100 ký tự">
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="password" name="password" placeholder="•••••••• (6-32 ký tự)" 
                               autocomplete="new-password" required minlength="6" maxlength="32" class="pass-input">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('password', this)"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu" 
                               autocomplete="new-password" required minlength="6" maxlength="32" class="pass-input">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('confirmPassword', this)"></i>
                    </div>
                    <small id="passwordError" style="color: red; display: none; margin-top: 5px; font-weight: 500;">Mật khẩu xác nhận không khớp!</small>
                </div>

                <button type="submit" class="btn-submit">Đăng ký</button>
            </form>

            <%
                String error = (String) request.getAttribute("error");
                if (error != null) {
            %>
            <div style="color: red; text-align: center; margin-top: 15px;">
                <%= error %>
            </div>
            <%
                }
            %>

            <div class="footer-text">
                Đã có tài khoản?
                <a href="${pageContext.request.contextPath}/Login">Đăng nhập</a>
            </div>
        </div>

        <script>
            function validateForm() {
                var fullNameInput = document.getElementById("fullName");
                var emailInput = document.getElementById("email");
                var password = document.getElementById("password").value;
                var confirmPassword = document.getElementById("confirmPassword").value;
                var errorMsg = document.getElementById("passwordError");

                fullNameInput.value = fullNameInput.value.trim();
                emailInput.value = emailInput.value.trim();

                if (password !== confirmPassword) {
                    errorMsg.style.display = "block";
                    return false; // Chặn việc gửi form lên server
                }
                errorMsg.style.display = "none";
                return true; // Cho phép gửi form
            }

            function togglePass(inputId, icon) {
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