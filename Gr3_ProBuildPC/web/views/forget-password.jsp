<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC - Quên mật khẩu</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>
    <body>

        <div class="card-container">
            <h2 class="card-title">Quên mật khẩu</h2>

            <p class="card-description">
                Nhập email đã đăng ký để nhận đường liên kết đặt lại mật khẩu.
            </p>

            <form action="${pageContext.request.contextPath}/ForgotPassword" method="post">
                <div class="form-group" style="margin-bottom: 25px;">
                    <label for="email">Email</label>
                    <div class="input-group">
                        <i class="fa-regular fa-envelope left-icon"></i>
                        <input type="email" id="email" name="email" placeholder="Nhập email của bạn" required>
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