<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="model.Category" %>

<%
    List<Category> categories = (List<Category>) request.getAttribute("categories");

    String keyword = (String) request.getAttribute("keyword");
    String sort = (String) request.getAttribute("sort");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalCategories = (Integer) request.getAttribute("totalCategories");
    Integer startItem = (Integer) request.getAttribute("startItem");
    Integer endItem = (Integer) request.getAttribute("endItem");

    if (categories == null) {
        categories = Collections.emptyList();
    }

    if (keyword == null) {
        keyword = "";
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
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý danh mục sản phẩm</title>

        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/style.css">
        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/categories.css">

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
                    <a href="<%= contextPath %>/admin/products">Sản phẩm</a>
                    <span>›</span>
                    <strong>Danh mục sản phẩm</strong>
                </div>
            </div>

            <section class="admin-category-card">

                <form action="<%= contextPath %>/admin/categories" method="get" class="admin-category-toolbar">

                    <div class="category-search">
                        <input type="text"
                               name="keyword"
                               value="<%= keyword %>"
                               placeholder="Tìm kiếm danh mục...">

                        <button type="submit">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </button>
                    </div>

                    <div class="category-sort">
                        <label>Sắp xếp:</label>

                        <select name="sort" onchange="this.form.submit()">
                            <option value="newest" <%= "newest".equals(sort) ? "selected" : "" %>>Mới nhất</option>
                            <option value="oldest" <%= "oldest".equals(sort) ? "selected" : "" %>>Cũ nhất</option>
                            <option value="name_asc" <%= "name_asc".equals(sort) ? "selected" : "" %>>Tên A-Z</option>
                            <option value="name_desc" <%= "name_desc".equals(sort) ? "selected" : "" %>>Tên Z-A</option>
                        </select>
                    </div>

                    <a href="<%= contextPath %>/admin/category/add" class="btn-add-category">
                        <i class="fa-solid fa-plus"></i>
                        Thêm danh mục
                    </a>

                </form>

                <div class="table-wrapper">
                    <table class="admin-category-table">
                        <thead>
                            <tr>
                                <th>Mã danh mục</th>
                                <th>Tên danh mục</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (categories.isEmpty()) { %>
                            <tr>
                                <td colspan="3" style="text-align:center; padding: 30px;">
                                    Không có danh mục nào
                                </td>
                            </tr>
                            <% } else { %>

                            <% for (Category c : categories) { %>
                            <tr>
                                <td><%= c.getCategoryId() %></td>
                                <td><%= c.getCategoryName() %></td>
                                <td>
                                    <div class="category-actions">

                                        <a href="<%= contextPath %>/admin/category/detail?id=<%= c.getCategoryId() %>"
                                           class="btn-view">
                                            <i class="fa-solid fa-eye"></i> Xem
                                        </a>

                                        <a href="<%= contextPath %>/admin/category/edit?id=<%= c.getCategoryId() %>"
                                           class="btn-edit">
                                            <i class="fa-solid fa-pen"></i> Sửa
                                        </a>

                                        <a href="<%= contextPath %>/admin/category/delete?id=<%= c.getCategoryId() %>"
                                           class="btn-delete"
                                           onclick="return confirm('Bạn có chắc muốn xóa danh mục này không?')">
                                            <i class="fa-solid fa-trash"></i> Xóa
                                        </a>

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
                        Hiển thị <%= startItem %> đến <%= endItem %> của <%= totalCategories %> danh mục
                    </p>

                    <div class="admin-pagination">

                        <% if (currentPage > 1) { %>
                        <a class="page-btn"
                           href="<%= contextPath %>/admin/categories?page=<%= currentPage - 1 %>&keyword=<%= keyword %>&sort=<%= sort %>">
                            ‹
                        </a>
                        <% } else { %>
                        <span class="page-btn disabled">‹</span>
                        <% } %>

                        <%
                            int showPages = Math.min(totalPages, 5);
                            for (int i = 1; i <= showPages; i++) {
                        %>
                        <a class="page-btn <%= currentPage == i ? "active" : "" %>"
                           href="<%= contextPath %>/admin/categories?page=<%= i %>&keyword=<%= keyword %>&sort=<%= sort %>">
                            <%= i %>
                        </a>
                        <% } %>

                        <% if (totalPages > 6) { %>
                        <span class="page-dots">...</span>

                        <a class="page-btn <%= currentPage == totalPages ? "active" : "" %>"
                           href="<%= contextPath %>/admin/categories?page=<%= totalPages %>&keyword=<%= keyword %>&sort=<%= sort %>">
                            <%= totalPages %>
                        </a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                        <a class="page-btn"
                           href="<%= contextPath %>/admin/categories?page=<%= currentPage + 1 %>&keyword=<%= keyword %>&sort=<%= sort %>">
                            ›
                        </a>
                        <% } else { %>
                        <span class="page-btn disabled">›</span>
                        <% } %>

                    </div>
                </div>

            </section>

        </main>

        <jsp:include page="/includes/footer.jsp" />

    </body>
</html>