package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Review;

public class ReviewDAO extends DBContext {

    static {
        // Auto-migration: Create REVIEW_IMAGES table if not exists
        try {
            DBContext db = new DBContext();
            java.sql.Connection conn = db.getConnection();
            if (conn != null) {
                java.sql.DatabaseMetaData dbmd = conn.getMetaData();
                boolean exists = false;
                try (ResultSet rs = dbmd.getTables(null, null, "REVIEW_IMAGES", null)) {
                    if (rs.next()) {
                        exists = true;
                    }
                }
                if (!exists) {
                    try (ResultSet rs = dbmd.getTables(null, null, "review_images", null)) {
                        if (rs.next()) {
                            exists = true;
                        }
                    }
                }
                if (!exists) {
                    String createTableSql = """
                        CREATE TABLE REVIEW_IMAGES (
                            image_id INT AUTO_INCREMENT PRIMARY KEY,
                            review_id INT NOT NULL,
                            image_url VARCHAR(255) NOT NULL,
                            CONSTRAINT FK_REVIEW_IMAGES_REVIEWS
                                FOREIGN KEY (review_id) REFERENCES REVIEWS(review_id) ON DELETE CASCADE
                        )
                    """;
                    try (java.sql.Statement stmt = conn.createStatement()) {
                        stmt.executeUpdate(createTableSql);
                        System.out.println("Table REVIEW_IMAGES created successfully!");
                    }
                }
                conn.close();
            }
        } catch (Exception e) {
            System.err.println("Database migration for REVIEW_IMAGES failed: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public List<String> getReviewImages(int reviewId) {
        List<String> images = new ArrayList<>();
        String sql = "SELECT image_url FROM REVIEW_IMAGES WHERE review_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, reviewId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    images.add(rs.getString("image_url"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return images;
    }

    public List<Review> getReviewsByProductId(int productId) {
        List<Review> list = new ArrayList<>();

        String sql = """
            SELECT review_id, customer_id, rating, product_id, comment, date
            FROM reviews
            WHERE product_id = ?
            ORDER BY date DESC
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setCustomerId(rs.getInt("customer_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setComment(rs.getString("comment"));
                    r.setDate(rs.getTimestamp("date"));
                    r.setImages(getReviewImages(r.getReviewId()));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Review> getReviewsByProductIdAndRating(int productId, int rating) {
        List<Review> list = new ArrayList<>();

        String sql = """
            SELECT review_id, customer_id, product_id, rating, comment, date
            FROM reviews
            WHERE product_id = ?
              AND rating = ?
            ORDER BY date DESC
        """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, rating);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setUserId(rs.getInt("customer_id"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setComment(rs.getString("comment"));
                    r.setDate(rs.getTimestamp("date"));
                    r.setImages(getReviewImages(r.getReviewId()));
                    list.add(r);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Review getReviewByCustomerAndProduct(int customerId, int productId) {
        String sql = """
            SELECT review_id, customer_id, rating, product_id, comment, date
            FROM reviews
            WHERE customer_id = ? AND product_id = ?
        """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setCustomerId(rs.getInt("customer_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setProductId(rs.getInt("product_id"));
                    r.setComment(rs.getString("comment"));
                    r.setDate(rs.getTimestamp("date"));
                    r.setImages(getReviewImages(r.getReviewId()));
                    return r;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean addReview(Review r) {
        String sql = """
            INSERT INTO reviews (customer_id, product_id, rating, comment, date)
            VALUES (?, ?, ?, ?, ?)
        """;
        try {
            connection.setAutoCommit(false);
            
            PreparedStatement ps = connection.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, r.getCustomerId());
            ps.setInt(2, r.getProductId());
            ps.setInt(3, r.getRating());
            ps.setString(4, r.getComment());
            ps.setTimestamp(5, new java.sql.Timestamp(r.getDate().getTime()));
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                connection.rollback();
                connection.setAutoCommit(true);
                return false;
            }
            
            int reviewId = 0;
            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    reviewId = generatedKeys.getInt(1);
                    r.setReviewId(reviewId);
                } else {
                    connection.rollback();
                    connection.setAutoCommit(true);
                    return false;
                }
            }
            
            // Insert images into REVIEW_IMAGES table
            if (r.getImages() != null && !r.getImages().isEmpty()) {
                String imgSql = "INSERT INTO REVIEW_IMAGES (review_id, image_url) VALUES (?, ?)";
                try (PreparedStatement imgPs = connection.prepareStatement(imgSql)) {
                    for (String imgUrl : r.getImages()) {
                        imgPs.setInt(1, reviewId);
                        imgPs.setString(2, imgUrl);
                        imgPs.addBatch();
                    }
                    imgPs.executeBatch();
                }
            }
            
            connection.commit();
            connection.setAutoCommit(true);
            return true;
        } catch (Exception e) {
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateReview(Review r) {
        String sql = """
            UPDATE reviews
            SET rating = ?, comment = ?, date = ?
            WHERE customer_id = ? AND product_id = ?
        """;
        try {
            connection.setAutoCommit(false);
            
            Review existing = getReviewByCustomerAndProduct(r.getCustomerId(), r.getProductId());
            if (existing == null) {
                connection.rollback();
                connection.setAutoCommit(true);
                return false;
            }
            int reviewId = existing.getReviewId();
            r.setReviewId(reviewId);
            
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, r.getRating());
            ps.setString(2, r.getComment());
            ps.setTimestamp(3, new java.sql.Timestamp(r.getDate().getTime()));
            ps.setInt(4, r.getCustomerId());
            ps.setInt(5, r.getProductId());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                connection.rollback();
                connection.setAutoCommit(true);
                return false;
            }
            
            // Delete old images from REVIEW_IMAGES table
            String deleteImgSql = "DELETE FROM REVIEW_IMAGES WHERE review_id = ?";
            try (PreparedStatement delPs = connection.prepareStatement(deleteImgSql)) {
                delPs.setInt(1, reviewId);
                delPs.executeUpdate();
            }
            
            // Insert new images
            if (r.getImages() != null && !r.getImages().isEmpty()) {
                String imgSql = "INSERT INTO REVIEW_IMAGES (review_id, image_url) VALUES (?, ?)";
                try (PreparedStatement imgPs = connection.prepareStatement(imgSql)) {
                    for (String imgUrl : r.getImages()) {
                        imgPs.setInt(1, reviewId);
                        imgPs.setString(2, imgUrl);
                        imgPs.addBatch();
                    }
                    imgPs.executeBatch();
                }
            }
            
            connection.commit();
            connection.setAutoCommit(true);
            return true;
        } catch (Exception e) {
            try {
                connection.rollback();
                connection.setAutoCommit(true);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
        }
        return false;
    }
}
