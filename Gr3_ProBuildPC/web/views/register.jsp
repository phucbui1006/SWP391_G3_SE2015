<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-TECH - Register</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background: linear-gradient(rgba(0, 0, 0, 0.45), rgba(0, 0, 0, 0.45)), 
                         url('../images/background.jpg');
            background-size: cover;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 20px;
        }

        .brand-title {
            color: #ffffff;
            font-size: 2.2rem;
            font-weight: bold;
            letter-spacing: 3px;
            margin-bottom: 20px;
            text-shadow: 2px 2px 10px rgba(0, 0, 0, 0.9);
        }

        .card-container {
            background-color: #ffffff;
            border-radius: 8px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            width: 100%;
            max-width: 420px;
            padding: 35px 30px;
        }

        .card-title {
            text-align: center;
            font-size: 1.8rem;
            color: #333333;
            margin-bottom: 25px;
            font-weight: 500;
        }

        .form-group {
            margin-bottom: 18px;
        }

        .form-group label {
            display: block;
            font-size: 0.9rem;
            color: #333333;
            font-weight: 600;
            margin-bottom: 6px;
        }

        .input-group {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-group i.left-icon {
            position: absolute;
            left: 12px;
            color: #a0a0a0;
            font-size: 1rem;
        }

        .input-group i.toggle-password {
            position: absolute;
            right: 12px;
            color: #a0a0a0;
            cursor: pointer;
            padding: 5px;
            border-left: 1px solid #e0e0e0;
            padding-left: 10px;
        }

        .input-group i.toggle-password:hover {
            color: #555;
        }

        .input-group input {
            width: 100%;
            padding: 10px 12px 10px 38px;
            border: 1px solid #cccccc;
            border-radius: 4px;
            font-size: 0.95rem;
            color: #333333;
            outline: none;
            transition: border-color 0.2s;
        }
        
        .input-group input[type="password"], 
        .input-group input[type="text"].pass-input {
            padding-right: 40px;
        }

        .input-group input::placeholder {
            color: #b3b3b3;
        }

        .input-group input:focus {
            border-color: #888888;
        }

        .btn-submit {
            width: 100%;
            background-color: #800c1e; /* Màu đỏ đô sang trọng giống thiết kế */
            color: #ffffff;
            border: none;
            padding: 12px;
            border-radius: 6px;
            font-size: 1rem;
            font-weight: bold;
            cursor: pointer;
            margin-top: 10px;
            transition: background-color 0.2s;
        }

        .btn-submit:hover {
            background-color: #610714;
        }

        .footer-text {
            text-align: center;
            margin-top: 20px;
            font-size: 0.85rem;
            color: #555555;
        }

        .footer-text a {
            color: #333333;
            text-decoration: underline;
            font-weight: bold;
        }
    </style>
</head>
<body>


    <div class="card-container">
        <h2 class="card-title">Đăng ký tài khoản</h2>
        
        <form action="RegisterServlet" method="POST">
            <div class="form-group">
                <label for="name">Tên</label>
                <div class="input-group">
                    <i class="fa-regular fa-user left-icon"></i>
                    <input type="text" id="name" name="name" placeholder="Nguyen Van A" required>
                </div>
            </div>

            <div class="form-group">
                <label for="email">Email</label>
                <div class="input-group">
                    <i class="fa-regular fa-envelope left-icon"></i>
                    <input type="email" id="email" name="email" placeholder="Nhập email" required>
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

            <div class="form-group">
                <label for="confirmPassword">Xác nhận mật khẩu</label>
                <div class="input-group">
                    <i class="fa-solid fa-lock left-icon"></i>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="••••••••" required class="pass-input">
                    <i class="fa-regular fa-eye toggle-password" onclick="togglePass('confirmPassword', this)"></i>
                </div>
            </div>

            <button type="submit" class="btn-submit">Bắt đầu</button>
        </form>

        <div class="footer-text">
            Đã có tài khoản? <a href="login.jsp">Đăng nhập</a>
        </div>
    </div>

    <script>
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