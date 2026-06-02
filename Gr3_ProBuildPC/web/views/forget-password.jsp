<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-TECH - Forgot Password</title>
    
    <link rel="stylesheet" type="text/css" href="css/style.css">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body>

   

    <div class="card-container">
        <h2 class="card-title">Quên mật khẩu?</h2>
        
        <p class="card-description">            
            Nhập email đã đăng ký để nhận đường liên kết đặt lại mật khẩu
        </p>
        
        <form action="ForgotPasswordServlet" method="POST">
            <div class="form-group" style="margin-bottom: 25px;">
                <div class="input-group">
                    <i class="fa-regular fa-envelope left-icon"></i>
                    <input type="email" id="email" name="email" placeholder="Nhập email" required>
                </div>
            </div>

            <button type="submit" class="btn-submit">Xác nhận</button>
        </form>

       
    </div>

</body>
</html>