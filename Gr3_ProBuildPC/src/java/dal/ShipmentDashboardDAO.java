package dal;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.OrderHistoryItem;
import model.OrderStatus;
import model.ShipmentDashboardView;

public class ShipmentDashboardDAO extends DBContext {

    // Lấy toàn bộ dữ liệu cần hiển thị cho Shipment Dashboard
    public ShipmentDashboardView getDashboard(Integer selectedStatusId, boolean todayOnly,
            int page, int pageSize) {
        List<OrderStatus> allStatuses = getOrderStatuses();
        List<OrderStatus> statusOptions = filterStatuses(allStatuses);
        List<Integer> excludedStatusIds = getExcludedStatusIds(allStatuses);

        if (!containsStatus(selectedStatusId, statusOptions)) {
            selectedStatusId = null;
        }

        int totalOrders = countOrders(selectedStatusId, todayOnly, excludedStatusIds);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) pageSize));
        page = Math.max(1, Math.min(page, totalPages));

        ShipmentDashboardView view = new ShipmentDashboardView();
        view.setOrders(getOrders(selectedStatusId, todayOnly, page, pageSize, excludedStatusIds));
        view.setStatusOptions(statusOptions);
        view.setStatusCounts(getStatusCounts(statusOptions, excludedStatusIds));
        view.setSelectedStatusId(selectedStatusId);
        view.setTodayOnly(todayOnly);
        view.setAllActiveCount(countOrders(null, false, excludedStatusIds));
        view.setTodayCount(countOrders(null, true, excludedStatusIds));
        view.setPage(page);
        view.setTotalPages(totalPages);
        view.setTotalOrders(totalOrders);
        return view;
    }

    // Lấy danh sách tất cả trạng thái đơn hàng
    private List<OrderStatus> getOrderStatuses() {
        List<OrderStatus> statuses = new ArrayList<>();
        String sql = "SELECT status_id, status_name FROM orders_status ORDER BY status_id";

        try (PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                statuses.add(new OrderStatus(rs.getInt("status_id"), rs.getString("status_name")));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return statuses;
    }

    // Lấy danh sách đơn hàng theo điều kiện và phân trang
    private List<OrderHistoryItem> getOrders(Integer statusId, boolean todayOnly,
            int page, int pageSize, List<Integer> excludedStatusIds) {
        List<OrderHistoryItem> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                SELECT o.order_id,
                       o.customer_id,
                       o.status_id,
                       o.order_date,
                       o.total_amount,
                       o.shipping_address,
                       os.status_name,
                       u.full_name AS customer_name,
                       COALESCE(addr.recipient_name, u.full_name) AS recipient_name,
                       sh.shipment_id,
                       sh.tracking_code,
                       sh.shipment_status,
                       sh.note AS shipment_note
                FROM orders o
                INNER JOIN customers c ON c.customer_id = o.customer_id
                INNER JOIN users u ON u.user_id = c.user_id
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                LEFT JOIN shipments sh ON sh.order_id = o.order_id
                LEFT JOIN (
                    SELECT customer_id, MIN(address_id) AS address_id
                    FROM address
                    GROUP BY customer_id
                ) picked_addr ON picked_addr.customer_id = o.customer_id
                LEFT JOIN address addr ON addr.address_id = picked_addr.address_id
                WHERE 1 = 1
                """);
        List<Integer> params = new ArrayList<>();
        appendDashboardFilters(sql, params, statusId, todayOnly, excludedStatusIds);
        sql.append(" ORDER BY o.order_date DESC, o.order_id DESC LIMIT ? OFFSET ?");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int index = setIntegerParameters(ps, params);
            ps.setInt(index++, pageSize);
            ps.setInt(index, Math.max(0, (page - 1) * pageSize));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    // Đếm số lượng đơn hàng theo điều kiện lọc
    private int countOrders(Integer statusId, boolean todayOnly, List<Integer> excludedStatusIds) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) AS total FROM orders o WHERE 1 = 1");
        List<Integer> params = new ArrayList<>();
        appendDashboardFilters(sql, params, statusId, todayOnly, excludedStatusIds);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            setIntegerParameters(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("total") : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    // Thống kê số lượng đơn theo từng trạng thái
    private Map<Integer, Integer> getStatusCounts(List<OrderStatus> statuses,
            List<Integer> excludedStatusIds) {
        Map<Integer, Integer> counts = new LinkedHashMap<>();
        for (OrderStatus status : statuses) {
            counts.put(status.getStatusId(), 0);
        }
        if (statuses.isEmpty()) {
            return counts;
        }

        StringBuilder sql = new StringBuilder("""
                SELECT o.status_id, COUNT(*) AS total
                FROM orders o
                WHERE 1 = 1
                """);
        List<Integer> params = new ArrayList<>();
        appendExcludedStatusFilter(sql, params, excludedStatusIds);
        sql.append(" GROUP BY o.status_id");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            setIntegerParameters(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int statusId = rs.getInt("status_id");
                    if (counts.containsKey(statusId)) {
                        counts.put(statusId, rs.getInt("total"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return counts;
    }

    // Thêm các điều kiện lọc vào câu lệnh SQL
    private void appendDashboardFilters(StringBuilder sql, List<Integer> params,
            Integer statusId, boolean todayOnly, List<Integer> excludedStatusIds) {
        if (statusId != null) {
            sql.append(" AND o.status_id = ?");
            params.add(statusId);
        }
        appendExcludedStatusFilter(sql, params, excludedStatusIds);
        if (todayOnly) {
            sql.append(" AND DATE(o.order_date) = CURDATE()");
        }
    }

    // Thêm điều kiện loại bỏ các trạng thái không hiển thị
    private void appendExcludedStatusFilter(StringBuilder sql, List<Integer> params,
            List<Integer> excludedStatusIds) {
        if (excludedStatusIds == null || excludedStatusIds.isEmpty()) {
            return;
        }
        sql.append(" AND (o.status_id IS NULL OR o.status_id NOT IN (");
        for (int i = 0; i < excludedStatusIds.size(); i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append("?");
            params.add(excludedStatusIds.get(i));
        }
        sql.append("))");
    }

    // Gán danh sách tham số vào PreparedStatement
    private int setIntegerParameters(PreparedStatement ps, List<Integer> params) throws SQLException {
        int index = 1;
        for (Integer value : params) {
            ps.setInt(index++, value);
        }
        return index;
    }

    // Ánh xạ một dòng dữ liệu thành đối tượng OrderHistoryItem
    private OrderHistoryItem mapOrder(ResultSet rs) throws SQLException {
        OrderHistoryItem order = new OrderHistoryItem();
        order.setOrderId(rs.getInt("order_id"));
        order.setCustomerId(rs.getInt("customer_id"));
        order.setStatusId(rs.getInt("status_id"));
        order.setOrderDate(rs.getTimestamp("order_date"));
        BigDecimal totalAmount = rs.getBigDecimal("total_amount");
        order.setTotalAmount(totalAmount == null ? BigDecimal.ZERO : totalAmount);
        order.setShippingAddress(rs.getString("shipping_address"));
        order.setStatusName(rs.getString("status_name"));
        order.setCustomerName(rs.getString("customer_name"));
        order.setRecipientName(rs.getString("recipient_name"));
        order.setShipmentId(rs.getInt("shipment_id"));
        order.setTrackingCode(rs.getString("tracking_code"));
        order.setShipmentStatus(rs.getString("shipment_status"));
        order.setShipmentNote(rs.getString("shipment_note"));
        return order;
    }

    // Lọc các trạng thái được phép hiển thị trên Dashboard
    private List<OrderStatus> filterStatuses(List<OrderStatus> statuses) {
        List<OrderStatus> filtered = new ArrayList<>();
        for (OrderStatus status : statuses) {
            if (!isExcludedStatus(status)) {
                filtered.add(status);
            }
        }
        return filtered;
    }

    // Lấy danh sách ID của các trạng thái cần loại bỏ
    private List<Integer> getExcludedStatusIds(List<OrderStatus> statuses) {
        List<Integer> ids = new ArrayList<>();
        for (OrderStatus status : statuses) {
            if (isExcludedStatus(status)) {
                ids.add(status.getStatusId());
            }
        }
        return ids;
    }

    // Kiểm tra trạng thái được chọn có hợp lệ hay không
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

    // Kiểm tra trạng thái có thuộc nhóm cần loại bỏ hay không
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