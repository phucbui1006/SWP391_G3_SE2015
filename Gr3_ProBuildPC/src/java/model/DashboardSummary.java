package model;

import java.math.BigDecimal;

public class DashboardSummary {
    private BigDecimal totalRevenue = BigDecimal.ZERO;
    private int totalOrders;
    private int activeProducts;
    private int totalBrands;
    private int warrantyRequests;
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

    public int getActiveProducts() {
        return activeProducts;
    }

    public void setActiveProducts(int activeProducts) {
        this.activeProducts = activeProducts;
    }

    public int getTotalBrands() {
        return totalBrands;
    }

    public void setTotalBrands(int totalBrands) {
        this.totalBrands = totalBrands;
    }

    public int getWarrantyRequests() {
        return warrantyRequests;
    }

    public void setWarrantyRequests(int warrantyRequests) {
        this.warrantyRequests = warrantyRequests;
    }

    public int getImportedBatches() {
        return importedBatches;
    }

    public void setImportedBatches(int importedBatches) {
        this.importedBatches = importedBatches;
    }
}
