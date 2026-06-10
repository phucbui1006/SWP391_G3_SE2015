<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Brand" %>
<%@ page import="model.User" %>

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
    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Quản lý thương hiệu</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body class="dashboard-body admin-brand-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="admin-brand-page">
            <section class="admin-page-heading">
                <h1>Quản lý thương hiệu</h1>
                <div class="admin-breadcrumb">
                    <a href="<%= ctx %>/Dashboard">Dashboard</a>
                    <span>›</span>
                    <span>Sản phẩm</span>
                    <span>›</span>
                    <strong>Thương hiệu</strong>
                </div>
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
                                    <th>Đường dẫn logo</th>
                                    <th>Số lượng sản phẩm</th>
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
                                    <td><%= h(brand.getImg()) %></td>
                                    <td><%= brand.getProductCount() %></td>
                                    <td>
                                        <div class="brand-actions">
                                            <a class="brand-action edit"
                                               href="#edit-brand-<%= brand.getBrandId() %>"
                                               aria-label="Sửa <%= h(brand.getBrandName()) %>">Sửa</a>

                                            <form action="<%= ctx %>/AdminBrands" method="post">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="brandId" value="<%= brand.getBrandId() %>">
                                                <button class="brand-action delete" type="submit" aria-label="Xóa <%= h(brand.getBrandName()) %>">Xóa</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
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

                    <label for="modalBrandName">Tên thương hiệu <span>*</span></label>
                    <input id="modalBrandName" name="brandName" type="text" placeholder="VD: ASUS" required>

                    <label for="modalBrandImg">Logo <span>*</span></label>
                    <input id="modalBrandImg" name="imgFile" type="file" accept="image/png,image/jpeg,image/webp" required>
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

                <form action="<%= ctx %>/AdminBrands" method="post" enctype="multipart/form-data" class="brand-modal-form">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="brandId" value="<%= brand.getBrandId() %>">
                    <input type="hidden" name="currentImg" value="<%= h(brand.getImg()) %>">

                    <label for="editBrandName<%= brand.getBrandId() %>">Tên thương hiệu <span>*</span></label>
                    <input id="editBrandName<%= brand.getBrandId() %>" name="brandName" type="text" value="<%= h(brand.getBrandName()) %>" required>

                    <label for="editBrandImg<%= brand.getBrandId() %>">Logo</label>
                    <input id="editBrandImg<%= brand.getBrandId() %>" name="imgFile" type="file" accept="image/png,image/jpeg,image/webp">
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
    </body>
</html>
