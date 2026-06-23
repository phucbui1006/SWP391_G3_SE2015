package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Product;

public class ProductDAO extends DBContext {

    private static final String PRODUCT_SELECT = """
            SELECT p.product_id,
                   p.product_name,
                   p.price,
                   COALESCE(stock.quantity, 0) AS quantity,
                   COALESCE(stock.batch_id, 0) AS batch_id,
                   p.description,
                   p.image_url,
                   COALESCE(p.warranty_months, 0) AS warranty_months,
                   p.status,
                   p.brand_id,
                   p.category_id,
                   br.brand_name,
                   br.status AS brand_status,
                   c.category_name,
                   c.status AS category_status
            FROM products p
            LEFT JOIN (
                SELECT product_id,
                       SUM(quantity) AS quantity,
                       MIN(batch_id) AS batch_id
                FROM batch_items
                GROUP BY product_id
            ) stock ON stock.product_id = p.product_id
            JOIN brands br ON p.brand_id = br.brand_id
            JOIN categories c ON p.category_id = c.category_id
            """;

    private Product mapProduct(ResultSet rs) throws Exception {
        Product p = new Product();

        p.setProductId(rs.getInt("product_id"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setQuantity(rs.getInt("quantity"));
        p.setBatchId(rs.getInt("batch_id"));
        p.setDescription(rs.getString("description"));
        p.setImageUrl(rs.getString("image_url"));
        p.setWarrantyMonths(rs.getInt("warranty_months"));
        p.setProductName(rs.getString("product_name"));
        p.setStatus(rs.getString("status"));
        p.setBrandId(rs.getInt("brand_id"));
        p.setCategoryId(rs.getInt("category_id"));
        p.setBrandName(rs.getString("brand_name"));
        p.setBrandStatus(rs.getString("brand_status"));
        p.setCategoryName(rs.getString("category_name"));
        p.setCategoryStatus(rs.getString("category_status"));

        return p;
    }

    private String getActiveProductCondition() {
        return " p.status = 'ACTIVE' AND br.status = 'ACTIVE' AND c.status = 'ACTIVE' ";
    }

    private String getOrderBy(String sort) {
        if ("price_asc".equals(sort)) {
            return " ORDER BY p.price ASC ";
        } else if ("price_desc".equals(sort)) {
            return " ORDER BY p.price DESC ";
        } else {
            return " ORDER BY p.product_id DESC ";
        }
    }

    public List<Product> getAllProducts(String sort) {
        List<Product> list = new ArrayList<>();
        String sql = PRODUCT_SELECT
                + "WHERE " + getActiveProductCondition()
                + getOrderBy(sort);

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> getAllProducts() {
        return getAllProducts("newest");
    }

    public List<Product> searchProducts(String keyword, String sort) {
        List<Product> list = new ArrayList<>();

        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllProducts(sort);
        }

        String sql = PRODUCT_SELECT
                + "WHERE " + getActiveProductCondition()
                + "AND (p.product_name LIKE ? "
                + "OR br.brand_name LIKE ? "
                + "OR c.category_name LIKE ?) "
                + getOrderBy(sort);

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            String searchValue = "%" + keyword.trim() + "%";

            ps.setString(1, searchValue);
            ps.setString(2, searchValue);
            ps.setString(3, searchValue);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Product getProductById(int productId) {
        String sql = PRODUCT_SELECT
                + "WHERE p.product_id = ? "
                + "AND " + getActiveProductCondition();

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapProduct(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<Product> getProductsByCategoryId(int categoryId) {
        return getProductsByCategoryId(categoryId, "newest");
    }

    public List<Product> getProductsByCategoryId(int categoryId, String sort) {
        List<Product> list = new ArrayList<>();
        String sql = PRODUCT_SELECT
                + "WHERE p.category_id = ? AND " + getActiveProductCondition()
                + getOrderBy(sort);

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, categoryId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> getProductsByCategoryIdForAdmin(int categoryId, String statusFilter) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(PRODUCT_SELECT);
        sql.append(" WHERE p.category_id = ? ");

        if ("ACTIVE".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND p.status = 'ACTIVE' ");
        } else if ("INACTIVE".equalsIgnoreCase(statusFilter)) {
            sql.append(" AND p.status = 'INACTIVE' ");
        }

        sql.append(" ORDER BY p.product_id DESC ");

        try {
            PreparedStatement ps = connection.prepareStatement(sql.toString());
            ps.setInt(1, categoryId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }


    public List<Product> getProductsByBrand(Integer brandId, String priceRange, String sort) {
        return getProductsByBrand(brandId, priceRange, sort, null);
    }

    public List<Product> getProductsByBrand(Integer brandId, String priceRange, String sort, String keyword) {
        List<Product> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        String sql = PRODUCT_SELECT
                + "WHERE " + getActiveProductCondition();

        if (brandId != null) {
            sql += "AND p.brand_id = ? ";
            params.add(brandId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND LOWER(p.product_name) LIKE LOWER(?) ";
            params.add("%" + keyword.trim() + "%");
        }

        if ("under5".equals(priceRange)) {
            sql += "AND p.price < ? ";
            params.add(5000000);
        } else if ("5to10".equals(priceRange)) {
            sql += "AND p.price BETWEEN ? AND ? ";
            params.add(5000000);
            params.add(10000000);
        } else if ("10to20".equals(priceRange)) {
            sql += "AND p.price BETWEEN ? AND ? ";
            params.add(10000000);
            params.add(20000000);
        } else if ("over20".equals(priceRange)) {
            sql += "AND p.price > ? ";
            params.add(20000000);
        }

        sql += getOrderBy(sort);

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public double getAverageRating(int productId) {
        String sql = """
            SELECT AVG(rating) AS avg_rating
            FROM reviews
            WHERE product_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                double avg = rs.getDouble("avg_rating");

                if (rs.wasNull()) {
                    return 0;
                }

                return avg;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public List<Product> getProductsByKeyword(String keyword, String sort) {
        List<Product> list = new ArrayList<>();

        String sql = """
        SELECT *
        FROM products
        WHERE UPPER(status) = 'ACTIVE'
        AND LOWER(product_name) LIKE LOWER(?)
    """;

        if ("price_asc".equals(sort)) {
            sql += " ORDER BY price ASC";
        } else if ("price_desc".equals(sort)) {
            sql += " ORDER BY price DESC";
        } else {
            sql += " ORDER BY product_id DESC";
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, "%" + keyword.trim() + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();

                p.setProductId(rs.getInt("product_id"));
                p.setProductName(rs.getString("product_name"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setQuantity(rs.getInt("quantity"));
                p.setImageUrl(rs.getString("image_url"));

                list.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> getProductsByCategoryAndKeyword(int categoryId,
            String keyword,
            String sort) {
        List<Product> list = new ArrayList<>();

        String sql = """
        SELECT *
        FROM products
        WHERE category_id = ?
        AND status = 'ACTIVE'
        AND LOWER(product_name) LIKE LOWER(?)
    """;

        if ("price_asc".equals(sort)) {
            sql += " ORDER BY price ASC";
        } else if ("price_desc".equals(sort)) {
            sql += " ORDER BY price DESC";
        } else {
            sql += " ORDER BY product_id DESC";
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, categoryId);
            ps.setString(2, "%" + keyword.trim() + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();

                p.setProductId(rs.getInt("product_id"));
                p.setProductName(rs.getString("product_name"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setQuantity(rs.getInt("quantity"));
                p.setImageUrl(rs.getString("image_url"));

                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean updateProductStatus(int productId, String status) {
        String sql = """
            UPDATE products
            SET status = ?
            WHERE product_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, productId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteProduct(int productId) {
        return updateProductStatus(productId, "INACTIVE");
    }

    public boolean activateProduct(int productId) {
        return updateProductStatus(productId, "ACTIVE");
    }

    public List<Product> getSimilarProducts(int productId) {
        List<Product> list = new ArrayList<>();

        String sql = PRODUCT_SELECT
                + "WHERE p.product_id <> ? "
                + "AND p.category_id = ( "
                + "    SELECT category_id "
                + "    FROM products "
                + "    WHERE product_id = ? "
                + ") "
                + "AND " + getActiveProductCondition()
                + "ORDER BY p.product_id ASC "
                + "LIMIT 4";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, productId);
            ps.setInt(2, productId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapProduct(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean verifyProductInCategory(int productId, int categoryId) {
        String sql = "SELECT COUNT(*) FROM products WHERE product_id = ? AND category_id = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);
            ps.setInt(2, categoryId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}

