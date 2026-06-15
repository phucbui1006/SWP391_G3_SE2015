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
    List<BatchItem> batchItems = (List<BatchItem>) request.getAttribute("batchItems");
    List<Product> products = (List<Product>) request.getAttribute("products");

    Batch editBatch = (Batch) request.getAttribute("editBatch");
    BatchItem editItem = (BatchItem) request.getAttribute("editItem");

    Integer selectedBatchId = (Integer) request.getAttribute("selectedBatchId");

    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");

    if (batches == null) {
        batches = new ArrayList<>();
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

<body class="batch-page-body">

    <jsp:include page="/includes/header.jsp" />

    <main class="batch-main">

        <!-- TIÊU ĐỀ TRANG -->
        <section class="batch-title-box">
            <div>
                <h1>📦 Quản lý lô hàng</h1>
                <p>Thêm, sửa, xóa lô hàng và xem chi tiết sản phẩm trong từng lô nhập.</p>
            </div>

            <a href="${pageContext.request.contextPath}/BatchServlet" class="batch-btn-reset">
                Làm mới
            </a>
        </section>

        <!-- THÔNG BÁO -->
        <% if (message != null) { %>
            <div class="batch-alert-success">
                <%= message %>
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="batch-alert-error">
                <%= error %>
            </div>
        <% } %>

        <!-- FORM THÊM / SỬA LÔ HÀNG -->
        <section class="batch-card">
            <div class="batch-card-header">
                <h2>
                    <%= editBatch == null ? "Thêm lô hàng mới" : "Cập nhật lô hàng" %>
                </h2>
            </div>

            <form action="${pageContext.request.contextPath}/BatchServlet" method="post" class="batch-form">
                <input type="hidden" name="action" value="<%= editBatch == null ? "addBatch" : "updateBatch" %>">

                <% if (editBatch != null) { %>
                    <input type="hidden" name="batchId" value="<%= editBatch.getBatchId() %>">
                <% } %>

                <div class="batch-form-group">
                    <label>Tên lô hàng</label>
                    <input 
                        type="text"
                        name="batchName"
                        placeholder="Ví dụ: Lô nhập tháng 06"
                        required
                        value="<%= editBatch != null ? editBatch.getBatchName() : "" %>">
                </div>

                <div class="batch-form-group">
                    <label>Ngày nhập</label>
                    <input 
                        type="date"
                        name="date"
                        required
                        value="<%= editBatch != null ? editBatch.getDate() : "" %>">
                </div>

                <div class="batch-form-actions">
                    <button type="submit" class="batch-btn-primary">
                        <%= editBatch == null ? "Thêm lô hàng" : "Cập nhật" %>
                    </button>

                    <% if (editBatch != null) { %>
                        <a href="${pageContext.request.contextPath}/BatchServlet" class="batch-btn-cancel">
                            Hủy
                        </a>
                    <% } %>
                </div>
            </form>
        </section>

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

                                            <a class="batch-btn-edit"
                                               href="${pageContext.request.contextPath}/BatchServlet?action=editBatch&batchId=<%= b.getBatchId() %>">
                                                Sửa
                                            </a>

                                            <form action="${pageContext.request.contextPath}/BatchServlet"
                                                  method="post"
                                                  class="batch-inline-form"
                                                  onsubmit="return confirm('Bạn có chắc muốn xóa lô hàng này không?');">

                                                <input type="hidden" name="action" value="deleteBatch">
                                                <input type="hidden" name="batchId" value="<%= b.getBatchId() %>">

                                                <button type="submit" class="batch-btn-delete">
                                                    Xóa
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
        </section>

        <!-- FORM THÊM / SỬA SẢN PHẨM TRONG LÔ -->
        <section class="batch-card">
            <div class="batch-card-header">
                <h2>
                    <%= editItem == null ? "Thêm sản phẩm vào lô" : "Cập nhật sản phẩm trong lô" %>
                </h2>
            </div>

            <form action="${pageContext.request.contextPath}/BatchItemServlet" method="post" class="batch-form batch-item-form">
                <input type="hidden" name="action" value="<%= editItem == null ? "addItem" : "updateItem" %>">

                <% if (editItem != null) { %>
                    <input type="hidden" name="batchItemId" value="<%= editItem.getBatchItemId() %>">
                <% } %>

                <div class="batch-form-group">
                    <label>Lô hàng</label>
                    <select name="batchId" required>
                        <option value="">-- Chọn lô hàng --</option>

                        <% for (Batch b : batches) { 
                            boolean selected = false;

                            if (editItem != null && editItem.getBatchId() == b.getBatchId()) {
                                selected = true;
                            }

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
                    <select name="productId" required>
                        <option value="">-- Chọn sản phẩm --</option>

                        <% for (Product p : products) { %>
                            <option value="<%= p.getProductId() %>"
                                <%= editItem != null && editItem.getProductId() == p.getProductId() ? "selected" : "" %>>
                                <%= p.getProductName() %>
                            </option>
                        <% } %>
                    </select>
                </div>

                <div class="batch-form-group">
                    <label>Số lượng</label>
                    <input 
                        type="number"
                        name="quantity"
                        min="1"
                        required
                        value="<%= editItem != null ? editItem.getQuantity() : "" %>">
                </div>

                <div class="batch-form-group">
                    <label>Giá nhập</label>
                    <input 
                        type="number"
                        name="price"
                        min="0"
                        step="1000"
                        required
                        value="<%= editItem != null ? editItem.getPrice() : "" %>">
                </div>

                <div class="batch-form-group">
                    <label>Bảo hành</label>
                    <input 
                        type="number"
                        name="warrantyMonths"
                        min="0"
                        required
                        value="<%= editItem != null ? editItem.getWarrantyMonths() : 0 %>">
                </div>

                <div class="batch-form-actions">
                    <button type="submit" class="batch-btn-primary">
                        <%= editItem == null ? "Thêm sản phẩm" : "Cập nhật" %>
                    </button>

                    <% if (editItem != null) { %>
                        <a href="${pageContext.request.contextPath}/BatchServlet?action=viewDetail&batchId=<%= editItem.getBatchId() %>"
                           class="batch-btn-cancel">
                            Hủy
                        </a>
                    <% } %>
                </div>
            </form>
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
                            <th>Mã lô</th>
                            <th>Mã sản phẩm</th>
                            <th>Số lượng</th>
                            <th>Giá nhập</th>
                            <th>Bảo hành</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>

                    <tbody>
                        <% if (batchItems.isEmpty()) { %>
                            <tr>
                                <td colspan="7" class="batch-empty-row">
                                    Bấm nút <b>Chi tiết</b> ở một lô hàng để xem sản phẩm trong lô.
                                </td>
                            </tr>
                        <% } else { %>
                            <% for (BatchItem item : batchItems) { %>
                                <tr>
                                    <td>#<%= item.getBatchItemId() %></td>
                                    <td>#<%= item.getBatchId() %></td>
                                    <td>#<%= item.getProductId() %></td>
                                    <td><%= item.getQuantity() %></td>
                                    <td><%= item.getPrice() %></td>
                                    <td><%= item.getWarrantyMonths() %> tháng</td>
                                    <td>
                                        <div class="batch-table-actions">

                                            <a class="batch-btn-edit"
                                               href="${pageContext.request.contextPath}/BatchItemServlet?action=editItem&batchItemId=<%= item.getBatchItemId() %>&batchId=<%= item.getBatchId() %>">
                                                Sửa
                                            </a>

                                            <form action="${pageContext.request.contextPath}/BatchItemServlet"
                                                  method="post"
                                                  class="batch-inline-form"
                                                  onsubmit="return confirm('Bạn có chắc muốn xóa sản phẩm này khỏi lô không?');">

                                                <input type="hidden" name="action" value="deleteItem">
                                                <input type="hidden" name="batchItemId" value="<%= item.getBatchItemId() %>">
                                                <input type="hidden" name="batchId" value="<%= item.getBatchId() %>">

                                                <button type="submit" class="batch-btn-delete">
                                                    Xóa
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
        </section>

    </main>

    <jsp:include page="/includes/footer.jsp" />

</body>
</html>