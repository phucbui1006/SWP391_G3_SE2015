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
        <title>Thanh to&#225;n</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
        <script src="${pageContext.request.contextPath}/js/checkout.js"></script>
    </head>
    <body class="checkout-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="checkout-shell">
            <div class="checkout-breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Trang ch&#7911;</a>
                <span>/</span>
                <span class="active">Thanh to&#225;n</span>
            </div>

            <% if (request.getAttribute("errorMsg") != null) { %>
            <div class="alert-message alert-danger checkout-feedback">
                <%= request.getAttribute("errorMsg") %>
            </div>
            <% } %>

            <div class="checkout-layout">
                <form class="checkout-main-column" action="${pageContext.request.contextPath}/checkout" method="post" onsubmit="return validateCheckoutForm(this)">
                    <input type="hidden" name="action" value="placeOrder">
                    <input type="hidden" name="selectedAddressId" value="<%= selectedAddress != null ? selectedAddress.getAddressId() : "" %>" data-checkout-selected-address-id>

                    <% if ("cart".equalsIgnoreCase(checkoutMode)) { %>
                    <% for (Integer cartItemId : selectedCartItemIds) { %>
                    <input type="hidden" name="selectedCartItemIds" value="<%= cartItemId %>">
                    <% } %>
                    <% } else if (directProductId != null && directQuantity != null) { %>
                    <input type="hidden" name="productId" value="<%= directProductId %>">
                    <input type="hidden" name="quantity" value="<%= directQuantity %>">
                    <% } %>

                    <section class="checkout-card">
                        <div class="checkout-section-header">
                            <h1>Th&#244;ng tin giao h&#224;ng</h1>
                        </div>

                        <% if (selectedAddress != null) { %>
                        <div class="checkout-address-summary">
                            <div class="checkout-address-line">
                                <span>T&#234;n ng&#432;&#7901;i nh&#7853;n</span>
                                <strong data-checkout-address-name><%= h(selectedAddress.getRecipientName()) %></strong>
                            </div>
                            <div class="checkout-address-line">
                                <span>S&#7889; &#273;i&#7879;n tho&#7841;i</span>
                                <strong data-checkout-address-phone><%= h(selectedAddress.getPhoneNumber()) %></strong>
                            </div>
                            <div class="checkout-address-line">
                                <span>&#272;&#7883;a ch&#7881; giao h&#224;ng</span>
                                <strong data-checkout-address-detail><%= h(selectedAddress.getAddressDetail()) %></strong>
                            </div>
                        </div>
                        <% } else { %>
                        <div class="checkout-empty-address">
                            <strong>Ch&#432;a c&#243; &#273;&#7883;a ch&#7881; giao h&#224;ng</strong>
                            <p>H&#227;y th&#234;m &#273;&#7883;a ch&#7881; nh&#7853;n h&#224;ng tr&#432;&#7899;c khi ti&#7871;n h&#224;nh thanh to&#225;n.</p>
                        </div>
                        <% } %>

                        <div class="checkout-address-picker">
                            <button
                                type="button"
                                class="checkout-address-toggle"
                                data-checkout-address-toggle
                                aria-haspopup="dialog"
                                aria-expanded="false">
                                <span>Ch&#7885;n &#273;&#7883;a ch&#7881; kh&#225;c</span>
                                <span class="checkout-address-toggle-icon">&#8250;</span>
                            </button>
                        </div>
                    </section>

                    <section class="checkout-card">
                        <div class="checkout-section-header">
                            <h2>Ph&#432;&#417;ng th&#7913;c thanh to&#225;n</h2>
                        </div>

                        <label class="checkout-payment-option <%= "COD".equalsIgnoreCase(selectedPaymentMethod) ? "is-selected" : "" %>">
                            <input type="radio" name="paymentMethod" value="COD" <%= "COD".equalsIgnoreCase(selectedPaymentMethod) ? "checked" : "" %>>
                            <div class="checkout-payment-copy">
                                <strong>Thanh to&#225;n khi nh&#7853;n h&#224;ng</strong>
                                <span>Thanh to&#225;n b&#7857;ng ti&#7873;n m&#7863;t khi nh&#7853;n h&#224;ng.</span>
                            </div>
                        </label>

                        <label class="checkout-payment-option <%= "VNPAY".equalsIgnoreCase(selectedPaymentMethod) ? "is-selected" : "" %>">
                            <input type="radio" name="paymentMethod" value="VNPAY" <%= "VNPAY".equalsIgnoreCase(selectedPaymentMethod) ? "checked" : "" %>>
                            <div class="checkout-payment-copy">
                                <strong>Thanh to&#225;n qua VNPAY</strong>
                                <span>L&#432;u l&#7921;a ch&#7885;n thanh to&#225;n VNPAY cho &#273;&#417;n h&#224;ng.</span>
                            </div>
                        </label>
                    </section>

                    <section class="checkout-card">
                        <div class="checkout-section-header">
                            <h2>Ghi ch&#250; &#273;&#417;n h&#224;ng <span>(kh&#244;ng b&#7855;t bu&#7897;c)</span></h2>
                        </div>

                        <div class="checkout-note-field">
                            <textarea
                                name="note"
                                id="note"
                                rows="4"
                                placeholder="Nh&#7853;p ghi ch&#250; cho &#273;&#417;n h&#224;ng..."
                                data-checkout-note><%= h(orderNote) %></textarea>
                            <div class="checkout-note-counter">
                                <span data-checkout-note-count><%= orderNote.length() %></span>/1000
                            </div>
                        </div>
                    </section>

                    <div class="checkout-actions">
                        <a class="checkout-back-link" href="${pageContext.request.contextPath}/cart">
                            &#8592; Quay l&#7841;i gi&#7887; h&#224;ng
                        </a>

                        <button
                            type="submit"
                            class="checkout-submit-btn"
                            <%= canPlaceOrder ? "" : "disabled" %>>
                            Ti&#7871;n h&#224;nh thanh to&#225;n &#8594;
                        </button>
                    </div>
                </form>

                <aside class="checkout-summary-column">
                    <section class="checkout-summary-card">
                        <div class="checkout-section-header">
                            <h2>&#272;&#417;n h&#224;ng c&#7911;a b&#7841;n <span>(<%= checkoutLineCount %> s&#7843;n ph&#7849;m)</span></h2>
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
                                    <%= currencyFormatter.format(item.getLineTotal()) %>&#273;
                                </div>
                            </article>
                            <% } %>
                        </div>

                        <div class="checkout-summary-totals">
                            <div class="checkout-summary-row">
                                <span>T&#7841;m t&#237;nh</span>
                                <strong><%= currencyFormatter.format(checkoutSubtotal) %>&#273;</strong>
                            </div>
                            <div class="checkout-summary-row">
                                <span>Ph&#237; v&#7853;n chuy&#7875;n</span>
                                <strong class="is-free">Mi&#7877;n ph&#237;</strong>
                            </div>
                            <div class="checkout-summary-row total">
                                <span>T&#7893;ng c&#7897;ng</span>
                                <strong><%= currencyFormatter.format(checkoutTotal) %>&#273;</strong>
                            </div>
                        </div>

                        <div class="checkout-summary-benefits">
                            <div class="checkout-benefit">
                                <strong>Th&#244;ng tin b&#7843;o m&#7853;t</strong>
                                <span>Th&#244;ng tin c&#7911;a b&#7841;n &#273;&#432;&#7907;c d&#249;ng cho x&#7917; l&#253; &#273;&#417;n h&#224;ng.</span>
                            </div>
                            <div class="checkout-benefit">
                                <strong>Mi&#7877;n ph&#237; v&#7853;n chuy&#7875;n</strong>
                                <span>&#193;p d&#7909;ng cho c&#225;c &#273;&#417;n h&#224;ng trong khu v&#7921;c H&#242;a L&#7841;c.</span>
                            </div>
                            <div class="checkout-benefit">
                                <strong>H&#7895; tr&#7907; nhanh</strong>
                                <span>C&#243; th&#7875; quay l&#7841;i trang &#273;&#7883;a ch&#7881; giao h&#224;ng &#273;&#7875; th&#234;m m&#7899;i b&#7845;t c&#7913; l&#250;c n&#224;o.</span>
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
                    aria-label="&#272;&#243;ng ch&#7885;n &#273;&#7883;a ch&#7881;">
                    &times;
                </button>

                <div class="checkout-address-dialog-header">
                    <h3 id="checkoutAddressDialogTitle">Ch&#7885;n &#273;&#7883;a ch&#7881; giao h&#224;ng</h3>
                    <p>Ch&#7885;n m&#7897;t &#273;&#7883;a ch&#7881; c&#243; s&#7861;n</p>
                </div>

                <% if (savedAddresses.isEmpty()) { %>
                <div class="checkout-address-empty-panel is-modal">
                    <p>Ch&#432;a c&#243; &#273;&#7883;a ch&#7881; n&#224;o &#273;&#432;&#7907;c l&#432;u trong t&#224;i kho&#7843;n.</p>
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
                        <span class="checkout-address-option-status">&#272;ang ch&#7885;n</span>

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
                        + Th&#234;m m&#7899;i &#273;&#7883;a ch&#7881;
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
