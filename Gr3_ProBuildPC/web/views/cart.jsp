<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.CartItem" %>
<%
    List<CartItem> cartItems = (List<CartItem>) request.getAttribute("cartItems");
    BigDecimal cartSubtotal = (BigDecimal) request.getAttribute("cartSubtotal");
    BigDecimal cartTotal = (BigDecimal) request.getAttribute("cartTotal");

    if (cartItems == null) {
        cartItems = java.util.Collections.emptyList();
    }
    if (cartSubtotal == null) {
        cartSubtotal = BigDecimal.ZERO;
    }
    if (cartTotal == null) {
        cartTotal = BigDecimal.ZERO;
    }

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
        <title>Gi&#7887; h&#224;ng</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body class="cart-page">
        <jsp:include page="/includes/header.jsp" />

        <div class="cart-container">
            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Trang ch&#7911;</a> / <span class="active">gi&#7887; h&#224;ng</span>
            </div>

            <div class="cart-layout">
                <div class="cart-main-column">
                    <div class="cart-list">
                        <div class="cart-header">
                            <div class="col-select">Ch&#7885;n</div>
                            <div class="col-product">S&#7843;n ph&#7849;m</div>
                            <div class="col-price">Gi&#225;</div>
                            <div class="col-qty">S&#7889; l&#432;&#7907;ng</div>
                            <div class="col-total">T&#7893;ng ti&#7873;n</div>
                            <div class="col-action">Thao t&#225;c</div>
                        </div>

                        <% if (cartItems.isEmpty()) { %>
                        <div class="cart-item empty-cart">
                            <div class="empty-cart-message">Gi&#7887; h&#224;ng c&#7911;a b&#7841;n &#273;ang tr&#7889;ng.</div>
                        </div>
                        <% } else { %>
                        <% for (CartItem item : cartItems) { %>
                        <%
                            BigDecimal unitPrice = BigDecimal.ZERO;
                            if (item.getProduct() != null && item.getProduct().getPrice() != null) {
                                unitPrice = item.getProduct().getPrice();
                            }

                            BigDecimal lineTotal = item.getLineTotal();
                            if (lineTotal == null) {
                                lineTotal = unitPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
                            }
                        %>
                        <div
                            class="cart-item"
                            data-cart-item-id="<%= item.getCartItemId() %>"
                            data-unit-price="<%= unitPrice.toPlainString() %>">
                            <div class="col-select">
                                <input
                                    class="cart-select-checkbox"
                                    type="checkbox"
                                    name="selectedCartItemIds"
                                    value="<%= item.getCartItemId() %>"
                                    aria-label="Ch&#7885;n s&#7843;n ph&#7849;m">
                            </div>
                            <div class="col-product">
                                <img src="<%= (item.getProduct() != null && item.getProduct().getImageUrl() != null && !item.getProduct().getImageUrl().trim().isEmpty())
                                        ? item.getProduct().getImageUrl()
                                        : "https://via.placeholder.com/72x72?text=PC" %>"
                                     alt="<%= item.getProduct() != null ? item.getProduct().getProductName() : "Product" %>">
                                <span class="product-name"><%= item.getProduct() != null ? item.getProduct().getProductName() : "S&#7843;n ph&#7849;m" %></span>
                            </div>
                            <div class="col-price line-price-value"><%= currencyFormatter.format(unitPrice) %>&#273;</div>
                            <div class="col-qty">
                                <div class="quantity-input-wrapper">
                                    <input
                                        class="cart-qty-input"
                                        type="number"
                                        value="<%= item.getQuantity() %>"
                                        min="1"
                                        step="1"
                                        inputmode="numeric"
                                        name="quantity_<%= item.getCartItemId() %>">
                                </div>
                            </div>
                            <div class="col-total line-total-value"><%= currencyFormatter.format(lineTotal) %>&#273;</div>
                            <div class="col-action">
                                <form class="cart-action-form" action="${pageContext.request.contextPath}/cart" method="post">
                                    <input type="hidden" name="action" value="removeCartItem">
                                    <input type="hidden" name="cartItemId" value="<%= item.getCartItemId() %>">
                                    <button class="cart-action-btn" type="submit" title="X&#243;a s&#7843;n ph&#7849;m">
                                        <span class="cart-action-icon" aria-hidden="true">
                                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#ef4444" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M3 6h18"></path>
                                                <path d="M8 6V4h8v2"></path>
                                                <path d="M19 6l-1 14H6L5 6"></path>
                                                <path d="M10 11v6"></path>
                                                <path d="M14 11v6"></path>
                                            </svg>
                                        </span>
                                        <span class="cart-action-label">X&#243;a</span>
                                    </button>
                                </form>
                            </div>
                        </div>
                        <% } %>
                        <% } %>
                    </div>
                </div>

                <aside class="cart-summary-column">
                    <div class="cart-total-box">
                        <h3>T&#7893;ng gi&#7887; h&#224;ng</h3>

                        <div class="summary-row">
                            <span>T&#7841;m t&#237;nh:</span>
                            <span data-cart-subtotal><%= currencyFormatter.format(BigDecimal.ZERO) %>&#273;</span>
                        </div>
                        <hr class="divider">
                        <div class="summary-row">
                            <span>Ph&#237; v&#7853;n chuy&#7875;n:</span>
                            <span>Mi&#7877;n ph&#237;</span>
                        </div>
                        <hr class="divider">
                        <div class="summary-row summary-row-total">
                            <span>T&#7893;ng c&#7897;ng:</span>
                            <span data-cart-total><%= currencyFormatter.format(BigDecimal.ZERO) %>&#273;</span>
                        </div>

                        <button type="button" class="checkout-btn">Ti&#7871;n h&#224;nh thanh to&#225;n</button>
                    </div>
                </aside>
            </div>
        </div>

        <script>
            (function () {
                const cartRows = document.querySelectorAll('.cart-item[data-unit-price]');
                const subtotalElement = document.querySelector('[data-cart-subtotal]');
                const totalElement = document.querySelector('[data-cart-total]');
                const headerCartCountElement = document.querySelector('.cart-box .cart-icon span');
                const cartUpdateUrl = '${pageContext.request.contextPath}/cart';
                const persistTimers = new Map();

                if (!cartRows.length || !subtotalElement || !totalElement) {
                    return;
                }

                const currencyFormatter = new Intl.NumberFormat('vi-VN', {
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 0
                });

                const formatCurrency = function (amount) {
                    return currencyFormatter.format(amount) + '\u0111';
                };

                const normalizeQuantity = function (input) {
                    let quantity = parseInt(input.value, 10);

                    if (Number.isNaN(quantity) || quantity < 1) {
                        quantity = 1;
                        input.value = quantity;
                    }

                    return quantity;
                };

                const normalizeAmount = function (amount) {
                    return Math.round(amount);
                };

                const updateCartTotals = function () {
                    let selectedSubtotal = 0;

                    cartRows.forEach(function (row) {
                        const unitPrice = Number(row.dataset.unitPrice) || 0;
                        const quantityInput = row.querySelector('.cart-qty-input');
                        const selectCheckbox = row.querySelector('.cart-select-checkbox');
                        const lineTotalElement = row.querySelector('.line-total-value');
                        const quantity = normalizeQuantity(quantityInput);
                        const lineTotal = normalizeAmount(unitPrice * quantity);

                        lineTotalElement.textContent = formatCurrency(lineTotal);

                        if (selectCheckbox.checked) {
                            selectedSubtotal = normalizeAmount(selectedSubtotal + lineTotal);
                        }
                    });

                    const formattedTotal = formatCurrency(selectedSubtotal);
                    subtotalElement.textContent = formattedTotal;
                    totalElement.textContent = formattedTotal;
                };

                const persistQuantityToDatabase = function (row, quantity) {
                    const cartItemId = row.dataset.cartItemId;
                    const quantityInput = row.querySelector('.cart-qty-input');

                    if (!cartItemId || !quantityInput) {
                        return Promise.resolve();
                    }

                    const payload = new URLSearchParams();
                    payload.set('action', 'updateCartQuantity');
                    payload.set('cartItemId', cartItemId);
                    payload.set('quantity', String(quantity));

                    return fetch(cartUpdateUrl, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: payload.toString()
                    })
                            .then(function (response) {
                                return response.json().then(function (data) {
                                    if (!response.ok) {
                                        throw new Error(data.message || 'Failed to persist cart quantity');
                                    }
                                    return data;
                                });
                            })
                            .then(function (data) {
                                if (typeof data.quantity === 'number' && data.quantity > 0) {
                                    quantityInput.value = data.quantity;
                                }

                                if (headerCartCountElement && typeof data.cartItemCount === 'number') {
                                    headerCartCountElement.textContent = data.cartItemCount;
                                }

                                updateCartTotals();
                            })
                            .catch(function (error) {
                                console.error(error);
                                updateCartTotals();
                            });
                };

                const queueQuantityPersist = function (row, quantity) {
                    const cartItemId = row.dataset.cartItemId;
                    if (!cartItemId) {
                        return;
                    }

                    const existingTimer = persistTimers.get(cartItemId);
                    if (existingTimer) {
                        window.clearTimeout(existingTimer);
                    }

                    const newTimer = window.setTimeout(function () {
                        persistTimers.delete(cartItemId);
                        persistQuantityToDatabase(row, quantity);
                    }, 300);

                    persistTimers.set(cartItemId, newTimer);
                };

                cartRows.forEach(function (row) {
                    const quantityInput = row.querySelector('.cart-qty-input');
                    const selectCheckbox = row.querySelector('.cart-select-checkbox');

                    quantityInput.addEventListener('input', function () {
                        updateCartTotals();
                        queueQuantityPersist(row, normalizeQuantity(quantityInput));
                    });
                    quantityInput.addEventListener('change', function () {
                        updateCartTotals();
                        queueQuantityPersist(row, normalizeQuantity(quantityInput));
                    });
                    selectCheckbox.addEventListener('change', updateCartTotals);
                });

                updateCartTotals();
            })();
        </script>
    </body>
</html>
