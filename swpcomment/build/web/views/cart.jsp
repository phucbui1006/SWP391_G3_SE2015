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

    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(Locale.US);
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Giỏ hàng</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body class="cart-page">
        <jsp:include page="/includes/header.jsp" />

        <div class="cart-container">
            <div class="breadcrumb">
                <span>Trang chủ</span> / <span class="active">giỏ hàng</span>
            </div>

            <div class="cart-list">
                <div class="cart-header">
                    <div class="col-product">Sản phẩm</div>
                    <div class="col-price">Giá</div>
                    <div class="col-qty">Số lượng</div>
                    <div class="col-total">Tổng tiền</div>
                </div>

                <% if (cartItems.isEmpty()) { %>
                <div class="cart-item empty-cart">
                    <div class="col-product">Giỏ hàng của bạn đang trống.</div>
                    <div class="col-price"></div>
                    <div class="col-qty"></div>
                    <div class="col-total"></div>
                </div>
                <% } else { %>
                <% for (CartItem item : cartItems) { %>
                <div class="cart-item">
                    <div class="col-product">
                        <button class="remove-btn" type="button" title="Xóa sản phẩm">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#df4444" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10" fill="#df4444" stroke="none"></circle>
                                <line x1="15" y1="9" x2="9" y2="15" stroke="#fff"></line>
                                <line x1="9" y1="9" x2="15" y2="15" stroke="#fff"></line>
                            </svg>
                        </button>
                        <img src="<%= (item.getProduct() != null && item.getProduct().getImageUrl() != null && !item.getProduct().getImageUrl().trim().isEmpty())
                                ? item.getProduct().getImageUrl()
                                : "https://via.placeholder.com/72x72?text=PC" %>"
                             alt="<%= item.getProduct() != null ? item.getProduct().getProductName() : "Product" %>">
                        <span class="product-name"><%= item.getProduct() != null ? item.getProduct().getProductName() : "Sản phẩm" %></span>
                    </div>
                    <div class="col-price"><%= currencyFormatter.format(item.getProduct().getPrice()) %></div>
                    <div class="col-qty">
                        <div class="quantity-input-wrapper">
                            <input type="number" value="<%= item.getQuantity() %>" min="1" name="quantity_<%= item.getCartItemId() %>">
                        </div>
                    </div>
                    <div class="col-total"><%= currencyFormatter.format(item.getLineTotal()) %></div>
                </div>
                <% } %>
                <% } %>
            </div>

            <div class="cart-footer">
                <div class="cart-total-box">
                    <h3>Cart Total</h3>

                    <div class="summary-row">
                        <span>Subtotal:</span>
                        <span><%= currencyFormatter.format(cartSubtotal) %></span>
                    </div>
                    <hr class="divider">
                    <div class="summary-row">
                        <span>Shipping:</span>
                        <span>Free</span>
                    </div>
                    <hr class="divider">
                    <div class="summary-row">
                        <span>Total:</span>
                        <span><%= currencyFormatter.format(cartTotal) %></span>
                    </div>

                    <button type="button" class="checkout-btn">Proceed to checkout</button>
                </div>
            </div>
        </div>
    </body>
</html>
