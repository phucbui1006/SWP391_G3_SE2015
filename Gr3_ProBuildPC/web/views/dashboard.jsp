<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.AdminDashboardView" %>
<%@ page import="model.OrderHistoryItem" %>
<%@ page import="model.OrderStatus" %>
<%@ page import="model.WarrantyRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
                            <span class="admin-stat-icon <%= stat.getIconClass() %>"><i class="<%= stat.getIcon() %>"></i></span>
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
                                <h2>Tổng quan đơn hàng trong ngày</h2>
                            </div>

                            <table class="admin-dashboard-table admin-order-summary-table">
                                <thead>
                                    <tr>
                                        <th>Thông tin</th>
                                        <th>Giá trị</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (adminDashboard.getOrderSummaries().isEmpty()) { %>
                                    <tr>
                                        <td colspan="2">
                                            <p class="admin-empty-message">Không có đơn hàng trong ngày đã chọn.</p>
                                        </td>
                                    </tr>
                                    <% } else {
                                        for (AdminDashboardView.OrderSummaryRow orderSummary : adminDashboard.getOrderSummaries()) {
                                            String orderSummaryStatusClass = orderSummary.getStatusClass();
                                            boolean hasStatusClass = orderSummaryStatusClass != null && !orderSummaryStatusClass.trim().isEmpty();
                                    %>
                                    <tr>
                                        <td><%= orderSummary.getLabel() %></td>
                                        <td>
                                            <% if (hasStatusClass) { %>
                                            <span class="shipment-status <%= orderSummaryStatusClass %>"><%= orderSummary.getValue() %></span>
                                            <% } else { %>
                                            <strong><%= orderSummary.getValue() %></strong>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <% }
                                    } %>
                                </tbody>
                            </table>
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

                <%
                    List<WarrantyRequest> employeeWarranties = (List<WarrantyRequest>) request.getAttribute("employeeWarranties");
                    List<OrderHistoryItem> employeeOrders = (List<OrderHistoryItem>) request.getAttribute("employeeOrders");
                    int warrantyTotal = (Integer) request.getAttribute("employeeWarrantyTotal");
                    int waitingWarrantyCount = (Integer) request.getAttribute("employeeWaitingWarrantyCount");
                    int receivedWarrantyCount = (Integer) request.getAttribute("employeeReceivedWarrantyCount");
                    int orderTotal = (Integer) request.getAttribute("employeeOrderTotal");
                    int failedOrderCount = (Integer) request.getAttribute("employeeFailedOrderCount");
                    int cancelledOrderCount = (Integer) request.getAttribute("employeeCancelledOrderCount");
                    SimpleDateFormat employeeDateFormat = new SimpleDateFormat("dd/MM/yyyy");
                %>

                <div class="employee-dashboard">
                    <div class="employee-summary-grid" aria-label="Tổng quan công việc cần xử lý">
                        <div class="employee-summary-card">
                            <span class="summary-icon today"><i class="fa-solid fa-list-check"></i></span>
                            <div class="summary-copy">
                                <p class="summary-title">Tổng công việc cần xử lý</p>
                                <div class="summary-value-row">
                                    <span class="summary-number"><%= warrantyTotal + orderTotal %></span>
                                    <span class="summary-unit">mục</span>
                                </div>
                            </div>
                        </div>

                        <div class="employee-summary-card">
                            <span class="summary-icon waiting"><i class="fa-regular fa-clock"></i></span>
                            <div class="summary-copy">
                                <p class="summary-title">Bảo hành chờ tiếp nhận</p>
                                <div class="summary-value-row">
                                    <span class="summary-number"><%= waitingWarrantyCount %></span>
                                    <span class="summary-unit">yêu cầu</span>
                                </div>
                            </div>
                        </div>

                        <div class="employee-summary-card">
                            <span class="summary-icon received"><i class="fa-solid fa-inbox"></i></span>
                            <div class="summary-copy">
                                <p class="summary-title">Bảo hành đã tiếp nhận</p>
                                <div class="summary-value-row">
                                    <span class="summary-number"><%= receivedWarrantyCount %></span>
                                    <span class="summary-unit">yêu cầu</span>
                                </div>
                            </div>
                        </div>

                        <div class="employee-summary-card">
                            <span class="summary-icon rejected"><i class="fa-solid fa-triangle-exclamation"></i></span>
                            <div class="summary-copy">
                                <p class="summary-title">Giao hàng thất bại</p>
                                <div class="summary-value-row">
                                    <span class="summary-number"><%= failedOrderCount %></span>
                                    <span class="summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="employee-summary-card">
                            <span class="summary-icon cancelled"><i class="fa-solid fa-ban"></i></span>
                            <div class="summary-copy">
                                <p class="summary-title">Đơn hàng đã hủy</p>
                                <div class="summary-value-row">
                                    <span class="summary-number"><%= cancelledOrderCount %></span>
                                    <span class="summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <section class="employee-request-panel">
                        <div class="employee-panel-title-row">
                            <h2 class="employee-request-title">5 yêu cầu bảo hành mới nhất cần xử lý</h2>
                            <a href="<%= ctx %>/ManageWarranty">Xem dịch vụ bảo hành</a>
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
                                <% if (employeeWarranties.isEmpty()) { %>
                                <tr>
                                    <td colspan="5" class="employee-empty-row">Không có yêu cầu bảo hành cần xử lý.</td>
                                </tr>
                                <% } %>
                                <% for (WarrantyRequest warranty : employeeWarranties) { %>
                                <tr>
                                    <td><a href="<%= ctx %>/ManageWarranty?warrantyId=<%= warranty.getWarrantyId() %>">#<%= warranty.getWarrantyId() %></a></td>
                                    <td><%= DashboardViewHelper.h(warranty.getCustomerName()) %></td>
                                    <td><%= DashboardViewHelper.h(warranty.getProductName()) %></td>
                                    <td><%= warranty.getRequestDate() == null ? "-" : employeeDateFormat.format(warranty.getRequestDate()) %></td>
                                    <td><span class="request-status <%= warranty.getStatusId() == 1 ? "waiting" : "received" %>"><%= DashboardViewHelper.h(warranty.getStatusName()) %></span></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% if (warrantyTotal > 5) { %>
                        <a class="employee-more-link" href="<%= ctx %>/ManageWarranty">
                            Còn <%= warrantyTotal - 5 %> đơn bảo hành bạn cần xử lý
                            <i class="fa-solid fa-arrow-right"></i>
                        </a>
                        <% } %>
                    </section>

                    <section class="employee-request-panel">
                        <div class="employee-panel-title-row">
                            <h2 class="employee-request-title">Yêu cầu đơn hàng cần xử lý</h2>
                            <a href="<%= ctx %>/order-history">Xem tất cả đơn hàng</a>
                        </div>

                        <table class="employee-request-table employee-order-request-table">
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Ngày đặt</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (employeeOrders.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="employee-empty-row">Không có đơn hàng cần xử lý.</td>
                                </tr>
                                <% } %>
                                <% for (OrderHistoryItem order : employeeOrders) { %>
                                <tr>
                                    <td>#<%= order.getOrderId() %></td>
                                    <td><%= DashboardViewHelper.h(order.getCustomerName()) %></td>
                                    <td><%= order.getOrderDate() == null ? "-" : employeeDateFormat.format(order.getOrderDate()) %></td>
                                    <td><%= DashboardViewHelper.formatCurrency(order.getTotalAmount()) %></td>
                                    <td><span class="request-status rejected"><%= DashboardViewHelper.h(order.getStatusName()) %></span></td>
                                    <td><a class="employee-row-action" href="<%= ctx %>/order-history?statusId=<%= order.getStatusId() %>&selectedOrderId=<%= order.getOrderId() %>">Xem chi tiết</a></td>
                                </tr>
                                <% } %>
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
                            <span class="shipment-summary-icon all"><i class="fa-solid fa-boxes-stacked"></i></span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title">Tất cả đơn hàng</p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number"><%= shipmentAllActiveCount %></span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>

                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon today"><i class="fa-solid fa-calendar-check"></i></span>
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
                            <span class="shipment-summary-icon <%= DashboardViewHelper.statusClass(status.getStatusName()) %>"><i class="<%= DashboardViewHelper.statusIcon(status.getStatusName()) %>"></i></span>
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
                                <span style="background: none";><%= shipmentTotalOrders %> đơn phù hợp</span>
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
