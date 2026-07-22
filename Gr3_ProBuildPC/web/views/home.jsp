<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="dal.ProductDAO" %>

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
%>

<%
    String ctx = request.getContextPath();
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Product> products = (List<Product>) request.getAttribute("products");
    ProductDAO productDAO = (ProductDAO) request.getAttribute("productDAO");
    String keyword = (String) request.getAttribute("keyword");
    boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
    Integer totalProductsObj = (Integer) request.getAttribute("totalProducts");
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    int totalProducts = totalProductsObj == null ? 0 : totalProductsObj;
    int startItem = request.getAttribute("startItem") == null ? 0 : (Integer) request.getAttribute("startItem");
    int endItem = request.getAttribute("endItem") == null ? 0 : (Integer) request.getAttribute("endItem");
    int currentPage = currentPageObj == null ? 1 : currentPageObj;
    int totalPages = totalPagesObj == null ? 1 : totalPagesObj;
    int searchResultCount = totalProducts;
    String pagingUrl = ctx + "/home?";
    if (hasKeyword) {
        pagingUrl += "keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&";
    }
    pagingUrl += "page=";
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC</title>
        <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=204">
    </head>

    <body class="home-page" data-context-path="<%= ctx %>">
        <jsp:include page="/includes/header.jsp" />

        <main class="page-shell">
            <aside class="sidebar">
                <h2>DANH MỤC SẢN PHẨM</h2>

                <ul class="category-list">
                    <% if (categories != null) {
                        for (Category category : categories) {
                    %>
                    <li>
                        <a href="<%= ctx %>/categories?id=<%= category.getCategoryId() %>">
                            <%= category.getCategoryName() %>
                        </a>
                    </li>
                    <% }} %>
                </ul>

                <a class="all-categories" href="<%= ctx %>/categories">
                    ▦ Xem tất cả danh mục
                </a>
            </aside>

            <section class="content">
                <section class="hero-banner">
                    <div class="hero-copy">
                        <p>ProBUILD PC</p>
                        <h1>
                            ĐỈNH CAO HIỆU NĂNG<br>
                            NÂNG TẦM TRẢI NGHIỆM
                        </h1>
                        <span>
                            TRỐN NẮNG TRONG PHÒNG - 
                            BUILD PC ĐỈNH DÒNG
                        </span>
                        <a href="<%= ctx %>/build-pc" style="
                           padding-left: 10px;
                           padding-right: 10px;">BUILD NGAY PC <br> BẠN YÊU THÍCH</a>
                    </div>
                </section>

                <section class="service-row">
                    <article>
                        <span><i class="fa-solid fa-shield-halved"></i></span>
                        <div>
                            <strong>Hàng chính hãng</strong>
                            <small>100% chính hãng</small>
                        </div>
                    </article>

                    <article>
                        <span><i class="fa-solid fa-rotate"></i></span>
                        <div>
                            <strong>Bảo hành uy tín</strong>
                            <small>Bảo hành chính hãng</small>
                        </div>
                    </article>

                    <article>
                        <span><i class="fa-solid fa-truck-fast"></i></span>
                        <div>
                            <strong>Giao hàng toàn Thạch Thất</strong>
                            <small>Miễn phí đơn từ 1 triệu</small>
                        </div>
                    </article>

                    <article>
                        <span><i class="fa-solid fa-headset"></i></span>
                        <div>
                            <strong>Hỗ trợ 24/7</strong>
                            <small>Tư vấn tận tâm</small>
                        </div>
                    </article>
                </section>

                <section class="filter-row">
                    <form class="filters" action="<%= ctx %>/categories" method="get">
                        <label>
                            Danh mục:
                            <select name="id">
                                <option value="">Tất cả</option>
                                <% if (categories != null) {
                                    for (Category category : categories) {
                                %>
                                <option value="<%= category.getCategoryId() %>">
                                    <%= category.getCategoryName() %>
                                </option>
                                <% }} %>
                            </select>
                        </label>
                        <button class="home-filter-btn" type="submit">Lọc</button>
                    </form>

                    <form class="sort-box" action="<%= ctx %>/categories" method="get">
                        <label>
                            Sắp xếp:
                            <select name="sort">
                                <option value="newest">Mới nhất</option>
                                <option value="price_asc">Giá tăng dần</option>
                                <option value="price_desc">Giá giảm dần</option>
                            </select>
                        </label>
                        <button class="home-filter-btn" type="submit">Áp dụng</button>
                    </form>
                </section>

                <% if (hasKeyword) { %>
                <div class="home-search-result">
                    <div>
                        <h2>Kết quả tìm kiếm cho "<%= h(keyword) %>"</h2>
                        <p>Tìm thấy <%= searchResultCount %> sản phẩm</p>
                    </div>
                    <a href="<%= ctx %>/home">Xem tất cả sản phẩm</a>
                </div>
                <% } %>

                <section class="product-grid">
                    <% if (products != null && !products.isEmpty()) {
                        for (Product product : products) {
                            double rating = productDAO == null ? 0 : productDAO.getAverageRating(product.getProductId());
                            int fullStars = (int) rating;
                    %>
                    <article class="product-card">
                        <figure>
                            <img src="<%= ctx %>/<%= product.getImageUrl() %>"
                                 alt="<%= product.getProductName() %>">
                        </figure>

                        <h3><%= product.getProductName() %></h3>

                        <strong>
                            <%= String.format("%,d", product.getPrice().longValue()) %>đ
                        </strong>

                        <div class="product-rating">
                            <% for (int i = 1; i <= 5; i++) { %>
                            <i class="<%= i <= fullStars ? "fa-solid" : "fa-regular" %> fa-star"></i>
                            <% } %>
                            <span><%= String.format("%.1f", rating) %></span>
                        </div>

                        <p class="product-stock <%= product.getQuantity() > 0 ? "in-stock" : "out-of-stock" %>">
                            <% if (product.getQuantity() > 0) { %>
                            Còn hàng: <%= product.getQuantity() %>
                            <% } else { %>
                            Hết hàng
                            <% } %>
                        </p>

                        <div class="product-actions">
                            <a class="detail-btn" href="<%= ctx %>/product-detail?id=<%= product.getProductId() %>">
                                Xem chi tiết
                            </a>

                            <form class="cart-form" action="<%= ctx %>/cart" method="post">
                                <input type="hidden" name="action" value="addToCart">
                                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                <input type="hidden" name="quantity" value="1">
                                <button class="cart-btn" type="submit" data-add-to-cart-btn data-product-name="<%= h(product.getProductName()) %>" <%= product.getQuantity() > 0 ? "" : "disabled" %>>
                                    <i class="fa-solid fa-cart-shopping"></i>
                                </button>
                            </form>
                        </div>
                    </article>
                    <% }} else { %>
                    <p class="home-empty-message">
                        <%= hasKeyword ? "Không tìm thấy sản phẩm phù hợp." : "Không có sản phẩm nào để hiển thị." %>
                    </p>
                    <% } %>
                </section>

                <% if (totalPages > 1) { %>
                <div class="home-pagination">
                    <a class="<%= currentPage <= 1 ? "disabled" : "" %>" 
                       href="<%= currentPage <= 1 ? "#" : pagingUrl + (currentPage - 1) %>">&lt;</a>

                    <%
                        int fromPage = Math.max(2, currentPage - 2);
                        int toPage = Math.min(totalPages - 1, currentPage + 2);
                        if (currentPage <= 4) {
                            fromPage = 2;
                            toPage = Math.min(totalPages - 1, 5);
                        } else if (currentPage >= totalPages - 3) {
                            fromPage = Math.max(2, totalPages - 4);
                            toPage = totalPages - 1;
                        }
                    %>
                    <a class="page-btn <%= currentPage == 1 ? "active" : "" %>" href="<%= pagingUrl + 1 %>">1</a>
                    <% if (fromPage > 2) { %>
                    <span class="page-btn disabled">...</span>
                    <% } %>
                    <% for (int i = fromPage; i <= toPage; i++) { %>
                    <a class="page-btn <%= currentPage == i ? "active" : "" %>" href="<%= pagingUrl + i %>">
                        <%= i %>
                    </a>
                    <% } %>
                    <% if (toPage < totalPages - 1) { %>
                    <span class="page-btn disabled">...</span>
                    <% } %>
                    <% if (totalPages > 1) { %>
                    <a class="page-btn <%= currentPage == totalPages ? "active" : "" %>" href="<%= pagingUrl + totalPages %>">
                        <%= totalPages %>
                    </a>
                    <% } %>

                    <a class="<%= currentPage >= totalPages ? "disabled" : "" %>" 
                       href="<%= currentPage >= totalPages ? "#" : pagingUrl + (currentPage + 1) %>">&gt;</a>
                </div>
                <% } %>
            </section>
        </main>

        <div class="home-toast" data-home-toast hidden>
            <div class="home-toast-icon" data-home-toast-icon aria-hidden="true">+</div>
            <div class="home-toast-message" data-home-toast-message></div>
        </div>

        <jsp:include page="/includes/footer.jsp" />

        <script src="<%= ctx %>/js/cart.js"></script>
    </body>
</html>
