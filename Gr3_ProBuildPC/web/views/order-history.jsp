<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.OrderHistoryDetail" %>
<%@ page import="model.OrderHistoryItem" %>
<%@ page import="model.OrderStatus" %>
<%!
    private String h(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String defaultText(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    private String formatMoney(BigDecimal value, NumberFormat formatter) {
        BigDecimal safeValue = value == null ? BigDecimal.ZERO : value;
        return formatter.format(safeValue) + "đ";
    }

    private String formatDate(Date value, SimpleDateFormat formatter) {
        return value == null ? "--/--/----" : formatter.format(value);
    }

    private String formatTime(Date value, SimpleDateFormat formatter) {
        return value == null ? "--:--" : formatter.format(value);
    }

    private String statusClass(String status) {
        String value = status == null ? "" : status.toLowerCase(Locale.ROOT);

        if (value.contains("hủy") || value.contains("huy")) {
            return "cancelled";
        }

        if (value.contains("hoàn") || value.contains("giao hàng") && value.contains("đã")) {
            return "completed";
        }

        if (value.contains("đang giao") || value.contains("dang giao")) {
            return "shipping";
        }

        if (value.contains("chuẩn") || value.contains("chuan")) {
            return "preparing";
        }

        if (value.contains("chờ") || value.contains("cho ")) {
            return "waiting";
        }

        if (value.contains("xác nhận") || value.contains("xac nhan")) {
            return "confirmed";
        }

        return "waiting";
    }

    private String appendParam(String query, String name, String value) {
        if (value == null || value.trim().isEmpty()) {
            return query;
        }

        StringBuilder builder = new StringBuilder(query == null ? "" : query);
        if (builder.length() > 0) {
            builder.append("&");
        }

        builder.append(name)
                .append("=")
                .append(URLEncoder.encode(value.trim(), StandardCharsets.UTF_8));
        return builder.toString();
    }

    private String buildOrderLink(String ctx, String keyword, String statusId, int page, int selectedOrderId, boolean deliveryHistoryMode) {
        String query = "";
        query = appendParam(query, "keyword", keyword);
        query = appendParam(query, "statusId", statusId);
        query = appendParam(query, "page", String.valueOf(page));
        query = appendParam(query, "selectedOrderId", String.valueOf(selectedOrderId));
        if (deliveryHistoryMode) {
            query = appendParam(query, "deliveryHistory", "1");
        }
        return ctx + "/order-history" + (query.isEmpty() ? "" : "?" + query);
    }

    private String buildPageLink(String ctx, String keyword, String statusId, int page, Integer selectedOrderId, boolean deliveryHistoryMode) {
        String query = "";
        query = appendParam(query, "keyword", keyword);
        query = appendParam(query, "statusId", statusId);
        query = appendParam(query, "page", String.valueOf(page));
        if (selectedOrderId != null) {
            query = appendParam(query, "selectedOrderId", String.valueOf(selectedOrderId));
        }
        if (deliveryHistoryMode) {
            query = appendParam(query, "deliveryHistory", "1");
        }
        return ctx + "/order-history" + (query.isEmpty() ? "" : "?" + query);
    }

    private String assetUrl(String ctx, String path) {
        if (path == null || path.trim().isEmpty()) {
            return "";
        }

        String value = path.trim();
        if (value.startsWith("http://") || value.startsWith("https://") || value.startsWith("/")) {
            return value;
        }

        return ctx + "/" + value;
    }

    private boolean canCancelOrder(OrderHistoryItem order) {
        if (order == null) {
            return false;
        }

        if (order.getStatusId() == 1) {
            return true;
        }

        String status = defaultText(order.getDisplayStatus(), "").toLowerCase(Locale.ROOT);
        return (status.contains("chờ") || status.contains("cho "))
                && (status.contains("xác nhận") || status.contains("xac nhan"));
    }

    private boolean isLockedShipmentOrder(OrderHistoryItem order) {
        if (order == null) {
            return false;
        }

        String status = defaultText(order.getDisplayStatus(), "").toLowerCase(Locale.ROOT);
        return isLockedShipmentStatus(status);
    }

    private boolean isLockedShipmentStatus(String status) {
        if (status == null) {
            return false;
        }

        status = status.toLowerCase(Locale.ROOT);
        return status.contains("hủy")
                || status.contains("huy")
                || status.contains("đã giao")
                || status.contains("da giao");
    }

    private boolean isDeliveredShipmentStatus(String status) {
        if (status == null) {
            return false;
        }

        status = status.toLowerCase(Locale.ROOT);
        return status.contains("đã giao")
                || status.contains("da giao");
    }
%>
<%
    List<OrderHistoryItem> orders = (List<OrderHistoryItem>) request.getAttribute("orders");
    List<OrderStatus> statusOptions = (List<OrderStatus>) request.getAttribute("statusOptions");
    OrderHistoryItem selectedOrder = (OrderHistoryItem) request.getAttribute("selectedOrder");
    String keyword = (String) request.getAttribute("keyword");
    Integer selectedStatusId = (Integer) request.getAttribute("selectedStatusId");
    Integer pageValue = (Integer) request.getAttribute("page");
    Integer totalPagesValue = (Integer) request.getAttribute("totalPages");
    Integer totalOrdersValue = (Integer) request.getAttribute("totalOrders");
    Boolean canManageShipmentValue = (Boolean) request.getAttribute("canManageShipment");
    Boolean isCustomerViewValue = (Boolean) request.getAttribute("isCustomerView");
    String shipmentStaffName = (String) request.getAttribute("shipmentStaffName");
    Boolean deliveryHistoryModeValue = (Boolean) request.getAttribute("deliveryHistoryMode");

    if (orders == null) {
        orders = Collections.emptyList();
    }
    if (statusOptions == null) {
        statusOptions = Collections.emptyList();
    }

    int currentPage = pageValue == null ? 1 : pageValue;
    int totalPages = totalPagesValue == null ? 1 : totalPagesValue;
    int totalOrders = totalOrdersValue == null ? 0 : totalOrdersValue;
    boolean canManageShipment = canManageShipmentValue != null && canManageShipmentValue;
    boolean isCustomerView = isCustomerViewValue == null || isCustomerViewValue;
    boolean deliveryHistoryMode = deliveryHistoryModeValue != null && deliveryHistoryModeValue;
    Integer selectedOrderId = selectedOrder == null ? null : selectedOrder.getOrderId();
    List<OrderHistoryDetail> selectedDetails = selectedOrder == null
            ? Collections.emptyList()
            : selectedOrder.getDetails();
    boolean selectedCanCancel = isCustomerView && canCancelOrder(selectedOrder);
    boolean selectedCanUpdateShipment = canManageShipment && !isLockedShipmentOrder(selectedOrder);
    String selectedStatusIdValue = selectedStatusId == null ? null : String.valueOf(selectedStatusId);

    Locale vietnameseLocale = new Locale("vi", "VN");
    NumberFormat currencyFormatter = NumberFormat.getNumberInstance(vietnameseLocale);
    currencyFormatter.setMinimumFractionDigits(0);
    currencyFormatter.setMaximumFractionDigits(0);
    SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= isCustomerView ? "Lịch sử đơn hàng" : (deliveryHistoryMode ? "Lịch sử giao hàng" : "Quản lý giao hàng") %></title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body class="order-history-body">
        <jsp:include page="/includes/header.jsp" />

        <main class="order-history-page">
            <nav class="order-history-breadcrumb" aria-label="Breadcrumb">
                <a href="<%= isCustomerView ? ctx + "/home" : ctx + "/Dashboard" %>">Trang chủ</a>
                <span>/</span>
                <span><%= isCustomerView ? "Lịch sử đơn hàng" : (deliveryHistoryMode ? "Lịch sử giao hàng" : "Quản lý giao hàng") %></span>
            </nav>

            <section class="order-history-heading">
                <div>
                    <h1><%= isCustomerView ? "Lịch sử đơn hàng" : (deliveryHistoryMode ? "Lịch sử giao hàng" : "Quản lý giao hàng") %></h1>
                    <p><%= isCustomerView ? "Theo dõi và quản lý các đơn hàng của bạn" : (deliveryHistoryMode ? "Các đơn hàng đã hoàn thành giao hàng" : "Theo dõi đơn hàng và trạng thái vận chuyển") %></p>
                </div>
                <form class="order-history-filter" action="<%= ctx %>/order-history" method="get">
                    <% if (deliveryHistoryMode) { %>
                    <input type="hidden" name="deliveryHistory" value="1">
                    <% } %>
                    <input type="search" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm mã đơn hàng">
                    <% if (!deliveryHistoryMode) { %>
                    <select name="statusId">
                        <option value="">Tất cả trạng thái</option>
                        <% for (OrderStatus status : statusOptions) { %>
                        <% if (canManageShipment && isDeliveredShipmentStatus(status.getStatusName())) {
                                continue;
                            } %>
                        <option value="<%= status.getStatusId() %>" <%= selectedStatusId != null && selectedStatusId == status.getStatusId() ? "selected" : "" %>>
                            <%= h(status.getStatusName()) %>
                        </option>
                        <% } %>
                    </select>
                    <% } %>
                    <button type="submit">Tìm</button>
                </form>
            </section>

            <% if (request.getAttribute("success") != null) { %>
            <div class="order-history-alert success"><%= h(String.valueOf(request.getAttribute("success"))) %></div>
            <% } %>
            <% if (request.getAttribute("error") != null) { %>
            <div class="order-history-alert error"><%= h(String.valueOf(request.getAttribute("error"))) %></div>
            <% } %>

            <section class="order-history-layout">
                <aside class="order-list-panel">
                    <div class="order-panel-title">
                        <h2><%= isCustomerView ? "Danh sách đơn hàng" : (deliveryHistoryMode ? "Đơn đã hoàn thành" : "Đơn cần hoàn thành") %></h2>
                        <span><%= totalOrders %> đơn</span>
                    </div>

                    <div class="order-card-list">
                        <% if (orders.isEmpty()) { %>
                        <div class="order-history-empty">
                            <strong>Chưa có đơn hàng phù hợp</strong>
                            <span>Thử đổi bộ lọc hoặc từ khóa tìm kiếm.</span>
                        </div>
                        <% } %>

                        <% for (OrderHistoryItem order : orders) { %>
                        <%
                            String displayStatus = defaultText(order.getDisplayStatus(), "Chờ xác nhận");
                            boolean active = selectedOrderId != null && selectedOrderId == order.getOrderId();
                        %>
                        <a class="order-list-card <%= active ? "active" : "" %>"
                           href="<%= buildOrderLink(ctx, keyword, selectedStatusIdValue, currentPage, order.getOrderId(), deliveryHistoryMode) %>">
                            <span class="order-card-icon" aria-hidden="true">🛒</span>
                            <span class="order-card-main">
                                <strong>PB<%= order.getOrderId() %></strong>
                                <small><%= formatDate(order.getOrderDate(), dateFormatter) %> · <%= formatTime(order.getOrderDate(), timeFormatter) %></small>
                                <% if (!isCustomerView) { %>
                                <em><%= h(defaultText(order.getCustomerName(), "Khách hàng")) %></em>
                                <% } %>
                            </span>
                            <span class="order-status-pill <%= statusClass(displayStatus) %>"><%= h(displayStatus) %></span>
                            <strong class="order-card-price"><%= formatMoney(order.getTotalAmount(), currencyFormatter) %></strong>
                            <span class="order-card-arrow" aria-hidden="true">›</span>
                        </a>
                        <% } %>
                    </div>

                    <% if (totalPages > 1) { %>
                    <div class="order-history-pagination">
                        <a class="<%= currentPage <= 1 ? "disabled" : "" %>"
                           href="<%= currentPage <= 1 ? "#" : buildPageLink(ctx, keyword, selectedStatusIdValue, currentPage - 1, selectedOrderId, deliveryHistoryMode) %>"
                           aria-label="Trang trước">‹</a>
                        <% for (int pageNumber = 1; pageNumber <= totalPages; pageNumber++) { %>
                        <a class="<%= pageNumber == currentPage ? "active" : "" %>"
                           href="<%= buildPageLink(ctx, keyword, selectedStatusIdValue, pageNumber, selectedOrderId, deliveryHistoryMode) %>"><%= pageNumber %></a>
                        <% } %>
                        <a class="<%= currentPage >= totalPages ? "disabled" : "" %>"
                           href="<%= currentPage >= totalPages ? "#" : buildPageLink(ctx, keyword, selectedStatusIdValue, currentPage + 1, selectedOrderId, deliveryHistoryMode) %>"
                           aria-label="Trang sau">›</a>
                    </div>
                    <% } %>
                </aside>

                <section class="order-detail-panel">
                    <% if (selectedOrder == null) { %>
                    <div class="order-history-empty detail-empty">
                        <strong>Chọn một đơn hàng</strong>
                        <span>Chi tiết đơn hàng sẽ hiển thị tại đây.</span>
                    </div>
                    <% } else { %>
                    <div class="order-detail-header">
                        <h2>Đơn hàng PB<%= selectedOrder.getOrderId() %></h2>
                        <div class="order-detail-actions">
                            <% if (selectedCanCancel) { %>
                            <form class="order-cancel-form" action="<%= ctx %>/order-history" method="post" onsubmit="return confirm('Bạn chắc chắn muốn hủy đơn hàng này?');">
                                <input type="hidden" name="action" value="cancelOrder">
                                <input type="hidden" name="orderId" value="<%= selectedOrder.getOrderId() %>">
                                <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                <input type="hidden" name="filterStatusId" value="<%= h(selectedStatusIdValue) %>">
                                <input type="hidden" name="page" value="<%= currentPage %>">
                                <button type="submit" class="order-cancel-btn">Hủy đơn</button>
                            </form>
                            <% } %>
                        </div>
                    </div>

                    <article class="order-summary-card">
                        <div class="order-summary-icon" aria-hidden="true">🛒</div>
                        <div>
                            <strong>Mã đơn hàng: PB<%= selectedOrder.getOrderId() %></strong>
                            <span>Đặt hàng: <%= formatDate(selectedOrder.getOrderDate(), dateFormatter) %> · <%= formatTime(selectedOrder.getOrderDate(), timeFormatter) %></span>
                            <span>Hình thức thanh toán: <%= h(defaultText(selectedOrder.getPaymentMethod(), "Chưa cập nhật")) %></span>
                        </div>
                        <span class="order-status-pill <%= statusClass(selectedOrder.getDisplayStatus()) %>" style="
                              margin-right: 300px;
                              ">
                            <%= h(defaultText(selectedOrder.getDisplayStatus(), "Chờ xác nhận")) %>
                        </span>
                    </article>

                    <div class="order-info-grid">
                        <section class="order-info-box">
                            <div class="order-box-title">
                                <h3>Thông tin nhận hàng</h3>
                                <button type="button" data-open-modal="detailQuickView">Xem chi tiết</button>
                            </div>
                            <p><span>Người nhận</span><strong><%= h(defaultText(selectedOrder.getRecipientName(), selectedOrder.getCustomerName())) %></strong></p>
                            <p><span>Số điện thoại</span><strong><%= h(defaultText(selectedOrder.getRecipientPhone(), "Chưa cập nhật")) %></strong></p>
                            <p><span>Địa chỉ</span><strong><%= h(defaultText(selectedOrder.getShippingAddress(), "Chưa cập nhật")) %></strong></p>
                        </section>

                        <section class="order-info-box">
                            <div class="order-box-title">
                                <h3>Vận chuyển</h3>
                            </div>
                            <p><span>Mã đơn hàng</span><strong><%= h(selectedOrder.getDisplayTrackingCode()) %></strong></p>
                            <p><span>Trạng thái</span><strong><%= h(defaultText(selectedOrder.getDisplayStatus(), "Chờ xác nhận")) %></strong></p>
                            <p><span>Ghi chú</span><strong><%= h(defaultText(selectedOrder.getShipmentNote(), "Chưa có ghi chú")) %></strong></p>
                        </section>
                    </div>

                    <% if (selectedCanUpdateShipment) { %>
                    <form class="shipment-update-form status-only" action="<%= ctx %>/order-history" method="post">
                        <input type="hidden" name="action" value="updateShipmentStatus">
                        <input type="hidden" name="orderId" value="<%= selectedOrder.getOrderId() %>">
                        <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                        <input type="hidden" name="filterStatusId" value="<%= h(selectedStatusIdValue) %>">
                        <input type="hidden" name="page" value="<%= currentPage %>">

                        <label>
                            <span>Trạng thái giao hàng</span>
                            <select name="shipmentStatusId" required>
                                <% for (OrderStatus status : statusOptions) { %>
                                <option value="<%= status.getStatusId() %>" <%= selectedOrder.getStatusId() == status.getStatusId() ? "selected" : "" %>>
                                    <%= h(status.getStatusName()) %>
                                </option>
                                <% } %>
                            </select>
                        </label>
                        <label>
                            <span>Tên người giao hàng</span>
                            <input type="text" name="deliveryName" value="<%= h(defaultText(shipmentStaffName, "")) %>" required>
                        </label>
                        <label>
                            <span>Số điện thoại người giao hàng</span>
                            <input type="tel" name="deliveryPhone" value="" required>
                        </label>
                        <button type="submit">Cập nhật</button>
                    </form>
                    <% } %>

                    <div class="order-products-box">
                        <h3>Danh sách sản phẩm</h3>
                        <div class="order-product-list">
                            <% for (OrderHistoryDetail detail : selectedDetails) { %>
                            <a class="order-product-row" href="<%= ctx %>/product-detail?id=<%= detail.getProductId() %>">
                                <% if (detail.getImageUrl() != null && !detail.getImageUrl().trim().isEmpty()) { %>
                                <img src="<%= h(assetUrl(ctx, detail.getImageUrl())) %>" alt="<%= h(defaultText(detail.getProductName(), "Sản phẩm")) %>">
                                <% } else { %>
                                <span class="order-product-placeholder">PC</span>
                                <% } %>
                                <div>
                                    <strong><%= h(defaultText(detail.getProductName(), "Sản phẩm")) %></strong>
                                    <span><%= h(defaultText(detail.getCategoryName(), "Danh mục")) %> · <%= h(defaultText(detail.getBrandName(), "Thương hiệu")) %></span>
                                </div>
                                <span>x<%= detail.getQuantity() %></span>
                                <strong><%= formatMoney(detail.getSubtotal(), currencyFormatter) %></strong>
                            </a>
                            <% } %>
                        </div>
                        <div class="order-total-row">
                            <span>Tổng cộng</span>
                            <strong><%= formatMoney(selectedOrder.getTotalAmount(), currencyFormatter) %></strong>
                        </div>
                    </div>
                    <% } %>
                </section>
            </section>
        </main>

        <% if (selectedOrder != null) { %>
        <div class="order-modal-backdrop" data-modal="detailQuickView" hidden>
            <div class="order-modal" role="dialog" aria-modal="true" aria-labelledby="detailQuickViewTitle">
                <div class="order-modal-header">
                    <div>
                        <h2 id="detailQuickViewTitle">Chi tiết đơn hàng PB<%= selectedOrder.getOrderId() %></h2>
                        <p><%= h(defaultText(selectedOrder.getCustomerName(), "Khách hàng")) %> · <%= h(defaultText(selectedOrder.getCustomerEmail(), "Chưa cập nhật email")) %></p>
                    </div>
                    <button type="button" data-close-modal aria-label="Đóng">×</button>
                </div>
                <div class="order-modal-content">
                    <div class="quickview-summary-grid">
                        <p><span>Ngày đặt</span><strong><%= formatDate(selectedOrder.getOrderDate(), dateFormatter) %> <%= formatTime(selectedOrder.getOrderDate(), timeFormatter) %></strong></p>
                        <p><span>Thanh toán</span><strong><%= h(defaultText(selectedOrder.getPaymentMethod(), "Chưa cập nhật")) %> · <%= h(defaultText(selectedOrder.getPaymentStatus(), "Chưa cập nhật")) %></strong></p>
                        <p><span>Vận chuyển</span><strong><%= h(selectedOrder.getDisplayTrackingCode()) %> · <%= h(defaultText(selectedOrder.getDisplayStatus(), "Chờ xác nhận")) %></strong></p>
                        <p><span>Ghi chú</span><strong><%= h(defaultText(selectedOrder.getNote(), "Không có")) %></strong></p>
                    </div>

                    <section class="quickview-address-box">
                        <h3>Thông tin nhận hàng</h3>
                        <p><%= h(defaultText(selectedOrder.getRecipientName(), selectedOrder.getCustomerName())) %></p>
                        <p><%= h(defaultText(selectedOrder.getRecipientPhone(), "Chưa cập nhật")) %></p>
                        <p><%= h(defaultText(selectedOrder.getShippingAddress(), "Chưa cập nhật")) %></p>
                    </section>

                    <section>
                        <h3>Sản phẩm trong đơn</h3>
                        <div class="quickview-product-table">
                            <% for (OrderHistoryDetail detail : selectedDetails) { %>
                            <div class="quickview-product-line">
                                <span><%= h(defaultText(detail.getProductName(), "Sản phẩm")) %></span>
                                <span><%= h(defaultText(detail.getBrandName(), "Thương hiệu")) %></span>
                                <span>x<%= detail.getQuantity() %></span>
                                <strong><%= formatMoney(detail.getSubtotal(), currencyFormatter) %></strong>
                            </div>
                            <% } %>
                        </div>
                    </section>
                </div>
            </div>
        </div>
        <% } %>

        <script>
            (function () {
                const openButtons = document.querySelectorAll("[data-open-modal]");
                const closeButtons = document.querySelectorAll("[data-close-modal]");

                function openModal(id) {
                    const modal = document.querySelector('[data-modal="' + id + '"]');
                    if (!modal) {
                        return;
                    }
                    modal.hidden = false;
                    document.body.classList.add("order-modal-open");
                }

                function closeModal(modal) {
                    if (!modal) {
                        return;
                    }
                    modal.hidden = true;
                    document.body.classList.remove("order-modal-open");
                }

                openButtons.forEach(function (button) {
                    button.addEventListener("click", function () {
                        openModal(button.getAttribute("data-open-modal"));
                    });
                });

                closeButtons.forEach(function (button) {
                    button.addEventListener("click", function () {
                        closeModal(button.closest("[data-modal]"));
                    });
                });

                document.querySelectorAll(".order-modal-backdrop").forEach(function (backdrop) {
                    backdrop.addEventListener("click", function (event) {
                        if (event.target === backdrop) {
                            closeModal(backdrop);
                        }
                    });
                });

                document.addEventListener("keydown", function (event) {
                    if (event.key === "Escape") {
                        document.querySelectorAll(".order-modal-backdrop:not([hidden])").forEach(closeModal);
                    }
                });
            })();
        </script>
    </body>
</html>
