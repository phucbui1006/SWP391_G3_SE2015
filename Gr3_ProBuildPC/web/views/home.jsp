<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="model.User" %>
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

        <main class="page-shell">

            <aside class="sidebar">
                <h2>DANH M&#7908;C S&#7842;N PH&#7848;M</h2>

                <ul class="category-list">
                    <% if (categories != null && !categories.isEmpty()) {
                        for (Category cat : categories) {
                    %>

                    <li>
                        <a href="<%= ctx %>/categories?id=<%= cat.getCategoryId() %>">
                            &#9635; <%= cat.getCategoryName() %>
                        </a>
                    </li>

                    <%
                        }
                    }
                    %>
                </ul>

                <a class="all-categories" href="<%= ctx %>/categories">
                    &#9674; Xem t&#7845;t c&#7843; danh m&#7909;c
                </a>
            </aside>

            <section class="content">

                <section class="hero-banner">
                    <div class="hero-copy">
                        <p>BUILD PC</p>

                        <h1>
                            &#272;&#7880;NH CAO HI&#7878;U N&#258;NG<br>
                            N&#194;NG T&#7846;M TR&#7842;I NGHI&#7878;M
                        </h1>

                        <span>
                            Linh ki&#7879;n ch&#237;nh h&#227;ng - Gi&#225; t&#7889;t nh&#7845;t<br>
                            B&#7843;o h&#224;nh uy t&#237;n - H&#7895; tr&#7907; t&#7853;n t&#226;m
                        </span>

                        <a href="<%= ctx %>/categories">MUA NGAY</a>
                    </div>
                </section>

                <section class="service-row">
                    <article>
                        <span>&#128737;</span>
                        <div>
                            <strong>H&#224;ng ch&#237;nh h&#227;ng</strong>
                            <small>100% ch&#237;nh h&#227;ng</small>
                        </div>
                    </article>

                    <article>
                        <span>&#128260;</span>
                        <div>
                            <strong>B&#7843;o h&#224;nh uy t&#237;n</strong>
                            <small>B&#7843;o h&#224;nh ch&#237;nh h&#227;ng</small>
                        </div>
                    </article>

                    <article>
                        <span>&#128666;</span>
                        <div>
                            <strong>Giao h&#224;ng to&#224;n Th&#7841;ch Th&#7845;t</strong>
                            <small>Mi&#7877;n ph&#237; &#273;&#417;n t&#7915; 1 tri&#7879;u</small>
                        </div>
                    </article>

                    <article>
                        <span>&#127911;</span>
                        <div>
                            <strong>H&#7895; tr&#7907; 24/7</strong>
                            <small>T&#432; v&#7845;n t&#7853;n t&#226;m</small>
                        </div>
                    </article>
                </section>

                <section class="filter-row">
                    <div class="filters">

                        <label>
                            Danh m&#7909;c:
                            <select onchange="location.href=this.value">
                                <option value="<%= ctx %>/categories">T&#7845;t c&#7843;</option>

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
                            Th&#432;&#417;ng hi&#7879;u:
                            <select>
                                <option>T&#7845;t c&#7843;</option>
                                <option>Intel</option>
                                <option>AMD</option>
                                <option>ASUS</option>
                                <option>MSI</option>
                            </select>
                        </label>

                        <label>
                            Kho&#7843;ng gi&#225;:
                            <select>
                                <option>T&#7845;t c&#7843;</option>
                                <option>D&#432;&#7899;i 2 tri&#7879;u</option>
                                <option>2 - 5 tri&#7879;u</option>
                                <option>Tr&#234;n 5 tri&#7879;u</option>
                            </select>
                        </label>

                    </div>

                    <label class="sort-box">
                        S&#7855;p x&#7871;p:
                        <select onchange="location.href='<%= ctx %>/categories?sort=' + this.value">
                            <option value="newest">M&#7899;i nh&#7845;t</option>
                            <option value="price_asc">Gi&#225; t&#259;ng d&#7847;n</option>
                            <option value="price_desc">Gi&#225; gi&#7843;m d&#7847;n</option>
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

                        <button class="wish-btn" type="button">&#9825;</button>

                        <figure>
                            <img src="<%= ctx %>/<%= product.getImageUrl() %>"
                                 alt="<%= product.getProductName() %>">
                        </figure>

                        <h3><%= product.getProductName() %></h3>

                        <strong>
                            <%= String.format("%,d", product.getPrice().longValue()) %>&#273;
                        </strong>

                        <div class="product-rating">
                            <% for (int i = 1; i <= 5; i++) { %>
                            <%= i <= fullStars ? "&#9733;" : "&#9734;" %>
                            <% } %>

                            <span><%= String.format("%.1f", rating) %></span>
                        </div>

                        <div class="product-actions">
                            <a class="detail-btn"
                               href="<%= ctx %>/product-detail?id=<%= product.getProductId() %>">
                                Xem chi ti&#7871;t
                            </a>

                            <button
                                type="button"
                                class="cart-btn add-to-cart-btn"
                                data-product-id="<%= product.getProductId() %>"
                                title="<%= product.getQuantity() > 0 ? "Them vao gio hang" : "San pham tam het hang" %>"
                                <%= product.getQuantity() > 0 ? "" : "disabled" %>>
                                <i class="fa-solid fa-cart-shopping"></i>
                            </button>
                        </div>

                    </article>

                    <%
                        }
                    } else {
                    %>
                    <p>Kh&#244;ng c&#243; s&#7843;n ph&#7849;m n&#224;o &#273;&#7875; hi&#7875;n th&#7883;.</p>
                    <% } %>
                </section>

                <nav class="home-pagination">
                    <a href="#">&#8249;</a>
                    <a href="#" class="active">1</a>
                    <a href="#">2</a>
                    <a href="#">3</a>
                    <a href="#">4</a>
                    <a href="#">5</a>
                    <span>...</span>
                    <a href="#">10</a>
                    <a href="#">&#8250;</a>
                </nav>
            </section>
        </main>

        <div id="homeToast" class="home-toast" role="status" aria-live="polite" aria-atomic="true">
            <span class="home-toast-icon">
                <i class="fa-solid fa-circle-check"></i>
            </span>
            <span class="home-toast-message">Da them san pham vao gio hang.</span>
        </div>

        <jsp:include page="/includes/footer.jsp" />

        <script>
            (function () {
                const addToCartButtons = document.querySelectorAll('.add-to-cart-btn');
                const homeToast = document.getElementById('homeToast');
                const homeToastMessage = homeToast ? homeToast.querySelector('.home-toast-message') : null;
                const headerCartCountElement = document.querySelector('.cart-box .cart-icon span');
                const cartApiUrl = '<%= ctx %>/cart';
                let toastTimer = null;

                if (!addToCartButtons.length || !homeToast || !homeToastMessage) {
                    return;
                }

                const showToast = function (message, type) {
                    homeToastMessage.textContent = message;
                    homeToast.classList.remove('is-success', 'is-error', 'show');
                    homeToast.classList.add(type === 'error' ? 'is-error' : 'is-success');
                    homeToast.offsetWidth;
                    homeToast.classList.add('show');

                    if (toastTimer) {
                        window.clearTimeout(toastTimer);
                    }

                    toastTimer = window.setTimeout(function () {
                        homeToast.classList.remove('show');
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

                addToCartButtons.forEach(function (button) {
                    button.addEventListener('click', function () {
                        const productId = button.dataset.productId;

                        if (!productId || button.disabled) {
                            showToast('San pham hien tam het hang.', 'error');
                            return;
                        }

                        const payload = new URLSearchParams();
                        payload.set('action', 'addToCart');
                        payload.set('productId', productId);
                        payload.set('quantity', '1');

                        button.classList.add('is-adding');
                        button.classList.remove('is-added');

                        fetch(cartApiUrl, {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                                'X-Requested-With': 'XMLHttpRequest'
                            },
                            body: payload.toString()
                        })
                                .then(function (response) {
                                    return parseJsonSafely(response).then(function (data) {
                                        if (!response.ok) {
                                            throw new Error(data.message || 'Khong the them san pham vao gio hang.');
                                        }
                                        return data;
                                    });
                                })
                                .then(function (data) {
                                    if (headerCartCountElement && typeof data.cartItemCount === 'number') {
                                        headerCartCountElement.textContent = data.cartItemCount;
                                    }

                                    button.classList.add('is-added');
                                    window.setTimeout(function () {
                                        button.classList.remove('is-added');
                                    }, 1400);

                                    showToast(data.message || 'Da them san pham vao gio hang.', 'success');
                                })
                                .catch(function (error) {
                                    showToast(error.message || 'Khong the them san pham vao gio hang.', 'error');
                                })
                                .finally(function () {
                                    button.classList.remove('is-adding');
                                });
                    });
                });
            })();
        </script>
    </body>
</html>
