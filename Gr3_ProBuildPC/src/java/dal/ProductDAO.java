package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Product;

public class ProductDAO extends DBContext {

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

        return p;
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

        String orderBy;

        if ("price_asc".equals(sort)) {
            orderBy = " ORDER BY price ASC ";
        } else if ("price_desc".equals(sort)) {
            orderBy = " ORDER BY price DESC ";
        } else {
            orderBy = " ORDER BY product_id DESC ";
        }

        String sql
                = "SELECT product_id, product_name, price, quantity, batch_id, "
                + "description, image_url, warranty_months "
                + "FROM products "
                + orderBy;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();

                p.setProductId(rs.getInt("product_id"));
                p.setProductName(rs.getString("product_name"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setQuantity(rs.getInt("quantity"));
                p.setBatchId(rs.getInt("batch_id"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setWarrantyMonths(rs.getInt("warranty_months"));

                list.add(p);
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

        String sql
                = "SELECT p.product_id, p.product_name, p.price, p.quantity, p.batch_id, "
                + "p.description, p.image_url, p.warranty_months, "
                + "br.brand_name, c.category_name "
                + "FROM products p "
                + "JOIN batch b ON p.batch_id = b.batch_id "
                + "JOIN brands br ON b.brand_id = br.brand_id "
                + "JOIN categories c ON b.category_id = c.category_id "
                + "WHERE p.product_name LIKE ? "
                + "OR br.brand_name LIKE ? "
                + "OR c.category_name LIKE ? "
                + getOrderBy(sort);

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            String searchValue = "%" + keyword.trim() + "%";

            ps.setString(1, searchValue);
            ps.setString(2, searchValue);
            ps.setString(3, searchValue);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = mapProduct(rs);
                p.setBrandName(rs.getString("brand_name"));
                p.setCategoryName(rs.getString("category_name"));
                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Product getProductById(int productId) {
        String sql = """
            SELECT product_id, price, quantity, batch_id,
                   description, image_url, warranty_months, product_name
            FROM products
            WHERE product_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Product p = new Product();

                p.setProductId(rs.getInt("product_id"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setQuantity(rs.getInt("quantity"));
                p.setBatchId(rs.getInt("batch_id"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setWarrantyMonths(rs.getInt("warranty_months"));
                p.setProductName(rs.getString("product_name"));

                return p;
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

        String orderBy;

        if ("price_asc".equals(sort)) {
            orderBy = " ORDER BY p.price ASC ";
        } else if ("price_desc".equals(sort)) {
            orderBy = " ORDER BY p.price DESC ";
        } else {
            orderBy = " ORDER BY p.product_id DESC ";
        }

        String sql
                = "SELECT p.product_id, p.product_name, p.price, p.quantity, p.batch_id, "
                + "p.description, p.image_url, p.warranty_months "
                + "FROM products p "
                + "JOIN batch b ON p.batch_id = b.batch_id "
                + "WHERE b.category_id = ? "
                + orderBy;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, categoryId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();

                p.setProductId(rs.getInt("product_id"));
                p.setProductName(rs.getString("product_name"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setQuantity(rs.getInt("quantity"));
                p.setBatchId(rs.getInt("batch_id"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setWarrantyMonths(rs.getInt("warranty_months"));

                list.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Product> getProductsByBrand(Integer brandId, String priceRange, String sort) {
        List<Product> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        String sql
                = "SELECT p.product_id, p.product_name, p.price, p.quantity, p.batch_id, "
                + "p.description, p.image_url, p.warranty_months "
                + "FROM products p "
                + "JOIN batch b ON p.batch_id = b.batch_id "
                + "WHERE 1 = 1 ";

        if (brandId != null) {
            sql += "AND b.brand_id = ? ";
            params.add(brandId);
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

        String orderBy;

        if ("price_asc".equals(sort)) {
            orderBy = " ORDER BY p.price ASC ";
        } else if ("price_desc".equals(sort)) {
            orderBy = " ORDER BY p.price DESC ";
        } else {
            orderBy = " ORDER BY p.product_id DESC ";
        }

        String sql
                = "SELECT p.product_id, p.product_name, p.price, p.quantity, p.batch_id, "
                + "p.description, p.image_url, p.warranty_months "
                + "FROM products p "
                + "WHERE LOWER(p.product_name) LIKE LOWER(?) "
                + orderBy;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, "%" + keyword + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();

                p.setProductId(rs.getInt("product_id"));
                p.setProductName(rs.getString("product_name"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setQuantity(rs.getInt("quantity"));
                p.setBatchId(rs.getInt("batch_id"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setWarrantyMonths(rs.getInt("warranty_months"));

                list.add(p);
            }

        } catch (SQLException e) {
        }

        return list;
    }

    public List<Product> getProductsByCategoryAndKeyword(int categoryId, String keyword, String sort) {
        List<Product> list = new ArrayList<>();

        String orderBy;

        if ("price_asc".equals(sort)) {
            orderBy = " ORDER BY p.price ASC ";
        } else if ("price_desc".equals(sort)) {
            orderBy = " ORDER BY p.price DESC ";
        } else {
            orderBy = " ORDER BY p.product_id DESC ";
        }

        String sql
                = "SELECT p.product_id, p.product_name, p.price, p.quantity, p.batch_id, "
                + "p.description, p.image_url, p.warranty_months "
                + "FROM products p "
                + "JOIN batch b ON p.batch_id = b.batch_id "
                + "WHERE b.category_id = ? "
                + "AND LOWER(p.product_name) LIKE LOWER(?) "
                + orderBy;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, categoryId);
            ps.setString(2, "%" + keyword + "%");

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Product p = new Product();

                p.setProductId(rs.getInt("product_id"));
                p.setProductName(rs.getString("product_name"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setQuantity(rs.getInt("quantity"));
                p.setBatchId(rs.getInt("batch_id"));
                p.setDescription(rs.getString("description"));
                p.setImageUrl(rs.getString("image_url"));
                p.setWarrantyMonths(rs.getInt("warranty_months"));

                list.add(p);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }
}
