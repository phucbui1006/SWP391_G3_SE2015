<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="dal.ProductDAO" %>

<%
    String ctx = request.getContextPath();

    User account = (User) session.getAttribute("account");

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
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    </head>

<body class="home-page">

        <jsp:include page="/includes/header.jsp" />

    <nav class="main-nav">
        <a class="active" href="<%= ctx %>/home">🏠 Trang chủ</a>
        <a href="<%= ctx %>/categories">Sản phẩm ▾</a>
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

                    <li>
                        <a href="<%= ctx %>/categories?id=<%= cat.getCategoryId() %>">
                            ▣ <%= cat.getCategoryName() %>
                        </a>
                    </li>

                <% 
                    }
                } 
                %>
            </ul>

            <a class="all-categories" href="<%= ctx %>/categories">
                ▦ Xem tất cả danh mục
            </a>
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

                    <a href="<%= ctx %>/categories">MUA NGAY</a>
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
                        <select onchange="location.href=this.value">
                            <option value="<%= ctx %>/categories">Tất cả</option>

                            <% if (categories != null && !categories.isEmpty()) {
                                for (Category cat : categories) {
                            %>

                                <option value="<%= ctx %>/categories?id=<%= cat.getCategoryId() %>">
                                    <%= cat.getCategoryName() %>
                                </option>

                            <% 
                                }
                            } 
                            %>
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
                    <select onchange="location.href='<%= ctx %>/categories?sort=' + this.value">
                        <option value="newest">Mới nhất</option>
                        <option value="price_asc">Giá tăng dần</option>
                        <option value="price_desc">Giá giảm dần</option>
                    </select>
                </label>
            </section>

            <section class="product-grid">

                <% if (products != null && !products.isEmpty()) {
                    for (Product product : products) {

                        double rating = 0;

                        if (productDAO != null) {
                            rating = productDAO.getAverageRating(product.getProductId());
                        }

                        int fullStars = (int) rating;
                %>

                    <article class="product-card">

                        <button class="wish-btn" type="button">♡</button>

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
                                <%= i <= fullStars ? "★" : "☆" %>
                            <% } %>

                            <span><%= String.format("%.1f", rating) %></span>
                        </div>

                        <div class="product-actions">
                            <a class="detail-btn"
                               href="<%= ctx %>/product-detail?id=<%= product.getProductId() %>">
                                Xem chi tiết
                            </a>

                            <button type="button" class="cart-btn">🛒</button>
                        </div>

                    </article>

                </section>
            </section>
        </main>
        <jsp:include page="/includes/footer.jsp" />

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