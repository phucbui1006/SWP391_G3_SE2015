<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Batch" %>

<%
    ArrayList<Batch> batchList = (ArrayList<Batch>) request.getAttribute("batchList");

    int pageSize = 5;
    int currentPage = 1;

    String pageParam = request.getParameter("page");
    if (pageParam != null) {
        try {
            currentPage = Integer.parseInt(pageParam);
        } catch (Exception e) {
            currentPage = 1;
        }
    }

    int totalItems = batchList == null ? 0 : batchList.size();
    int totalPages = (int) Math.ceil((double) totalItems / pageSize);

    if (totalPages == 0) totalPages = 1;
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages) currentPage = totalPages;

    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalItems);
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Batch Management</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>
        html, body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background: #f5f6fa !important;
        }

        body {
            background-image: none !important;
        }

        .batch-wrapper {
            background: #f5f6fa;
            min-height: calc(100vh - 120px);
            padding: 35px 55px;
        }

        .batch-container {
            max-width: 1400px;
            margin: 0 auto;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 28px;
        }

        .title-box {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .title-icon {
            width: 58px;
            height: 58px;
            border-radius: 16px;
            background: #fff;
            border: 1px solid #e5e7eb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.04);
        }

        .title-box h1 {
            margin: 0;
            color: #111827;
            font-size: 28px;
        }

        .title-box p {
            margin: 6px 0 0;
            color: #6b7280;
            font-size: 15px;
        }

        .top-actions {
            display: flex;
            gap: 12px;
        }

        .btn-dashboard {
            background: #111827;
            color: white;
            border: none;
            height: 44px;
            padding: 0 22px;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-dashboard:hover {
            background: #374151;
        }

        .btn-add-top {
            background: #ed1c24;
            color: white;
            border: none;
            height: 44px;
            padding: 0 24px;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-add-top:hover {
            background: #c9151c;
        }

        .form-card {
            display: none;
            background: white;
            border-radius: 12px;
            padding: 24px;
            border: 1px solid #e5e7eb;
            box-shadow: 0 4px 14px rgba(0,0,0,0.07);
            margin-bottom: 24px;
        }

        .form-card.show {
            display: block;
        }

        .form-title {
            margin: 0 0 18px;
            font-size: 20px;
            color: #111827;
        }

        .batch-form {
            display: flex;
            align-items: flex-end;
            gap: 16px;
        }

        .form-group {
            flex: 1;
        }

        .form-group:first-of-type {
            flex: 2;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #111827;
            font-weight: bold;
            font-size: 14px;
        }

        .form-group input {
            width: 100%;
            height: 42px;
            box-sizing: border-box;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            padding: 0 12px;
            font-size: 14px;
        }

        .form-group input:focus {
            outline: none;
            border-color: #ed1c24;
            box-shadow: 0 0 0 3px rgba(237, 28, 36, 0.12);
        }

        .form-actions {
            display: flex;
            gap: 10px;
        }

        .btn-save {
            background: #ed1c24;
            color: white;
            border: none;
            height: 42px;
            padding: 0 24px;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            white-space: nowrap;
        }

        .btn-cancel {
            background: #6b7280;
            color: white;
            border: none;
            height: 42px;
            padding: 0 22px;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-save.update-mode {
            background: #2563eb;
        }

        .table-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid #e5e7eb;
            box-shadow: 0 4px 14px rgba(0,0,0,0.07);
            overflow-x: auto;
        }

        .batch-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
            min-width: 1150px;
        }

        .batch-table th {
            background: #fafafa;
            color: #111827;
            font-size: 14px;
            padding: 15px 12px;
            border-bottom: 1px solid #e5e7eb;
            text-align: center;
            white-space: nowrap;
        }

        .batch-table td {
            padding: 13px 12px;
            border-bottom: 1px solid #eeeeee;
            color: #374151;
            font-size: 14px;
            vertical-align: middle;
            text-align: center;
        }

        .batch-table tr:hover {
            background: #fafafa;
        }

        .col-id { width: 80px; }
        .col-name { width: 260px; text-align: left !important; }
        .col-small { width: 120px; }
        .col-medium { width: 150px; }
        .col-action { width: 170px; }

        .category-badge {
            padding: 6px 12px;
            border-radius: 7px;
            font-size: 13px;
            font-weight: bold;
            background: #e8f0ff;
            color: #2563eb;
            display: inline-block;
        }

        .stock-badge {
            padding: 7px 13px;
            border-radius: 18px;
            font-size: 13px;
            font-weight: bold;
            display: inline-block;
            white-space: nowrap;
        }

        .in-stock {
            background: #dcfce7;
            color: #16a34a;
        }

        .low-stock {
            background: #ffedd5;
            color: #ea580c;
        }

        .out-stock {
            background: #fee2e2;
            color: #dc2626;
        }

        .action-group {
            display: flex;
            justify-content: center;
            gap: 8px;
        }

        .btn-edit {
            background: #2563eb;
            color: white;
            border: none;
            border-radius: 6px;
            height: 34px;
            padding: 0 14px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-delete {
            background: #ed1c24;
            color: white;
            border: none;
            border-radius: 6px;
            height: 34px;
            padding: 0 14px;
            font-weight: bold;
            cursor: pointer;
        }

        .empty-row {
            text-align: center !important;
            padding: 30px;
            color: #6b7280;
        }

        .table-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 18px;
            color: #6b7280;
            font-size: 14px;
        }

        .pagination {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .page-btn {
            min-width: 34px;
            height: 34px;
            padding: 0 10px;
            border: 1px solid #d1d5db;
            background: white;
            color: #111827;
            border-radius: 6px;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }

        .page-btn.active {
            background: #ed1c24;
            color: white;
            border-color: #ed1c24;
        }

        .page-btn.disabled {
            color: #9ca3af;
            background: #f3f4f6;
            cursor: not-allowed;
        }

        @media (max-width: 900px) {
            .batch-wrapper {
                padding: 25px 18px;
            }

            .top-bar {
                flex-direction: column;
                align-items: flex-start;
                gap: 18px;
            }

            .batch-form {
                flex-direction: column;
                align-items: stretch;
            }

            .form-actions {
                width: 100%;
            }

            .form-actions button {
                flex: 1;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/header.jsp" />

<div class="batch-wrapper">
    <div class="batch-container">

        <div class="top-bar">
            <div class="title-box">
                <div class="title-icon">📦</div>
                <div>
                    <h1>Batch Management</h1>
                    <p>Quản lý lô hàng nhập vào hệ thống</p>
                </div>
            </div>

            <div class="top-actions">
                <button type="button"
                        class="btn-dashboard"
                        onclick="window.location.href='${pageContext.request.contextPath}/Dashboard'">
                    🏠 Dashboard
                </button>

                <button type="button" class="btn-add-top" onclick="openAddForm()">
                    + Thêm lô hàng mới
                </button>
            </div>
        </div>

        <div id="formCard" class="form-card">
            <h2 id="formTitle" class="form-title">Thêm lô hàng mới</h2>

            <form id="batchForm" class="batch-form" action="${pageContext.request.contextPath}/batch" method="post">
                <input type="hidden" id="action" name="action" value="add">
                <input type="hidden" id="batchId" name="batchId">

                <div class="form-group">
                    <label>Batch Name</label>
                    <input id="batchName" type="text" name="batchName" placeholder="Nhập tên lô hàng..." required>
                </div>

                <div class="form-group">
                    <label>Category ID</label>
                    <input id="categoryId" type="number" name="categoryId" placeholder="Category ID" min="1" required>
                </div>

                <div class="form-group">
                    <label>Brand ID</label>
                    <input id="brandId" type="number" name="brandId" placeholder="Brand ID" min="1" required>
                </div>

                <div class="form-actions">
                    <button id="submitBtn" type="submit" class="btn-save">
                        Add Batch
                    </button>

                    <button type="button" class="btn-cancel" onclick="closeForm()">
                        Cancel
                    </button>
                </div>
            </form>
        </div>

        <div class="table-card">
            <table class="batch-table">
                <thead>
                    <tr>
                        <th class="col-id">Batch ID</th>
                        <th class="col-name">Tên lô hàng</th>
                        <th class="col-small">Danh mục ID</th>
                        <th class="col-medium">Danh mục</th>
                        <th class="col-small">Thương hiệu ID</th>
                        <th class="col-medium">Thương hiệu</th>
                        <th class="col-small">Số lượng</th>
                        <th class="col-medium">Tình trạng</th>
                        <th class="col-action">Thao tác</th>
                    </tr>
                </thead>

                <tbody>
                    <%
                        if (batchList != null && !batchList.isEmpty()) {
                            for (int i = startIndex; i < endIndex; i++) {
                                Batch b = batchList.get(i);

                                String stockStatus = b.getStockStatus();
                                if (stockStatus == null) stockStatus = "";

                                String statusClass = "in-stock";
                                if ("Low Stock".equalsIgnoreCase(stockStatus)
                                        || "Sắp hết hàng".equalsIgnoreCase(stockStatus)) {
                                    statusClass = "low-stock";
                                } else if ("Out of Stock".equalsIgnoreCase(stockStatus)
                                        || "Hết hàng".equalsIgnoreCase(stockStatus)) {
                                    statusClass = "out-stock";
                                }

                                String safeBatchName = b.getBatchName();
                                if (safeBatchName == null) safeBatchName = "";
                                safeBatchName = safeBatchName.replace("\\", "\\\\").replace("'", "\\'");
                    %>

                    <tr>
                        <td class="col-id"><%= b.getBatchId() %></td>
                        <td class="col-name"><%= b.getBatchName() %></td>
                        <td class="col-small"><%= b.getCategoryId() %></td>

                        <td class="col-medium">
                            <span class="category-badge"><%= b.getCategoryName() %></span>
                        </td>

                        <td class="col-small"><%= b.getBrandId() %></td>
                        <td class="col-medium"><%= b.getBrandName() %></td>
                        <td class="col-small"><%= b.getQuantity() %></td>

                        <td class="col-medium">
                            <span class="stock-badge <%= statusClass %>">
                                <%= stockStatus %>
                            </span>
                        </td>

                        <td class="col-action">
                            <div class="action-group">
                                <button type="button"
                                        class="btn-edit"
                                        onclick="openEditForm('<%= b.getBatchId() %>',
                                                              '<%= safeBatchName %>',
                                                              '<%= b.getCategoryId() %>',
                                                              '<%= b.getBrandId() %>')">
                                    Edit
                                </button>

                                <form action="${pageContext.request.contextPath}/batch"
                                      method="post"
                                      onsubmit="return confirm('Bạn có chắc muốn xóa lô hàng này?')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="batchId" value="<%= b.getBatchId() %>">

                                    <button type="submit" class="btn-delete">
                                        Delete
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>

                    <%
                            }
                        } else {
                    %>

                    <tr>
                        <td colspan="9" class="empty-row">Không có dữ liệu lô hàng.</td>
                    </tr>

                    <%
                        }
                    %>
                </tbody>
            </table>

            <div class="table-footer">
                <div>
                    Hiển thị
                    <b><%= totalItems == 0 ? 0 : startIndex + 1 %></b>
                    đến
                    <b><%= endIndex %></b>
                    của
                    <b><%= totalItems %></b>
                    kết quả
                </div>

                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a class="page-btn" href="${pageContext.request.contextPath}/batch?page=<%= currentPage - 1 %>">‹</a>
                    <% } else { %>
                        <span class="page-btn disabled">‹</span>
                    <% } %>

                    <% for (int p = 1; p <= totalPages; p++) { %>
                        <a class="page-btn <%= p == currentPage ? "active" : "" %>"
                           href="${pageContext.request.contextPath}/batch?page=<%= p %>">
                            <%= p %>
                        </a>
                    <% } %>

                    <% if (currentPage < totalPages) { %>
                        <a class="page-btn" href="${pageContext.request.contextPath}/batch?page=<%= currentPage + 1 %>">›</a>
                    <% } else { %>
                        <span class="page-btn disabled">›</span>
                    <% } %>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
    function openAddForm() {
        document.getElementById("batchForm").reset();
        document.getElementById("formCard").classList.add("show");
        document.getElementById("formTitle").innerText = "Thêm lô hàng mới";
        document.getElementById("action").value = "add";
        document.getElementById("batchId").value = "";

        var submitBtn = document.getElementById("submitBtn");
        submitBtn.innerText = "Add Batch";
        submitBtn.classList.remove("update-mode");

        document.getElementById("formCard").scrollIntoView({
            behavior: "smooth",
            block: "center"
        });

        setTimeout(function () {
            document.getElementById("batchName").focus();
        }, 300);
    }

    function openEditForm(batchId, batchName, categoryId, brandId) {
        document.getElementById("formCard").classList.add("show");
        document.getElementById("formTitle").innerText = "Cập nhật lô hàng";

        document.getElementById("action").value = "update";
        document.getElementById("batchId").value = batchId;
        document.getElementById("batchName").value = batchName;
        document.getElementById("categoryId").value = categoryId;
        document.getElementById("brandId").value = brandId;

        var submitBtn = document.getElementById("submitBtn");
        submitBtn.innerText = "Update Batch";
        submitBtn.classList.add("update-mode");

        document.getElementById("formCard").scrollIntoView({
            behavior: "smooth",
            block: "center"
        });

        setTimeout(function () {
            document.getElementById("batchName").focus();
        }, 300);
    }

    function closeForm() {
        document.getElementById("batchForm").reset();
        document.getElementById("formCard").classList.remove("show");
        document.getElementById("action").value = "add";
        document.getElementById("batchId").value = "";
    }
</script>

</body>
</html>