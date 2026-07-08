package controller;

import dal.AdminDashboardDAO;
import dal.EmployeeDashboardDAO;
import dal.ShipmentDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.math.BigDecimal;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import model.AccountSummary;
import model.AdminDashboardView;
import model.DashboardProduct;
import model.DashboardSummary;
import model.EmployeeDashboardView;
import model.OrderHistoryItem;
import model.OrderStatus;
import model.ShipmentDashboardView;
import model.User;
import model.WarrantyRequest;
import util.DashboardViewHelper;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/Dashboard"})
public class DashboardServlet extends HttpServlet {

    private static final int SHIPMENT_PAGE_SIZE = 10;
    private static final int MAX_CHART_DAYS = 366;
    private static final int LOW_STOCK_MAX_QUANTITY = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User user = (User) session.getAttribute("account");

        if (user.getRoleName() == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        if (user.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if (hasRole(user, "ADMIN")) {
            prepareAdminDashboard(request);
        } else if (hasRole(user, "EMPLOYEE")) {
            prepareEmployeeDashboard(request);
        } else if (hasRole(user, "SHIPMENT")) {
            prepareShipmentDashboard(request);
        }

        request.getRequestDispatcher("/views/dashboard.jsp").forward(request, response);
    }

    private void prepareAdminDashboard(HttpServletRequest request) {
        LocalDate referenceDate = LocalDate.now();
        LocalDate weekStart = referenceDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekEnd = weekStart.plusDays(6);
        LocalDate chartStartDate = parseDate(request.getParameter("chartFrom"), weekStart);
        LocalDate chartEndDate = parseDate(request.getParameter("chartTo"), weekEnd);
        if (chartStartDate.isAfter(chartEndDate)) {
            LocalDate temporaryDate = chartStartDate;
            chartStartDate = chartEndDate;
            chartEndDate = temporaryDate;
        }
        if (chartEndDate.isAfter(chartStartDate.plusDays(MAX_CHART_DAYS - 1L))) {
            chartEndDate = chartStartDate.plusDays(MAX_CHART_DAYS - 1L);
        }

        AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();
        DashboardSummary summary = dashboardDAO.getSummary(chartStartDate, chartEndDate);
        List<DashboardProduct> bestSellingProducts = dashboardDAO.getBestSellingProducts(
                chartStartDate, chartEndDate, 5);
        Map<Integer, Integer> lowStockProductCounts = dashboardDAO.getLowStockProductCounts(LOW_STOCK_MAX_QUANTITY);
        Map<String, Integer> orderStatusCounts = dashboardDAO.getOrderStatusCounts(
                chartStartDate, chartEndDate);
        AccountSummary accountSummary = dashboardDAO.getAccountSummary();
        Map<LocalDate, BigDecimal> revenueTimeline = dashboardDAO.getRevenueByDay(chartStartDate, chartEndDate);
        Map<String, Integer> categorySoldQuantities = dashboardDAO.getCategorySoldQuantities(chartStartDate, chartEndDate);

        AdminDashboardView adminDashboard = buildAdminDashboardView(
                request,
                summary,
                bestSellingProducts,
                lowStockProductCounts,
                orderStatusCounts,
                accountSummary
        );
        DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd/MM");
        DateTimeFormatter periodFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        adminDashboard.setRevenueTimeline(buildRevenueTimelinePoints(revenueTimeline, dayFormatter));
        adminDashboard.setCategorySoldProducts(buildCategorySoldProductPoints(categorySoldQuantities));
        adminDashboard.setChartStartDate(chartStartDate);
        adminDashboard.setChartEndDate(chartEndDate);
        adminDashboard.setChartPeriodLabel(chartStartDate.format(periodFormatter)
                + " - " + chartEndDate.format(periodFormatter));
        request.setAttribute("adminDashboard", adminDashboard);
    }

    private AdminDashboardView buildAdminDashboardView(HttpServletRequest request,
            DashboardSummary summary, List<DashboardProduct> bestSellingProducts,
            Map<Integer, Integer> lowStockProductCounts, Map<String, Integer> orderStatusCounts,
            AccountSummary accountSummary) {
        AdminDashboardView view = new AdminDashboardView();
        String ctx = request.getContextPath();
        DashboardSummary safeSummary = summary == null ? new DashboardSummary() : summary;
        AccountSummary safeAccountSummary = accountSummary == null ? new AccountSummary() : accountSummary;

        view.setFormAction(ctx + "/Dashboard");
        view.setStatCards(buildAdminStatCards(safeSummary, ctx));
        view.setBestSellingProducts(buildProductRows(bestSellingProducts));
        view.setLowStockProductsChart(buildLowStockChartPoints(lowStockProductCounts));
        view.setOrderStatusCounts(buildOrderStatusChartPoints(orderStatusCounts));
        view.setAccountSummaries(buildAccountRows(safeAccountSummary));

        return view;
    }

    private List<AdminDashboardView.ChartPoint> buildRevenueTimelinePoints(
            Map<LocalDate, BigDecimal> revenueByDay, DateTimeFormatter formatter) {
        List<AdminDashboardView.ChartPoint> points = new ArrayList<>();
        if (revenueByDay != null) {
            for (Map.Entry<LocalDate, BigDecimal> entry : revenueByDay.entrySet()) {
                points.add(new AdminDashboardView.ChartPoint(
                        entry.getKey().format(formatter), entry.getValue()));
            }
        }
        return points;
    }

    private List<AdminDashboardView.ChartPoint> buildCategorySoldProductPoints(
            Map<String, Integer> soldQuantitiesByCategory) {
        List<AdminDashboardView.ChartPoint> points = new ArrayList<>();
        if (soldQuantitiesByCategory != null) {
            for (Map.Entry<String, Integer> entry : soldQuantitiesByCategory.entrySet()) {
                int soldQuantity = entry.getValue() == null ? 0 : entry.getValue();
                points.add(new AdminDashboardView.ChartPoint(entry.getKey(), BigDecimal.valueOf(soldQuantity)));
            }
        }
        return points;
    }

    private List<AdminDashboardView.ChartPoint> buildOrderStatusChartPoints(
            Map<String, Integer> orderStatusCounts) {
        List<AdminDashboardView.ChartPoint> points = new ArrayList<>();
        if (orderStatusCounts != null) {
            for (Map.Entry<String, Integer> entry : orderStatusCounts.entrySet()) {
                String status = DashboardViewHelper.defaultText(entry.getKey(), "Chưa cập nhật");
                if (isHiddenOrderStatusInChart(status)) {
                    continue;
                }
                int total = entry.getValue() == null ? 0 : entry.getValue();
                points.add(new AdminDashboardView.ChartPoint(status, BigDecimal.valueOf(total)));
            }
        }
        return points;
    }

    private List<AdminDashboardView.ChartPoint> buildLowStockChartPoints(
            Map<Integer, Integer> productCountsByStock) {
        List<AdminDashboardView.ChartPoint> points = new ArrayList<>();
        for (int stockQuantity = 0; stockQuantity <= LOW_STOCK_MAX_QUANTITY; stockQuantity++) {
            int productCount = productCountsByStock == null
                    ? 0
                    : productCountsByStock.getOrDefault(stockQuantity, 0);
            points.add(new AdminDashboardView.ChartPoint(
                    "Tồn = " + stockQuantity,
                    BigDecimal.valueOf(productCount)
            ));
        }
        return points;
    }

    private boolean isHiddenOrderStatusInChart(String status) {
        String value = status == null ? "" : status.toLowerCase();
        return value.contains("chờ xác nhận")
                || value.contains("cho xac nhan")
                || value.contains("đang chuẩn bị hàng")
                || value.contains("dang chuan bi hang");
    }

    private List<AdminDashboardView.StatCard> buildAdminStatCards(DashboardSummary summary, String ctx) {
        List<AdminDashboardView.StatCard> cards = new ArrayList<>();
        cards.add(new AdminDashboardView.StatCard("red", "fa-solid fa-coins", "Tổng doanh thu",
                DashboardViewHelper.formatCurrency(summary.getTotalRevenue()), ctx + "/Dashboard#revenueCharts"));
        cards.add(new AdminDashboardView.StatCard("dark", "fa-solid fa-receipt", "Tổng đơn hàng",
                String.valueOf(summary.getTotalOrders()), ctx + "/order-history"));
        cards.add(new AdminDashboardView.StatCard("blue", "fa-solid fa-desktop", "Tất cả sản phẩm",
                String.valueOf(summary.getActiveProducts()), ctx + "/admin/products"));
        cards.add(new AdminDashboardView.StatCard("green", "fa-solid fa-tags", "Tất cả thương hiệu",
                String.valueOf(summary.getTotalBrands()), ctx + "/AdminBrands"));
        cards.add(new AdminDashboardView.StatCard("orange", "fa-solid fa-screwdriver-wrench",
                "Tổng yêu cầu bảo hành đã tiếp nhận",
                String.valueOf(summary.getAcceptedWarrantyRequests()),
                ctx + "/ManageWarranty?statusFilter=2"));
        cards.add(new AdminDashboardView.StatCard("purple", "fa-solid fa-truck-ramp-box", "Lô hàng đã nhập",
                String.valueOf(summary.getImportedBatches()), ctx + "/BatchServlet"));
        return cards;
    }

    private List<AdminDashboardView.ProductRow> buildProductRows(List<DashboardProduct> products) {
        List<AdminDashboardView.ProductRow> rows = new ArrayList<>();
        if (products == null) {
            return rows;
        }

        for (DashboardProduct product : products) {
            rows.add(new AdminDashboardView.ProductRow(
                    DashboardViewHelper.h(product.getProductName()),
                    product.getSoldQuantity()
            ));
        }
        return rows;
    }

    private List<AdminDashboardView.CountRow> buildAccountRows(AccountSummary summary) {
        List<AdminDashboardView.CountRow> rows = new ArrayList<>();
        rows.add(new AdminDashboardView.CountRow("Khách hàng", summary.getCustomers()));
        rows.add(new AdminDashboardView.CountRow("Nhân viên", summary.getEmployees()));
        rows.add(new AdminDashboardView.CountRow("Nhân viên giao hàng", summary.getTransports()));
        rows.add(new AdminDashboardView.CountRow("Bị khóa", summary.getLocked()));
        rows.add(new AdminDashboardView.CountRow("Đang hoạt động", summary.getActive()));
        return rows;
    }

    private void prepareEmployeeDashboard(HttpServletRequest request) {
        LocalDate referenceDate = LocalDate.now();
        LocalDate weekStart = referenceDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekEnd = weekStart.plusDays(6);
        LocalDate startDate = parseDate(request.getParameter("chartFrom"), weekStart);
        LocalDate endDate = parseDate(request.getParameter("chartTo"), weekEnd);
        if (startDate.isAfter(endDate)) {
            LocalDate temporaryDate = startDate;
            startDate = endDate;
            endDate = temporaryDate;
        }
        if (endDate.isAfter(startDate.plusDays(MAX_CHART_DAYS - 1L))) {
            endDate = startDate.plusDays(MAX_CHART_DAYS - 1L);
        }

        EmployeeDashboardView employeeDashboard = new EmployeeDashboardDAO()
                .getDashboard(startDate, endDate);
        employeeDashboard.setFormAction(request.getContextPath() + "/Dashboard");
        employeeDashboard.setSummaryCards(buildEmployeeSummaryCards(employeeDashboard));
        employeeDashboard.setWarrantyRows(buildEmployeeWarrantyRows(
                employeeDashboard.getWarranties(), request.getContextPath()));
        employeeDashboard.setOrderRows(buildEmployeeOrderRows(
                employeeDashboard.getOrders(), request.getContextPath()));
        request.setAttribute("employeeDashboard", employeeDashboard);
    }

    private void prepareShipmentDashboard(HttpServletRequest request) {
        Integer selectedStatusId = parsePositiveInteger(request.getParameter("statusId"));
        boolean todayOnly = "1".equals(request.getParameter("today"));
        int page = parsePositiveInt(request.getParameter("page"), 1);
        ShipmentDashboardView shipmentDashboard = new ShipmentDashboardDAO()
                .getDashboard(selectedStatusId, todayOnly, page, SHIPMENT_PAGE_SIZE);
        prepareShipmentView(shipmentDashboard, request.getContextPath());
        request.setAttribute("shipmentDashboard", shipmentDashboard);
    }

    private List<EmployeeDashboardView.SummaryCard> buildEmployeeSummaryCards(
            EmployeeDashboardView dashboard) {
        List<EmployeeDashboardView.SummaryCard> cards = new ArrayList<>();
        cards.add(new EmployeeDashboardView.SummaryCard(
                "today", "fa-solid fa-list-check", "Công việc cần xử lý",
                dashboard.getTotalWorkCount(), "mục"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "waiting", "fa-regular fa-clock", "Bảo hành chờ tiếp nhận",
                dashboard.getWaitingWarrantyCount(), "yêu cầu"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "received", "fa-solid fa-inbox", "Bảo hành đã tiếp nhận",
                dashboard.getReceivedWarrantyCount(), "yêu cầu"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "rejected", "fa-solid fa-triangle-exclamation", "Giao hàng thất bại",
                dashboard.getFailedOrderCount(), "đơn"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "cancelled", "fa-solid fa-ban", "Đơn hàng đã hủy",
                dashboard.getCancelledOrderCount(), "đơn"));
        return cards;
    }

    private List<EmployeeDashboardView.WarrantyRow> buildEmployeeWarrantyRows(
            List<WarrantyRequest> warranties, String ctx) {
        List<EmployeeDashboardView.WarrantyRow> rows = new ArrayList<>();
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        if (warranties == null) {
            return rows;
        }

        for (WarrantyRequest warranty : warranties) {
            String detailUrl = ctx + "/ManageWarranty?action=edit&warrantyId="
                    + warranty.getWarrantyId() + "&statusFilter=1";
            rows.add(new EmployeeDashboardView.WarrantyRow(
                    warranty.getWarrantyId(),
                    DashboardViewHelper.h(warranty.getCustomerName()),
                    DashboardViewHelper.h(warranty.getProductName()),
                    warranty.getRequestDate() == null ? "-" : dateFormat.format(warranty.getRequestDate()),
                    DashboardViewHelper.h(DashboardViewHelper.defaultText(
                            warranty.getStatusName(), "Chờ tiếp nhận")),
                    warranty.getStatusId() == 1 ? "waiting" : "received",
                    detailUrl
            ));
        }
        return rows;
    }

    private List<EmployeeDashboardView.OrderRow> buildEmployeeOrderRows(
            List<OrderHistoryItem> orders, String ctx) {
        List<EmployeeDashboardView.OrderRow> rows = new ArrayList<>();
        SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
        if (orders == null) {
            return rows;
        }

        for (OrderHistoryItem order : orders) {
            rows.add(new EmployeeDashboardView.OrderRow(
                    order.getOrderId(),
                    DashboardViewHelper.h(order.getCustomerName()),
                    order.getOrderDate() == null ? "-" : dateFormat.format(order.getOrderDate()),
                    DashboardViewHelper.formatCurrency(order.getTotalAmount()),
                    DashboardViewHelper.h(DashboardViewHelper.defaultText(
                            order.getStatusName(), "Chưa cập nhật")),
                    DashboardViewHelper.statusClass(order.getStatusName()),
                    ctx + "/order-history?statusId=" + order.getStatusId()
                            + "&selectedOrderId=" + order.getOrderId()
            ));
        }
        return rows;
    }

    private void prepareShipmentView(ShipmentDashboardView dashboard, String ctx) {
        List<ShipmentDashboardView.SummaryCard> cards = new ArrayList<>();
        cards.add(new ShipmentDashboardView.SummaryCard(
                "all", "fa-solid fa-boxes-stacked", "Tất cả đơn hàng",
                dashboard.getAllActiveCount()));
        cards.add(new ShipmentDashboardView.SummaryCard(
                "today", "fa-solid fa-calendar-check", "Đơn hàng hôm nay",
                dashboard.getTodayCount()));
        for (OrderStatus status : dashboard.getStatusOptions()) {
            Integer count = dashboard.getStatusCounts().get(status.getStatusId());
            cards.add(new ShipmentDashboardView.SummaryCard(
                    DashboardViewHelper.statusClass(status.getStatusName()),
                    DashboardViewHelper.statusIcon(status.getStatusName()),
                    DashboardViewHelper.h(status.getStatusName()),
                    count == null ? 0 : count
            ));
        }
        dashboard.setSummaryCards(cards);

        List<ShipmentDashboardView.FilterTab> tabs = new ArrayList<>();
        tabs.add(new ShipmentDashboardView.FilterTab(
                "Tất cả",
                DashboardViewHelper.buildShipmentLink(ctx, null, false, 1),
                dashboard.getSelectedStatusId() == null && !dashboard.isTodayOnly()));
        tabs.add(new ShipmentDashboardView.FilterTab(
                "Hôm nay",
                DashboardViewHelper.buildShipmentLink(
                        ctx, dashboard.getSelectedStatusId(), true, 1),
                dashboard.isTodayOnly()));
        for (OrderStatus status : dashboard.getStatusOptions()) {
            tabs.add(new ShipmentDashboardView.FilterTab(
                    DashboardViewHelper.h(status.getStatusName()),
                    DashboardViewHelper.buildShipmentLink(ctx, status.getStatusId(), false, 1),
                    !dashboard.isTodayOnly()
                            && dashboard.getSelectedStatusId() != null
                            && dashboard.getSelectedStatusId() == status.getStatusId()
            ));
        }
        dashboard.setFilterTabs(tabs);

        List<ShipmentDashboardView.OrderRow> rows = new ArrayList<>();
        for (OrderHistoryItem order : dashboard.getOrders()) {
            String displayStatus = DashboardViewHelper.defaultText(
                    order.getDisplayStatus(), "Chưa cập nhật");
            rows.add(new ShipmentDashboardView.OrderRow(
                    order.getDisplayTrackingCode(),
                    DashboardViewHelper.h(DashboardViewHelper.defaultText(
                            order.getRecipientName(), order.getCustomerName())),
                    DashboardViewHelper.h(DashboardViewHelper.defaultText(
                            order.getShippingAddress(), "Chưa cập nhật địa chỉ")),
                    DashboardViewHelper.h(displayStatus),
                    DashboardViewHelper.statusClass(displayStatus)
            ));
        }
        dashboard.setOrderRows(rows);

        List<ShipmentDashboardView.PageLink> pageLinks = new ArrayList<>();
        for (int pageNumber = 1; pageNumber <= dashboard.getTotalPages(); pageNumber++) {
            pageLinks.add(new ShipmentDashboardView.PageLink(
                    pageNumber,
                    DashboardViewHelper.buildShipmentLink(
                            ctx, dashboard.getSelectedStatusId(), dashboard.isTodayOnly(), pageNumber),
                    pageNumber == dashboard.getPage()
            ));
        }
        dashboard.setPageLinks(pageLinks);
        dashboard.setPreviousPageUrl(dashboard.getPage() <= 1 ? "#"
                : DashboardViewHelper.buildShipmentLink(
                        ctx, dashboard.getSelectedStatusId(), dashboard.isTodayOnly(),
                        dashboard.getPage() - 1));
        dashboard.setNextPageUrl(dashboard.getPage() >= dashboard.getTotalPages() ? "#"
                : DashboardViewHelper.buildShipmentLink(
                        ctx, dashboard.getSelectedStatusId(), dashboard.isTodayOnly(),
                        dashboard.getPage() + 1));
    }

    private boolean hasRole(User user, String expectedRole) {
        return user != null
                && user.getRoleName() != null
                && expectedRole.equals(user.getRoleName().trim().toUpperCase());
    }

    private Integer parsePositiveInteger(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private LocalDate parseDate(String value, LocalDate defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }

        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException e) {
            return defaultValue;
        }
    }

}
