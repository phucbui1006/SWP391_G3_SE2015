<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>

<%              String ctx=request.getContextPath();
                List<Category> categories = (List<Category>) request.getAttribute("categories");
                List<Product> products = (List<Product>) request.getAttribute("products");
                Category selectedCategory = (Category) request.getAttribute("selectedCategory");

                String selectedSort = (String) request.getAttribute("selectedSort");
                if (selectedSort == null || selectedSort.trim().isEmpty()) {
                selectedSort = "newest";
                }

                String keyword = (String) request.getAttribute("keyword");
                if (keyword == null) {
                keyword = "";
                }

                String title = "Tất cả sản phẩm";
                if (selectedCategory != null) {
                title = "Danh mục: " + selectedCategory.getCategoryName();
                }

                String cartMessage = (String) request.getAttribute("cartMessage");
                String cartMessageType = (String) request.getAttribute("cartMessageType");
                if (cartMessageType == null) {
                cartMessageType = "success";
                }

                Integer totalProductsObj = (Integer) request.getAttribute("totalProducts");
                Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                Integer totalPagesObj = (Integer) request.getAttribute("totalPages");

                int totalProducts = totalProductsObj == null ? 0 : totalProductsObj;
                int currentPage = currentPageObj == null ? 1 : currentPageObj;
                int totalPages = totalPagesObj == null ? 1 : totalPagesObj;

                String encodedKeyword = "";
                if (keyword != null && !keyword.trim().isEmpty()) {
                encodedKeyword = URLEncoder.encode(keyword, "UTF-8");
                }
                String searchValue = keyword == null ? "" : keyword
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("<", "&lt;" ) .replace(">", "&gt;");

                    String clearSearchUrl = ctx + "/categories?";
                    if (selectedCategory != null) {
                    clearSearchUrl += "id=" + selectedCategory.getCategoryId() + "&";
                    }
                    clearSearchUrl += "sort=" + selectedSort;

                    String currentUrl = ctx + "/categories";
                    if (request.getQueryString() != null &&
                    !request.getQueryString().trim().isEmpty()) {
                    currentUrl += "?" + request.getQueryString();
                    }

                    String pagingUrl = ctx + "/categories?";

                    if (selectedCategory != null) {
                    pagingUrl += "id=" + selectedCategory.getCategoryId() + "&";
                    }

                    if (keyword != null && !keyword.trim().isEmpty()) {
                    pagingUrl += "keyword=" + encodedKeyword + "&";
                    }

                    pagingUrl += "sort=" + selectedSort + "&page=";
%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Danh mục sản phẩm - ProBuild PC</title>

        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
        <link rel="stylesheet" href="<%= ctx %>/css/categories.css?v=51">
    </head>

    <body class="categories-page" data-context-path="<%= ctx %>">

        <jsp:include page="/includes/header.jsp" />

        <main class="category-page">

            <% if (cartMessage !=null && !cartMessage.trim().isEmpty()) { %>
            <div class="server-message <%= " error".equals(cartMessageType)
                                                        ? "error" : "success" %>">
                <%= cartMessage %>
            </div>
            <% } %>

            <section class="category-hero">
                <div>
                    <p>PROBUILD PC</p>
                    <h1>Danh mục sản phẩm</h1>
                    <span>Lựa chọn linh kiện theo từng nhóm sản phẩm</span>
                </div>
            </section>

            <section class="category-layout">

                <aside class="category-sidebar">
                    <h2>📦 Danh mục sản phẩm</h2>

                    <form action="<%= ctx %>/categories" method="get"
                          class="category-filter-form">

                        <input type="hidden" name="sort"
                               value="<%= selectedSort %>">

                        <label class="category-option <%= selectedCategory == null ? "active" : "" %>">
                            <input type="radio" name="id" value=""
                                   <%=selectedCategory==null ? "checked" : ""
                                   %>>
                            <span>Tất cả sản phẩm</span>
                        </label>

                        <% if (categories !=null && !categories.isEmpty()) {
                        %>
                        <% for (Category c : categories) { %>
                        <label class="category-option <%= selectedCategory != null && selectedCategory.getCategoryId() == c.getCategoryId() ? "active" : "" %>">
                            <input type="radio" name="id"
                                   value="<%= c.getCategoryId() %>"
                                   <%=selectedCategory !=null &&
                                   selectedCategory.getCategoryId()==c.getCategoryId()
                                   ? "checked" : "" %>>
                            <span>
                                <%= c.getCategoryName() %>
                            </span>
                        </label>
                        <% } %>
                        <% } %>

                        <button type="submit"
                                class="category-apply-btn">
                            Áp dụng
                        </button>

                        <% if (keyword !=null &&
                                                                                        !keyword.trim().isEmpty()) { %>
                        <a class="clear-search-btn"
                           href="<%= ctx %>/categories?sort=<%= selectedSort %>">
                            Xóa tìm kiếm
                        </a>
                        <% } %>

                    </form>
                </aside>

                <section class="category-content">

                    <div class="category-title-row">

                        <div class="category-heading">
                            <h2>
                                <% if (keyword !=null &&
                                                                                !keyword.trim().isEmpty()) { %>
                                Kết quả tìm kiếm: "<%= keyword %>"
                                <% } else { %>
                                <%= title %>
                                <% } %>
                            </h2>

                            <p>
                                Có 
                                <strong>
                                    <%= totalProducts %>
                                </strong>
                                sản phẩm
                            </p>
                        </div>

                        <form action="<%= ctx %>/categories" method="get"
                              class="category-search-form">
                            <% if (selectedCategory !=null) { %>
                            <input type="hidden" name="id"
                                   value="<%= selectedCategory.getCategoryId() %>">
                            <% } %>

                            <input type="hidden" name="sort"
                                   value="<%= selectedSort %>">

                            <div class="category-search-box">
                                <span class="search-icon-left">
                                    <svg xmlns="http://www.w3.org/2000/svg"
                                         width="16" height="16"
                                         viewBox="0 0 24 24"
                                         fill="none"
                                         stroke="currentColor"
                                         stroke-width="2.5"
                                         stroke-linecap="round"
                                         stroke-linejoin="round">
                                    <circle cx="11" cy="11"
                                            r="8"></circle>
                                    <line x1="21" y1="21"
                                          x2="16.65" y2="16.65">
                                    </line>
                                    </svg>
                                </span>
                                <input type="text" name="keyword"
                                       id="contentSearchInput"
                                       value="<%= searchValue %>"
                                       placeholder="Tìm sản phẩm theo tên/loại">

                                <% if (keyword !=null &&
                                                                                        !keyword.trim().isEmpty()) { %>
                                <a href="<%= clearSearchUrl %>"
                                   class="search-clear-btn"
                                   title="Xóa tìm kiếm">
                                    <svg xmlns="http://www.w3.org/2000/svg"
                                         width="14" height="14"
                                         viewBox="0 0 24 24"
                                         fill="none"
                                         stroke="currentColor"
                                         stroke-width="3"
                                         stroke-linecap="round"
                                         stroke-linejoin="round">
                                    <line x1="18" y1="6"
                                          x2="6" y2="18">
                                    </line>
                                    <line x1="6" y1="6"
                                          x2="18" y2="18">
                                    </line>
                                    </svg>
                                </a>
                                <% } %>

                                <button type="submit"
                                        class="search-submit-btn">
                                    <svg xmlns="http://www.w3.org/2000/svg"
                                         width="15"
                                         height="15"
                                         viewBox="0 0 24 24"
                                         fill="none"
                                         stroke="currentColor"
                                         stroke-width="2.5"
                                         stroke-linecap="round"
                                         stroke-linejoin="round">
                                    <circle cx="11"
                                            cy="11" r="8">
                                    </circle>
                                    <line x1="21"
                                          y1="21"
                                          x2="16.65"
                                          y2="16.65">
                                    </line>
                                    </svg>
                                    <span>Tìm kiếm</span>
                                </button>
                            </div>
                        </form>

                        <form action="<%= ctx %>/categories" method="get"
                              class="sort-form">
                            <% if (selectedCategory !=null) { %>
                            <input type="hidden" name="id"
                                   value="<%= selectedCategory.getCategoryId() %>">
                            <% } %>

                            <% if (keyword !=null &&
                                                                                    !keyword.trim().isEmpty()) { %>
                            <input type="hidden" name="keyword"
                                   value="<%= searchValue %>">
                            <% } %>

                            <label>Sắp xếp:</label>

                            <select name="sort"
                                    onchange="this.form.submit()">
                                <option value="newest"
                                        <%="newest"
                                        .equals(selectedSort)
                                        ? "selected" : "" %>>
                                    Mới nhất
                                </option>

                                <option value="price_asc"
                                        <%="price_asc"
                                        .equals(selectedSort)
                                        ? "selected" : "" %>>
                                    Giá tăng dần
                                </option>

                                <option value="price_desc"
                                        <%="price_desc"
                                        .equals(selectedSort)
                                        ? "selected" : "" %>>
                                    Giá giảm dần
                                </option>
                            </select>
                        </form>

                    </div>
                    <div class="category-grid">

                        <% if (products !=null && !products.isEmpty()) { %>

                        <% for (Product p : products) { %>

                        <article class="category-product-card">

                            <a
                                href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                <figure>
                                    <img src="<%= ctx %>/<%= p.getImageUrl() %>"
                                         alt="<%= p.getProductName() %>">
                                </figure>

                                <h3>
                                    <%= p.getProductName() %>
                                </h3>
                            </a>

                            <strong>
                                <%= String.format("%,d",
                                                                                        p.getPrice().longValue()) %>đ
                            </strong>

                            <p class="stock">
                                <% if (p.getQuantity()> 0) { %>
                                Còn hàng: <%= p.getQuantity() %>
                                <% } else { %>
                                Hết hàng
                                <% } %>
                            </p>

                            <div class="card-actions">
                                <a
                                    href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                    Xem chi tiết
                                </a>

                                <% if (p.getQuantity()> 0) { %>
                                <form action="<%= ctx %>/cart"
                                      method="post"
                                      class="cart-form">
                                    <input type="hidden"
                                           name="action"
                                           value="addToCart">
                                    <input type="hidden"
                                           name="productId"
                                           value="<%= p.getProductId() %>">
                                    <input type="hidden"
                                           name="quantity"
                                           value="1">

                                    <button type="submit"
                                            class="add-to-cart-btn"
                                            data-add-to-cart-btn
                                            title="Thêm vào giỏ hàng">
                                        🛒
                                    </button>
                                </form>
                                <% } else { %>
                                <button type="button"
                                        class="add-to-cart-btn"
                                        style="opacity: 0.6; cursor: not-allowed; background: #e5e7eb; border-color: #e5e7eb; color: #9ca3af;"
                                        title="Sản phẩm tạm hết hàng"
                                        disabled>
                                    🛒
                                </button>
                                <% } %>
                            </div>

                        </article>

                        <% } %>

                        <% } else { %>

                        <div class="empty-box">
                            <h3>Chưa có sản phẩm trong danh
                                mục này</h3>
                            <p>Vui lòng chọn danh mục khác.
                            </p>
                        </div>

                        <% } %>

                    </div>

                    <div class="category-pagination">
                        <% if (currentPage> 1) { %>
                        <a
                            href="<%= pagingUrl + (currentPage - 1) %>">Trước</a>
                        <% } %>

                        <% for (int i=1; i <=totalPages; i++) { %>
                        <a class="<%= currentPage == i ? "active" : "" %>"
                           href="<%= pagingUrl + i %>">
                            <%= i %>
                        </a>
                        <% } %>

                        <% if (currentPage < totalPages) {
                        %>
                        <a
                            href="<%= pagingUrl + (currentPage + 1) %>">Sau</a>
                        <% } %>
                    </div>

                </section>

            </section>

        </main>

        <div class="home-toast" data-home-toast hidden>
            <div class="home-toast-icon" data-home-toast-icon aria-hidden="true">+</div>
            <div class="home-toast-message" data-home-toast-message></div>
        </div>

        <jsp:include page="/includes/footer.jsp" />

        <script src="<%= ctx %>/js/cart.js"></script>
    </body>

</html>