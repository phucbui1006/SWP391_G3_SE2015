package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import model.Role;
import model.User;

public class UserDAO {

    public User login(String email, String password) {
        String sql = baseUserSelect() + """
                     WHERE u.email = ?
                       AND (
                           (UPPER(u.account_type) = 'CUSTOMER' AND c.customer_id IS NOT NULL)
                           OR
                           (UPPER(u.account_type) = 'STAFF' AND s.staff_id IS NOT NULL AND r.role_id IS NOT NULL)
                       )
                     """;

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapUser(rs);
                    String storedPassword = user.getPassword();
                    
                    String targetHash = storedPassword;
                    if (storedPassword != null && storedPassword.startsWith("!FIRST!")) {
                        targetHash = storedPassword.substring("!FIRST!".length());
                    }

                    if (util.PasswordUtil.verify(password, targetHash)) {
                        return user;
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Loi login:");
            e.printStackTrace();
        }

        return null;
    }

       public boolean checkEmailExist(String email) {
        String sql = "SELECT user_id FROM users WHERE email = ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            System.out.println("Loi checkEmailExist:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean registerCustomer(String fullName, String email, String password) {
        String insertCustomerSql = "INSERT INTO customers(user_id) VALUES (?)";

        try (Connection conn = new DBContext().getConnection()) {
            conn.setAutoCommit(false);

            int userId = insertUser(conn, fullName, email, password, "CUSTOMER");
            if (userId <= 0) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(insertCustomerSql)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            System.out.println("Loi registerCustomer:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean createStaff(String fullName, String email, String password, int roleId) {
        String insertStaffSql = "INSERT INTO staffs(user_id, role_id) VALUES (?, ?)";

        try (Connection conn = new DBContext().getConnection()) {
            if (!roleExists(conn, roleId)) {
                return false;
            }

            conn.setAutoCommit(false);

            int userId = insertUser(conn, fullName, email, password, "STAFF");
            if (userId <= 0) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(insertStaffSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, roleId);
                ps.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            System.out.println("Loi createStaff:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updatePassword(String email, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE email = ?";
        String hashToStore;
        if (newPassword != null && newPassword.startsWith("!FIRST!")) {
            hashToStore = "!FIRST!" + util.PasswordUtil.hash(newPassword.substring("!FIRST!".length()));
        } else {
            hashToStore = util.PasswordUtil.hash(newPassword);
        }

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, hashToStore);
            ps.setString(2, email);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Loi updatePassword:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateProfile(String email, String fullName, String password) {
        String sql = "UPDATE users SET full_name = ?, password = ? WHERE email = ?";
        String hashToStore;
        if (password != null && password.contains(":")) {
            hashToStore = password;
        } else {
            hashToStore = util.PasswordUtil.hash(password);
        }

        try (Connection conn = new DBContext().getConnection(); PreparedStatement st = conn.prepareStatement(sql)) {

            st.setString(1, fullName);
            st.setString(2, hashToStore);
            st.setString(3, email);

            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("LOI UPDATE PROFILE:");
            e.printStackTrace();
        }

        return false;
    }

    public List<User> getUsers(String keyword, Integer roleId, String status, String accountType, int page, int pageSize) {
        List<User> users = new ArrayList<>();
        StringBuilder sql = new StringBuilder(baseUserSelect());
        sql.append(" WHERE 1 = 1 ");

        List<Object> params = new ArrayList<>();
        appendUserFilters(sql, params, keyword, roleId, status, accountType);
        sql.append(" ORDER BY u.user_id ASC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            setParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUser(rs));
                }
            }
        } catch (Exception e) {
            System.out.println("Loi getUsers:");
            e.printStackTrace();
        }

        return users;
    }

    public int countUsers(String keyword, Integer roleId, String status, String accountType) {
        StringBuilder sql = new StringBuilder("""
                     SELECT COUNT(*) AS total
                     FROM users u
                     LEFT JOIN customers c ON c.user_id = u.user_id
                     LEFT JOIN staffs s ON s.user_id = u.user_id
                     LEFT JOIN roles r ON r.role_id = s.role_id
                     WHERE 1 = 1
                     """);

        List<Object> params = new ArrayList<>();
        appendUserFilters(sql, params, keyword, roleId, status, accountType);

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            setParameters(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (Exception e) {
            System.out.println("Loi countUsers:");
            e.printStackTrace();
        }

        return 0;
    }

    public List<Role> getRoles() {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT role_id, role_name FROM roles ORDER BY role_id ASC";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                roles.add(new Role(rs.getInt("role_id"), rs.getString("role_name")));
            }
        } catch (Exception e) {
            System.out.println("Loi getRoles:");
            e.printStackTrace();
        }

        return roles;
    }

    public User getUserById(int userId) {
        String sql = baseUserSelect() + " WHERE u.user_id = ?";

        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        } catch (Exception e) {
            System.out.println("Loi getUserById:");
            e.printStackTrace();
        }

        return null;
    }

    public boolean updateUserRole(int userId, int roleId) {
        String sql = """
                     UPDATE staffs s
                     SET s.role_id = ?
                     WHERE s.user_id = ?
                     """;

        try (Connection conn = new DBContext().getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, roleId);
                ps.setInt(2, userId);

                return ps.executeUpdate() > 0;
            }

        } catch (Exception e) {
            System.out.println("Loi updateUserRole:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateUserStatus(int userId, String status) {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";
        try (Connection conn = new DBContext().getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Loi updateUserStatus:");
            e.printStackTrace();
        }

        return false;
    }

    private int insertUser(Connection conn, String fullName, String email, String password, String accountType)
            throws Exception {
        String sql = """
                     INSERT INTO users(full_name, status, email, password, account_type)
                     VALUES (?, 'ACTIVE', ?, ?, ?)
                     """;

        String hashToStore;
        if (password != null && password.startsWith("!FIRST!")) {
            hashToStore = "!FIRST!" + util.PasswordUtil.hash(password.substring("!FIRST!".length()));
        } else {
            hashToStore = util.PasswordUtil.hash(password);
        }

        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, hashToStore);
            ps.setString(4, accountType);

            if (ps.executeUpdate() <= 0) {
                return -1;
            }

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }

        return -1;
    }
    
    private boolean roleExists(Connection conn, int roleId) throws Exception {
        String sql = "SELECT role_id FROM roles WHERE role_id = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, roleId);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private String baseUserSelect() {
        return """
               SELECT u.user_id, u.full_name, u.status, u.email, u.password, u.account_type,
                      c.customer_id,
                      s.staff_id,
                      s.role_id,
                      CASE
                          WHEN UPPER(u.account_type) = 'CUSTOMER' THEN 'CUSTOMER'
                          ELSE r.role_name
                      END AS role_name
               FROM users u
               LEFT JOIN customers c ON c.user_id = u.user_id
               LEFT JOIN staffs s ON s.user_id = u.user_id
               LEFT JOIN roles r ON r.role_id = s.role_id
               """;
    }

    private void appendUserFilters(StringBuilder sql, List<Object> params, String keyword, Integer roleId, String status, String accountType) {
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ?) ");
            String search = "%" + keyword.trim().toLowerCase() + "%";
            params.add(search);
            params.add(search);
        }

        if (roleId != null) {
            if (roleId == -1) {
                // Nếu chọn lọc Customer (mã -1 định nghĩa trên JSP), lọc theo account_type
                sql.append(" AND UPPER(u.account_type) = 'CUSTOMER' ");
            } else {
                // Nếu chọn lọc các vai trò nhân viên thông thường (1, 2, 3...)
                sql.append(" AND UPPER(u.account_type) = 'STAFF' AND s.role_id = ? ");
                params.add(roleId);
            }
        } else if (accountType != null && !accountType.isEmpty()) {
            sql.append(" AND UPPER(u.account_type) = ? ");
            params.add(accountType.trim().toUpperCase());
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND UPPER(u.status) = ? ");
            params.add(status.trim().toUpperCase());
        }
    }

    private void setParameters(PreparedStatement ps, List<Object> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            if (value instanceof Integer) {
                ps.setInt(i + 1, (Integer) value);
            } else {
                ps.setString(i + 1, String.valueOf(value));
            }
        }
    }

    private User mapUser(ResultSet rs) throws Exception {
        User u = new User();

        String accountType = rs.getString("account_type");
        String roleName = rs.getString("role_name");
        if ("CUSTOMER".equalsIgnoreCase(accountType)) {
            roleName = "CUSTOMER";
        } else {
            roleName = normalizeStaffRoleName(getNullableInt(rs, "role_id"), roleName);
        }

        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setStatus(rs.getString("status"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setAccountType(accountType);
        u.setCustomerId(getNullableInt(rs, "customer_id"));
        u.setStaffId(getNullableInt(rs, "staff_id"));
        u.setRoleId(getNullableInt(rs, "role_id"));
        u.setRoleName(roleName);

        return u;
    }

    private String normalizeStaffRoleName(int roleId, String roleName) {
        switch (roleId) {
            case 1:
                return "ADMIN";
            case 2:
                return "EMPLOYEE";
            case 3:
                return "SHIPMENT";
            default:
                return roleName;
        }
    }

    private int getNullableInt(ResultSet rs, String columnName) throws Exception {
        int value = rs.getInt(columnName);
        return rs.wasNull() ? 0 : value;
    }
}
