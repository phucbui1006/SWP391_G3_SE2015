<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="model.Review" %>

<%
    String contextPath = request.getContextPath();

    Product product = (Product) request.getAttribute("product");
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");

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
                <a href="<%= contextPath %>/home">Trang chủ</a>
                <span>&gt;</span>

                <a href="<%= contextPath %>/categories">Sản phẩm</a>
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
                            <%= i <= fullStars ? "★" : "☆" %>
                            <% } %>
                        </span>

                        <span><%= String.format("%.1f", avgRating) %></span>
                        <span class="review-count">| <%= totalReviews %> đánh giá</span>
                    </div>

                    <div class="price">
                        <%= String.format("%,d", product.getPrice().longValue()) %>đ
                    </div>

                    <div class="stock-status">
                        <% if (product.getQuantity() > 0) { %>
                        <span class="in-stock">Còn hàng</span>
                        <small>Số lượng: <%= product.getQuantity() %></small>
                        <% } else { %>
                        <span class="out-stock">Hết hàng</span>
                        <% } %>
                    </div>

                    <div class="option-box">
                        <p>Màu sắc</p>

                        <button type="button" class="color-option active" data-color="Đen">Đen</button>
                        <button type="button" class="color-option" data-color="Trắng">Trắng</button>
                        <button type="button" class="color-option" data-color="Xanh">Xanh</button>
                    </div>

                    <div class="purchase-panel" style="width: 500px">

                        <div class="warranty-box">
                            <div class="warranty-icon">🛡</div>

                            <div>
                                <span>Chính sách bảo hành</span>
                                <strong>Bảo hành chính hãng <%= product.getWarrantyMonths() %> tháng</strong>
                            </div>
                        </div>

                        <div class="quantity-box">
                            <span>Số lượng:</span>

                            <div class="quantity-control">
                                <button type="button" onclick="changeQty(-1)">-</button>

                                <input id="quantityInput"
                                       type="text"
                                       value="1"
                                       min="1"
                                       max="<%= product.getQuantity() %>"
                                       readonly>

                                <button type="button" onclick="changeQty(1)">+</button>
                            </div>
                        </div>

                        <div class="action-buttons">

                            <form action="<%= contextPath %>/cart" method="post">
                                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                <input type="hidden" name="quantity" id="cartQuantity" value="1">

                                <button type="submit" class="add-cart-btn">
                                    🛒 Thêm vào giỏ
                                </button>
                            </form>

                            <form action="<%= contextPath %>/checkout" method="post">
                                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                <input type="hidden" name="quantity" id="buyQuantity" value="1">

                                <button type="submit" class="buy-btn">
                                    Mua ngay
                                </button>
                            </form>

                        </div>

                    </div>

                </div>

            </section>

            <section class="description-card">
                <h2>Đặc điểm nổi bật</h2>

                <p><%= product.getDescription() %></p>

                <div class="spec-grid">

                    <div>
                        <strong>Tên sản phẩm</strong>
                        <span><%= product.getProductName() %></span>
                    </div>

                    <div>
                        <strong>Bảo hành</strong>
                        <span><%= product.getWarrantyMonths() %> tháng</span>
                    </div>

                    <div>
                        <strong>Tình trạng</strong>
                        <span><%= product.getQuantity() > 0 ? "Còn hàng" : "Hết hàng" %></span>
                    </div>

                    <div>
                        <strong>Giá bán</strong>
                        <span><%= String.format("%,d", product.getPrice().longValue()) %>đ</span>
                    </div>

                </div>
            </section>

            <section class="review-section">
                <h2>Đánh giá sản phẩm</h2>

                <div class="review-summary">

                    <div class="score">
                        <strong><%= String.format("%.1f", avgRating) %></strong>
                        <span>trên 5</span>

                        <p>
                            <% for (int i = 1; i <= 5; i++) { %>
                            <%= i <= fullStars ? "★" : "☆" %>
                            <% } %>
                        </p>
                    </div>

                    <div class="review-filter">
                        <button type="button" class="review-filter-btn active" data-rating="0">Tất cả</button>
                        <button type="button" class="review-filter-btn" data-rating="5">5 sao</button>
                        <button type="button" class="review-filter-btn" data-rating="4">4 sao</button>
                        <button type="button" class="review-filter-btn" data-rating="3">3 sao</button>
                        <button type="button" class="review-filter-btn" data-rating="2">2 sao</button>
                        <button type="button" class="review-filter-btn" data-rating="1">1 sao</button>
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

                            <h4>Người dùng #<%= review.getUserId() %></h4>

                            <div class="review-stars">
                                <% for (int i = 1; i <= 5; i++) { %>
                                <%= i <= review.getRating() ? "★" : "☆" %>
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

                    <div id="emptyReviewMessage"
                         class="empty-review"
                         style="<%= totalReviews == 0 ? "display:block;" : "display:none;" %>">
                        <% if (totalReviews == 0) { %>
                        Không có đánh giá nào tính đến hiện tại.
                        <% } %>
                    </div>

                </div>
            </section>

        </main>

        <script>
            function changeQty(value) {
                const input = document.getElementById("quantityInput");
                const cartQuantity = document.getElementById("cartQuantity");
                const buyQuantity = document.getElementById("buyQuantity");

                if (!input)
                    return;

                let current = parseInt(input.value);
                let min = parseInt(input.getAttribute("min"));
                let max = parseInt(input.getAttribute("max"));

                if (isNaN(current)) {
                    current = 1;
                }

                current += value;

                if (current < min)
                    current = min;
                if (current > max)
                    current = max;

                input.value = current;

                if (cartQuantity)
                    cartQuantity.value = current;
                if (buyQuantity)
                    buyQuantity.value = current;
            }

            const filterButtons = document.querySelectorAll(".review-filter-btn");
            const reviewItems = document.querySelectorAll(".review-item");
            const emptyReviewMessage = document.getElementById("emptyReviewMessage");

            filterButtons.forEach(function (button) {
                button.addEventListener("click", function () {
                    const selectedRating = this.getAttribute("data-rating");
                    let visibleCount = 0;

                    filterButtons.forEach(function (btn) {
                        btn.classList.remove("active");
                    });

                    this.classList.add("active");

                    reviewItems.forEach(function (item) {
                        const itemRating = item.getAttribute("data-rating");

                        if (selectedRating === "0" || itemRating === selectedRating) {
                            item.style.display = "flex";
                            visibleCount++;
                        } else {
                            item.style.display = "none";
                        }
                    });

                    if (visibleCount === 0) {
                        emptyReviewMessage.style.display = "block";

                        if (selectedRating === "0") {
                            emptyReviewMessage.innerText = "Không có đánh giá nào tính đến hiện tại.";
                        } else {
                            emptyReviewMessage.innerText = "Không có đánh giá " + selectedRating + " sao tính đến hiện tại.";
                        }
                    } else {
                        emptyReviewMessage.style.display = "none";
                        emptyReviewMessage.innerText = "";
                    }
                });
            });
        </script>
        <script>
            const colorOptions = document.querySelectorAll(".color-option");
            const cartColor = document.getElementById("cartColor");
            const buyColor = document.getElementById("buyColor");

            colorOptions.forEach(function (button) {
                button.addEventListener("click", function () {
                    colorOptions.forEach(function (item) {
                        item.classList.remove("active");
                    });

                    this.classList.add("active");

                    const selectedColor = this.getAttribute("data-color");

                    if (cartColor) {
                        cartColor.value = selectedColor;
                    }

                    if (buyColor) {
                        buyColor.value = selectedColor;
                    }
                });
            });
        </script>
    </body>
</html>
