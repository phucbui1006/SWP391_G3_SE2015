<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Đặt lại mật khẩu</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>
    <body>

        <div class="card-container">
            <h2 class="card-title">Đặt lại mật khẩu</h2>

            <form action="${pageContext.request.contextPath}/ResetPassword" method="post" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="password">Mật khẩu mới</label>

                    <div class="input-group">
                        <input type="password" id="password" name="password" placeholder="Nhập mật khẩu mới (8-31 ký tự, có hoa, thường và số)">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('password', this)"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu</label>

                    <div class="input-group">
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Xác nhận mật khẩu">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('confirmPassword', this)"></i>
                    </div>
                </div>

                <button type="submit" class="btn-submit">Cập nhật mật khẩu</button>
            </form>

            <%
                String error = (String) request.getAttribute("error");

                if (error != null) {
            %>
            <div style="color:red; text-align:center; margin-top:15px;"><%= error %></div>
            <%
                }
            %>
        </div>

        <script>
            document.addEventListener("DOMContentLoaded", function() {
                Validator.setupRealTimeValidation([
                    {
                        selector: '#password',
                        validateFn: (val) => Validator.validatePassword(val),
                        getErrorMsg: () => 'Mật khẩu từ 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.'
                    }
                ]);
            });

            function validateForm() {
                const passwordInput = document.getElementById("password");
                const confirmPasswordInput = document.getElementById("confirmPassword");

                const isPasswordValid = Validator.validatePassword(passwordInput.value);
                Validator.showFeedback(passwordInput, isPasswordValid, 'Mật khẩu từ 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.');

                const isMatch = passwordInput.value === confirmPasswordInput.value;
                Validator.showFeedback(confirmPasswordInput, isMatch, 'Mật khẩu xác nhận không khớp!');

                return isPasswordValid && isMatch;
            }
        </script>
    </body>
</html>