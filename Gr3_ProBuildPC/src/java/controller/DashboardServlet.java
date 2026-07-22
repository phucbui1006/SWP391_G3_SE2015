package controller;

import dal.AdminDashboardDAO;
import dal.EmployeeDashboardDAO;
import dal.ShipmentDashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.math.BigDecimal;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import model.AdminDashboardView;
import model.DashboardProduct;
import model.DashboardSummary;
import model.EmployeeDashboardView;
import model.ShipmentDashboardView;
import model.User;
import util.DashboardViewHelper;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/Dashboard"})
public class DashboardServlet extends HttpServlet {

    private static final int MAX_CHART_DAYS = 366;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("account");

        if (user.getRoleName() == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
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
        Map<String, Integer> orderStatusCounts = dashboardDAO.getOrderStatusCounts(
                chartStartDate, chartEndDate);
        Map<LocalDate, BigDecimal> revenueTimeline = dashboardDAO.getRevenueByDay(chartStartDate, chartEndDate);
        Map<String, Integer> categorySoldQuantities = dashboardDAO.getCategorySoldQuantities(chartStartDate, chartEndDate);

        AdminDashboardView adminDashboard = buildAdminDashboardView(
                request,
                summary,
                bestSellingProducts,
                orderStatusCounts
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
            Map<String, Integer> orderStatusCounts) {
        AdminDashboardView view = new AdminDashboardView();
        String ctx = request.getContextPath();
        DashboardSummary safeSummary = summary == null ? new DashboardSummary() : summary;

        view.setFormAction(ctx + "/Dashboard");
        view.setStatCards(buildAdminStatCards(safeSummary, ctx));
        view.setBestSellingProducts(buildProductRows(bestSellingProducts));
        view.setOrderStatusCounts(buildOrderStatusChartPoints(orderStatusCounts));

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
                DashboardViewHelper.formatCurrency(summary.getTotalRevenue()), ""));
        cards.add(new AdminDashboardView.StatCard("dark", "fa-solid fa-receipt", "Tổng đơn hàng",
                String.valueOf(summary.getTotalOrders()), ctx + "/order-history"));
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

    //Employee
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
        request.setAttribute("employeeDashboard", employeeDashboard);
    }

    private List<EmployeeDashboardView.SummaryCard> buildEmployeeSummaryCards(
            EmployeeDashboardView dashboard) {
        List<EmployeeDashboardView.SummaryCard> cards = new ArrayList<>();
      
        cards.add(new EmployeeDashboardView.SummaryCard(
                "delivered", "fa-solid fa-circle-check", "Đơn hàng đã giao",
                dashboard.getDeliveredOrderCount(), "đơn"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "cancelled", "fa-solid fa-ban", "Đơn hàng đã hủy",
                dashboard.getCancelledOrderCount(), "đơn"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "rejected", "fa-solid fa-triangle-exclamation", "Giao hàng thất bại",
                dashboard.getFailedOrderCount(), "đơn"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "waiting", "fa-regular fa-clock", "Bảo hành chờ tiếp nhận",
                dashboard.getWaitingWarrantyCount(), "yêu cầu"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "received", "fa-solid fa-clipboard-check", "Bảo hành đã được chấp nhận",
                dashboard.getAcceptedWarrantyCount(), "yêu cầu"));
        cards.add(new EmployeeDashboardView.SummaryCard(
                "warranty-rejected", "fa-solid fa-circle-xmark", "Bảo hành bị từ chối",
                dashboard.getRejectedWarrantyCount(), "yêu cầu"));
        return cards;
    }

    // Shipment dashboard
    private void prepareShipmentDashboard(HttpServletRequest request) {
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

        ShipmentDashboardView shipmentDashboard = new ShipmentDashboardDAO()
                .getDashboard(startDate, endDate);
        shipmentDashboard.setFormAction(request.getContextPath() + "/Dashboard");
        shipmentDashboard.setSummaryCards(buildShipmentSummaryCards(shipmentDashboard));
        request.setAttribute("shipmentDashboard", shipmentDashboard);
    }

    private List<ShipmentDashboardView.SummaryCard> buildShipmentSummaryCards(
            ShipmentDashboardView dashboard) {
        List<ShipmentDashboardView.SummaryCard> cards = new ArrayList<>();
        cards.add(new ShipmentDashboardView.SummaryCard(
                "all", "fa-solid fa-boxes-stacked", "Tổng đơn vận chuyển",
                dashboard.getTotalOrderCount()));
        cards.add(new ShipmentDashboardView.SummaryCard(
                "shipping", "fa-solid fa-truck", "Đang giao hàng",
                dashboard.getShippingOrderCount()));
        cards.add(new ShipmentDashboardView.SummaryCard(
                "delivered", "fa-solid fa-circle-check", "Đã giao hàng",
                dashboard.getDeliveredOrderCount()));
        cards.add(new ShipmentDashboardView.SummaryCard(
                "failed", "fa-solid fa-triangle-exclamation", "Giao hàng thất bại",
                dashboard.getFailedOrderCount()));
        return cards;
    }

    private boolean hasRole(User user, String expectedRole) {
        return user != null
                && user.getRoleName() != null
                && expectedRole.equals(user.getRoleName().trim().toUpperCase());
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
