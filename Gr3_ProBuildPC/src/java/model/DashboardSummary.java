package model;

import java.math.BigDecimal;

public class DashboardSummary {
    private BigDecimal totalRevenue = BigDecimal.ZERO;
    private int totalOrders;
    private int activeProducts;
    private int totalBrands;
    private int acceptedWarrantyRequests;
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

    public int getAcceptedWarrantyRequests() {
        return acceptedWarrantyRequests;
    }

    public void setAcceptedWarrantyRequests(int acceptedWarrantyRequests) {
        this.acceptedWarrantyRequests = acceptedWarrantyRequests;
    }

    public int getImportedBatches() {
        return importedBatches;
    }

    public void setImportedBatches(int importedBatches) {
        this.importedBatches = importedBatches;
    }
}
