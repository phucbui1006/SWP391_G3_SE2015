<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>

<%
    String ctx = request.getContextPath();

    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Product> products = (List<Product>) request.getAttribute("products");
    Category selectedCategory = (Category) request.getAttribute("selectedCategory");

    String selectedSort = (String) request.getAttribute("selectedSort");

    if (selectedSort == null) {
        selectedSort = "newest";
    }

    String title = "Tất cả sản phẩm";

    if (selectedCategory != null) {
        title = "Danh mục: " + selectedCategory.getCategoryName();
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Danh mục sản phẩm - ProBuild PC</title>

        <link rel="stylesheet" href="<%= ctx %>/css/header.css">
        <link rel="stylesheet" href="<%= ctx %>/css/categories.css">
    </head>

    <body>

        <jsp:include page="/includes/header.jsp" />

        <main class="category-page">

            <section class="category-hero">
                <div>
                    <p>PROBUILD PC</p>
                    <h1>Danh mục sản phẩm</h1>
                    <span>Lựa chọn linh kiện theo từng nhóm sản phẩm</span>
                </div>
            </section>

            <section class="category-layout">

                <aside class="category-sidebar">
                    <h2>📦 Danh mục sản phẩm</h2>

                    <a class="category-link <%= selectedCategory == null ? "active" : "" %>"
                       href="<%= ctx %>/categories?sort=<%= selectedSort %>">
                        Tất cả sản phẩm
                    </a>

                    <% if (categories != null && !categories.isEmpty()) {
                        for (Category c : categories) {
                    %>

                    <a class="category-link <%= selectedCategory != null && selectedCategory.getCategoryId() == c.getCategoryId() ? "active" : "" %>"
                       href="<%= ctx %>/categories?id=<%= c.getCategoryId() %>&sort=<%= selectedSort %>">
                        ▣ <%= c.getCategoryName() %>
                    </a>

                    <% }} %>
                </aside>

                <section class="category-content">

                    <div class="category-title-row">
                        <div>
                            <h2><%= title %></h2>

                            <p>
                                Hiện có
                                <strong><%= products == null ? 0 : products.size() %></strong>
                                sản phẩm
                            </p>
                        </div>

                        <form action="<%= ctx %>/categories" method="get" class="sort-form">

                            <% if (selectedCategory != null) { %>
                            <input type="hidden" name="id" value="<%= selectedCategory.getCategoryId() %>">
                            <% } %>

                            <select name="sort" onchange="this.form.submit()">
                                <option value="newest" <%= "newest".equals(selectedSort) ? "selected" : "" %>>
                                    Mới nhất
                                </option>

                                <option value="price_asc" <%= "price_asc".equals(selectedSort) ? "selected" : "" %>>
                                    Giá tăng dần
                                </option>

                                <option value="price_desc" <%= "price_desc".equals(selectedSort) ? "selected" : "" %>>
                                    Giá giảm dần
                                </option>
                            </select>

                        </form>
                    </div>

                    <div class="category-grid">

                        <% if (products != null && !products.isEmpty()) {
                            for (Product p : products) {
                        %>

                        <article class="category-product-card">

                            <button class="wish-btn" type="button">♡</button>

                            <a href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                <figure>
                                    <img src="<%= ctx %>/<%= p.getImageUrl() %>"
                                         alt="<%= p.getProductName() %>">
                                </figure>

                                <h3><%= p.getProductName() %></h3>
                            </a>

                            <strong>
                                <%= String.format("%,d", p.getPrice().longValue()) %>đ
                            </strong>

                            <p class="stock">
                                <% if (p.getQuantity() > 0) { %>
                                Còn hàng: <%= p.getQuantity() %>
                                <% } else { %>
                                Hết hàng
                                <% } %>
                            </p>

                            <div class="card-actions">
                                <a href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                    Xem chi tiết
                                </a>

                                <button type="button">🛒</button>
                            </div>

                        </article>

                        <% }} else { %>

                        <div class="empty-box">
                            <h3>Chưa có sản phẩm trong danh mục này</h3>
                            <p>Vui lòng chọn danh mục khác.</p>
                        </div>

                        <% } %>

                    </div>

                </section>

            </section>

        </main>

    </body>
</html>