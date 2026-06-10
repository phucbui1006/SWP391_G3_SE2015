<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%
    String ctx = request.getContextPath();

    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Product> products = (List<Product>) request.getAttribute("products");
    Category selectedCategory = (Category) request.getAttribute("selectedCategory");

    String selectedSort = (String) request.getAttribute("selectedSort");
    if (selectedSort == null || selectedSort.trim().isEmpty()) {
        selectedSort = "newest";
    }

    String title = "Tat ca san pham";
    if (selectedCategory != null) {
        title = "Danh muc: " + selectedCategory.getCategoryName();
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Danh muc san pham - ProBuild PC</title>

        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
        <link rel="stylesheet" href="<%= ctx %>/css/categories.css">
    </head>

    <body class="categories-page">

        <jsp:include page="/includes/header.jsp" />

        <main class="category-page">

            <section class="category-hero">
                <div>
                    <p>PROBUILD PC</p>
                    <h1>Danh m&#7909;c s&#7843;n ph&#7849;m</h1>
                    <span>L&#7921;a ch&#7885;n linh ki&#7879;n theo t&#7915;ng nh&#243;m s&#7843;n ph&#7849;m</span>
                </div>
            </section>

            <section class="category-layout">

                <aside class="category-sidebar">
                    <h2>&#128230; Danh m&#7909;c s&#7843;n ph&#7849;m</h2>

                    <a class="category-link <%= selectedCategory == null ? "active" : "" %>"
                       href="<%= ctx %>/categories?sort=<%= selectedSort %>">
                        T&#7845;t c&#7843; s&#7843;n ph&#7849;m
                    </a>

                    <% if (categories != null && !categories.isEmpty()) {
                        for (Category c : categories) {
                    %>
                    <a class="category-link <%= selectedCategory != null && selectedCategory.getCategoryId() == c.getCategoryId() ? "active" : "" %>"
                       href="<%= ctx %>/categories?id=<%= c.getCategoryId() %>&sort=<%= selectedSort %>">
                        &#9635; <%= c.getCategoryName() %>
                    </a>
                    <% }} %>
                </aside>

                <section class="category-content">

                    <div class="category-title-row">
                        <div>
                            <h2><%= title %></h2>
                            <p>
                                Hi&#7879;n c&#243;
                                <strong><%= products == null ? 0 : products.size() %></strong>
                                s&#7843;n ph&#7849;m
                            </p>
                        </div>

                        <form action="<%= ctx %>/categories" method="get" class="sort-form">
                            <% if (selectedCategory != null) { %>
                            <input type="hidden" name="id" value="<%= selectedCategory.getCategoryId() %>">
                            <% } %>

                            <select name="sort" onchange="this.form.submit()">
                                <option value="newest" <%= "newest".equals(selectedSort) ? "selected" : "" %>>
                                    M&#7899;i nh&#7845;t
                                </option>
                                <option value="price_asc" <%= "price_asc".equals(selectedSort) ? "selected" : "" %>>
                                    Gi&#225; t&#259;ng d&#7847;n
                                </option>
                                <option value="price_desc" <%= "price_desc".equals(selectedSort) ? "selected" : "" %>>
                                    Gi&#225; gi&#7843;m d&#7847;n
                                </option>
                            </select>
                        </form>
                    </div>

                    <div class="category-grid">

                        <% if (products != null && !products.isEmpty()) {
                            for (Product p : products) {
                        %>
                        <article class="category-product-card">

                            <button class="wish-btn" type="button">&#9825;</button>

                            <a href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                <figure>
                                    <img src="<%= ctx %>/<%= p.getImageUrl() %>"
                                         alt="<%= p.getProductName() %>">
                                </figure>

                                <h3><%= p.getProductName() %></h3>
                            </a>

                            <strong>
                                <%= String.format("%,d", p.getPrice().longValue()) %>&#273;
                            </strong>

                            <p class="stock">
                                <% if (p.getQuantity() > 0) { %>
                                C&#242;n h&#224;ng: <%= p.getQuantity() %>
                                <% } else { %>
                                H&#7871;t h&#224;ng
                                <% } %>
                            </p>

                            <div class="card-actions">
                                <a href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                    Xem chi ti&#7871;t
                                </a>

                                <button
                                    type="button"
                                    class="add-to-cart-btn"
                                    data-product-id="<%= p.getProductId() %>"
                                    title="<%= p.getQuantity() > 0 ? "Them vao gio hang" : "San pham tam het hang" %>"
                                    aria-label="<%= p.getQuantity() > 0 ? "Them vao gio hang" : "San pham tam het hang" %>"
                                    <%= p.getQuantity() > 0 ? "" : "disabled" %>>
                                    <span class="add-to-cart-icon" aria-hidden="true">&#128722;</span>
                                </button>
                            </div>

                        </article>
                        <% }} else { %>
                        <div class="empty-box">
                            <h3>Ch&#432;a c&#243; s&#7843;n ph&#7849;m trong danh m&#7909;c n&#224;y</h3>
                            <p>Vui l&#242;ng ch&#7885;n danh m&#7909;c kh&#225;c.</p>
                        </div>
                        <% } %>

                    </div>

                </section>

            </section>

        </main>

        <div id="categoryToast" class="category-toast" role="status" aria-live="polite" aria-atomic="true">
            <span class="category-toast-icon">&#10003;</span>
            <span class="category-toast-message">Da them san pham vao gio hang.</span>
        </div>

        <script>
            (function () {
                const addToCartButtons = document.querySelectorAll('.add-to-cart-btn');
                const categoryToast = document.getElementById('categoryToast');
                const categoryToastMessage = categoryToast ? categoryToast.querySelector('.category-toast-message') : null;
                const headerCartCountElement = document.querySelector('.cart-box .cart-icon span');
                const cartApiUrl = '<%= ctx %>/cart';
                let toastTimer = null;

                if (!addToCartButtons.length || !categoryToast || !categoryToastMessage) {
                    return;
                }

                const showToast = function (message, type) {
                    categoryToastMessage.textContent = message;
                    categoryToast.classList.remove('is-success', 'is-error', 'show');
                    categoryToast.classList.add(type === 'error' ? 'is-error' : 'is-success');
                    categoryToast.offsetWidth;
                    categoryToast.classList.add('show');

                    if (toastTimer) {
                        window.clearTimeout(toastTimer);
                    }

                    toastTimer = window.setTimeout(function () {
                        categoryToast.classList.remove('show');
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
                        const iconElement = button.querySelector('.add-to-cart-icon');

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
                        if (iconElement) {
                            iconElement.textContent = '\uD83D\uDED2';
                        }
                        button.title = 'Dang them vao gio hang';
                        button.setAttribute('aria-label', 'Dang them vao gio hang');

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
                                    if (iconElement) {
                                        iconElement.textContent = '\u2713';
                                    }
                                    button.title = 'Da them vao gio hang';
                                    button.setAttribute('aria-label', 'Da them vao gio hang');
                                    window.setTimeout(function () {
                                        button.classList.remove('is-added');
                                        if (iconElement) {
                                            iconElement.textContent = '\uD83D\uDED2';
                                        }
                                        button.title = 'Them vao gio hang';
                                        button.setAttribute('aria-label', 'Them vao gio hang');
                                    }, 1400);

                                    showToast(data.message || 'Da them san pham vao gio hang.', 'success');
                                })
                                .catch(function (error) {
                                    if (iconElement) {
                                        iconElement.textContent = '\uD83D\uDED2';
                                    }
                                    button.title = 'Them vao gio hang';
                                    button.setAttribute('aria-label', 'Them vao gio hang');
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
