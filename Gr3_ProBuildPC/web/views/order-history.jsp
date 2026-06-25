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

        if (order.getStatusId() == 1 || order.getStatusId() == 2) {
            return true;
        }

        String status = defaultText(order.getDisplayStatus(), "").toLowerCase(Locale.ROOT);
        return (status.contains("chờ") || status.contains("cho "))
                && (status.contains("xác nhận") || status.contains("xac nhan"))
                || (status.contains("đã") || status.contains("da ")) 
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
                || status.contains("da giao")
                || status.contains("thất bại")
                || status.contains("that bai");
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
    Boolean isShipperValue = (Boolean) request.getAttribute("isShipper");
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
    boolean isCustomerView = isCustomerViewValue != null && isCustomerViewValue;
    boolean isShipper = isShipperValue != null && isShipperValue;
    boolean deliveryHistoryMode = deliveryHistoryModeValue != null && deliveryHistoryModeValue;
    Integer selectedOrderId = selectedOrder == null ? null : selectedOrder.getOrderId();
    List<OrderHistoryDetail> selectedDetails = selectedOrder == null
            ? Collections.emptyList()
            : selectedOrder.getDetails();
    boolean selectedCanCancel = isCustomerView && canCancelOrder(selectedOrder);
    boolean selectedCanRetryVnpay = isCustomerView && selectedOrder != null
            && "VNPAY".equalsIgnoreCase(selectedOrder.getPaymentMethod())
            && "Chờ thanh toán".equals(selectedOrder.getPaymentStatus())
            && selectedOrder.getStatusId() == 1;

    boolean isEmployee = request.getAttribute("isEmployee") != null && (Boolean) request.getAttribute("isEmployee");
    boolean selectedCanUpdateShipment = false;
    if (canManageShipment && selectedOrder != null) {
        if (isShipper) {
            selectedCanUpdateShipment = !isLockedShipmentOrder(selectedOrder);
        } else if (isEmployee) {
            selectedCanUpdateShipment = (selectedOrder.getStatusId() == 7);
        } else {
            selectedCanUpdateShipment = true;
        }
    }
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
        <title><%= isCustomerView ? "Lịch sử đơn hàng" : (deliveryHistoryMode ? "Lịch sử giao hàng" : "Quản lý d hàng") %></title>
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
                            <span class="order-card-icon" aria-hidden="true"><i class="fa-solid fa-cart-shopping"></i></span>
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
                            <% if (selectedCanRetryVnpay) { %>
                            <form class="order-vnpay-retry-form" action="<%= ctx %>/vnpay-retry" method="post">
                                <input type="hidden" name="orderId" value="<%= selectedOrder.getOrderId() %>">
                                <button type="submit" class="order-vnpay-retry-btn"><i class="fa-regular fa-credit-card"></i> Tiếp tục thanh toán VNPAY</button>
                            </form>
                            <% } %>
                        </div>
                    </div>

                    <article class="order-summary-card">
                        <div class="order-summary-icon" aria-hidden="true"><i class="fa-solid fa-cart-shopping"></i></div>
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

                    <% if (selectedCanUpdateShipment) { 
                        String currentDeliveryName = defaultText(shipmentStaffName, "");
                        String currentDeliveryPhone = (String) session.getAttribute("lastDeliveryPhone");
                        if (currentDeliveryPhone == null) currentDeliveryPhone = "";
                        
                        if (selectedOrder != null && selectedOrder.getShipmentNote() != null) {
                            String note = selectedOrder.getShipmentNote();
                            int sdtIndex = note.lastIndexOf("SĐT: ");
                            if (sdtIndex != -1) {
                                currentDeliveryPhone = note.substring(sdtIndex + 5).trim();
                            }
                            int nameStart = note.indexOf("Người giao hàng: ");
                            if (nameStart != -1 && sdtIndex != -1 && nameStart < sdtIndex) {
                                String extractedName = note.substring(nameStart + 17, note.lastIndexOf(" - SĐT: ")).trim();
                                if (!extractedName.isEmpty()) {
                                    currentDeliveryName = extractedName;
                                }
                            }
                        }
                    %>
                    <form class="shipment-update-form status-only" action="<%= ctx %>/order-history" method="post">
                        <input type="hidden" name="action" value="updateShipmentStatus">
                        <input type="hidden" name="orderId" value="<%= selectedOrder.getOrderId() %>">
                        <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                        <input type="hidden" name="filterStatusId" value="<%= h(selectedStatusIdValue) %>">
                        <input type="hidden" name="page" value="<%= currentPage %>">

                        <label>
                            <span>Trạng thái giao hàng</span>
                            <select name="shipmentStatusId" required>
                                <% for (OrderStatus status : statusOptions) { 
                                       if (isShipper && status.getStatusId() != 4 && status.getStatusId() != 5 && status.getStatusId() != 7) {
                                           continue;
                                       }
                                       if (isEmployee && status.getStatusId() != 2 && status.getStatusId() != 6) {
                                           continue;
                                       }
                                %>
                                <option value="<%= status.getStatusId() %>" <%= selectedOrder.getStatusId() == status.getStatusId() ? "selected" : "" %>>
                                    <%= h(status.getStatusName()) %>
                                </option>
                                <% } %>
                            </select>
                        </label>
                        <label>
                            <span>Tên người giao hàng</span>
                            <input type="text" name="deliveryName" value="<%= h(currentDeliveryName) %>" required>
                        </label>
                        <label>
                            <span>Số điện thoại người giao hàng</span>
                            <input type="tel" name="deliveryPhone" value="<%= h(currentDeliveryPhone) %>" required>
                        </label>
                        <button type="submit">Cập nhật</button>
                    </form>
                    <% } %>

                    <div class="order-products-box">
                        <h3>Danh sách sản phẩm</h3>
                        <div class="order-product-list">
                            <% for (OrderHistoryDetail detail : selectedDetails) { %>
                            <div class="order-product-item-wrap">
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
                                
                                <% if (isCustomerView && selectedOrder != null && isDeliveredShipmentStatus(selectedOrder.getDisplayStatus())) { %>
                                <div class="order-product-review-row">
                                    <% if (detail.getReview() != null) { %>
                                        <%
                                            StringBuilder imgListBuilder = new StringBuilder();
                                            if (detail.getReview().getImages() != null) {
                                                for (String imgPath : detail.getReview().getImages()) {
                                                    if (imgListBuilder.length() > 0) {
                                                        imgListBuilder.append(",");
                                                    }
                                                    imgListBuilder.append(imgPath);
                                                }
                                            }
                                            String imagesCsv = imgListBuilder.toString();
                                        %>
                                        <div class="order-reviewed-status">
                                            <div class="order-reviewed-stars">
                                                <% for (int i = 1; i <= 5; i++) { %>
                                                    <span class="<%= i <= detail.getReview().getRating() ? "" : "star-empty" %>"><i class="fa-solid fa-star"></i></span>
                                                <% } %>
                                            </div>
                                            <span class="order-reviewed-text">Bạn đã đánh giá</span>
                                            <button type="button" class="order-review-edit-btn trigger-review-modal"
                                                    data-product-id="<%= detail.getProductId() %>"
                                                    data-product-name="<%= h(detail.getProductName()) %>"
                                                    data-product-image="<%= h(assetUrl(ctx, detail.getImageUrl())) %>"
                                                    data-product-meta="<%= h(detail.getCategoryName()) %> · <%= h(detail.getBrandName()) %>"
                                                    data-rating="<%= detail.getReview().getRating() %>"
                                                    data-comment="<%= h(detail.getReview().getComment()) %>"
                                                    data-images="<%= h(imagesCsv) %>">
                                                Sửa
                                            </button>
                                        </div>
                                    <% } else { %>
                                        <button type="button" class="order-review-btn trigger-review-modal"
                                                data-product-id="<%= detail.getProductId() %>"
                                                data-product-name="<%= h(detail.getProductName()) %>"
                                                data-product-image="<%= h(assetUrl(ctx, detail.getImageUrl())) %>"
                                                data-product-meta="<%= h(detail.getCategoryName()) %> · <%= h(detail.getBrandName()) %>"
                                                data-rating="5"
                                                data-comment=""
                                                data-images="">
                                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                                              <path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499c.15-.316.606-.316.756 0l2.224 4.507 4.973.723c.348.051.488.482.236.728l-3.6 3.512.85 4.955c.058.344-.304.607-.61.446l-4.444-2.336-4.444 2.336c-.306.161-.669-.102-.61-.446l.85-4.955-3.6-3.512c-.253-.246-.113-.677.236-.728l4.973-.723 2.224-4.507Z" />
                                            </svg>
                                            Đánh giá sản phẩm
                                        </button>
                                    <% } %>
                                </div>
                                <% } %>
                            </div>
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

        <div class="order-modal-backdrop" data-modal="reviewQuickView" hidden>
            <div class="order-modal review-modal" role="dialog" aria-modal="true" aria-labelledby="reviewQuickViewTitle" style="width: min(520px, 100%);">
                <div class="order-modal-header" style="padding: 16px 20px; border-bottom: none;">
                    <h2 id="reviewQuickViewTitle" style="font-size: 18px; font-weight: 700; margin: 0;">Đánh giá sản phẩm</h2>
                    <button type="button" data-close-modal aria-label="Đóng" style="border: none; background: none; font-size: 20px; cursor: pointer;">×</button>
                </div>
                
                <form id="reviewForm" action="<%= ctx %>/submit-review" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="orderId" value="<%= selectedOrder.getOrderId() %>">
                    <input type="hidden" name="productId" id="reviewProductId" value="">
                    
                    <div class="order-modal-content" style="padding: 0 20px 20px;">
                        <!-- Product Summary Info Row -->
                        <div class="review-product-summary" style="display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 16px; border-bottom: 1px solid #edf0f5;">
                            <img id="reviewProductImg" src="" alt="" style="width: 50px; height: 50px; border-radius: 8px; border: 1px solid #e5e9f0; object-fit: contain; background: #f8fafc;">
                            <div>
                                <strong id="reviewProductName" style="display: block; font-size: 14px; color: #111827;"></strong>
                                <span id="reviewProductMeta" style="font-size: 12px; color: #64748b;"></span>
                            </div>
                        </div>
                        
                        <!-- Star Rating Section -->
                        <div style="margin-bottom: 20px;">
                            <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 8px;">Chất lượng sản phẩm</label>
                            <div class="star-rating-picker" style="display: flex; gap: 6px;">
                                <input type="hidden" name="rating" id="reviewRatingInput" value="5" required>
                                <span class="rating-star-btn" data-star="1" style="font-size: 32px; cursor: pointer; color: #fbbf24; line-height: 1;"><i class="fa-solid fa-star"></i></span>
                                <span class="rating-star-btn" data-star="2" style="font-size: 32px; cursor: pointer; color: #fbbf24; line-height: 1;"><i class="fa-solid fa-star"></i></span>
                                <span class="rating-star-btn" data-star="3" style="font-size: 32px; cursor: pointer; color: #fbbf24; line-height: 1;"><i class="fa-solid fa-star"></i></span>
                                <span class="rating-star-btn" data-star="4" style="font-size: 32px; cursor: pointer; color: #fbbf24; line-height: 1;"><i class="fa-solid fa-star"></i></span>
                                <span class="rating-star-btn" data-star="5" style="font-size: 32px; cursor: pointer; color: #fbbf24; line-height: 1;"><i class="fa-solid fa-star"></i></span>
                            </div>
                        </div>
                        
                        <!-- Comment Section -->
                        <div style="margin-bottom: 20px;">
                            <label for="reviewComment" style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 8px;">Nhận xét của bạn</label>
                            <textarea id="reviewComment" name="comment" rows="4" placeholder="Hàng chạy ổn định, đóng gói chắc chắn..." style="width: 100%; padding: 10px 12px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 13px; outline: none; resize: vertical; box-sizing: border-box;"></textarea>
                        </div>
                        
                        <!-- Realistic Image Section -->
                        <div style="margin-bottom: 24px;">
                            <label style="display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 8px;">Hình ảnh thực tế (tối đa 5 ảnh, định dạng ảnh, < 2MB)</label>
                            <div class="review-image-upload-wrapper" style="display: flex; flex-direction: column; gap: 12px; align-items: flex-start;">
                                <label class="review-image-upload-box" style="width: 72px; height: 72px; border: 1px dashed #d1d5db; border-radius: 8px; display: flex; flex-direction: column; align-items: center; justify-content: center; cursor: pointer; background: #fafafa; transition: border-color 0.15s ease; margin: 0;">
                                    <input type="file" name="imgFiles" id="reviewImgFileInput" accept="image/*" multiple style="display: none;">
                                    <!-- Camera SVG Icon -->
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" style="width: 20px; height: 20px; color: #64748b;">
                                      <path stroke-linecap="round" stroke-linejoin="round" d="M6.827 6.175A2.31 2.31 0 0 1 5.186 7.23c-.38.054-.757.112-1.134.175C2.999 7.58 2.25 8.507 2.25 9.574V18a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18V9.574c0-1.067-.75-1.994-1.802-2.169a47.865 47.865 0 0 0-1.134-.175 2.31 2.31 0 0 1-1.64-1.055l-.822-1.316a2.192 2.192 0 0 0-1.736-1.039 48.774 48.774 0 0 0-5.232 0 2.192 2.192 0 0 0-1.736 1.039l-.821 1.316Z" />
                                      <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 12.75a4.5 4.5 0 1 1-9 0 4.5 4.5 0 0 1 9 0ZM18.75 10.5h.008v.008h-.008V10.5Z" />
                                    </svg>
                                </label>
                                <input type="hidden" name="clearImages" id="reviewClearImagesInput" value="false">
                                <input type="hidden" name="keepImages" id="reviewKeepImagesInput" value="">
                                <!-- Preview list container -->
                                <div id="reviewImgPreviewList" style="display: flex; flex-wrap: wrap; gap: 8px; margin-top: 8px; width: 100%;"></div>
                                <div id="reviewValidationError" style="color: #ef1b24; font-size: 12px; display: none; font-weight: 500;"></div>
                            </div>
                        </div>
                        
                        <!-- Modal Footer Action Buttons -->
                        <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 24px;">
                            <button type="button" data-close-modal class="review-modal-btn-cancel" style="padding: 10px 24px; border: 1px solid #d1d5db; border-radius: 8px; background: #ffffff; color: #374151; font-size: 13px; font-weight: 600; cursor: pointer; transition: background 0.15s ease;">Hủy</button>
                            <button type="submit" class="review-modal-btn-submit" style="padding: 10px 24px; border: none; border-radius: 8px; background: #111827; color: #ffffff; font-size: 13px; font-weight: 600; cursor: pointer; transition: background 0.15s ease;">Gửi đánh giá</button>
                        </div>
                    </div>
                </form>
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

                // --- LOGIC ĐÁNH GIÁ SẢN PHẨM ---
                const starRatingPicker = document.querySelector(".star-rating-picker");
                const stars = starRatingPicker ? starRatingPicker.querySelectorAll(".rating-star-btn") : [];
                const ratingInput = document.getElementById("reviewRatingInput");

                function setStarRating(ratingValue) {
                    ratingValue = parseInt(ratingValue) || 5;
                    if (ratingInput) {
                        ratingInput.value = ratingValue;
                    }
                    
                    stars.forEach(star => {
                        const starNum = parseInt(star.getAttribute("data-star"));
                        if (starNum <= ratingValue) {
                            star.style.color = "#fbbf24";
                        } else {
                            star.style.color = "#d1d5db";
                        }
                    });
                }

                if (starRatingPicker) {
                    stars.forEach(star => {
                        star.addEventListener("click", function() {
                            const val = this.getAttribute("data-star");
                            setStarRating(val);
                        });
                        
                        star.addEventListener("mouseover", function() {
                            const val = parseInt(this.getAttribute("data-star"));
                            stars.forEach(s => {
                                const sNum = parseInt(s.getAttribute("data-star"));
                                if (sNum <= val) {
                                    s.style.color = "#fbbf24";
                                } else {
                                    s.style.color = "#d1d5db";
                                }
                            });
                        });
                    });

                    starRatingPicker.addEventListener("mouseleave", function() {
                        setStarRating(ratingInput.value);
                    });
                }

                // State variables for images
                let currentExistingImages = [];
                let currentNewFiles = [];

                const fileInput = document.getElementById("reviewImgFileInput");
                const previewList = document.getElementById("reviewImgPreviewList");
                const errorDiv = document.getElementById("reviewValidationError");

                function renderImages() {
                    if (!previewList) return;
                    previewList.innerHTML = "";
                    if (errorDiv) {
                        errorDiv.style.display = "none";
                        errorDiv.textContent = "";
                    }

                    // 1. Render existing images
                    currentExistingImages.forEach(function(path, index) {
                        const item = document.createElement("div");
                        item.style.cssText = "position: relative; width: 72px; height: 72px;";
                        item.innerHTML = 
                            '<img src="<%= ctx %>/' + path.trim() + '" style="width: 100%; height: 100%; border-radius: 8px; border: 1px solid #e5e9f0; object-fit: cover;">' +
                            '<button type="button" class="remove-old-img-btn" style="position: absolute; top: -6px; right: -6px; width: 18px; height: 18px; border-radius: 50%; background: rgba(15, 23, 42, 0.7); border: none; color: #ffffff; font-size: 12px; display: flex; align-items: center; justify-content: center; cursor: pointer; padding: 0; line-height: 1;">×</button>';
                        
                        item.querySelector(".remove-old-img-btn").addEventListener("click", function(e) {
                            e.preventDefault();
                            currentExistingImages.splice(index, 1);
                            renderImages();
                        });
                        previewList.appendChild(item);
                    });

                    // 2. Render newly selected images
                    currentNewFiles.forEach(function(file, index) {
                        const item = document.createElement("div");
                        item.style.cssText = "position: relative; width: 72px; height: 72px;";
                        
                        const objectUrl = URL.createObjectURL(file);
                        item.innerHTML = 
                            '<img src="' + objectUrl + '" style="width: 100%; height: 100%; border-radius: 8px; border: 1px solid #e5e9f0; object-fit: cover;">' +
                            '<button type="button" class="remove-new-img-btn" style="position: absolute; top: -6px; right: -6px; width: 18px; height: 18px; border-radius: 50%; background: rgba(15, 23, 42, 0.7); border: none; color: #ffffff; font-size: 12px; display: flex; align-items: center; justify-content: center; cursor: pointer; padding: 0; line-height: 1;">×</button>';
                        
                        item.querySelector(".remove-new-img-btn").addEventListener("click", function(e) {
                            e.preventDefault();
                            currentNewFiles.splice(index, 1);
                            updateFileInput();
                            renderImages();
                        });
                        previewList.appendChild(item);
                    });

                    // 3. Update hidden inputs
                    const keepImagesInput = document.getElementById("reviewKeepImagesInput");
                    if (keepImagesInput) {
                        keepImagesInput.value = currentExistingImages.join(",");
                    }
                    const clearImagesInput = document.getElementById("reviewClearImagesInput");
                    if (clearImagesInput) {
                        if (currentExistingImages.length === 0 && currentNewFiles.length === 0) {
                            clearImagesInput.value = "true";
                        } else {
                            clearImagesInput.value = "false";
                        }
                    }
                }

                function updateFileInput() {
                    if (!fileInput) return;
                    try {
                        const dt = new DataTransfer();
                        currentNewFiles.forEach(function(file) {
                            dt.items.add(file);
                        });
                        fileInput.files = dt.files;
                    } catch (err) {
                        console.error("DataTransfer is not supported: ", err);
                    }
                }

                // Trigger mở modal đánh giá & điền thông tin cũ
                const reviewTriggers = document.querySelectorAll(".trigger-review-modal");
                reviewTriggers.forEach(function (button) {
                    button.addEventListener("click", function () {
                        const productId = this.getAttribute("data-product-id");
                        const productName = this.getAttribute("data-product-name");
                        const productImage = this.getAttribute("data-product-image");
                        const productMeta = this.getAttribute("data-product-meta");
                        const rating = this.getAttribute("data-rating");
                        const comment = this.getAttribute("data-comment");
                        const imagesCsv = this.getAttribute("data-images");
                        
                        document.getElementById("reviewProductId").value = productId;
                        document.getElementById("reviewProductName").textContent = productName;
                        document.getElementById("reviewProductImg").src = productImage || '';
                        document.getElementById("reviewProductMeta").textContent = productMeta;
                        
                        setStarRating(rating);
                        document.getElementById("reviewComment").value = comment || '';
                        
                        currentNewFiles = [];
                        if (imagesCsv && imagesCsv.trim() !== "") {
                            currentExistingImages = imagesCsv.split(",").filter(function(p) { return p.trim() !== ""; });
                        } else {
                            currentExistingImages = [];
                        }
                        if (fileInput) fileInput.value = "";
                        renderImages();
                        
                        openModal("reviewQuickView");
                    });
                });

                // Xử lý upload ảnh preview
                if (fileInput) {
                    fileInput.addEventListener("change", function() {
                        const files = Array.from(this.files);
                        if (errorDiv) {
                            errorDiv.style.display = "none";
                            errorDiv.textContent = "";
                        }

                        if (currentExistingImages.length + files.length > 5) {
                            if (errorDiv) {
                                errorDiv.textContent = "Bạn chỉ được đăng tải tối đa tổng cộng 5 ảnh (bao gồm cả ảnh cũ).";
                                errorDiv.style.display = "block";
                            }
                            this.value = "";
                            updateFileInput();
                            return;
                        }

                        for (let i = 0; i < files.length; i++) {
                            const file = files[i];
                            
                            // FE Validate Size: <= 2MB
                            if (file.size > 2 * 1024 * 1024) {
                                if (errorDiv) {
                                    errorDiv.textContent = "Dung lượng ảnh '" + file.name + "' lớn hơn 2MB. Vui lòng chọn ảnh khác.";
                                    errorDiv.style.display = "block";
                                }
                                this.value = "";
                                updateFileInput();
                                return;
                            }
                            
                            // FE Validate Format: must be an image
                            if (!file.type.startsWith("image/")) {
                                if (errorDiv) {
                                    errorDiv.textContent = "Tệp '" + file.name + "' không phải là định dạng hình ảnh hợp lệ.";
                                    errorDiv.style.display = "block";
                                }
                                this.value = "";
                                updateFileInput();
                                return;
                            }
                        }

                        currentNewFiles = files;
                        renderImages();
                    });
                }
            })();
        </script>
        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
