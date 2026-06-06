<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Xác nhận OTP</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>

        <div class="card-container">
            <h2 class="card-title">Xác nhận mã OTP</h2>

            <form action="${pageContext.request.contextPath}/VerifyOtp" method="post">
                <div class="form-group">
                    <label>Mã xác nhận</label>

                    <div class="input-group">
                        <input type="text" name="otp" placeholder="Nhập mã OTP" required>
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

    </body>
</html>