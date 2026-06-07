<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Đặt lại mật khẩu</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>

        <div class="card-container">
            <h2 class="card-title">Đặt lại mật khẩu</h2>

            <form action="${pageContext.request.contextPath}/ResetPassword" method="post">
                <div class="form-group">
                    <label>Mật khẩu mới</label>

                    <div class="input-group">
                        <input type="password" name="password" placeholder="Nhập mật khẩu mới" required>
                    </div>
                </div>

                <div class="form-group">
                    <label>Xác nhận mật khẩu</label>

                    <div class="input-group">
                        <input type="password" name="confirmPassword" placeholder="Xác nhận mật khẩu" required>
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

    </body>
</html>