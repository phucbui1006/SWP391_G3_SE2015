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

                <div class="warranty-hero-mark" aria-hidden="true">
                    <div class="warranty-shield">✓</div>
                    <div class="warranty-card-icon">
                        <span></span>
                        <span></span>
                    </div>
                </div>
            </section>

            <section class="warranty-layout">
                <div class="warranty-main-column">
                    <form id="warrantyForm" class="warranty-search-card" action="<%= ctx %>/warranty-lookup" method="get" onsubmit="return validateForm()">
                        <label for="orderId">Nhập mã đơn hàng <span>*</span></label>
                        <div class="warranty-search-row">
                            <input
                                id="orderId"
                                name="orderId"
                                type="text"
                                value="<%= h(orderIdInput) %>"
                                placeholder="VD: 10006 hoặc PB10006"
                                autocomplete="off"
                                required>
                            <button type="submit">Kiểm tra</button>
                        </div>
                        <p class="warranty-help-text">ⓘ Mã đơn hàng có trong email xác nhận hoặc trang chi tiết đơn hàng.</p>

                        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                        <div class="warranty-alert">
                            <%= h(errorMessage) %>
                        </div>
                        <% } %>

                    <% if (result != null) { %>
                    <section class="warranty-result-card">
                        <header class="warranty-result-header">
                            <div class="warranty-success-icon">✓</div>
                            <div>
                                <h2>Đơn hàng <%= displayOrderCode(result.getOrderId()) %></h2>
                                <p>
                                    Ngày đặt hàng: <%= formatDate(result.getOrderDate(), dateFormatter) %>
                                    <span>•</span>
                                    Tổng giá trị: <%= formatCurrency(result.getTotalAmount(), currencyFormatter) %>
                                </p>
                            </div>
                        </header>

                        <h3>Danh sách linh kiện và thông tin bảo hành</h3>

                        <div class="warranty-table">
                            <div class="warranty-table-head">
                                <div>Sản phẩm</div>
                                <div>Thời hạn bảo hành</div>
                                <div>Trạng thái</div>
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

                        <p class="warranty-note">ⓘ Thời gian bảo hành được tính từ ngày mua hàng.</p>
                    </section>
                    <% } else { %>
                    <section class="warranty-empty-state">
                        <div class="warranty-empty-icon">?</div>
                        <div>
                            <h2>Chưa có đơn hàng để hiển thị</h2>
                            <p>Nhập order ID trong hệ thống để xem ngày hết hạn bảo hành của từng linh kiện.</p>
                        </div>
                    </section>
                    <% } %>
                </div>

                <aside class="warranty-side-column">
                    <% if (result != null) { %>
                    <section class="warranty-info-card">
                        <h2>Thông tin đơn hàng</h2>

                        <dl>
                            <div>
                                <dt>Mã đơn hàng</dt>
                                <dd><%= displayOrderCode(result.getOrderId()) %></dd>
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
                            <div>
                                <dt>Trạng thái đơn hàng</dt>
                                <dd>
                                    <span class="order-status-pill order-status-<%= orderStatusClass(result.getOrderStatusName()) %>">
                                        <%= h(defaultText(result.getOrderStatusName(), "Chưa cập nhật")) %>
                                    </span>
                                </dd>
                            </div>
                            <div>
                                <dt>Tổng giá trị</dt>
                                <dd class="warranty-total"><%= formatCurrency(result.getTotalAmount(), currencyFormatter) %></dd>
                            </div>
                        </dl>

                        <a class="warranty-detail-link" href="#">
                            ⟳ Xem chi tiết đơn hàng
                        </a>
                    </section>
                    <% } %>

                    <section class="warranty-policy-card">
                        <h2>Chính sách bảo hành</h2>
                        <div class="warranty-policy-list">
                            <div>
                                <span>✓</span>
                                <p>Sản phẩm được bảo hành theo chính sách của nhà sản xuất.</p>
                            </div>
                            <div>
                                <span>□</span>
                                <p>Thời gian bảo hành có thể khác nhau tùy thuộc vào từng sản phẩm.</p>
                            </div>
                            <div>
                                <span>☎</span>
                                <p>Vui lòng liên hệ 1900 9999 nếu bạn cần hỗ trợ thêm.</p>
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