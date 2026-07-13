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

                        <!-- Header / Filter -->
                        <form id="adminChartFilter" class="admin-chart-filter" action="RevenueServlet" method="get">
                            <label>
                                
                                <input type="date" id="fromDate" name="fromDate" value="${param.fromDate}" title="Từ ngày" required> -
                                <input type="date" id="toDate" name="toDate" value="${param.toDate}" title="Đến ngày" required>
                            </label>
                            <select name="type" style="height: 40px; border-radius: 8px; font-size: 13px; font-weight: 800; padding: 0 12px; border: 1px solid #d8dee9; background: #ffffff; color: #111827; outline: none; font-family: inherit;">
                                <option value="day" ${param.type=='day' ? 'selected' : '' }>Ngày</option>
                                <option value="month" ${param.type=='month' ? 'selected' : '' }>Tháng</option>
                                <option value="year" ${param.type=='year' ? 'selected' : '' }>Năm</option>
                            </select>
                            <button type="submit">Xem báo cáo</button>
                            <button type="submit" formaction="RevenueExportServlet" style="background: #16a34a;">Xuất Excel</button>
                        </form>

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
                                                    <td colspan="5"
                                                        style="text-align: center; padding: 30px; color: #64748b; font-weight: 600;">
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
                                                        <td>${r.formattedRevenue}</td>
                                                        <td>${r.formattedAverage}</td>
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

            <jsp:include page="/includes/footer.jsp" />

            <script>
                document.addEventListener("DOMContentLoaded", function () {
                    const fromDateInput = document.getElementById('fromDate');
                    const toDateInput = document.getElementById('toDate');
                    const form = document.getElementById('adminChartFilter');
                    
                    // Get today's date in YYYY-MM-DD format based on local time
                    const today = new Date();
                    const todayFormatted = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
                    
                    // Set max date to today for both inputs
                    if (fromDateInput && toDateInput) {
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

                        // Initial state on load
                        updateToDateState();
                        
                        if (form) {
                            form.addEventListener('submit', function(e) {
                                const fromVal = fromDateInput.value;
                                const toVal = toDateInput.value;
                                
                                if (!fromVal) {
                                    e.preventDefault();
                                    alert('Vui lòng nhập đúng định dạng Từ ngày!');
                                    fromDateInput.focus();
                                    return;
                                }
                                
                                if (!toVal) {
                                    e.preventDefault();
                                    alert('Vui lòng nhập đúng định dạng Đến ngày!');
                                    toDateInput.focus();
                                    return;
                                }
                                
                                if (fromVal > todayFormatted || toVal > todayFormatted) {
                                    e.preventDefault();
                                    alert('Ngày được chọn không được vượt quá ngày hiện tại!');
                                    return;
                                }
                                
                                if (fromVal > toVal) {
                                    e.preventDefault();
                                    alert('Từ ngày không được lớn hơn Đến ngày!');
                                    return;
                                }
                            });
                        }
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
                const fromInput = document.getElementById('fromDate');
                const toInput = document.getElementById('toDate');
                const dateError = document.getElementById('dateError');
                const chartFilter = document.getElementById('adminChartFilter');
                const dateRegex = /^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])-\d{4}$/;

                function validateInput(e) {
                    const val = e.target.value.trim();
                    if (val && !dateRegex.test(val)) {
                        e.target.style.borderColor = '#e11d2e';
                        dateError.style.display = 'block';
                    } else {
                        e.target.style.borderColor = '';
                        dateError.style.display = 'none';
                    }
                }

                fromInput.addEventListener('blur', validateInput);
                toInput.addEventListener('blur', validateInput);

                chartFilter.addEventListener('submit', function (e) {
                    const fromVal = fromInput.value.trim();
                    const toVal = toInput.value.trim();
                    let valid = true;

                    if (fromVal && !dateRegex.test(fromVal)) {
                        fromInput.style.borderColor = '#e11d2e';
                        valid = false;
                    }
                    if (toVal && !dateRegex.test(toVal)) {
                        toInput.style.borderColor = '#e11d2e';
                        valid = false;
                    }

                    if (!valid) {
                        e.preventDefault();
                        dateError.style.display = 'block';
                    }
                });
            </script>

        </body>

        </html>