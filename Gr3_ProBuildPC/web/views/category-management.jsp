<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="model.Category" %>

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

    private String enc(String value) {
        if (value == null) {
            return "";
        }

        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
%>

<%
    List<Category> categories = (List<Category>) request.getAttribute("categories");

    String keyword = (String) request.getAttribute("keyword");
    String status = (String) request.getAttribute("status");
    String sort = (String) request.getAttribute("sort");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCategories = (Integer) request.getAttribute("totalCategories");
    Integer startItem = (Integer) request.getAttribute("startItem");
    Integer endItem = (Integer) request.getAttribute("endItem");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    String addCategoryNameError = (String) request.getAttribute("addCategoryNameError");
    String addCategoryOldName = (String) request.getAttribute("addCategoryOldName");

    String editCategoryNameError = (String) request.getAttribute("editCategoryNameError");
    String editCategoryOldName = (String) request.getAttribute("editCategoryOldName");
    String editCategoryOldId = (String) request.getAttribute("editCategoryOldId");

    if (categories == null) {
        categories = Collections.emptyList();
    }

    if (keyword == null) {
        keyword = "";
    }

    if (status == null || status.trim().isEmpty()) {
        status = "ALL";
    }

    if (sort == null || sort.trim().isEmpty()) {
        sort = "newest";
    }

    if (currentPage == null) {
        currentPage = 1;
    }

    if (totalPages == null) {
        totalPages = 1;
    }

    if (totalCategories == null) {
        totalCategories = 0;
    }

    if (startItem == null) {
        startItem = 0;
    }

    if (endItem == null) {
        endItem = 0;
    }

    if (addCategoryNameError == null) {
        addCategoryNameError = "";
    }

    if (addCategoryOldName == null) {
        addCategoryOldName = "";
    }

    if (editCategoryNameError == null) {
        editCategoryNameError = "";
    }

    if (editCategoryOldName == null) {
        editCategoryOldName = "";
    }

    if (editCategoryOldId == null) {
        editCategoryOldId = "";
    }

    String contextPath = request.getContextPath();
    String listQuery = "&keyword=" + enc(keyword)
            + "&status=" + enc(status)
            + "&sort=" + enc(sort);
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý danh mục sản phẩm</title>

        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/style.css">
        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/admin-categories.css?v=1.0.3">
    </head>

    <body class="admin-category-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="admin-category-container">

            <div class="admin-page-title">
                <nav class="admin-breadcrumb site-breadcrumb" aria-label="Breadcrumb">
                    <a href="<%= contextPath %>/Dashboard">Dashboard</a>
                    <span>›</span>
                    <span>Sản phẩm</span>
                    <span>›</span>
                    <strong>Quản lý danh mục sản phẩm</strong>
                </nav>
                <h2>Danh sách danh mục</h2>
            </div>

            <% if (success != null && !success.isEmpty()) { %>
            <div class="category-alert success">
                <%= h(success) %>
            </div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="category-alert error">
                <%= h(error) %>
            </div>
            <% } %>

            <section class="admin-category-card">

                <form action="<%= contextPath %>/admin/categories"
                      method="get"
                      class="admin-category-toolbar"
                      id="adminCategorySearchForm">

                    <div class="category-search-form">
                        <input type="text"
                               id="categorySearchInput"
                               name="keyword"
                               value="<%= h(keyword) %>"
                               placeholder="Tìm kiếm danh mục theo tên...">

                        <select name="status" id="statusFilter">
                            <option value="ALL" <%= "ALL".equals(status) ? "selected" : "" %>>
                                Tất cả trạng thái
                            </option>
                            <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : "" %>>
                                ACTIVE
                            </option>
                            <option value="INACTIVE" <%= "INACTIVE".equals(status) ? "selected" : "" %>>
                                INACTIVE
                            </option>
                        </select>

                        <select name="sort" id="sortFilter">
                            <option value="newest" <%= "newest".equals(sort) ? "selected" : "" %>>
                                Mới nhất
                            </option>
                            <option value="oldest" <%= "oldest".equals(sort) ? "selected" : "" %>>
                                Cũ nhất
                            </option>
                        </select>

                        <button type="submit">Tìm kiếm</button>
                    </div>

                    <a href="#addCategoryModal" class="btn-add-category">+ Thêm danh mục</a>
                </form>

                <div class="table-wrapper">
                    <table class="admin-category-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Tên danh mục</th>
                                <th>Trạng thái</th>
                                <th>Số sản phẩm</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (categories.isEmpty()) { %>
                            <tr>
                                <td colspan="5" style="text-align:center; padding: 30px;">
                                    Không có danh mục nào.
                                </td>
                            </tr>
                            <% } else { %>

                            <% for (Category c : categories) { %>
                            <%
                                String categoryStatus = c.getStatus();

                                if (categoryStatus == null || categoryStatus.trim().isEmpty()) {
                                    categoryStatus = "INACTIVE";
                                }

                                boolean isActive = "ACTIVE".equalsIgnoreCase(categoryStatus);
                            %>

                            <tr>
                                <td>
                                    <%= c.getCategoryId() %>
                                </td>

                                <td>
                                    <%= h(c.getCategoryName()) %>
                                </td>

                                <td>
                                    <span class="status-badge status-<%= categoryStatus.toLowerCase() %>">
                                        <%= isActive ? "ACTIVE" : "INACTIVE" %>
                                    </span>
                                </td>

                                <td>
                                    <%= c.getProductCount() %>
                                </td>

                                <td>
                                    <div class="category-actions">

                                        <a href="#editCategoryModal"
                                           class="btn-edit"
                                           data-id="<%= c.getCategoryId() %>"
                                           data-name="<%= h(c.getCategoryName()) %>">
                                            Sửa
                                        </a>

                                        <form action="<%= contextPath %>/admin/categories"
                                              method="post"
                                              style="display:inline;">

                                            <input type="hidden"
                                                   name="categoryId"
                                                   value="<%= c.getCategoryId() %>">

                                            <input type="hidden"
                                                   name="action"
                                                   value="<%= isActive ? "delete" : "activate" %>">

                                            <input type="hidden"
                                                   name="keyword"
                                                   value="<%= h(keyword) %>">

                                            <input type="hidden"
                                                   name="status"
                                                   value="<%= h(status) %>">

                                            <input type="hidden"
                                                   name="sort"
                                                   value="<%= h(sort) %>">

                                            <input type="hidden"
                                                   name="page"
                                                   value="<%= currentPage %>">

                                            <button type="submit" class="btn-delete">
                                                <%= isActive ? "Vô hiệu hóa" : "Kích hoạt" %>
                                            </button>
                                        </form>

                                    </div>
                                </td>
                            </tr>
                            <% } %>

                            <% } %>
                        </tbody>
                    </table>
                </div>

                <div class="admin-category-footer">
                    <!--                    <p>
                                            Hiển thị <%= startItem %>
                                            đến <%= endItem %>
                                            của <%= totalCategories %> danh mục.
                                        </p>-->

                    <div class="admin-pagination">
                        <% if (currentPage > 1) { %>
                        <a class="page-btn" href="<%= contextPath %>/admin/categories?page=<%= currentPage - 1 %><%= listQuery %>">Trước</a>
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
                        <a class="page-btn <%= currentPage == 1 ? "active" : "" %>" href="<%= contextPath %>/admin/categories?page=1<%= listQuery %>">1</a>
                        <% if (fromPage > 2) { %>
                        <span class="page-btn">...</span>
                        <% } %>
                        <% for (int i = fromPage; i <= toPage; i++) { %>
                        <a class="page-btn <%= currentPage == i ? "active" : "" %>" href="<%= contextPath %>/admin/categories?page=<%= i %><%= listQuery %>"><%= i %></a>
                        <% } %>
                        <% if (toPage < totalPages - 1) { %>
                        <span class="page-btn">...</span>
                        <% } %>
                        <% if (totalPages > 1) { %>
                        <a class="page-btn <%= currentPage == totalPages ? "active" : "" %>" href="<%= contextPath %>/admin/categories?page=<%= totalPages %><%= listQuery %>"><%= totalPages %></a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                        <a class="page-btn" href="<%= contextPath %>/admin/categories?page=<%= currentPage + 1 %><%= listQuery %>">Sau</a>
                        <% } %>
                    </div>
                </div>
            </section>
        </main>

        <!-- Add Category Modal Overlay -->
        <div class="brand-modal-overlay" id="addCategoryModal">
            <section class="brand-modal"
                     role="dialog"
                     aria-modal="true"
                     aria-labelledby="addCategoryTitle">

                <div class="brand-form-header">
                    <h2 id="addCategoryTitle">Thêm danh mục mới</h2>
                    <a href="#" aria-label="Đóng" class="btn-close-modal">×</a>
                </div>

                <form action="<%= contextPath %>/admin/categories"
                      method="post"
                      class="brand-modal-form"
                      id="addCategoryForm"
                      novalidate>

                    <input type="hidden" name="action" value="add">

                    <label for="addCategoryName">Tên danh mục <span>*</span></label>

                    <input id="addCategoryName"
                           name="categoryName"
                           type="text"
                           value="<%= h(addCategoryOldName) %>"
                           placeholder="VD: Card đồ họa, Bo mạch chủ, Nguồn máy tính..."
                           minlength="2"
                           class="<%= !addCategoryNameError.isEmpty() ? "is-invalid" : "" %>"
                           required>

                    <% if (!addCategoryNameError.isEmpty()) { %>
                    <small class="error-feedback">
                        <%= h(addCategoryNameError) %>
                    </small>
                    <% } %>

                    <div class="brand-form-actions">
                        <a class="brand-secondary-button btn-close-modal" href="#">Hủy</a>
                        <button class="brand-primary-button" type="submit">Lưu</button>
                    </div>
                </form>
            </section>
        </div>

        <!-- Edit Category Modal Overlay -->
        <div class="brand-modal-overlay" id="editCategoryModal">
            <section class="brand-modal"
                     role="dialog"
                     aria-modal="true"
                     aria-labelledby="editCategoryTitle">

                <div class="brand-form-header">
                    <h2 id="editCategoryTitle">Sửa danh mục</h2>
                    <a href="#" aria-label="Đóng" class="btn-close-modal">×</a>
                </div>

                <form action="<%= contextPath %>/admin/categories"
                      method="post"
                      class="brand-modal-form"
                      id="editCategoryForm"
                      novalidate>

                    <input type="hidden" name="action" value="update">

                    <input type="hidden"
                           name="categoryId"
                           id="editCategoryId"
                           value="<%= h(editCategoryOldId) %>">

                    <label for="editCategoryName">Tên danh mục <span>*</span></label>

                    <input id="editCategoryName"
                           name="categoryName"
                           type="text"
                           value="<%= h(editCategoryOldName) %>"
                           placeholder="VD: Card đồ họa"
                           minlength="2"
                           class="<%= !editCategoryNameError.isEmpty() ? "is-invalid" : "" %>"
                           required>

                    <% if (!editCategoryNameError.isEmpty()) { %>
                    <small class="error-feedback">
                        <%= h(editCategoryNameError) %>
                    </small>
                    <% } %>

                    <div class="brand-form-actions">
                        <a class="brand-secondary-button btn-close-modal" href="#">Hủy</a>
                        <button class="brand-primary-button" type="submit">Cập nhật</button>
                    </div>
                </form>
            </section>
        </div>

        <jsp:include page="/includes/footer.jsp" />

        <script>
            window.categoryValidationUrl = '<%= contextPath %>/admin/categories';
        </script>
        <script src="<%= contextPath %>/js/admin-categories.js?v=1.0.7"></script>

    </body>
</html>
