<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="dal.ProductDAO" %>

<%!
    private String h(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    String ctx = request.getContextPath();
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Product> products = (List<Product>) request.getAttribute("products");
    ProductDAO productDAO = (ProductDAO) request.getAttribute("productDAO");
    String keyword = (String) request.getAttribute("keyword");
    boolean hasKeyword = keyword != null && !keyword.trim().isEmpty();
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
        <jsp:include page="/includes/header.jsp" />

        <main class="page-shell">
            <aside class="sidebar">
                <h2>DANH MỤC SẢN PHẨM</h2>

                <ul class="category-list">
                    <% if (categories != null) {
                        for (Category category : categories) {
                    %>
                    <li>
                        <a href="<%= ctx %>/categories?id=<%= category.getCategoryId() %>">
                            ▣ <%= category.getCategoryName() %>
                        </a>
                    </li>
                    <% }} %>
                </ul>

                <a class="all-categories" href="<%= ctx %>/categories">
                    ▦ Xem tất cả danh mục
                </a>
            </aside>

            <section class="content">
                <section class="hero-banner">
                    <div class="hero-copy">
                        <p>ProBUILD PC</p>
                        <h1>
                            ĐỈNH CAO HIỆU NĂNG<br>
                            NÂNG TẦM TRẢI NGHIỆM
                        </h1>
                        <span>
                           TRỐN NẮNG TRONG PHÒNG - 
                            BUILD PC ĐỈNH DÒNG
                        </span>
                        <a href="#" style="
                           padding-left: 10px;
                           padding-right: 10px;">BUILD NGAY PC <br> BẠN YÊU THÍCH</a>
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
                                <form class="filters" action="<%= ctx %>/categories" method="get">
                                    <label>
                                        Danh mục:
                                        <select name="id">
                                            <option value="">Tất cả</option>
                                            <% if (categories != null) {
                                                for (Category category : categories) {
                                            %>
                                            <option value="<%= category.getCategoryId() %>">
                                                <%= category.getCategoryName() %>
                                            </option>
                                            <% }} %>
                                        </select>
                                    </label>
                                    <button class="home-filter-btn" type="submit">Lọc</button>
                                </form>

                                <form class="sort-box" action="<%= ctx %>/categories" method="get">
                                    <label>
                                        Sắp xếp:
                                        <select name="sort">
                                            <option value="newest">Mới nhất</option>
                                            <option value="price_asc">Giá tăng dần</option>
                                            <option value="price_desc">Giá giảm dần</option>
                                        </select>
                                    </label>
                                    <button class="home-filter-btn" type="submit">Áp dụng</button>
                                </form>
                            </section>

                            <% if (hasKeyword) { %>
                            <div class="home-search-result">
                                <h2>Kết quả tìm kiếm cho "<%= h(keyword) %>"</h2>
                                <a href="<%= ctx %>/home">Xem tất cả sản phẩm</a>
                            </div>
                            <% } %>

                            <section class="product-grid">
                                <% if (products != null && !products.isEmpty()) {
                                    for (Product product : products) {
                                        double rating = productDAO == null ? 0 : productDAO.getAverageRating(product.getProductId());
                                        int fullStars = (int) rating;
                                %>
                                <article class="product-card">
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
                                        <a class="detail-btn" href="<%= ctx %>/product-detail?id=<%= product.getProductId() %>">
                                            Xem chi tiết
                                        </a>

                                        <form class="cart-form" action="<%= ctx %>/cart" method="post">
                                            <input type="hidden" name="action" value="addToCart">
                                            <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                                            <input type="hidden" name="quantity" value="1">
                                            <button class="cart-btn" type="submit" data-add-to-cart-btn data-product-name="<%= h(product.getProductName()) %>" <%= product.getQuantity() > 0 ? "" : "disabled" %>>
                                                🛒
                                            </button>
                                        </form>
                                    </div>
                                </article>
                                <% }} else { %>
                                <p class="home-empty-message">
                                    <%= hasKeyword ? "Không tìm thấy sản phẩm phù hợp." : "Không có sản phẩm nào để hiển thị." %>
                                </p>
                                <% } %>
                            </section>
                            </section>
                            </main>

                            <div class="home-toast" data-home-toast hidden>
                                <div class="home-toast-icon" data-home-toast-icon aria-hidden="true">+</div>
                                <div class="home-toast-message" data-home-toast-message></div>
                            </div>

                            <jsp:include page="/includes/footer.jsp" />

                            <script>
                                (function () {
                                    const addToCartForms = document.querySelectorAll('.cart-form');
                                    const headerCartCountElement = document.querySelector('.cart-box .cart-icon span');
                                    const cartIconElement = document.querySelector('.cart-box .cart-icon');
                                    const toastElement = document.querySelector('[data-home-toast]');
                                    const toastMessageElement = document.querySelector('[data-home-toast-message]');
                                    const toastIconElement = document.querySelector('[data-home-toast-icon]');
                                    let toastTimerId = null;

                                    if (!addToCartForms.length) {
                                        return;
                                    }

                                    const showToast = function (message, isSuccess) {
                                        if (!toastElement || !toastMessageElement || !toastIconElement) {
                                            return;
                                        }

                                        if (toastTimerId) {
                                            window.clearTimeout(toastTimerId);
                                        }

                                        toastMessageElement.textContent = message;
                                        toastIconElement.textContent = isSuccess ? '+' : '!';
                                        toastElement.hidden = false;
                                        toastElement.classList.remove('is-success', 'is-error');
                                        toastElement.classList.add(isSuccess ? 'is-success' : 'is-error');

                                        window.requestAnimationFrame(function () {
                                            toastElement.classList.add('is-visible');
                                        });

                                        toastTimerId = window.setTimeout(function () {
                                            toastElement.classList.remove('is-visible');
                                            window.setTimeout(function () {
                                                if (!toastElement.classList.contains('is-visible')) {
                                                    toastElement.hidden = true;
                                                }
                                            }, 220);
                                        }, 2600);
                                    };

                                    const animateProductFlyToCart = function (form) {
                                        if (!cartIconElement || !form) {
                                            return;
                                        }

                                        const productCard = form.closest('.product-card');
                                        const productImage = productCard ? productCard.querySelector('figure img') : null;

                                        if (!productImage) {
                                            cartIconElement.classList.add('is-bumping');
                                            window.setTimeout(function () {
                                                cartIconElement.classList.remove('is-bumping');
                                            }, 520);
                                            return;
                                        }

                                        const imageRect = productImage.getBoundingClientRect();
                                        const cartRect = cartIconElement.getBoundingClientRect();
                                        const flyingImage = productImage.cloneNode(true);

                                        flyingImage.className = 'home-cart-flight';
                                        flyingImage.alt = '';
                                        flyingImage.setAttribute('aria-hidden', 'true');
                                        flyingImage.style.left = imageRect.left + 'px';
                                        flyingImage.style.top = imageRect.top + 'px';
                                        flyingImage.style.width = imageRect.width + 'px';
                                        flyingImage.style.height = imageRect.height + 'px';
                                        flyingImage.style.setProperty('--cart-flight-x', (cartRect.left - imageRect.left) + 'px');
                                        flyingImage.style.setProperty('--cart-flight-y', (cartRect.top - imageRect.top) + 'px');

                                        document.body.appendChild(flyingImage);

                                        window.requestAnimationFrame(function () {
                                            flyingImage.classList.add('is-flying');
                                        });

                                        window.setTimeout(function () {
                                            cartIconElement.classList.add('is-bumping');
                                        }, 520);

                                        window.setTimeout(function () {
                                            cartIconElement.classList.remove('is-bumping');
                                            flyingImage.remove();
                                        }, 980);
                                    };

                                    const handleAddToCart = function (form) {
                                        const submitButton = form.querySelector('[data-add-to-cart-btn]');
                                        if (!submitButton || submitButton.disabled || submitButton.classList.contains('is-adding')) {
                                            return;
                                        }

                                        const requestUrl = form.getAttribute('action') || '<%= ctx %>/cart';
                                        submitButton.classList.add('is-adding');

                                        fetch(requestUrl, {
                                            method: 'POST',
                                            headers: {
                                                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                                                'X-Requested-With': 'XMLHttpRequest'
                                            },
                                            body: new URLSearchParams(new FormData(form)).toString()
                                        })
                                                .then(function (response) {
                                                    return response.json().catch(function () {
                                                        return {};
                                                    }).then(function (data) {
                                                        return {response: response, data: data};
                                                    });
                                                })
                                                .then(function (result) {
                                                    const response = result.response;
                                                    const data = result.data || {};

                                                    if (response.status === 401) {
                                                        showToast('Vui long dang nhap de them san pham vao gio hang.', false);
                                                        window.setTimeout(function () {
                                                            window.location.href = '<%= ctx %>/Login';
                                                        }, 900);
                                                        return;
                                                    }

                                                    if (!response.ok || !data.success) {
                                                        showToast(data.message || 'Khong the them san pham vao gio hang luc nay.', false);
                                                        return;
                                                    }

                                                    if (headerCartCountElement && typeof data.cartItemCount === 'number') {
                                                        headerCartCountElement.textContent = data.cartItemCount;
                                                    }

                                                    animateProductFlyToCart(form);
                                                    submitButton.classList.add('is-added');
                                                    showToast(data.message || 'Da them san pham vao gio hang.', true);

                                                    window.setTimeout(function () {
                                                        submitButton.classList.remove('is-added');
                                                    }, 1400);
                                                })
                                                .catch(function () {
                                                    showToast('Khong the ket noi den gio hang luc nay.', false);
                                                })
                                                .finally(function () {
                                                    submitButton.classList.remove('is-adding');
                                                });
                                    };

                                    addToCartForms.forEach(function (form) {
                                        form.addEventListener('submit', function (event) {
                                            event.preventDefault();
                                            handleAddToCart(form);
                                        });
                                    });
                                })();
                            </script>
                            </body>
                            </html>
