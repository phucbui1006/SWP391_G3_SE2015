<%-- 
    Document   : warranty-manage
    Created on : Jun 7, 2026, 8:35:22 PM
    Author     : Admin
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="model.Warranty" %>

<%
    ArrayList<Warranty> warrantyList =
            (ArrayList<Warranty>) request.getAttribute("warrantyList");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Warranty Management</title>

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
            background: #f5f6fa;
            min-height: calc(100vh - 120px);
            padding: 35px 55px;
        }

        .warranty-container {
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
            font-size: 26px;
            font-weight: bold;
            color: #111827;
        }

        .table-card {
            background: white;
            border-radius: 12px;
            padding: 22px;
            border: 1px solid #e5e7eb;
            box-shadow: 0 4px 14px rgba(0,0,0,0.07);
            overflow-x: auto;
        }

        .card-title {
            margin: 0 0 20px;
            color: #111827;
            font-size: 20px;
        }

        .warranty-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1150px;
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
            text-align: center;
            vertical-align: middle;
        }

        .warranty-table tr:hover {
            background: #fafafa;
        }

        .text-left {
            text-align: left !important;
        }

        .product-name {
            font-weight: bold;
            color: #111827;
        }

        .request-content {
            max-width: 260px;
            line-height: 1.4;
            color: #4b5563;
        }

        .status-badge {
            padding: 7px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
            display: inline-block;
            white-space: nowrap;
        }

        .status-pending {
            background: #ffedd5;
            color: #ea580c;
        }

        .status-processing {
            background: #dbeafe;
            color: #2563eb;
        }

        .status-rejected {
            background: #fee2e2;
            color: #dc2626;
        }

        .status-completed {
            background: #dcfce7;
            color: #16a34a;
        }

        .status-select {
            height: 38px;
            border: 1px solid #d1d5db;
            border-radius: 7px;
            padding: 0 10px;
            background: white;
            outline: none;
        }

        .btn-update {
            background: #2563eb;
            color: white;
            border: none;
            height: 38px;
            padding: 0 16px;
            border-radius: 7px;
            cursor: pointer;
            font-weight: bold;
            margin-left: 8px;
        }

        .btn-update:hover {
            background: #1d4ed8;
        }

        .update-form {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 6px;
        }

        .empty-row {
            text-align: center !important;
            padding: 35px;
            color: #6b7280;
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

            .summary-box {
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
                <div class="title-icon">🛠️</div>
                <div>
                    <h1>Warranty Management</h1>
                    <p>Quản lý và cập nhật yêu cầu bảo hành của khách hàng</p>
                </div>
            </div>

            <div class="top-actions">
                <button type="button"
                        class="btn-dashboard"
                        onclick="window.location.href='${pageContext.request.contextPath}/Dashboard'">
                    🏠 Dashboard
                </button>
            </div>
        </div>

        <%
            int total = warrantyList == null ? 0 : warrantyList.size();
            int pending = 0;
            int processing = 0;
            int rejected = 0;
            int completed = 0;

            if (warrantyList != null) {
                for (Warranty w : warrantyList) {
                    if (w.getStatusId() == 1) {
                        pending++;
                    } else if (w.getStatusId() == 2) {
                        processing++;
                    } else if (w.getStatusId() == 3) {
                        rejected++;
                    } else if (w.getStatusId() == 4) {
                        completed++;
                    }
                }
            }
        %>

        <div class="summary-box">
            <div class="summary-card">
                <h3>Total Requests</h3>
                <p><%= total %></p>
            </div>

            <div class="summary-card">
                <h3>Pending</h3>
                <p><%= pending %></p>
            </div>

            <div class="summary-card">
                <h3>Processing</h3>
                <p><%= processing %></p>
            </div>

            <div class="summary-card">
                <h3>Completed</h3>
                <p><%= completed %></p>
            </div>
        </div>

        <div class="table-card">
            <h2 class="card-title">Danh sách yêu cầu bảo hành</h2>

            <table class="warranty-table">
                <thead>
                    <tr>
                        <th>Warranty ID</th>
                        <th>Customer</th>
                        <th>Product</th>
                        <th>Request Date</th>
                        <th>Request Content</th>
                        <th>Current Status</th>
                        <th>Update Status</th>
                    </tr>
                </thead>

                <tbody>
                <%
                    if (warrantyList != null && !warrantyList.isEmpty()) {
                        for (Warranty w : warrantyList) {
                            String statusClass = "status-pending";

                            if (w.getStatusId() == 2) {
                                statusClass = "status-processing";
                            } else if (w.getStatusId() == 3) {
                                statusClass = "status-rejected";
                            } else if (w.getStatusId() == 4) {
                                statusClass = "status-completed";
                            }
                %>

                    <tr>
                        <td><%= w.getWarrantyId() %></td>

                        <td><%= w.getCustomerName() %></td>

                        <td class="text-left product-name">
                            <%= w.getProductName() %>
                        </td>

                        <td><%= w.getRequestDate() %></td>

                        <td class="text-left request-content">
                            <%= w.getRequest() %>
                        </td>

                        <td>
                            <span class="status-badge <%= statusClass %>">
                                <%= w.getStatusName() %>
                            </span>
                        </td>

                        <td>
                            <form class="update-form"
                                  action="${pageContext.request.contextPath}/warranty-manage"
                                  method="post">

                                <input type="hidden"
                                       name="warrantyId"
                                       value="<%= w.getWarrantyId() %>">

                                <select name="statusId" class="status-select">
                                    <option value="1" <%= w.getStatusId() == 1 ? "selected" : "" %>>
                                        Pending
                                    </option>

                                    <option value="2" <%= w.getStatusId() == 2 ? "selected" : "" %>>
                                        Processing
                                    </option>

                                    <option value="3" <%= w.getStatusId() == 3 ? "selected" : "" %>>
                                        Rejected
                                    </option>

                                    <option value="4" <%= w.getStatusId() == 4 ? "selected" : "" %>>
                                        Completed
                                    </option>
                                </select>

                                <button type="submit" class="btn-update">
                                    Update
                                </button>
                            </form>
                        </td>
                    </tr>

                <%
                        }
                    } else {
                %>

                    <tr>
                        <td colspan="7" class="empty-row">
                            Không có yêu cầu bảo hành nào.
                        </td>
                    </tr>

                <%
                    }
                %>
                </tbody>
            </table>
        </div>

    </div>
</div>

</body>
</html>