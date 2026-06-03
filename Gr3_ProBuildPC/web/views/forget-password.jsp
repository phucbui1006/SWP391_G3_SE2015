<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<<<<<<< HEAD
<html>
    <head>
        <meta charset="UTF-8">
        <title>Quên mật khẩu</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>
=======
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-TECH - Forget Password</title>
    
    <link rel="stylesheet" type="text/css" href="css/style.css">
    
    <link rel="stylesheet" href="../css/style.css"><!-- comment -->
</head>
<body>
>>>>>>> 09f2d0e7b3c45b62d39fb275cfb2a06644824cca

        <div class="card-container">
            <h2 class="card-title">Quên mật khẩu</h2>

<<<<<<< HEAD
            <p class="card-description">
                Nhập email tài khoản của bạn. Hệ thống sẽ gửi mã xác nhận về email.
            </p>

            <form action="${pageContext.request.contextPath}/ForgotPassword" method="post">
                <div class="form-group">
                    <label>Email</label>

                    <div class="input-group">
                        <input type="email" name="email" placeholder="Nhập email của bạn" required>
                    </div>
=======
    <div class="card-container">
        <h2 class="card-title">Quên mật khẩu?</h2>
        
        <p class="card-description">            
            Nhập email đã đăng ký để nhận đường liên kết đặt lại mật khẩu
        </p>
        
        <form action="ForgetPasswordServlet" method="POST">
            <div class="form-group" style="margin-bottom: 25px;">
                <div class="input-group">
                    <i class="fa-regular fa-envelope left-icon"></i>
                    <input type="email" id="email" name="email" placeholder="Nhập email" required>
>>>>>>> 09f2d0e7b3c45b62d39fb275cfb2a06644824cca
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