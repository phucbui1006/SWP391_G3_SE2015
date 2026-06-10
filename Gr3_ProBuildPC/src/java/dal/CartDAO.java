package dal;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.CartItem;
import model.Product;

public class CartDAO extends DBContext {

    public List<CartItem> getCartItemsByCustomerId(int customerId) {
        List<CartItem> cartItems = new ArrayList<>();
        String sql = "SELECT ci.cart_item_id, ci.cart_id, ci.product_id, ci.quantity, "
                + "p.price, p.quantity AS stock_quantity, p.batch_id, p.description, "
                + "p.image_url, p.warranty_months, p.product_name, "
                + "br.brand_name, ca.category_name "
                + "FROM cart c "
                + "INNER JOIN cart_items ci ON c.cart_id = ci.cart_id "
                + "INNER JOIN products p ON ci.product_id = p.product_id "
                + "INNER JOIN batch ba ON p.batch_id = ba.batch_id "
                + "INNER JOIN brands br ON ba.brand_id = br.brand_id "
                + "INNER JOIN categories ca ON ba.category_id = ca.category_id "
                + "WHERE c.customer_id = ? "
                + "ORDER BY ci.cart_item_id";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);

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

    public int getCartItemCountByCustomerId(int customerId) {
        String sql = "SELECT COALESCE(SUM(ci.quantity), 0) AS cart_count "
                + "FROM cart c "
                + "LEFT JOIN cart_items ci ON c.cart_id = ci.cart_id "
                + "WHERE c.customer_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);

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

    public boolean removeCartItemByCustomerId(int customerId, int cartItemId) {
        String sql = "DELETE ci "
                + "FROM cart_items ci "
                + "INNER JOIN cart c ON c.cart_id = ci.cart_id "
                + "WHERE c.customer_id = ? AND ci.cart_item_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, cartItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateCartItemQuantity(int cartItemId, int quantity) {
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, cartItemId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public int addCartItemForCustomer(int customerId, int productId, int quantity) {
        int cartId = getOrCreateCartIdByCustomerId(customerId);
        if (cartId <= 0) {
            return -1;
        }

        String sql = "INSERT INTO cart_items (cart_id, product_id, quantity) VALUES (?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);
            ps.setInt(3, quantity);

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }

                return findCartItemId(cartId, productId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }

    private int getOrCreateCartIdByCustomerId(int customerId) {
        String selectSql = "SELECT cart_id FROM cart WHERE customer_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(selectSql)) {
            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cart_id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return -1;
        }

        String insertSql = "INSERT INTO cart (customer_id) VALUES (?)";

        try (PreparedStatement ps = connection.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);

            int affectedRows = ps.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }

                return findCartIdByCustomerId(customerId);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return findCartIdByCustomerId(customerId);
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
        Product product = new Product(
                rs.getInt("product_id"),
                rs.getBigDecimal("price"),
                rs.getInt("stock_quantity"),
                rs.getInt("batch_id"),
                rs.getString("description"),
                rs.getString("image_url"),
                rs.getInt("warranty_months"),
                rs.getString("product_name")
        );

        product.setBrandName(rs.getString("brand_name"));
        product.setCategoryName(rs.getString("category_name"));

        return product;
    }

    private int findCartIdByCustomerId(int customerId) {
        String sql = "SELECT cart_id FROM cart WHERE customer_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cart_id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }

    private int findCartItemId(int cartId, int productId) {
        String sql = "SELECT cart_item_id FROM cart_items WHERE cart_id = ? AND product_id = ? ORDER BY cart_item_id DESC LIMIT 1";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cart_item_id");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return -1;
    }
}
