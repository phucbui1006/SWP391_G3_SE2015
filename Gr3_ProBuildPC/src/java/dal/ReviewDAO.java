package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Review;

public class ReviewDAO extends DBContext {

    public List<Review> getReviewsByProductId(int productId) {
        List<Review> list = new ArrayList<>();

        String sql = """
            SELECT review_id, customer_id, rating, product_id, img, comment, date
            FROM reviews
            WHERE product_id = ?
            ORDER BY date DESC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, productId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Review r = new Review();

                r.setReviewId(rs.getInt("review_id"));
                r.setCustomerId(rs.getInt("customer_id"));
                r.setRating(rs.getInt("rating"));
                r.setProductId(rs.getInt("product_id"));
                r.setImg(rs.getString("img"));
                r.setComment(rs.getString("comment"));
                r.setDate(rs.getTimestamp("date"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public List<Review> getReviewsByProductIdAndRating(int productId, int rating) {
        List<Review> list = new ArrayList<>();

        String sql = """
        SELECT review_id, customer_id, product_id, rating, img, comment, date
        FROM reviews
        WHERE product_id = ?
          AND rating = ?
        ORDER BY date DESC
    """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, productId);
            ps.setInt(2, rating);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Review r = new Review();

                r.setReviewId(rs.getInt("review_id"));
                r.setUserId(rs.getInt("customer_id"));
                r.setProductId(rs.getInt("product_id"));
                r.setRating(rs.getInt("rating"));
                r.setImg(rs.getString("img"));
                r.setComment(rs.getString("comment"));
                r.setDate(rs.getTimestamp("date"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
