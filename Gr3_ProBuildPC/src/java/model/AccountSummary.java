package model;

public class AccountSummary {
    private int customers;
    private int employees;
    private int transports;
    private int locked;
    private int active;

    public AccountSummary() {
    }

    public int getCustomers() {
        return customers;
    }

    public void setCustomers(int customers) {
        this.customers = customers;
    }

    public int getEmployees() {
        return employees;
    }

    public void setEmployees(int employees) {
        this.employees = employees;
    }

    public int getTransports() {
        return transports;
    }

    public void setTransports(int transports) {
        this.transports = transports;
    }

    public int getLocked() {
        return locked;
    }

    public void setLocked(int locked) {
        this.locked = locked;
    }

    public int getActive() {
        return active;
    }

    public void setActive(int active) {
        this.active = active;
    }
}
