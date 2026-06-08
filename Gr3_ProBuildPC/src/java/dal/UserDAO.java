package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import model.Role;
import model.User;

public class UserDAO {

    public User login(String email, String password) {
        String sql = """
                     SELECT u.user_id, u.role_id, u.full_name, u.status,
                            u.email, u.password, r.role_name
                     FROM users u
                     JOIN roles r ON u.role_id = r.role_id
                     WHERE u.email = ?
                       AND u.password = ?
                       AND u.status = 'ACTIVE'
                     """;

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User u = new User();

                u.setUserId(rs.getInt("user_id"));
                u.setRoleId(rs.getInt("role_id"));
                u.setFullName(rs.getString("full_name"));
                u.setStatus(rs.getString("status"));
                u.setEmail(rs.getString("email"));
                u.setPassword(rs.getString("password"));
                u.setRoleName(rs.getString("role_name"));

                return u;
            }

        } catch (Exception e) {
            System.out.println("Loi login:");
            e.printStackTrace();
        }

        return null;
    }

    public boolean checkEmailExist(String email) {
        String sql = "SELECT user_id FROM users WHERE email = ?";

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {
            System.out.println("Loi checkEmailExist:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean registerCustomer(String fullName, String email, String password) {
        String sql = """
                     INSERT INTO users(role_id, full_name, status, email, password)
                     VALUES (?, ?, ?, ?, ?)
                     """;

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setInt(1, 1);
            ps.setString(2, fullName);
            ps.setString(3, "ACTIVE");
            ps.setString(4, email);
            ps.setString(5, password);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Loi registerCustomer:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updatePassword(String email, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE email = ?";

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);

            ps.setString(1, newPassword);
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

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement st = conn.prepareStatement(sql);

            st.setString(1, fullName);
            st.setString(2, password);
            st.setString(3, email);

            int rowsAffected = st.executeUpdate();

            System.out.println("====== DEBUG UPDATE PROFILE ======");
            System.out.println("Email truyen vao: " + email);
            System.out.println("So dong duoc cap nhat trong DB: " + rowsAffected);
            System.out.println("==================================");

            return rowsAffected > 0;

        } catch (Exception e) {
            System.out.println("LOI UPDATE PROFILE:");
            e.printStackTrace();
        }
        return false;
    }

    public List<User> getUsers(String keyword, Integer roleId, String status, int offset, int pageSize) {
        List<User> users = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        String sql = """
                     SELECT u.user_id, u.role_id, u.full_name, u.status,
                            u.email, u.password, r.role_name
                     FROM users u
                     JOIN roles r ON u.role_id = r.role_id
                     """
                + buildUserFilterClause(keyword, roleId, status, params)
                + """
                     ORDER BY u.user_id ASC
                     LIMIT ? OFFSET ?
                     """;

        params.add(pageSize);
        params.add(offset);

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            bindParameters(ps, params);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("user_id"));
                user.setRoleId(rs.getInt("role_id"));
                user.setFullName(rs.getString("full_name"));
                user.setStatus(rs.getString("status"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRoleName(rs.getString("role_name"));
                users.add(user);
            }
        } catch (Exception e) {
            System.out.println("Loi getUsers:");
            e.printStackTrace();
        }

        return users;
    }

    public int countUsers(String keyword, Integer roleId, String status) {
        List<Object> params = new ArrayList<>();

        String sql = """
                     SELECT COUNT(*)
                     FROM users u
                     JOIN roles r ON u.role_id = r.role_id
                     """
                + buildUserFilterClause(keyword, roleId, status, params);

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            bindParameters(ps, params);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            System.out.println("Loi countUsers:");
            e.printStackTrace();
        }

        return 0;
    }

    public List<Role> getRoles() {
        List<Role> roles = new ArrayList<>();
        String sql = """
                     SELECT role_id, role_name
                     FROM roles
                     ORDER BY role_id ASC
                     """;

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                roles.add(new Role(
                        rs.getInt("role_id"),
                        rs.getString("role_name")
                ));
            }
        } catch (Exception e) {
            System.out.println("Loi getRoles:");
            e.printStackTrace();
        }

        return roles;
    }

    public boolean updateUserRole(int userId, int roleId) {
        String sql = """
                     UPDATE users u
                     JOIN roles current_role ON u.role_id = current_role.role_id
                     SET u.role_id = ?
                     WHERE u.user_id = ?
                       AND UPPER(current_role.role_name) <> 'ADMIN'
                       AND EXISTS (
                           SELECT 1
                           FROM roles target_role
                           WHERE target_role.role_id = ?
                       )
                     """;

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, roleId);
            ps.setInt(2, userId);
            ps.setInt(3, roleId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Loi updateUserRole:");
            e.printStackTrace();
        }

        return false;
    }

    public boolean updateUserStatus(int userId, String status) {
        String sql = """
                     UPDATE users u
                     JOIN roles r ON u.role_id = r.role_id
                     SET u.status = ?
                     WHERE u.user_id = ?
                       AND UPPER(r.role_name) <> 'ADMIN'
                     """;

        try {
            Connection conn = new DBContext().getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Loi updateUserStatus:");
            e.printStackTrace();
        }

        return false;
    }

    private String buildUserFilterClause(String keyword, Integer roleId, String status, List<Object> params) {
        StringBuilder sql = new StringBuilder(" WHERE 1 = 1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            String searchValue = "%" + keyword.trim().toLowerCase() + "%";
            sql.append(" AND (LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ?) ");
            params.add(searchValue);
            params.add(searchValue);
        }

        if (roleId != null) {
            sql.append(" AND u.role_id = ? ");
            params.add(roleId);
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND UPPER(u.status) = ? ");
            params.add(status.trim().toUpperCase());
        }

        return sql.toString();
    }

    private void bindParameters(PreparedStatement ps, List<Object> params) throws Exception {
        for (int i = 0; i < params.size(); i++) {
            Object value = params.get(i);
            int index = i + 1;

            if (value instanceof Integer integerValue) {
                ps.setInt(index, integerValue);
            } else {
                ps.setString(index, String.valueOf(value));
            }
        }
    }
}
