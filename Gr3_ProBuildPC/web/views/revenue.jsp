<%@page contentType="text/html" pageEncoding="UTF-8" %>
    <%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

        <!DOCTYPE html>
        <html>

        <head>
            <meta charset="UTF-8">
            <title>Thống kê doanh thu</title>

            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
            <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                            <button type="submit" formaction="${pageContext.request.contextPath}/RevenueExportServlet" name="exportType" value="summary" style="background: #16a34a;">Xuất Tổng hợp</button>
                            <button type="submit" formaction="${pageContext.request.contextPath}/RevenueExportServlet" name="exportType" value="detail" style="background: #2563eb;">Xuất Chi tiết</button>
                        </form>

                        <!-- Summary -->
                        <div class="admin-stat-grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
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
                                    <small>Khách mua hàng</small>
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

            <script>
                const ctx = document.getElementById("revenueChart");
                if (ctx) {
                    new Chart(ctx, {
                        type: "bar",
                        data: {
                            labels: ${ chartLabels != null ? chartLabels : '[]'},
                datasets: [{
                    label: "Doanh thu",
                    data: ${ chartData != null ? chartData : '[]'},
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

            <script>
                // Xóa phần dateRegex check thủ công do ta đã dùng type date/month/number tự nhiên của browser, 
                // việc validate format sẽ do browser đảm nhận.
            </script>

        </body>

        </html>
