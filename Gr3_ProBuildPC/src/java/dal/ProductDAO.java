package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;
import model.Product;
import model.ProductSpecification;

public class ProductDAO extends DBContext {

    private static final String PRODUCT_SELECT = """
            SELECT p.product_id,
                   p.product_name,
                   p.price,
                   COALESCE(stock.import_quantity, 0) AS import_quantity,
                   COALESCE(stock.quantity, 0) AS quantity,
                   COALESCE(sales.sold_quantity, 0) AS sold_quantity,
                   COALESCE(stock.batch_id, 0) AS batch_id,
                   p.description,
                   p.image_url,
                   p.warranty_months,
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
                       SUM(import_quantity) AS import_quantity,
                       SUM(quantity) AS quantity,
                       MIN(batch_id) AS batch_id
                FROM batch_items
                GROUP BY product_id
             ) stock ON stock.product_id = p.product_id
            LEFT JOIN (
                SELECT od.product_id,
                       SUM(od.quantity) AS sold_quantity
                FROM order_details od
                JOIN orders o ON o.order_id = od.order_id
                JOIN orders_status os ON os.status_id = o.status_id
                WHERE os.status_name = 'Đã giao hàng'
                GROUP BY od.product_id
            ) sales ON sales.product_id = p.product_id
            JOIN brands br ON p.brand_id = br.brand_id
            JOIN categories c ON p.category_id = c.category_id
            """;

    private Product mapProduct(ResultSet rs) throws Exception {
        Product p = new Product();

        p.setProductId(rs.getInt("product_id"));
        p.setPrice(rs.getBigDecimal("price"));
        p.setQuantity(rs.getInt("quantity"));
        p.setImportQuantity(rs.getInt("import_quantity"));
        p.setSoldQuantity(rs.getInt("sold_quantity"));
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
        } else if ("qty_asc".equals(sort)) {
            return " ORDER BY quantity ASC ";
        } else if ("qty_desc".equals(sort)) {
            return " ORDER BY quantity DESC ";
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
        }

        return null;
    }

    public Product getProductByIdForAdmin(int productId) {
        String sql = PRODUCT_SELECT + " WHERE p.product_id = ? ";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapProduct(rs);
            }
        } catch (Exception e) {
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
                + "WHERE " + getActiveProductCondition()
                + "AND COALESCE(stock.quantity, 0) > 0 ";

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
        }

        return list;
    }

    public List<Product> getProductsByCategory(Integer categoryId, String sort, String keyword) {
        List<Product> list = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        String sql = PRODUCT_SELECT
                + "WHERE " + getActiveProductCondition();

        if (categoryId != null) {
            sql += "AND p.category_id = ? ";
            params.add(categoryId);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND LOWER(p.product_name) LIKE LOWER(?) ";
            params.add("%" + keyword.trim() + "%");
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

        } catch (SQLException e) {
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

        } catch (SQLException e) {
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
        }
        return false;
    }

    public int countProductsForAdmin(String keyword, Integer categoryId, Integer brandId, String status) {
        StringBuilder sql = new StringBuilder("""
            SELECT COUNT(*) 
            FROM products p
            JOIN brands br ON p.brand_id = br.brand_id
            JOIN categories c ON p.category_id = c.category_id
            WHERE 1=1
        """);
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.product_name LIKE ? OR br.brand_name LIKE ? OR c.category_name LIKE ?) ");
            String searchVal = "%" + keyword.trim() + "%";
            params.add(searchVal);
            params.add(searchVal);
            params.add(searchVal);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ? ");
            params.add(categoryId);
        }
        if (brandId != null && brandId > 0) {
            sql.append(" AND p.brand_id = ? ");
            params.add(brandId);
        }
        if (status != null && !status.equalsIgnoreCase("ALL")) {
            sql.append(" AND p.status = ? ");
            params.add(status.toUpperCase());
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
        }
        return 0;
    }

    public List<Product> getProductsForAdmin(String keyword, Integer categoryId, Integer brandId, String status, String sort, int page, int pageSize) {
        List<Product> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(PRODUCT_SELECT);
        sql.append(" WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (p.product_name LIKE ? OR br.brand_name LIKE ? OR c.category_name LIKE ?) ");
            String searchVal = "%" + keyword.trim() + "%";
            params.add(searchVal);
            params.add(searchVal);
            params.add(searchVal);
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ? ");
            params.add(categoryId);
        }
        if (brandId != null && brandId > 0) {
            sql.append(" AND p.brand_id = ? ");
            params.add(brandId);
        }
        if (status != null && !status.equalsIgnoreCase("ALL")) {
            sql.append(" AND p.status = ? ");
            params.add(status.toUpperCase());
        }

        // Sorting
        if ("price_asc".equals(sort)) {
            sql.append(" ORDER BY p.price ASC ");
        } else if ("price_desc".equals(sort)) {
            sql.append(" ORDER BY p.price DESC ");
        } else if ("qty_asc".equals(sort)) {
            sql.append(" ORDER BY quantity ASC ");
        } else if ("qty_desc".equals(sort)) {
            sql.append(" ORDER BY quantity DESC ");
        } else if ("oldest".equals(sort)) {
            sql.append(" ORDER BY p.product_id ASC ");
        } else if ("bestSeller".equals(sort)) {
            sql.append(" ORDER BY sold_quantity DESC, p.product_id DESC ");
        } else {
            sql.append(" ORDER BY p.product_id DESC "); // newest default
        }

        // Paging
        sql.append(" LIMIT ? OFFSET ? ");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try {
            PreparedStatement ps = connection.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapProduct(rs));
            }
        } catch (Exception e) {
        }
        return list;
    }

    public boolean existsByProductNameExceptId(String productName, int productId) {
        if (productName == null || productName.trim().isEmpty()) {
            return false;
        }

        String sql = """
                SELECT 1
                FROM products
                WHERE LOWER(TRIM(product_name)) = LOWER(?)
                  AND product_id <> ?
                LIMIT 1
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, productName.trim());
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean existsByProductName(String productName) {
        if (productName == null || productName.trim().isEmpty()) {
            return false;
        }

        String sql = "SELECT 1 FROM products WHERE LOWER(TRIM(product_name)) = LOWER(?) LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, productName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean addProduct(String productName, int categoryId, int brandId, BigDecimal price, String description, String imageUrl, int warrantyMonths, String[] specNames, String[] specValues) {
        String sql = """
            INSERT INTO products (product_name, category_id, brand_id, price, description, image_url, warranty_months, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, 'ACTIVE')
        """;
        PreparedStatement psProduct = null;
        PreparedStatement psSpec = null;
        try {
            connection.setAutoCommit(false);

            psProduct = connection.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            psProduct.setString(1, productName);
            psProduct.setInt(2, categoryId);
            psProduct.setInt(3, brandId);
            psProduct.setBigDecimal(4, price);
            psProduct.setString(5, description);
            psProduct.setString(6, imageUrl);
            psProduct.setInt(7, warrantyMonths);

            int affected = psProduct.executeUpdate();
            if (affected == 0) {
                connection.rollback();
                return false;
            }

            int productId = 0;
            try (ResultSet generatedKeys = psProduct.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    productId = generatedKeys.getInt(1);
                } else {
                    connection.rollback();
                    return false;
                }
            }

            if (specNames != null && specValues != null) {
                String specSql = "INSERT INTO PRODUCT_SPECIFICATIONS (product_id, specification_name, specification_value) VALUES (?, ?, ?)";
                psSpec = connection.prepareStatement(specSql);

                int specLength = Math.min(specNames.length, specValues.length);
                for (int i = 0; i < specLength; i++) {
                    String name = specNames[i];
                    String value = specValues[i];

                    if (name != null && !name.trim().isEmpty() && value != null && !value.trim().isEmpty()) {
                        psSpec.setInt(1, productId);
                        psSpec.setString(2, name.trim());
                        psSpec.setString(3, value.trim());
                        psSpec.addBatch();
                    }
                }
                psSpec.executeBatch();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (SQLException ex) {
            }
        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                }
                if (psProduct != null) {
                    psProduct.close();
                }
                if (psSpec != null) {
                    psSpec.close();
                }
            } catch (SQLException e) {
            }
        }
        return false;
    }

    public boolean updateProduct(int productId, String productName, int categoryId, int brandId, BigDecimal price, String description, String imageUrl, int warrantyMonths, String[] specNames, String[] specValues) {
        String sqlProduct = """
            UPDATE products
            SET product_name = ?, category_id = ?, brand_id = ?, price = ?, description = ?, image_url = ?, warranty_months = ?
            WHERE product_id = ?
        """;
        String sqlDeleteSpecs = "DELETE FROM PRODUCT_SPECIFICATIONS WHERE product_id = ?";
        String sqlInsertSpec = "INSERT INTO PRODUCT_SPECIFICATIONS (product_id, specification_name, specification_value) VALUES (?, ?, ?)";

        PreparedStatement psProduct = null;
        PreparedStatement psDelete = null;
        PreparedStatement psInsert = null;
        try {
            connection.setAutoCommit(false);

            psProduct = connection.prepareStatement(sqlProduct);
            psProduct.setString(1, productName);
            psProduct.setInt(2, categoryId);
            psProduct.setInt(3, brandId);
            psProduct.setBigDecimal(4, price);
            psProduct.setString(5, description);
            psProduct.setString(6, imageUrl);
            psProduct.setInt(7, warrantyMonths);
            psProduct.setInt(8, productId);

            int affected = psProduct.executeUpdate();
            if (affected == 0) {
                connection.rollback();
                return false;
            }

            // Delete existing specs
            psDelete = connection.prepareStatement(sqlDeleteSpecs);
            psDelete.setInt(1, productId);
            psDelete.executeUpdate();

            // Insert new specs
            if (specNames != null && specValues != null) {
                psInsert = connection.prepareStatement(sqlInsertSpec);
                int specLength = Math.min(specNames.length, specValues.length);
                for (int i = 0; i < specLength; i++) {
                    String name = specNames[i];
                    String value = specValues[i];

                    if (name != null && !name.trim().isEmpty() && value != null && !value.trim().isEmpty()) {
                        psInsert.setInt(1, productId);
                        psInsert.setString(2, name.trim());
                        psInsert.setString(3, value.trim());
                        psInsert.addBatch();
                    }
                }
                psInsert.executeBatch();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            try {
                if (connection != null) {
                    connection.rollback();
                }
            } catch (SQLException ex) {
            }
        } finally {
            try {
                if (connection != null) {
                    connection.setAutoCommit(true);
                }
                if (psProduct != null) {
                    psProduct.close();
                }
                if (psDelete != null) {
                    psDelete.close();
                }
                if (psInsert != null) {
                    psInsert.close();
                }
            } catch (SQLException e) {
            }
        }
        return false;
    }

    public List<ProductSpecification> getSpecificationsByProductId(int productId) {
        List<ProductSpecification> list = new ArrayList<>();
        String sql = "SELECT spec_id, product_id, specification_name, specification_value FROM PRODUCT_SPECIFICATIONS WHERE product_id = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                ProductSpecification spec = new ProductSpecification(
                        rs.getInt("spec_id"),
                        rs.getInt("product_id"),
                        rs.getString("specification_name"),
                        rs.getString("specification_value")
                );
                list.add(spec);
            }
        } catch (SQLException e) {
        }
        return list;
    }

}
