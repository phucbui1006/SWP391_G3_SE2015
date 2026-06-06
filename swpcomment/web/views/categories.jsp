<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>

<%
    /**
     * @file categories.jsp
     * @description Trang hiển thị danh sách sản phẩm theo danh mục, hỗ trợ tìm kiếm và sắp xếp.
     * Sử dụng mô hình MVC (gửi dữ liệu từ Servlet qua các attribute của Request).
     * * @requestAttribute {String} ctx Đường dẫn gốc của ứng dụng (Context Path).
     * @requestAttribute {List<Category>} categories Danh sách tất cả các danh mục sản phẩm có trong hệ thống.
     * @requestAttribute {List<Product>} products Danh sách sản phẩm cần hiển thị (đã qua bộ lọc/tìm kiếm).
     * @requestAttribute {Category} selectedCategory Danh mục hiện tại đang được chọn (null nếu hiển thị tất cả).
     * @requestAttribute {String} selectedSort Tiêu chí sắp xếp hiện tại (newest, price_asc, price_desc).
     * @requestAttribute {String} keyword Từ khóa tìm kiếm sản phẩm (nếu có).
     */

    // Lấy context path để cấu hình đường dẫn tuyệt đối cho các tài nguyên (CSS, hình ảnh, link)
    String ctx = request.getContextPath();

    // Ép kiểu các đối tượng nhận được từ Controller (Servlet) thông qua Request Attributes
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Product> products = (List<Product>) request.getAttribute("products");
    Category selectedCategory = (Category) request.getAttribute("selectedCategory");
    String selectedSort = (String) request.getAttribute("selectedSort");

    // Thiết lập giá trị sắp xếp mặc định là "mới nhất" nếu thuộc tính này bị trống
    if (selectedSort == null) {
        selectedSort = "newest";
    }

    // Khởi tạo tiêu đề mặc định cho trang
    String title = "Tất cả sản phẩm";

    // Thay đổi tiêu đề nếu người dùng đang đứng ở một danh mục cụ thể
    if (selectedCategory != null) {
        title = "Danh mục: " + selectedCategory.getCategoryName();
    }
    
    // Xử lý từ khóa tìm kiếm để tránh hiển thị giá trị null trên giao diện
    String keyword = (String) request.getAttribute("keyword");
    if (keyword == null) {
        keyword = "";
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Danh mục sản phẩm - ProBuild PC</title>

        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
        <link rel="stylesheet" href="<%= ctx %>/css/categories.css">
    </head>

    <body class="categories-page">

        <jsp:include page="/includes/header.jsp" />

        <main class="category-page">

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

                    <a class="category-link <%= selectedCategory == null ? "active" : "" %>"
                       href="<%= ctx %>/categories?sort=<%= selectedSort %>">
                        Tất cả sản phẩm
                    </a>

                    <% 
                        /**
                         * Vòng lặp duyệt và hiển thị danh sách các danh mục sang thanh Sidebar
                         */
                        if (categories != null && !categories.isEmpty()) {
                            for (Category c : categories) {
                    %>

                    <a class="category-link <%= selectedCategory != null && selectedCategory.getCategoryId() == c.getCategoryId() ? "active" : "" %>"
                       href="<%= ctx %>/categories?id=<%= c.getCategoryId() %>&sort=<%= selectedSort %>">
                        ▣ <%= c.getCategoryName() %>
                    </a>

                    <% }} %>
                </aside>

                <section class="category-content">

                    <div class="category-title-row">
                        <div>
                            <h2>
                                <%-- Hiển thị tiêu đề động tùy thuộc vào việc người dùng đang tìm kiếm hay lọc theo danh mục --%>
                                <% if (!keyword.isEmpty()) { %>
                                    Kết quả tìm kiếm: "<%= keyword %>"
                                <% } else { %>
                                    <%= title %>
                                <% } %>
                            </h2>
                            <p>
                                Hiện có
                                <strong><%= products == null ? 0 : products.size() %></strong>
                                sản phẩm
                            </p>
                        </div>

                        <form action="<%= ctx %>/categories" method="get" class="sort-form">

                            <%-- Lưu lại ID danh mục hiện tại để không bị mất bộ lọc khi sắp xếp giá --%>
                            <% if (selectedCategory != null) { %>
                            <input type="hidden" name="id" value="<%= selectedCategory.getCategoryId() %>">
                            <% } %>

                            <%-- Lưu lại từ khóa tìm kiếm hiện tại để giữ đúng phạm vi sản phẩm --%>
                            <% if (keyword != null && !keyword.isEmpty()) { %>
                            <input type="hidden" name="keyword" value="<%= keyword %>">
                            <% } %>

                            <select name="sort" onchange="this.form.submit()">
                                <option value="newest" <%= "newest".equals(selectedSort) ? "selected" : "" %>>
                                    Mới nhất
                                </option>
                                <option value="price_asc" <%= "price_asc".equals(selectedSort) ? "selected" : "" %>>
                                    Giá tăng dần
                                </option>
                                <option value="price_desc" <%= "price_desc".equals(selectedSort) ? "selected" : "" %>>
                                    Giá giảm dần
                                </option>
                            </select>

                        </form>
                    </div>

                    <div class="category-grid">

                        <% 
                            /**
                             * Vòng lặp duyệt và kết xuất (render) danh sách sản phẩm ra giao diện HTML
                             */
                            if (products != null && !products.isEmpty()) {
                                for (Product p : products) {
                        %>

                        <article class="category-product-card">

                            <button class="wish-btn" type="button">♡</button>

                            <a href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                <figure>
                                    <img src="<%= ctx %>/<%= p.getImageUrl() %>"
                                         alt="<%= p.getProductName() %>">
                                </figure>

                                <h3><%= p.getProductName() %></h3>
                            </a>

                            <strong>
                                <%= String.format("%,d", p.getPrice().longValue()) %>đ
                            </strong>

                            <p class="stock">
                                <% if (p.getQuantity() > 0) { %>
                                    Còn hàng: <%= p.getQuantity() %>
                                <% } else { %>
                                    Hết hàng
                                <% } %>
                            </p>

                            <div class="card-actions">
                                <a href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>">
                                    Xem chi tiết
                                </a>
                                <button type="button">🛒</button>
                            </div>

                        </article>

                        <% 
                                }
                            } else { 
                                /**
                                 * Hiển thị khối thông báo trống dưới đây nếu không tìm thấy bất kỳ sản phẩm nào phù hợp
                                 */
                        %>

                        <div class="empty-box">
                            <h3>Chưa có sản phẩm trong danh mục này</h3>
                            <p>Vui lòng chọn danh mục khác.</p>
                        </div>

                        <% } %>

                    </div>

                </section>

            </section>

        </main>
        <jsp:include page="/includes/footer.jsp" />

    </body>
</html>