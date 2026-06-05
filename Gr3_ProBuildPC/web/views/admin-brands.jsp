<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>

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

    String[][] brands = {
        {"1", "asus.png", "ASUS", "ASUS - Hãng công nghệ hàng đầu Đài Loan", "128"},
        {"2", "msi.png", "MSI", "MSI - Hãng chuyên về linh kiện máy tính", "96"},
        {"3", "gigabyte.png", "Gigabyte", "Gigabyte - Nhà sản xuất phần cứng uy tín", "113"},
        {"4", "intel.png", "Intel", "Intel - Hãng sản xuất CPU hàng đầu thế giới", "87"},
        {"5", "amd.png", "AMD", "AMD - Advanced Micro Devices", "75"},
        {"6", "kingston.png", "Kingston", "Kingston - Hãng chuyên về bộ nhớ", "29"},
        {"7", "asus.png", "AORUS", "AORUS - Thương hiệu gaming cao cấp của Gigabyte", "27"},
        {"8", "msi.png", "Cooler Master", "Cooler Master - Hãng chuyên về tản nhiệt và case", "21"},
        {"9", "gigabyte.png", "NVIDIA", "NVIDIA - Hãng sản xuất GPU hàng đầu thế giới", "18"}
    };
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

            <section class="brand-management-layout">
                <div class="brand-table-panel">
                    <div class="brand-toolbar">
                        <form class="brand-search-form" action="#" method="get">
                            <input type="text" name="keyword" placeholder="Tìm kiếm thương hiệu...">
                            <button type="submit" aria-label="Tìm kiếm">⌕</button>
                        </form>

                        <button class="brand-add-button" type="button">+ Thêm thương hiệu</button>
                    </div>

                    <div class="brand-table-wrap">
                        <table class="brand-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Logo</th>
                                    <th>Tên thương hiệu</th>
                                    <th>Mô tả</th>
                                    <th>Số lượng sản phẩm</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (String[] brand : brands) { %>
                                <tr>
                                    <td><%= brand[0] %></td>
                                    <td>
                                        <img class="brand-logo" src="<%= ctx %>/images/brands/<%= brand[1] %>" alt="<%= brand[2] %>">
                                    </td>
                                    <td><%= brand[2] %></td>
                                    <td><%= brand[3] %></td>
                                    <td><%= brand[4] %></td>
                                    <td>
                                        <div class="brand-actions">
                                            <button class="brand-action edit" type="button" aria-label="Sửa <%= brand[2] %>">✎</button>
                                            <button class="brand-action delete" type="button" aria-label="Xóa <%= brand[2] %>">⌫</button>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <aside class="brand-form-column">
                    <section class="brand-form-card">
                        <div class="brand-form-header">
                            <h2>Thêm thương hiệu</h2>
                            <button type="button" aria-label="Đóng">×</button>
                        </div>

                        <form action="#" method="post" enctype="multipart/form-data">
                            <label for="brandName">Tên thương hiệu <span>*</span></label>
                            <input id="brandName" name="brandName" type="text" placeholder="Nhập tên thương hiệu">

                            <label>Logo</label>
                            <div class="brand-upload-box">
                                <div class="upload-icon">⇧</div>
                                <strong>Chọn ảnh hoặc kéo thả vào đây</strong>
                                <small>PNG, JPG, JPEG (Tối đa 2MB)</small>
                            </div>

                            <label for="brandDescription">Mô tả</label>
                            <textarea id="brandDescription" name="description" rows="4" placeholder="Nhập mô tả thương hiệu"></textarea>

                            <label for="brandQuantity">Số lượng sản phẩm</label>
                            <input id="brandQuantity" name="productCount" type="number" min="0" placeholder="Nhập số lượng sản phẩm">

                            <div class="brand-form-actions">
                                <button class="brand-secondary-button" type="button">Hủy</button>
                                <button class="brand-primary-button" type="submit">Lưu</button>
                            </div>
                        </form>
                    </section>

                    <section class="brand-form-card">
                        <div class="brand-form-header">
                            <h2>Sửa thương hiệu</h2>
                            <button type="button" aria-label="Đóng">×</button>
                        </div>

                        <form action="#" method="post" enctype="multipart/form-data">
                            <label for="editBrandName">Tên thương hiệu <span>*</span></label>
                            <input id="editBrandName" name="editBrandName" type="text" value="ASUS">

                            <label>Logo</label>
                            <div class="brand-current-logo">
                                <img src="<%= ctx %>/images/brands/asus.png" alt="ASUS">
                                <button type="button">Thay đổi ảnh</button>
                            </div>

                            <label for="editBrandDescription">Mô tả</label>
                            <textarea id="editBrandDescription" name="editDescription" rows="4">ASUS - Hãng công nghệ hàng đầu Đài Loan</textarea>

                            <label for="editBrandQuantity">Số lượng sản phẩm</label>
                            <input id="editBrandQuantity" name="editProductCount" type="number" min="0" value="128">

                            <div class="brand-form-actions">
                                <button class="brand-secondary-button" type="button">Hủy</button>
                                <button class="brand-primary-button" type="submit">Cập nhật</button>
                            </div>
                        </form>
                    </section>
                </aside>
            </section>
        </main>

        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
