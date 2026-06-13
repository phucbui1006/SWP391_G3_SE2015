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
                                <span>Chinh sach bao hanh</span>
                                <strong>Bao hanh chinh hang <%= product.getWarrantyMonths() %> thang</strong>
                            </div>
                        </div>

                        <div class="quantity-box">
                            <span>So luong:</span>

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

                            <form class="detail-add-cart-form" action="<%= contextPath %>/cart" method="post">
                                <input type="hidden" name="action" value="addToCart">
                                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                <input type="hidden" name="quantity" id="cartQuantity" value="1">

                                <button type="submit" class="add-cart-btn" <%= product.getQuantity() > 0 ? "" : "disabled" %>>
                                    &#128722; Them vao gio
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
                <h2>Dac diem noi bat</h2>

                <p><%= product.getDescription() %></p>

                <div class="spec-grid">

                    <div>
                        <strong>Ten san pham</strong>
                        <span><%= product.getProductName() %></span>
                    </div>

                    <div>
                        <strong>Bao hanh</strong>
                        <span><%= product.getWarrantyMonths() %> thang</span>
                    </div>

                    <div>
                        <strong>Tinh trang</strong>
                        <span><%= product.getQuantity() > 0 ? "Con hang" : "Het hang" %></span>
                    </div>

                    <div>
                        <strong>Gia ban</strong>
                        <span><%= String.format("%,d", product.getPrice().longValue()) %>&#273;</span>
                    </div>

                </div>
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
                        <button type="button" class="review-filter-btn active" data-rating="0">Tat ca</button>
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

                    <div id="emptyReviewMessage"
                         class="empty-review"
                         style=<"<%= totalReviews == 0 ? "display:block;" : "display:none;" %>">
                        <% if (totalReviews == 0) { %>
                        Khong co danh gia nao tinh den hien tai.
                        <% } %>
                    </div>

                </div>
            </section>

        </main>

        <div id="detailToast" class="detail-toast" role="status" aria-live="polite" aria-atomic="true">
            <span class="detail-toast-icon">✓</span>
            <span class="detail-toast-message">Da them san pham vao gio hang.</span>
        </div>

        <script>
            function changeQty(value) {
                const input = document.getElementById("quantityInput");
                const cartQuantity = document.getElementById("cartQuantity");
                const buyQuantity = document.getElementById("buyQuantity");

                if (!input)
                    return;

                let current = parseInt(input.value, 10);
                let min = parseInt(input.getAttribute("min"), 10);
                let max = parseInt(input.getAttribute("max"), 10);

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
                            emptyReviewMessage.innerText = "Khong co danh gia nao tinh den hien tai.";
                        } else {
                            emptyReviewMessage.innerText = "Khong co danh gia " + selectedRating + " sao tinh den hien tai.";
                        }
                    } else {
                        emptyReviewMessage.style.display = "none";
                        emptyReviewMessage.innerText = "";
                    }
                });
            });

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

            (function () {
                const addToCartForm = document.querySelector(".detail-add-cart-form");
                const addToCartButton = addToCartForm ? addToCartForm.querySelector(".add-cart-btn") : null;
                const detailToast = document.getElementById("detailToast");
                const detailToastMessage = detailToast ? detailToast.querySelector(".detail-toast-message") : null;
                const headerCartCountElement = document.querySelector(".cart-box .cart-icon span");
                const cartApiUrl = addToCartForm ? addToCartForm.getAttribute("action") : "";
                let toastTimer = null;

                if (!addToCartForm || !addToCartButton || !detailToast || !detailToastMessage || !cartApiUrl) {
                    return;
                }

                const showToast = function (message, type) {
                    detailToastMessage.textContent = message;
                    detailToast.classList.remove("is-success", "is-error", "show");
                    detailToast.classList.add(type === "error" ? "is-error" : "is-success");
                    detailToast.offsetWidth;
                    detailToast.classList.add("show");

                    if (toastTimer) {
                        window.clearTimeout(toastTimer);
                    }

                    toastTimer = window.setTimeout(function () {
                        detailToast.classList.remove("show");
                    }, 2600);
                };

                const parseJsonSafely = function (response) {
                    return response.text().then(function (text) {
                        if (!text) {
                            return {};
                        }

                        try {
                            return JSON.parse(text);
                        } catch (error) {
                            return {};
                        }
                    });
                };

                addToCartForm.addEventListener("submit", function (event) {
                    event.preventDefault();

                    if (addToCartButton.disabled) {
                        showToast("San pham hien tam het hang.", "error");
                        return;
                    }

                    addToCartButton.classList.add("is-adding");
                    addToCartButton.classList.remove("is-added");

                    const payload = new URLSearchParams(new FormData(addToCartForm));

                    fetch(cartApiUrl, {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
                            "X-Requested-With": "XMLHttpRequest"
                        },
                        body: payload.toString()
                    })
                            .then(function (response) {
                                return parseJsonSafely(response).then(function (data) {
                                    if (!response.ok) {
                                        throw new Error(data.message || "Khong the them san pham vao gio hang.");
                                    }
                                    return data;
                                });
                            })
                            .then(function (data) {
                                if (headerCartCountElement && typeof data.cartItemCount === "number") {
                                    headerCartCountElement.textContent = data.cartItemCount;
                                }

                                addToCartButton.classList.add("is-added");
                                window.setTimeout(function () {
                                    addToCartButton.classList.remove("is-added");
                                }, 1400);

                                showToast(data.message || "Da them san pham vao gio hang.", "success");
                            })
                            .catch(function (error) {
                                showToast(error.message || "Khong the them san pham vao gio hang.", "error");
                            })
                            .finally(function () {
                                addToCartButton.classList.remove("is-adding");
                            });
                });
            })();
        </script>
    </body>
</html>
