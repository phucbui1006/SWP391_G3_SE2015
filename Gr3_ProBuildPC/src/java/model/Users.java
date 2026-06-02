package model;

public class Users {

    private int userId;
    private int roleId;
    private String fullName;
    private String status;
    private String email;
    private String password;

    public Users() {
    }

    public Users(int userId, int roleId, String fullName,
                String status, String email, String password) {
        this.userId = userId;
        this.roleId = roleId;
        this.fullName = fullName;
        this.status = status;
        this.email = email;
        this.password = password;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

}