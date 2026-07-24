package dal;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.OrderHistoryDetail;
import model.OrderHistoryItem;
import model.OrderStatus;
import util.OrderSearchCriteria;

public class OrderHistoryDAO extends DBContext {

    public int countOrders(Integer customerUserId, String trackingKeyword, Integer statusId) {
        return countOrders(customerUserId, trackingKeyword, statusId, false);
    }

    public int countOrders(Integer customerUserId, String trackingKeyword, Integer statusId, boolean completedOnly) {
        return countOrders(customerUserId, trackingKeyword, statusId, completedOnly, false);
    }

    public int countOrders(Integer customerUserId, String trackingKeyword, Integer statusId, boolean completedOnly, boolean incompleteOnly) {
        return countOrders(customerUserId, trackingKeyword, statusId, completedOnly, incompleteOnly, false);
    }

    public int countOrders(Integer customerUserId, String trackingKeyword, Integer statusId, boolean completedOnly, boolean incompleteOnly, boolean todayOnly) {
        StringBuilder sql = new StringBuilder("""
                     SELECT COUNT(*) AS total
                     FROM orders o
                     INNER JOIN customers c ON c.customer_id = o.customer_id
                     INNER JOIN users u ON u.user_id = c.user_id
                     LEFT JOIN orders_status os ON os.status_id = o.status_id
                     LEFT JOIN shipments sh ON sh.order_id = o.order_id
                     WHERE 1 = 1
                     """);

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, customerUserId, trackingKeyword, statusId, completedOnly, incompleteOnly);
        appendTodayFilter(sql, todayOnly);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            setParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public int countOrdersExcludingStatusIds(Integer customerUserId, String trackingKeyword, Integer statusId,
            boolean completedOnly, boolean incompleteOnly, boolean todayOnly, List<Integer> excludedStatusIds) {
        StringBuilder sql = new StringBuilder("""
                     SELECT COUNT(*) AS total
                     FROM orders o
                     INNER JOIN customers c ON c.customer_id = o.customer_id
                     INNER JOIN users u ON u.user_id = c.user_id
                     LEFT JOIN orders_status os ON os.status_id = o.status_id
                     LEFT JOIN shipments sh ON sh.order_id = o.order_id
                     WHERE 1 = 1
                     """);

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, customerUserId, trackingKeyword, statusId, completedOnly, incompleteOnly);
        appendExcludedStatusFilter(sql, params, excludedStatusIds);
        appendTodayFilter(sql, todayOnly);

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            setParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<OrderHistoryItem> getOrders(Integer customerUserId, String trackingKeyword, Integer statusId, int page, int pageSize) {
        return getOrders(customerUserId, trackingKeyword, statusId, page, pageSize, false);
    }

    public List<OrderHistoryItem> getOrders(Integer customerUserId, String trackingKeyword, Integer statusId, int page, int pageSize, boolean completedOnly) {
        return getOrders(customerUserId, trackingKeyword, statusId, page, pageSize, completedOnly, false);
    }

    public List<OrderHistoryItem> getOrders(Integer customerUserId, String trackingKeyword, Integer statusId, int page, int pageSize, boolean completedOnly, boolean incompleteOnly) {
        return getOrders(customerUserId, trackingKeyword, statusId, page, pageSize, completedOnly, incompleteOnly, false);
    }

    public List<OrderHistoryItem> getOrders(Integer customerUserId, String trackingKeyword, Integer statusId, int page, int pageSize, boolean completedOnly, boolean incompleteOnly, boolean todayOnly) {
        List<OrderHistoryItem> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseOrderSelect());

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, customerUserId, trackingKeyword, statusId, completedOnly, incompleteOnly);
        appendTodayFilter(sql, todayOnly);
        sql.append(" ORDER BY o.order_date DESC, o.order_id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            setParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        attachDetails(orders);
        return orders;
    }

    public List<OrderHistoryItem> getOrdersExcludingStatusIds(Integer customerUserId, String trackingKeyword, Integer statusId,
            int page, int pageSize, boolean completedOnly, boolean incompleteOnly, boolean todayOnly,
            List<Integer> excludedStatusIds) {
        List<OrderHistoryItem> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseOrderSelect());

        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, customerUserId, trackingKeyword, statusId, completedOnly, incompleteOnly);
        appendExcludedStatusFilter(sql, params, excludedStatusIds);
        appendTodayFilter(sql, todayOnly);
        sql.append(" ORDER BY o.order_date DESC, o.order_id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            setParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        attachDetails(orders);
        return orders;
    }

    public OrderHistoryItem getOrderById(int orderId, Integer customerUserId) {
        return getOrderById(orderId, customerUserId, false);
    }

    public OrderHistoryItem getOrderById(int orderId, Integer customerUserId, boolean completedOnly) {
        return getOrderById(orderId, customerUserId, completedOnly, false);
    }

    public OrderHistoryItem getOrderById(int orderId, Integer customerUserId, boolean completedOnly, boolean incompleteOnly) {
        List<OrderHistoryItem> orders = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseOrderSelect());
        List<Object> params = new ArrayList<>();

        sql.append(" AND o.order_id = ?");
        params.add(orderId);

        if (customerUserId != null) {
            sql.append(" AND u.user_id = ?");
            params.add(customerUserId);
        }

        if (completedOnly) {
            sql.append(" AND (LOWER(os.status_name) = LOWER(?) OR LOWER(os.status_name) = LOWER(?))");
            params.add("Đã giao hàng");
            params.add("Da giao hang");
        }

        if (incompleteOnly) {
            appendIncompleteOnlyFilter(sql, params);
        }

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            setParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    orders.add(mapOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        attachDetails(orders);
        return orders.isEmpty() ? null : orders.get(0);
    }

    public List<OrderStatus> getOrderStatuses() {
        List<OrderStatus> statuses = new ArrayList<>();
        String sql = "SELECT status_id, status_name FROM orders_status ORDER BY status_id ASC";

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

    public boolean updateShipmentStatus(int orderId, int statusId, String shipmentNote, boolean checkLock) {
        if (orderId <= 0 || statusId <= 0) {
            return false;
        }

        try {
            connection.setAutoCommit(false);

            String statusName = findOrderStatusName(statusId);
            String currentStatusName = findCurrentOrderStatusName(orderId);
            if (statusName == null || currentStatusName == null || (checkLock && isLockedShipmentStatus(currentStatusName))) {
                connection.rollback();
                return false;
            }

            Integer shipmentId = findShipmentId(orderId);
            if (shipmentId == null) {
                insertShipment(orderId, String.valueOf(orderId), statusName, shipmentNote);
            } else {
                updateShipmentStatusAndNote(shipmentId, statusName, shipmentNote);
            }

            // Lưu status_id hiện tại trước khi cập nhật (để xác định kho đã trừ chưa)
            boolean wasConfirmedOrLater = !currentStatusName.trim().equalsIgnoreCase("Chờ xác nhận")
                    && !currentStatusName.trim().equalsIgnoreCase("Đã hủy");

            updateOrderStatus(orderId, statusId);
            
            // If the status is changing to 'Đã hủy' (id = 6), release the stock only if order was confirmed (kho đã trừ)
            if (statusId == 6 && wasConfirmedOrLater) {
                OrderDAO orderDAO = new OrderDAO();
                orderDAO.releaseStock(orderId);
            }
            
            connection.commit();
            return true;
        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException rollbackException) {
                rollbackException.printStackTrace();
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public boolean cancelWaitingOrder(int orderId, int customerId) {
        if (orderId <= 0 || customerId <= 0) {
            return false;
        }

        try {
            Integer waitingStatusId = 1; // Chờ xác nhận
            Integer confirmedStatusId = 2; // Đã xác nhận
            Integer cancelledStatusId = 6; // Đã hủy

            // Lấy status hiện tại trước khi hủy
            int currentStatusId = 0;
            try (PreparedStatement psCheck = connection.prepareStatement(
                    "SELECT status_id FROM orders WHERE order_id = ? AND customer_id = ?")) {
                psCheck.setInt(1, orderId);
                psCheck.setInt(2, customerId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        currentStatusId = rs.getInt("status_id");
                    }
                }
            }

            String sql = """
                         UPDATE orders
                         SET status_id = ?,
                             payment_status = CASE
                                 WHEN payment_status IS NULL
                                      OR LOWER(payment_status) IN (LOWER('Chờ thanh toán'), LOWER('Chưa thanh toán'))
                                 THEN 'Đã hủy'
                                 ELSE payment_status
                             END
                         WHERE order_id = ?
                           AND customer_id = ?
                           AND status_id IN (?, ?)
                         """;

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, cancelledStatusId);
                ps.setInt(2, orderId);
                ps.setInt(3, customerId);
                ps.setInt(4, waitingStatusId);
                ps.setInt(5, confirmedStatusId);
                boolean success = ps.executeUpdate() > 0;
                if (success) {
                    // Chỉ hoàn kho nếu đơn đã ở trạng thái Đã xác nhận (kho đã trừ)
                    if (currentStatusId == confirmedStatusId) {
                        OrderDAO orderDAO = new OrderDAO();
                        orderDAO.releaseStock(orderId);
                    }
                    
                    // Also update shipment status if it exists
                    try (PreparedStatement psShipment = connection.prepareStatement(
                            "UPDATE shipments SET shipment_status = ? WHERE order_id = ?")) {
                        psShipment.setString(1, "Đã hủy");
                        psShipment.setInt(2, orderId);
                        psShipment.executeUpdate();
                    }
                }
                return success;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean cancelWaitingOrderByStaff(int orderId) {
        if (orderId <= 0) {
            return false;
        }

        try {
            Integer waitingStatusId = 1; // Chờ xác nhận
            Integer cancelledStatusId = 6; // Đã hủy

            int currentStatusId = 0;
            try (PreparedStatement psCheck = connection.prepareStatement(
                    "SELECT status_id FROM orders WHERE order_id = ?")) {
                psCheck.setInt(1, orderId);
                try (ResultSet rs = psCheck.executeQuery()) {
                    if (rs.next()) {
                        currentStatusId = rs.getInt("status_id");
                    }
                }
            }

            if (currentStatusId != waitingStatusId) {
                return false;
            }

            String sql = """
                         UPDATE orders
                         SET status_id = ?,
                             payment_status = CASE
                                 WHEN payment_status IS NULL
                                      OR LOWER(payment_status) IN (LOWER('Chờ thanh toán'), LOWER('Chưa thanh toán'))
                                 THEN 'Đã hủy'
                                 ELSE payment_status
                             END
                         WHERE order_id = ?
                           AND status_id = ?
                         """;

            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setInt(1, cancelledStatusId);
                ps.setInt(2, orderId);
                ps.setInt(3, waitingStatusId);
                boolean success = ps.executeUpdate() > 0;
                if (success) {
                    try (PreparedStatement psShipment = connection.prepareStatement(
                            "UPDATE shipments SET shipment_status = ? WHERE order_id = ?")) {
                        psShipment.setString(1, "Đã hủy");
                        psShipment.setInt(2, orderId);
                        psShipment.executeUpdate();
                    }
                }
                return success;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private String baseOrderSelect() {
        return """
               SELECT o.order_id,
                      o.customer_id,
                      o.status_id,
                      o.order_date,
                      o.total_amount,
                      o.shipping_address,
                      o.payment_method,
                      o.payment_status,
                      o.note AS order_note,
                      os.status_name,
                      u.full_name AS customer_name,
                      u.email AS customer_email,
                      COALESCE(addr.recipient_name, u.full_name) AS recipient_name,
                      addr.phone_number AS recipient_phone,
                      sh.shipment_id,
                      sh.tracking_code,
                      sh.shipment_status,
                      sh.note AS shipment_note,
                      COALESCE(line_stats.item_count, 0) AS item_count,
                      COALESCE(line_stats.total_quantity, 0) AS total_quantity
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
               LEFT JOIN (
                   SELECT order_id,
                          COUNT(*) AS item_count,
                          COALESCE(SUM(quantity), 0) AS total_quantity
                   FROM order_details
                   GROUP BY order_id
               ) line_stats ON line_stats.order_id = o.order_id
               WHERE 1 = 1
               """;
    }

    private void appendFilters(StringBuilder sql, List<Object> params, Integer customerUserId, String trackingKeyword, Integer statusId, boolean completedOnly, boolean incompleteOnly) {
        if (customerUserId != null) {
            sql.append(" AND u.user_id = ?");
            params.add(customerUserId);
        }

        if (completedOnly) {
            sql.append(" AND (LOWER(os.status_name) = LOWER(?) OR LOWER(os.status_name) = LOWER(?))");
            params.add("Đã giao hàng");
            params.add("Da giao hang");
        }

        if (incompleteOnly) {
            appendIncompleteOnlyFilter(sql, params);
        }

        OrderSearchCriteria searchCriteria = OrderSearchCriteria.fromKeyword(trackingKeyword);
        if (searchCriteria.hasKeyword()) {
            sql.append(" AND CAST(o.order_id AS CHAR) = ?");
            params.add(searchCriteria.getKeyword());
        }

        if (statusId != null) {
            sql.append(" AND o.status_id = ?");
            params.add(statusId);
        }
    }

    private void appendIncompleteOnlyFilter(StringBuilder sql, List<Object> params) {
        sql.append("""
                   AND NOT (
                       LOWER(os.status_name) = LOWER(?)
                       OR LOWER(os.status_name) = LOWER(?)
                   )
                   """);
        params.add("Đã giao hàng");
        params.add("Da giao hang");
    }

    private void appendExcludedStatusFilter(StringBuilder sql, List<Object> params, List<Integer> excludedStatusIds) {
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

    private void appendTodayFilter(StringBuilder sql, boolean todayOnly) {
        if (todayOnly) {
            sql.append(" AND DATE(o.order_date) = CURDATE()");
        }
    }

    private void attachDetails(List<OrderHistoryItem> orders) {
        if (orders == null || orders.isEmpty()) {
            return;
        }

        Map<Integer, OrderHistoryItem> orderMap = new LinkedHashMap<>();
        StringBuilder placeholders = new StringBuilder();
        for (OrderHistoryItem order : orders) {
            orderMap.put(order.getOrderId(), order);
            if (placeholders.length() > 0) {
                placeholders.append(", ");
            }
            placeholders.append("?");
        }

        String sql = """
                     SELECT od.order_detail_id,
                            od.order_id,
                            od.product_id,
                            od.quantity,
                            od.unit_price,
                            od.warranty_months,
                            od.subtotal,
                            p.product_name,
                            p.image_url,
                            b.brand_name,
                            c.category_name
                     FROM order_details od
                     INNER JOIN products p ON p.product_id = od.product_id
                     INNER JOIN brands b ON b.brand_id = p.brand_id
                     INNER JOIN categories c ON c.category_id = p.category_id
                     WHERE od.order_id IN (
                     """ + placeholders + """
                     )
                     ORDER BY od.order_id ASC, od.order_detail_id ASC
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            int index = 1;
            for (Integer orderId : orderMap.keySet()) {
                ps.setInt(index++, orderId);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderHistoryDetail detail = mapDetail(rs);
                    OrderHistoryItem order = orderMap.get(detail.getOrderId());
                    if (order != null) {
                        order.getDetails().add(detail);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private OrderHistoryItem mapOrder(ResultSet rs) throws SQLException {
        OrderHistoryItem order = new OrderHistoryItem();
        order.setOrderId(rs.getInt("order_id"));
        order.setCustomerId(rs.getInt("customer_id"));
        order.setStatusId(rs.getInt("status_id"));
        order.setOrderDate(rs.getTimestamp("order_date"));
        order.setTotalAmount(nullToZero(rs.getBigDecimal("total_amount")));
        order.setShippingAddress(rs.getString("shipping_address"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setPaymentStatus(rs.getString("payment_status"));
        order.setNote(rs.getString("order_note"));
        order.setStatusName(rs.getString("status_name"));
        order.setCustomerName(rs.getString("customer_name"));
        order.setCustomerEmail(rs.getString("customer_email"));
        order.setRecipientName(rs.getString("recipient_name"));
        order.setRecipientPhone(rs.getString("recipient_phone"));
        order.setShipmentId(getNullableInt(rs, "shipment_id"));
        order.setTrackingCode(rs.getString("tracking_code"));
        order.setShipmentStatus(rs.getString("shipment_status"));
        order.setShipmentNote(rs.getString("shipment_note"));
        order.setItemCount(rs.getInt("item_count"));
        order.setTotalQuantity(rs.getInt("total_quantity"));
        return order;
    }

    private OrderHistoryDetail mapDetail(ResultSet rs) throws SQLException {
        OrderHistoryDetail detail = new OrderHistoryDetail();
        detail.setOrderDetailId(rs.getInt("order_detail_id"));
        detail.setOrderId(rs.getInt("order_id"));
        detail.setProductId(rs.getInt("product_id"));
        detail.setQuantity(rs.getInt("quantity"));
        detail.setUnitPrice(nullToZero(rs.getBigDecimal("unit_price")));
        detail.setWarrantyMonths(rs.getInt("warranty_months"));
        detail.setSubtotal(nullToZero(rs.getBigDecimal("subtotal")));
        detail.setProductName(rs.getString("product_name"));
        detail.setImageUrl(rs.getString("image_url"));
        detail.setBrandName(rs.getString("brand_name"));
        detail.setCategoryName(rs.getString("category_name"));
        return detail;
    }

    private Integer findOrderStatusId(String statusName) throws SQLException {
        String sql = "SELECT status_id FROM orders_status WHERE LOWER(status_name) = LOWER(?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, statusName);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("status_id");
                }
            }
        }

        return null;
    }

    private String findOrderStatusName(int statusId) throws SQLException {
        String sql = "SELECT status_name FROM orders_status WHERE status_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, statusId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status_name");
                }
            }
        }

        return null;
    }

    public String findCurrentOrderStatusName(int orderId) {
        String sql = """
                     SELECT os.status_name
                     FROM orders o
                     INNER JOIN orders_status os ON os.status_id = o.status_id
                     WHERE o.order_id = ?
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status_name");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    private boolean isLockedShipmentStatus(String statusName) {
        if (statusName == null) {
            return false;
        }

        String normalizedStatus = statusName.trim().toLowerCase();
        return normalizedStatus.contains("hủy")
                || normalizedStatus.contains("huy")
                || normalizedStatus.contains("đã giao")
                || normalizedStatus.contains("da giao")
                || normalizedStatus.contains("thất bại")
                || normalizedStatus.contains("that bai");
    }

    private Integer findShipmentId(int orderId) throws SQLException {
        String sql = "SELECT shipment_id FROM shipments WHERE order_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("shipment_id");
                }
            }
        }

        return null;
    }

    private void insertShipment(int orderId, String trackingCode, String shipmentStatus, String note) throws SQLException {
        String sql = """
                     INSERT INTO shipments(order_id, tracking_code, shipment_status, note)
                     VALUES (?, ?, ?, ?)
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, trackingCode);
            ps.setString(3, shipmentStatus);
            ps.setString(4, note);
            ps.executeUpdate();
        }
    }

    private void updateShipmentStatusAndNote(int shipmentId, String shipmentStatus, String note) throws SQLException {
        String sql = """
                     UPDATE shipments
                     SET shipment_status = ?,
                         note = ?
                     WHERE shipment_id = ?
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, shipmentStatus);
            ps.setString(2, note);
            ps.setInt(3, shipmentId);
            ps.executeUpdate();
        }
    }

    private void updateOrderStatus(int orderId, int statusId) throws SQLException {
        String sql = "UPDATE orders SET status_id = ?";
        if (statusId == 5) {
            sql += ", received_date = CURRENT_TIMESTAMP";
        }
        sql += " WHERE order_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, statusId);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }

    private void setParameters(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                ps.setInt(i + 1, (Integer) value);
            } else {
                ps.setString(i + 1, String.valueOf(value));
            }
        }
    }

    private BigDecimal nullToZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private int getNullableInt(ResultSet rs, String columnName) throws SQLException {
        int value = rs.getInt(columnName);
        return rs.wasNull() ? 0 : value;
    }

}
