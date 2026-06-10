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
        b.setStatus(rs.getString("status"));

        return b;
    }

    public List<Brand> getBrands(String keyword) {
        return getBrands(keyword, null, "newest");
    }

    public List<Brand> getBrands(String keyword, String status, String sort) {
        List<Brand> list = new ArrayList<>();

        String sql = """
            SELECT br.brand_id, br.brand_name, br.img, br.status,
                   COUNT(p.product_id) AS product_count
            FROM brands br
            LEFT JOIN batch ba ON br.brand_id = ba.brand_id
            LEFT JOIN products p ON ba.batch_id = p.batch_id
            WHERE (? IS NULL OR br.brand_name LIKE ?)
              AND (? IS NULL OR br.status = ?)
            GROUP BY br.brand_id, br.brand_name, br.img, br.status
        """ + getAdminOrderBy(sort);

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            String normalizedKeyword = normalizeKeyword(keyword);
            String normalizedStatus = normalizeStatus(status);

            if (normalizedKeyword == null) {
                ps.setNull(1, java.sql.Types.VARCHAR);
                ps.setNull(2, java.sql.Types.VARCHAR);
            } else {
                ps.setString(1, normalizedKeyword);
                ps.setString(2, "%" + normalizedKeyword + "%");
            }

            if (normalizedStatus == null) {
                ps.setNull(3, java.sql.Types.VARCHAR);
                ps.setNull(4, java.sql.Types.VARCHAR);
            } else {
                ps.setString(3, normalizedStatus);
                ps.setString(4, normalizedStatus);
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

    public List<Brand> getActiveBrands() {
        List<Brand> list = new ArrayList<>();

        String sql = """
            SELECT br.brand_id, br.brand_name, br.img, br.status,
                   COUNT(p.product_id) AS product_count
            FROM brands br
            LEFT JOIN batch ba ON br.brand_id = ba.brand_id
            LEFT JOIN categories ca ON ba.category_id = ca.category_id AND ca.status = 'ACTIVE'
            LEFT JOIN products p ON ba.batch_id = p.batch_id AND p.status = 'ACTIVE' AND ca.category_id IS NOT NULL
            WHERE br.status = 'ACTIVE'
            GROUP BY br.brand_id, br.brand_name, br.img, br.status
            ORDER BY br.brand_id DESC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
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
            SELECT br.brand_id, br.brand_name, br.img, br.status,
                   COUNT(p.product_id) AS product_count
            FROM brands br
            LEFT JOIN batch ba ON br.brand_id = ba.brand_id
            LEFT JOIN products p ON ba.batch_id = p.batch_id
            WHERE br.brand_id = ?
            GROUP BY br.brand_id, br.brand_name, br.img, br.status
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
        int nextBrandId = getNextBrandId();
        String sql = """
            INSERT INTO brands (brand_id, brand_name, img)
            VALUES (?, ?, ?)
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, nextBrandId);
            ps.setString(2, brandName);
            ps.setString(3, img);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private int getNextBrandId() {
        String sql = "SELECT COALESCE(MAX(brand_id), 0) + 1 AS next_id FROM brands";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("next_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1;
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
        return updateBrandStatus(brandId, "INACTIVE");
    }

    public boolean activateBrand(int brandId) {
        return updateBrandStatus(brandId, "ACTIVE");
    }

    public boolean updateBrandStatus(int brandId, String status) {
        String sql = """
            UPDATE brands
            SET status = ?
            WHERE brand_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, brandId);

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

    private String normalizeStatus(String status) {
        if (status == null || status.trim().isEmpty() || "ALL".equalsIgnoreCase(status.trim())) {
            return null;
        }

        String normalizedStatus = status.trim().toUpperCase();
        if ("ACTIVE".equals(normalizedStatus) || "INACTIVE".equals(normalizedStatus)) {
            return normalizedStatus;
        }

        return null;
    }

    private String getAdminOrderBy(String sort) {
        if ("product_count_asc".equals(sort)) {
            return " ORDER BY product_count ASC, br.brand_id DESC ";
        } else if ("product_count_desc".equals(sort)) {
            return " ORDER BY product_count DESC, br.brand_id DESC ";
        }

        return " ORDER BY br.brand_id DESC ";
    }
}
