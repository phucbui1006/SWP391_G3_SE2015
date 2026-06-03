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

            <form action="${pageContext.request.contextPath}/Register" method="POST">
                <div class="form-group">
                    <label for="fullName">Họ và tên</label>

                    <div class="input-group">
                        <i class="fa-regular fa-user left-icon"></i>
                        <input type="text" id="fullName" name="fullName" placeholder="Nguyen Van A" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="email">Email</label>

                    <div class="input-group">
                        <i class="fa-regular fa-envelope left-icon"></i>
                        <input type="email" id="email" name="email" placeholder="Nhập email" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>

                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="password" name="password" placeholder="••••••••" required class="pass-input">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('password', this)"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu</label>

                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="••••••••" required class="pass-input">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('confirmPassword', this)"></i>
                    </div>
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