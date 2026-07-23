<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>

<head>
    <meta charset="UTF-8">
    <title>Thống kê doanh thu</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>

<body class="dashboard-body">

    <jsp:include page="/includes/header.jsp" />

    <div class="dashboard-content">
        <div class="dashboard-card admin-shell">
            <div class="admin-dashboard">
                <nav class="site-breadcrumb" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/Dashboard">Dashboard</a>
                    <span>›</span>
                    <strong>Thống kê doanh thu</strong>
                </nav>

                <h1>Thống kê doanh thu</h1>

                <!-- Header / Filter -->
                <form id="adminChartFilter" class="admin-chart-filter" action="${pageContext.request.contextPath}/RevenueServlet" method="get">
                    <label>
                        <input type="date" id="fromDate" name="fromDate" value="${param.fromDate}" title="Từ" required> -
                        <input type="date" id="toDate" name="toDate" value="${param.toDate}" title="Đến" required>
                    </label>

                    <button type="submit">Xem báo cáo</button>
                    <button type="submit" formaction="${pageContext.request.contextPath}/RevenueExportServlet" style="background: #16a34a;">Xuất Excel</button>
                </form>

                <!-- Summary Cards -->
                <div class="admin-stat-grid" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 16px; margin-bottom: 24px;">
                    <a class="admin-stat-card">
                        <span class="admin-stat-icon green"><i class="fa-solid fa-coins"></i></span>
                        <span>
                            <small>Tổng doanh thu</small>
                            <strong>${not empty totalRevenue ? totalRevenue : '0'}</strong>
                        </span>
                    </a>
                    <a class="admin-stat-card">
                        <span class="admin-stat-icon orange" style="background-color: #fff7ed; color: #ea580c;"><i class="fa-solid fa-file-invoice-dollar"></i></span>
                        <span>
                            <small>Vốn nhập hàng</small>
                            <strong>${not empty totalImportCost ? totalImportCost : '0'}</strong>
                        </span>
                    </a>

                    <a class="admin-stat-card">
                        <span class="admin-stat-icon blue"><i class="fa-solid fa-check"></i></span>
                        <span>
                            <small>Số đơn hàng thành công</small>
                            <strong>${not empty successOrders ? successOrders : '0'}</strong>
                        </span>
                    </a>
                </div>

                <!-- Financial Summary Table -->
                <div class="admin-dashboard-grid" style="grid-template-columns: 1fr;">
                    <section class="admin-panel admin-module-panel">
                        <div class="admin-panel-header">
                            <h2>Báo cáo chi tiết theo thời gian</h2>
                        </div>
                        <div style="padding: 20px; overflow-x: auto;">
                            <table class="admin-table" style="width: 100%; border-collapse: separate; border-spacing: 0;">
                                <thead>
                                    <tr style="background-color: #f8fafc; font-size: 14px;">
                                        <th style="padding: 14px 16px; font-weight: 600; text-align: center; width: 70px; border-bottom: 2px solid #e2e8f0; color: #475569;">STT</th>
                                        <th style="padding: 14px 16px; font-weight: 600; text-align: left; border-bottom: 2px solid #e2e8f0; color: #475569;">Thời gian</th>
                                        <th style="padding: 14px 16px; font-weight: 600; text-align: center; border-bottom: 2px solid #e2e8f0; color: #475569;">Số đơn thành công</th>
                                        <th style="padding: 14px 16px; font-weight: 600; text-align: center; border-bottom: 2px solid #e2e8f0; color: #475569;">Tổng SP bán ra</th>
                                        <th style="padding: 14px 16px; font-weight: 600; text-align: right; border-bottom: 2px solid #e2e8f0; color: #475569;">Doanh thu</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:set var="stt" value="0" />
                                    <c:forEach var="row" items="${revenueList}">
                                        <c:if test="${row.orderCount > 0 || row.productsSold > 0}">
                                            <c:set var="stt" value="${stt + 1}" />
                                            <tr style="transition: background-color 0.15s ease;">
                                                <td style="padding: 14px 16px; text-align: center; border-bottom: 1px solid #f1f5f9; color: #64748b;">${stt}</td>
                                                <td style="padding: 14px 16px; border-bottom: 1px solid #f1f5f9;"><strong style="color: #1e293b;">${row.label}</strong></td>
                                                <td style="padding: 14px 16px; text-align: center; border-bottom: 1px solid #f1f5f9;"><span style="display: inline-block; padding: 2px 10px; background-color: #eff6ff; color: #1d4ed8; font-weight: 600; border-radius: 12px; font-size: 13px;">${row.orderCount}</span></td>
                                                <td style="padding: 14px 16px; text-align: center; border-bottom: 1px solid #f1f5f9; color: #334155; font-weight: 500;">${row.productsSold}</td>
                                                <td style="padding: 14px 16px; text-align: right; border-bottom: 1px solid #f1f5f9; font-weight: 600; color: #16a34a; font-size: 15px;">${row.formattedRevenue}</td>
                                            </tr>
                                        </c:if>
                                    </c:forEach>
                                    <c:if test="${stt == 0}">
                                        <tr>
                                            <td colspan="5" style="text-align: center; color: #6b7280; padding: 36px 16px; font-size: 14px;">Không có phát sinh đơn hàng hay doanh thu trong khoảng thời gian đã chọn.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>

            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp" />

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const fromDateInput = document.getElementById('fromDate');
            const toDateInput = document.getElementById('toDate');
            const form = document.getElementById('adminChartFilter');
            
            // Get today's date
            const today = new Date();
            const todayFormatted = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
            
            fromDateInput.setAttribute('max', todayFormatted);
            toDateInput.setAttribute('max', todayFormatted);

            function updateToDateState() {
                if (fromDateInput.value) {
                    toDateInput.disabled = false;
                    toDateInput.setAttribute('min', fromDateInput.value);
                } else {
                    toDateInput.disabled = true;
                    if(!toDateInput.value) toDateInput.value = '';
                }
            }

            fromDateInput.addEventListener('change', updateToDateState);

            // Set values if passed back from server
            const paramFrom = '${param.fromDate}';
            const paramTo = '${param.toDate}';
            if (paramFrom) fromDateInput.value = paramFrom;
            if (paramTo) toDateInput.value = paramTo;
            updateToDateState();
            
            if (form) {
                form.addEventListener('submit', function(e) {
                    const fromVal = fromDateInput.value;
                    const toVal = toDateInput.value;
                    
                    if (!fromVal) {
                        e.preventDefault();
                        alert('Vui lòng chọn giá trị Từ!');
                        fromDateInput.focus();
                        return;
                    }
                    if (!toVal) {
                        e.preventDefault();
                        alert('Vui lòng chọn giá trị Đến!');
                        toDateInput.focus();
                        return;
                    }
                    
                    if (fromVal > toVal) {
                        e.preventDefault();
                        alert('Giá trị Từ không được lớn hơn Đến!');
                        return;
                    }

                    if (fromVal > todayFormatted || toVal > todayFormatted) {
                        e.preventDefault();
                        alert('Ngày được chọn không được vượt quá ngày hiện tại!');
                        return;
                    }
                });
            }
        });
    </script>

</body>

</html>
