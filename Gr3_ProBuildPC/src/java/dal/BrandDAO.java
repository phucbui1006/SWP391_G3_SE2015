package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Brand;

public class BrandDAO extends DBContext {

    private Brand mapBrand(ResultSet rs) throws SQLException {
        Brand b = new Brand();

        b.setBrandId(rs.getInt("brand_id"));
        b.setBrandName(rs.getString("brand_name"));
        b.setImg(rs.getString("img"));
        b.setProductCount(rs.getInt("product_count"));
        b.setStatus(rs.getString("status"));

        return b;
    }

    public List<Brand> getBrands(String keyword, String status, String sort) {
        return getBrands(keyword, status, sort, 0, 0);
    }

    public List<Brand> getBrands(String keyword, String status, String sort, int page, int pageSize) {
        List<Brand> list = new ArrayList<>();

        String sql = """
            SELECT br.brand_id, br.brand_name, br.img, br.status,
                   COUNT(p.product_id) AS product_count
            FROM brands br
            LEFT JOIN products p ON br.brand_id = p.brand_id
            WHERE (? IS NULL OR br.brand_name LIKE ?)
              AND (? IS NULL OR br.status = ?)
            GROUP BY br.brand_id, br.brand_name, br.img, br.status
        """ + getAdminOrderBy(sort) + (pageSize > 0 ? " LIMIT ? OFFSET ?" : "");

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

            if (pageSize > 0) {
                ps.setInt(5, pageSize);
                ps.setInt(6, (Math.max(page, 1) - 1) * pageSize);
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

    public int countBrands(String keyword, String status) {
        String sql = """
            SELECT COUNT(*) AS total
            FROM brands br
            WHERE (? IS NULL OR br.brand_name LIKE ?)
              AND (? IS NULL OR br.status = ?)
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String normalizedKeyword = normalizeKeyword(keyword);
            String normalizedStatus = normalizeStatus(status);

            setOptionalFilter(ps, 1, normalizedKeyword, true);
            setOptionalFilter(ps, 3, normalizedStatus, false);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("total") : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        }
    }

    private void setOptionalFilter(PreparedStatement ps, int index, String value, boolean useWildcard)
            throws SQLException {
        if (value == null) {
            ps.setNull(index, java.sql.Types.VARCHAR);
            ps.setNull(index + 1, java.sql.Types.VARCHAR);
            return;
        }

        ps.setString(index, value);
        ps.setString(index + 1, useWildcard ? "%" + value + "%" : value);
    }

    //Lấy ra, filter tất cả brand theo status
    public List<Brand> getActiveBrands() {
        List<Brand> list = new ArrayList<>();

        String sql = """
            SELECT br.brand_id, br.brand_name, br.img, br.status,
                   COUNT(CASE WHEN ca.category_id IS NOT NULL AND COALESCE(stock.quantity, 0) > 0 THEN p.product_id END) AS product_count
            FROM brands br
            LEFT JOIN products p ON br.brand_id = p.brand_id AND p.status = 'ACTIVE'
            LEFT JOIN categories ca ON p.category_id = ca.category_id AND ca.status = 'ACTIVE'
            LEFT JOIN (
                SELECT product_id, SUM(quantity) AS quantity
                FROM batch_items
                GROUP BY product_id
            ) stock ON stock.product_id = p.product_id
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

    //Lấy ra brand theo id
    public Brand getBrandById(int brandId) {
        String sql = """
            SELECT br.brand_id, br.brand_name, br.img, br.status,
                   COUNT(p.product_id) AS product_count
            FROM brands br
            LEFT JOIN products p ON br.brand_id = p.brand_id
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

    
    //Hàm tanwgg ID của brand mới khi add mới
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

    private boolean updateBrandStatus(int brandId, String status) {
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
        if ("oldest".equals(sort)) {
            return " ORDER BY br.brand_id ASC ";
        } else if ("product_count_asc".equals(sort)) {
            return " ORDER BY product_count ASC, br.brand_id DESC ";
        } else if ("product_count_desc".equals(sort)) {
            return " ORDER BY product_count DESC, br.brand_id DESC ";
        }

        return " ORDER BY br.brand_id DESC ";
    }
}
