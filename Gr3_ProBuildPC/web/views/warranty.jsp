<%-- 
    Document   : warranty
    Created on : Jun 7, 2026, 8:34:46 PM
    Author     : Admin
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Warranty" %>

<%
    ArrayList<Warranty> warrantyProducts = (ArrayList<Warranty>) request.getAttribute("warrantyProducts");
    ArrayList<Warranty> myWarrantyRequests = (ArrayList<Warranty>) request.getAttribute("myWarrantyRequests");

    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Warranty Service</title>

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

        .warranty-wrapper {
            min-height: calc(100vh - 120px);
            padding: 35px 55px;
            background: #f5f6fa;
        }

        .warranty-container {
            max-width: 1350px;
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
            background: white;
            border: 1px solid #e5e7eb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
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

        .alert-success {
            background: #dcfce7;
            color: #15803d;
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: bold;
        }

        .alert-error {
            background: #fee2e2;
            color: #dc2626;
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: bold;
        }

        .search-card,
        .table-card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            border: 1px solid #e5e7eb;
            box-shadow: 0 4px 14px rgba(0,0,0,0.07);
            margin-bottom: 24px;
        }

        .card-title {
            margin: 0 0 18px;
            color: #111827;
            font-size: 20px;
        }

        .search-form {
            display: flex;
            gap: 14px;
            align-items: flex-end;
        }

        .form-group {
            flex: 1;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #111827;
            font-weight: bold;
            font-size: 14px;
        }

        .form-group input,
        .request-textarea {
            width: 100%;
            box-sizing: border-box;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            padding: 0 12px;
            font-size: 14px;
            background: white;
        }

        .form-group input {
            height: 42px;
        }

        .request-textarea {
            height: 76px;
            padding: 10px 12px;
            resize: vertical;
            font-family: Arial, sans-serif;
        }

        .form-group input:focus,
        .request-textarea:focus {
            outline: none;
            border-color: #ed1c24;
            box-shadow: 0 0 0 3px rgba(237, 28, 36, 0.12);
        }

        .btn-search,
        .btn-request {
            border: none;
            height: 42px;
            padding: 0 22px;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
            white-space: nowrap;
        }

        .btn-search {
            background: #ed1c24;
            color: white;
        }

        .btn-request {
            background: #2563eb;
            color: white;
        }

        .btn-search:hover {
            background: #c9151c;
        }

        .btn-request:hover {
            background: #1d4ed8;
        }

        .warranty-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1000px;
        }

        .warranty-table th {
            background: #fafafa;
            color: #111827;
            font-size: 14px;
            padding: 15px 12px;
            border-bottom: 1px solid #e5e7eb;
            text-align: center;
            white-space: nowrap;
        }

        .warranty-table td {
            padding: 14px 12px;
            border-bottom: 1px solid #eeeeee;
            color: #374151;
            font-size: 14px;
            vertical-align: middle;
            text-align: center;
        }

        .warranty-table tr:hover {
            background: #fafafa;
        }

        .product-name {
            text-align: left !important;
            font-weight: bold;
            color: #111827;
        }

        .status-badge {
            padding: 7px 13px;
            border-radius: 18px;
            font-size: 13px;
            font-weight: bold;
            display: inline-block;
            white-space: nowrap;
            background: #e8f0ff;
            color: #2563eb;
        }

        .request-form {
            display: grid;
            grid-template-columns: 1fr 190px;
            gap: 12px;
            align-items: end;
        }

        .empty-row {
            text-align: center !important;
            padding: 30px;
            color: #6b7280;
        }

        .table-scroll {
            overflow-x: auto;
        }

        @media (max-width: 900px) {
            .warranty-wrapper {
                padding: 25px 18px;
            }

            .top-bar {
                flex-direction: column;
                align-items: flex-start;
                gap: 18px;
            }

            .search-form {
                flex-direction: column;
                align-items: stretch;
            }

            .request-form {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/header.jsp" />

<div class="warranty-wrapper">
    <div class="warranty-container">

        <div class="top-bar">
            <div class="title-box">
                <div class="title-icon">🛡️</div>
                <div>
                    <h1>Warranty & Support</h1>
                    <p>Tra cứu bảo hành và gửi yêu cầu hỗ trợ sản phẩm</p>
                </div>
            </div>

            <button type="button"
                    class="btn-dashboard"
                    onclick="window.location.href='${pageContext.request.contextPath}/Dashboard'">
                🏠 Dashboard
            </button>
        </div>

        <% if (message != null) { %>
            <div class="alert-success"><%= message %></div>
        <% } %>

        <% if (error != null) { %>
            <div class="alert-error"><%= error %></div>
        <% } %>

        <div class="search-card">
            <h2 class="card-title">Tra cứu ngày bảo hành</h2>

            <form class="search-form" action="${pageContext.request.contextPath}/warranty" method="post">
                <input type="hidden" name="action" value="search">

                <div class="form-group">
                    <label>Order ID</label>
                    <input type="number" name="orderId" placeholder="Nhập Order ID để tra cứu bảo hành..." min="1" required>
                </div>

                <button type="submit" class="btn-search">
                    Search Warranty
                </button>
            </form>
        </div>

        <% if (warrantyProducts != null && !warrantyProducts.isEmpty()) { %>
        <div class="table-card">
            <h2 class="card-title">Sản phẩm trong đơn hàng</h2>

            <div class="table-scroll">
                <table class="warranty-table">
                    <thead>
                        <tr>
                            <th>Order Detail ID</th>
                            <th>Product ID</th>
                            <th>Product Name</th>
                            <th>Order Date</th>
                            <th>Warranty Months</th>
                            <th>Warranty End Date</th>
                            <th>Request Content</th>
                            <th>Action</th>
                        </tr>
                    </thead>

                    <tbody>
                    <%
                        for (Warranty w : warrantyProducts) {
                    %>
                        <tr>
                            <td><%= w.getOrderDetailId() %></td>
                            <td><%= w.getProductId() %></td>
                            <td class="product-name"><%= w.getProductName() %></td>
                            <td><%= w.getOrderDate() %></td>
                            <td><%= w.getWarrantyMonths() %></td>
                            <td><%= w.getWarrantyEndDate() %></td>

                            <td>
                                <form id="requestForm<%= w.getOrderDetailId() %>"
                                      class="request-form"
                                      action="${pageContext.request.contextPath}/warranty"
                                      method="post">
                                    <input type="hidden" name="action" value="create">
                                    <input type="hidden" name="orderDetailId" value="<%= w.getOrderDetailId() %>">
                                    <input type="hidden" name="productId" value="<%= w.getProductId() %>">

                                    <textarea class="request-textarea"
                                              name="requestContent"
                                              placeholder="Mô tả lỗi sản phẩm..."
                                              required></textarea>
                                </form>
                            </td>

                            <td>
                                <button form="requestForm<%= w.getOrderDetailId() %>"
                                        type="submit"
                                        class="btn-request">
                                    Create Request
                                </button>
                            </td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>
        <% } %>

        <div class="table-card">
            <h2 class="card-title">Yêu cầu bảo hành đã gửi</h2>

            <div class="table-scroll">
                <table class="warranty-table">
                    <thead>
                        <tr>
                            <th>Warranty ID</th>
                            <th>Order Detail ID</th>
                            <th>Product ID</th>
                            <th>Product Name</th>
                            <th>Request Date</th>
                            <th>Request Content</th>
                            <th>Status</th>
                        </tr>
                    </thead>

                    <tbody>
                    <%
                        if (myWarrantyRequests != null && !myWarrantyRequests.isEmpty()) {
                            for (Warranty w : myWarrantyRequests) {
                    %>
                        <tr>
                            <td><%= w.getWarrantyId() %></td>
                            <td><%= w.getOrderDetailId() %></td>
                            <td><%= w.getProductId() %></td>
                            <td class="product-name"><%= w.getProductName() %></td>
                            <td><%= w.getRequestDate() %></td>
                            <td><%= w.getRequest() %></td>
                            <td>
                                <span class="status-badge">
                                    <%= w.getStatusName() %>
                                </span>
                            </td>
                        </tr>
                    <%
                            }
                        } else {
                    %>
                        <tr>
                            <td colspan="7" class="empty-row">Bạn chưa gửi yêu cầu bảo hành nào.</td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>

</body>
</html>