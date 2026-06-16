<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Category" %>

<%
    Category category = (Category) request.getAttribute("category");
    String error = (String) request.getAttribute("error");
    String ctx = request.getContextPath();
%>

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

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Sửa danh mục - <%= category != null ? h(category.getCategoryName()) : "" %></title>
        <link rel="stylesheet" type="text/css" href="<%= ctx %>/css/style.css">
        <link rel="stylesheet" type="text/css" href="<%= ctx %>/css/admin-categories.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    </head>
    <body class="admin-category-body">
        <jsp:include page="/includes/header.jsp" />

        <main class="admin-category-container" style="max-width: 600px;">
            <div class="admin-page-title">
                <h2>Sửa danh mục</h2>
                <div class="admin-breadcrumb">
                    <a href="<%= ctx %>/Dashboard">Dashboard</a>
                    <span>&rsaquo;</span>
                    <a href="<%= ctx %>/admin/categories">Danh mục sản phẩm</a>
                    <span>&rsaquo;</span>
                    <strong>Sửa</strong>
                </div>
            </div>

            <section class="admin-category-card" style="padding: 30px;">
                <!-- Error messages wrapper (For FE and BE errors) -->
                <div id="error-message-box" class="alert error" style="<%= (error != null && !error.isEmpty()) ? "" : "display: none;" %> background: #fce8e6; color: #c5221f; padding: 12px 16px; border-radius: 6px; margin-bottom: 20px; font-size: 14px; font-weight: 600;">
                    <i class="fa-solid fa-circle-exclamation" style="margin-right: 6px;"></i>
                    <span id="error-message-text"><%= error != null ? h(error) : "" %></span>
                </div>

                <% if (category != null) { %>
                <form id="edit-category-form" action="<%= ctx %>/admin/category/edit" method="post" style="display: flex; flex-direction: column; gap: 20px;" novalidate>
                    <input type="hidden" name="categoryId" value="<%= category.getCategoryId() %>">

                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <label style="font-weight: 600; font-size: 14px; color: #333;">Mã danh mục</label>
                        <input type="text" value="<%= category.getCategoryId() %>" disabled style="background: #f3f4f6; border: 1px solid #dfe5ee; border-radius: 6px; height: 44px; padding: 0 14px; font-size: 14px; color: #777;">
                    </div>

                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <label for="categoryName" style="font-weight: 600; font-size: 14px; color: #333;">Tên danh mục <span style="color: #ed1c24;">*</span></label>
                        <input type="text" id="categoryName" name="categoryName" value="<%= h(category.getCategoryName()) %>" required placeholder="Nhập tên danh mục..." style="border: 1px solid #dfe5ee; border-radius: 6px; height: 44px; padding: 0 14px; font-size: 14px; outline: none; transition: border-color 0.2s;">
                        <small style="color: #777; font-size: 12px;">Tên danh mục phải chứa từ 2 đến 100 ký tự.</small>
                    </div>

                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <label for="status" style="font-weight: 600; font-size: 14px; color: #333;">Trạng thái <span style="color: #ed1c24;">*</span></label>
                        <select id="status" name="status" style="border: 1px solid #dfe5ee; border-radius: 6px; height: 44px; padding: 0 12px; font-size: 14px; outline: none; background: #fff;">
                            <option value="ACTIVE" <%= "ACTIVE".equalsIgnoreCase(category.getStatus()) ? "selected" : "" %>>Đang hoạt động</option>
                            <option value="INACTIVE" <%= "INACTIVE".equalsIgnoreCase(category.getStatus()) ? "selected" : "" %>>Đã vô hiệu hóa</option>
                        </select>
                    </div>

                    <div style="display: flex; gap: 15px; margin-top: 10px;">
                        <a href="<%= ctx %>/admin/categories" style="flex: 1; height: 44px; border: 1px solid #dfe5ee; border-radius: 6px; display: inline-flex; align-items: center; justify-content: center; text-decoration: none; color: #555; font-size: 14px; font-weight: 700; background: #fff; transition: background 0.2s;">Hủy</a>
                        <button type="submit" style="flex: 1; height: 44px; border: none; border-radius: 6px; background: #ed1c24; color: #fff; font-size: 14px; font-weight: 700; cursor: pointer; transition: background 0.2s;">Lưu thay đổi</button>
                    </div>
                </form>
                <% } else { %>
                <div style="text-align: center; padding: 20px;">
                    <p style="color: #555; margin-bottom: 15px;">Không tìm thấy danh mục yêu cầu</p>
                    <a href="<%= ctx %>/admin/categories" class="btn-add-category" style="display: inline-flex; float: none; align-items: center; justify-content: center; height: 40px; padding: 0 20px;">
                        <i class="fa-solid fa-arrow-left" style="margin-right: 6px;"></i> Quay lại danh sách
                    </a>
                </div>
                <% } %>
            </section>
        </main>

        <jsp:include page="/includes/footer.jsp" />

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const form = document.getElementById("edit-category-form");
                if (!form) return;

                const nameInput = document.getElementById("categoryName");
                const statusSelect = document.getElementById("status");
                const errorBox = document.getElementById("error-message-box");
                const errorText = document.getElementById("error-message-text");

                function showError(msg) {
                    errorText.textContent = msg;
                    errorBox.style.display = "block";
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                }

                function hideError() {
                    errorBox.style.display = "none";
                }

                form.addEventListener("submit", function (event) {
                    hideError();
                    const trimmedName = nameInput.value.trim();

                    // Frontend Validations
                    if (trimmedName.length === 0) {
                        event.preventDefault();
                        nameInput.style.borderColor = "#ed1c24";
                        nameInput.focus();
                        showError("Tên danh mục không được để trống hoặc chỉ chứa khoảng trắng.");
                        return;
                    }

                    if (trimmedName.length < 2 || trimmedName.length > 100) {
                        event.preventDefault();
                        nameInput.style.borderColor = "#ed1c24";
                        nameInput.focus();
                        showError("Tên danh mục phải có độ dài từ 2 đến 100 ký tự.");
                        return;
                    }

                    const selectedStatus = statusSelect.value;
                    if (selectedStatus !== "ACTIVE" && selectedStatus !== "INACTIVE") {
                        event.preventDefault();
                        showError("Trạng thái danh mục không hợp lệ.");
                        return;
                    }

                    // Normalize value before submission
                    nameInput.value = trimmedName;
                });

                nameInput.addEventListener("input", function () {
                    nameInput.style.borderColor = "#dfe5ee";
                });
            });
        </script>
    </body>
</html>
