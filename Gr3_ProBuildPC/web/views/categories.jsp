<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Danh mục sản phẩm - ProBuild PC</title>

                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=2">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/categories.css?v=54">
            </head>

            <body class="categories-page" data-context-path="${pageContext.request.contextPath}">
                <jsp:include page="/includes/header.jsp" />

                <main class="category-page">

                    <c:if test="${not empty cartMessage}">
                        <div class="server-message ${cartMessageType == 'error' ? 'error' : 'success'}">
                            <c:out value="${cartMessage}" />
                        </div>
                    </c:if>

                    <nav class="category-breadcrumb site-breadcrumb" aria-label="Breadcrumb">
                        <a href="${pageContext.request.contextPath}/home">Trang chủ</a>
                        <span>›</span>
                        <strong>Danh mục sản phẩm</strong>
                    </nav>

                    <section class="category-heading">
                        <div>
                            <h1>Danh mục sản phẩm</h1>
                            <p>Lựa chọn linh kiện theo từng nhóm sản phẩm</p>
                        </div>
                    </section>

                    <section class="category-layout">

                        <aside class="category-sidebar" aria-label="Bộ lọc danh mục">
                            <form action="${pageContext.request.contextPath}/categories" method="get"
                                class="category-filter-form">

                                <input type="hidden" name="sort" value="${selectedSort}">

                                <c:if test="${not empty keyword}">
                                    <input type="hidden" name="keyword" value="${keyword}">
                                </c:if>

                                <c:if test="${not empty contentKeyword}">
                                    <input type="hidden" name="contentKeyword" value="${contentKeyword}">
                                </c:if>

                                <div class="filter-panel">
                                    <div class="filter-title">
                                        <h2>Danh mục</h2>
                                        <span>−</span>
                                    </div>

                                    <label class="${selectedCategory == null ? 'is-checked' : ''}">
                                        <input type="radio" name="id" value="" ${selectedCategory==null ? 'checked' : ''
                                            }>
                                        Tất cả sản phẩm
                                    </label>

                                    <c:forEach var="c" items="${categories}">
                                        <label
                                            class="${selectedCategory != null && selectedCategory.categoryId == c.categoryId ? 'is-checked' : ''}">
                                            <input type="radio" name="id" value="${c.categoryId}" ${selectedCategory
                                                !=null && selectedCategory.categoryId==c.categoryId ? 'checked' : '' }>
                                            <c:out value="${c.categoryName}" />
                                            <span class="category-count">(${c.productCount})</span>
                                        </label>
                                    </c:forEach>

                                    <div class="filter-actions">
                                        <button type="submit" class="apply-filter-btn">Áp dụng</button>

                                        <c:if test="${not empty keyword || not empty contentKeyword}">
                                            <c:url var="clearSearchUrl" value="/categories">
                                                <c:if test="${selectedCategory != null}">
                                                    <c:param name="id" value="${selectedCategory.categoryId}" />
                                                </c:if>
                                                <c:param name="sort" value="${selectedSort}" />
                                            </c:url>

                                            <a class="clear-search-btn" href="${clearSearchUrl}">
                                                Xóa tìm kiếm
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                            </form>
                        </aside>

                        <section class="category-content">

                            <div class="category-result-head">
                                <div>
                                    <h2>
                                        <c:choose>
                                            <c:when test="${not empty contentKeyword}">
                                                Kết quả tìm kiếm: "
                                                <c:out value="${contentKeyword}" />"
                                            </c:when>

                                            <c:when test="${not empty keyword}">
                                                Kết quả tìm kiếm: "
                                                <c:out value="${keyword}" />"
                                            </c:when>

                                            <c:otherwise>
                                                <c:out value="${title}" />
                                            </c:otherwise>
                                        </c:choose>

                                        <span>(${totalProducts} sản phẩm)</span>
                                    </h2>

                                    <p>Hiển thị ${totalProducts} sản phẩm</p>
                                </div>

                                <form action="${pageContext.request.contextPath}/categories" method="get"
                                    class="category-product-search-form">

                                    <c:if test="${selectedCategory != null}">
                                        <input type="hidden" name="id" value="${selectedCategory.categoryId}">
                                    </c:if>

                                    <input type="hidden" name="sort" value="${selectedSort}">

                                    <input type="text" name="contentKeyword" value="${contentKeyword}"
                                        placeholder="Tìm sản phẩm theo tên/loại...">

                                    <button type="submit">Tìm kiếm</button>
                                </form>

                                <form action="${pageContext.request.contextPath}/categories" method="get"
                                    class="category-sort-form">

                                    <c:if test="${selectedCategory != null}">
                                        <input type="hidden" name="id" value="${selectedCategory.categoryId}">
                                    </c:if>

                                    <c:if test="${not empty keyword}">
                                        <input type="hidden" name="keyword" value="${keyword}">
                                    </c:if>

                                    <c:if test="${not empty contentKeyword}">
                                        <input type="hidden" name="contentKeyword" value="${contentKeyword}">
                                    </c:if>

                                    <label>
                                        Sắp xếp:
                                        <select name="sort" onchange="this.form.submit()">
                                            <option value="newest" ${selectedSort=='newest' ? 'selected' : '' }>Mới nhất
                                            </option>
                                            <option value="price_asc" ${selectedSort=='price_asc' ? 'selected' : '' }>
                                                Giá thấp đến cao</option>
                                            <option value="price_desc" ${selectedSort=='price_desc' ? 'selected' : '' }>
                                                Giá cao đến thấp</option>
                                        </select>
                                    </label>
                                </form>
                            </div>

                            <div class="category-product-grid">

                                <c:choose>
                                    <c:when test="${not empty products}">

                                        <c:forEach var="p" items="${products}">
                                            <article class="product-card">

                                                <figure>
                                                    <c:choose>
                                                        <c:when test="${not empty p.imageUrl}">
                                                            <img src="${pageContext.request.contextPath}/${p.imageUrl}"
                                                                alt="${p.productName}">
                                                        </c:when>

                                                        <c:otherwise>
                                                            <span>PC</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </figure>

                                                <h3>
                                                    <c:out value="${p.productName}" />
                                                </h3>

                                                <strong>
                                                    <fmt:formatNumber value="${p.price}" pattern="#,###" />đ
                                                </strong>

                                                <c:set var="rating" value="${productRatings[p.productId]}" />
                                                <div class="product-rating" aria-label="Đánh giá ${rating} trên 5 sao">
                                                    <c:forEach begin="1" end="5" var="star">
                                                        <i class="${star <= rating ? 'fa-solid' : 'fa-regular'} fa-star"
                                                            aria-hidden="true"></i>
                                                    </c:forEach>
                                                    <span>
                                                        <fmt:formatNumber value="${rating}" minFractionDigits="1"
                                                            maxFractionDigits="1" />
                                                    </span>
                                                </div>

                                                <p
                                                    class="product-stock ${p.quantity > 0 ? 'in-stock' : 'out-of-stock'}">
                                                    <c:choose>
                                                        <c:when test="${p.quantity > 0}">
                                                            Còn hàng: ${p.quantity}
                                                        </c:when>

                                                        <c:otherwise>
                                                            Hết hàng
                                                        </c:otherwise>
                                                    </c:choose>
                                                </p>

                                                <div class="product-actions">
                                                    <a class="detail-btn"
                                                        href="${pageContext.request.contextPath}/product-detail?id=${p.productId}">
                                                        Xem chi tiết
                                                    </a>

                                                    <form class="cart-form"
                                                        action="${pageContext.request.contextPath}/cart" method="post">
                                                        <input type="hidden" name="action" value="addToCart">
                                                        <input type="hidden" name="productId" value="${p.productId}">
                                                        <input type="hidden" name="quantity" value="1">

                                                        <button class="cart-btn" type="submit" data-add-to-cart-btn
                                                            data-product-name="${p.productName}" ${p.quantity> 0 ? '' :
                                                            'disabled'}
                                                            >
                                                            <i class="fa-solid fa-cart-shopping"></i>
                                                        </button>
                                                    </form>
                                                </div>
                                            </article>
                                        </c:forEach>
                                    </c:when>

                                    <c:otherwise>
                                        <div class="category-empty">
                                            <h3>Chưa có sản phẩm trong danh mục này</h3>
                                            <p>Vui lòng chọn danh mục khác.</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <c:if test="${totalPages > 1}">
                                <div class="category-pagination">

                                    <c:if test="${currentPage > 1}">
                                        <c:set var="previousPageUrl" value="${pagingUrl}${currentPage - 1}" />
                                        <a href="<c:out value=" ${previousPageUrl}" />">&lt;</a>
                                    </c:if>

                                    <c:choose>
                                        <c:when test="${currentPage <= 4}">
                                            <c:set var="fromPage" value="2" />
                                            <c:set var="toPage" value="${totalPages - 1 < 5 ? totalPages - 1 : 5}" />
                                        </c:when>

                                        <c:when test="${currentPage >= totalPages - 3}">
                                            <c:set var="fromPage" value="${totalPages - 4 > 2 ? totalPages - 4 : 2}" />
                                            <c:set var="toPage" value="${totalPages - 1}" />
                                        </c:when>

                                        <c:otherwise>
                                            <c:set var="fromPage" value="${currentPage - 2}" />
                                            <c:set var="toPage" value="${currentPage + 2}" />
                                        </c:otherwise>
                                    </c:choose>

                                    <c:set var="firstPageUrl" value="${pagingUrl}1" />
                                    <a class="${currentPage == 1 ? 'active' : ''}" href="<c:out value="
                                        ${firstPageUrl}" />">1</a>

                                    <c:if test="${fromPage > 2}">
                                        <span>...</span>
                                    </c:if>

                                    <c:forEach begin="${fromPage}" end="${toPage}" var="pageNumber">
                                        <c:set var="numberedPageUrl" value="${pagingUrl}${pageNumber}" />
                                        <a class="${currentPage == pageNumber ? 'active' : ''}" href="<c:out value="
                                            ${numberedPageUrl}" />">
                                        ${pageNumber}
                                        </a>
                                    </c:forEach>

                                    <c:if test="${toPage < totalPages - 1}">
                                        <span>...</span>
                                    </c:if>

                                    <c:set var="lastPageUrl" value="${pagingUrl}${totalPages}" />
                                    <a class="${currentPage == totalPages ? 'active' : ''}" href="<c:out value="
                                        ${lastPageUrl}" />">
                                    ${totalPages}
                                    </a>

                                    <c:if test="${currentPage < totalPages}">
                                        <c:set var="nextPageUrl" value="${pagingUrl}${currentPage + 1}" />
                                        <a href="<c:out value=" ${nextPageUrl}" />">&gt;</a>
                                    </c:if>

                                </div>
                            </c:if>
                        </section>
                    </section>
                </main>

                <div class="home-toast" data-home-toast hidden>
                    <div class="home-toast-icon" data-home-toast-icon aria-hidden="true">+</div>
                    <div class="home-toast-message" data-home-toast-message></div>
                </div>

                <jsp:include page="/includes/footer.jsp" />

                <script src="${pageContext.request.contextPath}/js/cart.js"></script>
            </body>

            </html>
