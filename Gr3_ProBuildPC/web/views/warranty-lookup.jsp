<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.WarrantyLookupItem" %>
<%@ page import="model.WarrantyLookupResult" %>

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
        if (paymentMethod == null) {
            return "Chưa cập nhật";
        }

        String normalized = paymentMethod.trim();
        if ("COD".equalsIgnoreCase(normalized)) {
            return "Thanh toán khi nhận hàng";
        }

        if ("VNPAY".equalsIgnoreCase(normalized)) {
            return "Thanh toán qua VNPAY";
        }

        return normalized;
    }

    private String orderStatusClass(String statusName) {
        if (statusName == null) {
            return "neutral";
        }

        String normalized = statusName.toLowerCase();
        if (normalized.contains("hủy")) {
            return "cancelled";
        }

        if (normalized.contains("giao") || normalized.contains("hoàn")) {
            return "complete";
        }

        if (normalized.contains("chờ") || normalized.contains("đang")) {
            return "processing";
        }

        return "neutral";
    }
%>

<%
    String ctx = request.getContextPath();
    String orderIdInput = (String) request.getAttribute("orderIdInput");
    String errorMessage = (String) request.getAttribute("warrantyLookupError");
    WarrantyLookupResult result = (WarrantyLookupResult) request.getAttribute("warrantyLookupResult");
    List<WarrantyLookupItem> items = result == null ? java.util.Collections.emptyList() : result.getItems();

    Locale vietnameseLocale = new Locale("vi", "VN");
    NumberFormat currencyFormatter = NumberFormat.getNumberInstance(vietnameseLocale);
    currencyFormatter.setMinimumFractionDigits(0);
    currencyFormatter.setMaximumFractionDigits(0);
    DateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tra cứu bảo hành</title>
        <link rel="stylesheet" type="text/css" href="<%= ctx %>/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>
    <body class="warranty-lookup-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="warranty-shell">
            <nav class="warranty-breadcrumb" aria-label="breadcrumb">
                <a href="<%= ctx %>/home">Trang chủ</a>
                <span>›</span>
                <strong>Kiểm tra bảo hành</strong>
            </nav>

            <section class="warranty-intro">
                <div class="warranty-intro-copy">
                    <h1>Kiểm tra bảo hành</h1>
                    <p>Nhập mã đơn hàng để xem thời hạn bảo hành các sản phẩm trong đơn.</p>
                </div>

                <div class="warranty-hero-mark" aria-hidden="true">
                    <div class="warranty-shield"><i class="fa-solid fa-check"></i></div>
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
                        <p class="warranty-help-text"><i class="fa-solid fa-circle-info"></i> Mã đơn hàng có trong email xác nhận hoặc trang chi tiết đơn hàng.</p>

                        <% if (errorMessage != null && !errorMessage.trim().isEmpty()) { %>
                        <div class="warranty-alert">
                            <%= h(errorMessage) %>
                        </div>
                        <% } %>
                    </form>

                    <% if (result != null) { %>
                    <section class="warranty-result-card">
                        <header class="warranty-result-header">
                            <div class="warranty-success-icon"><i class="fa-solid fa-check"></i></div>
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
                            <div class="warranty-empty-row">
                                Đơn hàng này chưa có sản phẩm để tra cứu bảo hành.
                            </div>
                            <% } else { %>
                            <% for (WarrantyLookupItem item : items) { %>
                            <%
                                String imageUrl = defaultText(item.getImageUrl(), "");
                                String imageSrc = imageUrl.isEmpty()
                                        ? ctx + "/images/background.jpg"
                                        : (imageUrl.startsWith("http://") || imageUrl.startsWith("https://") ? imageUrl : ctx + "/" + imageUrl);
                                String state = item.getWarrantyState();
                            %>
                            <article class="warranty-row">
                                <div class="warranty-product-cell">
                                    <img src="<%= h(imageSrc) %>" alt="<%= h(defaultText(item.getProductName(), "Sản phẩm")) %>">
                                    <div>
                                        <strong><%= h(defaultText(item.getProductName(), "Sản phẩm")) %></strong>
                                        <span><%= h(defaultText(item.getCategoryName(), "Khác")) %> | <%= h(defaultText(item.getBrandName(), "Khác")) %></span>
                                        <small>Số lượng: <%= item.getQuantity() %></small>
                                    </div>
                                </div>

                                <div class="warranty-time-cell warranty-state-<%= state %>">
                                    <strong><%= h(item.getRemainingDaysLabel()) %></strong>
                                    <span>Hết hạn: <%= formatDate(item.getWarrantyEndDate(), dateFormatter) %></span>
                                    <small><%= item.getWarrantyMonths() %> tháng bảo hành</small>
                                </div>

                                <div>
                                    <span class="warranty-status-pill warranty-status-<%= state %>">
                                        <%= h(item.getWarrantyStatusLabel()) %>
                                    </span>
                                </div>
                            </article>
                            <% }} %>
                        </div>

                        <p class="warranty-note"><i class="fa-solid fa-circle-info"></i> Thời gian bảo hành được tính từ ngày mua hàng.</p>
                    </section>
                    <% } else { %>
                    <section class="warranty-empty-state">
                        <div class="warranty-empty-icon"><i class="fa-regular fa-circle-question"></i></div>
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
                            <div>
                                <dt>Ngày đặt hàng</dt>
                                <dd><%= formatDate(result.getOrderDate(), dateFormatter) %></dd>
                            </div>
                            <div>
                                <dt>Hình thức thanh toán</dt>
                                <dd><%= h(paymentMethodLabel(result.getPaymentMethod())) %></dd>
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
                            <i class="fa-solid fa-arrow-rotate-right"></i> Xem chi tiết đơn hàng
                        </a>
                    </section>
                    <% } %>

                    <section class="warranty-policy-card">
                        <h2>Chính sách bảo hành</h2>
                        <div class="warranty-policy-list">
                            <div>
                                <span><i class="fa-solid fa-check"></i></span>
                                <p>Sản phẩm được bảo hành theo chính sách của nhà sản xuất.</p>
                            </div>
                            <div>
                                <span><i class="fa-regular fa-calendar-days"></i></span>
                                <p>Thời gian bảo hành có thể khác nhau tùy thuộc vào từng sản phẩm.</p>
                            </div>
                            <div>
                                <span><i class="fa-solid fa-phone"></i></span>
                                <p>Vui lòng liên hệ 1900 9999 nếu bạn cần hỗ trợ thêm.</p>
                            </div>
                        </div>
                    </section>
                </aside>
            </section>
        </main>

        <jsp:include page="/includes/footer.jsp" />
        <script>
            document.addEventListener("DOMContentLoaded", function() {
                Validator.setupRealTimeValidation([
                    {
                        selector: '#orderId',
                        validateFn: (val) => Validator.validateOrderId(val),
                        getErrorMsg: () => 'Mã đơn hàng không hợp lệ. Vui lòng nhập số ID (VD: 10006 hoặc PB10006).'
                    }
                ]);
            });

            function validateForm() {
                const orderIdInput = document.getElementById("orderId");
                const isValid = Validator.validateOrderId(orderIdInput.value);
                Validator.showFeedback(orderIdInput, isValid, 'Mã đơn hàng không hợp lệ. Vui lòng nhập số ID (VD: 10006 hoặc PB10006).');
                return isValid;
            }
        </script>
    </body>
</html>
