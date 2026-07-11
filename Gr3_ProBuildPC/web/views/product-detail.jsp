<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><c:out value="${product.productName}"/> - ProBuild PC</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product-detail.css?v=202">
    </head>

    <body class="product-detail-body" data-context-path="${pageContext.request.contextPath}">

        <jsp:include page="/includes/header.jsp" />

        <main class="product-detail-page">

            <c:if test="${not empty cartMessage}">
                <div class="server-message ${cartMessageType eq 'error' ? 'error' : 'success'}">
                    <c:out value="${cartMessage}"/>
                </div>
            </c:if>

            <div class="breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
                <span aria-hidden="true">&gt;</span>

                <a href="${pageContext.request.contextPath}/categories">Sản phẩm</a>
                <span aria-hidden="true">&gt;</span>

                <strong><c:out value="${product.productName}"/></strong>
            </div>

            <section class="detail-card">

                <div class="product-images">
                    <div class="main-image">
                        <img src="${pageContext.request.contextPath}/${fn:escapeXml(product.imageUrl)}"
                             alt="${fn:escapeXml(product.productName)}">
                    </div>
                </div>

                <div class="product-info">

                    <h1><c:out value="${product.productName}"/></h1>

                    <div class="product-meta-details">
                        <span class="meta-label">Thương hiệu:</span>
                        <span class="meta-value"><c:out value="${product.brandName}"/></span>

                        <span class="meta-divider">|</span>

                        <span class="meta-label">Danh mục:</span>
                        <span class="meta-value"><c:out value="${product.categoryName}"/></span>
                    </div>

                    <div class="rating-row">
                        <span class="rating-badge">
                            <fmt:formatNumber value="${avgRating}" pattern="0.0"/>
                            <i class="fa-solid fa-star"></i>
                        </span>

                        <span class="stars">
                            <c:forEach begin="1" end="5" var="i">
                                <c:choose>
                                    <c:when test="${i <= fullStars}">
                                        <i class="fa-solid fa-star"></i>
                                    </c:when>
                                    <c:when test="${i - 1 < avgRating && avgRating < i}">
                                        <i class="fa-solid fa-star-half-stroke"></i>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-regular fa-star"></i>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </span>

                        <span class="review-count">| ${totalAllReviews} đánh giá</span>
                    </div>

                    <div class="warranty-text">
                        Bảo hành: ${product.warrantyMonths} tháng chính hãng
                    </div>

                    <div class="price">
                        <fmt:formatNumber value="${product.price}" pattern="#,###"/>đ
                    </div>

                    <div class="stock-status-inline">
                        <c:choose>
                            <c:when test="${product.quantity > 0}">
                                <span class="stock-text in-stock">Còn hàng</span>
                                <span class="quantity-text">(Số lượng: ${product.quantity})</span>
                            </c:when>
                            <c:otherwise>
                                <span class="stock-text out-stock">Hết hàng</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="purchase-panel-new">
                        <form class="purchase-form"
                              method="post"
                              action="${pageContext.request.contextPath}/cart">
                            <input type="hidden" name="action" value="addToCart">
                            <input type="hidden" name="productId" value="${product.productId}">
                            <input type="hidden" name="redirect" value="${fn:escapeXml(currentUrl)}">

                            <div class="info-label">SỐ LƯỢNG</div>

                            <div class="quantity-box">
                                <input class="quantity-input"
                                       id="quantityInput"
                                       type="number"
                                       name="quantity"
                                       value="1"
                                       min="1"
                                       step="1"
                                       max="${maxQuantity}"
                                       data-max-quantity="${maxQuantity}"
                                       inputmode="numeric"
                                       ${product.quantity > 0 ? "" : "disabled"}>
                            </div>

                            <div class="action-buttons">
                                <button type="submit"
                                        formaction="${pageContext.request.contextPath}/checkout"
                                        class="buy-btn"
                                        ${product.quantity > 0 ? "" : "disabled"}>
                                    Mua ngay
                                </button>

                                <button type="submit"
                                        class="add-cart-btn"
                                        data-add-to-cart-btn
                                        ${product.quantity > 0 ? "" : "disabled"}>
                                    <i class="fa-solid fa-cart-shopping"></i> Giỏ hàng
                                </button>
                            </div>
                        </form>
                    </div>

                </div>

            </section>

            <section class="info-specs-card">
                <div class="info-specs-header">
                    <h2>Thông Tin Chi Tiết & Kỹ Thuật <c:out value="${product.productName}"/></h2>
                    <p>Thông tin chi tiết về sản phẩm</p>
                </div>

                <div class="description-content-new">
                    <c:choose>
                        <c:when test="${not empty product.description}">
                            <p><c:out value="${product.description}"/></p>
                        </c:when>
                        <c:otherwise>
                            <p>Chưa có mô tả cho sản phẩm này.</p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <c:if test="${not empty specifications}">
                    <div class="specs-grid">
                        <c:forEach var="spec" items="${specifications}">
                            <div class="spec-card">
                                <div class="spec-icon">
                                    <i class="fa-solid fa-microchip"></i>
                                </div>

                                <div class="spec-info">
                                    <div class="spec-name"><c:out value="${spec.specificationName}"/></div>
                                    <div class="spec-value"><c:out value="${spec.specificationValue}"/></div>
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

                <c:choose>
                    <c:when test="${not empty similarProducts}">
                        <div class="similar-products-row">
                            <c:forEach var="item" items="${similarProducts}">
                                <a class="similar-product-item"
                                   href="${pageContext.request.contextPath}/product-detail?id=${item.productId}">

                                    <div class="similar-product-img">
                                        <img src="${pageContext.request.contextPath}/${fn:escapeXml(empty item.imageUrl ? 'images/no-image.png' : item.imageUrl)}"
                                             alt="${fn:escapeXml(item.productName)}">
                                    </div>

                                    <h3><c:out value="${item.productName}"/></h3>

                                    <div class="similar-price">
                                        <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                    </div>
                                </a>
                            </c:forEach>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="empty-similar">
                            <i class="fa-regular fa-folder-open"></i>
                            <p>Không có sản phẩm tương tự.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <section class="review-section">
                <h2>Đánh giá sản phẩm</h2>

                <div class="review-summary">

                    <div class="score">
                        <strong>
                            <fmt:formatNumber value="${avgRating}" pattern="0.0"/>
                        </strong>

                        <span>trên 5</span>

                        <p>
                            <c:forEach begin="1" end="5" var="i">
                                <c:choose>
                                    <c:when test="${i <= fullStars}">
                                        <i class="fa-solid fa-star"></i>
                                    </c:when>
                                    <c:when test="${i - 1 < avgRating && avgRating < i}">
                                        <i class="fa-solid fa-star-half-stroke"></i>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="fa-regular fa-star"></i>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </p>
                    </div>

                    <div class="review-stars-breakdown">

                        <div class="rating-bar-row">
                            <span class="bar-label">5 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill" style="width: ${pct5}%"></div>
                            </div>
                            <span class="bar-count">${count5}</span>
                        </div>

                        <div class="rating-bar-row">
                            <span class="bar-label">4 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill" style="width: ${pct4}%"></div>
                            </div>
                            <span class="bar-count">${count4}</span>
                        </div>

                        <div class="rating-bar-row">
                            <span class="bar-label">3 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill" style="width: ${pct3}%"></div>
                            </div>
                            <span class="bar-count">${count3}</span>
                        </div>

                        <div class="rating-bar-row">
                            <span class="bar-label">2 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill" style="width: ${pct2}%"></div>
                            </div>
                            <span class="bar-count">${count2}</span>
                        </div>

                        <div class="rating-bar-row">
                            <span class="bar-label">1 sao</span>
                            <div class="bar-track">
                                <div class="bar-fill" style="width: ${pct1}%"></div>
                            </div>
                            <span class="bar-count">${count1}</span>
                        </div>
                    </div>

                    <div class="review-filter">
                        <a class="review-filter-btn ${selectedRating == 0 ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/product-detail?id=${product.productId}">
                            Tất cả (${totalAllReviews})
                        </a>

                        <a class="review-filter-btn ${selectedRating == 5 ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/product-detail?id=${product.productId}&rating=5">
                            5 sao (${count5})
                        </a>

                        <a class="review-filter-btn ${selectedRating == 4 ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/product-detail?id=${product.productId}&rating=4">
                            4 sao (${count4})
                        </a>

                        <a class="review-filter-btn ${selectedRating == 3 ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/product-detail?id=${product.productId}&rating=3">
                            3 sao (${count3})
                        </a>

                        <a class="review-filter-btn ${selectedRating == 2 ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/product-detail?id=${product.productId}&rating=2">
                            2 sao (${count2})
                        </a>

                        <a class="review-filter-btn ${selectedRating == 1 ? 'active' : ''}"
                           href="${pageContext.request.contextPath}/product-detail?id=${product.productId}&rating=1">
                            1 sao (${count1})
                        </a>
                    </div>

                </div>

                <div class="review-list">

                    <c:choose>
                        <c:when test="${not empty reviews}">
                            <c:forEach var="review" items="${reviews}">
                                <article class="review-item">

                                    <div class="avatar">
                                        U<c:out value="${review.userId}"/>
                                    </div>

                                    <div class="review-content">

                                        <div class="review-content-header">
                                            <div>
                                                <h4>Người dùng #<c:out value="${review.userId}"/></h4>

                                                <div class="review-stars">
                                                    <c:forEach begin="1" end="5" var="i">
                                                        <c:choose>
                                                            <c:when test="${i <= review.rating}">
                                                                <i class="fa-solid fa-star"></i>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fa-regular fa-star"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:forEach>
                                                </div>
                                            </div>

                                            <small>
                                                <i class="fa-regular fa-calendar-days"></i>
                                                <fmt:formatDate value="${review.date}" pattern="dd/MM/yyyy HH:mm"/>
                                            </small>
                                        </div>

                                        <p><c:out value="${review.comment}"/></p>

                                        <c:if test="${not empty review.images}">
                                            <div class="review-images-row">
                                                <c:forEach var="imgPath" items="${review.images}">
                                                    <div class="review-img-container">
                                                        <a href="${pageContext.request.contextPath}/${fn:escapeXml(imgPath)}"
                                                           target="_blank"
                                                           rel="noopener noreferrer">
                                                            <img class="review-img"
                                                                 src="${pageContext.request.contextPath}/${fn:escapeXml(imgPath)}"
                                                                 alt="Hình ảnh đánh giá">
                                                        </a>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>

                                    </div>

                                </article>
                            </c:forEach>
                        </c:when>

                        <c:otherwise>
                            <div class="empty-review">

                                <c:choose>
                                    <c:when test="${selectedRating == 0}">
                                        <p>Chưa có đánh giá nào cho sản phẩm này.</p>
                                    </c:when>
                                    <c:otherwise>
                                        <p>Không có đánh giá ${selectedRating} sao nào.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:otherwise>
                    </c:choose>

                </div>
            </section>

        </main>

        <div class="home-toast" data-home-toast hidden>
            <div class="home-toast-icon" data-home-toast-icon aria-hidden="true">+</div>
            <div class="home-toast-message" data-home-toast-message></div>
        </div>

        <jsp:include page="/includes/footer.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="${pageContext.request.contextPath}/js/cart.js"></script>
        <script src="${pageContext.request.contextPath}/js/product-detail.js?v=203"></script>

    </body>
</html>
