<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>E-TECH Login</title>

        <link rel="stylesheet" href="../css/style.css">

        <link rel="stylesheet" href="../css/style.css">
    </head>
    <body>

        <div class="home-navigation">
            <a href="home.jsp" class="home-link">Home</a>
        </div>

        <div class="card-container">
            <h2 class="card-title">Chào mừng trở lại !</h2>

            <form action="${pageContext.request.contextPath}/login" method="POST">
                <div class="form-group">
                    <label for="email">Email</label>
                    <div class="input-group">
                        <i class="fa-regular fa-envelope left-icon"></i>
                        <input type="email" id="email" name="email" placeholder="Email Address" required>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <div class="input-group">
                        <i class="fa-solid fa-lock left-icon"></i>
                        <input type="password" id="password" name="password" placeholder="••••••••" required class="pass-input">
                        <i class="fa-regular fa-eye toggle-password" onclick="togglePass('password', this)"></i>
                    </div>
                </div>

                <div class="forgot-password-container">
                    <a href="forget-password.jsp" class="forgot-link">Quên mật khẩu?</a>
                </div>

                <button type="submit" class="btn-submit">Đăng nhập</button>
            </form>

            <div class="footer-text">
                Bạn chưa có tài khoản? <a href="register.jsp">Đăng ký</a>
            </div>
        </div>


    </body>
</html>