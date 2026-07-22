<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Brand" %>
<%@ page import="model.User" %>
<%@ page import="java.net.URLEncoder" %>

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

    private String js(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("<", "\\u003C")
                .replace(">", "\\u003E")
                .replace("&", "\\u0026");
    }

    private String pageUrl(String ctx, String keyword, String status, String sort, int page) {
        try {
            return ctx + "/AdminBrands?keyword=" + URLEncoder.encode(keyword == null ? "" : keyword, "UTF-8")
                    + "&status=" + URLEncoder.encode(status, "UTF-8")
                    + "&sort=" + URLEncoder.encode(sort, "UTF-8")
                    + "&page=" + page;
        } catch (Exception e) {
            return ctx + "/AdminBrands?page=" + page;
        }
    }
%>

<%
    User account = (User) session.getAttribute("account");

    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/Login");
        return;
    }

    String roleName = account.getRoleName();
    if (roleName != null) {
        roleName = roleName.trim().toUpperCase();
    } else {
        roleName = "";
    }

    if (!"ADMIN".equals(roleName)) {
        response.sendRedirect(request.getContextPath() + "/Dashboard");
        return;
    }

    String ctx = request.getContextPath();
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");
    String keyword = (String) request.getAttribute("keyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String selectedSort = (String) request.getAttribute("selectedSort");
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
    List<Brand> allBrands = (List<Brand>) request.getAttribute("allBrands");
    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
    int currentPage = currentPageObj == null ? 1 : currentPageObj;
    int totalPages = totalPagesObj == null ? 1 : totalPagesObj;

    if (selectedStatus == null || selectedStatus.isEmpty()) {
        selectedStatus = "ALL";
    }

    if (selectedSort == null || selectedSort.isEmpty()) {
        selectedSort = "newest";
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Quản lý thương hiệu</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>
    <body class="dashboard-body admin-brand-body" style=" padding-bottom: 0px">

        <jsp:include page="/includes/header.jsp" />

        <main class="admin-brand-page">
            <section class="admin-page-heading">
                <nav class="admin-breadcrumb site-breadcrumb" aria-label="Breadcrumb">
                    <a href="<%= ctx %>/Dashboard">Dashboard</a>
                    <span>›</span>
                    <span>Sản phẩm</span>
                    <span>›</span>
                    <strong>Thương hiệu</strong>
                </nav>
                <h1>Quản lý thương hiệu</h1>
            </section>

            <% if (success != null && !success.isEmpty()) { %>
            <div class="brand-alert success"><%= h(success) %></div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="brand-alert error"><%= h(error) %></div>
            <% } %>

            <section class="brand-management-layout">
                <div class="brand-table-panel">
                    <div class="brand-toolbar">
                        <form class="brand-search-form" action="<%= ctx %>/AdminBrands" method="get">
                            <input type="text" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm kiếm thương hiệu theo tên...">

                            <select name="status" onchange="this.form.submit()">
                                <option value="ALL" <%= "ALL".equals(selectedStatus) ? "selected" : "" %>>Tất cả trạng thái</option>
                                <option value="ACTIVE" <%= "ACTIVE".equals(selectedStatus) ? "selected" : "" %>>Hoạt động</option>
                                <option value="INACTIVE" <%= "INACTIVE".equals(selectedStatus) ? "selected" : "" %>>Ngưng hoạt động</option>
                            </select>

                            <select name="sort" onchange="this.form.submit()">
                                <option value="newest" <%= "newest".equals(selectedSort) ? "selected" : "" %>>Mới nhất</option>
                                <option value="oldest" <%= "oldest".equals(selectedSort) ? "selected" : "" %>>Cũ nhất</option>
                                <option value="product_count_asc" <%= "product_count_asc".equals(selectedSort) ? "selected" : "" %>>Số sản phẩm tăng dần</option>
                                <option value="product_count_desc" <%= "product_count_desc".equals(selectedSort) ? "selected" : "" %>>Số sản phẩm giảm dần</option>
                            </select>

                            <button type="submit">Tìm kiếm</button>
                        </form>

                        <a class="brand-add-button" href="#add-brand-modal">+ Thêm thương hiệu</a>
                    </div>

                    <div class="brand-table-wrap">
                        <table class="brand-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Logo</th>
                                    <th>Tên thương hiệu</th>
                                    <th>Số lượng sản phẩm</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (brands == null || brands.isEmpty()) { %>
                                <tr>
                                    <td class="brand-empty-state" colspan="6">Không tìm thấy thương hiệu phù hợp.</td>
                                </tr>
                                <% } else { %>
                                <% for (Brand brand : brands) { %>
                                <tr>
                                    <td><%= brand.getBrandId() %></td>
                                    <td>
                                        <img class="brand-logo" src="<%= ctx %>/<%= h(brand.getImg()) %>" alt="<%= h(brand.getBrandName()) %>">
                                    </td>
                                    <td><%= h(brand.getBrandName()) %></td>
                                    <td><%= brand.getProductCount() %></td>
                                    <td><%= "ACTIVE".equalsIgnoreCase(brand.getStatus()) ? "Hoạt động" : "Ngưng hoạt động" %></td>
                                    <td>
                                        <div class="brand-actions">
                                            <a class="brand-action edit"
                                               href="#edit-brand-<%= brand.getBrandId() %>"
                                               aria-label="Sửa <%= h(brand.getBrandName()) %>">Sửa</a>

                                            <form action="<%= ctx %>/AdminBrands" method="post">
                                                <input type="hidden" name="action" value="<%= "ACTIVE".equalsIgnoreCase(brand.getStatus()) ? "delete" : "activate" %>">
                                                <input type="hidden" name="brandId" value="<%= brand.getBrandId() %>">
                                                <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                                <input type="hidden" name="status" value="<%= h(selectedStatus) %>">
                                                <input type="hidden" name="sort" value="<%= h(selectedSort) %>">
                                                <input type="hidden" name="page" value="<%= currentPage %>">
                                                <button class="brand-action delete" type="submit" aria-label="Đổi trạng thái <%= h(brand.getBrandName()) %>">
                                                    <%= "ACTIVE".equalsIgnoreCase(brand.getStatus()) ? "Ngưng hoạt động" : "Hoạt động" %>
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

                    <% if (totalPages > 1) { %>
                    <nav class="home-pagination" aria-label="Phân trang thương hiệu">
                        <% if (currentPage > 1) { %>
                        <a href="<%= pageUrl(ctx, keyword, selectedStatus, selectedSort, currentPage - 1) %>" aria-label="Trang trước">&lt;</a>
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
                        <a class="<%= currentPage == 1 ? "active" : "" %>" href="<%= pageUrl(ctx, keyword, selectedStatus, selectedSort, 1) %>">1</a>
                        <% if (fromPage > 2) { %><span>...</span><% } %>
                        <% for (int pageNumber = fromPage; pageNumber <= toPage; pageNumber++) { %>
                        <a class="<%= currentPage == pageNumber ? "active" : "" %>"
                           href="<%= pageUrl(ctx, keyword, selectedStatus, selectedSort, pageNumber) %>"><%= pageNumber %></a>
                        <% } %>
                        <% if (toPage < totalPages - 1) { %><span>...</span><% } %>
                        <a class="<%= currentPage == totalPages ? "active" : "" %>"
                           href="<%= pageUrl(ctx, keyword, selectedStatus, selectedSort, totalPages) %>"><%= totalPages %></a>

                        <% if (currentPage < totalPages) { %>
                        <a href="<%= pageUrl(ctx, keyword, selectedStatus, selectedSort, currentPage + 1) %>" aria-label="Trang sau">&gt;</a>
                        <% } %>
                    </nav>
                    <% } %>
                </div>
            </section>
        </main>

        <div class="brand-modal-overlay" id="add-brand-modal">
            <section class="brand-modal" role="dialog" aria-modal="true" aria-labelledby="brandModalTitle">
                <div class="brand-form-header">
                    <h2 id="brandModalTitle">Thêm thương hiệu</h2>
                    <a href="#" aria-label="Đóng">×</a>
                </div>

                <form action="<%= ctx %>/AdminBrands" method="post" enctype="multipart/form-data" class="brand-modal-form">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                    <input type="hidden" name="status" value="<%= h(selectedStatus) %>">
                    <input type="hidden" name="sort" value="<%= h(selectedSort) %>">
                    <input type="hidden" name="page" value="<%= currentPage %>">

                    <label for="modalBrandName">Tên thương hiệu <span>*</span></label>
                    <input id="modalBrandName" name="brandName" type="text" placeholder="VD: ASUS" minlength="2" maxlength="20" required>

                    <label for="modalBrandImg">Logo <span>*</span></label>
                    <input id="modalBrandImg" name="imgFile" type="file" accept=".png,.jpg,.jpeg,.webp,image/png,image/jpeg,image/webp" required>
                    <small class="brand-file-note">PNG, JPG, JPEG, WEBP. Tối đa 2MB.</small>

                    <div class="brand-form-actions">
                        <a class="brand-secondary-button" href="#">Hủy</a>
                        <button class="brand-primary-button" type="submit">Lưu</button>
                    </div>
                </form>
            </section>
        </div>

        <% if (brands != null) { %>
        <% for (Brand brand : brands) { %>
        <div class="brand-modal-overlay" id="edit-brand-<%= brand.getBrandId() %>">
            <section class="brand-modal" role="dialog" aria-modal="true" aria-labelledby="editBrandTitle<%= brand.getBrandId() %>">
                <div class="brand-form-header">
                    <h2 id="editBrandTitle<%= brand.getBrandId() %>">Sửa thương hiệu</h2>
                    <a href="#" aria-label="Đóng">×</a>
                </div>

                <form action="<%= ctx %>/AdminBrands" method="post" enctype="multipart/form-data" class="brand-modal-form" data-brand-id="<%= brand.getBrandId() %>">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="brandId" value="<%= brand.getBrandId() %>">
                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                    <input type="hidden" name="status" value="<%= h(selectedStatus) %>">
                    <input type="hidden" name="sort" value="<%= h(selectedSort) %>">
                    <input type="hidden" name="page" value="<%= currentPage %>">
                    <label for="editBrandName<%= brand.getBrandId() %>">Tên thương hiệu <span>*</span></label>
                    <input id="editBrandName<%= brand.getBrandId() %>" name="brandName" type="text" value="<%= h(brand.getBrandName()) %>" minlength="2" maxlength="20" required>

                    <label for="editBrandImg<%= brand.getBrandId() %>">Logo</label>
                    <input id="editBrandImg<%= brand.getBrandId() %>" name="imgFile" type="file" accept=".png,.jpg,.jpeg,.webp,image/png,image/jpeg,image/webp">
                    <small class="brand-file-note">Chọn ảnh mới nếu muốn thay logo hiện tại.</small>

                    <div class="brand-form-actions">
                        <a class="brand-secondary-button" href="#">Hủy</a>
                        <button class="brand-primary-button" type="submit">Cập nhật</button>
                    </div>
                </form>
            </section>
        </div>
        <% } %>
        <% } %>

        <jsp:include page="/includes/footer.jsp" />
        <script>
            window.existingBrands = [
                <% if (allBrands != null) { %>
                <% for (int i = 0; i < allBrands.size(); i++) {
                    Brand brand = allBrands.get(i);
                %>
                {
                    id: <%= brand.getBrandId() %>,
                    name: "<%= js(brand.getBrandName()) %>"
                }<%= i + 1 < allBrands.size() ? "," : "" %>
                <% } %>
                <% } %>
            ];
        </script>
        <script src="<%= ctx %>/js/admin-brands.js?v=4"></script>
    </body>
</html>
