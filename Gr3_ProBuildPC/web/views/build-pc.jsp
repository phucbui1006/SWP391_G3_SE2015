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

    <body class="build-pc-page" style="padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px">
        <jsp:include page="/includes/header.jsp" />

        <main class="build-pc-shell">
            <section class="build-pc-main">
                <div class="build-pc-heading">
                    <div>
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
                    <div class="build-part-row">
                        <div class="build-part-type">
                            <strong><%= escapeHtml(slot.getDisplayName()) %></strong>
                        </div>

                        <div class="build-part-product">
                            <% if (selectedProduct != null && selectedProduct.getImageUrl() != null) { %>
                            <img src="<%= ctx %>/<%= escapeHtml(selectedProduct.getImageUrl()) %>" alt="<%= escapeHtml(selectedProduct.getProductName()) %>">
                            <% } else { %>
                            <div class="build-empty-image" aria-hidden="true"><%= getIcon(slot.getKey()) %></div>
                            <% } %>

                            <div>
                                <% if (selectedProduct != null) { %>
                                <h2><%= escapeHtml(selectedProduct.getProductName()) %></h2>
                                <strong><%= formatMoney(currencyFormatter, selectedProduct.getPrice()) %></strong>
                                <% } else if (slot.isCompatibilityChecked() && slot.getAvailableProducts().isEmpty()) { %>
                                <h2>Chưa thể chọn <%= escapeHtml(slot.getDisplayName()) %></h2>
                                <% } else { %>
                                <h2>Chưa chọn <%= escapeHtml(slot.getDisplayName()) %></h2>
                                <% } %>
                            </div>
                        </div>

                        <div class="build-quick-cell">
                            <% if (selectedProduct != null) { %>
                            <form class="build-quantity" action="<%= ctx %>/build-pc" method="post">
                                <input type="hidden" name="action" value="updateQuantity">
                                <input type="hidden" name="slot" value="<%= escapeHtml(slot.getKey()) %>">
                                <button class="build-qty-btn" type="submit" name="delta" value="-1" aria-label="Giảm số lượng <%= escapeHtml(slot.getDisplayName()) %>">−</button>
                                <input class="build-qty-input" type="number" name="quantity" value="<%= slot.getQuantity() %>" min="1" max="<%= selectedProduct.getQuantity() %>" step="1">
                                <button class="build-qty-btn" type="submit" name="delta" value="1" aria-label="Tăng số lượng <%= escapeHtml(slot.getDisplayName()) %>">+</button>
                            </form>
                            <% } else { %>
                            <button class="build-change-btn build-open-quick-view" type="button"
                                    data-build-modal="build-modal-<%= escapeHtml(slot.getKey()) %>">
                                Xem linh kiện
                            </button>
                            <% } %>
                            <small><%= slot.getAvailableProducts().size() %> sản phẩm phù hợp</small>
                        </div>

                        <div class="build-part-actions">
                            <% if (selectedProduct != null) { %>
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
                            <% } else { %>
                            <span class="build-waiting">Đang trống</span>
                            <% } %>
                        </div>
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
                        <form action="<%= ctx %>/build-pc" method="post">
                            <input type="hidden" name="action" value="addToCart">
                            <button class="build-cart-btn" type="submit">
                                <span aria-hidden="true"><i class="fa-solid fa-cart-shopping"></i></span>
                                Thêm cấu hình vào giỏ hàng
                            </button>
                        </form>
                    </div>
                    </div>
                </div>
            </aside>
        </main>

        <jsp:include page="/includes/footer.jsp" />

        <script>
            document.querySelectorAll(".build-open-quick-view").forEach(function (button) {
                button.addEventListener("click", function () {
                    var modal = document.getElementById(button.getAttribute("data-build-modal"));
                    if (modal) {
                        modal.classList.add("is-open");
                        modal.setAttribute("aria-hidden", "false");
                        document.body.classList.add("build-modal-open");
                    }
                });
            });

            document.querySelectorAll("[data-build-close]").forEach(function (button) {
                button.addEventListener("click", function () {
                    var modal = button.closest(".build-quick-view");
                    if (modal) {
                        modal.classList.remove("is-open");
                        modal.setAttribute("aria-hidden", "true");
                        document.body.classList.remove("build-modal-open");
                    }
                });
            });

            document.addEventListener("keydown", function (event) {
                if (event.key === "Escape") {
                    document.querySelectorAll(".build-quick-view.is-open").forEach(function (modal) {
                        modal.classList.remove("is-open");
                        modal.setAttribute("aria-hidden", "true");
                    });
                    document.body.classList.remove("build-modal-open");
                }
            });
        </script>
    </body>
</html>
