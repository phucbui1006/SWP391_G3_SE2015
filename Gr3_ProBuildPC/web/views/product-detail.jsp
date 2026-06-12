<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="model.Review" %>

<%
    String contextPath = request.getContextPath();

    Product product = (Product) request.getAttribute("product");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    List<Product> similarProducts = (List<Product>) request.getAttribute("similarProducts");

    double avgRating = 0;

    if (request.getAttribute("avgRating") != null) {
        avgRating = (Double) request.getAttribute("avgRating");
    }

    if (product == null) {
        response.sendRedirect(contextPath + "/home");
        return;
    }

    int fullStars = (int) avgRating;
    int totalReviews = reviews == null ? 0 : reviews.size();
    int maxQuantity = product.getQuantity() > 0 ? product.getQuantity() : 1;
    int selectedRating = 0;

if (request.getAttribute("selectedRating") != null) {
    selectedRating = (Integer) request.getAttribute("selectedRating");
}
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title><%= product.getProductName() %> - ProBuild PC</title>

        <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
        <link rel="stylesheet" href="<%= contextPath %>/css/product-detail.css">
    </head>

    <body class="product-detail-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="product-detail-page">

            <div class="breadcrumb">
                <a href="<%= contextPath %>/home">Trang ch&#7911;</a>
                <span>&gt;</span>

                <a href="<%= contextPath %>/categories">S&#7843;n ph&#7849;m</a>
                <span>&gt;</span>

                <strong><%= product.getProductName() %></strong>
            </div>

            <section class="detail-card">

                <div class="product-images">
                    <div class="main-image">
                        <img id="mainProductImage"
                             src="<%= contextPath %>/<%= product.getImageUrl() %>"
                             alt="<%= product.getProductName() %>">
                    </div>
                </div>

                <div class="product-info">

                    <h1><%= product.getProductName() %></h1>

                    <div class="rating-row">
                        <span class="stars">
                            <% for (int i = 1; i <= 5; i++) { %>
                            <%= i <= fullStars ? "&#9733;" : "&#9734;" %>
                            <% } %>
                        </span>

                        <span><%= String.format("%.1f", avgRating) %></span>
                        <span class="review-count">| <%= totalReviews %> danh gia</span>
                    </div>

                    <div class="price">
                        <%= String.format("%,d", product.getPrice().longValue()) %>&#273;
                    </div>

                    <div class="stock-status">
                        <% if (product.getQuantity() > 0) { %>
                        <span class="in-stock">Con hang</span>
                        <small>So luong: <%= product.getQuantity() %></small>
                        <% } else { %>
                        <span class="out-stock">Het hang</span>
                        <% } %>
                    </div>

                    <div class="option-box">
                        <p>Mau sac</p>

                        <button type="button" class="color-option active" data-color="Den">Den</button>
                        <button type="button" class="color-option" data-color="Trang">Trang</button>
                        <button type="button" class="color-option" data-color="Xanh">Xanh</button>
                    </div>

                    <div class="purchase-panel" style="width: 500px">

                        <div class="warranty-box">
                            <div class="warranty-icon">&#128737;</div>

                            <div>
                                <span>Chính sách bảo hành</span>
                                <strong>Bảo hành chính hãng <%= product.getWarrantyMonths() %> tháng</strong>
                            </div>
                        </div>

                        <form class="purchase-form" method="post">

                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">

                            <div class="option-box">
                                <p>Màu sắc</p>

                                <div class="color-radio-group">
                                    <input class="color-radio" type="radio" name="color" id="colorBlack" value="Đen" checked>
                                    <label class="color-option" for="colorBlack">Đen</label>

                                    <input class="color-radio" type="radio" name="color" id="colorWhite" value="Trắng">
                                    <label class="color-option" for="colorWhite">Trắng</label>

                                    <input class="color-radio" type="radio" name="color" id="colorBlue" value="Xanh">
                                    <label class="color-option" for="colorBlue">Xanh</label>
                                </div>
                            </div>

                            <div class="quantity-box">
                                <span>Số lượng:</span>

                                <input class="quantity-input"
                                       type="number"
                                       name="quantity"
                                       value="1"
                                       min="1"
                                       max="<%= maxQuantity %>"
                                       <%= product.getQuantity() > 0 ? "" : "disabled" %>>
                            </div>

                            <div class="action-buttons">

                                <button type="submit"
                                        formaction="<%= contextPath %>/cart"
                                        name="action"
                                        value="addToCart"
                                        class="add-cart-btn"
                                        <%= product.getQuantity() > 0 ? "" : "disabled" %>>
                                    &#128722; Thêm vào giỏ
                                </button>

                                <button type="submit"
                                        formaction="<%= contextPath %>/checkout"
                                        class="buy-btn"
                                        <%= product.getQuantity() > 0 ? "" : "disabled" %>>
                                    Mua ngay
                                </button>

                            </div>

                        </form>

                    </div>

                </div>

            </section>

            <section class="similar-card">
                <div class="similar-header">
                    <h2>Sản phẩm tương tự</h2>
                    <p>Các sản phẩm cùng danh mục</p>
                </div>

                <% if (similarProducts != null && !similarProducts.isEmpty()) { %>

                <div class="similar-products-row">

                    <% for (Product item : similarProducts) {
                        String imageUrl = item.getImageUrl();

                        if (imageUrl == null || imageUrl.trim().isEmpty()) {
                            imageUrl = "images/no-image.png";
                        }
                    %>

                    <a class="similar-product-item"
                       href="<%= contextPath %>/product-detail?id=<%= item.getProductId() %>">

                        <div class="similar-product-img">
                            <img src="<%= contextPath %>/<%= imageUrl %>"
                                 alt="<%= item.getProductName() %>">
                        </div>

                        <h3><%= item.getProductName() %></h3>

                        <div class="similar-price">
                            <%= String.format("%,d", item.getPrice().longValue()) %>đ
                        </div>

                    </a>

                    <% } %>

                </div>

                <% } else { %>

                <div class="empty-similar">
                    Không có sản phẩm tương tự.
                </div>

                <% } %>
            </section>

            <section class="review-section">
                <h2>Danh gia san pham</h2>

                <div class="review-summary">

                    <div class="score">
                        <strong><%= String.format("%.1f", avgRating) %></strong>
                        <span>tren 5</span>

                        <p>
                            <% for (int i = 1; i <= 5; i++) { %>
                            <%= i <= fullStars ? "&#9733;" : "&#9734;" %>
                            <% } %>
                        </p>
                    </div>

                    <div class="review-filter">

                        <a class="review-filter-btn <%= selectedRating == 0 ? "active" : "" %>"
                           href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>">
                            Tất cả
                        </a>

                        <a class="review-filter-btn <%= selectedRating == 5 ? "active" : "" %>"
                           href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=5">
                            5 sao
                        </a>

                        <a class="review-filter-btn <%= selectedRating == 4 ? "active" : "" %>"
                           href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=4">
                            4 sao
                        </a>

                        <a class="review-filter-btn <%= selectedRating == 3 ? "active" : "" %>"
                           href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=3">
                            3 sao
                        </a>

                        <a class="review-filter-btn <%= selectedRating == 2 ? "active" : "" %>"
                           href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=2">
                            2 sao
                        </a>

                        <a class="review-filter-btn <%= selectedRating == 1 ? "active" : "" %>"
                           href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=1">
                            1 sao
                        </a>

                    </div>

                </div>

                <div class="review-list">

                    <% if (reviews != null && !reviews.isEmpty()) {
                        for (Review review : reviews) {
                    %>

                    <article class="review-item" data-rating="<%= review.getRating() %>">

                        <div class="avatar">
                            <%= review.getUserId() %>
                        </div>

                        <div class="review-content">

                            <h4>Nguoi dung #<%= review.getUserId() %></h4>

                            <div class="review-stars">
                                <% for (int i = 1; i <= 5; i++) { %>
                                <%= i <= review.getRating() ? "&#9733;" : "&#9734;" %>
                                <% } %>
                            </div>

                            <small><%= review.getDate() %></small>

                            <p><%= review.getComment() %></p>

                            <% if (review.getImg() != null && !review.getImg().isEmpty()) { %>
                            <img class="review-img"
                                 src="<%= contextPath %>/<%= review.getImg() %>"
                                 alt="Review image">
                            <% } %>

                        </div>

                    </article>

                    <% }} %>

                    <% if (reviews == null || reviews.isEmpty()) { %>
                    <div class="empty-review">
                        <% if (selectedRating == 0) { %>
                        Không có đánh giá nào tính đến hiện tại.
                        <% } else { %>
                        Không có đánh giá <%= selectedRating %> sao tính đến hiện tại.
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </section>

        </main>

        <div id="detailToast" class="detail-toast" role="status" aria-live="polite" aria-atomic="true">
            <span class="detail-toast-icon">✓</span>
            <span class="detail-toast-message">Da them san pham vao gio hang.</span>
        </div>


    </body>
</html>
