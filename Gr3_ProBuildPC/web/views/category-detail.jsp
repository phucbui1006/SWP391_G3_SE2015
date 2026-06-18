<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="model.Category" %>
<%@ page import="model.Product" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

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
    Category category = (Category) request.getAttribute("category");
    List<Product> products = (List<Product>) request.getAttribute("products");
    String productStatus = (String) request.getAttribute("productStatus");

    Integer currentProductPage = (Integer) request.getAttribute("currentProductPage");
    Integer totalProductPages = (Integer) request.getAttribute("totalProductPages");
    Integer totalFilteredProducts = (Integer) request.getAttribute("totalFilteredProducts");

    if (products == null) {
        products = Collections.emptyList();
    }
    if (productStatus == null) {
        productStatus = "ALL";
    }
    if (currentProductPage == null) {
        currentProductPage = 1;
    }
    if (totalProductPages == null) {
        totalProductPages = 1;
    }
    if (totalFilteredProducts == null) {
        totalFilteredProducts = 0;
    }

    int pageSize = 4;
    int startItem = totalFilteredProducts == 0 ? 0 : (currentProductPage - 1) * pageSize + 1;
    int endItem = Math.min(currentProductPage * pageSize, totalFilteredProducts);

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết danh mục - <%= category != null ? h(category.getCategoryName()) : "" %></title>
        <link rel="stylesheet" type="text/css" href="<%= ctx %>/css/style.css">
        <link rel="stylesheet" type="text/css" href="<%= ctx %>/css/admin-categories.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    </head>
    <body class="admin-category-body">
        <jsp:include page="/includes/header.jsp" />

        <main class="admin-category-container">
            <div class="admin-page-title">
                <h2>Chi tiết danh mục</h2>
                <div class="admin-breadcrumb">
                    <a href="<%= ctx %>/Dashboard">Dashboard</a>
                    <span>&rsaquo;</span>
                    <a href="<%= ctx %>/admin/categories">Danh mục sản phẩm</a>
                    <span>&rsaquo;</span>
                    <strong><%= category != null ? h(category.getCategoryName()) : "" %></strong>
                </div>
            </div>

            <% if (category != null) { %>
            <!-- Category Info Panel -->
            <section class="admin-category-card" style="padding: 24px; margin-bottom: 30px;">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #edf0f5; padding-bottom: 15px; margin-bottom: 20px;">
                    <h3 style="margin: 0; font-size: 20px; font-weight: 700; color: #111;">Thông tin danh mục</h3>
                </div>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 20px;">
                    <div>
                        <span style="color: #777; font-size: 13px; display: block; margin-bottom: 4px; font-weight: 600;">Mã danh mục</span>
                        <strong style="font-size: 16px; color: #111;"><%= category.getCategoryId() %></strong>
                    </div>
                    <div>
                        <span style="color: #777; font-size: 13px; display: block; margin-bottom: 4px; font-weight: 600;">Tên danh mục</span>
                        <strong style="font-size: 16px; color: #111;"><%= h(category.getCategoryName()) %></strong>
                    </div>
                    <div>
                        <span style="color: #777; font-size: 13px; display: block; margin-bottom: 4px; font-weight: 600;">Trạng thái danh mục</span>
                        <span class="status-badge <%= "ACTIVE".equalsIgnoreCase(category.getStatus()) ? "status-active" : "status-inactive" %>" style="display: inline-block; padding: 4px 10px; border-radius: 4px; font-size: 13px; font-weight: 600; text-transform: uppercase;">
                            <%= "ACTIVE".equalsIgnoreCase(category.getStatus()) ? "Đang hoạt động" : "Đã vô hiệu hóa" %>
                        </span>
                    </div>
                    <div>
                        <span style="color: #777; font-size: 13px; display: block; margin-bottom: 4px; font-weight: 600;">Tổng số sản phẩm</span>
                        <strong style="font-size: 16px; color: #111;"><%= request.getAttribute("totalProductsInCategory") %></strong>
                    </div>
                </div>
            </section>

            <!-- Products List Panel -->
            <section class="admin-category-card">
                <div class="admin-category-toolbar" style="justify-content: space-between; flex-wrap: wrap; gap: 15px;">
                    <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: #111;">Danh sách sản phẩm (<%= products.size() %>)</h3>

                    <form action="<%= ctx %>/admin/category/detail" method="get" style="display: flex; gap: 15px; align-items: center;">
                        <input type="hidden" name="id" value="<%= category.getCategoryId() %>">
                        <div class="category-sort">
                            <label style="font-size: 14px; font-weight: 600; color: #333;">Lọc sản phẩm:</label>
                            <select name="productStatus" onchange="this.form.submit()" style="height: 38px; border: 1px solid #dfe5ee; border-radius: 6px; padding: 0 10px; outline: none; background: #fff;">
                                <option value="ALL" <%= "ALL".equals(productStatus) ? "selected" : "" %>>Tất cả sản phẩm</option>
                                <option value="ACTIVE" <%= "ACTIVE".equals(productStatus) ? "selected" : "" %>>Đang hoạt động</option>
                                <option value="INACTIVE" <%= "INACTIVE".equals(productStatus) ? "selected" : "" %>>Đã vô hiệu hóa</option>
                            </select>
                        </div>
                    </form>
                </div>

                <div class="table-wrapper">
                    <table class="admin-category-table">
                        <thead>
                            <tr>
                                <th style="padding: 18px 24px;">Mã SP</th>
                                <th style="padding: 18px 24px;">Ảnh</th>
                                <th style="padding: 18px 24px;">Tên sản phẩm</th>
                                <th style="padding: 18px 24px;">Giá bán</th>
                                <th style="padding: 18px 24px;">Số lượng tồn</th>
                                <th style="padding: 18px 24px;">Trạng thái</th>
                                <th style="padding: 18px 24px; text-align: center;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (products.isEmpty()) { %>
                            <tr>
                                <td colspan="7" style="text-align:center; padding: 40px; color: #777;">
                                    Không có sản phẩm nào thuộc danh mục này với trạng thái được chọn.
                                </td>
                            </tr>
                            <% } else { %>
                            <% for (Product p : products) { %>
                            <tr>
                                <td style="padding: 18px 24px;"><%= p.getProductId() %></td>
                                <td style="padding: 18px 24px;">
                                    <% if (p.getImageUrl() != null && !p.getImageUrl().trim().isEmpty()) { %>
                                    <img src="<%= ctx %>/<%= p.getImageUrl() %>" alt="<%= h(p.getProductName()) %>" style="width: 50px; height: 50px; object-fit: cover; border-radius: 6px; border: 1px solid #e5e7eb;">
                                    <% } else { %>
                                    <div style="width: 50px; height: 50px; background: #f3f4f6; display: grid; place-items: center; border-radius: 6px; color: #9ca3af; font-size: 11px; font-weight: 600; border: 1px solid #e5e7eb;">No Image</div>
                                    <% } %>
                                </td>
                                <td style="padding: 18px 24px; font-weight: 600; color: #111;"><%= h(p.getProductName()) %></td>
                                <td style="padding: 18px 24px; color: #ed1c24; font-weight: 700;"><%= String.format("%,d", p.getPrice().longValue()) %>đ</td>
                                <td style="padding: 18px 24px;"><%= p.getQuantity() %></td>
                                <td style="padding: 18px 24px;">
                                    <span class="status-badge <%= "ACTIVE".equalsIgnoreCase(p.getStatus()) ? "status-active" : "status-inactive" %>" style="display: inline-block; padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: 600;">
                                        <%= "ACTIVE".equalsIgnoreCase(p.getStatus()) ? "Hoạt động" : "Vô hiệu hóa" %>
                                    </span>
                                </td>
                                <td style="padding: 18px 24px; text-align: center;">
                                    <div class="category-actions" style="justify-content: center;">
                                        <a href="<%= ctx %>/product-detail?id=<%= p.getProductId() %>" class="btn-view" target="_blank" style="min-width: 60px; height: 32px; font-size: 12px;">
                                            <i class="fa-solid fa-eye"></i> Xem
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                            <% } %>
                        </tbody>
                    </table>
                <div class="admin-category-footer">
                    <p>
                        Hiển thị <%= startItem %> đến <%= endItem %> của <%= totalFilteredProducts %> sản phẩm
                    </p>

                    <div class="admin-pagination">

                        <% if (currentProductPage > 1) { %>
                        <a class="page-btn"
                           href="<%= ctx %>/admin/category/detail?id=<%= category.getCategoryId() %>&productStatus=<%= productStatus %>&productPage=<%= currentProductPage - 1 %>">
                            &lsaquo;
                        </a>
                        <% } else { %>
                        <span class="page-btn disabled">&lsaquo;</span>
                        <% } %>

                        <%
                            for (int i = 1; i <= totalProductPages; i++) {
                        %>
                        <a class="page-btn <%= currentProductPage == i ? "active" : "" %>"
                           href="<%= ctx %>/admin/category/detail?id=<%= category.getCategoryId() %>&productStatus=<%= productStatus %>&productPage=<%= i %>">
                            <%= i %>
                        </a>
                        <% } %>

                        <% if (currentProductPage < totalProductPages) { %>
                        <a class="page-btn"
                           href="<%= ctx %>/admin/category/detail?id=<%= category.getCategoryId() %>&productStatus=<%= productStatus %>&productPage=<%= currentProductPage + 1 %>">
                            &rsaquo;
                        </a>
                        <% } else { %>
                        <span class="page-btn disabled">&rsaquo;</span>
                        <% } %>

                    </div>
                </div>
            </section>
            <% } else { %>
            <div class="admin-category-card" style="padding: 40px; text-align: center;">
                <h3 style="color: #c5221f; margin-bottom: 15px;">Không tìm thấy danh mục yêu cầu</h3>
                <a href="<%= ctx %>/admin/categories" class="btn-add-category" style="display: inline-flex; float: none; align-items: center; justify-content: center; height: 40px; padding: 0 20px;">
                    <i class="fa-solid fa-arrow-left" style="margin-right: 6px;"></i> Quay lại danh sách
                </a>
            </div>
            <% } %>
        </main>

        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
