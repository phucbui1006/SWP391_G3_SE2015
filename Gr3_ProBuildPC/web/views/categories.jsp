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
    Category selectedCategory = (Category) request.getAttribute("selectedCategory");
    ProductDAO productDAO = new ProductDAO();

    String selectedSort = (String) request.getAttribute("selectedSort");
    if (selectedSort == null || selectedSort.trim().isEmpty()) {
        selectedSort = "newest";
    }

    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) {
        keyword = "";
    }
    String contentKeyword = (String) request.getAttribute("contentKeyword");
    if (contentKeyword == null) {
        contentKeyword = "";
    }

    String title = "Tất cả sản phẩm";
    if (selectedCategory != null) {
        title = "Danh mục: " + selectedCategory.getCategoryName();
    }

    String cartMessage = (String) request.getAttribute("cartMessage");
    String cartMessageType = (String) request.getAttribute("cartMessageType");
    if (cartMessageType == null) {
        cartMessageType = "success";
    }

    Integer totalProductsObj = (Integer) request.getAttribute("totalProducts");
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");

    int totalProducts = totalProductsObj == null ? 0 : totalProductsObj;
    int currentPage = currentPageObj == null ? 1 : currentPageObj;
    int totalPages = totalPagesObj == null ? 1 : totalPagesObj;

    String searchValue = contentKeyword == null ? "" : contentKeyword
            .replace("&", "&amp;")
            .replace("\"", "&quot;")
            .replace("<", "&lt;")
            .replace(">", "&gt;");

    String clearSearchUrl = ctx + "/categories?";
    if (selectedCategory != null) {
        clearSearchUrl += "id=" + selectedCategory.getCategoryId() + "&";
    }
    clearSearchUrl += "sort=" + selectedSort;

    String pagingUrl = ctx + "/categories?";
    if (selectedCategory != null) {
        pagingUrl += "id=" + selectedCategory.getCategoryId() + "&";
    }
    if (keyword != null && !keyword.trim().isEmpty()) {
        pagingUrl += "keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&";
    }
    if (contentKeyword != null && !contentKeyword.trim().isEmpty()) {
        pagingUrl += "contentKeyword=" + URLEncoder.encode(contentKeyword, "UTF-8") + "&";
    }
    pagingUrl += "sort=" + selectedSort + "&page=";
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Danh mục sản phẩm - ProBuild PC</title>
        <meta name="description" content="Khám phá và so sánh các danh mục linh kiện máy tính chất lượng cao tại ProBuild PC. Tự tạo cấu hình PC chuyên nghiệp dễ dàng.">
        <link rel="stylesheet" href="<%= ctx %>/css/style.css?v=2">
        <link rel="stylesheet" href="<%= ctx %>/css/categories.css?v=52">
    </head>
    <body class="categories-page" data-context-path="<%= ctx %>">
        <jsp:include page="/includes/header.jsp" />

        <main class="category-page">
            <% if (cartMessage != null && !cartMessage.trim().isEmpty()) { %>
            <div class="server-message <%= "error".equals(cartMessageType) ? "error" : "success" %>">
                <%= cartMessage %>
            </div>
            <% } %>

            <nav class="category-breadcrumb" aria-label="Breadcrumb">
                <a href="<%= ctx %>/home">Trang chủ</a>
                <span>›</span>
                <strong>Danh mục sản phẩm</strong>
            </nav>

            <section class="category-heading">
                <div>
                    <h1>Danh mục sản phẩm</h1>
                    <p>Lựa chọn linh kiện theo từng nhóm sản phẩm</p>
                </div>
            </section>

            <section class="category-layout">
                <aside class="category-sidebar" aria-label="Bộ lọc danh mục">
                    <form action="<%= ctx %>/categories" method="get" class="category-filter-form">
                        <input type="hidden" name="sort" value="<%= selectedSort %>">
                        <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                        <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                        <% } %>
                        <% if (contentKeyword != null && !contentKeyword.trim().isEmpty()) { %>
                        <input type="hidden" name="contentKeyword" value="<%= searchValue %>">
                        <% } %>

                        <div class="filter-panel">
                            <div class="filter-title">
                                <h2>Danh mục</h2>
                                <span>−</span>
                            </div>

                            <label class="<%= selectedCategory == null ? "is-checked" : "" %>">
                                <input type="radio" name="id" value="" <%= selectedCategory == null ? "checked" : "" %>>
                                Tất cả sản phẩm
                            </label>

                            <% if (categories != null && !categories.isEmpty()) { %>
                                <% for (Category c : categories) { 
                                    boolean isSelected = selectedCategory != null && selectedCategory.getCategoryId() == c.getCategoryId();
                                %>
                                <label class="<%= isSelected ? "is-checked" : "" %>">
                                    <input type="radio" name="id" value="<%= c.getCategoryId() %>" <%= isSelected ? "checked" : "" %>>
                                    <%= h(c.getCategoryName()) %> <span class="category-count">(<%= c.getProductCount() %>)</span>
                                </label>
                                <% } %>
                            <% } %>

                            <button type="submit">Áp dụng</button>

                            <% if ((keyword != null && !keyword.trim().isEmpty()) || (contentKeyword != null && !contentKeyword.trim().isEmpty())) { %>
                            <a class="clear-search-btn" href="<%= ctx %>/categories?sort=<%= selectedSort %>" style="display: block; text-align: center; margin-top: 12px; color: #ed1c24; font-size: 13px; font-weight: 800; text-decoration: none;">
                                Xóa tìm kiếm
                            </a>
                            <% } %>
                        </div>
                    </form>
                </aside>

                <section class="category-content">
                    <div class="category-result-head">
                        <div>
                            <h2>
                                <% if (contentKeyword != null && !contentKeyword.trim().isEmpty()) { %>
                                Kết quả tìm kiếm: "<%= h(contentKeyword) %>"
                                <% } else if (keyword != null && !keyword.trim().isEmpty()) { %>
                                Kết quả tìm kiếm: "<%= h(keyword) %>"
                                <% } else { %>
                                <%= h(title) %>
                                <% } %>
                                <span>(<%= totalProducts %> sản phẩm)</span>
                            </h2>
                            <p>Hiển thị <%= totalProducts %> sản phẩm</p>
                        </div>

                        <form action="<%= ctx %>/categories" method="get" class="category-product-search-form">
                            <% if (selectedCategory != null) { %>
                            <input type="hidden" name="id" value="<%= selectedCategory.getCategoryId() %>">
                            <% } %>
                            <input type="hidden" name="sort" value="<%= selectedSort %>">
                            <input type="text" name="contentKeyword" value="<%= searchValue %>" placeholder="Tìm sản phẩm theo tên/loại...">
                            <button type="submit">Tìm kiếm</button>
                        </form>

                        <form action="<%= ctx %>/categories" method="get" class="category-sort-form">
                            <% if (selectedCategory != null) { %>
                            <input type="hidden" name="id" value="<%= selectedCategory.getCategoryId() %>">
                            <% } %>
                            <% if (keyword != null && !keyword.trim().isEmpty()) { %>
                            <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                            <% } %>
                            <% if (contentKeyword != null && !contentKeyword.trim().isEmpty()) { %>
                            <input type="hidden" name="contentKeyword" value="<%= searchValue %>">
                            <% } %>
                            <label>
                                Sắp xếp:
                                <select name="sort" onchange="this.form.submit()">
                                    <option value="newest" <%= "newest".equals(selectedSort) ? "selected" : "" %>>Mới nhất</option>
                                    <option value="price_asc" <%= "price_asc".equals(selectedSort) ? "selected" : "" %>>Giá thấp đến cao</option>
                                    <option value="price_desc" <%= "price_desc".equals(selectedSort) ? "selected" : "" %>>Giá cao đến thấp</option>
                                </select>
                            </label>
                        </form>
                    </div>

                    <div class="category-product-grid">
                        <% if (products != null && !products.isEmpty()) { %>
                            <% for (Product p : products) {
                                double rating = productDAO.getAverageRating(p.getProductId());
                                int fullStars = (int) rating;
                            %>
                            <article class="product-card">
                                <figure>
                                    <% if (p.getImageUrl() != null && !p.getImageUrl().trim().isEmpty()) { %>
                                    <img src="<%= ctx %>/<%= h(p.getImageUrl()) %>" alt="<%= h(p.getProductName()) %>">
                                    <% } else { %>
                                    <span>PC</span>
                                    <% } %>
                                </figure>

                                <h3><%= h(p.getProductName()) %></h3>

                                <strong>
                                    <%= String.format("%,d", p.getPrice().longValue()) %>đ
                                </strong>

                                <div class="product-rating">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                    <i class="<%= i <= fullStars ? "fa-solid" : "fa-regular" %> fa-star"></i>
                                    <% } %>
                                    <span><%= String.format("%.1f", rating) %></span>
                                </div>

                                <p class="product-stock <%= p.getQuantity() > 0 ? "in-stock" : "out-of-stock" %>">
                                    <% if (p.getQuantity() > 0) { %>
                                    Còn hàng: <%= p.getQuantity() %>
                                    <% } else { %>
                                    Hết hàng
                                    <% } %>
                                </p>

                                <div class="product-actions">
                                    <a class="detail-btn" href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                        Xem chi tiết
                                    </a>

                                    <form class="cart-form" action="<%= ctx %>/cart" method="post">
                                        <input type="hidden" name="action" value="addToCart">
                                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                        <input type="hidden" name="quantity" value="1">
                                        <button class="cart-btn" type="submit" data-add-to-cart-btn data-product-name="<%= h(p.getProductName()) %>" <%= p.getQuantity() > 0 ? "" : "disabled" %>>
                                            <i class="fa-solid fa-cart-shopping"></i>
                                        </button>
                                    </form>
                                </div>
                            </article>
                            <% } %>
                        <% } else { %>
                            <div class="category-empty">
                                <h3>Chưa có sản phẩm trong danh mục này</h3>
                                <p>Vui lòng chọn danh mục khác.</p>
                            </div>
                        <% } %>
                    </div>

                    <div class="category-pagination">
                        <% if (currentPage > 1) { %>
                        <a href="<%= pagingUrl + (currentPage - 1) %>">Trước</a>
                        <% } %>

                        <% for (int i = 1; i <= totalPages; i++) { %>
                        <a class="<%= currentPage == i ? "active" : "" %>" href="<%= pagingUrl + i %>">
                            <%= i %>
                        </a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                        <a href="<%= pagingUrl + (currentPage + 1) %>">Sau</a>
                        <% } %>
                    </div>
                </section>
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
