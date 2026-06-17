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
    String listQuery = "&keyword=" + enc(keyword) + "&status=" + enc(status) + "&sort=" + enc(sort);
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Qu&#7843;n l&#253; danh m&#7909;c s&#7843;n ph&#7849;m</title>

        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/style.css">
        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/admin-categories.css">

        <link rel="stylesheet"
              href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    </head>

    <body class="admin-category-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="admin-category-container">

            <div class="admin-page-title">
                <h2>Danh s&#225;ch danh m&#7909;c</h2>

                <div class="admin-breadcrumb">
                    <a href="<%= contextPath %>/Dashboard">Dashboard</a>
                    <span>&rsaquo;</span>
                    <a href="<%= contextPath %>/admin/products">S&#7843;n ph&#7849;m</a>
                    <span>&rsaquo;</span>
                    <strong>Danh m&#7909;c s&#7843;n ph&#7849;m</strong>
                </div>
            </div>

            <% if (success != null && !success.isEmpty()) { %>
            <div class="category-alert success"><%= h(success) %></div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="category-alert error"><%= h(error) %></div>
            <% } %>

            <section class="admin-category-card">

                <form action="<%= contextPath %>/admin/categories" method="get" class="admin-category-toolbar" id="adminCategorySearchForm">

                    <div class="category-search">
                        <input type="text"
                               id="categorySearchInput"
                               name="keyword"
                               value="<%= h(keyword) %>"
                               placeholder="Tìm kiếm danh mục...">
                    </div>

                    <div class="category-sort">
                        <label>Trạng thái:</label>

                        <select name="status" id="statusFilter">
                            <option value="ALL" <%= "ALL".equals(status) ? "selected" : "" %>>Tất cả</option>
                            <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : "" %>>Đang hoạt động</option>
                            <option value="INACTIVE" <%= "INACTIVE".equals(status) ? "selected" : "" %>>Đã vô hiệu hóa</option>
                        </select>
                    </div>

                    <div class="category-sort">
                        <label>Sắp xếp:</label>

                        <select name="sort" id="sortFilter">
                            <option value="newest" <%= "newest".equals(sort) ? "selected" : "" %>>Mới nhất</option>
                            <option value="oldest" <%= "oldest".equals(sort) ? "selected" : "" %>>Cũ nhất</option>
                            <option value="name_asc" <%= "name_asc".equals(sort) ? "selected" : "" %>>Tên A-Z</option>
                            <option value="name_desc" <%= "name_desc".equals(sort) ? "selected" : "" %>>Tên Z-A</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-search-category">
                        <i class="fa-solid fa-magnifying-glass"></i> Tìm kiếm
                    </button>

                    <a href="#add-category-modal" class="btn-add-category">
                        <i class="fa-solid fa-plus"></i>
                        Thêm danh mục
                    </a>

                </form>

                <div class="table-wrapper">
                    <table class="admin-category-table">
                        <thead>
                            <tr>
                                <th>M&#227; danh m&#7909;c</th>
                                <th>T&#234;n danh m&#7909;c</th>
                                <th>Tr&#7841;ng th&#225;i</th>
                                <th>Số lượng sản phẩm</th>
                                <th>Thao t&#225;c</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (categories.isEmpty()) { %>
                            <tr>
                                <td colspan="5" style="text-align:center; padding: 30px;">
                                    Kh&#244;ng c&#243; danh m&#7909;c n&#224;o
                                </td>
                            </tr>
                            <% } else { %>

                            <% for (Category c : categories) { %>
                            <tr>
                                <td><%= c.getCategoryId() %></td>
                                <td><%= h(c.getCategoryName()) %></td>
                                <td><%= h(c.getStatus()) %></td>
                                <td><%= c.getProductCount() %></td>
                                <td>
                                    <div class="category-actions">

                                        <a href="<%= contextPath %>/admin/category/detail?id=<%= c.getCategoryId() %>"
                                           class="btn-view">
                                            <i class="fa-solid fa-eye"></i> Xem
                                        </a>

                                        <a href="#edit-category-<%= c.getCategoryId() %>"
                                           class="btn-edit">
                                            <i class="fa-solid fa-pen"></i> S&#7917;a
                                        </a>

                                        <form action="<%= contextPath %>/admin/categories" method="post" style="display:inline;">
                                            <input type="hidden" name="categoryId" value="<%= c.getCategoryId() %>">
                                            <input type="hidden" name="action" value="<%= "ACTIVE".equalsIgnoreCase(c.getStatus()) ? "delete" : "activate" %>">
                                            <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                            <input type="hidden" name="status" value="<%= h(status) %>">
                                            <input type="hidden" name="sort" value="<%= h(sort) %>">
                                            <input type="hidden" name="page" value="<%= currentPage %>">
                                            <button type="submit"
                                                    class="btn-delete"
                                                    onclick="return confirm('B&#7841;n c&#243; ch&#7855;c mu&#7889;n &#273;&#7893;i tr&#7841;ng th&#225;i danh m&#7909;c n&#224;y kh&#244;ng?')">
                                                <i class="fa-solid fa-power-off"></i>
                                                <%= "ACTIVE".equalsIgnoreCase(c.getStatus()) ? "V&#244; hi&#7879;u h&#243;a" : "K&#237;ch ho&#7841;t" %>
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
                        Hi&#7875;n th&#7883; <%= startItem %> &#273;&#7871;n <%= endItem %> c&#7911;a <%= totalCategories %> danh m&#7909;c
                    </p>

                    <div class="admin-pagination">

                        <% if (currentPage > 1) { %>
                        <a class="page-btn"
                           href="<%= contextPath %>/admin/categories?page=<%= currentPage - 1 %><%= listQuery %>">
                            &lsaquo;
                        </a>
                        <% } else { %>
                        <span class="page-btn disabled">&lsaquo;</span>
                        <% } %>

                        <%
                            for (int i = 1; i <= totalPages; i++) {
                        %>
                        <a class="page-btn <%= currentPage == i ? "active" : "" %>"
                           href="<%= contextPath %>/admin/categories?page=<%= i %><%= listQuery %>">
                            <%= i %>
                        </a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                        <a class="page-btn"
                           href="<%= contextPath %>/admin/categories?page=<%= currentPage + 1 %><%= listQuery %>">
                            &rsaquo;
                        </a>
                        <% } else { %>
                        <span class="page-btn disabled">&rsaquo;</span>
                        <% } %>

                    </div>
                </div>

            </section>

        </main>

        <%-- ==================== ADD CATEGORY MODAL ==================== --%>
        <div class="cat-modal-overlay" id="add-category-modal">
            <section class="cat-modal" role="dialog" aria-modal="true" aria-labelledby="addCategoryTitle">
                <div class="cat-modal-header">
                    <h2 id="addCategoryTitle">Thêm danh mục mới</h2>
                    <a href="#" aria-label="Đóng">&times;</a>
                </div>

                <form action="<%= contextPath %>/admin/categories" method="post" class="cat-modal-form"
                      id="addCategoryForm" novalidate>
                    <input type="hidden" name="action" value="add">

                    <div class="cat-form-group">
                        <label for="addCategoryName">Tên danh mục <span>*</span></label>
                        <input id="addCategoryName" name="categoryName" type="text"
                               placeholder="VD: CPU, RAM, SSD..." required
                               minlength="2" maxlength="100">
                        <small class="cat-form-error" id="addCategoryNameError"></small>
                    </div>

                    <div class="cat-modal-actions">
                        <a class="cat-btn-cancel" href="#">Hủy</a>
                        <button class="cat-btn-submit" type="submit">Thêm danh mục</button>
                    </div>
                </form>
            </section>
        </div>

        <%-- ==================== EDIT CATEGORY MODALS (one per row) ==================== --%>
        <% if (!categories.isEmpty()) { %>
        <% for (Category c : categories) { %>
        <div class="cat-modal-overlay" id="edit-category-<%= c.getCategoryId() %>">
            <section class="cat-modal" role="dialog" aria-modal="true"
                     aria-labelledby="editCategoryTitle<%= c.getCategoryId() %>">
                <div class="cat-modal-header">
                    <h2 id="editCategoryTitle<%= c.getCategoryId() %>">Sửa danh mục</h2>
                    <a href="#" aria-label="Đóng">&times;</a>
                </div>

                <form action="<%= contextPath %>/admin/categories" method="post" class="cat-modal-form"
                      novalidate>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="categoryId" value="<%= c.getCategoryId() %>">

                    <div class="cat-form-group">
                        <label>Mã danh mục</label>
                        <input type="text" value="<%= c.getCategoryId() %>" disabled>
                    </div>

                    <div class="cat-form-group">
                        <label for="editCategoryName<%= c.getCategoryId() %>">Tên danh mục <span>*</span></label>
                        <input id="editCategoryName<%= c.getCategoryId() %>"
                               name="categoryName" type="text"
                               value="<%= h(c.getCategoryName()) %>"
                               required minlength="2" maxlength="100">
                        <small class="cat-form-error"></small>
                    </div>

                    <div class="cat-form-group">
                        <label for="editCategoryStatus<%= c.getCategoryId() %>">Trạng thái</label>
                        <select id="editCategoryStatus<%= c.getCategoryId() %>" name="status">
                            <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(c.getStatus()) ? "selected" : "" %>>Đang hoạt động</option>
                            <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(c.getStatus()) ? "selected" : "" %>>Đã vô hiệu hóa</option>
                        </select>
                    </div>

                    <div class="cat-modal-actions">
                        <a class="cat-btn-cancel" href="#">Hủy</a>
                        <button class="cat-btn-submit" type="submit">Cập nhật</button>
                    </div>
                </form>
            </section>
        </div>
        <% } %>
        <% } %>

        <jsp:include page="/includes/footer.jsp" />

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                // Trim search input on submit
                var searchForm = document.getElementById("adminCategorySearchForm");
                if (searchForm) {
                    searchForm.addEventListener("submit", function () {
                        var searchInput = document.getElementById("categorySearchInput");
                        if (searchInput) {
                            searchInput.value = searchInput.value.trim();
                        }
                    });
                }

                // Client-side validation for all modal forms
                var modalForms = document.querySelectorAll(".cat-modal-form");
                modalForms.forEach(function (form) {
                    form.addEventListener("submit", function (e) {
                        var nameInput = form.querySelector("input[name='categoryName']");
                        var errorEl = nameInput
                                ? nameInput.parentElement.querySelector(".cat-form-error")
                                : null;

                        if (!nameInput) return;

                        var name = nameInput.value.trim();
                        nameInput.value = name;

                        if (name.length < 2 || name.length > 100) {
                            e.preventDefault();
                            if (errorEl) {
                                errorEl.textContent = "Tên danh mục phải từ 2 đến 100 ký tự.";
                                errorEl.style.display = "block";
                            }
                            nameInput.focus();
                            return;
                        }

                        if (errorEl) {
                            errorEl.style.display = "none";
                        }
                    });
                });

                // Clear the add form when its modal is opened
                var addLink = document.querySelector('a[href="#add-category-modal"]');
                if (addLink) {
                    addLink.addEventListener("click", function () {
                        var addInput = document.getElementById("addCategoryName");
                        var addError = document.getElementById("addCategoryNameError");
                        if (addInput) addInput.value = "";
                        if (addError) addError.style.display = "none";
                    });
                }
            });
        </script>

    </body>
</html>
