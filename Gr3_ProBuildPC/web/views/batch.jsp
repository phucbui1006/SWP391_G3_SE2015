<%-- 
    Document   : batch
    Created on : 15 thg 6, 2026, 15:31:10
    Author     : Cham Ngoc Ng
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>
<%@page import="model.Batch"%>
<%@page import="model.BatchItem"%>
<%@page import="model.Product"%>

<%
    List<Batch> batches = (List<Batch>) request.getAttribute("batches");
    List<Batch> allBatches = (List<Batch>) request.getAttribute("allBatches");
    List<BatchItem> batchItems = (List<BatchItem>) request.getAttribute("batchItems");
    List<Product> products = (List<Product>) request.getAttribute("products");

    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    Integer totalBatches = (Integer) request.getAttribute("totalBatches");
    Integer startItem = (Integer) request.getAttribute("startItem");
    Integer endItem = (Integer) request.getAttribute("endItem");

    Integer selectedBatchId = (Integer) request.getAttribute("selectedBatchId");

    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");

    if (currentPage == null) currentPage = 1;
    if (totalPages == null) totalPages = 1;
    if (totalBatches == null) totalBatches = 0;
    if (startItem == null) startItem = 0;
    if (endItem == null) endItem = 0;

    if (batches == null) {
        batches = new ArrayList<>();
    }

    if (allBatches == null) {
        allBatches = batches;
    }

    if (batchItems == null) {
        batchItems = new ArrayList<>();
    }

    if (products == null) {
        products = new ArrayList<>();
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Lô hàng</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
        <style>
            .btn-batch-edit {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                padding: 6px 14px;
                font-size: 13px;
                font-weight: 600;
                color: #2563eb;
                background-color: #eff6ff;
                border: 1px solid #bfdbfe;
                border-radius: 6px;
                cursor: pointer;
                transition: all 0.2s ease-in-out;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            }

            .btn-batch-edit:hover {
                background-color: #2563eb;
                color: #ffffff;
                border-color: #2563eb;
                box-shadow: 0 4px 10px rgba(37, 99, 235, 0.25);
                transform: translateY(-1px);
            }

            .btn-batch-edit:active {
                transform: translateY(0);
                box-shadow: none;
            }

            .btn-batch-edit i {
                font-size: 12px;
            }
        </style>
    </head>

    <body class="dashboard-body admin-brand-body" style="padding-bottom: 0px">

        <jsp:include page="/includes/header.jsp" />

        <main class="admin-brand-page">

            <section class="admin-page-heading" style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <nav class="admin-breadcrumb site-breadcrumb" aria-label="Breadcrumb">
                        <a href="${pageContext.request.contextPath}/Dashboard">Dashboard</a>
                        <span>›</span>
                        <span>Sản phẩm</span>
                        <span>›</span>
                        <strong>Quản lý lô hàng</strong>
                    </nav>
                    <h1>Quản lý lô hàng</h1>
                </div>
                <div style="display: flex; gap: 10px;">
                   
                    <a href="#add-batch-modal" class="brand-add-button" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">
                        + Thêm lô hàng
                    </a>
                    <a href="#add-item-modal" class="brand-add-button" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center; background-color: #28a745;">
                        + Thêm sản phẩm vào lô
                    </a>
                </div>
            </section>

            <!-- THÔNG BÁO -->
            <% if (message != null) { %>
            <div class="brand-alert success">
                <%= message %>
            </div>
            <% } %>

            <% if (error != null && !error.toLowerCase().contains("lô hàng")) { %>
            <div class="brand-alert error">
                <%= error %>
            </div>
            <% } %>


            <!-- DANH SÁCH LÔ HÀNG -->
            <section class="batch-card">
                <div class="batch-card-header">
                    <h2>Danh sách lô hàng</h2>
                </div>

                <div class="batch-table-wrapper">
                    <table class="batch-table">
                        <thead>
                            <tr>
                                <th>Mã lô</th>
                                <th>Tên lô hàng</th>
                                <th>Ngày nhập</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (batches.isEmpty()) { %>
                            <tr>
                                <td colspan="4" class="batch-empty-row">
                                    Chưa có lô hàng nào.
                                </td>
                            </tr>
                            <% } else { %>
                            <% for (Batch b : batches) { %>
                            <tr>
                                <td>#<%= b.getBatchId() %></td>
                                <td>
                                    <%= b.getBatchName() %>
                                    <% if (b.isEdited()) { %>
                                    <span style="background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; font-size: 11px; padding: 2px 6px; margin-left: 6px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px; font-weight: 500;">
                                        <i class="fa-solid fa-pen-to-square" style="font-size: 10px;"></i> Đã sửa
                                    </span>
                                    <% } %>
                                </td>
                                <td><%= b.getDate() %></td>
                                <td>
                                    <div class="batch-table-actions" style="display: flex; gap: 6px; align-items: center;">
                                        <a class="batch-btn-view"
                                           href="${pageContext.request.contextPath}/BatchServlet?action=viewDetail&batchId=<%= b.getBatchId() %>&page=<%= currentPage %>">
                                            Chi tiết
                                        </a>
                                        <button type="button" 
                                                class="btn-batch-edit" 
                                                onclick="openEditBatchModal(<%= b.getBatchId() %>, '<%= b.getBatchName().replace("'", "\\'").replace("\"", "&quot;") %>', '<%= b.getDate() %>')">
                                            <i class="fa-solid fa-pen-to-square"></i> Sửa
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Footer cho Lô hàng -->
                <%
                    String batchParam = (selectedBatchId != null) ? "&action=viewDetail&batchId=" + selectedBatchId : "";
                %>
                <div class="admin-product-footer">
                    <p>
                        Hiển thị <strong><%= startItem %></strong> đến <strong><%= endItem %></strong> của <strong><%= totalBatches %></strong> lô hàng
                    </p>
                    <div class="admin-pagination">
                        <% if (currentPage > 1) { %>
                        <a class="page-btn" href="${pageContext.request.contextPath}/BatchServlet?page=<%= currentPage - 1 %><%= batchParam %>">&lsaquo;</a>
                        <% } else { %>
                        <span class="page-btn disabled"><</span>
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
                        <a class="page-btn <%= currentPage == 1 ? "active" : "" %>" href="${pageContext.request.contextPath}/BatchServlet?page=1<%= batchParam %>">1</a>
                        <% if (fromPage > 2) { %>
                        <span class="page-btn disabled">...</span>
                        <% } %>
                        <% for (int i = fromPage; i <= toPage; i++) { %>
                        <a class="page-btn <%= currentPage == i ? "active" : "" %>" href="${pageContext.request.contextPath}/BatchServlet?page=<%= i %><%= batchParam %>"><%= i %></a>
                        <% } %>
                        <% if (toPage < totalPages - 1) { %>
                        <span class="page-btn disabled">...</span>
                        <% } %>
                        <% if (totalPages > 1) { %>
                        <a class="page-btn <%= currentPage == totalPages ? "active" : "" %>" href="${pageContext.request.contextPath}/BatchServlet?page=<%= totalPages %><%= batchParam %>"><%= totalPages %></a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                        <a class="page-btn" href="${pageContext.request.contextPath}/BatchServlet?page=<%= currentPage + 1 %><%= batchParam %>">&rsaquo;</a>
                        <% } else { %>
                        <span class="page-btn disabled">></span>
                        <% } %>
                    </div>
                </div>
            </section>


            <!-- CHI TIẾT LÔ NHẬP -->
            <section class="batch-card">
                <div class="batch-card-header">
                    <h2>Chi tiết lô nhập</h2>

                    <% if (selectedBatchId != null) { %>
                    <span class="batch-tag">
                        Batch ID: #<%= selectedBatchId %>
                    </span>
                    <% } %>
                </div>

                <div class="batch-table-wrapper">
                    <table class="batch-table">
                        <thead>
                            <tr>
                                <th>Mã chi tiết</th>
                                <th>Tên sản phẩm</th>
                                <th>SL nhập</th>
                                <th>SL tồn</th>
                                <th>Giá nhập</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>

                        <tbody>
                            <% if (batchItems.isEmpty()) { %>
                            <tr>
                                <td colspan="6" class="batch-empty-row">
                                    Bấm nút <b>Chi tiết</b> ở một lô hàng để xem sản phẩm trong lô.
                                </td>
                            </tr>
                            <% } else { %>
                            <% for (BatchItem item : batchItems) { 
                                String pName = "";
                                if (products != null) {
                                    for (Product p : products) {
                                        if (p.getProductId() == item.getProductId()) {
                                            pName = p.getProductName();
                                            break;
                                        }
                                    }
                                }
                                boolean canEdit = (item.getQuantity() == item.getImportQuantity());
                            %>
                            <tr>
                                <td>#<%= item.getBatchItemId() %></td>
                                <td>
                                    <%= pName %>
                                    <% if (item.isEdited()) { %>
                                    <span style="background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; font-size: 11px; padding: 2px 6px; margin-left: 6px; border-radius: 4px; display: inline-flex; align-items: center; gap: 4px; font-weight: 500;">
                                        <i class="fa-solid fa-pen-to-square" style="font-size: 10px;"></i> Đã sửa
                                    </span>
                                    <% } %>
                                </td>
                                <td><%= item.getImportQuantity() %></td>
                                <td><%= item.getQuantity() %></td>
                                <td><%= item.getPrice() %></td>
                                <td>
                                    <% if (canEdit) { %>
                                     <button type="button" 
                                             class="btn-batch-edit" 
                                             onclick="openEditItemModal(<%= item.getBatchItemId() %>, <%= item.getBatchId() %>, '<%= pName.replace("'", "\\'").replace("\"", "&quot;") %>', <%= item.getImportQuantity() %>, <%= item.getPrice() %>)">
                                         <i class="fa-solid fa-pen-to-square"></i> Sửa
                                     </button>
                                    <% } else { %>
                                    <span style="color: #6c757d; font-size: 12px; font-style: italic;">Đã bán (Không thể sửa)</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>

        </main>

        <!-- MODAL THÊM LÔ HÀNG -->
        <div class="brand-modal-overlay" id="add-batch-modal">
            <section class="brand-modal" role="dialog" aria-modal="true" aria-labelledby="addBatchTitle">
                <div class="brand-form-header">
                    <h2 id="addBatchTitle">Thêm lô hàng mới</h2>
                    <a href="#" aria-label="Đóng" style="text-decoration: none; font-size: 24px; color: #6c757d;">×</a>
                </div>

                <form action="${pageContext.request.contextPath}/BatchServlet" method="post" class="brand-modal-form" id="addBatchForm">
                    <input type="hidden" name="action" value="addBatch">

                    <div class="batch-form-group">
                        <label for="batchNameInput">Tên lô hàng <span>*</span></label>
                        <input 
                            type="text"
                            id="batchNameInput"
                            name="batchName"
                            placeholder="Ví dụ: Lô nhập tháng 06"
                            required
                            value="${requestScope.enteredBatchName != null ? requestScope.enteredBatchName : ''}">
                        <small id="batchNameErr" style="color: #dc3545; font-size: 13px; margin-top: 4px; display: none;"></small>
                    </div>

                    <div class="batch-form-group" style="margin-top: 12px;">
                        <label for="batchDateInput">Ngày nhập <span>*</span></label>
                        <input 
                            type="date"
                            id="batchDateInput"
                            name="date"
                            required
                            value="${requestScope.enteredDate != null ? requestScope.enteredDate : ''}">
                        <small id="batchDateErr" style="color: #dc3545; font-size: 13px; margin-top: 4px; display: none;"></small>
                    </div>

                    <div class="brand-form-actions" style="margin-top: 20px;">
                        <a class="brand-secondary-button" href="#" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Hủy</a>
                        <button class="brand-primary-button" type="submit">Thêm lô hàng</button>
                    </div>
                </form>
            </section>
        </div>

        <!-- MODAL SỬA LÔ HÀNG -->
        <div class="brand-modal-overlay" id="edit-batch-modal">
            <section class="brand-modal" role="dialog" aria-modal="true" aria-labelledby="editBatchModalTitle">
                <div class="brand-form-header">
                    <h2 id="editBatchModalTitle">Sửa thông tin lô hàng</h2>
                    <a href="#" aria-label="Đóng" style="text-decoration: none; font-size: 24px; color: #6c757d;">×</a>
                </div>

                <form action="${pageContext.request.contextPath}/BatchServlet" method="post" class="brand-modal-form" id="editBatchForm">
                    <input type="hidden" name="action" value="updateBatch">
                    <input type="hidden" name="batchId" id="editBatchIdVal">
                    <input type="hidden" name="page" value="<%= currentPage %>">

                    <div class="batch-form-group">
                        <label for="editBatchNameInput">Tên lô hàng <span>*</span></label>
                        <input 
                            type="text"
                            id="editBatchNameInput"
                            name="batchName"
                            placeholder="Ví dụ: Lô nhập tháng 06"
                            required>
                        <small id="editBatchNameErr" style="color: #dc3545; font-size: 13px; margin-top: 4px; display: none;"></small>
                    </div>

                    <div class="batch-form-group" style="margin-top: 12px;">
                        <label for="editBatchDateInput">Ngày nhập <span>*</span></label>
                        <input 
                            type="date"
                            id="editBatchDateInput"
                            name="date"
                            required>
                        <small id="editBatchDateErr" style="color: #dc3545; font-size: 13px; margin-top: 4px; display: none;"></small>
                    </div>

                    <div class="brand-form-actions" style="margin-top: 20px;">
                        <a class="brand-secondary-button" href="#" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Hủy</a>
                        <button class="brand-primary-button" type="submit">Lưu thay đổi</button>
                    </div>
                </form>
            </section>
        </div>



        <!-- MODAL THÊM SẢN PHẨM VÀO LÔ -->
        <div class="brand-modal-overlay" id="add-item-modal">
            <section class="brand-modal" style="width: min(600px, 100%);" role="dialog" aria-modal="true" aria-labelledby="addItemTitle">
                <div class="brand-form-header">
                    <h2 id="addItemTitle">Thêm sản phẩm vào lô</h2>
                    <a href="#" aria-label="Đóng" style="text-decoration: none; font-size: 24px; color: #6c757d;">×</a>
                </div>

                <form action="${pageContext.request.contextPath}/BatchItemServlet" method="post" class="brand-modal-form">
                    <input type="hidden" name="action" value="addItem">
                    <input type="hidden" name="page" value="<%= currentPage %>">

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                        <div class="batch-form-group">
                            <label>Lô hàng</label>
                            <select name="batchId" required style="width: 100%;">
                                <option value="">-- Chọn lô hàng --</option>
                                <% for (Batch b : allBatches) {
                                    boolean selected = false;
                                    if (selectedBatchId != null && selectedBatchId == b.getBatchId()) {
                                        selected = true;
                                    }
                                %>
                                <option value="<%= b.getBatchId() %>" <%= selected ? "selected" : "" %>>
                                    <%= b.getBatchName() %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="batch-form-group">
                            <label>Sản phẩm</label>
                            <select name="productId" required style="width: 100%;">
                                <option value="">-- Chọn sản phẩm --</option>
                                <% for (Product p : products) { %>
                                <option value="<%= p.getProductId() %>">
                                    <%= p.getProductName() %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                    </div>

                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-top: 12px;">
                        <div class="batch-form-group">
                            <label>Số lượng nhập</label>
                            <input 
                                type="number"
                                name="importQuantity"
                                min="1"
                                placeholder="Số lượng nhập ban đầu"
                                required
                                oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                                value="">
                        </div>

                        <div class="batch-form-group">
                            <label>Giá nhập (VNĐ)</label>
                            <input 
                                type="number"
                                name="price"
                                min="0"
                                step="1000"
                                placeholder="Giá nhập sản phẩm"
                                required
                                oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                                value="">
                        </div>
                    </div>

                    <div class="brand-form-actions" style="margin-top: 20px;">
                        <a class="brand-secondary-button" href="#" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Hủy</a>
                        <button class="brand-primary-button" type="submit">Thêm sản phẩm</button>
                    </div>
                </form>
            </section>
        </div>

        <!-- MODAL SỬA SẢN PHẨM TRONG LÔ -->
        <div class="brand-modal-overlay" id="edit-item-modal">
            <section class="brand-modal" role="dialog" aria-modal="true" aria-labelledby="editItemTitle">
                <div class="brand-form-header">
                    <h2 id="editItemTitle">Sửa sản phẩm trong lô</h2>
                    <a href="#" aria-label="Đóng" style="text-decoration: none; font-size: 24px; color: #6c757d;">×</a>
                </div>

                <form action="${pageContext.request.contextPath}/BatchItemServlet" method="post" class="brand-modal-form" id="editBatchItemForm">
                    <input type="hidden" name="action" value="updateItem">
                    <input type="hidden" name="batchItemId" id="editBatchItemId">
                    <input type="hidden" name="batchId" id="editBatchId">
                    <input type="hidden" name="page" value="<%= currentPage %>">

                    <div class="batch-form-group">
                        <label>Tên sản phẩm</label>
                        <input type="text" id="editProductName" readonly style="background-color: #e9ecef; cursor: not-allowed; font-weight: 600;">
                    </div>

                    <div class="batch-form-group" style="margin-top: 12px;">
                        <label for="editImportQuantity">Số lượng nhập mới <span>*</span></label>
                        <input 
                            type="number"
                            id="editImportQuantity"
                            name="importQuantity"
                            min="1"
                            placeholder="Số lượng nhập kho"
                            required>
                        <small id="editImportQuantityErr" style="color: #dc3545; font-size: 13px; margin-top: 4px; display: none;"></small>
                    </div>

                    <div class="batch-form-group" style="margin-top: 12px;">
                        <label for="editPrice">Giá nhập mới (VNĐ) <span>*</span></label>
                        <input 
                            type="number"
                            id="editPrice"
                            name="price"
                            min="0"
                            step="1000"
                            placeholder="Ví dụ: 15000000"
                            required>
                        <small id="editPriceErr" style="color: #dc3545; font-size: 13px; margin-top: 4px; display: none;"></small>
                    </div>

                    <div class="brand-form-actions" style="margin-top: 20px;">
                        <a class="brand-secondary-button" href="#" style="text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Hủy</a>
                        <button class="brand-primary-button" type="submit">Lưu thay đổi</button>
                    </div>
                </form>
            </section>
        </div>



        <jsp:include page="/includes/footer.jsp" />

        <script>
            function openEditBatchModal(batchId, batchName, date) {
                document.getElementById("editBatchIdVal").value = batchId;
                document.getElementById("editBatchNameInput").value = batchName;
                document.getElementById("editBatchDateInput").value = date;
                window.location.hash = "edit-batch-modal";
            }

            function openEditItemModal(batchItemId, batchId, productName, importQuantity, price) {
                document.getElementById("editBatchItemId").value = batchItemId;
                document.getElementById("editBatchId").value = batchId;
                document.getElementById("editProductName").value = productName;
                document.getElementById("editImportQuantity").value = importQuantity;
                document.getElementById("editPrice").value = price;
                window.location.hash = "edit-item-modal";
            }

            document.addEventListener("DOMContentLoaded", function () {
                const batchNameInput = document.getElementById("batchNameInput");
                const batchNameErr = document.getElementById("batchNameErr");
                const batchDateInput = document.getElementById("batchDateInput");
                const batchDateErr = document.getElementById("batchDateErr");
                const addBatchForm = document.getElementById("addBatchForm");

                const editBatchNameInput = document.getElementById("editBatchNameInput");
                const editBatchNameErr = document.getElementById("editBatchNameErr");
                const editBatchDateInput = document.getElementById("editBatchDateInput");
                const editBatchDateErr = document.getElementById("editBatchDateErr");
                const editBatchForm = document.getElementById("editBatchForm");

                // Biểu thức chính quy cho tên lô hàng: cho phép chữ cái, chữ số, khoảng trắng, và các dấu -, _, /, ()
                const batchNameRegex = /^[\p{L}\p{N}\s\-_/()]+$/u;

                function validateBatchName() {
                    if (!batchNameInput) return true;
                    const val = batchNameInput.value.trim();
                    if (!val) {
                        batchNameErr.textContent = "Vui lòng nhập tên lô hàng.";
                        batchNameErr.style.display = "block";
                        batchNameInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    if (!batchNameRegex.test(val)) {
                        batchNameErr.textContent = "Tên lô hàng không được chứa ký tự đặc biệt.";
                        batchNameErr.style.display = "block";
                        batchNameInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    batchNameErr.style.display = "none";
                    batchNameInput.style.borderColor = "";
                    return true;
                }

                function validateBatchDate() {
                    if (!batchDateInput) return true;
                    const val = batchDateInput.value;
                    if (!val) {
                        batchDateErr.textContent = "Vui lòng chọn ngày nhập.";
                        batchDateErr.style.display = "block";
                        batchDateInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    const selectedDate = new Date(val);
                    const today = new Date();
                    today.setHours(23, 59, 59, 999);
                    if (selectedDate > today) {
                        batchDateErr.textContent = "Ngày nhập lô hàng không được lớn hơn ngày hiện tại.";
                        batchDateErr.style.display = "block";
                        batchDateInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    batchDateErr.style.display = "none";
                    batchDateInput.style.borderColor = "";
                    return true;
                }

                function validateEditBatchName() {
                    if (!editBatchNameInput) return true;
                    const val = editBatchNameInput.value.trim();
                    if (!val) {
                        editBatchNameErr.textContent = "Vui lòng nhập tên lô hàng.";
                        editBatchNameErr.style.display = "block";
                        editBatchNameInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    if (!batchNameRegex.test(val)) {
                        editBatchNameErr.textContent = "Tên lô hàng không được chứa ký tự đặc biệt.";
                        editBatchNameErr.style.display = "block";
                        editBatchNameInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    editBatchNameErr.style.display = "none";
                    editBatchNameInput.style.borderColor = "";
                    return true;
                }

                function validateEditBatchDate() {
                    if (!editBatchDateInput) return true;
                    const val = editBatchDateInput.value;
                    if (!val) {
                        editBatchDateErr.textContent = "Vui lòng chọn ngày nhập.";
                        editBatchDateErr.style.display = "block";
                        editBatchDateInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    const selectedDate = new Date(val);
                    const today = new Date();
                    today.setHours(23, 59, 59, 999);
                    if (selectedDate > today) {
                        editBatchDateErr.textContent = "Ngày nhập lô hàng không được lớn hơn ngày hiện tại.";
                        editBatchDateErr.style.display = "block";
                        editBatchDateInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    editBatchDateErr.style.display = "none";
                    editBatchDateInput.style.borderColor = "";
                    return true;
                }

                if (batchNameInput) {
                    batchNameInput.addEventListener("input", validateBatchName);
                    batchNameInput.addEventListener("blur", validateBatchName);
                }
                if (batchDateInput) {
                    batchDateInput.addEventListener("input", validateBatchDate);
                    batchDateInput.addEventListener("change", validateBatchDate);
                }

                if (addBatchForm) {
                    addBatchForm.addEventListener("submit", function (e) {
                        const isNameValid = validateBatchName();
                        const isDateValid = validateBatchDate();
                        if (!isNameValid || !isDateValid) {
                            e.preventDefault();
                        }
                    });
                }

                if (editBatchNameInput) {
                    editBatchNameInput.addEventListener("input", validateEditBatchName);
                    editBatchNameInput.addEventListener("blur", validateEditBatchName);
                }
                if (editBatchDateInput) {
                    editBatchDateInput.addEventListener("input", validateEditBatchDate);
                    editBatchDateInput.addEventListener("change", validateEditBatchDate);
                }

                if (editBatchForm) {
                    editBatchForm.addEventListener("submit", function (e) {
                        const isNameValid = validateEditBatchName();
                        const isDateValid = validateEditBatchDate();
                        if (!isNameValid || !isDateValid) {
                            e.preventDefault();
                        }
                    });
                }

                <%-- Nếu Server trả về lỗi, hiển thị trực tiếp bên dưới ô input tương ứng bên trong Modal --%>
                <% String serverBatchErr = (String) request.getAttribute("error"); %>
                <% if (serverBatchErr != null && !serverBatchErr.trim().isEmpty()) { %>
                    const serverErrText = "<%= serverBatchErr.replace("\"", "\\\"") %>";
                    if (serverErrText.includes("Tên lô hàng") || serverErrText.includes("kí tự đặc biệt") || serverErrText.includes("ký tự đặc biệt")) {
                        if (batchNameErr && batchNameInput) {
                            batchNameErr.textContent = serverErrText;
                            batchNameErr.style.display = "block";
                            batchNameInput.style.borderColor = "#dc3545";
                        }
                        if (editBatchNameErr && editBatchNameInput) {
                            editBatchNameErr.textContent = serverErrText;
                            editBatchNameErr.style.display = "block";
                            editBatchNameInput.style.borderColor = "#dc3545";
                        }
                    } else if (serverErrText.includes("Ngày nhập")) {
                        if (batchDateErr && batchDateInput) {
                            batchDateErr.textContent = serverErrText;
                            batchDateErr.style.display = "block";
                            batchDateInput.style.borderColor = "#dc3545";
                        }
                        if (editBatchDateErr && editBatchDateInput) {
                            editBatchDateErr.textContent = serverErrText;
                            editBatchDateErr.style.display = "block";
                            editBatchDateInput.style.borderColor = "#dc3545";
                        }
                    }
                <% } %>

                const editImportQtyInput = document.getElementById("editImportQuantity");
                const editImportQtyErr = document.getElementById("editImportQuantityErr");
                const editPriceInput = document.getElementById("editPrice");
                const editPriceErr = document.getElementById("editPriceErr");
                const editBatchItemForm = document.getElementById("editBatchItemForm");

                function validateEditQty() {
                    if (!editImportQtyInput) return true;
                    const val = parseInt(editImportQtyInput.value, 10);
                    if (isNaN(val) || val <= 0) {
                        editImportQtyErr.textContent = "Số lượng nhập phải lớn hơn 0.";
                        editImportQtyErr.style.display = "block";
                        editImportQtyInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    editImportQtyErr.style.display = "none";
                    editImportQtyInput.style.borderColor = "";
                    return true;
                }

                function validateEditPrice() {
                    if (!editPriceInput) return true;
                    const val = parseFloat(editPriceInput.value);
                    if (isNaN(val) || val < 0) {
                        editPriceErr.textContent = "Giá nhập không được âm.";
                        editPriceErr.style.display = "block";
                        editPriceInput.style.borderColor = "#dc3545";
                        return false;
                    }
                    editPriceErr.style.display = "none";
                    editPriceInput.style.borderColor = "";
                    return true;
                }

                if (editImportQtyInput) {
                    editImportQtyInput.addEventListener("input", validateEditQty);
                }
                if (editPriceInput) {
                    editPriceInput.addEventListener("input", validateEditPrice);
                }
                if (editBatchItemForm) {
                    editBatchItemForm.addEventListener("submit", function (e) {
                        const qValid = validateEditQty();
                        const pValid = validateEditPrice();
                        if (!qValid || !pValid) {
                            e.preventDefault();
                        }
                    });
                }
            });
        </script>

    </body>
</html>
