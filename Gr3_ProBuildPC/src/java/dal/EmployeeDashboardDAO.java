package dal;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.EmployeeDashboardView;
import model.OrderHistoryItem;
import model.OrderStatus;
import model.WarrantyRequest;

public class EmployeeDashboardDAO {

    public EmployeeDashboardView getDashboard(LocalDate startDate, LocalDate endDate) {
        EmployeeDashboardView view = new EmployeeDashboardView();
        view.setStartDate(startDate);
        view.setEndDate(endDate);

        WarrantyDAO warrantyDAO = new WarrantyDAO();
        List<WarrantyRequest> pendingWarranties = new ArrayList<>();
        int waitingWarrantyCount = 0;
        int receivedWarrantyCount = 0;

        for (WarrantyRequest warranty : warrantyDAO.getAllWarrantyRequestsForAdmin(null, null)) {
            if (!isDateInRange(warranty.getRequestDate(), startDate, endDate)) {
                continue;
            }
            if (warranty.getStatusId() == 1) {
                pendingWarranties.add(warranty);
                waitingWarrantyCount++;
            } else if (warranty.getStatusId() == 2) {
                receivedWarrantyCount++;
            }
        }

        OrderHistoryDAO orderDAO = new OrderHistoryDAO();
        int failedStatusId = 0;
        int cancelledStatusId = 0;
        for (OrderStatus status : orderDAO.getOrderStatuses()) {
            if ("Giao hàng thất bại".equalsIgnoreCase(status.getStatusName())) {
                failedStatusId = status.getStatusId();
            } else if ("Đã hủy".equalsIgnoreCase(status.getStatusName())) {
                cancelledStatusId = status.getStatusId();
            }
        }

        List<OrderHistoryItem> failedOrders = getOrdersInPeriod(
                orderDAO, failedStatusId, startDate, endDate);
        int cancelledOrderCount = getOrdersInPeriod(
                orderDAO, cancelledStatusId, startDate, endDate).size();

        view.setWarranties(pendingWarranties);
        view.setOrders(failedOrders);
        view.setWaitingWarrantyCount(waitingWarrantyCount);
        view.setReceivedWarrantyCount(receivedWarrantyCount);
        view.setFailedOrderCount(failedOrders.size());
        view.setCancelledOrderCount(cancelledOrderCount);
        return view;
    }

    private List<OrderHistoryItem> getOrdersInPeriod(OrderHistoryDAO orderDAO, int statusId,
            LocalDate startDate, LocalDate endDate) {
        if (statusId <= 0) {
            return new ArrayList<>();
        }

        int total = orderDAO.countOrders(null, null, statusId, false, false);
        if (total <= 0) {
            return new ArrayList<>();
        }

        List<OrderHistoryItem> filteredOrders = new ArrayList<>();
        for (OrderHistoryItem order : orderDAO.getOrders(null, null, statusId, 1, total)) {
            if (isDateInRange(order.getOrderDate(), startDate, endDate)) {
                filteredOrders.add(order);
            }
        }
        return filteredOrders;
    }

    private boolean isDateInRange(Date date, LocalDate startDate, LocalDate endDate) {
        if (date == null) {
            return false;
        }
        LocalDate value = Instant.ofEpochMilli(date.getTime())
                .atZone(ZoneId.systemDefault()).toLocalDate();
        return !value.isBefore(startDate) && !value.isAfter(endDate);
    }
}
