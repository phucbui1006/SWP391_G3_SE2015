package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Batch;

public class BatchDAO extends DBContext {

    public BatchDAO() {
        super();
        ensureIsEditedColumnExists();
    }

    private void ensureIsEditedColumnExists() {
        try {
            String checkSql = "SHOW COLUMNS FROM BATCH LIKE 'is_edited'";
            PreparedStatement psCheck = connection.prepareStatement(checkSql);
            ResultSet rs = psCheck.executeQuery();
            if (!rs.next()) {
                String alterSql = "ALTER TABLE BATCH ADD COLUMN is_edited TINYINT(1) DEFAULT 0";
                PreparedStatement psAlter = connection.prepareStatement(alterSql);
                psAlter.executeUpdate();
            }
        } catch (Exception e) {
            // Column may already exist
        }
    }

    private Batch mapBatch(ResultSet rs) throws Exception {
        Batch b = new Batch();

        b.setBatchId(rs.getInt("batch_id"));
        b.setBatchName(rs.getString("batch_name"));
        b.setDate(rs.getDate("date"));
        try {
            b.setEdited(rs.getBoolean("is_edited"));
        } catch (Exception e) {
            b.setEdited(false);
        }

        return b;
    }

    public List<Batch> getAllBatches() {
        List<Batch> list = new ArrayList<>();

        String sql = """
            SELECT batch_id, batch_name, date, is_edited
            FROM BATCH
            ORDER BY batch_id ASC
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapBatch(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int countBatches() {
        String sql = "SELECT COUNT(*) FROM BATCH";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Batch> getBatches(int offset, int limit) {
        List<Batch> list = new ArrayList<>();
        String sql = """
            SELECT batch_id, batch_name, date, is_edited
            FROM BATCH
            ORDER BY batch_id ASC
            LIMIT ? OFFSET ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setInt(2, offset);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapBatch(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public Batch getBatchById(int batchId) {
        String sql = """
            SELECT batch_id, batch_name, date, is_edited
            FROM BATCH
            WHERE batch_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, batchId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return mapBatch(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean addBatch(Batch batch) {
        String sql = """
            INSERT INTO BATCH (batch_name, date)
            VALUES (?, ?)
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, batch.getBatchName());
            ps.setDate(2, batch.getDate());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateBatch(int batchId, String batchName, java.sql.Date date) {
        String sql = """
            UPDATE BATCH
            SET batch_name = ?, date = ?, is_edited = 1
            WHERE batch_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, batchName);
            ps.setDate(2, date);
            ps.setInt(3, batchId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}