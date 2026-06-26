<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="model.Product" %>
<%@ page import="model.Category" %>
<%@ page import="model.Brand" %>
<%@ page import="model.CategorySpecTemplate" %>

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
    List<Product> products = (List<Product>) request.getAttribute("products");
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    List<Brand> brands = (List<Brand>) request.getAttribute("brands");

    String keyword = (String) request.getAttribute("keyword");
    Integer selectedCategoryId = (Integer) request.getAttribute("categoryId");
    Integer selectedBrandId = (Integer) request.getAttribute("brandId");
    String status = (String) request.getAttribute("status");
    String sort = (String) request.getAttribute("sort");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalProducts = (Integer) request.getAttribute("totalProducts");
    Integer startItem = (Integer) request.getAttribute("startItem");
    Integer endItem = (Integer) request.getAttribute("endItem");

    String success = (String) request.getAttribute("success");
    String error = (String) request.getAttribute("error");

    // Preserve backend entered data on validation errors
    String enteredProductName = (String) request.getAttribute("enteredProductName");
    Integer enteredCategoryId = (Integer) request.getAttribute("enteredCategoryId");
    Integer enteredBrandId = (Integer) request.getAttribute("enteredBrandId");
    String enteredPrice = (String) request.getAttribute("enteredPrice");
    String enteredDescription = (String) request.getAttribute("enteredDescription");
    String failedAction = (String) request.getAttribute("failedAction");
    Integer enteredProductId = (Integer) request.getAttribute("enteredProductId");
    String enteredCurrentImg = (String) request.getAttribute("enteredCurrentImg");

    // Spec templates and entered spec values for server-side re-rendering
    List<CategorySpecTemplate> specTemplates = (List<CategorySpecTemplate>) request.getAttribute("specTemplates");
    String[] enteredSpecNames = (String[]) request.getAttribute("enteredSpecNames");
    String[] enteredSpecValues = (String[]) request.getAttribute("enteredSpecValues");
    if (specTemplates == null) specTemplates = Collections.emptyList();

    if (products == null) {
        products = Collections.emptyList();
    }
    if (categories == null) {
        categories = Collections.emptyList();
    }
    if (brands == null) {
        brands = Collections.emptyList();
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
    if (totalProducts == null) {
        totalProducts = 0;
    }
    if (startItem == null) {
        startItem = 0;
    }
    if (endItem == null) {
        endItem = 0;
    }

    if (enteredProductName == null) enteredProductName = "";
    if (enteredPrice == null) enteredPrice = "";
    if (enteredDescription == null) enteredDescription = "";

    String contextPath = request.getContextPath();
    String listQuery = "&keyword=" + enc(keyword) 
                     + "&categoryId=" + (selectedCategoryId != null ? selectedCategoryId : "")
                     + "&brandId=" + (selectedBrandId != null ? selectedBrandId : "")
                     + "&status=" + enc(status) 
                     + "&sort=" + enc(sort);
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý sản phẩm - ProBuild PC</title>
        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/style.css">
        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/admin-products.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
    </head>
    <body class="admin-product-body" data-ctx="<%= contextPath %>">

        <jsp:include page="/includes/header.jsp" />

        <main class="admin-product-container">
            <div class="admin-page-title">
                <h2>Quản lý sản phẩm</h2>
                <div class="admin-breadcrumb">
                    <a href="<%= contextPath %>/Dashboard">Dashboard</a>
                    
                    <span>›</span>
                    <span>Sản phẩm</span>
                    <span>›</span>
                    <span>Quản lý sản phẩm</span>
                </div>
            </div>

            <% if (success != null && !success.isEmpty()) { %>
            <div class="product-alert success"><%= h(success) %></div>
            <% } %>

            <% if (error != null && !error.isEmpty() && failedAction == null) { %>
            <div class="product-alert error"><%= h(error) %></div>
            <% } %>

            <section class="admin-product-card">
                <!-- Search & Filters Toolbar -->
                <form action="<%= contextPath %>/admin/products" method="get" class="admin-product-toolbar" id="adminProductSearchForm">
                    
                    <div class="product-toolbar-left">
                        <div class="filter-group keyword-search">
                            <input type="text"
                                   id="productSearchInput"
                                   name="keyword"
                                   value="<%= h(keyword) %>"
                                   placeholder="Tìm tên, thương hiệu, danh mục...">
                        </div>

                        <div class="filter-group">
                            <label for="categoryFilter">Danh mục:</label>
                            <select name="categoryId" id="categoryFilter">
                                <option value="">Tất cả</option>
                                <% for (Category c : categories) { %>
                                <option value="<%= c.getCategoryId() %>" <%= (selectedCategoryId != null && selectedCategoryId == c.getCategoryId()) ? "selected" : "" %>><%= h(c.getCategoryName()) %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label for="brandFilter">Thương hiệu:</label>
                            <select name="brandId" id="brandFilter">
                                <option value="">Tất cả</option>
                                <% for (Brand b : brands) { %>
                                <option value="<%= b.getBrandId() %>" <%= (selectedBrandId != null && selectedBrandId == b.getBrandId()) ? "selected" : "" %>><%= h(b.getBrandName()) %></option>
                                <% } %>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label for="statusFilter">Trạng thái:</label>
                            <select name="status" id="statusFilter">
                                <option value="ALL" <%= "ALL".equals(status) ? "selected" : "" %>>Tất cả</option>
                                <option value="ACTIVE" <%= "ACTIVE".equals(status) ? "selected" : "" %>>Đang hoạt động</option>
                                <option value="INACTIVE" <%= "INACTIVE".equals(status) ? "selected" : "" %>>Đã vô hiệu hóa</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label for="sortFilter">Sắp xếp:</label>
                            <select name="sort" id="sortFilter">
                                <option value="newest" <%= "newest".equals(sort) ? "selected" : "" %>>Mới nhất</option>
                                <option value="oldest" <%= "oldest".equals(sort) ? "selected" : "" %>>Cũ nhất</option>
                                <option value="price_asc" <%= "price_asc".equals(sort) ? "selected" : "" %>>Giá tăng dần</option>
                                <option value="price_desc" <%= "price_desc".equals(sort) ? "selected" : "" %>>Giá giảm dần</option>
                                <option value="qty_asc" <%= "qty_asc".equals(sort) ? "selected" : "" %>>Số lượng tăng dần</option>
                                <option value="qty_desc" <%= "qty_desc".equals(sort) ? "selected" : "" %>>Số lượng giảm dần</option>
                            </select>
                        </div>

                    </div>

                    <div class="product-toolbar-right">
                        <button type="submit" class="btn-search-product">Tìm kiếm</button>
                        <a href="#add-product-modal" class="btn-add-product" onclick="openAddModal()">
                            <i class="fa-solid fa-plus"></i> Thêm sản phẩm
                        </a>
                    </div>
                </form>

                <!-- Products Table -->
                <div class="table-wrapper">
                    <table class="admin-product-table">
                        <thead>
                            <tr>
                                <th>Ảnh</th>
                                <th>Tên sản phẩm</th>
                                <th>Danh mục</th>
                                <th>Thương hiệu</th>
                                <th>Giá bán</th>
                                <th>Kho hàng</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (products.isEmpty()) { %>
                            <tr>
                                <td colspan="8" style="text-align:center; padding: 40px; color: #9ca3af;">
                                    Không tìm thấy sản phẩm nào khớp với bộ lọc
                                </td>
                            </tr>
                            <% } else { %>
                                <% for (Product p : products) { 
                                    String imgUrl = p.getImageUrl();
                                    if (imgUrl == null || imgUrl.trim().isEmpty()) {
                                        imgUrl = "images/no-image.png";
                                    }
                                %>
                                <tr>
                                    <td>
                                        <img src="<%= contextPath %>/<%= imgUrl %>" alt="<%= h(p.getProductName()) %>" class="table-product-img">
                                    </td>
                                    <td class="product-name-cell">
                                        <strong><%= h(p.getProductName()) %></strong>
                                    </td>
                                    <td><%= h(p.getCategoryName()) %></td>
                                    <td><%= h(p.getBrandName()) %></td>
                                    <td class="price-cell">
                                        <%= String.format("%,d", p.getPrice().longValue()) %>đ
                                    </td>
                                    <td>
                                        <% if (p.getQuantity() > 0) { %>
                                        <span class="stock-badge in-stock"><%= p.getQuantity() %> sản phẩm</span>
                                        <% } else { %>
                                        <span class="stock-badge out-stock">Hết hàng</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= "ACTIVE".equalsIgnoreCase(p.getStatus()) ? "active" : "inactive" %>">
                                            <%= "ACTIVE".equalsIgnoreCase(p.getStatus()) ? "Đang hoạt động" : "Vô hiệu hóa" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="product-actions">
                                            <!-- Edit Details -->
                                            <a href="#edit-product-modal" class="action-btn btn-edit" title="Sửa thông tin sản phẩm"
                                               onclick="openEditModal(<%= p.getProductId() %>, '<%= h(p.getProductName()) %>', <%= p.getCategoryId() %>, <%= p.getBrandId() %>, <%= p.getPrice() %>, <%= p.getWarrantyMonths() %>, '<%= h(p.getDescription()) %>', '<%= p.getImageUrl() %>')">
                                                <i class="fa-solid fa-pen"></i> Sửa
                                            </a>

                                            <!-- Toggle Status -->
                                            <form action="<%= contextPath %>/admin/products" method="post" style="display:inline;">
                                                <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                                                <input type="hidden" name="action" value="<%= "ACTIVE".equalsIgnoreCase(p.getStatus()) ? "delete" : "activate" %>">
                                                
                                                <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                                                <input type="hidden" name="categoryId" value="<%= selectedCategoryId != null ? selectedCategoryId : "" %>">
                                                <input type="hidden" name="brandId" value="<%= selectedBrandId != null ? selectedBrandId : "" %>">
                                                <input type="hidden" name="status" value="<%= h(status) %>">
                                                <input type="hidden" name="sort" value="<%= h(sort) %>">
                                                <input type="hidden" name="page" value="<%= currentPage %>">
                                                
                                                <button type="submit"
                                                        class="action-btn <%= "ACTIVE".equalsIgnoreCase(p.getStatus()) ? "btn-status-deactivate" : "btn-status-activate" %>"
                                                        onclick="return confirm('Bạn có chắc chắn muốn thay đổi trạng thái hoạt động của sản phẩm này?')">
                                                    <i class="fa-solid fa-power-off"></i>
                                                    <%= "ACTIVE".equalsIgnoreCase(p.getStatus()) ? "Vô hiệu hóa" : "Kích hoạt" %>
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

                <!-- Pagination Footer -->
                <div class="admin-product-footer">
                    <p>
                        Hiển thị <strong><%= startItem %></strong> đến <strong><%= endItem %></strong> của <strong><%= totalProducts %></strong> sản phẩm
                    </p>
                    <div class="admin-pagination">
                        <% if (currentPage > 1) { %>
                        <a class="page-btn" href="<%= contextPath %>/admin/products?page=<%= currentPage - 1 %><%= listQuery %>">&lsaquo;</a>
                        <% } else { %>
                        <span class="page-btn disabled">&lsaquo;</span>
                        <% } %>

                        <% for (int i = 1; i <= totalPages; i++) { %>
                        <a class="page-btn <%= currentPage == i ? "active" : "" %>" href="<%= contextPath %>/admin/products?page=<%= i %><%= listQuery %>"><%= i %></a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                        <a class="page-btn" href="<%= contextPath %>/admin/products?page=<%= currentPage + 1 %><%= listQuery %>">&rsaquo;</a>
                        <% } else { %>
                        <span class="page-btn disabled">&rsaquo;</span>
                        <% } %>
                    </div>
                </div>
            </section>
        </main>

        <!-- ADD PRODUCT MODAL -->
        <div class="product-modal-overlay" id="add-product-modal">
            <section class="product-modal" role="dialog" aria-modal="true" aria-labelledby="addProductTitle">
                <div class="product-modal-header">
                    <h2 id="addProductTitle"><i class="fa-solid fa-plus-circle"></i> Thêm sản phẩm mới</h2>
                    <a href="#" class="close-btn" aria-label="Đóng">&times;</a>
                </div>

                <form action="<%= contextPath %>/admin/products" method="post" enctype="multipart/form-data" class="product-modal-form" id="addProductForm" novalidate>
                    <input type="hidden" name="action" value="add">
                    
                    <% if ("add".equals(failedAction) && error != null && !error.isEmpty()) { %>
                    <div class="product-alert error" style="margin: 0 0 12px 0;"><%= h(error) %></div>
                    <% } %>

                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label for="addProductName">Tên sản phẩm <span>*</span></label>
                            <input id="addProductName" name="productName" type="text" placeholder="Ví dụ: Card màn hình ASUS RTX 4060..." value="<%= "add".equals(failedAction) ? h(enteredProductName) : "" %>" required>
                            <small class="form-error-text" id="addProductNameError"></small>
                        </div>

                        <div class="form-group">
                            <label for="addCategory">Danh mục sản phẩm <span>*</span></label>
                            <select id="addCategory" name="categoryId" required>
                                <option value="">-- Chọn danh mục --</option>
                                <% for (Category c : categories) { %>
                                <option value="<%= c.getCategoryId() %>" <%= ("add".equals(failedAction) && enteredCategoryId != null && enteredCategoryId == c.getCategoryId()) ? "selected" : "" %>><%= h(c.getCategoryName()) %></option>
                                <% } %>
                            </select>
                            <small class="form-error-text" id="addCategoryError"></small>
                        </div>

                        <div class="form-group">
                            <label for="addBrand">Thương hiệu <span>*</span></label>
                            <select id="addBrand" name="brandId" required>
                                <option value="">-- Chọn thương hiệu --</option>
                                <% for (Brand b : brands) { %>
                                <option value="<%= b.getBrandId() %>" <%= ("add".equals(failedAction) && enteredBrandId != null && enteredBrandId == b.getBrandId()) ? "selected" : "" %>><%= h(b.getBrandName()) %></option>
                                <% } %>
                            </select>
                            <small class="form-error-text" id="addBrandError"></small>
                        </div>

                        <div class="form-group">
                            <label for="addPrice">Giá bán (VND) <span>*</span></label>
                            <input id="addPrice" name="price" type="number" min="0" step="1000" placeholder="VD: 5500000" value="<%= "add".equals(failedAction) ? h(enteredPrice) : "" %>" required>
                            <small class="form-error-text" id="addPriceError"></small>
                        </div>

                        <div class="form-group">
                            <label for="addWarrantyMonths">Bảo hành (tháng) <span>*</span></label>
                            <input id="addWarrantyMonths" name="warrantyMonths" type="number" min="0" placeholder="VD: 12" value="<%= "add".equals(failedAction) && request.getAttribute("enteredWarrantyMonths") != null ? h((String)request.getAttribute("enteredWarrantyMonths")) : "" %>" required>
                            <small class="form-error-text" id="addWarrantyMonthsError"></small>
                        </div>

                        <div class="form-group">
                            <label for="addImageFile">Hình ảnh sản phẩm</label>
                            <input id="addImageFile" name="imgFile" type="file" accept=".jpg,.jpeg,.png,.webp">
                            <small class="image-hint">Tối đa 2MB | Hỗ trợ .png, .jpg, .jpeg, .webp</small>
                            <small class="form-error-text" id="addImageFileError"></small>

                        </div>

                        <!-- Button to load technical specifications -->
                        <div class="form-group full-width">
                            <button type="button" id="addSpecBtn" class="btn-load-specs" style="display: <%= ("add".equals(failedAction) && enteredCategoryId != null) ? "inline-flex" : "none" %>;">
                                <i class="fa-solid fa-gear"></i> Lựa chọn thông số kĩ thuật
                            </button>
                        </div>

                        <!-- Dynamic Category Specific specifications container -->
                        <div class="form-group full-width" id="dynamicSpecsContainer" style="display: <%= ("add".equals(failedAction) && !specTemplates.isEmpty()) ? "block" : "none" %>; border: 1px solid #e5e7eb; padding: 16px; border-radius: 6px; background-color: #fafbfe;">
                            <h3 style="font-size: 14px; font-weight: 700; margin: 0 0 12px 0; color: #111827;">Thông số kỹ thuật theo danh mục</h3>
                            <div id="dynamicSpecsFields" class="form-grid" style="grid-template-columns: repeat(2, 1fr); gap: 15px; display: grid;">
                                <% if ("add".equals(failedAction) && !specTemplates.isEmpty()) {
                                    for (CategorySpecTemplate t : specTemplates) {
                                        // Find the corresponding entered value
                                        String enteredVal = "";
                                        if (enteredSpecNames != null && enteredSpecValues != null) {
                                            for (int si = 0; si < enteredSpecNames.length && si < enteredSpecValues.length; si++) {
                                                if (t.getSpecName().equalsIgnoreCase(enteredSpecNames[si])) {
                                                    enteredVal = enteredSpecValues[si] != null ? enteredSpecValues[si] : "";
                                                    break;
                                                }
                                            }
                                        }
                                %>
                                <div class="form-group">
                                    <label><%= h(t.getSpecName()) %> <% if (t.isRequired()) { %><span>*</span><% } %></label>
                                    <input type="hidden" name="spec_names[]" value="<%= h(t.getSpecName()) %>">
                                    <% if ("SELECT".equalsIgnoreCase(t.getSpecType()) && t.getAllowedValues() != null) {
                                        String[] specOptions = t.getAllowedValues().split(",");
                                    %>
                                    <select name="spec_values[]" <%= t.isRequired() ? "required" : "" %>>
                                        <option value="">-- Chọn <%= h(t.getSpecName()) %> --</option>
                                        <% for (String optItem : specOptions) {
                                            String optTrimmed = optItem.trim();
                                        %>
                                        <option value="<%= h(optTrimmed) %>" <%= optTrimmed.equals(enteredVal) ? "selected" : "" %>><%= h(optTrimmed) %></option>
                                        <% } %>
                                    </select>
                                    <% } else if ("NUMBER".equalsIgnoreCase(t.getSpecType())) { %>
                                    <input type="number" name="spec_values[]" placeholder="Nhập số lượng/thông số..." value="<%= h(enteredVal) %>" min="0" <%= t.isRequired() ? "required" : "" %>>
                                    <% } else { %>
                                    <input type="text" name="spec_values[]" placeholder="Nhập thông tin..." value="<%= h(enteredVal) %>" <%= t.isRequired() ? "required" : "" %>>
                                    <% } %>
                                </div>
                                <% } } %>
                            </div>
                        </div>

                        <div class="form-group full-width">
                            <label for="addDescription">Mô tả chi tiết</label>
                            <textarea id="addDescription" name="description" rows="4" placeholder="Nhập mô tả sản phẩm, thông số kỹ thuật..."><%= "add".equals(failedAction) ? h(enteredDescription) : "" %></textarea>
                        </div>
                    </div>

                    <div class="product-modal-actions">
                        <a class="btn-secondary" href="#">Hủy</a>
                        <button class="btn-primary" type="submit"><i class="fa-solid fa-save"></i> Lưu sản phẩm</button>
                    </div>
                </form>
            </section>
        </div>

        <!-- EDIT PRODUCT DETAILS MODAL -->
        <div class="product-modal-overlay" id="edit-product-modal">
            <section class="product-modal" role="dialog" aria-modal="true" aria-labelledby="editProductTitle">
                <div class="product-modal-header">
                    <h2 id="editProductTitle"><i class="fa-solid fa-pen-to-square"></i> Cập nhật thông tin sản phẩm</h2>
                    <a href="#" class="close-btn" aria-label="Đóng">&times;</a>
                </div>

                <form action="<%= contextPath %>/admin/products" method="post" enctype="multipart/form-data" class="product-modal-form" id="editProductForm" novalidate>
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="productId" id="editProductId" value="<%= "update".equals(failedAction) && enteredProductId != null ? enteredProductId : "" %>">
                    <input type="hidden" name="currentImg" id="editCurrentImg" value="<%= "update".equals(failedAction) && enteredCurrentImg != null ? h(enteredCurrentImg) : "" %>">
                    
                    <% if ("update".equals(failedAction) && error != null && !error.isEmpty()) { %>
                    <div class="product-alert error" style="margin: 0 0 12px 0;"><%= h(error) %></div>
                    <% } %>

                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label for="editProductName">Tên sản phẩm <span>*</span></label>
                            <input id="editProductName" name="productName" type="text" value="<%= "update".equals(failedAction) ? h(enteredProductName) : "" %>" required>
                            <small class="form-error-text" id="editProductNameError"></small>
                        </div>

                        <div class="form-group">
                            <label for="editCategory">Danh mục sản phẩm <span>*</span></label>
                            <select id="editCategory" name="categoryId" required>
                                <% for (Category c : categories) { %>
                                <option value="<%= c.getCategoryId() %>" <%= ("update".equals(failedAction) && enteredCategoryId != null && enteredCategoryId == c.getCategoryId()) ? "selected" : "" %>><%= h(c.getCategoryName()) %></option>
                                <% } %>
                            </select>
                            <small class="form-error-text" id="editCategoryError"></small>
                        </div>

                        <div class="form-group">
                            <label for="editBrand">Thương hiệu <span>*</span></label>
                            <select id="editBrand" name="brandId" required>
                                <% for (Brand b : brands) { %>
                                <option value="<%= b.getBrandId() %>" <%= ("update".equals(failedAction) && enteredBrandId != null && enteredBrandId == b.getBrandId()) ? "selected" : "" %>><%= h(b.getBrandName()) %></option>
                                <% } %>
                            </select>
                            <small class="form-error-text" id="editBrandError"></small>
                        </div>

                        <div class="form-group">
                            <label for="editPrice">Giá bán (VND) <span>*</span></label>
                            <input id="editPrice" name="price" type="number" min="0" step="1000" value="<%= "update".equals(failedAction) ? h(enteredPrice) : "" %>" required>
                            <small class="form-error-text" id="editPriceError"></small>
                        </div>

                        <div class="form-group">
                            <label for="editWarrantyMonths">Bảo hành (tháng) <span>*</span></label>
                            <input id="editWarrantyMonths" name="warrantyMonths" type="number" min="0" value="<%= "update".equals(failedAction) && request.getAttribute("enteredWarrantyMonths") != null ? h((String)request.getAttribute("enteredWarrantyMonths")) : "" %>" required>
                            <small class="form-error-text" id="editWarrantyMonthsError"></small>
                        </div>

                        <div class="form-group">
                            <label for="editImageFile">Thay đổi hình ảnh</label>
                            <input id="editImageFile" name="imgFile" type="file" accept=".jpg,.jpeg,.png,.webp">
                            <small class="image-hint">Tối đa 2MB | Bỏ trống nếu giữ ảnh cũ</small>
                            <small class="form-error-text" id="editImageFileError"></small>

                            <div class="current-image-preview" id="editImgPreviewContainer" style="margin-top:8px; display:none;">
                                <small>Ảnh hiện tại:</small><br>
                                <img id="editImgPreview" src="" alt="Thumbnail" style="height: 50px; border-radius: 4px; border: 1px solid #4b5563; margin-top:4px;">
                            </div>
                        </div>

                        <div class="form-group full-width">
                            <label for="editDescription">Mô tả chi tiết</label>
                            <textarea id="editDescription" name="description" rows="4"><%= "update".equals(failedAction) ? h(enteredDescription) : "" %></textarea>
                        </div>

                        <!-- Button to load technical specifications for edit -->
                        <div class="form-group full-width">
                            <button type="button" id="editSpecBtn" class="btn-load-specs" style="display: inline-flex;">
                                <i class="fa-solid fa-gear"></i> Lựa chọn thông số kĩ thuật
                            </button>
                        </div>

                        <!-- Dynamic specifications container for edit -->
                        <div class="form-group full-width" id="editDynamicSpecsContainer" style="display: <%= ("update".equals(failedAction) && !specTemplates.isEmpty()) ? "block" : "none" %>; border: 1px solid #e5e7eb; padding: 16px; border-radius: 6px; background-color: #fafbfe;">
                            <h3 style="font-size: 14px; font-weight: 700; margin: 0 0 12px 0; color: #111827;">Thông số kỹ thuật theo danh mục</h3>
                            <div id="editDynamicSpecsFields" class="form-grid" style="grid-template-columns: repeat(2, 1fr); gap: 15px; display: grid;">
                                <% if ("update".equals(failedAction) && !specTemplates.isEmpty()) {
                                    for (CategorySpecTemplate t : specTemplates) {
                                        String enteredVal = "";
                                        if (enteredSpecNames != null && enteredSpecValues != null) {
                                            for (int si = 0; si < enteredSpecNames.length && si < enteredSpecValues.length; si++) {
                                                if (t.getSpecName().equalsIgnoreCase(enteredSpecNames[si])) {
                                                    enteredVal = enteredSpecValues[si] != null ? enteredSpecValues[si] : "";
                                                    break;
                                                }
                                            }
                                        }
                                %>
                                <div class="form-group">
                                    <label><%= h(t.getSpecName()) %> <% if (t.isRequired()) { %><span>*</span><% } %></label>
                                    <input type="hidden" name="spec_names[]" value="<%= h(t.getSpecName()) %>">
                                    <% if ("SELECT".equalsIgnoreCase(t.getSpecType()) && t.getAllowedValues() != null) {
                                        String[] specOptions = t.getAllowedValues().split(",");
                                    %>
                                    <select name="spec_values[]" <%= t.isRequired() ? "required" : "" %>>
                                        <option value="">-- Chọn <%= h(t.getSpecName()) %> --</option>
                                        <% for (String optItem : specOptions) {
                                            String optTrimmed = optItem.trim();
                                        %>
                                        <option value="<%= h(optTrimmed) %>" <%= optTrimmed.equals(enteredVal) ? "selected" : "" %>><%= h(optTrimmed) %></option>
                                        <% } %>
                                    </select>
                                    <% } else if ("NUMBER".equalsIgnoreCase(t.getSpecType())) { %>
                                    <input type="number" name="spec_values[]" placeholder="Nhập số lượng/thông số..." value="<%= h(enteredVal) %>" min="0" <%= t.isRequired() ? "required" : "" %>>
                                    <% } else { %>
                                    <input type="text" name="spec_values[]" placeholder="Nhập thông tin..." value="<%= h(enteredVal) %>" <%= t.isRequired() ? "required" : "" %>>
                                    <% } %>
                                </div>
                                <% } } %>
                            </div>
                        </div>
                    </div>

                    <div class="product-modal-actions">
                        <a class="btn-secondary" href="#">Hủy</a>
                        <button class="btn-primary" type="submit"><i class="fa-solid fa-save"></i> Cập nhật</button>
                    </div>
                </form>
            </section>
        </div>

        <!-- QUICK EDIT PRICE MODAL -->
        <div class="product-modal-overlay" id="price-product-modal">
            <section class="product-modal price-modal-size" role="dialog" aria-modal="true" aria-labelledby="priceTitle">
                <div class="product-modal-header">
                    <h2 id="priceTitle"><i class="fa-solid fa-coins"></i> Cập nhật giá bán</h2>
                    <a href="#" class="close-btn" aria-label="Đóng">&times;</a>
                </div>

                <form action="<%= contextPath %>/admin/products" method="post" class="product-modal-form" id="priceProductForm" novalidate>
                    <input type="hidden" name="action" value="updatePrice">
                    <input type="hidden" name="productId" id="priceProductId">

                    <!-- Preserving filters to return back to exact state -->
                    <input type="hidden" name="keyword" value="<%= h(keyword) %>">
                    <input type="hidden" name="categoryId" value="<%= selectedCategoryId != null ? selectedCategoryId : "" %>">
                    <input type="hidden" name="brandId" value="<%= selectedBrandId != null ? selectedBrandId : "" %>">
                    <input type="hidden" name="status" value="<%= h(status) %>">
                    <input type="hidden" name="sort" value="<%= h(sort) %>">
                    <input type="hidden" name="page" value="<%= currentPage %>">

                    <div class="form-group">
                        <label>Sản phẩm:</label>
                        <strong id="priceProductName" style="display:block; margin: 6px 0 15px 0; color: #f3f4f6; font-size:1.1rem;"></strong>
                    </div>

                    <div class="form-group">
                        <label for="quickPriceVal">Giá bán mới (VND) <span>*</span></label>
                        <input id="quickPriceVal" name="price" type="number" min="0" step="1000" placeholder="Nhập giá mới..." required>
                        <small class="form-error-text" id="quickPriceError"></small>
                    </div>

                    <div class="product-modal-actions">
                        <a class="btn-secondary" href="#">Hủy</a>
                        <button class="btn-primary" type="submit"><i class="fa-solid fa-check"></i> Cập nhật giá</button>
                    </div>
                </form>
            </section>
        </div>

        <jsp:include page="/includes/footer.jsp" />

        <script src="<%= contextPath %>/js/admin-products.js"></script>

        <% if (failedAction != null && !failedAction.isEmpty()) { %>
        <script>
            // Auto-open the correct modal when the servlet forwards back on validation failure
            (function() {
                var action = "<%= h(failedAction) %>";
                if (action === "add") {
                    window.location.hash = "add-product-modal";
                } else if (action === "update") {
                    window.location.hash = "edit-product-modal";
                }
            })();
        </script>
        <% } %>

    </body>
</html>
