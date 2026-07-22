<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.Address" %>
<%@ page import="model.CartItem" %>
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
%>
<%
    List<CartItem> checkoutItems = (List<CartItem>) request.getAttribute("checkoutItems");
    if (checkoutItems == null) {
        checkoutItems = Collections.emptyList();
    }

    List<Address> savedAddresses = (List<Address>) request.getAttribute("savedAddresses");
    if (savedAddresses == null) {
        savedAddresses = Collections.emptyList();
    }

    List<Integer> selectedCartItemIds = (List<Integer>) request.getAttribute("selectedCartItemIds");
    if (selectedCartItemIds == null) {
        selectedCartItemIds = Collections.emptyList();
    }

    BigDecimal checkoutSubtotal = (BigDecimal) request.getAttribute("checkoutSubtotal");
    BigDecimal checkoutTotal = (BigDecimal) request.getAttribute("checkoutTotal");
    if (checkoutSubtotal == null) {
        checkoutSubtotal = BigDecimal.ZERO;
    }
    if (checkoutTotal == null) {
        checkoutTotal = BigDecimal.ZERO;
    }

    Address selectedAddress = (Address) request.getAttribute("selectedAddress");
    String selectedPaymentMethod = String.valueOf(request.getAttribute("selectedPaymentMethod") != null
            ? request.getAttribute("selectedPaymentMethod")
            : "COD");
    String orderNote = String.valueOf(request.getAttribute("orderNote") != null
            ? request.getAttribute("orderNote")
            : "");
    String checkoutMode = String.valueOf(request.getAttribute("checkoutMode") != null
            ? request.getAttribute("checkoutMode")
            : "cart");
    Object directProductIdObj = request.getAttribute("directProductId");
    Object directQuantityObj = request.getAttribute("directQuantity");
    Integer directProductId = directProductIdObj instanceof Integer ? (Integer) directProductIdObj : null;
    Integer directQuantity = directQuantityObj instanceof Integer ? (Integer) directQuantityObj : null;
    boolean canPlaceOrder = Boolean.TRUE.equals(request.getAttribute("canPlaceOrder"));
    int checkoutLineCount = request.getAttribute("checkoutLineCount") instanceof Integer
            ? (Integer) request.getAttribute("checkoutLineCount")
            : checkoutItems.size();

    Locale vietnameseLocale = new Locale("vi", "VN");
    NumberFormat currencyFormatter = NumberFormat.getNumberInstance(vietnameseLocale);
    currencyFormatter.setMinimumFractionDigits(0);
    currencyFormatter.setMaximumFractionDigits(0);
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thanh toán</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
        <script src="${pageContext.request.contextPath}/js/checkout.js"></script>
    </head>
    <body class="checkout-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="checkout-shell">
            <nav class="checkout-breadcrumb site-breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
                <span>›</span>
                <strong>Thanh toán</strong>
            </nav>

            <% if (request.getAttribute("errorMsg") != null) { %>
            <div class="alert-message alert-danger checkout-feedback">
                <%= request.getAttribute("errorMsg") %>
            </div>
            <% } %>

            <div class="checkout-layout">
                <form class="checkout-main-column" action="${pageContext.request.contextPath}/checkout" method="post" onsubmit="return validateCheckoutForm(this)">
                    <input type="hidden" name="action" value="placeOrder">
                    <input type="hidden" name="selectedAddressId" value="<%= selectedAddress != null ? selectedAddress.getAddressId() : "" %>" data-checkout-selected-address-id>

                    <% if ("build".equalsIgnoreCase(checkoutMode)) { %>
                    <input type="hidden" name="checkoutMode" value="build">
                    <% } else if ("cart".equalsIgnoreCase(checkoutMode)) { %>
                    <% for (Integer cartItemId : selectedCartItemIds) { %>
                    <input type="hidden" name="selectedCartItemIds" value="<%= cartItemId %>">
                    <% } %>
                    <% } else if (directProductId != null && directQuantity != null) { %>
                    <input type="hidden" name="productId" value="<%= directProductId %>">
                    <input type="hidden" name="quantity" value="<%= directQuantity %>">
                    <% } %>

                    <section class="checkout-card">
                        <div class="checkout-section-header">
                            <h1>Thông tin giao hàng</h1>
                        </div>

                        <% if (selectedAddress != null) { %>
                        <div class="checkout-address-summary">
                            <div class="checkout-address-line">
                                <span>Tên người nhận</span>
                                <strong data-checkout-address-name><%= h(selectedAddress.getRecipientName()) %></strong>
                            </div>
                            <div class="checkout-address-line">
                                <span>Số điện thoại</span>
                                <strong data-checkout-address-phone><%= h(selectedAddress.getPhoneNumber()) %></strong>
                            </div>
                            <div class="checkout-address-line">
                                <span>Địa chỉ giao hàng</span>
                                <strong data-checkout-address-detail><%= h(selectedAddress.getAddressDetail()) %></strong>
                            </div>
                        </div>
                        <% } else { %>
                        <div class="checkout-empty-address">
                            <strong>Chưa có địa chỉ giao hàng</strong>
                            <p>Hãy thêm địa chỉ nhận hàng trước khi tiến hành thanh toán.</p>
                        </div>
                        <% } %>

                        <div class="checkout-address-picker">
                            <button
                                type="button"
                                class="checkout-address-toggle"
                                data-checkout-address-toggle
                                aria-haspopup="dialog"
                                aria-expanded="false">
                                <span>Chọn địa chỉ khác</span>
                                <span class="checkout-address-toggle-icon">›</span>
                            </button>
                        </div>
                    </section>

                    <section class="checkout-card">
                        <div class="checkout-section-header">
                            <h2>Phương thức thanh toán</h2>
                        </div>

                        <label class="checkout-payment-option <%= "COD".equalsIgnoreCase(selectedPaymentMethod) ? "is-selected" : "" %>">
                            <input type="radio" name="paymentMethod" value="COD" <%= "COD".equalsIgnoreCase(selectedPaymentMethod) ? "checked" : "" %>>
                            <div class="checkout-payment-copy">
                                <strong>Thanh toán khi nhận hàng</strong>
                                <span>Thanh toán bằng tiền mặt khi nhận hàng.</span>
                            </div>
                        </label>

                        <label class="checkout-payment-option <%= "VNPAY".equalsIgnoreCase(selectedPaymentMethod) ? "is-selected" : "" %>">
                            <input type="radio" name="paymentMethod" value="VNPAY" <%= "VNPAY".equalsIgnoreCase(selectedPaymentMethod) ? "checked" : "" %>>
                            <div class="checkout-payment-copy">
                                <strong>Thanh toán qua VNPAY</strong>
                                <span>Lưu lựa chọn thanh toán VNPAY cho đơn hàng.</span>
                            </div>
                        </label>
                    </section>

                    <section class="checkout-card">
                        <div class="checkout-section-header">
                            <h2>Ghi chú đơn hàng <span>(không bắt buộc)</span></h2>
                        </div>

                        <div class="checkout-note-field">
                            <textarea
                                name="note"
                                id="note"
                                rows="4"
                                placeholder="Nhập ghi chú cho đơn hàng..."
                                data-checkout-note><%= h(orderNote) %></textarea>
                            <div class="checkout-note-counter">
                                <span data-checkout-note-count><%= orderNote.length() %></span>/1000
                            </div>
                        </div>
                    </section>

                    <div class="checkout-actions">
                        <a class="checkout-back-link" href="${pageContext.request.contextPath}/<%= "build".equalsIgnoreCase(checkoutMode) ? "build-pc" : "cart" %>">
                            ← <%= "build".equalsIgnoreCase(checkoutMode) ? "Quay lại Build PC" : "Quay lại giỏ hàng" %>
                        </a>

                        <button
                            type="submit"
                            class="checkout-submit-btn"
                            <%= canPlaceOrder ? "" : "disabled" %>>
                            Tiến hành thanh toán →
                        </button>
                    </div>
                </form>

                <aside class="checkout-summary-column">
                    <section class="checkout-summary-card">
                        <div class="checkout-section-header">
                            <h2>Đơn hàng của bạn <span>(<%= checkoutLineCount %> sản phẩm)</span></h2>
                        </div>

                        <div class="checkout-summary-items">
                            <% for (CartItem item : checkoutItems) { %>
                            <%
                                String productName = item.getProduct() != null
                                        ? defaultText(item.getProduct().getProductName(), "San pham")
                                        : "San pham";
                                String imageUrl = (item.getProduct() != null
                                        && item.getProduct().getImageUrl() != null
                                        && !item.getProduct().getImageUrl().trim().isEmpty())
                                        ? item.getProduct().getImageUrl()
                                        : "https://via.placeholder.com/72x72?text=PC";
                            %>
                            <article class="checkout-summary-item">
                                <img src="<%= imageUrl %>" alt="<%= h(productName) %>">
                                <div class="checkout-summary-item-copy">
                                    <strong><%= h(productName) %></strong>
                                    <span>x<%= item.getQuantity() %></span>
                                </div>
                                <div class="checkout-summary-item-price">
                                    <%= currencyFormatter.format(item.getLineTotal()) %>đ
                                </div>
                            </article>
                            <% } %>
                        </div>

                        <div class="checkout-summary-totals">
                            <div class="checkout-summary-row">
                                <span>Tạm tính</span>
                                <strong><%= currencyFormatter.format(checkoutSubtotal) %>đ</strong>
                            </div>
                            <div class="checkout-summary-row">
                                <span>Phí vận chuyển</span>
                                <strong class="is-free">Miễn phí</strong>
                            </div>
                            <div class="checkout-summary-row total">
                                <span>Tổng cộng</span>
                                <strong><%= currencyFormatter.format(checkoutTotal) %>đ</strong>
                            </div>
                        </div>

                        <div class="checkout-summary-benefits">
                            <div class="checkout-benefit">
                                <strong>Thông tin bảo mật</strong>
                                <span>Thông tin của bạn được dùng cho xử lý đơn hàng.</span>
                            </div>
                            <div class="checkout-benefit">
                                <strong>Miễn phí vận chuyển</strong>
                                <span>Áp dụng cho các đơn hàng trong khu vực Hòa Lạc.</span>
                            </div>
                            <div class="checkout-benefit">
                                <strong>Hỗ trợ nhanh</strong>
                                <span>Có thể quay lại trang địa chỉ giao hàng để thêm mới bất cứ lúc nào.</span>
                            </div>
                        </div>
                    </section>
                </aside>
            </div>
        </main>

        <div class="checkout-address-modal" data-checkout-address-modal hidden>
            <div class="checkout-address-modal-backdrop" data-checkout-address-close></div>

            <div
                class="checkout-address-dialog"
                role="dialog"
                aria-modal="true"
                aria-labelledby="checkoutAddressDialogTitle">
                <button
                    type="button"
                    class="checkout-address-dialog-close"
                    data-checkout-address-close
                    aria-label="Đóng chọn địa chỉ">
                    &times;
                </button>

                <div class="checkout-address-dialog-header">
                    <h3 id="checkoutAddressDialogTitle">Chọn địa chỉ giao hàng</h3>
                    <p>Chọn một địa chỉ có sẵn</p>
                </div>

                <% if (savedAddresses.isEmpty()) { %>
                <div class="checkout-address-empty-panel is-modal">
                    <p>Chưa có địa chỉ nào được lưu trong tài khoản.</p>
                </div>
                <% } else { %>
                <div class="checkout-address-option-list is-modal">
                    <% for (Address address : savedAddresses) { %>
                    <button
                        type="button"
                        class="checkout-address-option <%= selectedAddress != null && address.getAddressId() == selectedAddress.getAddressId() ? "is-active" : "" %>"
                        data-checkout-address-option
                        data-address-id="<%= address.getAddressId() %>"
                        data-recipient-name="<%= h(address.getRecipientName()) %>"
                        data-phone-number="<%= h(address.getPhoneNumber()) %>"
                        data-address-detail="<%= h(address.getAddressDetail()) %>">
                        <span class="checkout-address-option-radio" aria-hidden="true"></span>
                        <span class="checkout-address-option-status">Đang chọn</span>

                        <span class="checkout-address-option-copy">
                            <strong><%= h(address.getRecipientName()) %></strong>
                            <span><%= h(defaultText(address.getPhoneNumber(), "Chua co so dien thoai")) %></span>
                            <small><%= h(address.getAddressDetail()) %></small>
                        </span>
                    </button>
                    <% } %>
                </div>
                <% } %>

                <div class="checkout-address-dialog-footer">
                    <a class="checkout-address-dialog-add-link" href="${pageContext.request.contextPath}/shipping-address">
                        + Thêm mới địa chỉ
                    </a>
                </div>
            </div>
        </div>

        <script>
            (function () {
                const toggleButton = document.querySelector('[data-checkout-address-toggle]');
                const addressModal = document.querySelector('[data-checkout-address-modal]');
                const closeTriggers = document.querySelectorAll('[data-checkout-address-close]');
                const dialogCloseButton = document.querySelector('.checkout-address-dialog-close');
                const addressOptions = document.querySelectorAll('[data-checkout-address-option]');
                const selectedAddressIdInput = document.querySelector('[data-checkout-selected-address-id]');
                const addressNameElement = document.querySelector('[data-checkout-address-name]');
                const addressPhoneElement = document.querySelector('[data-checkout-address-phone]');
                const addressDetailElement = document.querySelector('[data-checkout-address-detail]');
                const noteField = document.querySelector('[data-checkout-note]');
                const noteCountElement = document.querySelector('[data-checkout-note-count]');
                const paymentOptions = document.querySelectorAll('.checkout-payment-option');
                const paymentInputs = document.querySelectorAll('.checkout-payment-option input[type="radio"]');

                const closeAddressModal = function () {
                    if (!toggleButton || !addressModal) {
                        return;
                    }

                    toggleButton.setAttribute('aria-expanded', 'false');
                    addressModal.hidden = true;
                    document.body.classList.remove('checkout-address-modal-open');
                };

                const openAddressModal = function () {
                    if (!toggleButton || !addressModal) {
                        return;
                    }

                    toggleButton.setAttribute('aria-expanded', 'true');
                    addressModal.hidden = false;
                    document.body.classList.add('checkout-address-modal-open');

                    if (dialogCloseButton) {
                        dialogCloseButton.focus();
                    }
                };

                if (toggleButton && addressModal) {
                    toggleButton.addEventListener('click', function () {
                        const expanded = toggleButton.getAttribute('aria-expanded') === 'true';

                        if (expanded) {
                            closeAddressModal();
                            return;
                        }

                        openAddressModal();
                    });
                }

                closeTriggers.forEach(function (trigger) {
                    trigger.addEventListener('click', closeAddressModal);
                });

                addressOptions.forEach(function (option) {
                    option.addEventListener('click', function () {
                        addressOptions.forEach(function (item) {
                            item.classList.remove('is-active');
                        });

                        option.classList.add('is-active');

                        if (selectedAddressIdInput) {
                            selectedAddressIdInput.value = option.dataset.addressId || '';
                        }

                        if (addressNameElement) {
                            addressNameElement.textContent = option.dataset.recipientName || '';
                        }

                        if (addressPhoneElement) {
                            addressPhoneElement.textContent = option.dataset.phoneNumber || '';
                        }

                        if (addressDetailElement) {
                            addressDetailElement.textContent = option.dataset.addressDetail || '';
                        }

                        closeAddressModal();
                    });
                });



                paymentInputs.forEach(function (input) {
                    input.addEventListener('change', function () {
                        paymentOptions.forEach(function (option) {
                            const radio = option.querySelector('input[type="radio"]');
                            option.classList.toggle('is-selected', !!radio && radio.checked);
                        });
                    });
                });

                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && addressModal && !addressModal.hidden) {
                        closeAddressModal();
                    }
                });
            })();


        </script>
    </body>
</html>
