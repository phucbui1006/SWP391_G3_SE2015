<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đổi mật khẩu bắt buộc</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>
    <body>

        <div class="card-container">
            <h2 class="card-title">Đổi mật khẩu lần đầu</h2>
            <p style="text-align: center; color: #555; margin-bottom: 20px;">
                Vì lý do bảo mật, bạn bắt buộc phải đổi mật khẩu trong lần đăng nhập đầu tiên.
            </p>

            <form action="${pageContext.request.contextPath}/ForceChangePassword" method="post" onsubmit="return validateForm()">
                
                <div class="form-group">
                    <label for="newPassword">Mật khẩu mới</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="newPassword" name="newPassword" placeholder="Nhập mật khẩu mới" 
                               required minlength="8" maxlength="31" class="pass-input">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('newPassword', this)"></i>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Xác nhận mật khẩu</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Nhập lại mật khẩu mới" 
                               required minlength="8" maxlength="31" class="pass-input">
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
                        selector: '#newPassword',
                        validateFn: (val) => Validator.validatePassword(val),
                        getErrorMsg: () => 'Mật khẩu 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.'
                    }
                ]);
            });

            function validateForm() {
                const newPasswordInput = document.getElementById("newPassword");
                const confirmPasswordInput = document.getElementById("confirmPassword");

                const isPasswordValid = Validator.validatePassword(newPasswordInput.value);
                Validator.showFeedback(newPasswordInput, isPasswordValid, 'Mật khẩu 8-31 ký tự, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.');

                const isMatch = newPasswordInput.value === confirmPasswordInput.value;
                Validator.showFeedback(confirmPasswordInput, isMatch, 'Mật khẩu xác nhận không khớp!');

                return isPasswordValid && isMatch;
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
