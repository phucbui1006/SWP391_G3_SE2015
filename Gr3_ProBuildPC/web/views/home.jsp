<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="dal.ProductDAO" %>

<%
    User account = (User) session.getAttribute("account");
    String ctx = request.getContextPath();
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Product> products = (List<Product>) request.getAttribute("products");
    ProductDAO productDAO = (ProductDAO) request.getAttribute("productDAO");
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC</title>

        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    </head>

    <body class="home-page">

        <div class="top-strip"></div>

        <header class="site-header">
            <div class="header-inner">

                <a class="brand" href="<%= ctx %>/home">
                    <span class="brand-mark">P</span>

                    <span class="brand-text">
                        <strong><span>ProBuild</span> PC</strong>
                        <small>BUILD YOUR PERFECT PC</small>
                    </span>
                </a>

                <form class="home-search-box" action="#" method="get">
                    <input type="text" name="q" placeholder="Tìm kiếm sản phẩm, danh mục, thương hiệu...">
                    <button type="submit">🔍</button>
                </form>

                <nav class="header-actions">

                    <a href="#" class="header-link">
                        <span>🛡</span>
                        <b>Dịch vụ bảo hành</b>
                    </a>

                    <a href="#" class="header-link cart-link">
                        <span>🛒</span>
                        <b>Giỏ hàng</b>
                        <em>0</em>
                    </a>

                    <% if (account == null) { %>

                    <a href="<%= ctx %>/Login" class="header-link">
                        <span>👤</span>
                        <b>Đăng nhập</b>
                    </a>

                    <a href="<%= ctx %>/Register" class="register-btn">
                        Đăng ký
                    </a>

                    <% } else { %>

                    <a href="<%= ctx %>/Dashboard" class="header-link">
                        <span>👤</span>
                        <b><%= account.getFullName() %></b>
                    </a>

                    <a href="<%= ctx %>/Logout" class="register-btn">
                        Đăng xuất
                    </a>

                    <% } %>

                </nav>
            </div>
        </header>

        <nav class="main-nav">
            <a class="active" href="<%= ctx %>/home">🏠 Trang chủ</a>
            <a href="#">Sản phẩm ▾</a>
            <a href="#">Build PC</a>
            <a href="#">Đơn hàng</a>
        </nav>

        <main class="page-shell">

            <aside class="sidebar">
                <h2>DANH MỤC SẢN PHẨM</h2>

                <ul class="category-list">
                    <% if (categories != null && !categories.isEmpty()) {
                        for (Category cat : categories) {
                    %>
                    <li><span>▣ <%= cat.getCategoryName() %></span></li>
                    <% }} %>
                </ul>

                <a class="all-categories" href="#">▦ Xem tất cả danh mục</a>
            </aside>

            <section class="content">

                <section class="hero-banner">
                    <div class="hero-copy">
                        <p>BUILD PC</p>

                        <h1>
                            ĐỈNH CAO HIỆU NĂNG<br>
                            NÂNG TẦM TRẢI NGHIỆM
                        </h1>

                        <span>
                            Linh kiện chính hãng - Giá tốt nhất<br>
                            Bảo hành uy tín - Hỗ trợ tận tâm
                        </span>

                        <a href="#">MUA NGAY</a>
                    </div>
                </section>

                <section class="service-row">
                    <article>
                        <span>🛡</span>
                        <div>
                            <strong>Hàng chính hãng</strong>
                            <small>100% chính hãng</small>
                        </div>
                    </article>

                    <article>
                        <span>🔄</span>
                        <div>
                            <strong>Bảo hành uy tín</strong>
                            <small>Bảo hành chính hãng</small>
                        </div>
                    </article>

                    <article>
                        <span>🚚</span>
                        <div>
                            <strong>Giao hàng toàn Thạch Thất</strong>
                            <small>Miễn phí đơn từ 1 triệu</small>
                        </div>
                    </article>

                    <article>
                        <span>🎧</span>
                        <div>
                            <strong>Hỗ trợ 24/7</strong>
                            <small>Tư vấn tận tâm</small>
                        </div>
                    </article>
                </section>

                <section class="filter-row">
                    <div class="filters">

                        <label>
                            Danh mục:
                            <select>
                                <option>Tất cả</option>
                                <% if (categories != null && !categories.isEmpty()) {
                                    for (Category cat : categories) {
                                %>
                                <option><%= cat.getCategoryName() %></option>
                                <% }} %>
                            </select>
                        </label>

                        <label>
                            Thương hiệu:
                            <select>
                                <option>Tất cả</option>
                                <option>Intel</option>
                                <option>AMD</option>
                                <option>ASUS</option>
                                <option>MSI</option>
                            </select>
                        </label>

                        <label>
                            Khoảng giá:
                            <select>
                                <option>Tất cả</option>
                                <option>Dưới 2 triệu</option>
                                <option>2 - 5 triệu</option>
                                <option>Trên 5 triệu</option>
                            </select>
                        </label>

                    </div>

                    <label class="sort-box">
                        Sắp xếp:
                        <select>
                            <option>Mới nhất</option>
                            <option>Giá tăng dần</option>
                            <option>Giá giảm dần</option>
                        </select>
                    </label>
                </section>

                <section class="product-grid">
                    <% if (products != null && !products.isEmpty()) {
                        for (Product product : products) {
                            double rating = productDAO.getAverageRating(product.getProductId());
                            int fullStars = (int) rating;
                            boolean hasHalfStar = (rating - fullStars) >= 0.5;
                    %>
                    <article class="product-card">
                        <button class="wish-btn">♡</button>
                        <figure>
                            <img src="<%= ctx %>/<%= product.getImageUrl() %>" alt="<%= product.getProductName() %>">
                        </figure>
                        <h3><%= product.getProductName() %></h3>
                        <strong><%= String.format("%,d", product.getPrice().longValue()) %>đ</strong>
                        
                        <!-- Rating Stars -->
                        <div class="product-rating" style="margin: 5px 0; font-size: 14px;">
                            <% for (int i = 0; i < 5; i++) {
                                if (i < fullStars) { %>
                                    ★
                                <% } else if (i == fullStars && hasHalfStar) { %>
                                    ☆
                                <% } else { %>
                                    ☆
                                <% }
                            } %>
                            <span style="margin-left: 5px;"><%= String.format("%.1f", rating) %></span>
                        </div>

                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button">🛒</button>
                        </div>
                    </article>
                    <% }} %>

                </section>

                <nav class="home-pagination">
                    <a href="#">‹</a>
                    <a href="#" class="active">1</a>
                    <a href="#">2</a>
                    <a href="#">3</a>
                    <a href="#">4</a>
                    <a href="#">5</a>
                    <span>...</span>
                    <a href="#">10</a>
                    <a href="#">›</a>
                </nav>

            </section>
        </main>

    </body>
</html>