<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.Warranty" %>

<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String defaultText(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    private String displayOrderCode(int orderId) {
        return "PB" + orderId;
    }

    private String formatDate(java.util.Date date, DateFormat formatter) {
        return date == null ? "Chưa có dữ liệu" : formatter.format(date);
    }

    private String formatCurrency(BigDecimal amount, NumberFormat formatter) {
        BigDecimal safeAmount = amount == null ? BigDecimal.ZERO : amount;
        return formatter.format(safeAmount) + "đ";
    }

    private String paymentMethodLabel(String paymentMethod) {
        if (paymentMethod == null) return "Chưa cập nhật";

        String normalized = paymentMethod.trim();
        if ("COD".equalsIgnoreCase(normalized)) return "Thanh toán khi nhận hàng";
        if ("VNPAY".equalsIgnoreCase(normalized)) return "Thanh toán qua VNPAY";

        return normalized;
    }

    private String orderStatusClass(String statusName) {
        if (statusName == null) return "neutral";

        String normalized = statusName.toLowerCase();
        if (normalized.contains("hủy")) return "cancelled";
        if (normalized.contains("giao") || normalized.contains("hoàn")) return "complete";
        if (normalized.contains("chờ") || normalized.contains("đang")) return "processing";
        if (normalized.contains("xác nhận")) return "confirmed";

        return "neutral";
    }
%>

<%
    String ctx = request.getContextPath();

    String orderIdInput = (String) request.getAttribute("orderIdInput");

    List<Warranty> items = (List<Warranty>) request.getAttribute("warrantyItems");
    Warranty orderInfo = (items == null || items.isEmpty()) ? null : items.get(0);

    Locale vietnameseLocale = new Locale("vi", "VN");
    NumberFormat currencyFormatter = NumberFormat.getNumberInstance(vietnameseLocale);
    currencyFormatter.setMinimumFractionDigits(0);
    currencyFormatter.setMaximumFractionDigits(0);

    DateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");

    boolean isDelivered = orderInfo != null && "Đã giao hàng".equalsIgnoreCase(orderInfo.getOrderStatusName());
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tra cứu bảo hành – ProBuild PC</title>
        <meta name="description" content="Tra cứu thời hạn bảo hành linh kiện PC theo mã đơn hàng tại ProBuild PC.">
        <link rel="stylesheet" type="text/css" href="<%= ctx %>/css/style.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    </head>

    <body class="warranty-lookup-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="wl-shell">
            <div class="wl-container">
                <!-- 1. Breadcrumbs & Header sitting directly on the flat light background -->
                <nav class="wl-breadcrumb" aria-label="breadcrumb">
                    <a href="<%= ctx %>/home">Trang chủ</a>
                    <span class="wl-breadcrumb-sep">›</span>
                    <span>Kiểm tra bảo hành</span>
                </nav>

                <header class="wl-page-header">
                    <h1 id="warranty-page-title">Kiểm tra bảo hành</h1>
                    <p class="wl-subtitle">Nhập mã đơn hàng để tra cứu trạng thái bảo hành từng linh kiện.</p>
                </header>

                <!-- 2. Two-Column Grid Layout -->
                <div class="wl-grid">
                    <!-- Left Column: Search & Results -->
                    <div class="wl-main-col">
                        <!-- Search Box Card -->
                        <div class="wl-card wl-search-card">
                            <form class="wl-search-form" id="warranty-search-form" action="<%= ctx %>/warranty-lookup" method="get" autocomplete="off">
                                <label for="orderId" class="wl-search-label">Nhập mã đơn hàng <span class="wl-required">*</span></label>
                                <div class="wl-search-input-wrapper">
                                    <div class="wl-search-field-container">
                                        <svg class="wl-search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                        <input
                                            id="orderId"
                                            name="orderId"
                                            type="text"
                                            value="<%= h(orderIdInput) %>"
                                            placeholder="VD: 10006 hoặc PB10006"
                                            required>
                                    </div>
                                    <button type="submit" id="warranty-search-btn">
                                        Kiểm tra
                                    </button>
                                </div>
                                <p class="wl-search-hint">Mã đơn hàng có trong email xác nhận hoặc trang chi tiết đơn hàng.</p>
                            </form>
                        </div>

                        <!-- Alerts -->
                        <c:if test="${not empty warrantyLookupError}">
                            <div class="wl-alert wl-alert--error" role="alert">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                <c:out value="${warrantyLookupError}" />
                            </div>
                        </c:if>

                        <c:if test="${not empty sessionScope.warrantySuccessMessage}">
                            <div class="wl-alert wl-alert--success" role="alert">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                <c:out value="${sessionScope.warrantySuccessMessage}" />
                            </div>
                            <c:remove var="warrantySuccessMessage" scope="session" />
                        </c:if>

                        <c:if test="${not empty sessionScope.warrantyFailMessage}">
                            <div class="wl-alert wl-alert--error" role="alert">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                <c:out value="${sessionScope.warrantyFailMessage}" />
                            </div>
                            <c:remove var="warrantyFailMessage" scope="session" />
                        </c:if>

                        <!-- Results Content -->
                        <% if (orderInfo != null) { %>
                        <!-- Order summary card -->
                        <section class="wl-order-strip" id="order-summary">
                            <div class="wl-order-strip-main">
                                <div class="wl-order-id-badge">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                    <strong><%= displayOrderCode(orderInfo.getOrderId()) %></strong>
                                </div>

                                <div class="wl-strip-divider"></div>

                                <div class="wl-order-detail-item">
                                    <span class="wl-detail-label">Ngày đặt</span>
                                    <span class="wl-detail-value"><%= formatDate(orderInfo.getOrderDate(), dateFormatter) %></span>
                                </div>

                                <div class="wl-strip-divider"></div>

                                <div class="wl-order-detail-item">
                                    <span class="wl-detail-label">Thanh toán</span>
                                    <span class="wl-detail-value"><%= h(paymentMethodLabel(orderInfo.getPaymentMethod())) %></span>
                                </div>

                                <div class="wl-strip-divider"></div>

                                <div class="wl-order-detail-item">
                                    <span class="wl-detail-label">Tổng giá trị</span>
                                    <span class="wl-detail-value wl-detail-value--price"><%= formatCurrency(orderInfo.getTotalAmount(), currencyFormatter) %></span>
                                </div>
                            </div>

                            <span class="wl-order-status-pill wl-order-status--<%= orderStatusClass(orderInfo.getOrderStatusName()) %>">
                                <%= h(defaultText(orderInfo.getOrderStatusName(), "Chưa cập nhật")) %>
                            </span>
                        </section>

                        <% if (!isDelivered) { %>
                        <div class="wl-notice wl-notice--warn" id="delivery-notice">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                            <span>Bảo hành chỉ áp dụng cho đơn hàng đã giao thành công. Đơn hàng này hiện chưa đủ điều kiện.</span>
                        </div>
                        <% } %>

                        <section class="wl-products" id="warranty-products">
                            <div class="wl-products-header">
                                <h2>Danh sách linh kiện</h2>
                                <span class="wl-product-count"><%= items.size() %> sản phẩm</span>
                            </div>

                            <% if (items.isEmpty()) { %>
                            <div class="wl-empty-products">
                                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                                <p>Đơn hàng này chưa có sản phẩm để tra cứu bảo hành.</p>
                            </div>
                            <% } else { %>
                            <div class="wl-product-list">
                                <% for (Warranty item : items) { %>
                                <%
                                    String imageUrl = defaultText(item.getImageUrl(), "");
                                    String imageSrc = imageUrl.isEmpty()
                                            ? ctx + "/images/background.jpg"
                                            : (imageUrl.startsWith("http://") || imageUrl.startsWith("https://")
                                            ? imageUrl
                                            : ctx + "/" + imageUrl);

                                    String state = item.getWarrantyState();

                                    boolean isWarrantyValid =
                                            item.getRemainingDays() > 0
                                                    && item.getWarrantyMonths() > 0
                                                    && item.getWarrantyEndDate() != null;
                                %>

                                <article class="wl-product-card" id="product-<%= item.getProductId() %>">
                                    <div class="wl-product-info">
                                        <img class="wl-product-img"
                                             src="<%= h(imageSrc) %>"
                                             alt="<%= h(defaultText(item.getProductName(), "Sản phẩm")) %>"
                                             loading="lazy">

                                        <div class="wl-product-text">
                                            <h3 class="wl-product-name" title="<%= h(defaultText(item.getProductName(), "Sản phẩm")) %>">
                                                <%= h(defaultText(item.getProductName(), "Sản phẩm")) %>
                                            </h3>
                                            <div class="wl-product-meta">
                                                <span class="wl-meta-tag"><%= h(defaultText(item.getCategoryName(), "Khác")) %></span>
                                                <span class="wl-meta-tag"><%= h(defaultText(item.getBrandName(), "Khác")) %></span>
                                                <span class="wl-meta-tag wl-meta-tag--qty">SL: <%= item.getQuantity() %></span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="wl-warranty-timeline">
                                        <div class="wl-timeline-top">
                                            <span class="wl-remaining-days wl-state-<%= state %>">
                                                <%= h(item.getRemainingDaysLabel()) %>
                                            </span>
                                            <span class="wl-warranty-badge wl-state-<%= state %>">
                                                <%= h(item.getWarrantyStatusLabel()) %>
                                            </span>
                                        </div>
                                        <div class="wl-timeline-bottom">
                                            <span>Hết hạn: <%= formatDate(item.getWarrantyEndDate(), dateFormatter) %></span>
                                            <span class="wl-timeline-sep">•</span>
                                            <span><%= item.getWarrantyMonths() %> tháng bảo hành</span>
                                        </div>
                                    </div>

                                    <div class="wl-product-action">
                                        <% if (isDelivered && isWarrantyValid) { %>
                                        <form class="wl-claim-form"
                                              action="<%= ctx %>/warranty-lookup"
                                              method="post"
                                              onsubmit="submitInlineWarrantyRequest(event, this)">

                                            <input type="hidden" name="action" value="createRequest">
                                            <input type="hidden" name="orderId" value="<%= orderInfo.getOrderId() %>">
                                            <input type="hidden" name="orderDetailId" value="<%= item.getOrderDetailId() %>">
                                            <input type="hidden" name="productId" value="<%= item.getProductId() %>">

                                            <textarea
                                                name="request"
                                                class="wl-claim-textarea"
                                                rows="2"
                                                placeholder="Mô tả lỗi sản phẩm..."
                                                required></textarea>

                                            <button type="submit" class="wl-btn wl-btn--primary">
                                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                                                Gửi yêu cầu
                                            </button>
                                        </form>
                                        <% } else if (isDelivered && !isWarrantyValid) { %>
                                        <span class="wl-status-badge wl-status-badge--expired">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                            Hết hạn bảo hành
                                        </span>
                                        <% } else { %>
                                        <span class="wl-status-badge wl-status-badge--locked">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                            Chờ giao hàng
                                        </span>
                                        <% } %>
                                    </div>
                                </article>
                                <% } %>
                            </div>
                            <% } %>

                            <p class="wl-footnote">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                Thời gian bảo hành được tính từ ngày đơn hàng giao thành công.
                            </p>
                        </section>
                        <% } else { %>
                        <!-- ═══════════════ EMPTY STATE ALERT CARD ═══════════════ -->
                        <div class="wl-empty-alert-card" id="warranty-empty">
                            <div class="wl-empty-alert-icon">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                    <circle cx="12" cy="12" r="10"/>
                                    <line x1="12" y1="16" x2="12" y2="12"/>
                                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                                </svg>
                            </div>
                            <div class="wl-empty-alert-content">
                                Chưa có đơn hàng để hiển thị - Nhập order ID trong hệ thống để xem ngày hết hạn bảo hành của từng linh kiện.
                            </div>
                        </div>
                        <% } %>
                    </div>

                    <!-- Right Column: Sidebar (Warranty Policy) -->
                    <div class="wl-side-col">
                        <div class="wl-card wl-policy-card" id="warranty-policy">
                            <h3 class="wl-policy-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                                </svg>
                                Chính sách bảo hành
                            </h3>
                            <div class="wl-policy-list">
                                <div class="wl-policy-item">
                                    <div class="wl-policy-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    </div>
                                    <p>Sản phẩm được bảo hành theo chính sách của nhà sản xuất.</p>
                                </div>
                                <div class="wl-policy-item">
                                    <div class="wl-policy-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </div>
                                    <p>Thời gian bảo hành có thể khác nhau tùy thuộc vào từng sản phẩm.</p>
                                </div>
                                <div class="wl-policy-item">
                                    <div class="wl-policy-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                                    </div>
                                    <p>Vui lòng liên hệ <strong>0368.176.253</strong> nếu bạn cần hỗ trợ thêm.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <jsp:include page="/includes/footer.jsp" />

        <script>
            function submitInlineWarrantyRequest(event, form) {
                var btn = form.querySelector('button[type="submit"]');
                if (btn) {
                    btn.disabled = true;
                    btn.innerHTML = '<span class="wl-btn-spinner"></span> Đang gửi...';
                }
            }
        </script>
    </body>
</html>