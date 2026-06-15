package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.BatchItem;

public class BatchItemDAO extends DBContext {

    private BatchItem mapBatchItem(ResultSet rs) throws Exception {
        BatchItem item = new BatchItem();

        item.setBatchItemId(rs.getInt("batch_item_id"));
        item.setBatchId(rs.getInt("batch_id"));
        item.setProductId(rs.getInt("product_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setPrice(rs.getBigDecimal("price"));
        item.setWarrantyMonths(rs.getInt("warranty_months"));

        return item;
    }

    public List<BatchItem> getItemsByBatchId(int batchId) {
        List<BatchItem> list = new ArrayList<>();

        String sql = """
            SELECT batch_item_id, batch_id, product_id, quantity, price, warranty_months
            FROM BATCH_ITEMS
            WHERE batch_id = ?
            ORDER BY batch_item_id DESC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, batchId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapBatchItem(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public BatchItem getItemById(int batchItemId) {
        String sql = """
            SELECT batch_item_id, batch_id, product_id, quantity, price, warranty_months
            FROM BATCH_ITEMS
            WHERE batch_item_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, batchItemId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapBatchItem(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean addItem(BatchItem item) {
        String sql = """
            INSERT INTO BATCH_ITEMS 
                (batch_id, product_id, quantity, price, warranty_months)
            VALUES 
                (?, ?, ?, ?, ?)
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, item.getBatchId());
            ps.setInt(2, item.getProductId());
            ps.setInt(3, item.getQuantity());
            ps.setBigDecimal(4, item.getPrice());
            ps.setInt(5, item.getWarrantyMonths());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateItem(BatchItem item) {
        String sql = """
            UPDATE BATCH_ITEMS
            SET batch_id = ?,
                product_id = ?,
                quantity = ?,
                price = ?,
                warranty_months = ?
            WHERE batch_item_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, item.getBatchId());
            ps.setInt(2, item.getProductId());
            ps.setInt(3, item.getQuantity());
            ps.setBigDecimal(4, item.getPrice());
            ps.setInt(5, item.getWarrantyMonths());
            ps.setInt(6, item.getBatchItemId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


    public boolean existsBatchProduct(int batchId, int productId) {
        String sql = """
            SELECT batch_item_id
            FROM BATCH_ITEMS
            WHERE batch_id = ? AND product_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, batchId);
            ps.setInt(2, productId);

            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean hasItemsInBatch(int batchId) {
        String sql = """
            SELECT batch_item_id
            FROM BATCH_ITEMS
            WHERE batch_id = ?
            LIMIT 1
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, batchId);

            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}