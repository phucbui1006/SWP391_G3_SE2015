package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Brand;

public class BrandDAO extends DBContext {

    private Brand mapBrand(ResultSet rs) throws Exception {
        Brand b = new Brand();

        b.setBrandId(rs.getInt("brand_id"));
        b.setBrandName(rs.getString("brand_name"));
        b.setImg(rs.getString("img"));
        b.setProductCount(rs.getInt("product_count"));

        return b;
    }

    public List<Brand> getBrands(String keyword) {
        List<Brand> list = new ArrayList<>();

        String sql = """
            SELECT br.brand_id, br.brand_name, br.img,
                   COUNT(p.product_id) AS product_count
            FROM brands br
            LEFT JOIN batch ba ON br.brand_id = ba.brand_id
            LEFT JOIN products p ON ba.batch_id = p.batch_id
            WHERE (? IS NULL OR br.brand_name LIKE ?)
            GROUP BY br.brand_id, br.brand_name, br.img
            ORDER BY br.brand_id DESC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            String normalizedKeyword = normalizeKeyword(keyword);

            if (normalizedKeyword == null) {
                ps.setNull(1, java.sql.Types.VARCHAR);
                ps.setNull(2, java.sql.Types.VARCHAR);
            } else {
                ps.setString(1, normalizedKeyword);
                ps.setString(2, "%" + normalizedKeyword + "%");
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapBrand(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Brand getBrandById(int brandId) {
        String sql = """
            SELECT br.brand_id, br.brand_name, br.img,
                   COUNT(p.product_id) AS product_count
            FROM brands br
            LEFT JOIN batch ba ON br.brand_id = ba.brand_id
            LEFT JOIN products p ON ba.batch_id = p.batch_id
            WHERE br.brand_id = ?
            GROUP BY br.brand_id, br.brand_name, br.img
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, brandId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapBrand(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean addBrand(String brandName, String img) {
        String sql = """
            INSERT INTO brands (brand_name, img)
            VALUES (?, ?)
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, brandName);
            ps.setString(2, img);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateBrand(int brandId, String brandName, String img) {
        String sql = """
            UPDATE brands
            SET brand_name = ?, img = ?
            WHERE brand_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, brandName);
            ps.setString(2, img);
            ps.setInt(3, brandId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteBrand(int brandId) {
        String sql = """
            DELETE FROM brands
            WHERE brand_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, brandId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean hasBatches(int brandId) {
        String sql = """
            SELECT COUNT(*) AS total
            FROM batch
            WHERE brand_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, brandId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total") > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return true;
    }

    private String normalizeKeyword(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return null;
        }

        return keyword.trim();
    }
}
