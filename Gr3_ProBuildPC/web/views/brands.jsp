<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="model.Brand" %>
<%@ page import="model.Product" %>

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

    private String url(String value) {
        return URLEncoder.encode(value == null ? "" : value, StandardCharsets.UTF_8);
    }
%>

<%
    String ctx = request.getContextPath();
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
    List<Product> products = (List<Product>) request.getAttribute("products");
    Brand selectedBrand = (Brand) request.getAttribute("selectedBrand");
    Integer selectedBrandId = (Integer) request.getAttribute("selectedBrandId");
    String selectedPriceRange = (String) request.getAttribute("selectedPriceRange");
    String selectedSort = (String) request.getAttribute("selectedSort");
    String keyword = (String) request.getAttribute("keyword");

    if (selectedPriceRange == null) {
        selectedPriceRange = "all";
    }

    if (selectedSort == null) {
        selectedSort = "newest";
    }

    if (keyword == null) {
        keyword = "";
    }

    int productCount = products == null ? 0 : products.size();
    String pageTitle = selectedBrand == null
            ? "Tất cả thương hiệu"
            : "Sản phẩm thương hiệu " + selectedBrand.getBrandName();
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thương hiệu sản phẩm - ProBuild PC</title>
        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
        <link rel="stylesheet" href="<%= ctx %>/css/brands.css">
    </head>
    <body class="brands-page" style="padding-bottom: 0px; padding-left: 0px; padding-right: 0px; padding-top: 0px">
        <jsp:include page="/includes/header.jsp" />
        <main class="brand-page">
            <nav class="brand-breadcrumb" aria-label="Breadcrumb">
                <a href="<%= ctx %>/home">Trang chủ</a>
                <span>›</span>
                <strong>Thương hiệu</strong>
            </nav>

            <section class="brand-heading">
                <div>
                    <h1>Thương hiệu</h1>
                    <p>Khám phá sản phẩm từ các thương hiệu hàng đầu</p>
                </div>
            </section>

            <section class="brand-layout">
                <aside class="brand-sidebar" aria-label="Bộ lọc thương hiệu">
                    <form class="brand-filter-form" action="<%= ctx %>/brands" method="get">
                        <input type="hidden" name="sort" value="<%= h(selectedSort) %>">
                        <input type="hidden" name="keyword" value="<%= h(keyword) %>">

                        <div class="filter-panel">
                            <div class="filter-title">
                                <h2>Thương hiệu</h2>
                                <span>−</span>
                            </div>

                            <label>
                                <input type="radio" name="brandId" value="" <%= selectedBrandId == null ? "checked" : "" %>>
                                Tất cả
                            </label>

                            <% if (brands != null) {
                                for (Brand brand : brands) {
                            %>
                            <label>
                                <input type="radio"
                                       name="brandId"
                                       value="<%= brand.getBrandId() %>"
                                       <%= selectedBrandId != null && selectedBrandId == brand.getBrandId() ? "checked" : "" %>>
                                <%= h(brand.getBrandName()) %> (<%= brand.getProductCount() %>)
                            </label>
                            <% }} %>
                        </div>

                        <div class="filter-panel">
                            <div class="filter-title">
                                <h2>Khoảng giá</h2>
                                <span>−</span>
                            </div>
                            <label><input type="radio" name="priceRange" value="all" <%= "all".equals(selectedPriceRange) ? "checked" : "" %>> Tất cả</label>
                            <label><input type="radio" name="priceRange" value="under5" <%= "under5".equals(selectedPriceRange) ? "checked" : "" %>> Dưới 5.000.000đ</label>
                            <label><input type="radio" name="priceRange" value="5to10" <%= "5to10".equals(selectedPriceRange) ? "checked" : "" %>> 5.000.000đ - 10.000.000đ</label>
                            <label><input type="radio" name="priceRange" value="10to20" <%= "10to20".equals(selectedPriceRange) ? "checked" : "" %>> 10.000.000đ - 20.000.000đ</label>
                            <label><input type="radio" name="priceRange" value="over20" <%= "over20".equals(selectedPriceRange) ? "checked" : "" %>> Trên 20.000.000đ</label>
                            <button type="submit">Áp dụng</button>
                        </div>
                    </form>
                </aside>

                <section class="brand-content">
                    <div class="brand-strip" aria-label="Danh sách thương hiệu">
                        <% if (brands != null) {
                            for (Brand brand : brands) {
                                boolean active = selectedBrandId != null && selectedBrandId == brand.getBrandId();
                        %>
                        <a class="brand-card <%= active ? "active" : "" %>"
                           href="<%= ctx %>/brands?brandId=<%= brand.getBrandId() %>&priceRange=<%= url(selectedPriceRange) %>&sort=<%= url(selectedSort) %>&keyword=<%= url(keyword) %>">
                            <% if (brand.getImg() != null && !brand.getImg().trim().isEmpty()) { %>
                            <img src="<%= ctx %>/<%= h(brand.getImg()) %>" alt="<%= h(brand.getBrandName()) %>">
                            <% } else { %>
                            <span class="brand-text-logo"><%= h(brand.getBrandName()) %></span>
                            <% } %>
                            <small>(<%= brand.getProductCount() %> sản phẩm)</small>
                        </a>
                        <% }} %>

                        <a class="brand-card view-all <%= selectedBrandId == null ? "active" : "" %>"
                           href="<%= ctx %>/brands?priceRange=<%= url(selectedPriceRange) %>&sort=<%= url(selectedSort) %>&keyword=<%= url(keyword) %>">
                            <span>▦</span>
                            <small>Xem tất cả</small>
                        </a>
                    </div>

                    <div class="brand-result-head">
                        <div>
                            <h2><%= h(pageTitle) %> <span>(<%= productCount %> sản phẩm)</span></h2>
                            <p>Hiển thị <%= productCount %> sản phẩm</p>
                        </div>

                        <form action="<%= ctx %>/brands" method="get" class="brand-product-search-form">
                            <% if (selectedBrandId != null) { %>
                            <input type="hidden" name="brandId" value="<%= selectedBrandId %>">
                            <% } %>
                            <input type="hidden" name="priceRange" value="<%= h(selectedPriceRange) %>">
                            <input type="hidden" name="sort" value="<%= h(selectedSort) %>">
                            <input type="text" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm sản phẩm trong hãng...">
                            <button type="submit">Tìm kiếm</button>
                        </form>

                        <form action="<%= ctx %>/brands" method="get" class="brand-sort-form">
                            <% if (selectedBrandId != null) { %>
                            <input type="hidden" name="brandId" value="<%= selectedBrandId %>">
                            <% } %>
                            <input type="hidden" name="priceRange" value="<%= h(selectedPriceRange) %>">
                            <input type="hidden" name="keyword" value="<%= h(keyword) %>">
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

                    <div class="brand-product-grid">
                        <% if (products != null && !products.isEmpty()) {
                            for (Product product : products) {
                        %>
                        <article class="brand-product-card">
                            <a class="brand-product-image" href="<%= ctx %>/product-detail?id=<%= product.getProductId() %>">
                                <% if (product.getImageUrl() != null && !product.getImageUrl().trim().isEmpty()) { %>
                                <img src="<%= ctx %>/<%= h(product.getImageUrl()) %>" alt="<%= h(product.getProductName()) %>">
                                <% } else { %>
                                <span>PC</span>
                                <% } %>
                            </a>
                            <h3>
                                <a href="<%= ctx %>/product-detail?id=<%= product.getProductId() %>">
                                    <%= h(product.getProductName()) %>
                                </a>
                            </h3>
                            <strong><%= String.format("%,d", product.getPrice().longValue()) %>đ</strong>
                            <p>Số lượng: <%= product.getQuantity() %></p>
                            <a class="detail-link" href="<%= ctx %>/product-detail?id=<%= product.getProductId() %>">
                                Chi tiết <span>›</span>
                            </a>
                        </article>
                        <% }} else { %>
                        <div class="brand-empty">
                            <h3>Chưa có sản phẩm phù hợp</h3>
                            <p>Vui lòng thử từ khóa, thương hiệu hoặc khoảng giá khác.</p>
                        </div>
                        <% } %>
                    </div>
                </section>
            </section>
        </main>
        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
