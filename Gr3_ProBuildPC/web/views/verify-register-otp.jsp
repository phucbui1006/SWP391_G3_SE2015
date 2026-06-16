<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Xác nhận OTP Đăng Ký</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>
    <body>

        <div class="card-container">
            <h2 class="card-title">Xác nhận mã OTP</h2>

            <form action="${pageContext.request.contextPath}/VerifyRegisterOtp" method="post" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="otp">Mã xác nhận</label>

                    <div class="input-group">
                        <input type="text" id="otp" name="otp" placeholder="Nhập mã OTP đã gửi đến email" required maxlength="6">
                    </div>
                </div>

                <button type="submit" class="btn-submit">Xác nhận</button>
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
                        selector: '#otp',
                        validateFn: (val) => Validator.validateOTP(val),
                        getErrorMsg: () => 'Mã OTP phải gồm đúng 6 chữ số.'
                    }
                ]);
            });

            function validateForm() {
                const otpInput = document.getElementById("otp");
                const isValid = Validator.validateOTP(otpInput.value);
                Validator.showFeedback(otpInput, isValid, 'Mã OTP phải gồm đúng 6 chữ số.');
                return isValid;
            }
        </script>
    </body>
</html>
