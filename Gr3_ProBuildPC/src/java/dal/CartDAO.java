package dal;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.Product;

public class CartDAO extends DBContext {

    public List<CartItem> getCartItemsByUserId(int userId) {
        List<CartItem> cartItems = new ArrayList<>();
        String sql = "SELECT ci.cart_item_id, ci.cart_id, ci.product_id, ci.quantity, "
                + "p.price, p.quantity AS stock_quantity, p.batch_id, p.description, "
                + "p.image_url, p.warranty_months, p.product_name "
                + "FROM cart c "
                + "INNER JOIN cart_items ci ON c.cart_id = ci.cart_id "
                + "INNER JOIN products p ON ci.product_id = p.product_id "
                + "WHERE c.user_id = ? "
                + "ORDER BY ci.cart_item_id";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    cartItems.add(mapCartItem(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return cartItems;
    }

    public int getCartItemCountByUserId(int userId) {
        String sql = "SELECT COALESCE(SUM(ci.quantity), 0) AS cart_count "
                + "FROM cart c "
                + "LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id "
                + "WHERE c.user_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cart_count");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    public BigDecimal calculateSubtotal(List<CartItem> cartItems) {
        BigDecimal subtotal = BigDecimal.ZERO;

        for (CartItem item : cartItems) {
            subtotal = subtotal.add(item.getLineTotal());
        }

        return subtotal;
    }

    private CartItem mapCartItem(ResultSet rs) throws SQLException {
        CartItem item = new CartItem(
                rs.getInt("cart_item_id"),
                rs.getInt("cart_id"),
                rs.getInt("product_id"),
                rs.getInt("quantity")
        );
        item.setProduct(mapProduct(rs));
        return item;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        return new Product(
                rs.getInt("product_id"),
                rs.getBigDecimal("price"),
                rs.getInt("stock_quantity"),
                rs.getInt("batch_id"),
                rs.getString("description"),
                rs.getString("image_url"),
                rs.getInt("warranty_months"),
                rs.getString("product_name")
        );
    }
}
