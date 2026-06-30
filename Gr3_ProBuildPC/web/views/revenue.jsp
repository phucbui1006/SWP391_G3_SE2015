<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thống kê doanh thu</title>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body class="dashboard-body">

    <jsp:include page="/includes/header.jsp"/>

    <div class="dashboard-content">
        <div class="dashboard-card admin-shell">
            <div class="admin-dashboard">
                
                <!-- Header -->
                <div class="dashboard-page-heading admin-dashboard-heading" style="display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 15px;">
                    <div>
                        <h1 style="margin: 0 0 8px; font-size: 30px; font-weight: 850;">Thống kê doanh thu</h1>
                        <p style="margin: 0; color: #64748b; font-size: 14px; font-weight: 600;">Xem doanh thu theo khoảng thời gian và xuất báo cáo.</p>
                    </div>

                    <form action="RevenueServlet" method="get" style="display: flex; gap: 10px; align-items: center; margin: 0; flex-wrap: wrap;">
                        <input type="date" name="fromDate" value="${param.fromDate}" title="Từ ngày" style="height: 42px; padding: 0 14px; border: 1px solid #dbe1ea; border-radius: 8px; outline: none; font-weight: 650; font-family: inherit;">
                        <input type="date" name="toDate" value="${param.toDate}" title="Đến ngày" style="height: 42px; padding: 0 14px; border: 1px solid #dbe1ea; border-radius: 8px; outline: none; font-weight: 650; font-family: inherit;">
                        <select name="type" style="height: 42px; padding: 0 12px; border: 1px solid #dbe1ea; border-radius: 8px; outline: none; font-weight: 650; font-family: inherit;">
                            <option value="day" ${param.type == 'day' ? 'selected' : ''}>Ngày</option>
                            <option value="month" ${param.type == 'month' ? 'selected' : ''}>Tháng</option>
                            <option value="year" ${param.type == 'year' ? 'selected' : ''}>Năm</option>
                        </select>
                        <button type="submit" style="height: 42px; border-radius: 8px; background: #ef1b24; color: #ffffff; font-size: 14px; font-weight: 800; border: 0; padding: 0 16px; cursor: pointer; transition: transform 0.16s ease;">Xem</button>
                        <button formaction="RevenueExportServlet" style="height: 42px; border-radius: 8px; background: #16a34a; color: #ffffff; font-size: 14px; font-weight: 800; border: 0; padding: 0 16px; cursor: pointer; transition: transform 0.16s ease;">Xuất Excel</button>
                    </form>
                </div>

                <!-- Summary -->
                <div class="admin-stat-grid">
                    <a class="admin-stat-card">
                        <span class="admin-stat-icon green"><i class="fa-solid fa-coins"></i></span>
                        <span>
                            <small>Tổng doanh thu</small>
                            <strong>${not empty totalRevenue ? totalRevenue : '0'}</strong>
                        </span>
                    </a>
                    <a class="admin-stat-card">
                        <span class="admin-stat-icon blue"><i class="fa-solid fa-boxes-stacked"></i></span>
                        <span>
                            <small>Tổng đơn hàng</small>
                            <strong>${not empty totalOrders ? totalOrders : '0'}</strong>
                        </span>
                    </a>
                    <a class="admin-stat-card">
                        <span class="admin-stat-icon purple"><i class="fa-solid fa-check"></i></span>
                        <span>
                            <small>Đơn thành công</small>
                            <strong>${not empty successOrders ? successOrders : '0'}</strong>
                        </span>
                    </a>
                    <a class="admin-stat-card">
                        <span class="admin-stat-icon orange"><i class="fa-solid fa-users"></i></span>
                        <span>
                            <small>Khách hàng</small>
                            <strong>${not empty totalCustomers ? totalCustomers : '0'}</strong>
                        </span>
                    </a>
                </div>

                <!-- Chart -->
                <div class="admin-dashboard-grid" style="grid-template-columns: 1fr;">
                    <section class="admin-panel admin-module-panel">
                        <div class="admin-panel-header">
                            <h2>Biểu đồ doanh thu</h2>
                        </div>
                        <div style="padding: 20px;">
                            <canvas id="revenueChart" height="100"></canvas>
                        </div>
                    </section>
                </div>

                <!-- Table -->
                <div class="admin-dashboard-grid" style="grid-template-columns: 1fr; margin-top: 18px;">
                    <section class="admin-panel">
                        <div class="admin-panel-header">
                            <h2>Chi tiết doanh thu</h2>
                        </div>
                        <table class="admin-dashboard-table">
                            <thead>
                                <tr>
                                    <th>STT</th>
                                    <th>Thời gian</th>
                                    <th>Số đơn</th>
                                    <th>Doanh thu</th>
                                    <th>TB/Đơn</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty revenueList}">
                                        <tr>
                                            <td colspan="5" style="text-align: center; padding: 30px; color: #64748b; font-weight: 600;">
                                                Chưa có dữ liệu.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach items="${revenueList}" var="r" varStatus="loop">
                                            <tr>
                                                <td>${loop.index+1}</td>
                                                <td>${r.label}</td>
                                                <td>${r.orderCount}</td>
                                                <td>${r.revenue}</td>
                                                <td>${r.average}</td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </section>
                </div>

            </div>
        </div>
    </div>

    <jsp:include page="/includes/footer.jsp"/>

<script>
const ctx = document.getElementById("revenueChart");
if(ctx) {
    new Chart(ctx, {
        type: "bar",
        data: {
            labels: ["T1", "T2", "T3", "T4", "T5", "T6"],
            datasets: [{
                label: "Doanh thu",
                data: [20, 35, 18, 45, 39, 55],
                backgroundColor: '#1d5edb',
                borderRadius: 4
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });
}
</script>
</body>
</html>