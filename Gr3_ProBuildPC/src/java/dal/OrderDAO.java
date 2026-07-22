package dal;

import java.util.ArrayList;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
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

            String insertOrderDetailSql = """
                                          INSERT INTO order_details (
                                              order_id,
                                              product_id,
                                              quantity,
                                              unit_price,
                                              subtotal
                                          )
                                          VALUES (?, ?, ?, ?, ?)
                                          """;

            try (PreparedStatement ps = connection.prepareStatement(insertOrderDetailSql)) {
                for (CartItem item : items) {
                    Product product = item.getProduct();
                    if (product == null || product.getPrice() == null) {
                        connection.rollback();
                        return -1;
                    }

                    ps.setInt(1, orderId);
                    ps.setInt(2, item.getProductId());
                    ps.setInt(3, item.getQuantity());
                    ps.setBigDecimal(4, product.getPrice());
                    ps.setBigDecimal(5, item.getLineTotal());
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

            if (!reserveStockForOrder(orderId)) {
                connection.rollback();
                return false;
            }

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
            try (PreparedStatement ps = connection.prepareStatement(updateOrderSql)) {
                ps.setInt(1, STATUS_CANCELLED);
                ps.setString(2, paymentStatus);
                ps.setInt(3, orderId);
                ps.setString(4, PAYMENT_METHOD_VNPAY);
                ps.setInt(5, STATUS_WAITING_CONFIRMATION);
                ps.setString(6, PAYMENT_STATUS_PENDING);

                return ps.executeUpdate() == 1;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
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
                           """;

        try (PreparedStatement psSelect = connection.prepareStatement(selectSql)) {
            psSelect.setInt(1, STATUS_WAITING_CONFIRMATION);
            psSelect.setString(2, PAYMENT_STATUS_PENDING);
            psSelect.setString(3, PAYMENT_METHOD_VNPAY);

            try (ResultSet rs = psSelect.executeQuery()) {
                while (rs.next()) {
                    int orderId = rs.getInt("order_id");
                    if (cancelPendingVnpayOrder(orderId, PAYMENT_STATUS_FAILED)) {
                        cancelledIds.add(orderId);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
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

    private boolean releaseStockInternal(int orderId) throws SQLException {
        String selectDetailsSql = """
                                  SELECT product_id, SUM(quantity) AS total_quantity
                                  FROM order_details
                                  WHERE order_id = ?
                                  GROUP BY product_id
                                  """;
        String findBatchSql = """
                              SELECT batch_item_id
                              FROM batch_items
                              WHERE product_id = ?
                              ORDER BY batch_item_id ASC
                              LIMIT 1
                              """;
        String updateBatchSql = """
                                UPDATE batch_items
                                SET quantity = quantity + ?
                                WHERE batch_item_id = ?
                                """;

        Map<Integer, Integer> quantitiesByProduct = new LinkedHashMap<>();
        try (PreparedStatement psSelect = connection.prepareStatement(selectDetailsSql)) {
            psSelect.setInt(1, orderId);
            try (ResultSet rs = psSelect.executeQuery()) {
                while (rs.next()) {
                    quantitiesByProduct.put(rs.getInt("product_id"), rs.getInt("total_quantity"));
                }
            }
        }

        if (quantitiesByProduct.isEmpty()) {
            return true;
        }

        try (PreparedStatement psFindBatch = connection.prepareStatement(findBatchSql);
             PreparedStatement psUpdateBatch = connection.prepareStatement(updateBatchSql)) {
            for (Map.Entry<Integer, Integer> entry : quantitiesByProduct.entrySet()) {
                psFindBatch.setInt(1, entry.getKey());
                try (ResultSet rs = psFindBatch.executeQuery()) {
                    if (!rs.next()) {
                        return false;
                    }

                    int batchItemId = rs.getInt("batch_item_id");
                    psUpdateBatch.setInt(1, entry.getValue());
                    psUpdateBatch.setInt(2, batchItemId);
                    if (psUpdateBatch.executeUpdate() != 1) {
                        return false;
                    }
                }
            }
        }

        return true;
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

    /**
     * Employee xác nhận đơn COD. Trừ kho và chuyển status 1 → 2.
     * @return null nếu thành công, hoặc String thông báo lỗi chi tiết SP thiếu kho.
     */
    public String confirmCodOrder(int orderId) {
        String checkOrderSql = """
                               SELECT payment_method, status_id
                               FROM orders
                               WHERE order_id = ?
                               """;
        String updateOrderSql = """
                                UPDATE orders
                                SET status_id = ?
                                WHERE order_id = ?
                                  AND status_id = ?
                                """;

        try {
            connection.setAutoCommit(false);

            // Kiểm tra đơn hàng hợp lệ
            try (PreparedStatement ps = connection.prepareStatement(checkOrderSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        connection.rollback();
                        return "Không tìm thấy đơn hàng.";
                    }
                    int currentStatus = rs.getInt("status_id");
                    if (currentStatus != STATUS_WAITING_CONFIRMATION) {
                        connection.rollback();
                        return "Đơn hàng không ở trạng thái Chờ xác nhận.";
                    }
                }
            }

            // Kiểm tra tồn kho trước khi trừ
            List<String> stockErrors = checkStockForOrder(orderId);
            if (!stockErrors.isEmpty()) {
                connection.rollback();
                StringBuilder message = new StringBuilder("Không thể xác nhận đơn hàng. Các sản phẩm sau không đủ tồn kho:");
                for (String error : stockErrors) {
                    message.append("\n- ").append(error);
                }
                return message.toString();
            }

            // Trừ kho
            if (!reserveStockForOrder(orderId)) {
                connection.rollback();
                return "Lỗi khi trừ kho. Vui lòng thử lại.";
            }

            // Chuyển trạng thái sang Đã xác nhận
            try (PreparedStatement ps = connection.prepareStatement(updateOrderSql)) {
                ps.setInt(1, STATUS_CONFIRMED);
                ps.setInt(2, orderId);
                ps.setInt(3, STATUS_WAITING_CONFIRMATION);
                if (ps.executeUpdate() != 1) {
                    connection.rollback();
                    return "Không thể cập nhật trạng thái đơn hàng.";
                }
            }

            connection.commit();
            return null; // Thành công
        } catch (SQLException e) {
            rollbackQuietly();
            e.printStackTrace();
            return "Lỗi hệ thống khi xác nhận đơn hàng.";
        } finally {
            resetAutoCommit();
        }
    }

    /**
     * Kiểm tra tồn kho cho đơn hàng. Trả về danh sách SP thiếu kho.
     */
    public List<String> checkStockForOrder(int orderId) throws SQLException {
        List<String> errors = new ArrayList<>();
        String sql = """
                     SELECT od.product_id, od.quantity AS ordered_qty, p.product_name,
                            COALESCE(SUM(bi.quantity), 0) AS available_qty
                     FROM order_details od
                     INNER JOIN products p ON p.product_id = od.product_id
                     LEFT JOIN batch_items bi ON bi.product_id = od.product_id AND bi.quantity > 0
                     WHERE od.order_id = ?
                     GROUP BY od.product_id, od.quantity, p.product_name
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int orderedQty = rs.getInt("ordered_qty");
                    int availableQty = rs.getInt("available_qty");
                    if (availableQty < orderedQty) {
                        String productName = rs.getString("product_name");
                        errors.add(productName + ": cần " + orderedQty + ", kho còn " + availableQty);
                    }
                }
            }
        }

        return errors;
    }

    /**
     * Trừ kho cho tất cả SP trong đơn hàng.
     */
    private boolean reserveStockForOrder(int orderId) throws SQLException {
        String sql = "SELECT product_id, quantity FROM order_details WHERE order_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    if (!reserveStock(rs.getInt("product_id"), rs.getInt("quantity"))) {
                        return false;
                    }
                }
            }
        }
        return true;
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
