package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.WarrantyLookupItem;
import model.WarrantyLookupResult;

public class WarrantyLookupDAO extends DBContext {

    public WarrantyLookupResult findByOrderIdAndCustomerId(int orderId, int customerId) {
        String sql = """
            SELECT o.order_id,
                   o.customer_id,
                   o.order_date,
                   o.total_amount,
                   o.payment_method,
                   o.payment_status,
                   os.status_name AS order_status_name,
                   od.order_detail_id,
                   od.product_id,
                   od.quantity,
                   p.product_name,
                   p.image_url,
                   COALESCE(od.warranty_months, 0) AS warranty_months,
                   br.brand_name,
                   ca.category_name,
                   DATE_ADD(o.order_date, INTERVAL COALESCE(od.warranty_months, 0) MONTH) AS warranty_end_date,
                   DATEDIFF(DATE_ADD(o.order_date, INTERVAL COALESCE(od.warranty_months, 0) MONTH), CURDATE()) AS remaining_days
            FROM orders o
            INNER JOIN orders_status os ON o.status_id = os.status_id
            INNER JOIN order_details od ON o.order_id = od.order_id
            INNER JOIN products p ON od.product_id = p.product_id
            INNER JOIN brands br ON p.brand_id = br.brand_id
            INNER JOIN categories ca ON p.category_id = ca.category_id
            WHERE o.order_id = ?
              AND o.customer_id = ?
            ORDER BY od.order_detail_id
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                WarrantyLookupResult result = null;

                while (rs.next()) {
                    if (result == null) {
                        result = mapResult(rs);
                    }

                    result.addItem(mapItem(rs));
                }

                return result;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    private WarrantyLookupResult mapResult(ResultSet rs) throws SQLException {
        WarrantyLookupResult result = new WarrantyLookupResult();
        result.setOrderId(rs.getInt("order_id"));
        result.setCustomerId(rs.getInt("customer_id"));
        result.setOrderDate(rs.getTimestamp("order_date"));
        result.setTotalAmount(rs.getBigDecimal("total_amount"));
        result.setPaymentMethod(rs.getString("payment_method"));
        result.setPaymentStatus(rs.getString("payment_status"));
        result.setOrderStatusName(rs.getString("order_status_name"));
        return result;
    }

    private WarrantyLookupItem mapItem(ResultSet rs) throws SQLException {
        WarrantyLookupItem item = new WarrantyLookupItem();
        item.setOrderDetailId(rs.getInt("order_detail_id"));
        item.setProductId(rs.getInt("product_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setProductName(rs.getString("product_name"));
        item.setImageUrl(rs.getString("image_url"));
        item.setWarrantyMonths(rs.getInt("warranty_months"));
        item.setBrandName(rs.getString("brand_name"));
        item.setCategoryName(rs.getString("category_name"));
        item.setWarrantyEndDate(rs.getDate("warranty_end_date"));
        item.setRemainingDays(rs.getLong("remaining_days"));
        return item;
    }
}
