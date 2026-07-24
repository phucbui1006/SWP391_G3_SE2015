package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.BatchItem;

public class BatchItemDAO extends DBContext {

    public BatchItemDAO() {
        super();
        try {
            if (connection != null) {
                try (java.sql.Statement stmt = connection.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE BATCH_ITEMS ADD COLUMN is_edited TINYINT(1) DEFAULT 0");
                } catch (Exception ignored) {
                    // Column already exists
                }
            }
        } catch (Exception ignored) {}
    }

    private BatchItem mapBatchItem(ResultSet rs) throws Exception {
        BatchItem item = new BatchItem();

        item.setBatchItemId(rs.getInt("batch_item_id"));
        item.setBatchId(rs.getInt("batch_id"));
        item.setProductId(rs.getInt("product_id"));
        item.setImportQuantity(rs.getInt("import_quantity"));
        item.setQuantity(rs.getInt("quantity"));
        item.setPrice(rs.getBigDecimal("price"));
        try {
            item.setEdited(rs.getBoolean("is_edited"));
        } catch (Exception ignored) {}

        return item;
    }

    public List<BatchItem> getItemsByBatchId(int batchId) {
        List<BatchItem> list = new ArrayList<>();

        String sql = """
            SELECT batch_item_id, batch_id, product_id, import_quantity, quantity, price, is_edited
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
            SELECT batch_item_id, batch_id, product_id, import_quantity, quantity, price, is_edited
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
                (batch_id, product_id, import_quantity, quantity, price, is_edited)
            VALUES 
                (?, ?, ?, ?, ?, 0)
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, item.getBatchId());
            ps.setInt(2, item.getProductId());
            ps.setInt(3, item.getImportQuantity());
            ps.setInt(4, item.getQuantity());
            ps.setBigDecimal(5, item.getPrice());

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

    public boolean updateItem(int batchItemId, int newImportQuantity, java.math.BigDecimal newPrice) {
        String sql = """
            UPDATE BATCH_ITEMS
            SET import_quantity = ?, quantity = ?, price = ?, is_edited = 1
            WHERE batch_item_id = ? AND quantity = import_quantity
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, newImportQuantity);
            ps.setInt(2, newImportQuantity);
            ps.setBigDecimal(3, newPrice);
            ps.setInt(4, batchItemId);

            return ps.executeUpdate() > 0;

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