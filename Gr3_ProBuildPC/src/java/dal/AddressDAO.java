package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.Address;

public class AddressDAO {

    @FunctionalInterface
    private interface StatementBinder {
        void bind(PreparedStatement ps) throws SQLException;
    }

    public List<Address> getAddressesByCustomerId(int customerId) {
        List<Address> addresses = new ArrayList<>();
        String sql = """
                     SELECT address_id, customer_id, recipient_name, phoneNumber, Address_detail
                     FROM address
                     WHERE customer_id = ?
                     ORDER BY address_id DESC
                     """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    addresses.add(mapAddress(rs));
                }
            }

        } catch (SQLException e) {
            System.out.println("Loi getAddressesByCustomerId:");
            e.printStackTrace();
        }

        return addresses;
    }

    public Address getAddressByIdAndCustomerId(int addressId, int customerId) {
        String sql = """
                     SELECT address_id, customer_id, recipient_name, phoneNumber, Address_detail
                     FROM address
                     WHERE address_id = ? AND customer_id = ?
                     """;

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, addressId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAddress(rs);
                }
            }

        } catch (SQLException e) {
            System.out.println("Loi getAddressByIdAndCustomerId:");
            e.printStackTrace();
        }

        return null;
    }

    public boolean addAddress(Address address) {
        String sql = """
                     INSERT INTO address(customer_id, recipient_name, phoneNumber, Address_detail)
                     VALUES (?, ?, ?, ?)
                     """;

        try (Connection conn = new DBContext().getConnection()) {
            return executeAddressWrite(conn, sql, ps -> {
                ps.setInt(1, address.getCustomerId());
                ps.setString(2, address.getRecipientName());
                ps.setString(3, address.getPhoneNumber());
                ps.setString(4, address.getAddressDetail());
            });

        } catch (SQLException e) {
            System.out.println("Loi addAddress:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateAddress(Address address) {
        String sql = """
                     UPDATE address
                     SET recipient_name = ?, phoneNumber = ?, Address_detail = ?
                     WHERE address_id = ? AND customer_id = ?
                     """;

        try (Connection conn = new DBContext().getConnection()) {
            return executeAddressWrite(conn, sql, ps -> {
                ps.setString(1, address.getRecipientName());
                ps.setString(2, address.getPhoneNumber());
                ps.setString(3, address.getAddressDetail());
                ps.setInt(4, address.getAddressId());
                ps.setInt(5, address.getCustomerId());
            });

        } catch (SQLException e) {
            System.out.println("Loi updateAddress:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean deleteAddress(int addressId, int customerId) {
        String sql = "DELETE FROM address WHERE address_id = ? AND customer_id = ?";

        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, addressId);
            ps.setInt(2, customerId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.out.println("Loi deleteAddress:");
            e.printStackTrace();
        }

        return false;
    }

    private Address mapAddress(ResultSet rs) throws SQLException {
        Address address = new Address();
        address.setAddressId(rs.getInt("address_id"));
        address.setCustomerId(rs.getInt("customer_id"));
        address.setRecipientName(rs.getString("recipient_name"));
        address.setPhoneNumber(rs.getString("phoneNumber"));
        address.setAddressDetail(rs.getString("Address_detail"));
        return address;
    }

    private boolean executeAddressWrite(Connection conn, String sql, StatementBinder binder) throws SQLException {
        return executeAddressWrite(conn, sql, binder, true);
    }

    private boolean executeAddressWrite(Connection conn, String sql, StatementBinder binder, boolean allowConstraintRecovery)
            throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            binder.bind(ps);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            if (allowConstraintRecovery && isLegacyRecipientConstraintViolation(e) && dropLegacyRecipientUniqueIndex(conn)) {
                return executeAddressWrite(conn, sql, binder, false);
            }

            throw e;
        }
    }

    private boolean isLegacyRecipientConstraintViolation(SQLException e) {
        String message = e.getMessage();
        if (message == null) {
            return false;
        }

        String normalizedMessage = message.toLowerCase();
        return (e.getErrorCode() == 1062 || "23000".equals(e.getSQLState()))
                && normalizedMessage.contains("recipient_name");
    }

    private boolean dropLegacyRecipientUniqueIndex(Connection conn) throws SQLException {
        String legacyIndexName = findLegacyRecipientUniqueIndex(conn);

        if (legacyIndexName == null || !legacyIndexName.matches("[A-Za-z0-9_]+")) {
            return false;
        }

        String sql = "ALTER TABLE address DROP INDEX `" + legacyIndexName + "`";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.executeUpdate();
            return true;
        }
    }

    private String findLegacyRecipientUniqueIndex(Connection conn) throws SQLException {
        String sql = """
                     SELECT INDEX_NAME
                     FROM INFORMATION_SCHEMA.STATISTICS
                     WHERE TABLE_SCHEMA = ?
                       AND TABLE_NAME = 'address'
                       AND COLUMN_NAME = 'recipient_name'
                       AND NON_UNIQUE = 0
                       AND INDEX_NAME <> 'PRIMARY'
                     ORDER BY INDEX_NAME
                     LIMIT 1
                     """;

        String catalog = conn.getCatalog();
        if (catalog == null || catalog.trim().isEmpty()) {
            catalog = "db1";
        }

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, catalog);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("INDEX_NAME");
                }
            }
        }

        return null;
    }
}
