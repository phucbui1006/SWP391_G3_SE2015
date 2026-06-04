<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>

<%
    User account = (User) session.getAttribute("account");

    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/Login");
        return;
    }

    String roleName = account.getRoleName();
    if (roleName != null) {
        roleName = roleName.trim().toUpperCase();
    } else {
        roleName = "";
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Dashboard</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

        <style>
            .dashboard-content {
                padding: 30px;
                background: #f5f5f5;
                min-height: calc(100vh - 150px);
            }

            .dashboard-card {
                background: #fff;
                padding: 25px;
                border-radius: 8px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            }

            .dashboard-card h1 {
                margin-top: 0;
                color: #ed1c24;
            }

            .role-box {
                margin-top: 20px;
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 20px;
            }

            .role-item {
                background: #fff;
                border: 1px solid #ddd;
                border-left: 5px solid #ed1c24;
                padding: 18px;
                border-radius: 6px;
            }

            .role-item h3 {
                margin: 0 0 10px;
                color: #111;
            }

            .role-item p {
                margin: 0;
                color: #666;
            }

            @media (max-width: 900px) {
                .role-box {
                    grid-template-columns: 1fr;
                }
            }
        </style>
    </head>
    <body class="dashboard-body">

        <jsp:include page="/includes/header.jsp" />

        <div class="dashboard-content">
            <div class="dashboard-card">

                <% if ("ADMIN".equals(roleName)) { %>

                <h1>Admin Dashboard</h1>
                <p>Xin chào <b><%= account.getFullName() %></b>. Bạn đang đăng nhập với quyền <b>ADMIN</b>.</p>

                <div class="role-box">
                    <div class="role-item">
                        <h3>Quản lý đơn hàng</h3>
                        <p>Xem, cập nhật và xử lý đơn hàng.</p>
                    </div>

                    <div class="role-item">
                        <h3>Quản lý người dùng</h3>
                        <p>Quản lý tài khoản, vai trò và trạng thái người dùng.</p>
                    </div>

                    <div class="role-item">
                        <h3>Quản lý sản phẩm</h3>
                        <p>Thêm, sửa, xóa và cập nhật sản phẩm.</p>
                    </div>

                    <div class="role-item">
                        <h3>Lô hàng</h3>
                        <p>Quản lý lô hàng nhập vào hệ thống.</p>
                    </div>

                    <div class="role-item">
                        <h3>Bảo hành</h3>
                        <p>Theo dõi và xử lý thông tin bảo hành.</p>
                    </div>

                    <div class="role-item">
                        <h3>Thống kê doanh thu</h3>
                        <p>Xem báo cáo và thống kê doanh thu.</p>
                    </div>
                </div>


                <% } else if ("EMPLOYEE".equals(roleName)) { %>

                <h1>Employee Dashboard</h1>
                <p>Xin chào <b><%= account.getFullName() %></b>. Bạn đang đăng nhập với quyền <b>EMPLOYEE</b>.</p>

                <div class="role-box">
                    <div class="role-item">
                        <h3>Dịch vụ bảo hành</h3>
                        <p>Tiếp nhận và xử lý yêu cầu bảo hành.</p>
                    </div>

                    <div class="role-item">
                        <h3>Cập nhật trạng thái</h3>
                        <p>Cập nhật tiến trình xử lý bảo hành.</p>
                    </div>
                </div>

                <% } else if ("SHIPMENT".equals(roleName)) { %>

                <h1>Transport Dashboard</h1>
                <p>Xin chào <b><%= account.getFullName() %></b>. Bạn đang đăng nhập với quyền <b>SHIPMENT</b>.</p>

                <div class="role-box">
                    <div class="role-item">
                        <h3>Đơn hàng giao</h3>
                        <p>Xem danh sách đơn hàng cần vận chuyển.</p>
                    </div>
                    <div class="role-item">
                        <h3>Lịch sử giao hàng</h3>
                        <p>Theo dõi các đơn hàng đã giao.</p>
                    </div>

                    <div class="role-item">
                        <h3>Cập nhật trạng thái</h3>
                        <p>Cập nhật trạng thái giao hàng.</p>
                    </div>
                </div>

                <% } else { %>

                <h1>Không có quyền truy cập</h1>
                <p>Tài khoản của bạn chưa được gán vai trò hợp lệ.</p>

                <% } %>

            </div>
        </div>
        <jsp:include page="/includes/footer.jsp" />

    </body>
</html>