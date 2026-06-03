package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import model.User;

public class UserDAO {

    public User login(String email, String password) {
        String sql = """
                     SELECT u.user_id, u.role_id, u.full_name, u.status,
                            u.email, u.password, r.role_name
                     FROM users u
                     JOIN Roles r ON u.role_id = r.role_id
                     WHERE u.email = ?
                       AND u.password = ?
                       AND u.status = 1
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
                u.setStatus(rs.getInt("status"));
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
            ps.setInt(3, 1);
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
}
