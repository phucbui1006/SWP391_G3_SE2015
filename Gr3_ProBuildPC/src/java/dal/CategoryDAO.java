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
            SELECT category_id, category_name, status
            FROM categories
            WHERE status = 'ACTIVE'
            ORDER BY category_name ASC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
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

    public List<Category> getCategories(String keyword, String sort, int page, int pageSize) {
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

        sql += "ORDER BY " + orderBy + " LIMIT ? OFFSET ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            int index = 1;

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(index++, "%" + keyword.trim() + "%");
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

    public int countCategories(String keyword) {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM categories "
                + "WHERE 1 = 1 ";

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += "AND category_name LIKE ? ";
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(1, "%" + keyword.trim() + "%");
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
        }

        return 0;
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
