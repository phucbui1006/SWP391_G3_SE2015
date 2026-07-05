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
                                <span>Mở trang quản lý toàn bộ sản phẩm.</span>
                                <a href="<%= ctx %>/admin/products">Xem tất cả</a>
                            </div>
                        </section>

                        <aside class="admin-panel admin-quick-panel admin-chart-panel">
                            <div class="admin-panel-header">
                                <h2>Sản phẩm mức tồn kho thấp (&lt;5)</h2>
                            </div>
                            <div class="admin-chart-body">
                                <% if (adminDashboard.getLowStockProductsChart().isEmpty()) { %>
                                <p class="admin-empty-message">Không có sản phẩm nào sắp hết hàng.</p>
                                <% } else { %>
                                <canvas id="lowStockProductsChart" aria-label="Biểu đồ sản phẩm tồn kho thấp"></canvas>
                                <% } %>
                            </div>
                            <div class="admin-panel-footer">
                                <span>Danh sách sản phẩm theo tồn kho tăng dần.</span>
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

                        <section class="admin-panel admin-chart-panel admin-account-panel">
                            <div class="admin-panel-header">
                                <div>
                                    <h2>Tổng quan tài khoản</h2>
                                    <p class="admin-chart-period">Số lượng tài khoản theo nhóm</p>
                                </div>
                            </div>

                            <div class="admin-account-chart-wrap">
                                <% if (adminDashboard.getAccountSummaries().isEmpty()) { %>
                                <p class="admin-empty-message">Chưa có dữ liệu tài khoản.</p>
                                <% } else { %>
                                <div class="admin-account-chart">
                                    <canvas id="accountOverviewChart" aria-label="Biểu đồ tổng quan tài khoản"></canvas>
                                </div>
                                <div class="admin-account-grid">
                                    <% for (int i = 0; i < adminDashboard.getAccountSummaries().size(); i++) {
                                        AdminDashboardView.CountRow accountRow = adminDashboard.getAccountSummaries().get(i); %>
                                    <div>
                                        <span>
                                            <i class="admin-account-dot"></i>
                                            <%= accountRow.getLabel() %>
                                        </span>
                                        <strong><%= accountRow.getValue() %></strong>
                                    </div>
                                    <% } %>
                                </div>
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
                            const accountLabels = [
                                <% for (int i = 0; i < adminDashboard.getAccountSummaries().size(); i++) {
                                    AdminDashboardView.CountRow accountRow = adminDashboard.getAccountSummaries().get(i); %>
                                <%= i > 0 ? "," : "" %><%= DashboardViewHelper.toJsonString(accountRow.getLabel()) %>
                                <% } %>
                            ];
                            const accountValues = [
                                <% for (int i = 0; i < adminDashboard.getAccountSummaries().size(); i++) {
                                    AdminDashboardView.CountRow accountRow = adminDashboard.getAccountSummaries().get(i); %>
                                <%= i > 0 ? "," : "" %><%= accountRow.getValue() %>
                                <% } %>
                            ];

                            const formatCurrency = value =>
                                new Intl.NumberFormat('vi-VN').format(value) + ' ₫';
                            const formatOrderCount = value =>
                                new Intl.NumberFormat('vi-VN').format(value) + ' đơn';
                            const formatProductCount = value =>
                                new Intl.NumberFormat('vi-VN').format(value) + ' sản phẩm';
                            const formatAccountCount = value =>
                                new Intl.NumberFormat('vi-VN').format(value) + ' tài khoản';
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

                            const accountCanvas = document.getElementById('accountOverviewChart');
                            if (accountCanvas) {
                                const accountColors = [
                                    '#dc2626', '#2563eb', '#16a34a', '#f59e0b', '#7c3aed',
                                    '#0891b2', '#db2777', '#65a30d', '#ea580c', '#475569'
                                ];
                                new Chart(accountCanvas, {
                                    type: 'bar',
                                    data: {
                                        labels: accountLabels,
                                        datasets: [{
                                            label: 'Số tài khoản',
                                            data: accountValues,
                                            backgroundColor: accountLabels.map((_, index) =>
                                                accountColors[index % accountColors.length]),
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
                                                    label: context => context.label + ': ' + formatAccountCount(context.parsed.x)
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
                                            y: {
                                                ticks: {display: false},
                                                grid: {display: false}
                                            }
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

                    <section class="employee-request-panel">
                        <div class="employee-panel-title-row">
                            <h2 class="employee-request-title">Đơn bảo hành cần xử lý (<%= employeeDashboard.getWarrantyRows().size() %>)</h2>
                            <a href="<%= ctx %>/ManageWarranty">Xem dịch vụ bảo hành</a>
                        </div>

                        <table class="employee-request-table">
                            <thead>
                                <tr>
                                    <th>Mã yêu cầu</th>
                                    <th>Khách hàng</th>
                                    <th>Sản phẩm</th>
                                    <th>Ngày tạo</th>
                                    <th>Trạng thái</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (employeeDashboard.getWarrantyRows().isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="employee-empty-row">Không có yêu cầu bảo hành chờ tiếp nhận trong khoảng thời gian này.</td>
                                </tr>
                                <% } %>
                                <% for (EmployeeDashboardView.WarrantyRow warranty : employeeDashboard.getWarrantyRows()) { %>
                                <tr>
                                    <td><a href="<%= warranty.getDetailUrl() %>">#<%= warranty.getWarrantyId() %></a></td>
                                    <td><%= warranty.getCustomerName() %></td>
                                    <td><%= warranty.getProductName() %></td>
                                    <td><%= warranty.getRequestDate() %></td>
                                    <td><span class="request-status <%= warranty.getStatusClass() %>"><%= warranty.getStatus() %></span></td>
                                    <td><a class="employee-row-action" href="<%= warranty.getDetailUrl() %>">Xem chi tiết</a></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </section>

                    <section class="employee-request-panel">
                        <div class="employee-panel-title-row">
                            <h2 class="employee-request-title">Đơn hàng cần xử lý (<%= employeeDashboard.getOrderRows().size() %>)</h2>
                            <a href="<%= ctx %>/order-history">Xem tất cả đơn hàng</a>
                        </div>

                        <table class="employee-request-table employee-order-request-table">
                            <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Ngày đặt</th>
                                    <th>Tổng tiền</th>
                                    <th>Trạng thái</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (employeeDashboard.getOrderRows().isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="employee-empty-row">Không có đơn giao hàng thất bại trong khoảng thời gian này.</td>
                                </tr>
                                <% } %>
                                <% for (EmployeeDashboardView.OrderRow order : employeeDashboard.getOrderRows()) { %>
                                <tr>
                                    <td>#<%= order.getOrderId() %></td>
                                    <td><%= order.getCustomerName() %></td>
                                    <td><%= order.getOrderDate() %></td>
                                    <td><%= order.getTotalAmount() %></td>
                                    <td><span class="request-status <%= order.getStatusClass() %>"><%= order.getStatus() %></span></td>
                                    <td><a class="employee-row-action" href="<%= order.getDetailUrl() %>">Xem chi tiết</a></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </section>
                </div>

                <% } else if ("SHIPMENT".equals(roleName)) { %>

                <%
                    ShipmentDashboardView shipmentDashboard = (ShipmentDashboardView) request.getAttribute("shipmentDashboard");
                %>

                <div class="shipment-dashboard">
                    <div class="dashboard-page-heading">
                     
                    </div>

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

                    <section class="shipment-order-panel">
                        <div class="shipment-order-header">
                            <div class="shipment-order-title-row">
                                <h2 class="shipment-order-title">Danh sách đơn hàng vận chuyển</h2>
                                <span style="background: none;"><%= shipmentDashboard.getTotalOrders() %> đơn phù hợp</span>
                            </div>

                            <div class="shipment-filter-tabs" aria-label="Lọc đơn hàng theo trạng thái">
                                <% for (ShipmentDashboardView.FilterTab tab : shipmentDashboard.getFilterTabs()) { %>
                                <a class="shipment-filter-tab <%= tab.isActive() ? "active" : "" %>"
                                   href="<%= tab.getUrl() %>"><%= tab.getLabel() %></a>
                                <% } %>
                            </div>
                        </div>

                        <table class="shipment-order-table">
                            <thead>
                                <tr>
                                    <th>Mã đơn hàng</th>
                                    <th>Khách hàng</th>
                                    <th>Địa chỉ giao hàng</th>
                                    <th>Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (shipmentDashboard.getOrderRows().isEmpty()) { %>
                                <tr>
                                    <td colspan="4">
                                        <p class="shipment-empty-message">Không có đơn hàng nào ở bộ lọc hiện tại.</p>
                                    </td>
                                </tr>
                                <% } %>
                                <% for (ShipmentDashboardView.OrderRow order : shipmentDashboard.getOrderRows()) { %>
                                <tr>
                                    <td><%= order.getOrderCode() %></td>
                                    <td><%= order.getCustomerName() %></td>
                                    <td><%= order.getShippingAddress() %></td>
                                    <td>
                                        <span class="shipment-status <%= order.getStatusClass() %>"><%= order.getStatus() %></span>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>

                        <% if (shipmentDashboard.getTotalPages() > 1) { %>
                        <div class="shipment-pagination">
                            <a class="<%= shipmentDashboard.getPage() <= 1 ? "disabled" : "" %>"
                               href="<%= shipmentDashboard.getPreviousPageUrl() %>">‹</a>
                            <% for (ShipmentDashboardView.PageLink pageLink : shipmentDashboard.getPageLinks()) { %>
                            <a class="<%= pageLink.isActive() ? "active" : "" %>"
                               href="<%= pageLink.getUrl() %>"><%= pageLink.getPageNumber() %></a>
                            <% } %>
                            <a class="<%= shipmentDashboard.getPage() >= shipmentDashboard.getTotalPages() ? "disabled" : "" %>"
                               href="<%= shipmentDashboard.getNextPageUrl() %>">›</a>
                        </div>
                        <% } %>
                    </section>
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
