package dal;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.OrderHistoryItem;
import model.OrderStatus;
import model.ShipmentDashboardView;

public class ShipmentDashboardDAO {

    public ShipmentDashboardView getDashboard(Integer selectedStatusId, boolean todayOnly,
            int page, int pageSize) {
        OrderHistoryDAO orderHistoryDAO = new OrderHistoryDAO();
        List<OrderStatus> allStatuses = orderHistoryDAO.getOrderStatuses();
        List<OrderStatus> statusOptions = filterStatuses(allStatuses);
        List<Integer> excludedStatusIds = getExcludedStatusIds(allStatuses);

        if (!containsStatus(selectedStatusId, statusOptions)) {
            selectedStatusId = null;
        }

        int totalOrders = orderHistoryDAO.countOrdersExcludingStatusIds(
                null, null, selectedStatusId, false, false, todayOnly, excludedStatusIds);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) pageSize));
        page = Math.max(1, Math.min(page, totalPages));

        List<OrderHistoryItem> orders = orderHistoryDAO.getOrdersExcludingStatusIds(
                null, null, selectedStatusId, page, pageSize,
                false, false, todayOnly, excludedStatusIds);

        int allActiveCount = orderHistoryDAO.countOrdersExcludingStatusIds(
                null, null, null, false, false, false, excludedStatusIds);
        int todayCount = orderHistoryDAO.countOrdersExcludingStatusIds(
                null, null, null, false, false, true, excludedStatusIds);

        Map<Integer, Integer> statusCounts = new LinkedHashMap<>();
        for (OrderStatus status : statusOptions) {
            statusCounts.put(status.getStatusId(),
                    orderHistoryDAO.countOrdersExcludingStatusIds(
                            null, null, status.getStatusId(), false, false, false, excludedStatusIds));
        }

        ShipmentDashboardView view = new ShipmentDashboardView();
        view.setOrders(orders);
        view.setStatusOptions(statusOptions);
        view.setStatusCounts(statusCounts);
        view.setSelectedStatusId(selectedStatusId);
        view.setTodayOnly(todayOnly);
        view.setAllActiveCount(allActiveCount);
        view.setTodayCount(todayCount);
        view.setPage(page);
        view.setTotalPages(totalPages);
        view.setTotalOrders(totalOrders);
        return view;
    }

    private List<OrderStatus> filterStatuses(List<OrderStatus> statuses) {
        List<OrderStatus> filtered = new ArrayList<>();
        if (statuses != null) {
            for (OrderStatus status : statuses) {
                if (!isExcludedStatus(status)) {
                    filtered.add(status);
                }
            }
        }
        return filtered;
    }

    private List<Integer> getExcludedStatusIds(List<OrderStatus> statuses) {
        List<Integer> ids = new ArrayList<>();
        if (statuses != null) {
            for (OrderStatus status : statuses) {
                if (isExcludedStatus(status)) {
                    ids.add(status.getStatusId());
                }
            }
        }
        return ids;
    }

    private boolean containsStatus(Integer statusId, List<OrderStatus> statuses) {
        if (statusId == null) {
            return true;
        }
        for (OrderStatus status : statuses) {
            if (status.getStatusId() == statusId) {
                return true;
            }
        }
        return false;
    }

    private boolean isExcludedStatus(OrderStatus status) {
        if (status == null || status.getStatusName() == null) {
            return false;
        }
        String name = status.getStatusName().toLowerCase();
        boolean pendingConfirmation = (name.contains("chờ") || name.contains("cho "))
                && (name.contains("xác nhận") || name.contains("xac nhan"));
        boolean preparing = name.contains("chuẩn bị") || name.contains("chuan bi");
        boolean cancelled = name.contains("đã hủy") || name.contains("da huy");
        return pendingConfirmation || preparing || cancelled;
    }
}
