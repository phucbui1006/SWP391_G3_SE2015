<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ page import="java.util.List" %>
            <%@ page import="model.Product" %>
                <%@ page import="model.Review" %>

                    <% String contextPath=request.getContextPath(); Product product=(Product)
                        request.getAttribute("product"); List<Review> reviews = (List<Review>)
                            request.getAttribute("reviews");
                            List<Review> allReviews = (List<Review>) request.getAttribute("allReviews");
                                    List<Product> similarProducts = (List<Product>)
                                            request.getAttribute("similarProducts");

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

                                            int fullStars = (int) avgRating;
                                            int maxQuantity = product.getQuantity() > 0 ? product.getQuantity() : 1;

                                            String currentUrl = contextPath + "/product-detail";
                                            if (request.getQueryString() != null &&
                                            !request.getQueryString().trim().isEmpty()) {
                                            currentUrl += "?" + request.getQueryString();
                                            } else {
                                            currentUrl += "?id=" + product.getProductId();
                                            }

                                            int totalAllReviews = allReviews == null ? 0 : allReviews.size();

                                            int count5 = 0;
                                            int count4 = 0;
                                            int count3 = 0;
                                            int count2 = 0;
                                            int count1 = 0;

                                            if (allReviews != null) {
                                            for (Review r : allReviews) {
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
                                                    href="<%= contextPath %>/css/product-detail.css?v=200">
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

                                                            <div class="breadcrumb">
                                                                <a href="<%= contextPath %>/home">Trang chủ</a>
                                                                <span><i class="fa-solid fa-chevron-right"></i></span>

                                                                <a href="<%= contextPath %>/categories">Sản phẩm</a>
                                                                <span><i class="fa-solid fa-chevron-right"></i></span>

                                                                <strong>
                                                                    <%= product.getProductName() %>
                                                                </strong>
                                                            </div>

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
                                                                        <div class="meta-item">
                                                                            <span class="meta-label">Thương hiệu:</span>
                                                                            <span class="meta-value">
                                                                                <%= product.getBrandName() %>
                                                                            </span>
                                                                        </div>
                                                                        <span class="meta-divider">|</span>
                                                                        <div class="meta-item">
                                                                            <span class="meta-label">Danh mục:</span>
                                                                            <span class="meta-value">
                                                                                <%= product.getCategoryName() %>
                                                                            </span>
                                                                        </div>
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
                                                                                    <% } else if (i - 1 < avgRating &&
                                                                                        avgRating < i) { %>
                                                                                        <i
                                                                                            class="fa-solid fa-star-half-stroke"></i>
                                                                                        <% } else { %>
                                                                                            <i
                                                                                                class="fa-regular fa-star"></i>
                                                                                            <% } %>
                                                                                                <% } %>
                                                                        </span>

                                                                        <span class="review-count">| <%= totalAllReviews
                                                                                %> đánh giá</span>
                                                                    </div>

                                                                    <div class="price">
                                                                        <%= String.format("%,d",
                                                                            product.getPrice().longValue()) %>đ
                                                                    </div>

                                                                    <div class="stock-status">
                                                                        <% if (product.getQuantity()> 0) { %>
                                                                            <span class="badge-stock in-stock">Còn
                                                                                hàng</span>
                                                                            <span class="quantity-text">Số lượng trong
                                                                                kho: <%= product.getQuantity() %></span>
                                                                            <% } else { %>
                                                                                <span class="badge-stock out-stock">Hết
                                                                                    hàng</span>
                                                                                <% } %>
                                                                                    <span class="meta-divider"
                                                                                        style="color: #cbd5e1; font-weight: 300; margin: 0 4px;">|</span>
                                                                                    <span class="quantity-text">Bảo
                                                                                        hành: <%=
                                                                                            product.getWarrantyMonths()
                                                                                            %> tháng</span>
                                                                    </div>

                                                                    <div class="purchase-panel">

                                                                        <form class="purchase-form" method="post">
                                                                            <input type="hidden" name="action" value="addToCart"><input type="hidden" name="productId"
                                                                                value="<%= product.getProductId() %>">
                                                                            <input type="hidden" name="redirect"
                                                                                value="<%= currentUrl %>">

                                                                            <div class="quantity-box">
                                                                                <span>Số lượng:</span>

                                                                                <input class="quantity-input"
                                                                                    type="number" name="quantity"
                                                                                    value="1" inputmode="numeric"
                                                                                    min="1" step="1"
                                                                                    max="<%= maxQuantity %>"
                                                                                    data-max-quantity="<%= maxQuantity %>"
                                                                                    <%=product.getQuantity()> 0 ? "" :
                                                                                "disabled" %>>
                                                                            </div>

                                                                            <div class="action-buttons">

                                                                                <button type="button"
                                                                                    onclick="handleAddToCartAjax(this, <%= product.getQuantity() > 0 %>)"
                                                                                    class="add-cart-btn"
                                                                                    data-add-to-cart-btn
                                                                                    <%= product.getQuantity() > 0 ? "" : "style=\"opacity: 0.6; cursor: not-allowed; background: #e5e7eb; border-color: #e5e7eb; color: #9ca3af;\"" %>>
                                                                                    <i class="fa-solid fa-cart-shopping"></i>
                                                                                    Thêm vào giỏ
                                                                                </button>

                                                                                <button type="submit"
                                                                                    formaction="<%= contextPath %>/checkout"
                                                                                    class="buy-btn"
                                                                                    <%=product.getQuantity()> 0 ? "" :
                                                                                    "disabled" %>>
                                                                                    Mua ngay
                                                                                </button>

                                                                            </div>
                                                                        </form>

                                                                    </div>

                                                                </div>

                                                            </section>

                                                            <section class="description-card">
                                                                <div class="description-box">
                                                                    <div class="description-title-row">
                                                                        <div>
                                                                            <h2>Mô tả sản phẩm</h2>
                                                                            <span>Thông tin chi tiết về sản phẩm</span>
                                                                        </div>
                                                                    </div>

                                                                    <div class="description-content">
                                                                        <% if (product.getDescription() !=null &&
                                                                            !product.getDescription().trim().isEmpty())
                                                                            { %>
                                                                            <p>
                                                                                <%= product.getDescription() %>
                                                                            </p>
                                                                            <% } else { %>
                                                                                <p>Chưa có mô tả cho sản phẩm này.</p>
                                                                                <% } %>
                                                                    </div>
                                                                </div>
                                                            </section>

                                                            <c:if test="${not empty specifications}">
                                                                <section class="probuild-specs-container">
                                                                    <div class="probuild-specs-box">
                                                                        <div class="probuild-specs-header">
                                                                            <h2>Thông số kỹ thuật</h2>
                                                                            <p>Thông số kỹ thuật chi tiết của sản phẩm</p>
                                                                        </div>
                                                                        <div class="probuild-specs-table-wrap">
                                                                            <table class="probuild-specs-table">
                                                                                <tbody>
                                                                                    <c:forEach var="spec" items="${specifications}">
                                                                                        <tr>
                                                                                            <td class="probuild-item-name">${spec.specificationName}</td>
                                                                                            <td class="probuild-item-value">${spec.specificationValue}</td>
                                                                                        </tr>
                                                                                    </c:forEach>
                                                                                </tbody>
                                                                            </table>
                                                                        </div>
                                                                    </div>
                                                                </section>
                                                            </c:if>

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
                                                                                    <% } else if (i - 1 < avgRating &&
                                                                                        avgRating < i) { %>
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
                                                                        <a class="review-filter-btn <%= selectedRating == 0 ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>">Tất cả (<%= totalAllReviews %>)</a>
                                                                        <a class="review-filter-btn <%= selectedRating == 5 ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=5">5 sao (<%= count5 %>)</a>
                                                                        <a class="review-filter-btn <%= selectedRating == 4 ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=4">4 sao (<%= count4 %>)</a>
                                                                        <a class="review-filter-btn <%= selectedRating == 3 ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=3">3 sao (<%= count3 %>)</a>
                                                                        <a class="review-filter-btn <%= selectedRating == 2 ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=2">2 sao (<%= count2 %>)</a>
                                                                        <a class="review-filter-btn <%= selectedRating == 1 ? "active" : "" %>" href="<%= contextPath %>/product-detail?id=<%= product.getProductId() %>&rating=1">1 sao (<%= count1 %>)</a>
                                                                    </div>

                                                                </div>

                                                                <div class="review-list">

                                                                    <% if (reviews !=null && !reviews.isEmpty()) { %>

                                                                        <% for (Review review : reviews) { String
                                                                            nameSeed=String.valueOf(review.getUserId());
                                                                            String
                                                                            initial=nameSeed.substring(Math.max(0,
                                                                            nameSeed.length() - 2)); %>

                                                                            <article class="review-item">

                                                                                <div class="avatar">
                                                                                    U<%= initial %>
                                                                                </div>

                                                                                <div class="review-content">

                                                                                    <div class="review-content-header">
                                                                                        <div>
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
                                                                                        <i
                                                                                            class="fa-regular fa-comment-dots"></i>

                                                                                        <% if (selectedRating==0) { %>
                                                                                            <p>Chưa có đánh giá nào cho
                                                                                                sản phẩm này.</p>
                                                                                            <% } else { %>
                                                                                                <p>Không có đánh giá <%=
                                                                                                        selectedRating
                                                                                                        %> sao nào.</p>
                                                                                                <% } %>
                                                                                    </div>

                                                                                    <% } %>

                                                                </div>
                                                            </section>

                                                            <script
                                                                src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                                                            <script src="<%= contextPath %>/js/cart.js"></script>
                                                            <script>
                                                                function showQuantityError(message) {
                                                                    Swal.fire({
                                                                        title: 'Số lượng không hợp lệ!',
                                                                        text: message,
                                                                        icon: 'warning',
                                                                        timer: 3000,
                                                                        showConfirmButton: false,
                                                                        toast: true,
                                                                        position: 'bottom-end'
                                                                    });
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
                                                                            showQuantityError('Vui lòng chỉ nhập số cho số lượng.');
                                                                        }
                                                                        quantityInput.focus();
                                                                        return false;
                                                                    }

                                                                    var quantity = parseInt(quantityText, 10);

                                                                    if (quantity < 1) {
                                                                        if (showError) {
                                                                            showQuantityError('Số lượng phải lớn hơn hoặc bằng 1.');
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

                                                                    return true;
                                                                }

                                                                function handleAddToCartAjax(btn, inStock) {
                                                                    if (!inStock) {
                                                                        Swal.fire({
                                                                            title: 'Hết hàng!',
                                                                            text: 'Sản phẩm này hiện tại đã hết hàng.',
                                                                            icon: 'error',
                                                                            timer: 3000,
                                                                            showConfirmButton: false,
                                                                            toast: true,
                                                                            position: 'bottom-end'
                                                                        });
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
                                                                            showQuantityError('Vui lòng chỉ nhập số cho số lượng.');
                                                                        });

                                                                        quantityInput.addEventListener('paste', function (event) {
                                                                            var pastedText = (event.clipboardData || window.clipboardData).getData('text');

                                                                            if (/^\d+$/.test(pastedText)) {
                                                                                return;
                                                                            }

                                                                            event.preventDefault();
                                                                            showQuantityError('Vui lòng chỉ nhập số cho số lượng.');
                                                                        });

                                                                        quantityInput.addEventListener('blur', function () {
                                                                            validateQuantity(purchaseForm, quantityInput.value.trim() !== '');
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
