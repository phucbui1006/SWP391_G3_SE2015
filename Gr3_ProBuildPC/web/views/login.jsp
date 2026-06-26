<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC - Login</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>

    <body>

        <div class="home-navigation">
            <a href="${pageContext.request.contextPath}/home" class="home-link">Home</a>
        </div>

        <div class="card-container">
            <h2 class="card-title">Chào mừng trở lại!</h2>

            <form action="${pageContext.request.contextPath}/Login" method="POST" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="email">Email</label>

                    <div class="input-group">
                        <i class="fa-regular fa-envelope left-icon"></i>
                        <input type="email" id="email" name="email" placeholder="Email Address" value="${not empty requestScope.enteredEmail ? requestScope.enteredEmail : sessionScope.registeredEmail}">
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>

                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="password" name="password" placeholder="••••••••" class="pass-input" value="${requestScope.enteredPassword}">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('password', this)"></i>
                    </div>
                </div>

                <div class="forgot-password-container">
                    <a href="${pageContext.request.contextPath}/ForgotPassword" class="forgot-link">
                        Quên mật khẩu?
                    </a>
                </div>

                <button type="submit" class="btn-submit">Đăng nhập</button>
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

            <%
                String successMessage = (String) session.getAttribute("successMessage");
                if (successMessage != null && !successMessage.isEmpty()) {
            %>
            <div style="color: green; text-align: center; margin-top: 15px;">
                <%= successMessage %>
            </div>
            <%
                    session.removeAttribute("successMessage");
                    // We also remove registeredEmail here so it doesn't persist forever
                    session.removeAttribute("registeredEmail");
                }
            %>

            <div class="footer-text">
                Bạn chưa có tài khoản?
                <a href="${pageContext.request.contextPath}/Register">Đăng ký</a>
            </div>
        </div>

        <script>
            document.addEventListener("DOMContentLoaded", function() {
                Validator.setupRealTimeValidation([
                    {
                        selector: '#email',
                        validateFn: (val) => Validator.validateEmail(val),
                        getErrorMsg: () => 'Vui lòng nhập định dạng email hợp lệ.'
                    },
                    {
                        selector: '#password',
                        validateFn: (val) => val.trim().length > 0,
                        getErrorMsg: () => 'Vui lòng nhập mật khẩu.'
                    }
                ]);
            });

            function validateForm() {
                const emailInput = document.getElementById("email");
                const passwordInput = document.getElementById("password");

                const isEmailValid = Validator.validateEmail(emailInput.value);
                Validator.showFeedback(emailInput, isEmailValid, 'Vui lòng nhập định dạng email hợp lệ.');

                const isPasswordValid = passwordInput.value.trim().length > 0;
                Validator.showFeedback(passwordInput, isPasswordValid, 'Vui lòng nhập mật khẩu.');

                return isEmailValid && isPasswordValid;
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
