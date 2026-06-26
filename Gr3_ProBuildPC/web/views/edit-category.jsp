<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="model.Category" %>
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
%>

<% 
    Category editCategory = (Category) session.getAttribute("editCategory");
    List<CategorySpecTemplate> editTemplates = (List<CategorySpecTemplate>) session.getAttribute("editTemplates");
    Integer editingIndex = (Integer) session.getAttribute("editingIndex");
    String error = (String) request.getAttribute("error");
    String contextPath = request.getContextPath();

    if (editTemplates == null) {
        editTemplates = Collections.emptyList();
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chỉnh sửa danh mục - <%= editCategory != null ? h(editCategory.getCategoryName()) : "" %></title>
        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/style.css">
        <link rel="stylesheet" type="text/css" href="<%= contextPath %>/css/admin-categories.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
        <style>
            .spec-table-container {
                margin-top: 25px;
                background: #fff;
                border-radius: 6px;
                border: 1px solid #eceff4;
                overflow: hidden;
            }
            .spec-table-title {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 16px 20px;
                background: #fafbfe;
                border-bottom: 1px solid #eceff4;
            }
            .spec-table-title h3 {
                margin: 0;
                font-size: 16px;
                font-weight: 800;
                color: #252932;
            }
            .btn-action-row {
                padding: 6px 12px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: 700;
                cursor: pointer;
                border: none;
                transition: opacity 0.15s ease;
            }
            .btn-row-edit {
                background: #ff9f0a;
                color: #fff;
            }
            .btn-row-delete {
                background: #ed1c24;
                color: #fff;
            }
            .btn-row-save {
                background: #137333;
                color: #fff;
            }
            .input-spec-field {
                width: 100%;
                height: 34px;
                border: 1px solid #dfe5ee;
                border-radius: 4px;
                padding: 0 8px;
                font-size: 13.5px;
                box-sizing: border-box;
            }
            .select-spec-field {
                width: 100%;
                height: 34px;
                border: 1px solid #dfe5ee;
                border-radius: 4px;
                padding: 0 4px;
                font-size: 13.5px;
                background: #fff;
            }
            .checkbox-spec-field {
                width: 18px;
                height: 18px;
                cursor: pointer;
            }
            .form-section-card {
                padding: 24px;
                background: #fff;
                border: 1px solid #eceff4;
                border-radius: 6px;
                margin-bottom: 20px;
            }
            .form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            .btn-add-spec {
                background: #252932;
                color: #fff;
                border: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-weight: 700;
                font-size: 13px;
                cursor: pointer;
                display: inline-flex;
                align-items: center;
                gap: 6px;
            }
            .btn-add-spec:hover {
                background: #1d2027;
            }
            .category-submit-actions {
                display: flex;
                justify-content: flex-end;
                gap: 15px;
                margin-top: 30px;
            }
            .btn-submit-main {
                height: 42px;
                padding: 0 24px;
                background: #ed1c24;
                color: #fff;
                border: none;
                border-radius: 5px;
                font-weight: 700;
                font-size: 14px;
                cursor: pointer;
                transition: background 0.15s ease;
            }
            .btn-submit-main:hover {
                background: #d90008;
            }
            .btn-cancel-main {
                height: 42px;
                padding: 0 24px;
                background: #fff;
                color: #4d5562;
                border: 1px solid #e1e5ec;
                border-radius: 5px;
                font-weight: 700;
                font-size: 14px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                text-decoration: none;
                transition: background 0.15s;
            }
            .btn-cancel-main:hover {
                background: #f3f4f6;
            }
            .toggle-switch-btn {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                background: none;
                border: none;
                cursor: pointer;
                padding: 4px 8px;
                border-radius: 20px;
                transition: background 0.2s ease;
            }
            .toggle-switch-btn:hover {
                background: #f1f3f9;
            }
            .toggle-track {
                width: 38px;
                height: 20px;
                background-color: #cbd5e1;
                border-radius: 10px;
                position: relative;
                transition: background-color 0.2s ease;
                display: inline-block;
            }
            .toggle-thumb {
                width: 16px;
                height: 16px;
                background-color: #ffffff;
                border-radius: 50%;
                position: absolute;
                top: 2px;
                left: 2px;
                transition: transform 0.2s ease;
                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.15);
            }
            .toggle-switch-btn.active .toggle-track {
                background-color: #137333;
            }
            .toggle-switch-btn.active .toggle-thumb {
                transform: translateX(18px);
            }
            .toggle-label {
                font-size: 12.5px;
                font-weight: 700;
                color: #475569;
            }
            .toggle-switch-btn.active .toggle-label {
                color: #137333;
            }
            .disabled-row {
                background-color: #f8fafc !important;
                color: #94a3b8 !important;
            }
            .disabled-row strong, .disabled-row span, .disabled-row td, .disabled-row .toggle-label {
                color: #94a3b8 !important;
            }
            .disabled-row em {
                color: #cbd5e1 !important;
            }
        </style>
    </head>
    <body class="admin-category-body">

        <jsp:include page="/includes/header.jsp" />

        <main class="admin-category-container">

            <div class="admin-page-title">
                <h2>Chỉnh sửa danh mục</h2>
                <div class="admin-breadcrumb">
                    <a href="<%= contextPath %>/Dashboard">Dashboard</a>
                    <span>›</span>
                    <a href="<%= contextPath %>/admin/categories">Danh mục sản phẩm</a>
                    <span>›</span>
                    <span>Sửa danh mục</span>
                </div>
            </div>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="category-alert error">
                <i class="fa-solid fa-triangle-exclamation" style="margin-right: 6px;"></i><%= h(error) %>
            </div>
            <% } %>

            <% if (editCategory != null) { %>
            <form action="<%= contextPath %>/admin/category/edit" method="post" id="editCategoryForm" novalidate>
                
                <!-- Category Basic Info -->
                <div class="form-section-card">
                    <h3 style="margin: 0 0 20px; font-size: 18px; font-weight: 800; color: #222; border-bottom: 1px solid #edf0f5; padding-bottom: 10px;">
                        Thông tin danh mục
                    </h3>
                    <div class="form-grid">
                        <div class="cat-form-group">
                            <label>Mã danh mục</label>
                            <input type="text" value="<%= editCategory.getCategoryId() %>" disabled style="background: #f3f4f6; color: #8b8f99; cursor: not-allowed;">
                        </div>
                        <div class="cat-form-group">
                            <label for="categoryName">Tên danh mục <span>*</span></label>
                            <input id="categoryName" name="categoryName" type="text" value="<%= h(editCategory.getCategoryName()) %>" required minlength="2" maxlength="100">
                        </div>
                    </div>
                    <div class="cat-form-group" style="margin-top: 15px;">
                        <label for="categoryStatus">Trạng thái</label>
                        <select id="categoryStatus" name="status" style="width: 100%; height: 40px; border: 1px solid #e1e5ec; border-radius: 5px; padding: 0 12px; font-size: 14px;">
                            <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(editCategory.getStatus()) ? "selected" : "" %>>Đang hoạt động</option>
                            <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(editCategory.getStatus()) ? "selected" : "" %>>Đã vô hiệu hóa</option>
                        </select>
                    </div>
                </div>

                <!-- Category Specifications Template -->
                <div class="spec-table-container">
                    <div class="spec-table-title">
                        <h3>Mẫu thuộc tính thông số kỹ thuật</h3>
                        <button type="submit" name="action" value="addSpec" class="btn-add-spec">
                            <i class="fa-solid fa-plus"></i> Thêm thuộc tính
                        </button>
                    </div>

                    <div class="table-wrapper">
                        <table class="admin-category-table" style="min-width: 900px;">
                            <thead>
                                <tr>
                                    <th style="width: 25%;">Tên thuộc tính</th>
                                    <th style="width: 15%; text-align: center;">Kiểu dữ liệu</th>
                                    <th style="width: 30%;">Giá trị cho phép (nếu kiểu SELECT, phân cách bằng dấu phẩy)</th>
                                    <th style="width: 10%; text-align: center;">Bắt buộc</th>
                                    <th style="width: 10%; text-align: center;">Thứ tự hiển thị</th>
                                    <th style="width: 10%; text-align: center;">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (editTemplates.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 30px; color: #777;">
                                        Chưa có thuộc tính nào được thêm. Nhấp "Thêm thuộc tính" để bắt đầu.
                                    </td>
                                </tr>
                                <% } else { %>
                                    <% for (int i = 0; i < editTemplates.size(); i++) {
                                        CategorySpecTemplate t = editTemplates.get(i);
                                        boolean isRowEditing = (editingIndex != null && editingIndex == i);
                                    %>
                                    <tr class="<%= "INACTIVE".equalsIgnoreCase(t.getStatus()) ? "disabled-row" : "" %>">
                                        <!-- Spec Name -->
                                        <td>
                                            <% if (isRowEditing) { %>
                                                <input type="text" name="specName_<%= i %>" value="<%= h(t.getSpecName()) %>" class="input-spec-field" placeholder="VD: Dung lượng, Socket..." required>
                                            <% } else { %>
                                                <input type="hidden" name="specName_<%= i %>" value="<%= h(t.getSpecName()) %>">
                                                <strong style="color: #252932;"><%= h(t.getSpecName()) %></strong>
                                            <% } %>
                                        </td>

                                        <!-- Spec Type -->
                                        <td style="text-align: center;">
                                            <% if (isRowEditing) { %>
                                                <select name="specType_<%= i %>" class="select-spec-field" onchange="handleSpecTypeChange(this)">
                                                    <option value="TEXT" <%= "TEXT".equalsIgnoreCase(t.getSpecType()) ? "selected" : "" %>>TEXT</option>
                                                    <option value="SELECT" <%= "SELECT".equalsIgnoreCase(t.getSpecType()) ? "selected" : "" %>>SELECT</option>
                                                    <option value="NUMBER" <%= "NUMBER".equalsIgnoreCase(t.getSpecType()) ? "selected" : "" %>>NUMBER</option>
                                                </select>
                                            <% } else { %>
                                                <input type="hidden" name="specType_<%= i %>" value="<%= h(t.getSpecType()) %>">
                                                <span class="status-badge" style="background: #f1f3f9; color: #4a5568;"><%= h(t.getSpecType()) %></span>
                                            <% } %>
                                        </td>

                                        <!-- Allowed Values -->
                                        <td>
                                            <% if (isRowEditing) { 
                                                boolean isSelect = "SELECT".equalsIgnoreCase(t.getSpecType());
                                                String placeholder = isSelect ? "VD: 8GB,16GB,32GB" : "Không giới hạn (Bất kỳ)";
                                                String disabledAttr = isSelect ? "" : "disabled";
                                                String bgStyle = isSelect ? "" : "background-color: #f3f4f6; cursor: not-allowed;";
                                            %>
                                                <input type="text" name="allowedValues_<%= i %>" value="<%= isSelect ? h(t.getAllowedValues()) : "" %>" class="input-spec-field" placeholder="<%= placeholder %>" <%= disabledAttr %> style="<%= bgStyle %>">
                                            <% } else { %>
                                                <input type="hidden" name="allowedValues_<%= i %>" value="<%= h(t.getAllowedValues()) %>">
                                                <span style="color: #666; font-size: 13px;"><%= t.getAllowedValues() != null && !t.getAllowedValues().isEmpty() ? h(t.getAllowedValues()) : "<em>Không giới hạn (Bất kỳ)</em>" %></span>
                                            <% } %>
                                        </td>

                                        <!-- Is Required -->
                                        <td style="text-align: center;">
                                            <% if (isRowEditing) { %>
                                                <input type="checkbox" name="isRequired_<%= i %>" value="true" <%= t.isRequired() ? "checked" : "" %> class="checkbox-spec-field">
                                            <% } else { %>
                                                <input type="hidden" name="isRequired_<%= i %>" value="<%= t.isRequired() ? "true" : "false" %>">
                                                <button type="submit" name="action" value="toggleRequired_<%= i %>" class="toggle-switch-btn <%= t.isRequired() ? "active" : "" %>" title="Nhấp để đổi trạng thái Bắt buộc">
                                                    <span class="toggle-track">
                                                        <span class="toggle-thumb"></span>
                                                    </span>
                                                    <span class="toggle-label"><%= t.isRequired() ? "Bắt buộc" : "Không bắt buộc" %></span>
                                                </button>
                                            <% } %>
                                        </td>

                                        <!-- Display Order -->
                                        <td style="text-align: center;">
                                            <% if (isRowEditing) { %>
                                                <input type="number" name="displayOrder_<%= i %>" value="<%= t.getDisplayOrder() %>" class="input-spec-field" style="width: 80px; text-align: center;" min="0" required>
                                            <% } else { %>
                                                <input type="hidden" name="displayOrder_<%= i %>" value="<%= t.getDisplayOrder() %>">
                                                <span><%= t.getDisplayOrder() %></span>
                                            <% } %>
                                        </td>

                                        <!-- Actions -->
                                        <td style="text-align: center;">
                                            <div style="display: flex; gap: 8px; justify-content: center; align-items: center;">
                                                <% if (isRowEditing) { %>
                                                    <button type="submit" name="action" value="saveSpec_<%= i %>" class="btn-action-row btn-row-save" title="Lưu hàng này">
                                                        <i class="fa-solid fa-check"></i> Lưu
                                                    </button>
                                                <% } else { %>
                                                    <button type="submit" name="action" value="editSpec_<%= i %>" class="btn-action-row btn-row-edit" title="Sửa hàng này">
                                                        <i class="fa-solid fa-pen-to-square"></i> Sửa
                                                    </button>
                                                <% } %>
                                                <% if ("INACTIVE".equalsIgnoreCase(t.getStatus())) { %>
                                                    <button type="submit" name="action" value="activateSpec_<%= i %>" class="btn-action-row btn-row-save" title="Kích hoạt hàng này">
                                                        <i class="fa-solid fa-circle-check"></i> Kích hoạt
                                                    </button>
                                                <% } else { %>
                                                    <button type="submit" name="action" value="deleteSpec_<%= i %>" class="btn-action-row btn-row-delete" onclick="return confirm('Bạn có chắc muốn vô hiệu hóa thuộc tính này?')" title="Vô hiệu hóa hàng này">
                                                        <i class="fa-solid fa-ban"></i> Vô hiệu hóa
                                                    </button>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Submit / Cancel buttons -->
                <div class="category-submit-actions">
                    <a href="<%= contextPath %>/admin/categories" class="btn-cancel-main">Hủy bỏ</a>
                    <button type="submit" name="action" value="saveCategory" class="btn-submit-main">
                        <i class="fa-solid fa-floppy-disk" style="margin-right: 6px;"></i> Lưu danh mục
                    </button>
                </div>

            </form>
            <% } %>

        </main>

        <jsp:include page="/includes/footer.jsp" />

        <script>
            function handleSpecTypeChange(select) {
                const tr = select.closest('tr');
                if (tr) {
                    const input = tr.querySelector('input[name^="allowedValues_"]');
                    if (input) {
                        if (select.value === 'TEXT' || select.value === 'NUMBER') {
                            input.value = '';
                            input.disabled = true;
                            input.placeholder = 'Không giới hạn (Bất kỳ)';
                            input.style.backgroundColor = '#f3f4f6';
                            input.style.cursor = 'not-allowed';
                        } else {
                            input.disabled = false;
                            input.placeholder = 'VD: 8GB,16GB,32GB';
                            input.style.backgroundColor = '';
                            input.style.cursor = '';
                        }
                    }
                }
            }
        </script>
    </body>
</html>
