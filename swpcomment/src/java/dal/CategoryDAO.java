package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Category;

public class CategoryDAO extends DBContext {

    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();

        String sql = """
            SELECT category_id, category_name
            FROM categories
            ORDER BY category_name ASC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Category c = new Category();

                c.setCategoryId(rs.getInt("category_id"));
                c.setCategoryName(rs.getString("category_name"));

                list.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Category getCategoryById(int categoryId) {
        String sql = """
            SELECT category_id, category_name
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

                return c;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }
}