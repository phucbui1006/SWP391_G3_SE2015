/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */


import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.Batch;

public class BatchDAO extends DBContext {

    public ArrayList<Batch> getAllBatches() {
        ArrayList<Batch> list = new ArrayList<>();

        String sql = "SELECT b.batch_id, b.batch_name, b.category_id, b.brand_id, "
                + "c.category_name, br.brand_name, "
                + "COALESCE(SUM(p.quantity), 0) AS total_quantity "
                + "FROM batch b "
                + "JOIN categories c ON b.category_id = c.category_id "
                + "JOIN brands br ON b.brand_id = br.brand_id "
                + "LEFT JOIN products p ON b.batch_id = p.batch_id "
                + "GROUP BY b.batch_id, b.batch_name, b.category_id, b.brand_id, c.category_name, br.brand_name "
                + "ORDER BY b.batch_id DESC";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Batch b = new Batch();

                b.setBatchId(rs.getInt("batch_id"));
                b.setBatchName(rs.getString("batch_name"));
                b.setCategoryId(rs.getInt("category_id"));
                b.setBrandId(rs.getInt("brand_id"));
                b.setCategoryName(rs.getString("category_name"));
                b.setBrandName(rs.getString("brand_name"));

                int quantity = rs.getInt("total_quantity");
                b.setQuantity(quantity);

                if (quantity == 0) {
                    b.setStockStatus("Out of Stock");
                } else if (quantity < 10) {
                    b.setStockStatus("Low Stock");
                } else {
                    b.setStockStatus("In Stock");
                }

                list.add(b);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return list;
    }

    public void addBatch(String batchName, int categoryId, int brandId) {
        String sql = "INSERT INTO batch(batch_name, category_id, brand_id) VALUES (?, ?, ?)";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, batchName);
            ps.setInt(2, categoryId);
            ps.setInt(3, brandId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

public void updateBatch(int batchId, String batchName, int categoryId, int brandId) {
    String sql = "UPDATE batch SET batch_name = ?, category_id = ?, brand_id = ? WHERE batch_id = ?";

    try {
        PreparedStatement ps = connection.prepareStatement(sql);
        ps.setString(1, batchName);
        ps.setInt(2, categoryId);
        ps.setInt(3, brandId);
        ps.setInt(4, batchId);
        ps.executeUpdate();
    } catch (Exception e) {
        e.printStackTrace();
    }
}

    public void deleteBatch(int batchId) {
        String sql = "DELETE FROM batch WHERE batch_id = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, batchId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}