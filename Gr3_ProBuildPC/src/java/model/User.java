package model;

public class User {
    private int userId;
    private int roleId;
    private String fullName;
    private String status;
    private String email;
    private String password;
    private String roleName;

    public User() {
    }

    public User(int userId, int roleId, String fullName, String status, String email, String password, String roleName) {
        this.userId = userId;
        this.roleId = roleId;
        this.fullName = fullName;
        this.status = status;
        this.email = email;
        this.password = password;
        this.roleName = roleName;
    }

    public int getUserId() {
        return userId;
    }

    public int getRoleId() {
        return roleId;
    }

    public String getFullName() {
        return fullName;
    }

    public String getStatus() {
        return status;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
}