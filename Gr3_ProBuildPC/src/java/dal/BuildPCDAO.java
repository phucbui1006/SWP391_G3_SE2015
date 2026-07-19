package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Product;

public class BuildPCDAO extends DBContext {

    private static final String PRODUCT_SELECT
            = "SELECT p.product_id, p.price, COALESCE(stock.quantity, 0) AS quantity, "
            + "COALESCE(stock.batch_id, 0) AS batch_id, p.description, p.image_url, "
            + "COALESCE(p.warranty_months, 0) AS warranty_months, p.product_name, "
            + "p.status, p.brand_id, p.category_id, br.brand_name, br.status AS brand_status, "
            + "c.category_name, c.status AS category_status "
            + "FROM products p "
            + "JOIN categories c ON c.category_id = p.category_id "
            + "JOIN brands br ON br.brand_id = p.brand_id "
            + "JOIN ( "
            + "    SELECT product_id, SUM(quantity) AS quantity, MIN(batch_id) AS batch_id "
            + "    FROM batch_items "
            + "    GROUP BY product_id "
            + ") stock ON stock.product_id = p.product_id ";

    private static final String ACTIVE_IN_STOCK_CONDITION
            = "p.status = 'ACTIVE' AND c.status = 'ACTIVE' AND br.status = 'ACTIVE' "
            + "AND stock.quantity > 0 ";

    public List<Product> getProductsByCategory(int categoryId) {
        List<Product> products = new ArrayList<>();
        // Query nền cho tất cả slot: chỉ lấy sản phẩm đang bán, danh mục/thương hiệu ACTIVE
        // và tồn kho thực tế được cộng từ BATCH_ITEMS lớn hơn 0.
        String sql = PRODUCT_SELECT
                + "WHERE p.category_id = ? AND " + ACTIVE_IN_STOCK_CONDITION
                + "ORDER BY p.product_name";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, categoryId);

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

    /**
     * Lấy các sản phẩm cho một slot hiện đang có sẵn và tương thích với các linh kiện Build PC đã chọn.
     */
    public List<Product> getProductsByCategoryCompatibleWithBuild(int categoryId,
            Map<String, Integer> selectedBuild, String currentSlot) {
        List<Product> compatibleProducts = new ArrayList<>();
        List<Product> products = getProductsByCategory(categoryId);

        for (Product product : products) {
            if (isProductCompatibleWithSelectedBuild(product.getProductId(), selectedBuild, currentSlot)) {
                compatibleProducts.add(product);
            }
        }

        return compatibleProducts;
    }

    /**
     * Kiểm tra xem một sản phẩm đề cử có tương thích với các sản phẩm đã được chọn trong cấu hình Build PC hay không.
     */
    public boolean isProductCompatibleWithSelectedBuild(int productId,
            Map<String, Integer> selectedBuild, String currentSlot) {
        Product candidate = getProductById(productId);

        if (candidate == null) {
            return false;
        }

        if (selectedBuild == null || selectedBuild.isEmpty()) {
            return true;
        }

        for (Map.Entry<String, Integer> entry : selectedBuild.entrySet()) {
            if (entry.getKey().equals(currentSlot)) {
                continue;
            }

            Product selectedProduct = getProductById(entry.getValue());
            if (selectedProduct == null) {
                continue;
            }

            // Kiểm tra hai chiều để người dùng có thể chọn Mainboard/RAM/GPU trước CPU
            // nhưng các rule trong COMPATIBILITY_RULES vẫn được áp dụng đầy đủ.
            if (!areProductsCompatible(candidate.getProductId(), selectedProduct.getProductId())
                    || !areProductsCompatible(selectedProduct.getProductId(), candidate.getProductId())) {
                return false;
            }
        }

        return true;
    }

    /**
     * Chuyển bản đồ slot -> id sản phẩm đã chọn thành bản đồ slot -> object sản phẩm.
     */
    public Map<String, Product> getSelectedBuild(Map<String, Integer> selectedBuild) {
        Map<String, Product> selectedProducts = new LinkedHashMap<>();

        if (selectedBuild == null || selectedBuild.isEmpty()) {
            return selectedProducts;
        }

        for (Map.Entry<String, Integer> entry : selectedBuild.entrySet()) {
            Product product = getProductById(entry.getValue());
            if (product != null) {
                selectedProducts.put(entry.getKey(), product);
            }
        }

        return selectedProducts;
    }

    /**
     * Lấy tổng tồn kho có sẵn của một sản phẩm từ batch_items.
     */
    public int getAvailableQuantity(int productId) {
        String sql = "SELECT COALESCE(SUM(bi.quantity), 0) AS available_quantity "
                + "FROM batch_items bi "
                + "JOIN products p ON p.product_id = bi.product_id "
                + "JOIN categories c ON c.category_id = p.category_id "
                + "JOIN brands br ON br.brand_id = p.brand_id "
                + "WHERE bi.product_id = ? "
                + "AND p.status = 'ACTIVE' AND c.status = 'ACTIVE' AND br.status = 'ACTIVE'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("available_quantity");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * Lấy sản phẩm đang hoạt động theo id khi sản phẩm vẫn còn hàng và có thể bán.
     */
    public Product getProductById(int productId) {
        String sql = PRODUCT_SELECT
                + "WHERE p.product_id = ? AND " + ACTIVE_IN_STOCK_CONDITION;

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

    /**
     * Áp dụng các quy tắc tương thích giữa hai sản phẩm bằng bảng product_specifications.
     */
    private boolean areProductsCompatible(int sourceProductId, int targetProductId) {
        String sql = "SELECT COUNT(*) AS invalid_rules "
                + "FROM compatibility_rules cr "
                + "JOIN products source_product ON source_product.product_id = ? "
                + "JOIN products target_product ON target_product.product_id = ? "
                + "JOIN product_specifications source_spec "
                + "  ON source_spec.product_id = source_product.product_id "
                + " AND source_spec.specification_name = cr.source_spec_name "
                + "WHERE cr.source_category_id = source_product.category_id "
                + "AND cr.target_category_id = target_product.category_id "
                + "AND cr.comparison_operator = '=' "
                + "AND NOT EXISTS ( "
                + "    SELECT 1 "
                + "    FROM product_specifications target_spec "
                + "    WHERE target_spec.product_id = target_product.product_id "
                + "      AND target_spec.specification_name = cr.target_spec_name "
                + "      AND LOWER(TRIM(target_spec.specification_value)) = LOWER(TRIM(source_spec.specification_value)) "
                + ")";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, sourceProductId);
            ps.setInt(2, targetProductId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("invalid_rules") == 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setPrice(rs.getBigDecimal("price"));
        product.setQuantity(rs.getInt("quantity"));
        product.setBatchId(rs.getInt("batch_id"));
        product.setDescription(rs.getString("description"));
        product.setImageUrl(rs.getString("image_url"));
        product.setWarrantyMonths(rs.getInt("warranty_months"));
        product.setProductName(rs.getString("product_name"));
        product.setStatus(rs.getString("status"));
        product.setBrandId(rs.getInt("brand_id"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setBrandName(rs.getString("brand_name"));
        product.setBrandStatus(rs.getString("brand_status"));
        product.setCategoryName(rs.getString("category_name"));
        product.setCategoryStatus(rs.getString("category_status"));
        return product;
    }
}
