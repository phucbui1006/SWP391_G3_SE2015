package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Category;

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
            orderBy = "category_name ASC";
        } else if ("name_desc".equalsIgnoreCase(sort)) {
            orderBy = "category_name DESC";
        } else if ("oldest".equalsIgnoreCase(sort)) {
            orderBy = "category_id ASC";
        } else {
            orderBy = "category_id DESC";
        }

        String sql = "SELECT category_id, category_name, status "
                + "FROM categories "
                + "WHERE 1 = 1 ";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND category_name LIKE ? ";
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql += "AND status = ? ";
        }

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

                list.add(c);
            }

        } catch (SQLException e) {
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
}
