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

    public boolean createOrder(
            int customerId,
            Address shippingAddress,
            String paymentMethod,
            String paymentStatus,
            String note,
            List<CartItem> items,
            List<Integer> cartItemIdsToRemove) {

        if (shippingAddress == null || items == null || items.isEmpty()) {
            return false;
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
                ps.setInt(2, DEFAULT_STATUS_ID);
                ps.setBigDecimal(3, totalAmount);
                ps.setString(4, buildShippingAddressValue(shippingAddress));
                ps.setString(5, paymentMethod);
                ps.setString(6, paymentStatus);
                ps.setString(7, normalizeText(note));
                ps.executeUpdate();

                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (!rs.next()) {
                        connection.rollback();
                        return false;
                    }

                    orderId = rs.getInt(1);
                }
            }

            try (PreparedStatement ps = connection.prepareStatement(insertOrderDetailSql)) {
                for (CartItem item : items) {
                    Product product = item.getProduct();
                    if (product == null || product.getPrice() == null) {
                        connection.rollback();
                        return false;
                    }

                    if (!reserveStock(item.getProductId(), item.getQuantity())) {
                        connection.rollback();
                        return false;
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
            return true;
        } catch (SQLException e) {
            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (SQLException rollbackException) {
                rollbackException.printStackTrace();
            }

            e.printStackTrace();
            return false;
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

    private static class BatchStock {

        private final int batchItemId;
        private final int quantity;

        private BatchStock(int batchItemId, int quantity) {
            this.batchItemId = batchItemId;
            this.quantity = quantity;
        }
    }
}
