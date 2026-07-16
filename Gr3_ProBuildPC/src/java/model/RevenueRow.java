package model;

import java.math.BigDecimal;
import java.math.RoundingMode;
import util.DashboardViewHelper;

public class RevenueRow {
    private String label;
    private int orderCount;
    private BigDecimal revenue;
    private BigDecimal average;
    private int productsSold;

    public RevenueRow(String label, int orderCount, BigDecimal revenue) {
        this(label, orderCount, revenue, 0);
    }

    public RevenueRow(String label, int orderCount, BigDecimal revenue, int productsSold) {
        this.label = label;
        this.orderCount = orderCount;
        this.revenue = revenue == null ? BigDecimal.ZERO : revenue;
        this.productsSold = productsSold;
        if (this.orderCount > 0) {
            this.average = this.revenue.divide(new BigDecimal(this.orderCount), 0, RoundingMode.HALF_UP);
        } else {
            this.average = BigDecimal.ZERO;
        }
    }

    public int getProductsSold() {
        return productsSold;
    }

    public void setProductsSold(int productsSold) {
        this.productsSold = productsSold;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public int getOrderCount() {
        return orderCount;
    }

    public void setOrderCount(int orderCount) {
        this.orderCount = orderCount;
    }

    public BigDecimal getRevenue() {
        return revenue;
    }

    public void setRevenue(BigDecimal revenue) {
        this.revenue = revenue;
    }

    public BigDecimal getAverage() {
        return average;
    }

    public void setAverage(BigDecimal average) {
        this.average = average;
    }

    public String getFormattedRevenue() {
        return DashboardViewHelper.formatCurrency(revenue);
    }

    public String getFormattedAverage() {
        return DashboardViewHelper.formatCurrency(average);
    }
}
