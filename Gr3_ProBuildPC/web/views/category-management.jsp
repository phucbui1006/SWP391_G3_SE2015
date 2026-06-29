<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="model.Category" %>

<%! private String h(String value) { if (value==null) { return "" ; } return value
    .replace("&", "&amp;" ) .replace("<", "&lt;" ) .replace(">", "&gt;")
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

<% List<Category> categories = (List<Category>) request.getAttribute("categories");

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

        if (categories == null) {
        categories = Collections.emptyList();
        }

        if (keyword == null) {
        keyword = "";
        }

        if (status == null || status.trim().isEmpty()) {
        status = "ALL";
        }

        if (sort == null) {
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

        String contextPath = request.getContextPath();
        String listQuery = "&keyword=" + enc(keyword) + "&status=" + enc(status) + "&sort="
        + enc(sort);
%>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <title>Quản lý danh mục sản phẩm</title>

        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/style.css">
        <link rel="stylesheet" type="text/css"
              href="<%= contextPath %>/css/admin-categories.css?v=1.0.1"">

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    </head>

    <body class="admin-category-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="admin-category-container">

            <div class="admin-page-title">
                <h2>Danh sách danh mục</h2>

                <div class="admin-breadcrumb">
                    <a href="<%= contextPath %>/Dashboard">Dashboard</a>
                    <span>›</span>
                    <span>Sản phẩm</span>
                    <span>›</span>
                    <span>Quản lý danh mục sản phẩm</span>
                </div>
            </div>

            <% if (success !=null && !success.isEmpty()) { %>
            <div class="category-alert success">
                <%= h(success) %>
            </div>
            <% } %>

            <% if (error !=null && !error.isEmpty()) { %>
            <div class="category-alert error">
                <%= h(error) %>
            </div>
            <% } %>

            <section class="admin-category-card">

                <form action="<%= contextPath %>/admin/categories" method="get" class="admin-category-toolbar" id="adminCategorySearchForm">
                    <div class="category-search-form">
                        <input type="text" id="categorySearchInput" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm kiếm danh mục theo tên...">

                        <select name="status" id="statusFilter">
                            <option value="ALL" <%= "ALL".equals(status) ? "selected" : "" %>>Tất cả trạng thái</option>
                            <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : "" %>>ACTIVE</option>
                            <option value="INACTIVE" <%= "INACTIVE".equals(status) ? "selected" : "" %>>INACTIVE</option>
                        </select>

                        <select name="sort" id="sortFilter">
                            <option value="newest" <%= "newest".equals(sort) ? "selected" : "" %>>Mới nhất</option>
                            <option value="oldest" <%= "oldest".equals(sort) ? "selected" : "" %>>Cũ nhất</option>
                            <option value="name_asc" <%= "name_asc".equals(sort) ? "selected" : "" %>>Tên A-Z</option>
                            <option value="name_desc" <%= "name_desc".equals(sort) ? "selected" : "" %>>Tên Z-A</option>
                        </select>

                        <button type="submit">Tìm kiếm</button>
                    </div>

                    <a href="<%= contextPath %>/admin/category/add" class="btn-add-category">+ Thêm danh mục</a>
                </form>

                <div class="table-wrapper">
                    <table class="admin-category-table">
                        <thead>
                            <tr>
                                <th>Mã danh mục</th>
                                <th>Tên danh mục</th>
                                <th>Trạng thái</th>
                                <th>Số lượng sản phẩm</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (categories.isEmpty()) { %>
                            <tr>
                                <td colspan="5"
                                    style="text-align:center; padding: 30px;">
                                    Không có danh mục nào.
                                </td>
                            </tr>
                            <% } else { %>

                            <% for (Category c : categories) {
                            %>
                            <tr>
                                <td>
                                    <%= c.getCategoryId() %>
                                </td>
                                <td>
                                    <%= h(c.getCategoryName())
                                    %>
                                </td>
                                <td>
                                    <span
                                        class="status-badge status-<%= c.getStatus().toLowerCase() %>">
                                        <%= "ACTIVE"
                                            .equalsIgnoreCase(c.getStatus())
                                            ? "Đang hoạt động"
                                            : "Vô hiệu hóa"
                                        %>
                                    </span>
                                </td>
                                <td>
                                    <%= c.getProductCount()
                                    %>
                                </td>
                                <td>
                                    <div
                                        class="category-actions">

                                        <a href="<%= contextPath %>/admin/category/edit?id=<%= c.getCategoryId() %>"
                                           class="btn-edit">Sửa</a>

                                        <form
                                            action="<%= contextPath %>/admin/categories"
                                            method="post"
                                            style="display:inline;">
                                            <input
                                                type="hidden"
                                                name="categoryId"
                                                value="<%= c.getCategoryId() %>">
                                            <input
                                                type="hidden"
                                                name="action"
                                                value="<%= "ACTIVE".equalsIgnoreCase(c.getStatus()) ? "delete" : "activate" %>">
                                            <input
                                                type="hidden"
                                                name="keyword"
                                                value="<%= h(keyword) %>">
                                            <input
                                                type="hidden"
                                                name="status"
                                                value="<%= h(status) %>">
                                            <input
                                                type="hidden"
                                                name="sort"
                                                value="<%= h(sort) %>">
                                            <input
                                                type="hidden"
                                                name="page"
                                                value="<%= currentPage %>">
                                            <button
                                                type="submit"
                                                class="btn-delete"
                                                onclick="return confirm('Bạn có chắc muốn đổi trạng thái danh mục này không?')">
                                                <%= "ACTIVE"
                                                    .equalsIgnoreCase(c.getStatus())
                                                    ? "Vô hiệu hóa"
                                                    : "Kích hoạt"
                                                %>
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
                    <p>
                        Hiển thị <%= startItem %>
                        đến <%= endItem %> của <%=totalCategories %> danh mục.
                    </p>

                    <div class="admin-pagination">

                        <% if (currentPage> 1) { %>
                        <a class="page-btn"
                           href="<%= contextPath %>/admin/categories?page=<%= currentPage - 1 %><%= listQuery %>">
                            ‹
                        </a>
                        <% } else { %>
                        <span
                            class="page-btn disabled">‹</span>
                        <% } %>

                        <% for (int i=1; i <=totalPages; i++) { %>
                        <a class="page-btn <%= currentPage == i ? "active" : "" %>"
                           href="<%= contextPath %>/admin/categories?page=<%= i %><%= listQuery %>">
                            <%= i %>
                        </a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                        <a class="page-btn"
                           href="<%= contextPath %>/admin/categories?page=<%= currentPage + 1 %><%= listQuery %>">
                           ›
                        </a>
                        <% } else { %>
                        <span
                            class="page-btn disabled">›</span>
                        <% } %>
                    </div>
                </div>
            </section>
        </main>
        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>