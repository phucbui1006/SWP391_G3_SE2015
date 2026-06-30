<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC - Register</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
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
                               value="${param.fullName != null ? param.fullName : ''}">
                    </div>
                </div>

                <div class="form-group">
                    <label for="email">Email</label>
                    <div class="input-group">
                        <i class="fa-regular fa-envelope left-icon"></i>
                        <input type="email" id="email" name="email" placeholder="Nhập email.." 
                               autocomplete="none"
                               value="${param.email != null ? param.email : ''}">
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="password" name="password" placeholder="•••••••• (8-31 ký tự, có hoa, thường và số)" 
                               autocomplete="new-password" class="pass-input">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('password', this)"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu" 
                               autocomplete="new-password" class="pass-input">
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
            document.addEventListener("DOMContentLoaded", function() {
                Validator.setupRealTimeValidation([
                    {
                        selector: '#fullName',
                        validateFn: (val) => Validator.validateName(val),
                        getErrorMsg: () => 'Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.'
                    },
                    {
                        selector: '#email',
                        validateFn: (val) => Validator.validateEmail(val),
                        getErrorMsg: () => 'Định dạng email không hợp lệ (tối đa 100 ký tự).'
                    },
                    {
                        selector: '#password',
                        validateFn: (val) => Validator.validatePassword(val),
                        getErrorMsg: () => 'Mật khẩu 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.'
                    }
                ]);
            });

            function validateForm() {
                const nameInput = document.getElementById("fullName");
                const emailInput = document.getElementById("email");
                const passwordInput = document.getElementById("password");
                const confirmPasswordInput = document.getElementById("confirmPassword");

                const isNameValid = Validator.validateName(nameInput.value);
                Validator.showFeedback(nameInput, isNameValid, 'Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.');

                const isEmailValid = Validator.validateEmail(emailInput.value);
                Validator.showFeedback(emailInput, isEmailValid, 'Định dạng email không hợp lệ (tối đa 100 ký tự).');

                const isPasswordValid = Validator.validatePassword(passwordInput.value);
                Validator.showFeedback(passwordInput, isPasswordValid, 'Mật khẩu 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.');

                const isMatch = passwordInput.value === confirmPasswordInput.value;
                Validator.showFeedback(confirmPasswordInput, isMatch, 'Mật khẩu xác nhận không khớp!');

                return isNameValid && isEmailValid && isPasswordValid && isMatch;
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
