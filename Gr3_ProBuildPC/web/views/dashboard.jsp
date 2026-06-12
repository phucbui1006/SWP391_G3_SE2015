<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.OrderHistoryItem" %>
<%@ page import="model.OrderStatus" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
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

    private String buildShipmentLink(String ctx, Integer statusId, int page) {
        StringBuilder query = new StringBuilder();
        if (statusId != null) {
            appendParam(query, "statusId", String.valueOf(statusId));
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

                <%
                    List<OrderHistoryItem> shipmentOrders = (List<OrderHistoryItem>) request.getAttribute("shipmentOrders");
                    List<OrderStatus> shipmentStatusOptions = (List<OrderStatus>) request.getAttribute("shipmentStatusOptions");
                    Map<Integer, Integer> shipmentStatusCounts = (Map<Integer, Integer>) request.getAttribute("shipmentStatusCounts");
                    Integer shipmentSelectedStatusId = (Integer) request.getAttribute("shipmentSelectedStatusId");
                    Integer shipmentPageObject = (Integer) request.getAttribute("shipmentPage");
                    Integer shipmentTotalPagesObject = (Integer) request.getAttribute("shipmentTotalPages");
                    Integer shipmentTotalOrdersObject = (Integer) request.getAttribute("shipmentTotalOrders");
                    Integer shipmentAllActiveCountObject = (Integer) request.getAttribute("shipmentAllActiveCount");
                    int shipmentPage = shipmentPageObject == null ? 1 : shipmentPageObject;
                    int shipmentTotalPages = shipmentTotalPagesObject == null ? 1 : shipmentTotalPagesObject;
                    int shipmentTotalOrders = shipmentTotalOrdersObject == null ? 0 : shipmentTotalOrdersObject;
                    int shipmentAllActiveCount = shipmentAllActiveCountObject == null ? 0 : shipmentAllActiveCountObject;
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
                                <a class="shipment-filter-tab <%= shipmentSelectedStatusId == null ? "active" : "" %>"
                                   href="<%= buildShipmentLink(ctx, null, 1) %>">Tất cả</a>
                                <% if (shipmentStatusOptions != null) {
                                    for (OrderStatus status : shipmentStatusOptions) { %>
                                <a class="shipment-filter-tab <%= shipmentSelectedStatusId != null && shipmentSelectedStatusId == status.getStatusId() ? "active" : "" %>"
                                   href="<%= buildShipmentLink(ctx, status.getStatusId(), 1) %>"><%= h(status.getStatusName()) %></a>
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
                               href="<%= shipmentPage <= 1 ? "#" : buildShipmentLink(ctx, shipmentSelectedStatusId, shipmentPage - 1) %>">‹</a>
                            <% for (int pageNumber = 1; pageNumber <= shipmentTotalPages; pageNumber++) { %>
                            <a class="<%= pageNumber == shipmentPage ? "active" : "" %>"
                               href="<%= buildShipmentLink(ctx, shipmentSelectedStatusId, pageNumber) %>"><%= pageNumber %></a>
                            <% } %>
                            <a class="<%= shipmentPage >= shipmentTotalPages ? "disabled" : "" %>"
                               href="<%= shipmentPage >= shipmentTotalPages ? "#" : buildShipmentLink(ctx, shipmentSelectedStatusId, shipmentPage + 1) %>">›</a>
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
