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
                                <td><%= b.getBatchName() %></td>
                                <td><%= b.getDate() %></td>
                                <td>
                                    <div class="batch-table-actions">
                                        <a class="batch-btn-view"
                                           href="${pageContext.request.contextPath}/BatchServlet?action=viewDetail&batchId=<%= b.getBatchId() %>">
                                            Chi tiết
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination Footer cho Lô hàng -->
                <div class="admin-product-footer">
                    <p>
                        Hiển thị <strong><%= startItem %></strong> đến <strong><%= endItem %></strong> của <strong><%= totalBatches %></strong> lô hàng
                    </p>
                    <div class="admin-pagination">
                        <% if (currentPage > 1) { %>
                        <a class="page-btn" href="${pageContext.request.contextPath}/BatchServlet?page=<%= currentPage - 1 %>">&lsaquo;</a>
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
                        <a class="page-btn <%= currentPage == 1 ? "active" : "" %>" href="${pageContext.request.contextPath}/BatchServlet?page=1">1</a>
                        <% if (fromPage > 2) { %>
                        <span class="page-btn disabled">...</span>
                        <% } %>
                        <% for (int i = fromPage; i <= toPage; i++) { %>
                        <a class="page-btn <%= currentPage == i ? "active" : "" %>" href="${pageContext.request.contextPath}/BatchServlet?page=<%= i %>"><%= i %></a>
                        <% } %>
                        <% if (toPage < totalPages - 1) { %>
                        <span class="page-btn disabled">...</span>
                        <% } %>
                        <% if (totalPages > 1) { %>
                        <a class="page-btn <%= currentPage == totalPages ? "active" : "" %>" href="${pageContext.request.contextPath}/BatchServlet?page=<%= totalPages %>"><%= totalPages %></a>
                        <% } %>

                        <% if (currentPage < totalPages) { %>
                        <a class="page-btn" href="${pageContext.request.contextPath}/BatchServlet?page=<%= currentPage + 1 %>">&rsaquo;</a>
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
                            </tr>
                        </thead>

                        <tbody>
                            <% if (batchItems.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="batch-empty-row">
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
                            %>
                            <tr>
                                <td>#<%= item.getBatchItemId() %></td>
                                <td><%= pName %></td>
                                <td><%= item.getImportQuantity() %></td>
                                <td><%= item.getQuantity() %></td>
                                <td><%= item.getPrice() %></td>
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



        <!-- MODAL THÊM SẢN PHẨM VÀO LÔ -->
        <div class="brand-modal-overlay" id="add-item-modal">
            <section class="brand-modal" style="width: min(600px, 100%);" role="dialog" aria-modal="true" aria-labelledby="addItemTitle">
                <div class="brand-form-header">
                    <h2 id="addItemTitle">Thêm sản phẩm vào lô</h2>
                    <a href="#" aria-label="Đóng" style="text-decoration: none; font-size: 24px; color: #6c757d;">×</a>
                </div>

                <form action="${pageContext.request.contextPath}/BatchItemServlet" method="post" class="brand-modal-form">
                    <input type="hidden" name="action" value="addItem">

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



        <jsp:include page="/includes/footer.jsp" />

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const batchNameInput = document.getElementById("batchNameInput");
                const batchNameErr = document.getElementById("batchNameErr");
                const batchDateInput = document.getElementById("batchDateInput");
                const batchDateErr = document.getElementById("batchDateErr");
                const addBatchForm = document.getElementById("addBatchForm");

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
                    } else if (serverErrText.includes("Ngày nhập")) {
                        if (batchDateErr && batchDateInput) {
                            batchDateErr.textContent = serverErrText;
                            batchDateErr.style.display = "block";
                            batchDateInput.style.borderColor = "#dc3545";
                        }
                    }
                <% } %>
            });
        </script>

    </body>
</html>
