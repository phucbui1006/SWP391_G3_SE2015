package model;

public class User {
    private int userId;
    private String fullName;
    private String status;
    private String email;
    private String password;
    private String accountType;
    private int customerId;
    private int staffId;
    private int roleId;
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
        this.accountType = "CUSTOMER".equalsIgnoreCase(roleName) ? "CUSTOMER" : "STAFF";
    }

    public User(int userId, String fullName, String status, String email, String password,
                String accountType, int customerId, int staffId, int roleId, String roleName) {
        this.userId = userId;
        this.fullName = fullName;
        this.status = status;
        this.email = email;
        this.password = password;
        this.accountType = accountType;
        this.customerId = customerId;
        this.staffId = staffId;
        this.roleId = roleId;
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

    public String getAccountType() {
        return accountType;
    }

    public int getCustomerId() {
        return customerId;
    }

    public int getStaffId() {
        return staffId;
    }

    public boolean isCustomer() {
        return "CUSTOMER".equalsIgnoreCase(accountType) && customerId > 0;
    }

    public boolean isStaff() {
        return "STAFF".equalsIgnoreCase(accountType) && staffId > 0;
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

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public void setStaffId(int staffId) {
        this.staffId = staffId;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }
}
