<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.OrderHistoryItem" %>
<%@ page import="model.OrderStatus" %>
<%@ page import="dal.AdminDashboardDAO.AccountSummary" %>
<%@ page import="dal.AdminDashboardDAO.DashboardProduct" %>
<%@ page import="dal.AdminDashboardDAO.DashboardSummary" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%!
    private String h(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    private String defaultText(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    private String statusClass(String status) {
        String value = status == null ? "" : status.toLowerCase();
        if (value.contains("hủy") || value.contains("huy")) {
            return "cancelled";
        }
        if (value.contains("đã giao") || value.contains("da giao")) {
            return "delivered";
        }
        if (value.contains("đang giao") || value.contains("dang giao")) {
            return "shipping";
        }
        if (value.contains("chuẩn bị") || value.contains("chuan bi")) {
            return "preparing";
        }
        if (value.contains("xác nhận") || value.contains("xac nhan")) {
            return value.contains("chờ") || value.contains("cho ") ? "pending" : "confirmed";
        }
        return "all";
    }

    private String statusIcon(String status) {
        String cssClass = statusClass(status);
        if ("pending".equals(cssClass)) {
            return "!";
        }
        if ("confirmed".equals(cssClass) || "delivered".equals(cssClass)) {
            return "✓";
        }
        if ("preparing".equals(cssClass)) {
            return "□";
        }
        if ("shipping".equals(cssClass)) {
            return "→";
        }
        if ("cancelled".equals(cssClass)) {
            return "X";
        }
        return "#";
    }

    private String productStatusClass(String status) {
        return status != null && "ACTIVE".equalsIgnoreCase(status.trim()) ? "active" : "inactive";
    }

    private String formatCurrency(BigDecimal value) {
        DecimalFormat formatter = new DecimalFormat("#,###");
        BigDecimal safeValue = value == null ? BigDecimal.ZERO : value;
        return formatter.format(safeValue) + "đ";
    }

    private String formatDateTime(java.util.Date value) {
        if (value == null) {
            return "";
        }

        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(value);
    }

    private String buildShipmentLink(String ctx, Integer statusId, boolean todayOnly, int page) {
        StringBuilder query = new StringBuilder();
        if (statusId != null) {
            appendParam(query, "statusId", String.valueOf(statusId));
        }
        if (todayOnly) {
            appendParam(query, "today", "1");
        }
        if (page > 1) {
            appendParam(query, "page", String.valueOf(page));
        }
        return ctx + "/Dashboard" + (query.length() == 0 ? "" : "?" + query);
    }

    private void appendParam(StringBuilder query, String name, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        if (query.length() > 0) {
            query.append("&");
        }

        query.append(name)
                .append("=")
                .append(URLEncoder.encode(value.trim(), StandardCharsets.UTF_8));
    }
%>

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

                <% if ("ADMIN".equals(roleName)) { %>

                <%
                    LocalDate adminSelectedDate = (LocalDate) request.getAttribute("adminSelectedDate");
                    DashboardSummary adminSummary = (DashboardSummary) request.getAttribute("adminSummary");
                    List<DashboardProduct> adminBestSellingProducts = (List<DashboardProduct>) request.getAttribute("adminBestSellingProducts");
                    List<DashboardProduct> adminLowStockProducts = (List<DashboardProduct>) request.getAttribute("adminLowStockProducts");
                    List<OrderHistoryItem> adminLatestOrders = (List<OrderHistoryItem>) request.getAttribute("adminLatestOrders");
                    Map<String, Integer> adminWarrantyStatusCounts = (Map<String, Integer>) request.getAttribute("adminWarrantyStatusCounts");
                    AccountSummary adminAccountSummary = (AccountSummary) request.getAttribute("adminAccountSummary");

                    if (adminSelectedDate == null) {
                        adminSelectedDate = LocalDate.now();
                    }
                    if (adminSummary == null) {
                        adminSummary = new DashboardSummary();
                    }
                    if (adminAccountSummary == null) {
                        adminAccountSummary = new AccountSummary();
                    }
                %>

                <div class="admin-dashboard">
                    <div class="admin-dashboard-heading">
                        <form class="admin-date-filter" action="<%= ctx %>/Dashboard" method="get">
                            <input type="date" name="date" value="<%= adminSelectedDate %>">
                            <button type="submit">Xem</button>
                        </form>
                    </div>

                    <div class="admin-stat-grid" aria-label="Tổng quan chức năng quản trị">
                        <a class="admin-stat-card" >
                            <span class="admin-stat-icon red">📦</span>
                            <span>
                                <small>Tổng doanh thu</small>
                                <strong><%= formatCurrency(adminSummary.getTotalRevenue()) %></strong>
                                
                            </span>
                        </a>

                        <a class="admin-stat-card">
                            <span class="admin-stat-icon dark">👥</span>
                            <span>
                                <small>Tổng đơn hàng</small>
                                <strong><%= adminSummary.getTotalOrders() %></strong>
                               
                            </span>
                        </a>

                        <a class="admin-stat-card">
                            <span class="admin-stat-icon blue">▦</span>
                            <span>
                                <small>Tổng sản phẩm</small>
                                <strong><%= adminSummary.getActiveProducts() %></strong>
                                
                            </span>
                        </a>

                        <a class="admin-stat-card">
                            <span class="admin-stat-icon green">◆</span>
                            <span>
                                <small>Tất cả thương hiệu</small>
                                <strong><%= adminSummary.getTotalBrands() %></strong>
                              
                            </span>
                        </a>

                        <div class="admin-stat-card">
                            <span class="admin-stat-icon orange">!</span>
                            <span>
                                <small>Yêu cầu bảo hành</small>
                                <strong><%= adminSummary.getWarrantyRequests() %></strong>
                               
                            </span>
                        </div>

                        <a class="admin-stat-card">
                            <span class="admin-stat-icon purple">▣</span>
                            <span>
                                <small>Lô hàng đã nhập</small>
                                <strong><%= adminSummary.getImportedBatches() %></strong>
                               
                            </span>
                        </a>
                    </div>

                    <div class="admin-dashboard-grid admin-products-grid">
                        <section class="admin-panel admin-module-panel">
                            <div class="admin-panel-header">
                                <h2>Sản phẩm bán chạy nhất</h2>
                            </div>

                            <table class="admin-dashboard-table">
                                <thead>
                                    <tr>
                                        <th>Mã SP</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Đã bán</th>
                                        <th>Tồn kho</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (adminBestSellingProducts == null || adminBestSellingProducts.isEmpty()) { %>
                                    <tr><td colspan="4" class="admin-empty-cell">Không có dữ liệu bán hàng trong ngày này.</td></tr>
                                    <% } else {
                                        for (DashboardProduct product : adminBestSellingProducts) { %>
                                    <tr>
                                        <td>SP<%= product.getProductId() %></td>
                                        <td><%= h(product.getProductName()) %></td>
                                        <td><%= product.getSoldQuantity() %></td>
                                        <td><%= product.getStockQuantity() %></td>
                                    </tr>
                                    <% }
                                    } %>
                                </tbody>
                            </table>
                        </section>

                        <aside class="admin-panel admin-quick-panel">
                            <div class="admin-panel-header">
                                <h2>Sản phẩm sắp hết hàng</h2>
                            </div>

                            <table class="admin-dashboard-table compact">
                                <thead>
                                    <tr>
                                        <th>Sản phẩm</th>
                                        <th>SL</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (adminLowStockProducts == null || adminLowStockProducts.isEmpty()) { %>
                                    <tr><td colspan="3" class="admin-empty-cell">Chưa có sản phẩm.</td></tr>
                                    <% } else {
                                        for (DashboardProduct product : adminLowStockProducts) { %>
                                    <tr>
                                        <td><%= h(product.getProductName()) %></td>
                                        <td><%= product.getStockQuantity() %></td>
                                        <td><span class="admin-status <%= productStatusClass(product.getStatus()) %>"><%= h(product.getStatus()) %></span></td>
                                    </tr>
                                    <% }
                                    } %>
                                </tbody>
                            </table>
                        </aside>
                    </div>

                    <div class="admin-dashboard-grid admin-bottom-grid">
                        <section class="admin-panel">
                            <div class="admin-panel-header">
                                <h2>Đơn hàng mới nhất</h2>
                            </div>

                            <table class="admin-dashboard-table">
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
                                    <% if (adminLatestOrders == null || adminLatestOrders.isEmpty()) { %>
                                    <tr><td colspan="5" class="admin-empty-cell">Không có đơn hàng trong ngày này.</td></tr>
                                    <% } else {
                                        for (OrderHistoryItem order : adminLatestOrders) {
                                            String displayStatus = defaultText(order.getDisplayStatus(), "Chưa cập nhật");
                                    %>
                                    <tr>
                                        <td>PB<%= order.getOrderId() %></td>
                                        <td><%= h(order.getCustomerName()) %></td>
                                        <td><%= formatCurrency(order.getTotalAmount()) %></td>
                                        <td><span class="shipment-status <%= statusClass(displayStatus) %>"><%= h(displayStatus) %></span></td>
                                        <td><%= h(formatDateTime(order.getOrderDate())) %></td>
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
                                <% if (adminWarrantyStatusCounts == null || adminWarrantyStatusCounts.isEmpty()) { %>
                                <p class="admin-empty-message">Không có yêu cầu bảo hành trong ngày này.</p>
                                <% } else {
                                    for (Map.Entry<String, Integer> entry : adminWarrantyStatusCounts.entrySet()) { %>
                                <p>
                                    <span><%= h(entry.getKey()) %></span>
                                    <strong><%= entry.getValue() %></strong>
                                </p>
                                <% }
                                } %>
                            </div>
                        </aside>
                        <section class="admin-panel">
                            <div class="admin-panel-header">
                                <h2>Tổng quan tài khoản</h2>
                            </div>

                            <div class="admin-account-grid">
                                <div><span>Khách hàng</span><strong><%= adminAccountSummary.getCustomers() %></strong></div>
                                <div><span>Nhân viên</span><strong><%= adminAccountSummary.getEmployees() %></strong></div>
                                <div><span>Nhân viên giao hàng</span><strong><%= adminAccountSummary.getTransports() %></strong></div>
                                <div><span>Bị khóa</span><strong><%= adminAccountSummary.getLocked() %></strong></div>
                                <div><span>Đang hoạt động</span><strong><%= adminAccountSummary.getActive() %></strong></div>
                            </div>
                        </section>
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
                            <span class="shipment-summary-icon <%= statusClass(status.getStatusName()) %>"><%= statusIcon(status.getStatusName()) %></span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title"><%= h(status.getStatusName()) %></p>
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
                                   href="<%= buildShipmentLink(ctx, null, false, 1) %>">Tất cả</a>
                                <a class="shipment-filter-tab <%= shipmentTodayOnly ? "active" : "" %>"
                                   href="<%= buildShipmentLink(ctx, shipmentSelectedStatusId, true, 1) %>">Hôm nay</a>
                                <% if (shipmentStatusOptions != null) {
                                    for (OrderStatus status : shipmentStatusOptions) { %>
                                <a class="shipment-filter-tab <%= !shipmentTodayOnly && shipmentSelectedStatusId != null && shipmentSelectedStatusId == status.getStatusId() ? "active" : "" %>"
                                   href="<%= buildShipmentLink(ctx, status.getStatusId(), false, 1) %>"><%= h(status.getStatusName()) %></a>
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
                                        String displayStatus = defaultText(order.getDisplayStatus(), "Chờ xác nhận");
                                %>
                                <tr>
                                    <td>
                                        PB<%= order.getOrderId() %>
                                    </td>
                                    <td>
                                        <%= h(defaultText(order.getRecipientName(), order.getCustomerName())) %>
                                    </td>
                                    <td><%= h(defaultText(order.getShippingAddress(), "Chưa cập nhật địa chỉ")) %></td>
                                    <td>
                                        <span class="shipment-status <%= statusClass(displayStatus) %>"><%= h(displayStatus) %></span>
                                    </td>
                                </tr>
                                <% }
                                } %>
                            </tbody>
                        </table>

                        <% if (shipmentTotalPages > 1) { %>
                        <div class="shipment-pagination">
                            <a class="<%= shipmentPage <= 1 ? "disabled" : "" %>"
                               href="<%= shipmentPage <= 1 ? "#" : buildShipmentLink(ctx, shipmentSelectedStatusId, shipmentTodayOnly, shipmentPage - 1) %>">‹</a>
                            <% for (int pageNumber = 1; pageNumber <= shipmentTotalPages; pageNumber++) { %>
                            <a class="<%= pageNumber == shipmentPage ? "active" : "" %>"
                               href="<%= buildShipmentLink(ctx, shipmentSelectedStatusId, shipmentTodayOnly, pageNumber) %>"><%= pageNumber %></a>
                            <% } %>
                            <a class="<%= shipmentPage >= shipmentTotalPages ? "disabled" : "" %>"
                               href="<%= shipmentPage >= shipmentTotalPages ? "#" : buildShipmentLink(ctx, shipmentSelectedStatusId, shipmentTodayOnly, shipmentPage + 1) %>">›</a>
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
