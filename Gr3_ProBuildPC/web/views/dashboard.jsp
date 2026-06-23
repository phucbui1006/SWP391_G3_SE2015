<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.AdminDashboardView" %>
<%@ page import="model.OrderHistoryItem" %>
<%@ page import="model.OrderStatus" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="util.DashboardViewHelper" %>

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

    String ctx = request.getContextPath();
    final int ADMIN_TABLE_ROWS = 5;
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
            <div class="dashboard-card <%= "ADMIN".equals(roleName) ? "admin-shell" : ("EMPLOYEE".equals(roleName) ? "employee-shell" : ("SHIPMENT".equals(roleName) ? "shipment-shell" : "")) %>">

                <% if ("ADMIN".equals(roleName)) {
                    AdminDashboardView adminDashboard = (AdminDashboardView) request.getAttribute("adminDashboard");
                %>

                <div class="admin-dashboard">
                    <div class="dashboard-page-heading admin-dashboard-heading">
                     
                        <form class="admin-date-filter" action="<%= adminDashboard.getFormAction() %>" method="get">
                            <input type="date" name="date" value="<%= adminDashboard.getSelectedDate() %>">
                            <button type="submit">Xem</button>
                        </form>
                    </div>

                    <div class="admin-stat-grid" >
                        <% for (AdminDashboardView.StatCard stat : adminDashboard.getStatCards()) { %>
                        <a class="admin-stat-card" >
                            <span class="admin-stat-icon <%= stat.getIconClass() %>"><%= stat.getIcon() %></span>
                            <span>
                                <small><%= stat.getLabel() %></small>
                                <strong><%= stat.getValue() %></strong>
                            </span>
                        </a>
                        <% } %>
                    </div>

                    <div class="admin-dashboard-grid admin-products-grid">
                        <section class="admin-panel admin-module-panel">
                            <div class="admin-panel-header">
                                <h2>Sản phẩm bán chạy nhất</h2>
                            </div>

                            <table class="admin-dashboard-table admin-best-selling-table">
                                <thead>
                                    <tr>
                                        <th>Mã SP</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Đã bán</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (int rowIndex = 0; rowIndex < ADMIN_TABLE_ROWS; rowIndex++) {
                                        if (rowIndex < adminDashboard.getBestSellingProducts().size()) {
                                            AdminDashboardView.ProductRow product = adminDashboard.getBestSellingProducts().get(rowIndex);
                                    %>
                                    <tr>
                                        <td><%= product.getProductCode() %></td>
                                        <td><%= product.getProductName() %></td>
                                        <td><%= product.getSoldQuantity() %></td>
                                    </tr>
                                    <% } else { %>
                                    <tr class="admin-placeholder-row">
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                    </tr>
                                    <% }
                                    } %>
                                </tbody>
                            </table>
                            <% if (adminDashboard.getBestSellingFooterMessage() != null) { %>
                            <div class="admin-panel-footer">
                                <span><%= adminDashboard.getBestSellingFooterMessage() %></span>
                                <a href="#">Xem tất cả</a>
                            </div>
                            <% } %>
                        </section>

                        <aside class="admin-panel admin-quick-panel">
                            <div class="admin-panel-header">
                                <h2>Sản phẩm sắp hết hàng</h2>
                            </div>

                            <table class="admin-dashboard-table admin-low-stock-table compact">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>SL</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (int rowIndex = 0; rowIndex < ADMIN_TABLE_ROWS; rowIndex++) {
                                        if (rowIndex < adminDashboard.getLowStockProducts().size()) {
                                            AdminDashboardView.ProductRow product = adminDashboard.getLowStockProducts().get(rowIndex);
                                    %>
                                    <tr>
                                        <td><%= product.getProductName() %></td>
                                        <td><%= product.getStockQuantity() %></td>
                                        <td><span class="admin-status <%= product.getStatusClass() %>"><%= product.getStatus() %></span></td>
                                    </tr>
                                    <% } else { %>
                                    <tr class="admin-placeholder-row">
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                    </tr>
                                    <% }
                                    } %>
                                </tbody>
                            </table>
                            <% if (adminDashboard.getLowStockFooterMessage() != null) { %>
                            <div class="admin-panel-footer">
                                <span><%= adminDashboard.getLowStockFooterMessage() %></span>
                                <a href="#">Xem tất cả</a>
                            </div>
                            <% } %>
                        </aside>
                    </div>

                    <div class="admin-dashboard-grid admin-bottom-grid">
                        <section class="admin-panel">
                            <div class="admin-panel-header">
                                <h2>Đơn hàng mới nhất</h2>
                            </div>

                            <table class="admin-dashboard-table admin-latest-orders-table">
                                <thead>
                                    <tr>
                                        <th>Mã đơn</th>
                                        <th>Khách hàng</th>
                                        <th>Tổng tiền</th>
                                        <th>Trạng thái</th>
                                        <th>Thời gian</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (int rowIndex = 0; rowIndex < ADMIN_TABLE_ROWS; rowIndex++) {
                                        if (rowIndex < adminDashboard.getLatestOrders().size()) {
                                            AdminDashboardView.OrderRow order = adminDashboard.getLatestOrders().get(rowIndex);
                                    %>
                                    <tr>
                                        <td><%= order.getOrderCode() %></td>
                                        <td><%= order.getCustomerName() %></td>
                                        <td><%= order.getTotalAmount() %></td>
                                        <td><span class="shipment-status <%= order.getStatusClass() %>"><%= order.getStatus() %></span></td>
                                        <td><%= order.getOrderDate() %></td>
                                    </tr>
                                    <% } else { %>
                                    <tr class="admin-placeholder-row">
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                        <td>&nbsp;</td>
                                    </tr>
                                    <% }
                                    } %>
                                </tbody>
                            </table>
                            <% if (adminDashboard.getLatestOrdersFooterMessage() != null) { %>
                            <div class="admin-panel-footer">
                                <span><%= adminDashboard.getLatestOrdersFooterMessage() %></span>
                                <a href="<%= adminDashboard.getLatestOrdersFooterUrl() %>">Xem tất cả</a>
                            </div>
                            <% } %>
                        </section>

                        <aside class="admin-panel">
                            <div class="admin-panel-header">
                                <h2>Yêu cầu bảo hành</h2>
                            </div>

                            <div class="admin-count-list">
                                <% if (adminDashboard.getWarrantyStatusCounts().isEmpty()) { %>
                                <p class="admin-empty-message">Không có yêu cầu bảo hành trong ngày này.</p>
                                <% } else {
                                    for (AdminDashboardView.CountRow entry : adminDashboard.getWarrantyStatusCounts()) { %>
                                <p>
                                    <span><%= entry.getLabel() %></span>
                                    <strong><%= entry.getValue() %></strong>
                                </p>
                                <% }
                                } %>
                            </div>
                            <% if (adminDashboard.isShowWarrantyFooter()) { %>
                            <div class="admin-panel-footer">
                                <span><%= adminDashboard.getWarrantyFooterMessage() %></span>
                                <a href="<%= adminDashboard.getWarrantyAllUrl() %>">Xem tất cả</a>
                            </div>
                            <% } %>
                        </aside>
                        <section class="admin-panel">
                            <div class="admin-panel-header">
                                <h2>Tổng quan tài khoản</h2>
                            </div>

                            <div class="admin-account-grid">
                                <% for (AdminDashboardView.CountRow accountRow : adminDashboard.getAccountSummaries()) { %>
                                <div><span><%= accountRow.getLabel() %></span><strong><%= accountRow.getValue() %></strong></div>
                                <% } %>
                            </div>
                        </section>
                    </div>
                </div>


                <% } else if ("EMPLOYEE".equals(roleName)) { %>

                <div class="employee-dashboard">
                    <div class="dashboard-page-heading">
                        
                    </div>

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

                <%
                    List<OrderHistoryItem> shipmentOrders = (List<OrderHistoryItem>) request.getAttribute("shipmentOrders");
                    List<OrderStatus> shipmentStatusOptions = (List<OrderStatus>) request.getAttribute("shipmentStatusOptions");
                    Map<Integer, Integer> shipmentStatusCounts = (Map<Integer, Integer>) request.getAttribute("shipmentStatusCounts");
                    Integer shipmentSelectedStatusId = (Integer) request.getAttribute("shipmentSelectedStatusId");
                    Integer shipmentPageObject = (Integer) request.getAttribute("shipmentPage");
                    Integer shipmentTotalPagesObject = (Integer) request.getAttribute("shipmentTotalPages");
                    Integer shipmentTotalOrdersObject = (Integer) request.getAttribute("shipmentTotalOrders");
                    Integer shipmentAllActiveCountObject = (Integer) request.getAttribute("shipmentAllActiveCount");
                    Integer shipmentTodayCountObject = (Integer) request.getAttribute("shipmentTodayCount");
                    Boolean shipmentTodayOnlyObject = (Boolean) request.getAttribute("shipmentTodayOnly");
                    int shipmentPage = shipmentPageObject == null ? 1 : shipmentPageObject;
                    int shipmentTotalPages = shipmentTotalPagesObject == null ? 1 : shipmentTotalPagesObject;
                    int shipmentTotalOrders = shipmentTotalOrdersObject == null ? 0 : shipmentTotalOrdersObject;
                    int shipmentAllActiveCount = shipmentAllActiveCountObject == null ? 0 : shipmentAllActiveCountObject;
                    int shipmentTodayCount = shipmentTodayCountObject == null ? 0 : shipmentTodayCountObject;
                    boolean shipmentTodayOnly = shipmentTodayOnlyObject != null && shipmentTodayOnlyObject;
                %>

                <div class="shipment-dashboard">
                    <div class="dashboard-page-heading">
                     
                    </div>

                    <div class="shipment-summary-grid" aria-label="Thống kê đơn hàng vận chuyển">
                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon all">#</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Tất cả đơn hàng</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number"><%= shipmentAllActiveCount %></span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon today">✓</span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Đơn hàng hôm nay</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number"><%= shipmentTodayCount %></span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <% if (shipmentStatusOptions != null) {
                            for (OrderStatus status : shipmentStatusOptions) {
                                Integer countValue = shipmentStatusCounts == null ? null : shipmentStatusCounts.get(status.getStatusId());
                        %>
                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon <%= DashboardViewHelper.statusClass(status.getStatusName()) %>"><%= DashboardViewHelper.statusIcon(status.getStatusName()) %></span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title"><%= DashboardViewHelper.h(status.getStatusName()) %></p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number"><%= countValue == null ? 0 : countValue %></span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>
                        <% }
                        } %>
                    </div>

                    <section class="shipment-order-panel">
                        <div class="shipment-order-header">
                            <div class="shipment-order-title-row">
                                <h2 class="shipment-order-title">Danh sách đơn hàng vận chuyển</h2>
                                <span><%= shipmentTotalOrders %> đơn phù hợp</span>
                            </div>

                            <div class="shipment-filter-tabs" aria-label="Lọc đơn hàng theo trạng thái">
                                <a class="shipment-filter-tab <%= shipmentSelectedStatusId == null && !shipmentTodayOnly ? "active" : "" %>"
                                   href="<%= DashboardViewHelper.buildShipmentLink(ctx, null, false, 1) %>">Tất cả</a>
                                <a class="shipment-filter-tab <%= shipmentTodayOnly ? "active" : "" %>"
                                   href="<%= DashboardViewHelper.buildShipmentLink(ctx, shipmentSelectedStatusId, true, 1) %>">Hôm nay</a>
                                <% if (shipmentStatusOptions != null) {
                                    for (OrderStatus status : shipmentStatusOptions) { %>
                                <a class="shipment-filter-tab <%= !shipmentTodayOnly && shipmentSelectedStatusId != null && shipmentSelectedStatusId == status.getStatusId() ? "active" : "" %>"
                                   href="<%= DashboardViewHelper.buildShipmentLink(ctx, status.getStatusId(), false, 1) %>"><%= DashboardViewHelper.h(status.getStatusName()) %></a>
                                <% }
                                } %>
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
                                <% if (shipmentOrders == null || shipmentOrders.isEmpty()) { %>
                                <tr>
                                    <td colspan="4">
                                        <p class="shipment-empty-message">Không có đơn hàng nào ở bộ lọc hiện tại.</p>
                                    </td>
                                </tr>
                                <% } else {
                                    for (OrderHistoryItem order : shipmentOrders) {
                                        String displayStatus = DashboardViewHelper.defaultText(order.getDisplayStatus(), "Chưa cập nhật");
                                %>
                                <tr>
                                    <td>
                                        PB<%= order.getOrderId() %>
                                    </td>
                                    <td>
                                        <%= DashboardViewHelper.h(DashboardViewHelper.defaultText(order.getRecipientName(), order.getCustomerName())) %>
                                    </td>
                                    <td><%= DashboardViewHelper.h(DashboardViewHelper.defaultText(order.getShippingAddress(), "Chưa cập nhật địa chỉ")) %></td>
                                    <td>
                                        <span class="shipment-status <%= DashboardViewHelper.statusClass(displayStatus) %>"><%= DashboardViewHelper.h(displayStatus) %></span>
                                    </td>
                                </tr>
                                <% }
                                } %>
                            </tbody>
                        </table>

                        <% if (shipmentTotalPages > 1) { %>
                        <div class="shipment-pagination">
                            <a class="<%= shipmentPage <= 1 ? "disabled" : "" %>"
                               href="<%= shipmentPage <= 1 ? "#" : DashboardViewHelper.buildShipmentLink(ctx, shipmentSelectedStatusId, shipmentTodayOnly, shipmentPage - 1) %>">‹</a>
                            <% for (int pageNumber = 1; pageNumber <= shipmentTotalPages; pageNumber++) { %>
                            <a class="<%= pageNumber == shipmentPage ? "active" : "" %>"
                               href="<%= DashboardViewHelper.buildShipmentLink(ctx, shipmentSelectedStatusId, shipmentTodayOnly, pageNumber) %>"><%= pageNumber %></a>
                            <% } %>
                            <a class="<%= shipmentPage >= shipmentTotalPages ? "disabled" : "" %>"
                               href="<%= shipmentPage >= shipmentTotalPages ? "#" : DashboardViewHelper.buildShipmentLink(ctx, shipmentSelectedStatusId, shipmentTodayOnly, shipmentPage + 1) %>">›</a>
                        </div>
                        <% } %>
                    </section>
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
