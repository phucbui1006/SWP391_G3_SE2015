package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Category;
import model.CategorySpecTemplate;

public class CategoryDAO extends DBContext {

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();

        String sql = """
            SELECT c.category_id, c.category_name, c.status, COUNT(p.product_id) AS product_count
            FROM categories c
            LEFT JOIN products p ON c.category_id = p.category_id AND p.status = 'ACTIVE'
            WHERE c.status = 'ACTIVE'
            GROUP BY c.category_id, c.category_name, c.status
            ORDER BY c.category_name ASC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryName(rs.getString("category_name"));
                c.setStatus(rs.getString("status"));
                c.setProductCount(rs.getInt("product_count"));
                list.add(c);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public Category getCategoryById(int categoryId) {
        String sql = """
            SELECT category_id, category_name, status
            FROM categories
            WHERE category_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, categoryId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Category c = new Category();
                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryName(rs.getString("category_name"));
                c.setStatus(rs.getString("status"));
                return c;
            }

        } catch (SQLException e) {
        }

        return null;
    }

    public List<Category> getCategories(String keyword, String status, String sort, int page, int pageSize) {
        List<Category> list = new ArrayList<>();

        String orderBy;

        if ("name_asc".equalsIgnoreCase(sort)) {
            orderBy = "c.category_name ASC";
        } else if ("name_desc".equalsIgnoreCase(sort)) {
            orderBy = "c.category_name DESC";
        } else if ("oldest".equalsIgnoreCase(sort)) {
            orderBy = "c.category_id ASC";
        } else {
            orderBy = "c.category_id DESC";
        }

        String sql = """
            SELECT c.category_id, c.category_name, c.status, COUNT(p.product_id) AS total_products
            FROM categories c
            LEFT JOIN products p ON c.category_id = p.category_id AND p.status = 'ACTIVE'
            WHERE 1 = 1
        """;

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND c.category_name LIKE ? ";
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql += "AND c.status = ? ";
        }

        sql += "GROUP BY c.category_id, c.category_name, c.status ";
        sql += "ORDER BY " + orderBy + " LIMIT ? OFFSET ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            int index = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(index++, "%" + keyword.trim() + "%");
            }

            if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
                ps.setString(index++, status.trim().toUpperCase());
            }

            int offset = (page - 1) * pageSize;

            ps.setInt(index++, pageSize);
            ps.setInt(index, offset);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Category c = new Category();

                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryName(rs.getString("category_name"));
                c.setStatus(rs.getString("status"));
                c.setProductCount(rs.getInt("total_products"));

                list.add(c);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countCategories(String keyword, String status) {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM categories "
                + "WHERE 1 = 1 ";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND category_name LIKE ? ";
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql += "AND status = ? ";
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            int index = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(index++, "%" + keyword.trim() + "%");
            }

            if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
                ps.setString(index++, status.trim().toUpperCase());
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
        }

        return 0;
    }

    public boolean addCategory(String categoryName) {
        int nextCategoryId = getnextCategoryId();
        String sql = """
            INSERT INTO categories (category_id, category_name)
            VALUES (?, ?)
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, nextCategoryId);
            ps.setString(2, categoryName);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
        }

        return false;
    }

    private int getnextCategoryId() {
        String sql = "SELECT MAX(category_id) + 1 AS next_id\n"
                + "FROM Categories";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("next_id");
            }
        } catch (SQLException e) {
        }
        return 1;
    }

    public boolean updateCategoryName(int categoryId, String categoryName) {
        String sql = """
            UPDATE categories
            SET category_name = ?
            WHERE category_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, categoryName);
            ps.setInt(2, categoryId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
        }

        return false;
    }

    public boolean updateCategoryStatus(int categoryId, String status) {
        String sql = """
            UPDATE categories
            SET status = ?
            WHERE category_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, status);
            ps.setInt(2, categoryId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
        }

        return false;
    }

    public List<CategorySpecTemplate> getTemplatesByCategoryId(int categoryId) {
        List<CategorySpecTemplate> list = new ArrayList<>();
        String sql = """
            SELECT template_id, category_id, spec_name, spec_type, allowed_values, is_required, display_order
            FROM CATEGORY_SPEC_TEMPLATES
            WHERE category_id = ?
            ORDER BY display_order ASC
        """;
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, categoryId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CategorySpecTemplate t = new CategorySpecTemplate();
                t.setTemplateId(rs.getInt("template_id"));
                t.setCategoryId(rs.getInt("category_id"));
                t.setSpecName(rs.getString("spec_name"));
                t.setSpecType(rs.getString("spec_type"));
                t.setAllowedValues(rs.getString("allowed_values"));
                t.setRequired(rs.getBoolean("is_required"));
                t.setDisplayOrder(rs.getInt("display_order"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<CategorySpecTemplate> getTemplatesWithValues(int categoryId, Integer productId) {
        List<CategorySpecTemplate> list = new ArrayList<>();
        String sql;
        if (productId != null && productId > 0) {
            sql = """
                SELECT t.template_id, t.category_id, t.spec_name, t.spec_type, t.allowed_values, t.is_required, t.display_order, s.specification_value AS spec_value
                FROM CATEGORY_SPEC_TEMPLATES t
                LEFT JOIN PRODUCT_SPECIFICATIONS s ON t.spec_name = s.specification_name AND s.product_id = ?
                WHERE t.category_id = ?
                ORDER BY t.display_order ASC, t.template_id ASC
            """;
        } else {
            sql = """
                SELECT t.template_id, t.category_id, t.spec_name, t.spec_type, t.allowed_values, t.is_required, t.display_order, NULL AS spec_value
                FROM CATEGORY_SPEC_TEMPLATES t
                WHERE t.category_id = ?
                ORDER BY t.display_order ASC, t.template_id ASC
            """;
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            if (productId != null && productId > 0) {
                ps.setInt(1, productId);
                ps.setInt(2, categoryId);
            } else {
                ps.setInt(1, categoryId);
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CategorySpecTemplate t = new CategorySpecTemplate();
                t.setTemplateId(rs.getInt("template_id"));
                t.setCategoryId(rs.getInt("category_id"));
                t.setSpecName(rs.getString("spec_name"));
                t.setSpecType(rs.getString("spec_type"));
                t.setAllowedValues(rs.getString("allowed_values"));
                t.setRequired(rs.getBoolean("is_required"));
                t.setDisplayOrder(rs.getInt("display_order"));
                t.setSpecValue(rs.getString("spec_value"));
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }


    public boolean addCategoryWithTemplates(String categoryName, List<CategorySpecTemplate> templates) {
        try {
            connection.setAutoCommit(false);

            // 1. Insert Category and get next ID
            int nextCategoryId = getnextCategoryId();
            String insertCatSql = "INSERT INTO categories (category_id, category_name, status) VALUES (?, ?, 'ACTIVE')";
            try (PreparedStatement ps = connection.prepareStatement(insertCatSql)) {
                ps.setInt(1, nextCategoryId);
                ps.setString(2, categoryName);
                ps.executeUpdate();
            }

            // 2. Insert spec templates
            String insertTemplateSql = """
                INSERT INTO CATEGORY_SPEC_TEMPLATES (category_id, spec_name, spec_type, allowed_values, is_required, display_order)
                VALUES (?, ?, ?, ?, ?, ?)
            """;
            try (PreparedStatement ps = connection.prepareStatement(insertTemplateSql)) {
                for (CategorySpecTemplate t : templates) {
                    ps.setInt(1, nextCategoryId);
                    ps.setString(2, t.getSpecName());
                    ps.setString(3, t.getSpecType());
                    ps.setString(4, t.getAllowedValues());
                    ps.setBoolean(5, t.isRequired());
                    ps.setInt(6, t.getDisplayOrder());
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return false;
    }

    public boolean updateCategoryWithTemplates(Category category, List<CategorySpecTemplate> templates) {
        try {
            connection.setAutoCommit(false);

            // 1. Update Category Name and Status
            String updateCatSql = "UPDATE categories SET category_name = ?, status = ? WHERE category_id = ?";
            try (PreparedStatement ps = connection.prepareStatement(updateCatSql)) {
                ps.setString(1, category.getCategoryName());
                ps.setString(2, category.getStatus());
                ps.setInt(3, category.getCategoryId());
                ps.executeUpdate();
            }

            // 2. Delete existing spec templates
            String deleteTemplatesSql = "DELETE FROM CATEGORY_SPEC_TEMPLATES WHERE category_id = ?";
            try (PreparedStatement ps = connection.prepareStatement(deleteTemplatesSql)) {
                ps.setInt(1, category.getCategoryId());
                ps.executeUpdate();
            }

            // 3. Re-insert the templates
            String insertTemplateSql = """
                INSERT INTO CATEGORY_SPEC_TEMPLATES (category_id, spec_name, spec_type, allowed_values, is_required, display_order)
                VALUES (?, ?, ?, ?, ?, ?)
            """;
            try (PreparedStatement ps = connection.prepareStatement(insertTemplateSql)) {
                for (CategorySpecTemplate t : templates) {
                    ps.setInt(1, category.getCategoryId());
                    ps.setString(2, t.getSpecName());
                    ps.setString(3, t.getSpecType());
                    ps.setString(4, t.getAllowedValues());
                    ps.setBoolean(5, t.isRequired());
                    ps.setInt(6, t.getDisplayOrder());
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        } finally {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        return false;
    }
}
