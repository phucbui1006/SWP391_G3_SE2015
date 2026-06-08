<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    // Dữ liệu mẫu khớp 100% với danh sách INSERT lệnh dữ liệu SQL của bạn
    List<User> list = new ArrayList<>();
    list.add(new User(1, 3, "Bui Phuc", "ACTIVE", "bui.phuc.admin@gmail.com", "ADMIN"));
    list.add(new User(2, 2, "Nguyen Van Nam", "ACTIVE", "nguyenvannam@gmail.com", "EMPLOYEE"));
    list.add(new User(3, 4, "Tran Minh Quan", "ACTIVE", "tranminhquan@gmail.com", "SHIPMENT"));
    list.add(new User(4, 1, "Le Hoang Anh", "ACTIVE", "lehoanganh@gmail.com", "CUSTOMER"));
    list.add(new User(5, 1, "Pham Thu Trang", "ACTIVE", "phamthutrang@gmail.com", "CUSTOMER"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ProBuild PC - Quản lý tài khoản người dùng</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>
<body class="dashboard-body">

    <header class="main-header">
        <div class="header-top-line"></div>
        <div class="header-menu">
            <a href="dashboard.jsp" class="menu-item">Dashboard</a>
            <a href="#" class="menu-item">Quản lý đơn hàng</a>
            <a href="#" class="menu-item active">Tài khoản người dùng</a>
            <a href="#" class="menu-item">Sản phẩm</a>
            <a href="#" class="menu-item">Lô hàng</a>
            <a href="#" class="menu-item">Bảo hành</a>
            <a href="#" class="menu-item">Thống kê doanh thu</a>
            <a href="../Logout" class="menu-item logout">Đăng xuất</a>
        </div>
    </header>

    <div class="header-bottom">
        <div class="logo-box">
            <div class="logo-icon">P</div>
            <div>
                <h2>ProBuild <span>PC</span></h2>
                <p>Professionnel admin dashboard</p>
            </div>
        </div>
        
        <div class="sub-navigation">
            <a href="#" class="sub-nav-item">Quản dịch khoản</a>
            <a href="#" class="sub-nav-item">Tài khan hàng</a>
            <a href="#" class="sub-nav-item active">Tài khoản người dùng</a>
            <a href="#" class="sub-nav-item">Tài trò ở chặn</a>
            <a href="#" class="sub-nav-item">Tài kthật nhận</a>
            <a href="#" class="sub-nav-item">Đản hành hoàn</a>
        </div>

        <div class="right-box">
            <div class="user-box">
                <i class="fa-solid fa-circle-user user-icon"></i>
                <div>
                    <h4>Bui Phuc</h4>
                    <p>Admin</p>
                </div>
            </div>
        </div>
    </div>

    <main class="dashboard-container">
        
        <h1 class="main-page-title">Quản lý tài khoản người dùng</h1>

        <div class="search-filter-wrapper-card">
            <div class="search-input-group-container">
                <i class="fa-solid fa-magnifying-glass search-inner-icon"></i>
                <input type="text" class="search-main-input" placeholder="Tìm kiếm người dùng...">
            </div>
            <button class="btn-action-filter-trigger"><i class="fa-solid fa-sliders"></i> Bộ lọc</button>
        </div>

        <div class="management-card">
            <table class="user-table">
                <thead>
                    <tr>
                        <th style="width: 25%;">Tên người dùng</th>
                        <th style="width: 25%;">Email</th>
                        <th style="width: 15%;">Vai trò</th>
                        <th style="width: 15%;">Trạng thái</th>
                        <th style="text-align: center; width: 20%;">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <% if(list != null) { 
                        for(User u : list) { %>
                        <tr>
                            <td class="user-name-cell">
                                <i class="fa-solid fa-circle-user table-avatar-icon"></i>
                                <strong><%= u.getFullName() %></strong>
                            </td>
                            <td class="email-cell-text"><%= u.getEmail() %></td>
                            <td>
                                <div class="custom-select-role-container">
                                    <span class="role-badge role-<%= u.getRoleName().toLowerCase() %>">
                                        <%= u.getRoleName() %>
                                    </span>
                                    <i class="fa-solid fa-caret-down dropdown-select-arrow"></i>
                                </div>
                            </td>
                            <td>
                                <span class="status-badge-text <%= u.getStatus().toLowerCase() %>">
                                    <%= u.getStatus().equals("ACTIVE") ? "Hoạt động" : "Bị chặn" %>
                                </span>
                            </td>
                            <td style="text-align: center;">
                                <div class="action-buttons-flex-group">
                                    <a href="#" class="btn-table-action text-edit" title="Chỉnh sửa"><i class="fa-solid fa-pen-to-square"></i></a>
                                    <button class="btn-table-action text-ban" title="Ban người dùng" <%= u.getUserId() == 1 ? "disabled" : "" %>>ban</button>
                                    <a href="#" class="btn-table-action text-delete" title="Xóa tài khoản"><i class="fa-solid fa-trash"></i></a>
                                </div>
                            </td>
                        </tr>
                    <%   } 
                       } %>
                </tbody>
            </table>

            <div class="table-footer">
                <span class="footer-rows-count">Biảng - 1-5 của 12 đồng</span>
                <ul class="pagination-control-list">
                    <li><a href="#" class="page-nav-link disabled">&lt;</a></li>
                    <li><a href="#" class="page-nav-link active">1</a></li>
                    <li><a href="#" class="page-nav-link">2</a></li>
                    <li><a href="#" class="page-nav-link">3</a></li>
                    <li><span class="page-nav-ellipsis">...</span></li>
                    <li><a href="#" class="page-nav-link">10</a></li>
                    <li><a href="#" class="page-nav-link">&gt;</a></li>
                </ul>
            </div>
        </div>
    </main>

</body>
</html>