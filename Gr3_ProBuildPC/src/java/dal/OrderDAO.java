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

    private static final int DEFAULT_STATUS_ID = 1;

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

        String insertOrderDetailSql = """
                                      INSERT INTO order_details (
                                          order_id,
                                          product_id,
                                          quantity,
                                          unit_price,
                                          warranty_months,
                                          subtotal
                                      )
                                      VALUES (?, ?, ?, ?, ?, ?)
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

            try (PreparedStatement ps = connection.prepareStatement(insertOrderDetailSql)) {
                for (CartItem item : items) {
                    Product product = item.getProduct();
                    if (product == null || product.getPrice() == null) {
                        connection.rollback();
                        return -1;
                    }

                    if (!reserveStock(item.getProductId(), item.getQuantity())) {
                        connection.rollback();
                        return -1;
                    }

                    ps.setInt(1, orderId);
                    ps.setInt(2, item.getProductId());
                    ps.setInt(3, item.getQuantity());
                    ps.setBigDecimal(4, product.getPrice());
                    ps.setInt(5, product.getWarrantyMonths());
                    ps.setBigDecimal(6, item.getLineTotal());
                    ps.addBatch();
                }

                ps.executeBatch();
            }

            if (!cartItemIdsToRemove.isEmpty()) {
                removeSelectedCartItems(customerId, cartItemIdsToRemove);
            }

            connection.commit();
            return orderId;
        } catch (SQLException e) {
            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (SQLException rollbackException) {
                rollbackException.printStackTrace();
            }

            e.printStackTrace();
            return -1;
        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private BigDecimal calculateTotalAmount(List<CartItem> items) {
        BigDecimal total = BigDecimal.ZERO;

        for (CartItem item : items) {
            total = total.add(item.getLineTotal());
        }

        return total;
    }

    private boolean reserveStock(int productId, int requestedQuantity) throws SQLException {
        if (requestedQuantity <= 0) {
            return false;
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
            return false;
        }

        String updateSql = """
                           UPDATE batch_items
                           SET quantity = quantity - ?
                           WHERE batch_item_id = ?
                             AND quantity >= ?
                           """;

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
                    return false;
                }

                quantityToReserve -= deductedQuantity;
            }
        }

        return quantityToReserve == 0;
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

    public boolean updateOrderStatusAndPaymentStatus(int orderId, int statusId, String paymentStatus) {
        String sql = "UPDATE orders SET status_id = ?, payment_status = ? WHERE order_id = ?";
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
        String sql = "INSERT INTO payments (order_id, payment_status, payment_provider, amount) VALUES (?, ?, ?, ?)";
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
        String selectDetailsSql = "SELECT product_id, quantity FROM order_details WHERE order_id = ?";
        String updateBatchSql = """
                                UPDATE batch_items 
                                SET quantity = quantity + ? 
                                WHERE product_id = ? 
                                ORDER BY batch_item_id ASC 
                                LIMIT 1
                                """;
        try (PreparedStatement psSelect = connection.prepareStatement(selectDetailsSql)) {
            psSelect.setInt(1, orderId);
            try (ResultSet rs = psSelect.executeQuery()) {
                try (PreparedStatement psUpdate = connection.prepareStatement(updateBatchSql)) {
                    while (rs.next()) {
                        int productId = rs.getInt("product_id");
                        int quantity = rs.getInt("quantity");
                        psUpdate.setInt(1, quantity);
                        psUpdate.setInt(2, productId);
                        psUpdate.executeUpdate();
                    }
                }
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
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

    public java.math.BigDecimal getOrderTotalAmount(int orderId) {
        String sql = "SELECT total_amount FROM orders WHERE order_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getBigDecimal("total_amount");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return java.math.BigDecimal.ZERO;
    }

    /**
     * Tìm và hủy tất cả đơn VNPAY đã hết hạn (status=1, payment_status='Chờ thanh toán', quá vnpay_expires_at).
     * Trả về danh sách orderId đã hủy.
     */
    public java.util.List<Integer> cancelExpiredVnpayOrders() {
        java.util.List<Integer> cancelledIds = new java.util.ArrayList<>();
        String selectSql = """
            SELECT order_id FROM orders
            WHERE status_id = 1
              AND payment_status = 'Chờ thanh toán'
              AND payment_method = 'VNPAY'
              AND vnpay_expires_at IS NOT NULL
              AND vnpay_expires_at < NOW()
            """;
        String updateSql = "UPDATE orders SET status_id = 6, payment_status = 'Thất bại' WHERE order_id = ?";
        try (PreparedStatement psSelect = connection.prepareStatement(selectSql);
             ResultSet rs = psSelect.executeQuery()) {
            while (rs.next()) {
                int orderId = rs.getInt("order_id");
                try (PreparedStatement psUpdate = connection.prepareStatement(updateSql)) {
                    psUpdate.setInt(1, orderId);
                    if (psUpdate.executeUpdate() > 0) {
                        releaseStock(orderId);
                        cancelledIds.add(orderId);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cancelledIds;
    }

    private static class BatchStock {

        private final int batchItemId;
        private final int quantity;

        private BatchStock(int batchItemId, int quantity) {
            this.batchItemId = batchItemId;
            this.quantity = quantity;
        }
    }
}
