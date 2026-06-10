<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.CartItem" %>
<%!
    private String escapeHtmlAttribute(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }

    private String defaultText(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }
%>
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

            <% if (request.getAttribute("cartSuccessMsg") != null) { %>
            <div class="alert-message alert-success cart-feedback">
                <%= request.getAttribute("cartSuccessMsg") %>
            </div>
            <% } %>

            <% if (request.getAttribute("cartErrorMsg") != null) { %>
            <div class="alert-message alert-danger cart-feedback">
                <%= request.getAttribute("cartErrorMsg") %>
            </div>
            <% } %>

            <div class="cart-page-heading">
                <div class="cart-page-title">Gi&#7887; h&#224;ng c&#7911;a b&#7841;n</div>

                <div class="cart-group-toggle" aria-label="Tuy chon nhom san pham">
                    <button
                        type="button"
                        class="cart-group-btn is-active"
                        data-group-mode="brand"
                        aria-pressed="true"
                        <%= cartItems.isEmpty() ? "disabled" : "" %>>
                        Nh&#243;m theo Brand
                    </button>
                    <button
                        type="button"
                        class="cart-group-btn"
                        data-group-mode="category"
                        aria-pressed="false"
                        <%= cartItems.isEmpty() ? "disabled" : "" %>>
                        Nh&#243;m theo Category
                    </button>
                </div>
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
                            <div class="empty-cart-content">
                                <div class="empty-cart-message">Gi&#7887; h&#224;ng c&#7911;a b&#7841;n &#273;ang tr&#7889;ng.</div>
                                <a class="empty-cart-link" href="${pageContext.request.contextPath}/home">
                                    B&#7855;t &#273;&#7847;u mua s&#7855;m
                                </a>
                            </div>
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

                            String productName = item.getProduct() != null
                                    ? defaultText(item.getProduct().getProductName(), "San pham")
                                    : "San pham";
                            String productDescription = item.getProduct() != null
                                    ? defaultText(item.getProduct().getDescription(), "Chua co chi tiet san pham.")
                                    : "Chua co chi tiet san pham.";
                            String brandName = item.getProduct() != null
                                    ? defaultText(item.getProduct().getBrandName(), "Khac")
                                    : "Khac";
                            String categoryName = item.getProduct() != null
                                    ? defaultText(item.getProduct().getCategoryName(), "Khac")
                                    : "Khac";
                            int stockQuantity = item.getProduct() != null ? item.getProduct().getQuantity() : 0;
                            int warrantyMonths = item.getProduct() != null ? item.getProduct().getWarrantyMonths() : 0;
                            boolean availableForSale = item.getProduct() != null && item.getProduct().isAvailableForSale();
                        %>
                        <div
                            class="cart-item"
                            data-cart-item-id="<%= item.getCartItemId() %>"
                            data-unit-price="<%= unitPrice.toPlainString() %>"
                            data-brand-name="<%= escapeHtmlAttribute(brandName) %>"
                            data-category-name="<%= escapeHtmlAttribute(categoryName) %>">
                            <div class="col-select">
                                <input
                                    class="cart-select-checkbox"
                                    type="checkbox"
                                    name="selectedCartItemIds"
                                    value="<%= item.getCartItemId() %>"
                                    <%= availableForSale ? "" : "disabled" %>
                                    aria-label="Ch&#7885;n s&#7843;n ph&#7849;m">
                            </div>
                            <div class="col-product">
                                <img src="<%= (item.getProduct() != null && item.getProduct().getImageUrl() != null && !item.getProduct().getImageUrl().trim().isEmpty())
                                        ? item.getProduct().getImageUrl()
                                        : "https://via.placeholder.com/72x72?text=PC" %>"
                                     alt="<%= productName %>">
                                <button
                                    type="button"
                                    class="product-name quick-view-trigger"
                                    data-product-name="<%= escapeHtmlAttribute(productName) %>"
                                    data-product-description="<%= escapeHtmlAttribute(productDescription) %>"
                                    data-brand-name="<%= escapeHtmlAttribute(brandName) %>"
                                    data-category-name="<%= escapeHtmlAttribute(categoryName) %>"
                                    data-stock-quantity="<%= stockQuantity %>"
                                    data-warranty-months="<%= warrantyMonths %>"
                                    data-unit-price="<%= unitPrice.toPlainString() %>">
                                    <%= productName %>
                                </button>
                                <% if (!availableForSale) { %>
                                <div class="cart-unavailable-note">Sản phẩm hiện không còn kinh doanh</div>
                                <% } %>
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
                                        <%= availableForSale ? "" : "disabled" %>
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

                        <button
                            type="button"
                            class="checkout-btn"
                            data-checkout-button
                            <%= cartItems.isEmpty() ? "disabled" : "" %>>
                            Ti&#7871;n h&#224;nh thanh to&#225;n
                        </button>
                    </div>
                </aside>
            </div>
        </div>

        <div class="cart-quick-view-backdrop" data-quick-view-backdrop hidden>
            <div class="cart-quick-view-modal" role="dialog" aria-modal="true" aria-labelledby="cartQuickViewTitle">
                <button type="button" class="cart-quick-view-close" data-quick-view-close aria-label="Dong xem nhanh">
                    &times;
                </button>

                <div class="cart-quick-view-layout">
                    <div class="cart-quick-view-media">
                        <div class="cart-quick-view-image-shell">
                            <img
                                class="cart-quick-view-image"
                                data-quick-view-image
                                src="https://via.placeholder.com/320x320?text=PC"
                                alt="San pham">
                        </div>

                        <div class="cart-quick-view-stock-pill is-in-stock" data-quick-view-stock-pill>
                            C&#242;n h&#224;ng: 0
                        </div>
                    </div>

                    <div class="cart-quick-view-content">
                        <div class="cart-quick-view-header">
                            <span class="cart-quick-view-eyebrow">Xem nhanh</span>
                            <h3 id="cartQuickViewTitle" data-quick-view-title>T&#234;n s&#7843;n ph&#7849;m</h3>
                        </div>

                        <div class="cart-quick-view-price-panel">
                            <span class="cart-quick-view-label">Gi&#225; hi&#7879;n t&#7841;i</span>
                            <strong class="cart-quick-view-price" data-quick-view-price>0&#273;</strong>
                        </div>

                        <div class="cart-quick-view-grid">
                            <div class="cart-quick-view-item">
                                <span class="cart-quick-view-label">Brand</span>
                                <strong data-quick-view-brand>Khac</strong>
                            </div>

                            <div class="cart-quick-view-item">
                                <span class="cart-quick-view-label">Category</span>
                                <strong data-quick-view-category>Khac</strong>
                            </div>

                            <div class="cart-quick-view-item">
                                <span class="cart-quick-view-label">S&#7889; l&#432;&#7907;ng c&#242;n l&#7841;i</span>
                                <strong data-quick-view-stock>0</strong>
                            </div>

                            <div class="cart-quick-view-item">
                                <span class="cart-quick-view-label">Th&#7901;i gian b&#7843;o h&#224;nh</span>
                                <strong data-quick-view-warranty>0 th&#225;ng</strong>
                            </div>
                        </div>

                        <div class="cart-quick-view-section">
                            <div class="cart-quick-view-label">Chi ti&#7871;t s&#7843;n ph&#7849;m</div>
                            <p class="cart-quick-view-description" data-quick-view-description>Chua co chi tiet san pham.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            (function () {
                const cartRows = document.querySelectorAll('.cart-item[data-unit-price]');
                const cartListElement = document.querySelector('.cart-list');
                const groupButtons = document.querySelectorAll('[data-group-mode]');
                const quickViewTriggers = document.querySelectorAll('.quick-view-trigger');
                const quickViewBackdrop = document.querySelector('[data-quick-view-backdrop]');
                const quickViewCloseButton = document.querySelector('[data-quick-view-close]');
                const quickViewImage = document.querySelector('[data-quick-view-image]');
                const quickViewStockPill = document.querySelector('[data-quick-view-stock-pill]');
                const quickViewTitle = document.querySelector('[data-quick-view-title]');
                const quickViewDescription = document.querySelector('[data-quick-view-description]');
                const quickViewBrand = document.querySelector('[data-quick-view-brand]');
                const quickViewCategory = document.querySelector('[data-quick-view-category]');
                const quickViewStock = document.querySelector('[data-quick-view-stock]');
                const quickViewWarranty = document.querySelector('[data-quick-view-warranty]');
                const quickViewPrice = document.querySelector('[data-quick-view-price]');
                const subtotalElement = document.querySelector('[data-cart-subtotal]');
                const totalElement = document.querySelector('[data-cart-total]');
                const checkoutButton = document.querySelector('[data-checkout-button]');
                const headerCartCountElement = document.querySelector('.cart-box .cart-icon span');
                const cartUpdateUrl = '${pageContext.request.contextPath}/cart';
                const persistTimers = new Map();

                if (!subtotalElement || !totalElement || !checkoutButton) {
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

                const closeQuickView = function () {
                    if (!quickViewBackdrop) {
                        return;
                    }

                    quickViewBackdrop.classList.remove('is-open');
                    document.body.classList.remove('quick-view-open');

                    window.setTimeout(function () {
                        if (!quickViewBackdrop.classList.contains('is-open')) {
                            quickViewBackdrop.hidden = true;
                        }
                    }, 180);
                };

                const openQuickView = function (triggerButton) {
                    if (!quickViewBackdrop || !triggerButton) {
                        return;
                    }

                    const stockQuantity = Number(triggerButton.dataset.stockQuantity) || 0;
                    const warrantyMonths = Number(triggerButton.dataset.warrantyMonths) || 0;
                    const price = Number(triggerButton.dataset.unitPrice) || 0;
                    const brandName = triggerButton.dataset.brandName || 'Khac';
                    const categoryName = triggerButton.dataset.categoryName || 'Khac';
                    const productName = triggerButton.dataset.productName || 'San pham';
                    const productImage = triggerButton.closest('.col-product')
                            ? triggerButton.closest('.col-product').querySelector('img')
                            : null;

                    if (quickViewTitle) {
                        quickViewTitle.textContent = productName;
                    }

                    if (quickViewImage) {
                        quickViewImage.src = productImage ? productImage.src : 'https://via.placeholder.com/320x320?text=PC';
                        quickViewImage.alt = productName;
                    }

                    if (quickViewDescription) {
                        quickViewDescription.textContent = triggerButton.dataset.productDescription || 'Chua co chi tiet san pham.';
                    }

                    if (quickViewBrand) {
                        quickViewBrand.textContent = brandName;
                    }

                    if (quickViewCategory) {
                        quickViewCategory.textContent = categoryName;
                    }

                    if (quickViewStock) {
                        quickViewStock.textContent = String(stockQuantity);
                    }

                    if (quickViewStockPill) {
                        quickViewStockPill.textContent = stockQuantity > 0
                                ? 'Con hang: ' + stockQuantity
                                : 'Tam het hang';
                        quickViewStockPill.classList.toggle('is-in-stock', stockQuantity > 0);
                        quickViewStockPill.classList.toggle('is-out-of-stock', stockQuantity <= 0);
                    }

                    if (quickViewWarranty) {
                        quickViewWarranty.textContent = warrantyMonths + ' thang';
                    }

                    if (quickViewPrice) {
                        quickViewPrice.textContent = formatCurrency(price);
                    }

                    quickViewBackdrop.hidden = false;
                    document.body.classList.add('quick-view-open');

                    window.requestAnimationFrame(function () {
                        quickViewBackdrop.classList.add('is-open');
                    });

                    if (quickViewCloseButton) {
                        quickViewCloseButton.focus();
                    }
                };

                const setActiveGroupButton = function (mode) {
                    groupButtons.forEach(function (button) {
                        const isActive = button.dataset.groupMode === mode;
                        button.classList.toggle('is-active', isActive);
                        button.setAttribute('aria-pressed', isActive ? 'true' : 'false');
                    });
                };

                const renderGroupedRows = function (mode) {
                    if (!cartRows.length || !cartListElement) {
                        return;
                    }

                    cartListElement.querySelectorAll('.cart-group-section').forEach(function (section) {
                        section.remove();
                    });

                    const groupLabel = mode === 'category' ? 'Category' : 'Brand';
                    const groupedRows = new Map();

                    cartRows.forEach(function (row) {
                        const rawGroupName = mode === 'category' ? row.dataset.categoryName : row.dataset.brandName;
                        const groupName = rawGroupName && rawGroupName.trim() ? rawGroupName.trim() : 'Khac';

                        if (!groupedRows.has(groupName)) {
                            groupedRows.set(groupName, []);
                        }

                        groupedRows.get(groupName).push(row);
                    });

                    groupedRows.forEach(function (rows, groupName) {
                        const section = document.createElement('section');
                        section.className = 'cart-group-section';

                        const heading = document.createElement('div');
                        heading.className = 'cart-group-heading';

                        const title = document.createElement('div');
                        title.className = 'cart-group-title';
                        title.textContent = groupLabel + ': ' + groupName;

                        const meta = document.createElement('div');
                        meta.className = 'cart-group-meta';
                        meta.textContent = rows.length + ' san pham';

                        heading.appendChild(title);
                        heading.appendChild(meta);
                        section.appendChild(heading);

                        rows.forEach(function (row) {
                            section.appendChild(row);
                        });

                        cartListElement.appendChild(section);
                    });
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
                    checkoutButton.disabled = selectedSubtotal <= 0;
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

                groupButtons.forEach(function (button) {
                    button.addEventListener('click', function () {
                        if (button.disabled) {
                            return;
                        }

                        const mode = button.dataset.groupMode || 'brand';
                        setActiveGroupButton(mode);
                        renderGroupedRows(mode);
                    });
                });

                quickViewTriggers.forEach(function (triggerButton) {
                    triggerButton.addEventListener('click', function () {
                        openQuickView(triggerButton);
                    });
                });

                if (quickViewBackdrop) {
                    quickViewBackdrop.addEventListener('click', function (event) {
                        if (event.target === quickViewBackdrop) {
                            closeQuickView();
                        }
                    });
                }

                if (quickViewCloseButton) {
                    quickViewCloseButton.addEventListener('click', closeQuickView);
                }

                document.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape' && quickViewBackdrop && !quickViewBackdrop.hidden) {
                        closeQuickView();
                    }
                });

                checkoutButton.addEventListener('click', function () {
                    if (checkoutButton.disabled) {
                        return;
                    }

                    const selectedIds = [];

                    cartRows.forEach(function (row) {
                        const checkbox = row.querySelector('.cart-select-checkbox');
                        if (checkbox && checkbox.checked) {
                            selectedIds.push(checkbox.value);
                        }
                    });

                    if (!selectedIds.length) {
                        return;
                    }

                    const params = new URLSearchParams();
                    selectedIds.forEach(function (cartItemId) {
                        params.append('selectedCartItemIds', cartItemId);
                    });

                    window.location.href = cartUpdateUrl.replace('/cart', '/checkout') + '?' + params.toString();
                });

                setActiveGroupButton('brand');
                renderGroupedRows('brand');
                updateCartTotals();
            })();
        </script>
    </body>
</html>
