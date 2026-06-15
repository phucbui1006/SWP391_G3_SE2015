package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Batch;

public class BatchDAO extends DBContext {

    private Batch mapBatch(ResultSet rs) throws Exception {
        Batch b = new Batch();

        b.setBatchId(rs.getInt("batch_id"));
        b.setBatchName(rs.getString("batch_name"));
        b.setDate(rs.getDate("date"));

        return b;
    }

    public List<Batch> getAllBatches() {
        List<Batch> list = new ArrayList<>();

        String sql = """
            SELECT batch_id, batch_name, date
            FROM BATCH
            ORDER BY batch_id DESC
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

    public Batch getBatchById(int batchId) {
        String sql = """
            SELECT batch_id, batch_name, date
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

    public boolean updateBatch(Batch batch) {
        String sql = """
            UPDATE BATCH
            SET batch_name = ?, date = ?
            WHERE batch_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setString(1, batch.getBatchName());
            ps.setDate(2, batch.getDate());
            ps.setInt(3, batch.getBatchId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteBatch(int batchId) {
        String sql = """
            DELETE FROM BATCH
            WHERE batch_id = ?
        """;

        try {
            PreparedStatement ps = connection.prepareStatement(sql);

            ps.setInt(1, batchId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}