<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    boolean isSuccess = Boolean.TRUE.equals(request.getAttribute("isSuccess"));
    String message = String.valueOf(request.getAttribute("message"));
    Object orderIdObj = request.getAttribute("orderId");
    Object amountObj = request.getAttribute("amount");
    String bankCode = String.valueOf(request.getAttribute("bankCode") != null ? request.getAttribute("bankCode") : "");
    String transactionNo = String.valueOf(request.getAttribute("transactionNo") != null ? request.getAttribute("transactionNo") : "");

    int orderId = orderIdObj instanceof Integer ? (Integer) orderIdObj : -1;
    BigDecimal amount = amountObj instanceof BigDecimal ? (BigDecimal) amountObj : BigDecimal.ZERO;

    Locale vietnameseLocale = new Locale("vi", "VN");
    NumberFormat currencyFormatter = NumberFormat.getNumberInstance(vietnameseLocale);
    currencyFormatter.setMinimumFractionDigits(0);
    currencyFormatter.setMaximumFractionDigits(0);
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Kết quả thanh toán</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
        <style>
            .vnpay-result-container {
                max-width: 600px;
                margin: 60px auto;
                padding: 0 20px;
            }
            .result-card {
                background: #ffffff;
                border-radius: 16px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
                padding: 40px;
                text-align: center;
                border: 1px solid #eef2f5;
            }
            .icon-wrapper {
                width: 80px;
                height: 80px;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 24px;
            }
            .icon-success {
                background-color: #e6f6ec;
                color: #24b47e;
            }
            .icon-failure {
                background-color: #fde8e8;
                color: #f05252;
            }
            .icon-wrapper svg {
                width: 40px;
                height: 40px;
            }
            .result-title {
                font-size: 24px;
                font-weight: 700;
                margin-bottom: 12px;
                color: #1a1f36;
            }
            .result-message {
                font-size: 16px;
                color: #697386;
                margin-bottom: 30px;
                line-height: 1.6;
            }
            .details-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 30px;
                text-align: left;
            }
            .details-table th, .details-table td {
                padding: 14px 16px;
                border-bottom: 1px solid #eef2f5;
                font-size: 15px;
            }
            .details-table th {
                color: #8792a2;
                font-weight: 500;
                width: 45%;
            }
            .details-table td {
                color: #1a1f36;
                font-weight: 600;
            }
            .action-buttons {
                display: flex;
                gap: 16px;
                justify-content: center;
                flex-wrap: wrap;
            }
            .btn {
                padding: 12px 24px;
                border-radius: 8px;
                font-size: 15px;
                font-weight: 600;
                text-decoration: none;
                transition: all 0.2s ease;
                display: inline-block;
                cursor: pointer;
            }
            .btn-primary {
                background-color: #0066cc;
                color: #ffffff;
                border: 1px solid #0066cc;
            }
            .btn-primary:hover {
                background-color: #0052a3;
                border-color: #0052a3;
            }
            .btn-secondary {
                background-color: #ffffff;
                color: #4f566b;
                border: 1px solid #d9dce1;
            }
            .btn-secondary:hover {
                background-color: #f7f8fa;
                border-color: #c1c9d2;
            }
        </style>
    </head>
    <body class="checkout-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="vnpay-result-container">
            <div class="result-card">
                <% if (isSuccess) { %>
                    <div class="icon-wrapper icon-success">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5" />
                        </svg>
                    </div>
                    <h1 class="result-title" style="color: #24b47e;">Thanh toán thành công</h1>
                <% } else { %>
                    <div class="icon-wrapper icon-failure">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </div>
                    <h1 class="result-title" style="color: #f05252;">Thanh toán thất bại</h1>
                <% } %>

                <p class="result-message"><%= message %></p>

                <% if (orderId != -1) { %>
                <table class="details-table">
                    <tbody>
                        <tr>
                            <th>Mã đơn hàng</th>
                            <td>#<%= orderId %></td>
                        </tr>
                        <% if (isSuccess) { %>
                        <tr>
                            <th>Số tiền thanh toán</th>
                            <td style="color: #0066cc;"><%= currencyFormatter.format(amount) %>₫</td>
                        </tr>
                        <tr>
                            <th>Ngân hàng thanh toán</th>
                            <td><%= bankCode %></td>
                        </tr>
                        <tr>
                            <th>Mã giao dịch VNPAY</th>
                            <td><%= transactionNo %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>

                <div class="action-buttons">
                    <a href="${pageContext.request.contextPath}/order-history?selectedOrderId=<%= orderId %>" class="btn btn-primary">Xem chi tiết đơn hàng</a>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">Quay lại trang chủ</a>
                </div>
            </div>
        </main>
    </body>
</html>
