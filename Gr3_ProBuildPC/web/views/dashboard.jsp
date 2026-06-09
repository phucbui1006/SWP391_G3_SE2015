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
    </head>
    <body class="dashboard-body">

        <jsp:include page="/includes/header.jsp" />

        <div class="dashboard-content">
            <div class="dashboard-card <%= "EMPLOYEE".equals(roleName) ? "employee-shell" : "" %>">

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

                <div class="employee-dashboard">
                    <div class="employee-summary-grid" aria-label="Thống kê yêu cầu bảo hành">
                        <div class="employee-summary-card">
                            <span class="summary-icon today">📚</span>
                            <div class="summary-copy">
                                <p class="summary-title">Tất cả yêu cầu</p>
                                <div class="summary-value-row">
                                    <span class="summary-number">8</span>
                                    <span class="summary-unit">yêu cầu</span>
                                </div>
                            </div>
                        </div>

                        <div class="employee-summary-card">
                            <span class="summary-icon waiting">⏳</span>
                            <div class="summary-copy">
                                <p class="summary-title">Chờ xác nhận</p>
                                <div class="summary-value-row">
                                    <span class="summary-number">5</span>
                                    <span class="summary-unit">yêu cầu</span>
                                </div>
                            </div>
                        </div>

                        <div class="employee-summary-card">
                            <span class="summary-icon received">📥</span>
                            <div class="summary-copy">
                                <p class="summary-title">Đã tiếp nhận</p>
                                <div class="summary-value-row">
                                    <span class="summary-number">2</span>
                                    <span class="summary-unit">yêu cầu</span>
                                </div>
                            </div>
                        </div>

                        <div class="employee-summary-card">
                            <span class="summary-icon rejected">❌</span>
                            <div class="summary-copy">
                                <p class="summary-title">Từ chối</p>
                                <div class="summary-value-row">
                                    <span class="summary-number">1</span>
                                    <span class="summary-unit">yêu cầu</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <section class="employee-request-panel">
                        <h2 class="employee-request-title">Danh sách yêu cầu bảo hành</h2>

                        <div class="employee-request-tabs" role="tablist" aria-label="Lọc yêu cầu bảo hành">
                            <a class="employee-request-tab active" href="#">Tất cả yêu cầu</a>
                            <a class="employee-request-tab" href="#">Chờ xác nhận</a>
                            <a class="employee-request-tab" href="#">Đã tiếp nhận</a>
                            <a class="employee-request-tab" href="#">Từ chối</a>
                        </div>

                        <table class="employee-request-table">
                            <thead>
                                <tr>
                                    <th>Mã yêu cầu</th>
                                    <th>Khách hàng</th>
                                    <th>Sản phẩm</th>
                                    <th>Ngày tạo</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>1</td>
                                    <td>Nguyễn Văn A</td>
                                    <td>ASUS TUF B760M-PLUS WIFI DDR5</td>
                                    <td>26/05/2024</td>
                                    <td><span class="request-status waiting">Chờ xác nhận</span></td>
                                </tr>
                                <tr>
                                    <td>2</td>
                                    <td>Trần Văn B</td>
                                    <td>Intel Core i5-14600KF</td>
                                    <td>26/05/2024</td>
                                    <td><span class="request-status received">Đã tiếp nhận</span></td>
                                </tr>
                                <tr>
                                    <td>10</td>
                                    <td>Lê Minh C</td>
                                    <td>G.Skill Ripjaws S5 16GB DDR5</td>
                                    <td>25/05/2024</td>
                                    <td><span class="request-status waiting">Chờ xác nhận</span></td>
                                </tr>
                                <tr>
                                    <td>8</td>
                                    <td>Phạm Hữu D</td>
                                    <td>ASUS Dual RTX 4060 8GB</td>
                                    <td>25/05/2024</td>
                                    <td><span class="request-status received">Đã tiếp nhận</span></td>
                                </tr>
                                <tr>
                                    <td>7</td>
                                    <td>Hoàng Gia E</td>
                                    <td>Kingston NV2 1TB NVMe</td>
                                    <td>24/05/2024</td>
                                    <td><span class="request-status rejected">Từ chối</span></td>
                                </tr>
                            </tbody>
                        </table>
                    </section>
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
