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
            <div class="dashboard-card <%= "EMPLOYEE".equals(roleName) ? "employee-shell" : ("SHIPMENT".equals(roleName) ? "shipment-shell" : "") %>">

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

                <div class="shipment-dashboard">
                    <div class="shipment-summary-grid" aria-label="Thống kê đơn hàng vận chuyển">
                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon all">📋</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Tất cả đơn hàng của bạn</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number">24</span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon pending">⏳</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Chờ xác nhận</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number">5</span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon confirmed">✓</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Đã xác nhận</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number">4</span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon preparing">📦</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Đang chuẩn bị hàng</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number">3</span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon shipping">🚚</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Đang giao hàng</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number">6</span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon delivered">✓</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Đã giao hàng</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number">5</span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon cancelled">!</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Đã hủy</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number">1</span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <section class="shipment-order-panel">
                        <div class="shipment-order-header">
                            <h2 class="shipment-order-title">Danh sách đơn hàng</h2>

                            <div class="shipment-filter-tabs" aria-label="Lọc đơn hàng theo trạng thái">
                                <button class="shipment-filter-tab active" type="button" data-filter="all">Tất cả</button>
                                <button class="shipment-filter-tab" type="button" data-filter="pending">Chờ xác nhận</button>
                                <button class="shipment-filter-tab" type="button" data-filter="confirmed">Đã xác nhận</button>
                                <button class="shipment-filter-tab" type="button" data-filter="preparing">Đang chuẩn bị hàng</button>
                                <button class="shipment-filter-tab" type="button" data-filter="shipping">Đang giao hàng</button>
                                <button class="shipment-filter-tab" type="button" data-filter="delivered">Đã giao hàng</button>
                                <button class="shipment-filter-tab" type="button" data-filter="cancelled">Đã hủy</button>
                            </div>
                        </div>

                        <table class="shipment-order-table">
                            <thead>
                                <tr>
                                    <th>Mã đơn hàng</th>
                                    <th>Khách hàng</th>
                                    <th>Địa chỉ giao hàng</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr data-status="pending">
                                    <td>#DH10090</td>
                                    <td>Đỗ Hoàng K</td>
                                    <td>18 Lý Thường Kiệt, Q.10, TP.HCM</td>
                                    <td><span class="shipment-status pending">Chờ xác nhận</span></td>
                                </tr>
                                <tr data-status="confirmed">
                                    <td>#DH10089</td>
                                    <td>Vũ Thanh H</td>
                                    <td>99 Nguyễn Huệ, Q.1, TP.HCM</td>
                                    <td><span class="shipment-status confirmed">Đã xác nhận</span></td>
                                </tr>
                                <tr data-status="preparing">
                                    <td>#DH10088</td>
                                    <td>Mai Quốc P</td>
                                    <td>27 Âu Cơ, Q.Tân Bình, TP.HCM</td>
                                    <td><span class="shipment-status preparing">Đang chuẩn bị hàng</span></td>
                                </tr>
                                <tr data-status="shipping">
                                    <td>#DH10086</td>
                                    <td>Nguyễn Văn A</td>
                                    <td>123 Nguyễn Trãi, Q.1, TP.HCM</td>
                                    <td><span class="shipment-status shipping">Đang giao hàng</span></td>
                                </tr>
                                <tr data-status="shipping">
                                    <td>#DH10085</td>
                                    <td>Trần Văn B</td>
                                    <td>456 Lê Văn Sỹ, Q.3, TP.HCM</td>
                                    <td><span class="shipment-status shipping">Đang giao hàng</span></td>
                                </tr>
                                <tr data-status="shipping">
                                    <td>#DH10084</td>
                                    <td>Lê Minh C</td>
                                    <td>789 Cách Mạng Tháng 8, Q.10, TP.HCM</td>
                                    <td><span class="shipment-status shipping">Đang giao hàng</span></td>
                                </tr>
                                <tr data-status="shipping">
                                    <td>#DH10083</td>
                                    <td>Phạm Hữu D</td>
                                    <td>321 Điện Biên Phủ, Q.Bình Thạnh, TP.HCM</td>
                                    <td><span class="shipment-status shipping">Đang giao hàng</span></td>
                                </tr>
                                <tr data-status="delivered">
                                    <td>#DH10082</td>
                                    <td>Ngô Minh T</td>
                                    <td>72 Phan Xích Long, Q.Phú Nhuận, TP.HCM</td>
                                    <td><span class="shipment-status delivered">Đã giao hàng</span></td>
                                </tr>
                                <tr data-status="cancelled">
                                    <td>#DH10081</td>
                                    <td>Huỳnh Gia N</td>
                                    <td>11 Võ Văn Ngân, TP.Thủ Đức, TP.HCM</td>
                                    <td><span class="shipment-status cancelled">Đã hủy</span></td>
                                </tr>
                            </tbody>
                        </table>
                        <p class="shipment-empty-message" hidden>Không có đơn hàng nào ở trạng thái này.</p>
                    </section>
                </div>

                <% } else { %>

                <h1>Không có quyền truy cập</h1>
                <p>Tài khoản của bạn chưa được gán vai trò hợp lệ.</p>

                <% } %>

            </div>
        </div>
        <jsp:include page="/includes/footer.jsp" />

        <script>
            (function () {
                const filterTabs = document.querySelectorAll(".shipment-filter-tab");
                const orderRows = document.querySelectorAll(".shipment-order-table tbody tr[data-status]");
                const emptyMessage = document.querySelector(".shipment-empty-message");

                if (!filterTabs.length || !orderRows.length) {
                    return;
                }

                filterTabs.forEach(function (tab) {
                    tab.addEventListener("click", function () {
                        const selectedStatus = tab.dataset.filter;
                        let visibleCount = 0;

                        filterTabs.forEach(function (item) {
                            item.classList.toggle("active", item === tab);
                        });

                        orderRows.forEach(function (row) {
                            const isVisible = selectedStatus === "all" || row.dataset.status === selectedStatus;
                            row.hidden = !isVisible;

                            if (isVisible) {
                                visibleCount++;
                            }
                        });

                        if (emptyMessage) {
                            emptyMessage.hidden = visibleCount > 0;
                        }
                    });
                });
            })();
        </script>

    </body>
</html>
