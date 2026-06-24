package controller;

import dal.AdminDashboardDAO;
import dal.OrderHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.math.BigDecimal;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
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
import util.DashboardViewHelper;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/Dashboard"})
public class DashboardServlet extends HttpServlet {

    private static final int SHIPMENT_PAGE_SIZE = 10;

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
        } else if (hasRole(user, "SHIPMENT")) {
            prepareShipmentDashboard(request);
        }

        request.getRequestDispatcher("/views/dashboard.jsp").forward(request, response);
    }

    private void prepareAdminDashboard(HttpServletRequest request) {
        LocalDate selectedDate = parseDate(request.getParameter("date"), LocalDate.now());
        AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();
        DashboardSummary summary = dashboardDAO.getSummary(selectedDate);
        List<DashboardProduct> bestSellingProducts = dashboardDAO.getBestSellingProducts(selectedDate, 5);
        List<DashboardProduct> lowStockProducts = dashboardDAO.getLowStockProducts(5);
        Map<String, Integer> orderStatusCounts = dashboardDAO.getOrderStatusCounts(selectedDate);
        Map<String, Integer> warrantyStatusCounts = dashboardDAO.getWarrantyStatusCounts(selectedDate);
        AccountSummary accountSummary = dashboardDAO.getAccountSummary();
        int bestSellingTotal = dashboardDAO.countBestSellingProducts(selectedDate);
        int lowStockTotal = dashboardDAO.countLowStockProducts();
        boolean showWarrantyAll = "1".equals(request.getParameter("showWarrantyAll"));

        request.setAttribute("adminDashboard", buildAdminDashboardView(
                request,
                selectedDate,
                summary,
                bestSellingProducts,
                bestSellingTotal,
                lowStockProducts,
                lowStockTotal,
                orderStatusCounts,
                warrantyStatusCounts,
                accountSummary,
                showWarrantyAll
        ));
    }

    private AdminDashboardView buildAdminDashboardView(HttpServletRequest request, LocalDate selectedDate,
            DashboardSummary summary, List<DashboardProduct> bestSellingProducts, int bestSellingTotal,
            List<DashboardProduct> lowStockProducts, int lowStockTotal, Map<String, Integer> orderStatusCounts,
            Map<String, Integer> warrantyStatusCounts, AccountSummary accountSummary, boolean showWarrantyAll) {
        AdminDashboardView view = new AdminDashboardView();
        String ctx = request.getContextPath();
        DashboardSummary safeSummary = summary == null ? new DashboardSummary() : summary;
        AccountSummary safeAccountSummary = accountSummary == null ? new AccountSummary() : accountSummary;

        view.setSelectedDate(selectedDate);
        view.setFormAction(ctx + "/Dashboard");
        view.setWarrantyAllUrl(ctx + "/Dashboard?date=" + selectedDate + "&showWarrantyAll=1");
        view.setStatCards(buildAdminStatCards(safeSummary));
        view.setBestSellingProducts(buildProductRows(bestSellingProducts));
        view.setLowStockProducts(buildProductRows(lowStockProducts));
        view.setOrderSummaries(buildOrderSummaryRows(safeSummary, orderStatusCounts));
        view.setWarrantyStatusCounts(buildWarrantyRows(warrantyStatusCounts, showWarrantyAll));
        view.setAccountSummaries(buildAccountRows(safeAccountSummary));

        int bestSellingVisible = view.getBestSellingProducts().size();
        if (bestSellingTotal > bestSellingVisible) {
            view.setBestSellingFooterMessage("Còn " + (bestSellingTotal - bestSellingVisible)
                    + " sản phẩm bán chạy khác trong ngày.");
            view.setBestSellingFooterUrl(ctx + "/order-history");
        }

        int lowStockVisible = view.getLowStockProducts().size();
        if (lowStockTotal > lowStockVisible) {
            view.setLowStockFooterMessage("Còn " + (lowStockTotal - lowStockVisible)
                    + " sản phẩm sắp hết hàng khác.");
            view.setLowStockFooterUrl(ctx + "/admin/categories");
        }

        int warrantyStatusTotal = warrantyStatusCounts == null ? 0 : warrantyStatusCounts.size();
        if (!showWarrantyAll && warrantyStatusTotal > 5) {
            view.setShowWarrantyFooter(true);
            view.setWarrantyFooterMessage("Còn " + (warrantyStatusTotal - 5) + " trạng thái bảo hành khác.");
        }

        return view;
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
                    "SP" + product.getProductId(),
                    DashboardViewHelper.h(product.getProductName()),
                    product.getSoldQuantity(),
                    product.getStockQuantity(),
                    DashboardViewHelper.h(product.getStatus()),
                    DashboardViewHelper.productStatusClass(product.getStatus())
            ));
        }
        return rows;
    }

    private List<AdminDashboardView.OrderRow> buildOrderRows(List<OrderHistoryItem> orders) {
        List<AdminDashboardView.OrderRow> rows = new ArrayList<>();
        if (orders == null) {
            return rows;
        }

        for (OrderHistoryItem order : orders) {
            String displayStatus = DashboardViewHelper.defaultText(order.getDisplayStatus(), "Chưa cập nhật");
            rows.add(new AdminDashboardView.OrderRow(
                    "PB" + order.getOrderId(),
                    DashboardViewHelper.h(order.getCustomerName()),
                    DashboardViewHelper.formatCurrency(order.getTotalAmount()),
                    DashboardViewHelper.h(displayStatus),
                    DashboardViewHelper.statusClass(displayStatus),
                    DashboardViewHelper.h(DashboardViewHelper.formatDateTime(order.getOrderDate()))
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
                "Tất cả đơn phát sinh trong ngày đã chọn",
                ""
        ));
        rows.add(new AdminDashboardView.OrderSummaryRow(
                "Doanh thu hợp lệ",
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
        return isPendingConfirmationStatus(status) || isPreparingOrderStatus(status);
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
