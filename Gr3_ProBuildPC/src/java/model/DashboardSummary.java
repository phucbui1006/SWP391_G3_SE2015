package model;

import java.math.BigDecimal;

public class DashboardSummary {
    private BigDecimal totalRevenue = BigDecimal.ZERO;
    private int totalOrders;
    private int importedBatches;

    public DashboardSummary() {
    }

    public BigDecimal getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(BigDecimal totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public int getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(int totalOrders) {
        this.totalOrders = totalOrders;
    }

    public int getImportedBatches() {
        return importedBatches;
    }

    public void setImportedBatches(int importedBatches) {
        this.importedBatches = importedBatches;
    }
}
