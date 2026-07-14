package dal;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import model.Address;
import model.CartItem;
import model.Product;

public class OrderDAO extends DBContext {

    private static final int STATUS_WAITING_CONFIRMATION = 1;
    private static final int STATUS_CONFIRMED = 2;
    private static final int STATUS_CANCELLED = 6;
    private static final String PAYMENT_METHOD_VNPAY = "VNPAY";
    private static final String PAYMENT_STATUS_PENDING = "Chờ thanh toán";
    private static final String PAYMENT_STATUS_PAID = "Đã thanh toán";
    private static final String PAYMENT_STATUS_FAILED = "Thất bại";

    public OrderDAO() {
        super();
        ensureStockReservationTable();
    }

    public int createOrder(
            int customerId,
            Address shippingAddress,
            String paymentMethod,
            String paymentStatus,
            int statusId,
            String note,
            List<CartItem> items,
            List<Integer> cartItemIdsToRemove) {

        if (shippingAddress == null || items == null || items.isEmpty()) {
            return -1;
        }

        if (cartItemIdsToRemove == null) {
            cartItemIdsToRemove = Collections.emptyList();
        }

        String insertOrderSql = """
                                INSERT INTO orders (
                                    customer_id,
                                    status_id,
                                    order_date,
                                    total_amount,
                                    shipping_address,
                                    payment_method,
                                    payment_status,
                                    note
                                )
                                VALUES (?, ?, NOW(), ?, ?, ?, ?, ?)
                                """;

        try {
            connection.setAutoCommit(false);

            int orderId;
            BigDecimal totalAmount = calculateTotalAmount(items);

            try (PreparedStatement ps = connection.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, customerId);
                ps.setInt(2, statusId);
                ps.setBigDecimal(3, totalAmount);
                ps.setString(4, buildShippingAddressValue(shippingAddress));
                ps.setString(5, paymentMethod);
                ps.setString(6, paymentStatus);
                ps.setString(7, normalizeText(note));
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) {
                        connection.rollback();
                        return -1;
                    }

                    orderId = rs.getInt(1);
                }
            }

            for (CartItem item : items) {
                Product product = item.getProduct();
                if (product == null || product.getPrice() == null) {
                    connection.rollback();
                    return -1;
                }

                List<BatchReservation> reservations = reserveStock(item.getProductId(), item.getQuantity());
                if (reservations == null || reservations.isEmpty()) {
                    connection.rollback();
                    return -1;
                }

                int orderDetailId = insertOrderDetail(orderId, item);
                if (orderDetailId <= 0) {
                    connection.rollback();
                    return -1;
                }

                if (!insertStockReservations(orderId, orderDetailId, item.getProductId(), reservations)) {
                    connection.rollback();
                    return -1;
                }
            }

            if (!cartItemIdsToRemove.isEmpty()) {
                removeSelectedCartItems(customerId, cartItemIdsToRemove);
            }

            connection.commit();
            return orderId;
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return -1;
        } finally {
            resetAutoCommit();
        }
    }

    public boolean updateOrderStatusAndPaymentStatus(int orderId, int statusId, String paymentStatus) {
        String sql = """
                     UPDATE orders
                     SET status_id = ?, payment_status = ?, vnpay_expires_at = NULL
                     WHERE order_id = ?
                     """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, statusId);
            ps.setString(2, paymentStatus);
            ps.setInt(3, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean createPaymentRecord(int orderId, String paymentStatus, String provider, BigDecimal amount) {
        String sql = """
                     INSERT INTO payments (order_id, payment_status, payment_provider, amount)
                     VALUES (?, ?, ?, ?)
                     ON DUPLICATE KEY UPDATE
                         payment_status = VALUES(payment_status),
                         payment_provider = VALUES(payment_provider),
                         amount = VALUES(amount)
                     """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, paymentStatus);
            ps.setString(3, provider);
            ps.setBigDecimal(4, amount);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean releaseStock(int orderId) {
        try {
            connection.setAutoCommit(false);
            boolean released = releaseStockInternal(orderId);
            if (!released) {
                connection.rollback();
                return false;
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return false;
        } finally {
            resetAutoCommit();
        }
    }

    public boolean setVnpayExpiresAt(int orderId, int minutes) {
        String sql = "UPDATE orders SET vnpay_expires_at = DATE_ADD(NOW(), INTERVAL ? MINUTE) WHERE order_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, minutes);
            ps.setInt(2, orderId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean extendVnpayExpiresAtForCustomer(int orderId, int customerId, int minutes) {
        String sql = """
                     UPDATE orders
                     SET vnpay_expires_at = DATE_ADD(NOW(), INTERVAL ? MINUTE)
                     WHERE order_id = ?
                       AND customer_id = ?
                       AND payment_method = ?
                       AND status_id = ?
                       AND payment_status = ?
                       AND (vnpay_expires_at IS NULL OR vnpay_expires_at >= NOW())
                     """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, minutes);
            ps.setInt(2, orderId);
            ps.setInt(3, customerId);
            ps.setString(4, PAYMENT_METHOD_VNPAY);
            ps.setInt(5, STATUS_WAITING_CONFIRMATION);
            ps.setString(6, PAYMENT_STATUS_PENDING);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public BigDecimal getOrderTotalAmount(int orderId) {
        String sql = "SELECT total_amount FROM orders WHERE order_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total_amount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public BigDecimal getOrderTotalAmountForCustomer(int orderId, int customerId) {
        String sql = "SELECT total_amount FROM orders WHERE order_id = ? AND customer_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total_amount");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public boolean confirmVnpayPayment(int orderId, BigDecimal amount) {
        String updateOrderSql = """
                                UPDATE orders
                                SET status_id = ?, payment_status = ?, vnpay_expires_at = NULL
                                WHERE order_id = ?
                                  AND payment_method = ?
                                  AND status_id = ?
                                  AND payment_status = ?
                                  AND (vnpay_expires_at IS NULL OR vnpay_expires_at >= NOW())
                                """;

        try {
            connection.setAutoCommit(false);

            try (PreparedStatement ps = connection.prepareStatement(updateOrderSql)) {
                ps.setInt(1, STATUS_CONFIRMED);
                ps.setString(2, PAYMENT_STATUS_PAID);
                ps.setInt(3, orderId);
                ps.setString(4, PAYMENT_METHOD_VNPAY);
                ps.setInt(5, STATUS_WAITING_CONFIRMATION);
                ps.setString(6, PAYMENT_STATUS_PENDING);

                if (ps.executeUpdate() != 1) {
                    connection.rollback();
                    return false;
                }
            }

            if (!createPaymentRecord(orderId, PAYMENT_STATUS_PAID, PAYMENT_METHOD_VNPAY, amount)) {
                connection.rollback();
                return false;
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return false;
        } finally {
            resetAutoCommit();
        }
    }

    public boolean cancelPendingVnpayOrder(int orderId, String paymentStatus) {
        String updateOrderSql = """
                                UPDATE orders
                                SET status_id = ?, payment_status = ?, vnpay_expires_at = NULL
                                WHERE order_id = ?
                                  AND payment_method = ?
                                  AND status_id = ?
                                  AND payment_status = ?
                                """;
        try {
            connection.setAutoCommit(false);

            try (PreparedStatement ps = connection.prepareStatement(updateOrderSql)) {
                ps.setInt(1, STATUS_CANCELLED);
                ps.setString(2, paymentStatus);
                ps.setInt(3, orderId);
                ps.setString(4, PAYMENT_METHOD_VNPAY);
                ps.setInt(5, STATUS_WAITING_CONFIRMATION);
                ps.setString(6, PAYMENT_STATUS_PENDING);

                if (ps.executeUpdate() != 1) {
                    connection.rollback();
                    return false;
                }
            }

            if (!releaseStockInternal(orderId)) {
                connection.rollback();
                return false;
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return false;
        } finally {
            resetAutoCommit();
        }
    }

    public boolean isVnpayOrderExpiredOrCancelled(int orderId) {
        String sql = """
                     SELECT 1
                     FROM orders
                     WHERE order_id = ?
                       AND payment_method = ?
                       AND (
                           status_id = ?
                           OR (vnpay_expires_at IS NOT NULL AND vnpay_expires_at < NOW())
                       )
                     """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setString(2, PAYMENT_METHOD_VNPAY);
            ps.setInt(3, STATUS_CANCELLED);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Integer> cancelExpiredVnpayOrders() {
        List<Integer> cancelledIds = new ArrayList<>();
        String selectSql = """
                           SELECT order_id
                           FROM orders
                           WHERE status_id = ?
                             AND payment_status = ?
                             AND payment_method = ?
                             AND vnpay_expires_at IS NOT NULL
                             AND vnpay_expires_at <= NOW()
                           FOR UPDATE
                           """;
        String updateSql = """
                           UPDATE orders
                           SET status_id = ?, payment_status = ?, vnpay_expires_at = NULL
                           WHERE order_id = ?
                           """;

        try {
            connection.setAutoCommit(false);

            List<Integer> expiredOrderIds = new ArrayList<>();
            try (PreparedStatement psSelect = connection.prepareStatement(selectSql)) {
                psSelect.setInt(1, STATUS_WAITING_CONFIRMATION);
                psSelect.setString(2, PAYMENT_STATUS_PENDING);
                psSelect.setString(3, PAYMENT_METHOD_VNPAY);

                try (ResultSet rs = psSelect.executeQuery()) {
                    while (rs.next()) {
                        expiredOrderIds.add(rs.getInt("order_id"));
                    }
                }
            }

            try (PreparedStatement psUpdate = connection.prepareStatement(updateSql)) {
                for (Integer orderId : expiredOrderIds) {
                    psUpdate.setInt(1, STATUS_CANCELLED);
                    psUpdate.setString(2, PAYMENT_STATUS_FAILED);
                    psUpdate.setInt(3, orderId);

                    if (psUpdate.executeUpdate() == 1 && releaseStockInternal(orderId)) {
                        cancelledIds.add(orderId);
                    } else {
                        connection.rollback();
                        return Collections.emptyList();
                    }
                }
            }

            connection.commit();
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            resetAutoCommit();
        }

        return cancelledIds;
    }

    private BigDecimal calculateTotalAmount(List<CartItem> items) {
        BigDecimal total = BigDecimal.ZERO;

        for (CartItem item : items) {
            total = total.add(item.getLineTotal());
        }

        return total;
    }

    private List<BatchReservation> reserveStock(int productId, int requestedQuantity) throws SQLException {
        if (requestedQuantity <= 0) {
            return null;
        }

        String selectSql = """
                           SELECT bi.batch_item_id, bi.quantity
                           FROM batch_items bi
                           INNER JOIN batch b ON bi.batch_id = b.batch_id
                           WHERE bi.product_id = ?
                             AND bi.quantity > 0
                           ORDER BY b.date ASC, bi.batch_item_id ASC
                           FOR UPDATE
                           """;

        List<BatchStock> availableBatches = new ArrayList<>();
        int remainingQuantity = requestedQuantity;

        try (PreparedStatement ps = connection.prepareStatement(selectSql)) {
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next() && remainingQuantity > 0) {
                    int availableQuantity = rs.getInt("quantity");
                    availableBatches.add(new BatchStock(rs.getInt("batch_item_id"), availableQuantity));
                    remainingQuantity -= availableQuantity;
                }
            }
        }

        if (remainingQuantity > 0) {
            return null;
        }

        String updateSql = """
                           UPDATE batch_items
                           SET quantity = quantity - ?
                           WHERE batch_item_id = ?
                             AND quantity >= ?
                           """;

        List<BatchReservation> reservations = new ArrayList<>();
        int quantityToReserve = requestedQuantity;
        try (PreparedStatement ps = connection.prepareStatement(updateSql)) {
            for (BatchStock batchStock : availableBatches) {
                int deductedQuantity = Math.min(quantityToReserve, batchStock.quantity);
                if (deductedQuantity <= 0) {
                    break;
                }

                ps.setInt(1, deductedQuantity);
                ps.setInt(2, batchStock.batchItemId);
                ps.setInt(3, deductedQuantity);

                if (ps.executeUpdate() != 1) {
                    return null;
                }

                reservations.add(new BatchReservation(batchStock.batchItemId, deductedQuantity));
                quantityToReserve -= deductedQuantity;
            }
        }

        return quantityToReserve == 0 ? reservations : null;
    }

    private int insertOrderDetail(int orderId, CartItem item) throws SQLException {
        String sql = """
                     INSERT INTO order_details (
                         order_id,
                         product_id,
                         quantity,
                         unit_price,
                         subtotal
                     )
                     VALUES (?, ?, ?, ?, ?)
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, orderId);
            ps.setInt(2, item.getProductId());
            ps.setInt(3, item.getQuantity());
            ps.setBigDecimal(4, item.getProduct().getPrice());
            ps.setBigDecimal(5, item.getLineTotal());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return -1;
    }

    private boolean insertStockReservations(int orderId, int orderDetailId, int productId, List<BatchReservation> reservations)
            throws SQLException {
        String sql = """
                     INSERT INTO order_stock_reservations (
                         order_id,
                         order_detail_id,
                         product_id,
                         batch_item_id,
                         reserved_quantity
                     )
                     VALUES (?, ?, ?, ?, ?)
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            for (BatchReservation reservation : reservations) {
                ps.setInt(1, orderId);
                ps.setInt(2, orderDetailId);
                ps.setInt(3, productId);
                ps.setInt(4, reservation.batchItemId);
                ps.setInt(5, reservation.quantity);
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            for (int result : results) {
                if (result == Statement.EXECUTE_FAILED) {
                    return false;
                }
            }
            return true;
        }
    }

    private boolean releaseStockInternal(int orderId) throws SQLException {
        String selectSql = """
                           SELECT reservation_id, batch_item_id, reserved_quantity
                           FROM order_stock_reservations
                           WHERE order_id = ?
                             AND released_at IS NULL
                           FOR UPDATE
                           """;
        String updateBatchSql = """
                                UPDATE batch_items
                                SET quantity = quantity + ?
                                WHERE batch_item_id = ?
                                """;
        String updateReservationSql = """
                                      UPDATE order_stock_reservations
                                      SET released_at = NOW()
                                      WHERE reservation_id = ?
                                      """;

        List<BatchReservationRow> reservations = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(selectSql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(new BatchReservationRow(
                            rs.getInt("reservation_id"),
                            rs.getInt("batch_item_id"),
                            rs.getInt("reserved_quantity")));
                }
            }
        }

        if (reservations.isEmpty()) {
            return true;
        }

        try (PreparedStatement psBatch = connection.prepareStatement(updateBatchSql);
             PreparedStatement psReservation = connection.prepareStatement(updateReservationSql)) {
            for (BatchReservationRow reservation : reservations) {
                psBatch.setInt(1, reservation.quantity);
                psBatch.setInt(2, reservation.batchItemId);
                if (psBatch.executeUpdate() != 1) {
                    return false;
                }

                psReservation.setInt(1, reservation.reservationId);
                if (psReservation.executeUpdate() != 1) {
                    return false;
                }
            }
        }

        return true;
    }

    private void removeSelectedCartItems(int customerId, List<Integer> cartItemIds) throws SQLException {
        StringBuilder sql = new StringBuilder();
        sql.append("DELETE ci ");
        sql.append("FROM cart_items ci ");
        sql.append("INNER JOIN cart c ON c.cart_id = ci.cart_id ");
        sql.append("WHERE c.customer_id = ? AND ci.cart_item_id IN (");

        for (int i = 0; i < cartItemIds.size(); i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append("?");
        }

        sql.append(")");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            ps.setInt(1, customerId);

            for (int i = 0; i < cartItemIds.size(); i++) {
                ps.setInt(i + 2, cartItemIds.get(i));
            }

            ps.executeUpdate();
        }
    }

    private String buildShippingAddressValue(Address address) {
        String recipientName = normalizeText(address.getRecipientName());
        String phoneNumber = normalizeText(address.getPhoneNumber());
        String addressDetail = normalizeText(address.getAddressDetail());

        StringBuilder value = new StringBuilder();

        if (!recipientName.isEmpty()) {
            value.append(recipientName);
        }

        if (!phoneNumber.isEmpty()) {
            if (value.length() > 0) {
                value.append(" - ");
            }
            value.append(phoneNumber);
        }

        if (!addressDetail.isEmpty()) {
            if (value.length() > 0) {
                value.append(" - ");
            }
            value.append(addressDetail);
        }

        String normalizedValue = value.toString().trim();
        if (normalizedValue.length() <= 255) {
            return normalizedValue;
        }

        return normalizedValue.substring(0, 255);
    }

    private String normalizeText(String value) {
        return value == null ? "" : value.trim();
    }

    private void ensureStockReservationTable() {
        String sql = """
                     CREATE TABLE IF NOT EXISTS order_stock_reservations (
                         reservation_id INT AUTO_INCREMENT PRIMARY KEY,
                         order_id INT NOT NULL,
                         order_detail_id INT NOT NULL,
                         product_id INT NOT NULL,
                         batch_item_id INT NOT NULL,
                         reserved_quantity INT NOT NULL,
                         released_at DATETIME NULL,
                         created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         CONSTRAINT fk_osr_orders
                             FOREIGN KEY (order_id) REFERENCES orders(order_id),
                         CONSTRAINT fk_osr_order_details
                             FOREIGN KEY (order_detail_id) REFERENCES order_details(order_detail_id),
                         CONSTRAINT fk_osr_products
                             FOREIGN KEY (product_id) REFERENCES products(product_id),
                         CONSTRAINT fk_osr_batch_items
                             FOREIGN KEY (batch_item_id) REFERENCES batch_items(batch_item_id)
                     )
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.execute();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private void rollbackQuietly() {
        try {
            if (connection != null) {
                connection.rollback();
            }
        } catch (SQLException rollbackException) {
            rollbackException.printStackTrace();
        }
    }

    private void resetAutoCommit() {
        try {
            if (connection != null) {
                connection.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private static class BatchStock {

        private final int batchItemId;
        private final int quantity;

        private BatchStock(int batchItemId, int quantity) {
            this.batchItemId = batchItemId;
            this.quantity = quantity;
        }
    }

    private static class BatchReservation {

        private final int batchItemId;
        private final int quantity;

        private BatchReservation(int batchItemId, int quantity) {
            this.batchItemId = batchItemId;
            this.quantity = quantity;
        }
    }

    private static class BatchReservationRow {

        private final int reservationId;
        private final int batchItemId;
        private final int quantity;

        private BatchReservationRow(int reservationId, int batchItemId, int quantity) {
            this.reservationId = reservationId;
            this.batchItemId = batchItemId;
            this.quantity = quantity;
        }
    }
}
