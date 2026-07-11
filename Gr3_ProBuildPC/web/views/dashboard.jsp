<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.AdminDashboardView" %>
<%@ page import="model.EmployeeDashboardView" %>
<%@ page import="model.ShipmentDashboardView" %>
<%@ page import="util.DashboardViewHelper" %>

<%
    User account = (User) session.getAttribute("account");

    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/Login");
        return;
    }

    String roleName = account.getRoleName();
    if (roleName != null) {
        roleName = roleName.trim().toUpperCase();
    } else {
        roleName = "";
    }

    String ctx = request.getContextPath();
    final int ADMIN_TABLE_ROWS = 5;
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Dashboard</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body class="dashboard-body">

        <jsp:include page="/includes/header.jsp" />

        <div class="dashboard-content">
            <div class="dashboard-card <%= "ADMIN".equals(roleName) ? "admin-shell" : ("EMPLOYEE".equals(roleName) ? "employee-shell" : ("SHIPMENT".equals(roleName) ? "shipment-shell" : "")) %>">

                <% if ("ADMIN".equals(roleName)) {
                    AdminDashboardView adminDashboard = (AdminDashboardView) request.getAttribute("adminDashboard");
                %>

                <div class="admin-dashboard">
                    <form id="adminChartFilter" class="admin-chart-filter" action="<%= adminDashboard.getFormAction() %>" method="get">
                        <label>
                            <input type="date" name="chartFrom" value="<%= adminDashboard.getChartStartDate() %>" required> -
                            <input type="date" name="chartTo" value="<%= adminDashboard.getChartEndDate() %>" required>
                        </label>
                        <button type="submit">Xem</button>
                    </form>

                    <div class="admin-stat-grid" >
                        <% for (AdminDashboardView.StatCard stat : adminDashboard.getStatCards()) { %>
                        <a class="admin-stat-card" href="<%= stat.getUrl() %>">
                            <span class="admin-stat-icon <%= stat.getIconClass() %>"><i class="<%= stat.getIcon() %>"></i></span>
                            <span>
                                <small><%= stat.getLabel() %></small>
                                <strong><%= stat.getValue() %></strong>
                            </span>
                        </a>
                        <% } %>
                    </div>

                    <div id="revenueCharts" class="admin-dashboard-grid admin-chart-grid">
                        <section class="admin-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <div>
                                    <h2>Biểu đồ doanh thu theo thời gian</h2>
                                    <p class="admin-chart-period"><%= adminDashboard.getChartPeriodLabel() %></p>
                                </div>
                            </div>
                            <div class="admin-chart-body">
                                <canvas id="revenueTimelineChart" aria-label="Biểu đồ đường doanh thu theo thời gian"></canvas>
                            </div>
                        </section>

                        <section class="admin-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <div>
                                    <h2>Cơ cấu doanh thu theo danh mục</h2>
                                    <p class="admin-chart-period"><%= adminDashboard.getChartPeriodLabel() %></p>
                                </div>
                            </div>
                            <div class="admin-chart-body admin-pie-chart-body">
                                <% if (adminDashboard.getCategoryRevenue().isEmpty()) { %>
                                <p class="admin-empty-message">Chưa có doanh thu theo danh mục trong khoảng thời gian này.</p>
                                <% } else { %>
                                <canvas id="categoryRevenueChart" aria-label="Biểu đồ tròn doanh thu theo danh mục"></canvas>
                                <% } %>
                            </div>
                        </section>
                    </div>

                    <div class="admin-dashboard-grid admin-products-grid">
                        <section class="admin-panel admin-module-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <h2>Top 5 sản phẩm bán chạy nhất</h2>
                            </div>

                            <div class="admin-chart-body">
                                <% if (adminDashboard.getBestSellingProducts().isEmpty()) { %>
                                <p class="admin-empty-message">Chưa có sản phẩm bán ra trong khoảng thời gian này.</p>
                                <% } else { %>
                                <canvas id="bestSellingProductsChart" aria-label="Biểu đồ thanh ngang top 5 sản phẩm bán chạy nhất"></canvas>
                                <% } %>
                            </div>
                            <div class="admin-panel-footer">
                                <span><%= adminDashboard.getBestSellingFooterMessage() != null
                                        ? adminDashboard.getBestSellingFooterMessage()
                                        : "Mở trang quản lý toàn bộ sản phẩm." %></span>
                                <a href="<%= ctx %>/admin/products">Xem tất cả</a>
                            </div>
                        </section>

                        <aside class="admin-panel admin-quick-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <h2>Sản phẩm mức tồn kho thấp (&lt;5)</h2>
                            </div>
                            <div class="admin-chart-body">
                                <% if (adminDashboard.getLowStockProducts().isEmpty()) { %>
                                <p class="admin-empty-message">Không có sản phẩm nào sắp hết hàng.</p>
                                <% } else { %>
                                <canvas id="lowStockProductsChart" aria-label="Biểu đồ sản phẩm tồn kho thấp"></canvas>
                                <% } %>
                            </div>
                            <div class="admin-panel-footer">
                                <span><%= adminDashboard.getLowStockFooterMessage() != null
                                        ? adminDashboard.getLowStockFooterMessage()
                                        : "Danh sách sản phẩm theo tồn kho tăng dần." %></span>
                                <a href="<%= ctx %>/admin/products?sort=qty_asc">Xem tất cả</a>
                            </div>
                        </aside>
                    </div>

                    <div class="admin-dashboard-grid admin-bottom-grid">
                        <section class="admin-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <div>
                                    <h2>Thống kê về đơn hàng</h2>
                                    <p class="admin-chart-period"><%= adminDashboard.getChartPeriodLabel() %></p>
                                </div>
                            </div>

                            <div class="admin-chart-body admin-order-status-chart-body">
                                <% if (adminDashboard.getOrderStatusCounts().isEmpty()) { %>
                                <p class="admin-empty-message">Không có đơn hàng trong khoảng thời gian đã chọn.</p>
                                <% } else { %>
                                <canvas id="orderStatusChart" aria-label="Biểu đồ số lượng đơn hàng theo trạng thái"></canvas>
                                <% } %>
                            </div>
                            <div class="admin-panel-footer">
                                <span>Quản lý và theo dõi toàn bộ đơn hàng.</span>
                                <a href="<%= ctx %>/order-history">Xem tất cả</a>
                            </div>
                        </section>

                        <section class="admin-panel">
                            <div class="admin-panel-header">
                                <h2>Tổng quan tài khoản</h2>
                            </div>

                            <div class="admin-account-grid">
                                <% for (AdminDashboardView.CountRow accountRow : adminDashboard.getAccountSummaries()) { %>
                                <div><span><%= accountRow.getLabel() %></span><strong><%= accountRow.getValue() %></strong></div>
                                <% } %>
                            </div>
                            <div class="admin-panel-footer">
                                <span><a href="<%= ctx %>/AccountManagement?type=user">Quản lý khách hàng</a></span>
                                <a href="<%= ctx %>/AccountManagement?type=staff">Quản lý nhân viên</a>
                            </div>
                        </section>
                    </div>

                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js"></script>
                    <script>
                        (() => {
                            const timelineLabels = [
                                <% for (int i = 0; i < adminDashboard.getRevenueTimeline().size(); i++) {
                                    AdminDashboardView.ChartPoint point = adminDashboard.getRevenueTimeline().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(point.getLabel()) %>
                                <% } %>
                            ];
                            const timelineValues = [
                                <% for (int i = 0; i < adminDashboard.getRevenueTimeline().size(); i++) {
                                    AdminDashboardView.ChartPoint point = adminDashboard.getRevenueTimeline().get(i); %>
                                <%= i > 0 ? "," : "" %><%= point.getValue().toPlainString() %>
                                <% } %>
                            ];
                            const categoryLabels = [
                                <% for (int i = 0; i < adminDashboard.getCategoryRevenue().size(); i++) {
                                    AdminDashboardView.ChartPoint point = adminDashboard.getCategoryRevenue().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(point.getLabel()) %>
                                <% } %>
                            ];
                            const categoryValues = [
                                <% for (int i = 0; i < adminDashboard.getCategoryRevenue().size(); i++) {
                                    AdminDashboardView.ChartPoint point = adminDashboard.getCategoryRevenue().get(i); %>
                                <%= i > 0 ? "," : "" %><%= point.getValue().toPlainString() %>
                                <% } %>
                            ];
                            const bestSellingLabels = [
                                <% for (int i = 0; i < adminDashboard.getBestSellingProducts().size(); i++) {
                                    AdminDashboardView.ProductRow product = adminDashboard.getBestSellingProducts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(product.getProductName()) %>
                                <% } %>
                            ];
                            const bestSellingValues = [
                                <% for (int i = 0; i < adminDashboard.getBestSellingProducts().size(); i++) {
                                    AdminDashboardView.ProductRow product = adminDashboard.getBestSellingProducts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= product.getSoldQuantity() %>
                                <% } %>
                            ];
                            const lowStockLabels = [
                                <% for (int i = 0; i < adminDashboard.getLowStockProductsChart().size(); i++) {
                                    AdminDashboardView.ChartPoint point = adminDashboard.getLowStockProductsChart().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(point.getLabel()) %>
                                <% } %>
                            ];
                            const lowStockValues = [
                                <% for (int i = 0; i < adminDashboard.getLowStockProductsChart().size(); i++) {
                                    AdminDashboardView.ChartPoint point = adminDashboard.getLowStockProductsChart().get(i); %>
                                <%= i > 0 ? "," : "" %><%= point.getValue().toPlainString() %>
                                <% } %>
                            ];
                            const orderStatusLabels = [
                                <% for (int i = 0; i < adminDashboard.getOrderStatusCounts().size(); i++) {
                                    AdminDashboardView.ChartPoint point = adminDashboard.getOrderStatusCounts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(point.getLabel()) %>
                                <% } %>
                            ];
                            const orderStatusValues = [
                                <% for (int i = 0; i < adminDashboard.getOrderStatusCounts().size(); i++) {
                                    AdminDashboardView.ChartPoint point = adminDashboard.getOrderStatusCounts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= point.getValue().toPlainString() %>
                                <% } %>
                            ];

                            const formatCurrency = value =>
                                new Intl.NumberFormat('vi-VN').format(value) + ' ₫';
                            const formatOrderCount = value =>
                                new Intl.NumberFormat('vi-VN').format(value) + ' đơn';
                            const formatProductCount = value =>
                                new Intl.NumberFormat('vi-VN').format(value) + ' sản phẩm';
                            const commonTooltip = {
                                callbacks: {
                                    label: context => context.dataset.label
                                        ? context.dataset.label + ': ' + formatCurrency(context.parsed.y)
                                        : context.label + ': ' + formatCurrency(context.parsed)
                                }
                            };

                            new Chart(document.getElementById('revenueTimelineChart'), {
                                type: 'line',
                                data: {
                                    labels: timelineLabels,
                                    datasets: [{
                                        label: 'Doanh thu',
                                        data: timelineValues,
                                        borderColor: '#dc2626',
                                        backgroundColor: 'rgba(220, 38, 38, 0.12)',
                                        pointBackgroundColor: '#dc2626',
                                        pointRadius: 4,
                                        pointHoverRadius: 6,
                                        borderWidth: 3,
                                        tension: 0.35,
                                        fill: true
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    plugins: {
                                        legend: {display: false},
                                        tooltip: commonTooltip
                                    },
                                    scales: {
                                        y: {
                                            beginAtZero: true,
                                            ticks: {callback: value => formatCurrency(value)},
                                            grid: {color: '#eef2f7'}
                                        },
                                        x: {grid: {display: false}}
                                    }
                                }
                            });

                            const categoryCanvas = document.getElementById('categoryRevenueChart');
                            if (categoryCanvas) {
                                const colors = [
                                    '#dc2626', '#2563eb', '#16a34a', '#f59e0b', '#7c3aed',
                                    '#0891b2', '#db2777', '#65a30d', '#ea580c', '#475569'
                                ];
                                new Chart(categoryCanvas, {
                                    type: 'pie',
                                    data: {
                                        labels: categoryLabels,
                                        datasets: [{
                                            data: categoryValues,
                                            backgroundColor: categoryLabels.map((_, index) =>
                                                colors[index % colors.length]),
                                            borderColor: '#ffffff',
                                            borderWidth: 2
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                position: 'bottom',
                                                labels: {usePointStyle: true, padding: 16}
                                            },
                                            tooltip: commonTooltip
                                        }
                                    }
                                });
                            }

                            const bestSellingCanvas = document.getElementById('bestSellingProductsChart');
                            if (bestSellingCanvas) {
                                new Chart(bestSellingCanvas, {
                                    type: 'bar',
                                    data: {
                                        labels: bestSellingLabels,
                                        datasets: [{
                                            label: 'Đã bán',
                                            data: bestSellingValues,
                                            backgroundColor: '#dc2626',
                                            borderRadius: 8,
                                            maxBarThickness: 34
                                        }]
                                    },
                                    options: {
                                        indexAxis: 'y',
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {display: false},
                                            tooltip: {
                                                callbacks: {
                                                    label: context => formatProductCount(context.parsed.x)
                                                }
                                            }
                                        },
                                        scales: {
                                            x: {
                                                beginAtZero: true,
                                                ticks: {
                                                    precision: 0,
                                                    callback: value => new Intl.NumberFormat('vi-VN').format(value)
                                                },
                                                grid: {color: '#eef2f7'}
                                            },
                                            y: {grid: {display: false}}
                                        }
                                    }
                                });
                            }
                            
                            const lowStockCanvas = document.getElementById('lowStockProductsChart');
                            if (lowStockCanvas) {
                                new Chart(lowStockCanvas, {
                                    type: 'bar',
                                    data: {
                                        labels: lowStockLabels,
                                        datasets: [{
                                            label: 'Tồn kho',
                                            data: lowStockValues,
                                            backgroundColor: '#f59e0b',
                                            borderRadius: 8,
                                            maxBarThickness: 34
                                        }]
                                    },
                                    options: {
                                        indexAxis: 'y',
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {display: false},
                                            tooltip: {
                                                callbacks: {
                                                    label: context => 'Tồn kho: ' + formatProductCount(context.parsed.x)
                                                }
                                            }
                                        },
                                        scales: {
                                            x: {
                                                beginAtZero: true,
                                                ticks: {
                                                    precision: 0,
                                                    callback: value => new Intl.NumberFormat('vi-VN').format(value)
                                                },
                                                grid: {color: '#eef2f7'}
                                            },
                                            y: {grid: {display: false}}
                                        }
                                    }
                                });
                            }

                            const orderStatusCanvas = document.getElementById('orderStatusChart');
                            if (orderStatusCanvas) {
                                const statusColors = [
                                    '#2563eb', '#16a34a', '#f59e0b', '#dc2626', '#7c3aed',
                                    '#0891b2', '#db2777', '#65a30d', '#ea580c', '#475569'
                                ];
                                new Chart(orderStatusCanvas, {
                                    type: 'bar',
                                    data: {
                                        labels: orderStatusLabels,
                                        datasets: [{
                                            label: 'Số lượng đơn hàng',
                                            data: orderStatusValues,
                                            backgroundColor: orderStatusLabels.map((_, index) =>
                                                statusColors[index % statusColors.length]),
                                            borderRadius: 8,
                                            maxBarThickness: 44
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {display: false},
                                            tooltip: {
                                                callbacks: {
                                                    label: context => formatOrderCount(context.parsed.y)
                                                }
                                            }
                                        },
                                        scales: {
                                            y: {
                                                beginAtZero: true,
                                                ticks: {
                                                    precision: 0,
                                                    callback: value => new Intl.NumberFormat('vi-VN').format(value)
                                                },
                                                grid: {color: '#eef2f7'}
                                            },
                                            x: {grid: {display: false}}
                                        }
                                    }
                                });
                            }
                        })();
                    </script>
                </div>


                <% } else if ("EMPLOYEE".equals(roleName)) { %>

                <%
                    EmployeeDashboardView employeeDashboard = (EmployeeDashboardView) request.getAttribute("employeeDashboard");
                %>

                <div class="employee-dashboard">
                    <form class="admin-chart-filter" action="<%= employeeDashboard.getFormAction() %>" method="get">
                        <label>
                            <input type="date" name="chartFrom" value="<%= employeeDashboard.getStartDate() %>" required> -
                            <input type="date" name="chartTo" value="<%= employeeDashboard.getEndDate() %>" required>
                        </label>
                        <button type="submit">Xem</button>
                    </form>

                    <div class="employee-summary-grid" aria-label="Tổng quan công việc cần xử lý">
                        <% for (EmployeeDashboardView.SummaryCard card : employeeDashboard.getSummaryCards()) { %>
                        <div class="employee-summary-card">
                            <span class="summary-icon <%= card.getIconClass() %>"><i class="<%= card.getIcon() %>"></i></span>
                            <div class="summary-copy">
                                <p class="summary-title"><%= card.getLabel() %></p>
                                <div class="summary-value-row">
                                    <span class="summary-number"><%= card.getValue() %></span>
                                    <span class="summary-unit"><%= card.getUnit() %></span>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>

                    <div id="employeeCharts" class="admin-dashboard-grid admin-bottom-grid" style="margin-top: 20px; margin-bottom: 20px;">
                        <section class="admin-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <div>
                                    <h2>Biểu đồ xử lý bảo hành</h2>
                                    <p class="admin-chart-period">
                                        <%= employeeDashboard.getStartDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %> - <%= employeeDashboard.getEndDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %>
                                        | <strong>Tổng cộng: <%= employeeDashboard.getWarrantyStatusCounts().stream().mapToInt(p -> p.getValue()).sum() %> đơn</strong>
                                    </p>
                                </div>
                            </div>
                            <div class="admin-chart-body" style="display: flex; align-items: center; justify-content: center;">
                                <% if (employeeDashboard.getWarrantyStatusCounts().stream().mapToInt(p -> p.getValue()).sum() == 0) { %>
                                <p class="admin-empty-message">Không có đơn bảo hành trong khoảng thời gian này.</p>
                                <% } else { %>
                                <canvas id="employeeWarrantyChart" aria-label="Biểu đồ xử lý bảo hành"></canvas>
                                <% } %>
                            </div>
                        </section>

                        <section class="admin-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <div>
                                    <h2>Biểu đồ quản lý đơn hàng</h2>
                                    <p class="admin-chart-period">
                                        <%= employeeDashboard.getStartDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %> - <%= employeeDashboard.getEndDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %>
                                        | <strong>Tổng cộng: <%= employeeDashboard.getOrderStatusCounts().stream().mapToInt(p -> p.getValue()).sum() %> đơn</strong>
                                    </p>
                                </div>
                            </div>
                            <div class="admin-chart-body" style="display: flex; align-items: center; justify-content: center;">
                                <% if (employeeDashboard.getOrderStatusCounts().stream().mapToInt(p -> p.getValue()).sum() == 0) { %>
                                <p class="admin-empty-message">Không có đơn hàng trong khoảng thời gian này.</p>
                                <% } else { %>
                                <canvas id="employeeOrderChart" aria-label="Biểu đồ quản lý đơn hàng"></canvas>
                                <% } %>
                            </div>
                        </section>
                    </div>


                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js"></script>
                    <script>
                        (() => {
                            const warrantyLabels = [
                                <% for (int i = 0; i < employeeDashboard.getWarrantyStatusCounts().size(); i++) {
                                    EmployeeDashboardView.ChartPoint point = employeeDashboard.getWarrantyStatusCounts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(point.getLabel()) %>
                                <% } %>
                            ];
                            const warrantyValues = [
                                <% for (int i = 0; i < employeeDashboard.getWarrantyStatusCounts().size(); i++) {
                                    EmployeeDashboardView.ChartPoint point = employeeDashboard.getWarrantyStatusCounts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= point.getValue() %>
                                <% } %>
                            ];

                            const orderLabels = [
                                <% for (int i = 0; i < employeeDashboard.getOrderStatusCounts().size(); i++) {
                                    EmployeeDashboardView.ChartPoint point = employeeDashboard.getOrderStatusCounts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(point.getLabel()) %>
                                <% } %>
                            ];
                            const orderValues = [
                                <% for (int i = 0; i < employeeDashboard.getOrderStatusCounts().size(); i++) {
                                    EmployeeDashboardView.ChartPoint point = employeeDashboard.getOrderStatusCounts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= point.getValue() %>
                                <% } %>
                            ];

                            const formatCount = value =>
                                new Intl.NumberFormat('vi-VN').format(value) + ' đơn';

                            const warrantyColors = ['#f59e0b', '#16a34a', '#dc2626']; 
                            const orderColors = ['#16a34a', '#dc2626', '#f59e0b']; 

                            const warrantyCanvas = document.getElementById('employeeWarrantyChart');
                            if (warrantyCanvas) {
                                new Chart(warrantyCanvas, {
                                    type: 'pie',
                                    data: {
                                        labels: warrantyLabels,
                                        datasets: [{
                                            data: warrantyValues,
                                            backgroundColor: warrantyColors,
                                            borderColor: '#ffffff',
                                            borderWidth: 2
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                position: 'bottom',
                                                labels: {usePointStyle: true, padding: 16},
                                                onClick: null
                                            },
                                            tooltip: {
                                                enabled: false
                                            }
                                        }
                                    }
                                });
                            }

                            const orderCanvas = document.getElementById('employeeOrderChart');
                            if (orderCanvas) {
                                new Chart(orderCanvas, {
                                    type: 'pie',
                                    data: {
                                        labels: orderLabels,
                                        datasets: [{
                                            data: orderValues,
                                            backgroundColor: orderColors,
                                            borderColor: '#ffffff',
                                            borderWidth: 2
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                position: 'bottom',
                                                labels: {usePointStyle: true, padding: 16},
                                                onClick: null
                                            },
                                            tooltip: {
                                                enabled: false
                                            }
                                        }
                                    }
                                });
                            }
                        })();
                    </script>
                </div>

                            
       
                <% } else if ("SHIPMENT".equals(roleName)) { %>

                <%
                    ShipmentDashboardView shipmentDashboard = (ShipmentDashboardView) request.getAttribute("shipmentDashboard");
                %>

                <div class="shipment-dashboard">
                    <form class="admin-chart-filter" action="<%= shipmentDashboard.getFormAction() %>" method="get">
                        <label>
                            <input type="date" name="chartFrom" value="<%= shipmentDashboard.getStartDate() %>" required> -
                            <input type="date" name="chartTo" value="<%= shipmentDashboard.getEndDate() %>" required>
                        </label>
                        <button type="submit">Xem</button>
                    </form>

                    <div class="shipment-summary-grid" aria-label="Thống kê đơn hàng vận chuyển">
                        <% for (ShipmentDashboardView.SummaryCard card : shipmentDashboard.getSummaryCards()) { %>
                        <div class="shipment-summary-card">
                            <span class="shipment-summary-icon <%= card.getIconClass() %>"><i class="<%= card.getIcon() %>"></i></span>
                            <div class="shipment-summary-copy">
                                <p class="shipment-summary-title"><%= card.getLabel() %></p>
                                <div class="shipment-summary-value-row">
                                    <span class="shipment-summary-number"><%= card.getValue() %></span>
                                    <span class="shipment-summary-unit">đơn</span>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>

                    <div id="shipmentCharts" class="admin-dashboard-grid" style="margin-top: 20px; margin-bottom: 20px;">
                        <section class="admin-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <div>
                                    <h2>Biểu đồ trạng thái vận chuyển</h2>
                                    <p class="admin-chart-period">
                                        <%= shipmentDashboard.getStartDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %> - <%= shipmentDashboard.getEndDate().format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) %>
                                        | <strong>Tổng cộng: <%= shipmentDashboard.getTotalOrderCount() %> đơn</strong>
                                    </p>
                                </div>
                            </div>
                            <div class="admin-chart-body" style="display: flex; align-items: center; justify-content: center;">
                                <% if (shipmentDashboard.getTotalOrderCount() == 0) { %>
                                <p class="admin-empty-message">Không có đơn vận chuyển trong khoảng thời gian này.</p>
                                <% } else { %>
                                <canvas id="shipmentStatusChart" aria-label="Biểu đồ trạng thái vận chuyển"></canvas>
                                <% } %>
                            </div>
                        </section>

                    </div>
                            
                     
                    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js"></script>
                    <script>
                        (() => {
                            const statusLabels = [
                                <% for (int i = 0; i < shipmentDashboard.getOrderStatusCounts().size(); i++) {
                                    ShipmentDashboardView.ChartPoint point = shipmentDashboard.getOrderStatusCounts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(point.getLabel()) %>
                                <% } %>
                            ];
                            const statusValues = [
                                <% for (int i = 0; i < shipmentDashboard.getOrderStatusCounts().size(); i++) {
                                    ShipmentDashboardView.ChartPoint point = shipmentDashboard.getOrderStatusCounts().get(i); %>
                                <%= i > 0 ? "," : "" %><%= point.getValue() %>
                                <% } %>
                            ];
                            const statusCanvas = document.getElementById('shipmentStatusChart');
                            if (statusCanvas) {
                                new Chart(statusCanvas, {
                                    type: 'pie',
                                    data: {
                                        labels: statusLabels,
                                        datasets: [{
                                            data: statusValues,
                                            backgroundColor: ['#f59e0b', '#16a34a', '#dc2626'],
                                            borderColor: '#ffffff',
                                            borderWidth: 2
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        plugins: {
                                            legend: {
                                                position: 'bottom',
                                                labels: {usePointStyle: true, padding: 16},
                                                onClick: null
                                            },
                                            tooltip: {
                                                enabled: false
                                            }
                                        }
                                    }
                                });
                            }

                        })();
                    </script>
                </div>

                <% } else { %>

                <h1>Không có quyền truy cập</h1>
                <p>Tài khoản của bạn chưa được gán vai trò hợp lệ.</p>

                <% } %>

            </div>
        </div>
        <jsp:include page="/includes/footer.jsp" />

    </body>
</html>
