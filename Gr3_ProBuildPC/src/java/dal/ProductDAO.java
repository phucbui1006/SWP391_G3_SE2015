package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Product;

public class ProductDAO extends DBContext {

    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM PRODUCTS ORDER BY product_id";

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                products.add(mapProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    public Product getProductById(int productId) {
        String sql = "SELECT * FROM PRODUCTS WHERE product_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapProduct(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Product> searchProductsByName(String keyword) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM PRODUCTS WHERE product_name LIKE ? ORDER BY product_id";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "%" + keyword + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    public boolean addProduct(Product product) {
        String sql = "INSERT INTO PRODUCTS "
                + "(price, quantity, batch_id, description, image_url, warranty_months, product_name) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBigDecimal(1, product.getPrice());
            ps.setInt(2, product.getQuantity());
            ps.setInt(3, product.getBatchId());
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getImageUrl());
            ps.setInt(6, product.getWarrantyMonths());
            ps.setString(7, product.getProductName());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateProduct(Product product) {
        String sql = "UPDATE PRODUCTS "
                + "SET price = ?, quantity = ?, batch_id = ?, description = ?, "
                + "image_url = ?, warranty_months = ?, product_name = ? "
                + "WHERE product_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBigDecimal(1, product.getPrice());
            ps.setInt(2, product.getQuantity());
            ps.setInt(3, product.getBatchId());
            ps.setString(4, product.getDescription());
            ps.setString(5, product.getImageUrl());
            ps.setInt(6, product.getWarrantyMonths());
            ps.setString(7, product.getProductName());
            ps.setInt(8, product.getProductId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteProduct(int productId) {
        String sql = "DELETE FROM PRODUCTS WHERE product_id = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        return new Product(
                rs.getInt("product_id"),
                rs.getBigDecimal("price"),
                rs.getInt("quantity"),
                rs.getInt("batch_id"),
                rs.getString("description"),
                rs.getString("image_url"),
                rs.getInt("warranty_months"),
                rs.getString("product_name")
        );
    }
}
