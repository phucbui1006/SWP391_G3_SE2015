package controller;

import dal.AdminDashboardDAO;
import dal.OrderHistoryDAO;
import dal.WarrantyDAO;
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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.AccountSummary;
import model.AdminDashboardView;
import model.DashboardProduct;
import model.DashboardSummary;
import model.OrderHistoryItem;
import model.OrderStatus;
import model.User;
import model.WarrantyRequest;
import util.DashboardViewHelper;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/Dashboard"})
public class DashboardServlet extends HttpServlet {

    private static final int SHIPMENT_PAGE_SIZE = 10;
    private static final int MAX_CHART_DAYS = 366;

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
        List<DashboardProduct> lowStockProducts = dashboardDAO.getLowStockProducts(5);
        Map<String, Integer> orderStatusCounts = dashboardDAO.getOrderStatusCounts(
                chartStartDate, chartEndDate);
        Map<String, Integer> warrantyStatusCounts = dashboardDAO.getWarrantyStatusCounts(
                chartStartDate, chartEndDate);
        AccountSummary accountSummary = dashboardDAO.getAccountSummary();
        int bestSellingTotal = dashboardDAO.countBestSellingProducts(chartStartDate, chartEndDate);
        int lowStockTotal = dashboardDAO.countLowStockProducts();
        boolean showWarrantyAll = "1".equals(request.getParameter("showWarrantyAll"));
        Map<LocalDate, BigDecimal> revenueTimeline = dashboardDAO.getRevenueByDay(chartStartDate, chartEndDate);
        Map<String, BigDecimal> categoryRevenue = dashboardDAO.getCategoryRevenue(chartStartDate, chartEndDate);

        AdminDashboardView adminDashboard = buildAdminDashboardView(
                request,
                chartStartDate,
                chartEndDate,
                summary,
                bestSellingProducts,
                bestSellingTotal,
                lowStockProducts,
                lowStockTotal,
                orderStatusCounts,
                warrantyStatusCounts,
                accountSummary,
                showWarrantyAll
        );
        DateTimeFormatter dayFormatter = DateTimeFormatter.ofPattern("dd/MM");
        DateTimeFormatter periodFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        adminDashboard.setRevenueTimeline(buildRevenueTimelinePoints(revenueTimeline, dayFormatter));
        adminDashboard.setCategoryRevenue(buildCategoryRevenuePoints(categoryRevenue));
        adminDashboard.setChartStartDate(chartStartDate);
        adminDashboard.setChartEndDate(chartEndDate);
        adminDashboard.setChartPeriodLabel(chartStartDate.format(periodFormatter)
                + " - " + chartEndDate.format(periodFormatter));
        request.setAttribute("adminDashboard", adminDashboard);
    }

    private AdminDashboardView buildAdminDashboardView(HttpServletRequest request,
            LocalDate chartStartDate, LocalDate chartEndDate,
            DashboardSummary summary, List<DashboardProduct> bestSellingProducts, int bestSellingTotal,
            List<DashboardProduct> lowStockProducts, int lowStockTotal, Map<String, Integer> orderStatusCounts,
            Map<String, Integer> warrantyStatusCounts, AccountSummary accountSummary, boolean showWarrantyAll) {
        AdminDashboardView view = new AdminDashboardView();
        String ctx = request.getContextPath();
        DashboardSummary safeSummary = summary == null ? new DashboardSummary() : summary;
        AccountSummary safeAccountSummary = accountSummary == null ? new AccountSummary() : accountSummary;

        view.setFormAction(ctx + "/Dashboard");
        view.setWarrantyAllUrl(ctx + "/Dashboard?chartFrom=" + chartStartDate
                + "&chartTo=" + chartEndDate + "&showWarrantyAll=1");
        view.setStatCards(buildAdminStatCards(safeSummary));
        view.setBestSellingProducts(buildProductRows(bestSellingProducts));
        view.setLowStockProducts(buildProductRows(lowStockProducts));
        view.setOrderSummaries(buildOrderSummaryRows(safeSummary, orderStatusCounts));
        view.setWarrantyStatusCounts(buildWarrantyRows(warrantyStatusCounts, showWarrantyAll));
        view.setAccountSummaries(buildAccountRows(safeAccountSummary));

        int bestSellingVisible = view.getBestSellingProducts().size();
        if (bestSellingTotal > bestSellingVisible) {
            view.setBestSellingFooterMessage("Còn " + (bestSellingTotal - bestSellingVisible)
                    + " sản phẩm bán chạy khác trong khoảng đã chọn.");
        }

        int lowStockVisible = view.getLowStockProducts().size();
        if (lowStockTotal > lowStockVisible) {
            view.setLowStockFooterMessage("Còn " + (lowStockTotal - lowStockVisible)
                    + " sản phẩm sắp hết hàng khác.");
        }

        int warrantyStatusTotal = warrantyStatusCounts == null ? 0 : warrantyStatusCounts.size();
        if (!showWarrantyAll && warrantyStatusTotal > 5) {
            view.setShowWarrantyFooter(true);
            view.setWarrantyFooterMessage("Còn " + (warrantyStatusTotal - 5) + " trạng thái bảo hành khác.");
        }

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

    private List<AdminDashboardView.ChartPoint> buildCategoryRevenuePoints(
            Map<String, BigDecimal> revenueByCategory) {
        List<AdminDashboardView.ChartPoint> points = new ArrayList<>();
        if (revenueByCategory != null) {
            for (Map.Entry<String, BigDecimal> entry : revenueByCategory.entrySet()) {
                points.add(new AdminDashboardView.ChartPoint(entry.getKey(), entry.getValue()));
            }
        }
        return points;
    }

    private List<AdminDashboardView.StatCard> buildAdminStatCards(DashboardSummary summary) {
        List<AdminDashboardView.StatCard> cards = new ArrayList<>();
        cards.add(new AdminDashboardView.StatCard("red", "fa-solid fa-coins", "Tổng doanh thu",
                DashboardViewHelper.formatCurrency(summary.getTotalRevenue())));
        cards.add(new AdminDashboardView.StatCard("dark", "fa-solid fa-receipt", "Tổng đơn hàng",
                String.valueOf(summary.getTotalOrders())));
        cards.add(new AdminDashboardView.StatCard("blue", "fa-solid fa-desktop", "Tất cả sản phẩm",
                String.valueOf(summary.getActiveProducts())));
        cards.add(new AdminDashboardView.StatCard("green", "fa-solid fa-tags", "Tất cả thương hiệu",
                String.valueOf(summary.getTotalBrands())));
        cards.add(new AdminDashboardView.StatCard("orange", "fa-solid fa-screwdriver-wrench", "Yêu cầu bảo hành",
                String.valueOf(summary.getWarrantyRequests())));
        cards.add(new AdminDashboardView.StatCard("purple", "fa-solid fa-truck-ramp-box", "Lô hàng đã nhập",
                String.valueOf(summary.getImportedBatches())));
        return cards;
    }

    private List<AdminDashboardView.ProductRow> buildProductRows(List<DashboardProduct> products) {
        List<AdminDashboardView.ProductRow> rows = new ArrayList<>();
        if (products == null) {
            return rows;
        }

        for (DashboardProduct product : products) {
            rows.add(new AdminDashboardView.ProductRow(
                    String.valueOf(product.getProductId()),
                    DashboardViewHelper.h(product.getProductName()),
                    product.getSoldQuantity(),
                    product.getStockQuantity(),
                    DashboardViewHelper.h(product.getStatus()),
                    DashboardViewHelper.productStatusClass(product.getStatus())
            ));
        }
        return rows;
    }

    private List<AdminDashboardView.OrderSummaryRow> buildOrderSummaryRows(
            DashboardSummary summary, Map<String, Integer> orderStatusCounts) {
        List<AdminDashboardView.OrderSummaryRow> rows = new ArrayList<>();
        int totalOrders = summary.getTotalOrders();
        BigDecimal totalRevenue = summary.getTotalRevenue() == null ? BigDecimal.ZERO : summary.getTotalRevenue();
        int successfulOrders = countSuccessfulOrders(orderStatusCounts);

        rows.add(new AdminDashboardView.OrderSummaryRow(
                "Tổng đơn hàng",
                String.valueOf(totalOrders),
                "Tất cả đơn phát sinh trong khoảng đã chọn",
                ""
        ));
        rows.add(new AdminDashboardView.OrderSummaryRow(
                "Doanh thu",
                DashboardViewHelper.formatCurrency(totalRevenue),
                "Không tính đơn đã hủy",
                ""
        ));
        rows.add(new AdminDashboardView.OrderSummaryRow(
                "Đã giao thành công/hoàn thành",
                String.valueOf(successfulOrders),
                "Tổng đơn đã giao thành công hoặc đã hoàn thành",
                "delivered"
        ));

        if (orderStatusCounts != null) {
            for (Map.Entry<String, Integer> entry : orderStatusCounts.entrySet()) {
                String status = DashboardViewHelper.defaultText(entry.getKey(), "Chưa cập nhật");
                if (isConfirmedOrderStatus(status) || isSuccessfulOrderStatus(status)) {
                    continue;
                }
                rows.add(new AdminDashboardView.OrderSummaryRow(
                        DashboardViewHelper.h(status),
                        String.valueOf(entry.getValue() == null ? 0 : entry.getValue()),
                        "Theo trạng thái đơn hàng",
                        DashboardViewHelper.statusClass(status)
                ));
            }
        }

        return rows;
    }

    private int countSuccessfulOrders(Map<String, Integer> orderStatusCounts) {
        if (orderStatusCounts == null) {
            return 0;
        }

        int total = 0;
        for (Map.Entry<String, Integer> entry : orderStatusCounts.entrySet()) {
            if (isSuccessfulOrderStatus(entry.getKey())) {
                total += entry.getValue() == null ? 0 : entry.getValue();
            }
        }
        return total;
    }

    private boolean isSuccessfulOrderStatus(String status) {
        String value = status == null ? "" : status.toLowerCase();
        return value.contains("đã giao")
                || value.contains("da giao")
                || value.contains("hoàn thành")
                || value.contains("hoan thanh")
                || value.contains("thành công")
                || value.contains("thanh cong");
    }

    private boolean isConfirmedOrderStatus(String status) {
        String value = status == null ? "" : status.toLowerCase();
        return (value.contains("xác nhận") || value.contains("xac nhan"))
                && !value.contains("chờ")
                && !value.contains("cho ");
    }

    private List<AdminDashboardView.CountRow> buildWarrantyRows(Map<String, Integer> counts, boolean showAll) {
        List<AdminDashboardView.CountRow> rows = new ArrayList<>();
        if (counts == null) {
            return rows;
        }

        int index = 0;
        for (Map.Entry<String, Integer> entry : counts.entrySet()) {
            if (showAll || index < 5) {
                rows.add(new AdminDashboardView.CountRow(
                        DashboardViewHelper.h(entry.getKey()),
                        entry.getValue() == null ? 0 : entry.getValue()
                ));
            }
            index++;
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
        WarrantyDAO warrantyDAO = new WarrantyDAO();
        List<WarrantyRequest> pendingWarranties = new ArrayList<>();
        int waitingWarrantyCount = 0;
        int receivedWarrantyCount = 0;

        for (WarrantyRequest warranty : warrantyDAO.getAllWarrantyRequestsForAdmin(null, null)) {
            if (warranty.getStatusId() == 1 || warranty.getStatusId() == 2) {
                pendingWarranties.add(warranty);
                if (warranty.getStatusId() == 1) {
                    waitingWarrantyCount++;
                } else {
                    receivedWarrantyCount++;
                }
            }
        }

        int warrantyTotal = pendingWarranties.size();
        request.setAttribute("employeeWarranties",
                new ArrayList<>(pendingWarranties.subList(0, Math.min(5, warrantyTotal))));
        request.setAttribute("employeeWarrantyTotal", warrantyTotal);
        request.setAttribute("employeeWaitingWarrantyCount", waitingWarrantyCount);
        request.setAttribute("employeeReceivedWarrantyCount", receivedWarrantyCount);

        OrderHistoryDAO orderDAO = new OrderHistoryDAO();
        List<OrderStatus> statuses = orderDAO.getOrderStatuses();
        int failedStatusId = 0;
        int cancelledStatusId = 0;

        for (OrderStatus status : statuses) {
            if ("Giao hàng thất bại".equalsIgnoreCase(status.getStatusName())) {
                failedStatusId = status.getStatusId();
            } else if ("Đã hủy".equalsIgnoreCase(status.getStatusName())) {
                cancelledStatusId = status.getStatusId();
            }
        }

        int failedOrderCount = failedStatusId == 0 ? 0
                : orderDAO.countOrders(null, null, failedStatusId, false, false);
        int cancelledOrderCount = cancelledStatusId == 0 ? 0
                : orderDAO.countOrders(null, null, cancelledStatusId, false, false);
        List<OrderHistoryItem> orders = new ArrayList<>();
        if (failedOrderCount > 0) {
            orders.addAll(orderDAO.getOrders(null, null, failedStatusId, 1, failedOrderCount));
        }
        if (cancelledOrderCount > 0) {
            orders.addAll(orderDAO.getOrders(null, null, cancelledStatusId, 1, cancelledOrderCount));
        }
        orders.sort((first, second) -> second.getOrderDate().compareTo(first.getOrderDate()));

        request.setAttribute("employeeOrders", orders);
        request.setAttribute("employeeOrderTotal", failedOrderCount + cancelledOrderCount);
        request.setAttribute("employeeFailedOrderCount", failedOrderCount);
        request.setAttribute("employeeCancelledOrderCount", cancelledOrderCount);
    }

    private void prepareShipmentDashboard(HttpServletRequest request) {
        Integer selectedStatusId = parsePositiveInteger(request.getParameter("statusId"));
        boolean todayOnly = "1".equals(request.getParameter("today"));
        int page = parsePositiveInt(request.getParameter("page"), 1);

        OrderHistoryDAO orderHistoryDAO = new OrderHistoryDAO();
        List<OrderStatus> allStatusOptions = orderHistoryDAO.getOrderStatuses();
        List<OrderStatus> statusOptions = filterShipmentStatuses(allStatusOptions);
        List<Integer> removedShipmentStatusIds = getRemovedShipmentStatusIds(allStatusOptions);
        if (isRemovedShipmentStatus(selectedStatusId, statusOptions)) {
            selectedStatusId = null;
        }

        int totalOrders = orderHistoryDAO.countOrdersExcludingStatusIds(
                null, null, selectedStatusId, false, false, todayOnly, removedShipmentStatusIds);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) SHIPMENT_PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<OrderHistoryItem> shipmentOrders = orderHistoryDAO.getOrdersExcludingStatusIds(
                null,
                null,
                selectedStatusId,
                page,
                SHIPMENT_PAGE_SIZE,
                false,
                false,
                todayOnly,
                removedShipmentStatusIds
        );

        Map<Integer, Integer> shipmentStatusCounts = new LinkedHashMap<>();
        int allActiveOrders = orderHistoryDAO.countOrdersExcludingStatusIds(
                null, null, null, false, false, false, removedShipmentStatusIds);
        int todayOrders = orderHistoryDAO.countOrdersExcludingStatusIds(
                null, null, null, false, false, true, removedShipmentStatusIds);
        for (OrderStatus status : statusOptions) {
            shipmentStatusCounts.put(
                    status.getStatusId(),
                    orderHistoryDAO.countOrdersExcludingStatusIds(
                            null, null, status.getStatusId(), false, false, false, removedShipmentStatusIds)
            );
        }

        request.setAttribute("shipmentOrders", shipmentOrders);
        request.setAttribute("shipmentStatusOptions", statusOptions);
        request.setAttribute("shipmentStatusCounts", shipmentStatusCounts);
        request.setAttribute("shipmentAllActiveCount", allActiveOrders);
        request.setAttribute("shipmentTodayCount", todayOrders);
        request.setAttribute("shipmentSelectedStatusId", selectedStatusId);
        request.setAttribute("shipmentTodayOnly", todayOnly);
        request.setAttribute("shipmentPage", page);
        request.setAttribute("shipmentTotalPages", totalPages);
        request.setAttribute("shipmentTotalOrders", totalOrders);
    }

    private List<OrderStatus> filterShipmentStatuses(List<OrderStatus> statuses) {
        List<OrderStatus> filteredStatuses = new ArrayList<>();
        if (statuses == null) {
            return filteredStatuses;
        }

        for (OrderStatus status : statuses) {
            if (!isHiddenShipmentStatus(status)) {
                filteredStatuses.add(status);
            }
        }
        return filteredStatuses;
    }

    private List<Integer> getRemovedShipmentStatusIds(List<OrderStatus> statuses) {
        List<Integer> statusIds = new ArrayList<>();
        if (statuses == null) {
            return statusIds;
        }

        for (OrderStatus status : statuses) {
            if (isHiddenShipmentStatus(status)) {
                statusIds.add(status.getStatusId());
            }
        }
        return statusIds;
    }

    private boolean isRemovedShipmentStatus(Integer selectedStatusId, List<OrderStatus> statusOptions) {
        if (selectedStatusId == null) {
            return false;
        }

        for (OrderStatus status : statusOptions) {
            if (status.getStatusId() == selectedStatusId) {
                return false;
            }
        }
        return true;
    }

    private boolean isHiddenShipmentStatus(OrderStatus status) {
        return isPendingConfirmationStatus(status)
                || isPreparingOrderStatus(status)
                || isCancelledStatus(status);
    }

    private boolean isCancelledStatus(OrderStatus status) {
        if (status == null || status.getStatusName() == null) {
            return false;
        }

        String statusName = status.getStatusName().toLowerCase();
        return statusName.contains("đã hủy") || statusName.contains("da huy");
    }

    private boolean isPendingConfirmationStatus(OrderStatus status) {
        if (status == null || status.getStatusName() == null) {
            return false;
        }

        String statusName = status.getStatusName().toLowerCase();
        return (statusName.contains("chờ") || statusName.contains("cho "))
                && (statusName.contains("xác nhận") || statusName.contains("xac nhan"));
    }

    private boolean isPreparingOrderStatus(OrderStatus status) {
        if (status == null || status.getStatusName() == null) {
            return false;
        }

        String statusName = status.getStatusName().toLowerCase();
        return statusName.contains("chuẩn bị") || statusName.contains("chuan bi");
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

//    private String normalizeText(String value) {
//        if (value == null || value.trim().isEmpty()) {
//            return null;
//        }
//
//        return value.trim();
//    }
}
