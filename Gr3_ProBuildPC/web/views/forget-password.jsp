<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Quên mật khẩu</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>

        <div class="card-container">
            <h2 class="card-title">Quên mật khẩu</h2>

            <p class="card-description">
                Nhập email tài khoản của bạn. Hệ thống sẽ gửi mã xác nhận về email.
            </p>

            <form action="${pageContext.request.contextPath}/ForgotPassword" method="post">
                <div class="form-group">
                    <label>Email</label>

                    <div class="input-group">
                        <input type="email" name="email" placeholder="Nhập email của bạn" required>
                    </div>
                </div>

                <button type="submit" class="btn-submit">Gửi mã xác nhận</button>
            </form>

            <%
                String error = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");

                if (error != null) {
            %>
            <div style="color:red; text-align:center; margin-top:15px;"><%= error %></div>
            <%
                }

                if (success != null) {
            %>
            <div style="color:green; text-align:center; margin-top:15px;"><%= success %></div>
            <%
                }
            %>

            <div class="footer-text">
                <a href="${pageContext.request.contextPath}/Login">Quay lại đăng nhập</a>
            </div>
        </div>

    </body>
</html>