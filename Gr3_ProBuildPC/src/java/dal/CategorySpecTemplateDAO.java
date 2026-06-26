package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.CategorySpecTemplate;

public class CategorySpecTemplateDAO extends DBContext {

    public List<CategorySpecTemplate> getTemplatesByCategoryId(int categoryId) {
        List<CategorySpecTemplate> list = new ArrayList<>();

        String sql = """
            SELECT template_id,
                   category_id,
                   spec_name,
                   spec_type,
                   allowed_values,
                   is_required,
                   display_order,
                   status
            FROM CATEGORY_SPEC_TEMPLATES
            WHERE category_id = ?
            ORDER BY display_order ASC, template_id ASC
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {

            ps.setInt(1, categoryId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CategorySpecTemplate t = new CategorySpecTemplate();

                    t.setTemplateId(rs.getInt("template_id"));
                    t.setCategoryId(rs.getInt("category_id"));
                    t.setSpecName(rs.getString("spec_name"));
                    t.setSpecType(rs.getString("spec_type"));
                    t.setAllowedValues(rs.getString("allowed_values"));
                    t.setRequired(rs.getBoolean("is_required"));
                    t.setDisplayOrder(rs.getInt("display_order"));
                    t.setStatus(rs.getString("status"));

                    list.add(t);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}