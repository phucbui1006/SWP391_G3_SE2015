<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="model.Review" %>

<% String contextPath=request.getContextPath(); Product product=(Product)
    request.getAttribute("product"); List<Review> reviews = (List<Review>)
        request.getAttribute("reviews");
        List<Review> allReviews = (List<Review>) request.getAttribute("allReviews");
        List<Product> similarProducts = (List<Product>) request.getAttribute("similarProducts");

                        if (product == null) {
                        response.sendRedirect(contextPath + "/home");
                        return;
                        }

                        double avgRating = 0;
                        if (request.getAttribute("avgRating") != null) {
                        avgRating = (Double) request.getAttribute("avgRating");
                        }

                        int selectedRating = 0;
                        if (request.getAttribute("selectedRating") != null) {
                        selectedRating = (Integer) request.getAttribute("selectedRating");
                        }

                        boolean hasImage = false;
                        if (request.getAttribute("hasImage") != null) {
                            hasImage = (Boolean) request.getAttribute("hasImage");
                        }

                        int currentPage = 1;
                        if (request.getAttribute("currentPage") != null) {
                            currentPage = (Integer) request.getAttribute("currentPage");
                        }

                        int totalPages = 1;
                        if (request.getAttribute("totalPages") != null) {
                            totalPages = (Integer) request.getAttribute("totalPages");
                        }

                        int fullStars = (int) avgRating;
                        int maxQuantity = product.getQuantity() > 0 ? product.getQuantity() : 1;

                        String currentUrl = contextPath + "/product-detail";
                        if (request.getQueryString() != null &&
                        !request.getQueryString().trim().isEmpty()) {
                        currentUrl += "?" + request.getQueryString();
                        } else {
                        currentUrl += "?id=" + product.getProductId();
                        }

                        String reviewPagingUrl = contextPath + "/product-detail?id=" + product.getProductId();
                        if (selectedRating > 0) {
                            reviewPagingUrl += "&rating=" + selectedRating;
                        }
                        if (hasImage) {
                            reviewPagingUrl += "&hasImage=true";
                        }
                        reviewPagingUrl += "&page=";

                        int totalAllReviews = allReviews == null ? 0 : allReviews.size();

                        int count5 = 0;
                        int count4 = 0;
                        int count3 = 0;
                        int count2 = 0;
                        int count1 = 0;
                        int countHasImage = 0;

                        if (allReviews != null) {
                        for (Review r : allReviews) {
                        if (r.getImages() != null && !r.getImages().isEmpty()) {
                            countHasImage++;
                        }
                        if (r.getRating() == 5) {
                        count5++;
                        } else if (r.getRating() == 4) {
                        count4++;
                        } else if (r.getRating() == 3) {
                        count3++;
                        } else if (r.getRating() == 2) {
                        count2++;
                        } else if (r.getRating() == 1) {
                        count1++;
                        }
                        }
                        }

                        int pct5 = totalAllReviews == 0 ? 0 : (count5 * 100) / totalAllReviews;
                        int pct4 = totalAllReviews == 0 ? 0 : (count4 * 100) / totalAllReviews;
                        int pct3 = totalAllReviews == 0 ? 0 : (count3 * 100) / totalAllReviews;
                        int pct2 = totalAllReviews == 0 ? 0 : (count2 * 100) / totalAllReviews;
                        int pct1 = totalAllReviews == 0 ? 0 : (count1 * 100) / totalAllReviews;
                        String cartMessage = (String) request.getAttribute("cartMessage");
                        String cartMessageType = (String) request.getAttribute("cartMessageType");

                        if (cartMessage == null) {
                        cartMessage = (String) session.getAttribute("cartMessage");
                        session.removeAttribute("cartMessage");
                        }

                        if (cartMessageType == null) {
                        cartMessageType = (String) session.getAttribute("cartMessageType");
                        session.removeAttribute("cartMessageType");
                        }

                        if (cartMessageType == null) {
                        cartMessageType = "success";
                        }
%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            <%= product.getProductName() %> - ProBuild PC
        </title>

        <link rel="stylesheet" href="<%= contextPath %>/css/style.css">
        <link rel="stylesheet"
              href="<%= contextPath %>/css/product-detail.css?v=203">
    </head>

    <body class="product-detail-body" data-context-path="<%= contextPath %>">

        <jsp:include page="/includes/header.jsp" />

        <main class="product-detail-page">

            <% if (cartMessage !=null && !cartMessage.trim().isEmpty()) { %>
            <div class="server-message <%= " error".equals(cartMessageType)
                                                            ? "error" : "success" %>">
                <%= cartMessage %>
            </div>
            <% } %>

            <nav class="breadcrumb site-breadcrumb" aria-label="Breadcrumb">
                <a href="<%= contextPath %>/home">Trang chủ</a>
                <span>›</span>

                <a href="<%= contextPath %>/categories">Sản phẩm</a>
                <span>›</span>

                <strong>
                    <%= product.getProductName() %>
                </strong>
            </nav>

            <section class="detail-card">
                <div class="product-images">
                    <div class="main-image">
                        <img src="<%= contextPath %>/<%= product.getImageUrl() %>"
                             alt="<%= product.getProductName() %>">
                    </div>
                </div>

                <div class="product-info">

                    <h1>
                        <%= product.getProductName() %>
                    </h1>

                    <div class="product-meta-details">
                        <span class="meta-label">Thương hiệu:</span>
                        <span class="meta-value"><%= product.getBrandName() %></span>
                        <span class="meta-divider">|</span>
                        <span class="meta-label">Danh mục:</span>
                        <span class="meta-value"><%= product.getCategoryName() %></span>
                    </div>

                    <div class="rating-row">
                        <span class="rating-badge">
                            <%= String.format("%.1f", avgRating) %>
                            <i class="fa-solid fa-star"></i>
                        </span>
                        <span class="stars">
                            <% for (int i=1; i <=5; i++) { %>
                            <% if (i <=fullStars) { %>
                            <i class="fa-solid fa-star"></i>
                            <% } else if (i - 1 < avgRating && avgRating < i) { %>
                            <i class="fa-solid fa-star-half-stroke"></i>
                            <% } else { %>
                            <i class="fa-regular fa-star"></i>
                            <% } %>
                            <% } %>
                        </span>
                        <span class="review-count">| <%= totalAllReviews %> đánh giá</span>
                    </div>

                    <div class="warranty-text">
                        Bảo hành: <%= product.getWarrantyMonths() %> tháng chính hãng
                    </div>

                    <div class="price">
                        <%= String.format("%,d", product.getPrice().longValue()) %>đ
                    </div>

                    <div class="stock-status-inline">
                        <% if (product.getQuantity()> 0) { %>
                        <span class="stock-text in-stock">Còn hàng</span>
                        <span class="quantity-text">(Số lượng: <%= product.getQuantity() %>)</span>
                        <% } else { %>
                        <span class="stock-text out-stock">Hết hàng</span>
                        <% } %>
                    </div>

                    <div class="purchase-panel-new">
                        <form class="purchase-form" method="post" novalidate>
                            <input type="hidden" name="action" value="addToCart">
                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                            <input type="hidden" name="redirect" value="<%= currentUrl %>">

                            <div class="info-label">SỐ LƯỢNG</div>
                            <div class="quantity-box">
                                <input class="quantity-input" id="quantityInput" type="number" name="quantity" value="1" inputmode="numeric" min="1" step="1" max="<%= maxQuantity %>" data-max-quantity="<%= maxQuantity %>" aria-describedby="quantityError" aria-invalid="false" <%=product.getQuantity()> 0 ? "" : "disabled" %>>
                            </div>
                            <p id="quantityError" class="quantity-error" role="alert" aria-live="polite" hidden></p>

                            <div class="action-buttons">
                                <button type="submit" formaction="<%= contextPath %>/checkout" class="buy-btn" <%=product.getQuantity()> 0 ? "" : "disabled" %>>
                                    Mua ngay
                                </button>
                                <button type="button" onclick="handleAddToCartAjax(this, <%= product.getQuantity() > 0 %>)" class="add-cart-btn" data-add-to-cart-btn <%= product.getQuantity() > 0 ? "" : "disabled" %>>
                                    <i class="fa-solid fa-cart-shopping"></i> Giỏ hàng
                                </button>
                            </div>
                        </form>
                    </div>

                </div>

            </section>

            <section class="info-specs-card">
                <div class="info-specs-header">
                    <h2>Thông Tin Chi Tiết & Kỹ Thuật <%= product.getProductName() %></h2>
                    <p>Thông tin chi tiết về sản phẩm</p>
                </div>

                <div class="description-content-new">
                    <% if (product.getDescription() !=null && !product.getDescription().trim().isEmpty()) { %>
                    <p><%= product.getDescription() %></p>
                    <% } else { %>
                    <p>Chưa có mô tả cho sản phẩm này.</p>
                    <% } %>
                </div>

                <c:if test="${not empty specifications}">
                    <div class="specs-grid">
                        <c:forEach var="spec" items="${specifications}">
                            <div class="spec-card">
                                <div class="spec-icon">
                                    <i class="fa-solid fa-microchip"></i>
                                </div>
                                <div class="spec-info">
                                    <div class="spec-name">${spec.specificationName}</div>
                                    <div class="spec-value">${spec.specificationValue}</div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </section>

            <section class="similar-card">
                <div class="similar-header">
                    <h2>Sản phẩm tương tự</h2>
                    <p>Các sản phẩm cùng danh mục</p>
                </div>

                <% if (similarProducts !=null &&
                                                                    !similarProducts.isEmpty()) { %>

                <div class="similar-products-row">

                    <% for (Product item : similarProducts) { String
                        imageUrl=item.getImageUrl(); if
                        (imageUrl==null ||
                        imageUrl.trim().isEmpty()) {
                        imageUrl="images/no-image.png" ; } %>

                    <a class="similar-product-item"
                       href="<%= contextPath %>/product-detail?id=<%= item.getProductId() %>">

                        <div class="similar-product-img">
                            <img src="<%= contextPath %>/<%= imageUrl %>"
                                 alt="<%= item.getProductName() %>">
                        </div>

                        <h3>
                            <%= item.getProductName() %>
                        </h3>

                        <div class="similar-price">
                            <%= String.format("%,d",
                                                                                        item.getPrice().longValue()) %>đ
                        </div>

                    </a>

                    <% } %>

                </div>

                <% } else { %>

                <div class="empty-similar">
                    <i class="fa-regular fa-folder-open"></i>
                    <p>Không có sản phẩm tương tự.</p>
                </div>

                <% } %>
            </section>

            <section class="review-section">
                <h2>Đánh giá sản phẩm</h2>

                <div class="review-summary">

                    <div class="score">
                        <strong>
                            <%= String.format("%.1f", avgRating) %>
                        </strong>
                        <span>trên 5</span>

                        <p>
                            <% for (int i=1; i <=5; i++) { %>
                            <% if (i <=fullStars) { %>
                            <i class="fa-solid fa-star"></i>
                            <% } else if (i - 1 < avgRating && avgRating < i) { %>
                            <i
                                class="fa-solid fa-star-half-stroke"></i>
                            <% } else { %>
                            <i
                                class="fa-regular fa-star"></i>
                            <% } %>
                            <% } %>
                        </p>
                    </div>

                    <div class="review-stars-breakdown">

                        <div class="rating-bar-row">
                            <span class="bar-label">5 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill"
                                     style="width: <%= pct5 %>%"></div>
                            </div>
                            <span class="bar-count">
                                <%= count5 %>
                            </span>
                        </div>

                        <div class="rating-bar-row">
                            <span class="bar-label">4 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill"
                                     style="width: <%= pct4 %>%"></div>
                            </div>
                            <span class="bar-count">
                                <%= count4 %>
                            </span>
                        </div>

                        <div class="rating-bar-row">
                            <span class="bar-label">3 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill"
                                     style="width: <%= pct3 %>%"></div>
                            </div>
                            <span class="bar-count">
                                <%= count3 %>
                            </span>
                        </div>

                        <div class="rating-bar-row">
                            <span class="bar-label">2 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill"
                                     style="width: <%= pct2 %>%"></div>
                            </div>
                            <span class="bar-count">
                                <%= count2 %>
                            </span>
                        </div>

                        <div class="rating-bar-row">
                            <span class="bar-label">1 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill"
                                     style="width: <%= pct1 %>%"></div>
                            </div>
                            <span class="bar-count">
                                <%= count1 %>
                            </span>
                        </div>

                    </div>

                    <div class="review-filter">
                        <a class="review-filter-btn <%= selectedRating == 0 && !hasImage ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>">Tất cả (<%= totalAllReviews %>)</a>
                        <a class="review-filter-btn <%= hasImage ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %><%= selectedRating > 0 ? "&rating=" + selectedRating : "" %><%= hasImage ? "" : "&hasImage=true" %>">Có hình ảnh (<%= countHasImage %>)</a>
                        <a class="review-filter-btn <%= selectedRating == 5 && !hasImage ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=5<%= hasImage ? "&hasImage=true" : "" %>">5 sao (<%= count5 %>)</a>
                        <a class="review-filter-btn <%= selectedRating == 4 && !hasImage ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=4<%= hasImage ? "&hasImage=true" : "" %>">4 sao (<%= count4 %>)</a>
                        <a class="review-filter-btn <%= selectedRating == 3 && !hasImage ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=3<%= hasImage ? "&hasImage=true" : "" %>">3 sao (<%= count3 %>)</a>
                        <a class="review-filter-btn <%= selectedRating == 2 && !hasImage ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=2<%= hasImage ? "&hasImage=true" : "" %>">2 sao (<%= count2 %>)</a>
                        <a class="review-filter-btn <%= selectedRating == 1 && !hasImage ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=1<%= hasImage ? "&hasImage=true" : "" %>">1 sao (<%= count1 %>)</a>
                    </div>

                </div>

                <div class="review-list">

                    <% if (reviews !=null && !reviews.isEmpty()) { %>

                    <% for (Review review : reviews) { %>

                    <article class="review-item">

                        <div class="review-content">

                            <div class="review-content-header">
                                <div>
                                    <div class="reviewer-name"><%= review.getReviewerName() != null
                                            ? review.getReviewerName()
                                            : "User" %></div>
                                    <h4>Người dùng #<%=
                                            review.getUserId()
                                        %>
                                    </h4>

                                    <div class="review-stars">
                                        <% for (int i=1; i <=5;
                                                                                                    i++) { %>
                                        <% if (i
                                            <=review.getRating())
                                            { %>
                                        <i
                                            class="fa-solid fa-star"></i>
                                        <% } else { %>
                                        <i
                                            class="fa-regular fa-star"></i>
                                        <% } %>
                                        <% } %>
                                    </div>
                                </div>

                                <small>
                                    <i
                                        class="fa-regular fa-calendar-days"></i>
                                    <%= review.getDate() %>
                                </small>
                            </div>

                            <p>
                                <%= review.getComment() %>
                            </p>

                            <% if (review.getImages() !=null &&
                                !review.getImages().isEmpty()) {
                            %>
                            <div class="review-images-row"
                                 style="display: flex; gap: 8px; flex-wrap: wrap; margin-top: 8px;">
                                <% for (String imgPath :
                                                                                                review.getImages()) { %>
                                <div class="review-img-container"
                                     style="width: 80px; height: 80px; border-radius: 8px; overflow: hidden; border: 1px solid #e5e9f0;">
                                    <img class="review-img"
                                         src="<%= contextPath %>/<%= imgPath.trim() %>"
                                         alt="Hình ảnh đánh giá"
                                         style="width: 100%; height: 100%; object-fit: cover; cursor: pointer;"
                                         onclick="window.open(this.src, '_blank')">
                                </div>
                                <% } %>
                            </div>
                            <% } %>

                        </div>

                    </article>

                    <% } %>

                    <% } else { %>

                    <div class="empty-review">

                        <% if (selectedRating==0 && !hasImage) { %>
                        <p>Chưa có đánh giá nào cho
                            sản phẩm này.</p>
                            <% } else if (hasImage) { %>
                        <p>Không có đánh giá có hình ảnh nào<%= selectedRating > 0 ? (" (" + selectedRating + " sao)") : "" %>.</p>
                        <% } else { %>
                        <p>Không có đánh giá <%=
                                selectedRating
                            %> sao nào.</p>
                            <% } %>
                    </div>

                    <% } %>

                </div>

                <% if (totalPages > 1 && (reviews != null && !reviews.isEmpty())) { %>
                <div class="review-pagination">

                    <% if (currentPage > 1) { %>
                    <a href="<%= reviewPagingUrl + (currentPage - 1) %>">Trước</a>
                    <% } %>

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
                    <a class="<%= currentPage == 1 ? "active" : "" %>" href="<%= reviewPagingUrl + 1 %>">1</a>
                    <% if (fromPage > 2) { %>
                    <span>...</span>
                    <% } %>
                    <% for (int i = fromPage; i <= toPage; i++) { %>
                    <a class="<%= currentPage == i ? "active" : "" %>" href="<%= reviewPagingUrl + i %>">
                        <%= i %>
                    </a>
                    <% } %>
                    <% if (toPage < totalPages - 1) { %>
                    <span>...</span>
                    <% } %>
                    <% if (totalPages > 1) { %>
                    <a class="<%= currentPage == totalPages ? "active" : "" %>" href="<%= reviewPagingUrl + totalPages %>">
                        <%= totalPages %>
                    </a>
                    <% } %>

                    <% if (currentPage < totalPages) { %>
                    <a href="<%= reviewPagingUrl + (currentPage + 1) %>">Sau</a>
                    <% } %>
                </div>
                <% } %>

            </section>

            <script src="<%= contextPath %>/js/cart.js"></script>
            <script>
                                             var quantityValidationMessage = 'Số lượng phải là số nguyên từ 1 trở lên.';

                                             function showQuantityError(message) {
                                                 var quantityInput = document.getElementById('quantityInput');
                                                 var errorMessage = document.getElementById('quantityError');

                                                 if (!quantityInput || !errorMessage) {
                                                     return;
                                                 }

                                                 errorMessage.textContent = message;
                                                 errorMessage.hidden = false;
                                                 quantityInput.setAttribute('aria-invalid', 'true');
                                             }

                                             function clearQuantityError() {
                                                 var quantityInput = document.getElementById('quantityInput');
                                                 var errorMessage = document.getElementById('quantityError');

                                                 if (!quantityInput || !errorMessage) {
                                                     return;
                                                 }

                                                 errorMessage.textContent = '';
                                                 errorMessage.hidden = true;
                                                 quantityInput.setAttribute('aria-invalid', 'false');
                                             }

                                             function isTypingNumberKey(event) {
                                                 return event.key.length === 1 && /^\d$/.test(event.key);
                                             }

                                             function isControlKey(event) {
                                                 return event.ctrlKey || event.metaKey || [
                                                     'Backspace',
                                                     'Delete',
                                                     'Tab',
                                                     'Enter',
                                                     'Escape',
                                                     'ArrowLeft',
                                                     'ArrowRight',
                                                     'ArrowUp',
                                                     'ArrowDown',
                                                     'Home',
                                                     'End'
                                                 ].indexOf(event.key) !== -1;
                                             }

                                             function validateQuantity(form, showError) {
                                                 var quantityInput = form.querySelector('input[name="quantity"]');

                                                 if (!quantityInput) {
                                                     return true;
                                                 }

                                                 var maxQuantity = parseInt(quantityInput.dataset.maxQuantity || quantityInput.max || '1', 10);
                                                 var quantityText = quantityInput.value.trim();

                                                 if (quantityText === '' || !/^\d+$/.test(quantityText)) {
                                                     if (showError) {
                                                         showQuantityError(quantityValidationMessage);
                                                     }
                                                     quantityInput.focus();
                                                     return false;
                                                 }

                                                 var quantity = parseInt(quantityText, 10);

                                                 if (quantity < 1) {
                                                     if (showError) {
                                                         showQuantityError(quantityValidationMessage);
                                                     }
                                                     quantityInput.focus();
                                                     return false;
                                                 }

                                                 if (quantity > maxQuantity) {
                                                     if (showError) {
                                                         showQuantityError('Số lượng không được lớn hơn số lượng trong kho (' + maxQuantity + ').');
                                                     }
                                                     quantityInput.focus();
                                                     return false;
                                                 }

                                                 clearQuantityError();
                                                 return true;
                                             }

                                             function handleAddToCartAjax(btn, inStock) {
                                                 if (!inStock) {
                                                     showQuantityError('Sản phẩm này hiện tại đã hết hàng.');
                                                     return;
                                                 }

                                                 var form = btn.closest('form');
                                                 if (!validateQuantity(form, true)) {
                                                     return;
                                                 }

                                                 if (window.ProBuildCart && window.ProBuildCart.handleAddToCart) {
                                                     window.ProBuildCart.handleAddToCart(form);
                                                 } else {
                                                     form.submit();
                                                 }
                                             }

                                             document.addEventListener('DOMContentLoaded', function () {
                                                 var purchaseForm = document.querySelector('.purchase-form');
                                                 var quantityInput = document.querySelector('.purchase-form input[name="quantity"]');

                                                 if (quantityInput) {
                                                     quantityInput.addEventListener('keydown', function (event) {
                                                         if (isControlKey(event) || isTypingNumberKey(event)) {
                                                             return;
                                                         }

                                                         event.preventDefault();
                                                         showQuantityError(quantityValidationMessage);
                                                     });

                                                     quantityInput.addEventListener('paste', function (event) {
                                                         var pastedText = (event.clipboardData || window.clipboardData).getData('text');

                                                         if (/^\d+$/.test(pastedText)) {
                                                             return;
                                                         }

                                                         event.preventDefault();
                                                         showQuantityError(quantityValidationMessage);
                                                     });

                                                     quantityInput.addEventListener('input', function () {
                                                         if (quantityInput.value.trim() === '') {
                                                             showQuantityError(quantityValidationMessage);
                                                             return;
                                                         }

                                                         validateQuantity(purchaseForm, true);
                                                     });

                                                     quantityInput.addEventListener('blur', function () {
                                                         validateQuantity(purchaseForm, true);
                                                     });
                                                 }

                                                 if (purchaseForm) {
                                                     purchaseForm.addEventListener('submit', function (event) {
                                                         if (!validateQuantity(purchaseForm, true)) {
                                                             event.preventDefault();
                                                         }
                                                     });
                                                 }
                                             });
            </script>

        </main>

        <div class="home-toast" data-home-toast hidden>
            <div class="home-toast-icon" data-home-toast-icon aria-hidden="true">+</div>
            <div class="home-toast-message" data-home-toast-message></div>
        </div>

        <jsp:include page="/includes/footer.jsp" />

    </body>

</html>
