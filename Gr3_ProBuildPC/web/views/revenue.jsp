<%-- 
    Document   : revenue
    Created on : Jun 7, 2026, 8:48:28 PM
    Author     : Admin
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Revenue" %>
<%@ page import="java.text.DecimalFormat" %>

<%
    ArrayList<Revenue> revenueList = (ArrayList<Revenue>) request.getAttribute("revenueList");

    Integer totalOrdersObj = (Integer) request.getAttribute("totalOrders");
    Double totalRevenueObj = (Double) request.getAttribute("totalRevenue");
    Integer totalProductsSoldObj = (Integer) request.getAttribute("totalProductsSold");
    Integer completedPaymentsObj = (Integer) request.getAttribute("completedPayments");

    int totalOrders = totalOrdersObj == null ? 0 : totalOrdersObj;
    double totalRevenue = totalRevenueObj == null ? 0 : totalRevenueObj;
    int totalProductsSold = totalProductsSoldObj == null ? 0 : totalProductsSoldObj;
    int completedPayments = completedPaymentsObj == null ? 0 : completedPaymentsObj;

    String fromDate = (String) request.getAttribute("fromDate");
    String toDate = (String) request.getAttribute("toDate");
    String paymentMethod = (String) request.getAttribute("paymentMethod");
    String paymentStatus = (String) request.getAttribute("paymentStatus");

    if (fromDate == null) fromDate = "";
    if (toDate == null) toDate = "";
    if (paymentMethod == null) paymentMethod = "";
    if (paymentStatus == null) paymentStatus = "";

    DecimalFormat df = new DecimalFormat("#,###");

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

    int totalItems = revenueList == null ? 0 : revenueList.size();
    int totalPages = (int) Math.ceil((double) totalItems / pageSize);

    if (totalPages == 0) totalPages = 1;
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages) currentPage = totalPages;

    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalItems);

    String queryString = "&fromDate=" + fromDate
            + "&toDate=" + toDate
            + "&paymentMethod=" + paymentMethod
            + "&paymentStatus=" + paymentStatus;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Revenue Management</title>

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

        .revenue-wrapper {
            background: #f5f6fa;
            min-height: calc(100vh - 120px);
            padding: 35px 55px;
        }

        .revenue-container {
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
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
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

        .btn-export {
            background: #2563eb;
            color: white;
            border: none;
            height: 44px;
            padding: 0 22px;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-export:hover {
            background: #1d4ed8;
        }

        .summary-box {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 24px;
        }

        .summary-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            border: 1px solid #e5e7eb;
            box-shadow: 0 4px 14px rgba(0,0,0,0.07);
        }

        .summary-card h3 {
            margin: 0 0 8px;
            color: #6b7280;
            font-size: 14px;
        }

        .summary-card p {
            margin: 0;
            font-size: 24px;
            font-weight: bold;
            color: #111827;
        }

        .filter-card {
            background: white;
            border-radius: 12px;
            padding: 24px;
            border: 1px solid #e5e7eb;
            box-shadow: 0 4px 14px rgba(0,0,0,0.07);
            margin-bottom: 24px;
        }

        .filter-title {
            margin: 0 0 18px;
            color: #111827;
            font-size: 20px;
        }

        .filter-form {
            display: grid;
            grid-template-columns: repeat(4, 1fr) auto auto;
            gap: 14px;
            align-items: end;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #111827;
            font-weight: bold;
            font-size: 14px;
        }

        .form-group input,
        .form-group select {
            width: 100%;
            height: 42px;
            box-sizing: border-box;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            padding: 0 12px;
            font-size: 14px;
            background: white;
        }

        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #ed1c24;
            box-shadow: 0 0 0 3px rgba(237, 28, 36, 0.12);
        }

        .btn-filter {
            background: #ed1c24;
            color: white;
            border: none;
            height: 42px;
            padding: 0 22px;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-reset {
            background: #6b7280;
            color: white;
            border: none;
            height: 42px;
            padding: 0 22px;
            border-radius: 8px;
            font-weight: bold;
            cursor: pointer;
        }

        .btn-filter:hover {
            background: #c9151c;
        }

        .btn-reset:hover {
            background: #4b5563;
        }

        .table-card {
            background: white;
            border-radius: 12px;
            padding: 22px;
            border: 1px solid #e5e7eb;
            box-shadow: 0 4px 14px rgba(0,0,0,0.07);
            overflow-x: auto;
        }

        .table-title {
            margin: 0 0 20px;
            color: #111827;
            font-size: 20px;
        }

        .revenue-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1050px;
        }

        .revenue-table th {
            background: #fafafa;
            color: #111827;
            font-size: 14px;
            padding: 15px 12px;
            border-bottom: 1px solid #e5e7eb;
            text-align: center;
            white-space: nowrap;
        }

        .revenue-table td {
            padding: 14px 12px;
            border-bottom: 1px solid #eeeeee;
            color: #374151;
            font-size: 14px;
            text-align: center;
            vertical-align: middle;
        }

        .revenue-table tr:hover {
            background: #fafafa;
        }

        .amount {
            font-weight: bold;
            color: #16a34a;
        }

        .status-badge {
            padding: 7px 13px;
            border-radius: 18px;
            font-size: 13px;
            font-weight: bold;
            display: inline-block;
            white-space: nowrap;
        }

        .status-paid {
            background: #dcfce7;
            color: #16a34a;
        }

        .status-unpaid {
            background: #fee2e2;
            color: #dc2626;
        }

        .status-pending {
            background: #ffedd5;
            color: #ea580c;
        }

        .method-badge {
            padding: 7px 13px;
            border-radius: 18px;
            font-size: 13px;
            font-weight: bold;
            background: #e8f0ff;
            color: #2563eb;
            display: inline-block;
        }

        .empty-row {
            text-align: center !important;
            padding: 35px;
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

        @media (max-width: 1000px) {
            .summary-box {
                grid-template-columns: repeat(2, 1fr);
            }

            .filter-form {
                grid-template-columns: 1fr 1fr;
            }
        }

        @media (max-width: 700px) {
            .revenue-wrapper {
                padding: 25px 18px;
            }

            .top-bar {
                flex-direction: column;
                align-items: flex-start;
                gap: 18px;
            }

            .summary-box {
                grid-template-columns: 1fr;
            }

            .filter-form {
                grid-template-columns: 1fr;
            }

            .top-actions {
                width: 100%;
            }

            .top-actions button {
                flex: 1;
            }
        }
    </style>
</head>

<body>

<jsp:include page="/includes/header.jsp" />

<div class="revenue-wrapper">
    <div class="revenue-container">

        <div class="top-bar">
            <div class="title-box">
                <div class="title-icon">📊</div>
                <div>
                    <h1>Revenue Management</h1>
                    <p>Thống kê doanh thu và xuất báo cáo doanh thu</p>
                </div>
            </div>

            <div class="top-actions">
                <button type="button"
                        class="btn-dashboard"
                        onclick="window.location.href='${pageContext.request.contextPath}/Dashboard'">
                    🏠 Dashboard
                </button>

                <form action="${pageContext.request.contextPath}/revenue" method="post">
                    <input type="hidden" name="action" value="export">
                    <input type="hidden" name="fromDate" value="<%= fromDate %>">
                    <input type="hidden" name="toDate" value="<%= toDate %>">
                    <input type="hidden" name="paymentMethod" value="<%= paymentMethod %>">
                    <input type="hidden" name="paymentStatus" value="<%= paymentStatus %>">

                    <button type="submit" class="btn-export">
                        ⬇ Export CSV
                    </button>
                </form>
            </div>
        </div>

        <div class="summary-box">
            <div class="summary-card">
                <h3>Total Orders</h3>
                <p><%= totalOrders %></p>
            </div>

            <div class="summary-card">
                <h3>Total Products Sold</h3>
                <p><%= totalProductsSold %></p>
            </div>

            <div class="summary-card">
                <h3>Total Revenue</h3>
                <p><%= df.format(totalRevenue) %> VND</p>
            </div>

            <div class="summary-card">
                <h3>Completed Payments</h3>
                <p><%= completedPayments %></p>
            </div>
        </div>

        <div class="filter-card">
            <h2 class="filter-title">Bộ lọc doanh thu</h2>

            <form class="filter-form" action="${pageContext.request.contextPath}/revenue" method="get">
                <div class="form-group">
                    <label>From Date</label>
                    <input type="date" name="fromDate" value="<%= fromDate %>">
                </div>

                <div class="form-group">
                    <label>To Date</label>
                    <input type="date" name="toDate" value="<%= toDate %>">
                </div>

                <div class="form-group">
                    <label>Payment Method</label>
                    <select name="paymentMethod">
                        <option value="" <%= paymentMethod.equals("") ? "selected" : "" %>>All Methods</option>
                        <option value="COD" <%= paymentMethod.equals("COD") ? "selected" : "" %>>COD</option>
                        <option value="VNPAY" <%= paymentMethod.equals("VNPAY") ? "selected" : "" %>>VNPAY</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Payment Status</label>
                    <select name="paymentStatus">
                        <option value="" <%= paymentStatus.equals("") ? "selected" : "" %>>All Status</option>
                        <option value="Đã thanh toán" <%= paymentStatus.equals("Đã thanh toán") ? "selected" : "" %>>Đã thanh toán</option>
                        <option value="Chưa thanh toán" <%= paymentStatus.equals("Chưa thanh toán") ? "selected" : "" %>>Chưa thanh toán</option>
                        <option value="Pending" <%= paymentStatus.equals("Pending") ? "selected" : "" %>>Pending</option>
                    </select>
                </div>

                <button type="submit" class="btn-filter">
                    View Revenue
                </button>

                <button type="button"
                        class="btn-reset"
                        onclick="window.location.href='${pageContext.request.contextPath}/revenue'">
                    Reset
                </button>
            </form>
        </div>

        <div class="table-card">
            <h2 class="table-title">Danh sách doanh thu theo đơn hàng</h2>

            <table class="revenue-table">
                <thead>
                    <tr>
                        <th>Order ID</th>
                        <th>User ID</th>
                        <th>Order Date</th>
                        <th>Payment Method</th>
                        <th>Payment Status</th>
                        <th>Total Amount</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (revenueList != null && !revenueList.isEmpty()) {
                        for (int i = startIndex; i < endIndex; i++) {
                            Revenue r = revenueList.get(i);

                            String status = r.getPaymentStatus();
                            if (status == null) status = "";

                            String statusClass = "status-pending";
                            if ("Đã thanh toán".equalsIgnoreCase(status) || "PAID".equalsIgnoreCase(status)) {
                                statusClass = "status-paid";
                            } else if ("Chưa thanh toán".equalsIgnoreCase(status) || "UNPAID".equalsIgnoreCase(status)) {
                                statusClass = "status-unpaid";
                            }
                %>

                    <tr>
                        <td><%= r.getOrderId() %></td>
                        <td><%= r.getUserId() %></td>
                        <td><%= r.getOrderDate() %></td>
                        <td>
                            <span class="method-badge">
                                <%= r.getPaymentMethod() %>
                            </span>
                        </td>
                        <td>
                            <span class="status-badge <%= statusClass %>">
                                <%= r.getPaymentStatus() %>
                            </span>
                        </td>
                        <td class="amount">
                            <%= df.format(r.getTotalAmount()) %> VND
                        </td>
                    </tr>

                <%
                        }
                    } else {
                %>

                    <tr>
                        <td colspan="6" class="empty-row">
                            Không có dữ liệu doanh thu.
                        </td>
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
                        <a class="page-btn"
                           href="${pageContext.request.contextPath}/revenue?page=<%= currentPage - 1 %><%= queryString %>">
                            ‹
                        </a>
                    <% } else { %>
                        <span class="page-btn disabled">‹</span>
                    <% } %>

                    <% for (int p = 1; p <= totalPages; p++) { %>
                        <a class="page-btn <%= p == currentPage ? "active" : "" %>"
                           href="${pageContext.request.contextPath}/revenue?page=<%= p %><%= queryString %>">
                            <%= p %>
                        </a>
                    <% } %>

                    <% if (currentPage < totalPages) { %>
                        <a class="page-btn"
                           href="${pageContext.request.contextPath}/revenue?page=<%= currentPage + 1 %><%= queryString %>">
                            ›
                        </a>
                    <% } else { %>
                        <span class="page-btn disabled">›</span>
                    <% } %>
                </div>
            </div>
        </div>

    </div>
</div>

</body>
</html>
