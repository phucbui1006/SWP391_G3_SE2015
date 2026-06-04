<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ProBuild PC - My Profile</title>
    
    <link rel="stylesheet" type="text/css" href="../css/style.css">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body class="profile-body">
    <div class="home-navigation">
        <a style="color: black" href="${pageContext.request.contextPath}/home" class="home-link">Home</a>
        </div>

    <div class="profile-container">
        
        <div class="profile-left">
            <div class="overlay-text">
                <h2>ProBuild PC</h2>
                <p>Cập nhật hồ sơ để bảo mật tài khoản và quản lý đơn hàng của bạn tốt hơn.</p>
            </div>
        </div>
        
        <div class="profile-right">
            <h2 class="profile-title">Thông tin cá nhân</h2>
            
            <form action="../ProfileServlet" method="POST" class="profile-form">
                
                <div class="profile-form-group">
                    <label class="profile-label">Email</label>
                    <div class="profile-input-wrapper">
                        <input type="email" name="email" value="phamthutrang@gmail.com" readonly>
                        <i class="fa-solid fa-lock lock-icon"></i>
                    </div>
                </div>

                <div class="profile-form-group">
                    <label class="profile-label" for="fullName">Họ tên</label>
                    <div class="profile-input-wrapper">
                        <input type="text" id="fullName" name="fullName" value="Pham Thu Trang" required>
                    </div>
                </div>

                <div class="profile-form-group">
                    <label class="profile-label" for="currentPassword">Mật khẩu cũ</label>
                    <div class="profile-input-wrapper">
                        <input type="password" id="currentPassword" name="currentPassword" placeholder="•••••••••" required>
                        <i class="fa-regular fa-eye toggle-eye" onclick="toggleProfilePass('currentPassword', this)"></i>
                    </div>
                </div>

                <div class="profile-form-group">
                    <label class="profile-label" for="newPassword">Mật khẩu mới</label>
                    <div class="profile-input-wrapper">
                        <input type="password" id="newPassword" name="newPassword" placeholder="•••••••••" required>
                        <i class="fa-regular fa-eye toggle-eye" onclick="toggleProfilePass('newPassword', this)"></i>
                        
                    </div>
                </div>

                <div class="profile-form-group">
                    <label class="profile-label" for="confirmPassword">Xác nhận mật khẩu mới</label>
                    <div class="profile-input-wrapper">
                        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="•••••••••" required>
                        <i class="fa-regular fa-eye toggle-eye" onclick="toggleProfilePass('confirmPassword', this)"></i>
                        
                    </div>
                </div>

                
                
            </form>
            <div class="profile-action-row">
                    <button type="submit" class="profile-btn-save">Lưu thay đổi</button>
                </div>
        </div>
        
    </div>

    <script>
        function toggleProfilePass(inputId, icon) {
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