<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.BuildPCSlot" %>
<%@ page import="model.Product" %>

<%!
    private String formatMoney(NumberFormat formatter, BigDecimal value) {
        if (value == null) {
            return "0đ";
        }
        return formatter.format(value) + "đ";
    }

    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String getIcon(String key) {
        if ("CPU".equals(key)) {
            return "▣";
        } else if ("Mainboard".equals(key)) {
            return "▤";
        } else if ("RAM".equals(key)) {
            return "▰";
        } else if ("GPU".equals(key)) {
            return "▧";
        } else if ("SSD".equals(key)) {
            return "▯";
        } else if ("Case".equals(key)) {
            return "▥";
        } else if ("Monitor".equals(key)) {
            return "▱";
        } else if ("Keyboard".equals(key)) {
            return "⌨";
        } else if ("Mouse".equals(key)) {
            return "◉";
        }
        return "◈";
    }

    private String getPlaceholderImage(String key) {
        if ("CPU".equals(key)) {
            return "images/buildPC/CPU.png";
        } else if ("Mainboard".equals(key)) {
            return "images/buildPC/MainBoard.png";
        } else if ("GPU".equals(key)) {
            return "images/buildPC/GPU.png";
        } else if ("RAM".equals(key)) {
            return "images/buildPC/RAM.png";
        } else if ("SSD".equals(key)) {
            return "images/buildPC/SSD.png";
        } else if ("Case".equals(key)) {
            return "images/buildPC/VỏCase.png";
        } else if ("Monitor".equals(key)) {
            return "images/buildPC/Screen.png";
        } else if ("Keyboard".equals(key)) {
            return "images/buildPC/KeyBoard.png";
        } else if ("Mouse".equals(key)) {
            return "images/buildPC/Mouse.png";
        }
        return "";
    }

    private String getEmptySlotLabel(BuildPCSlot slot) {
        String key = slot.getKey();
        if ("CPU".equals(key)) {
            return "CPU";
        } else if ("Mainboard".equals(key)) {
            return "Mainboard";
        } else if ("GPU".equals(key)) {
            return "Card màn hình";
        } else if ("RAM".equals(key)) {
            return "RAM";
        } else if ("SSD".equals(key)) {
            return "Ổ cứng SSD";
        } else if ("Case".equals(key)) {
            return "Vỏ Case";
        } else if ("Monitor".equals(key)) {
            return "Màn hình";
        } else if ("Keyboard".equals(key)) {
            return "Bàn phím";
        } else if ("Mouse".equals(key)) {
            return "Chuột";
        }
        return slot.getDisplayName();
    }
%>

<%
    String ctx = request.getContextPath();
    Locale vietnameseLocale = new Locale("vi", "VN");
    NumberFormat currencyFormatter = NumberFormat.getNumberInstance(vietnameseLocale);
    currencyFormatter.setMinimumFractionDigits(0);
    currencyFormatter.setMaximumFractionDigits(0);

    List<BuildPCSlot> buildSlots = (List<BuildPCSlot>) request.getAttribute("buildSlots");
    BigDecimal buildTotal = (BigDecimal) request.getAttribute("buildTotal");
    String buildPcMessage = (String) request.getAttribute("buildPcMessage");
    String buildPcMessageType = (String) request.getAttribute("buildPcMessageType");
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Build PC - ProBuild PC</title>
        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    </head>

    <body class="build-pc-page" data-context-path="<%= ctx %>" style="padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px">
        <jsp:include page="/includes/header.jsp" />

        <main class="build-pc-shell">
            <section class="build-pc-main">
                <nav class="build-breadcrumb site-breadcrumb" aria-label="Breadcrumb">
                    <a href="<%= ctx %>/home">Trang chủ</a>
                    <span>›</span>
                    <strong>Build PC</strong>
                </nav>

                <div class="build-pc-heading">
                    <div class="headerBuild" style="text-center">
                        <h1>BUILD PC</h1>
                        <p>Tự tay lựa chọn linh kiện để tạo nên cấu hình PC theo nhu cầu của bạn.</p>
                    </div>

                    <form action="<%= ctx %>/build-pc" method="post">
                        <input type="hidden" name="action" value="clear">
                        <button class="build-clear-btn" type="submit">Reset cấu hình</button>
                    </form>
                </div>

                <% if (buildPcMessage != null) { %>
                <div class="build-message <%= "success".equals(buildPcMessageType) ? "is-success" : "is-error" %>">
                    <%= escapeHtml(buildPcMessage) %>
                </div>
                <% } %>

                <div class="build-part-list">
                    <% if (buildSlots != null) { %>
                    <% for (BuildPCSlot slot : buildSlots) { %>
                    <% Product selectedProduct = slot.getSelectedProduct(); %>
                    <div class="build-part-row <%= selectedProduct == null ? "is-empty" : "" %>">
                        <% if (selectedProduct == null) { %>
                        <div class="build-empty-slot-main">
                            <img class="build-slot-placeholder"
                                 src="<%= ctx %>/<%= escapeHtml(getPlaceholderImage(slot.getKey())) %>"
                                 alt="<%= escapeHtml(getEmptySlotLabel(slot)) %>">
                            <strong><%= escapeHtml(getEmptySlotLabel(slot)) %></strong>
                        </div>

                        <button class="build-empty-choose build-open-quick-view" type="button"
                                data-build-modal="build-modal-<%= escapeHtml(slot.getKey()) %>">
                            Chọn
                        </button>
                        <% } else { %>
                        <div class="build-part-type">
                            <strong><%= escapeHtml(slot.getDisplayName()) %></strong>
                        </div>

                        <div class="build-part-product">
                            <% if (selectedProduct.getImageUrl() != null) { %>
                            <img src="<%= ctx %>/<%= escapeHtml(selectedProduct.getImageUrl()) %>" alt="<%= escapeHtml(selectedProduct.getProductName()) %>">
                            <% } else { %>
                            <div class="build-empty-image" aria-hidden="true"><%= getIcon(slot.getKey()) %></div>
                            <% } %>

                            <div>
                                <h2><%= escapeHtml(selectedProduct.getProductName()) %></h2>
                                <strong><%= formatMoney(currencyFormatter, selectedProduct.getPrice()) %></strong>
                            </div>
                        </div>

                        <div class="build-quick-cell">
                            <form class="build-quantity" action="<%= ctx %>/build-pc" method="post">
                                <input type="hidden" name="action" value="updateQuantity">
                                <input type="hidden" name="slot" value="<%= escapeHtml(slot.getKey()) %>">
                                <input class="build-qty-input"
                                       type="number"
                                       name="quantity"
                                       value="<%= slot.getQuantity() %>"
                                       min="1"
                                       max="<%= selectedProduct.getQuantity() %>"
                                       step="1"
                                       inputmode="numeric"
                                       autocomplete="off"
                                       data-max-quantity="<%= selectedProduct.getQuantity() %>">
                            </form>
                            <small><%= slot.getAvailableProducts().size() %> sản phẩm phù hợp</small>
                        </div>

                        <div class="build-part-actions">
                            <button class="build-detail-link build-open-quick-view" type="button"
                                    data-build-modal="build-modal-<%= escapeHtml(slot.getKey()) %>">
                                Thay đổi
                            </button>
                            <form action="<%= ctx %>/build-pc" method="post">
                                <input type="hidden" name="action" value="remove">
                                <input type="hidden" name="slot" value="<%= escapeHtml(slot.getKey()) %>">
                                <button class="build-delete-btn" type="submit" title="Xóa <%= escapeHtml(slot.getDisplayName()) %>">
                                    Xóa
                                </button>
                            </form>
                            <a class="build-detail-link" href="<%= ctx %>/product-detail?id=<%= selectedProduct.getProductId() %>">
                                Xem chi tiết
                            </a>
                        </div>
                        <% } %>
                    </div>

                    <div class="build-quick-view" id="build-modal-<%= escapeHtml(slot.getKey()) %>" aria-hidden="true">
                        <div class="build-quick-backdrop" data-build-close></div>
                        <section class="build-quick-dialog" role="dialog" aria-modal="true" aria-labelledby="build-title-<%= escapeHtml(slot.getKey()) %>">
                            <header class="build-quick-header">
                                <div>
                                    <span><%= escapeHtml(slot.getDisplayName()) %></span>
                                    <h2 id="build-title-<%= escapeHtml(slot.getKey()) %>">Chọn linh kiện</h2>
                                </div>
                                <button class="build-quick-close" type="button" aria-label="Đóng quick view" data-build-close>×</button>
                            </header>

                            <% if (slot.getAvailableProducts().isEmpty()) { %>
                            <div class="build-quick-empty">
                                Chưa có sản phẩm phù hợp với cấu hình hiện tại.
                            </div>
                            <% } else { %>
                            <div class="build-quick-grid">
                                <% for (Product product : slot.getAvailableProducts()) { %>
                                <article class="build-quick-card <%= selectedProduct != null && selectedProduct.getProductId() == product.getProductId() ? "is-selected" : "" %>">
                                    <div class="build-quick-image">
                                        <% if (product.getImageUrl() != null) { %>
                                        <img src="<%= ctx %>/<%= escapeHtml(product.getImageUrl()) %>" alt="<%= escapeHtml(product.getProductName()) %>">
                                        <% } else { %>
                                        <span aria-hidden="true"><%= getIcon(slot.getKey()) %></span>
                                        <% } %>
                                    </div>
                                    <div class="build-quick-info">
                                        <h3><%= escapeHtml(product.getProductName()) %></h3>
                                        <p><%= escapeHtml(product.getBrandName()) %></p>
                                        <strong><%= formatMoney(currencyFormatter, product.getPrice()) %></strong>
                                    </div>
                                    <div class="build-quick-actions">
                                        <form action="<%= ctx %>/build-pc" method="post">
                                            <input type="hidden" name="action" value="select">
                                            <input type="hidden" name="slot" value="<%= escapeHtml(slot.getKey()) %>">
                                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                            <button class="build-quick-select" type="submit">
                                                <%= selectedProduct != null && selectedProduct.getProductId() == product.getProductId() ? "Đang chọn" : "Chọn" %>
                                            </button>
                                        </form>
                                        <a class="build-quick-detail" href="<%= ctx %>/product-detail?id=<%= product.getProductId() %>">
                                            Xem chi tiết
                                        </a>
                                    </div>
                                </article>
                                <% } %>
                            </div>
                            <% } %>
                        </section>
                    </div>
                    <% } %>
                    <% } %>
                </div>
            </section>

            <aside class="build-summary">
                <div class="build-summary-card">
                    <h2>TỔNG TIỀN</h2>
                    <strong class="build-total" data-build-total><%= formatMoney(currencyFormatter, buildTotal) %></strong>

                    <div class="build-cart-action">
                        <form class="build-add-cart-form cart-form" action="<%= ctx %>/build-pc" method="post">
                            <input type="hidden" name="action" value="addToCart">
                            <button class="build-cart-btn" type="submit" data-add-to-cart-btn data-product-name="Cấu hình Build PC">
                                <span aria-hidden="true"><i class="fa-solid fa-cart-shopping"></i></span>
                                Thêm cấu hình vào giỏ hàng
                            </button>
                        </form>
                    </div>
                </div>
            </aside>
        </main>

        <jsp:include page="/includes/footer.jsp" />

        <div class="home-toast" data-home-toast hidden>
            <div class="home-toast-icon" data-home-toast-icon aria-hidden="true">+</div>
            <div class="home-toast-message" data-home-toast-message></div>
        </div>

        <script src="<%= ctx %>/js/validator.js"></script>
        <script src="<%= ctx %>/js/build-pc.js"></script>
        <script src="<%= ctx %>/js/cart.js"></script>
    </body>
</html>
