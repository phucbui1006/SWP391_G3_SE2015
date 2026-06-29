package model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class AdminDashboardView {
    private String formAction;
    private List<StatCard> statCards = new ArrayList<>();
    private List<ProductRow> bestSellingProducts = new ArrayList<>();
    private List<ProductRow> lowStockProducts = new ArrayList<>();
    private List<OrderSummaryRow> orderSummaries = new ArrayList<>();
    private List<CountRow> accountSummaries = new ArrayList<>();
    private List<ChartPoint> revenueTimeline = new ArrayList<>();
    private List<ChartPoint> categoryRevenue = new ArrayList<>();
    private LocalDate chartStartDate;
    private LocalDate chartEndDate;
    private String chartPeriodLabel;
    private String bestSellingFooterMessage;
    private String lowStockFooterMessage;

    public String getFormAction() {
        return formAction;
    }

    public void setFormAction(String formAction) {
        this.formAction = formAction;
    }

    public List<StatCard> getStatCards() {
        return statCards;
    }

    public void setStatCards(List<StatCard> statCards) {
        this.statCards = statCards == null ? new ArrayList<>() : statCards;
    }

    public List<ProductRow> getBestSellingProducts() {
        return bestSellingProducts;
    }

    public void setBestSellingProducts(List<ProductRow> bestSellingProducts) {
        this.bestSellingProducts = bestSellingProducts == null ? new ArrayList<>() : bestSellingProducts;
    }

    public List<ProductRow> getLowStockProducts() {
        return lowStockProducts;
    }

    public void setLowStockProducts(List<ProductRow> lowStockProducts) {
        this.lowStockProducts = lowStockProducts == null ? new ArrayList<>() : lowStockProducts;
    }

    public List<OrderSummaryRow> getOrderSummaries() {
        return orderSummaries;
    }

    public void setOrderSummaries(List<OrderSummaryRow> orderSummaries) {
        this.orderSummaries = orderSummaries == null ? new ArrayList<>() : orderSummaries;
    }

    public List<CountRow> getAccountSummaries() {
        return accountSummaries;
    }

    public void setAccountSummaries(List<CountRow> accountSummaries) {
        this.accountSummaries = accountSummaries == null ? new ArrayList<>() : accountSummaries;
    }

    public List<ChartPoint> getRevenueTimeline() {
        return revenueTimeline;
    }

    public void setRevenueTimeline(List<ChartPoint> revenueTimeline) {
        this.revenueTimeline = revenueTimeline == null ? new ArrayList<>() : revenueTimeline;
    }

    public List<ChartPoint> getCategoryRevenue() {
        return categoryRevenue;
    }

    public void setCategoryRevenue(List<ChartPoint> categoryRevenue) {
        this.categoryRevenue = categoryRevenue == null ? new ArrayList<>() : categoryRevenue;
    }

    public LocalDate getChartStartDate() {
        return chartStartDate;
    }

    public void setChartStartDate(LocalDate chartStartDate) {
        this.chartStartDate = chartStartDate;
    }

    public LocalDate getChartEndDate() {
        return chartEndDate;
    }

    public void setChartEndDate(LocalDate chartEndDate) {
        this.chartEndDate = chartEndDate;
    }

    public String getChartPeriodLabel() {
        return chartPeriodLabel;
    }

    public void setChartPeriodLabel(String chartPeriodLabel) {
        this.chartPeriodLabel = chartPeriodLabel;
    }

    public String getBestSellingFooterMessage() {
        return bestSellingFooterMessage;
    }

    public void setBestSellingFooterMessage(String bestSellingFooterMessage) {
        this.bestSellingFooterMessage = bestSellingFooterMessage;
    }

    public String getLowStockFooterMessage() {
        return lowStockFooterMessage;
    }

    public void setLowStockFooterMessage(String lowStockFooterMessage) {
        this.lowStockFooterMessage = lowStockFooterMessage;
    }

    public static class StatCard {
        private final String iconClass;
        private final String icon;
        private final String label;
        private final String value;
        private final String url;

        public StatCard(String iconClass, String icon, String label, String value, String url) {
            this.iconClass = iconClass;
            this.icon = icon;
            this.label = label;
            this.value = value;
            this.url = url;
        }

        public String getIconClass() {
            return iconClass;
        }

        public String getIcon() {
            return icon;
        }

        public String getLabel() {
            return label;
        }

        public String getValue() {
            return value;
        }

        public String getUrl() {
            return url;
        }
    }

    public static class ProductRow {
        private final String productCode;
        private final String productName;
        private final int soldQuantity;
        private final int stockQuantity;
        private final String status;
        private final String statusClass;

        public ProductRow(String productCode, String productName, int soldQuantity, int stockQuantity,
                String status, String statusClass) {
            this.productCode = productCode;
            this.productName = productName;
            this.soldQuantity = soldQuantity;
            this.stockQuantity = stockQuantity;
            this.status = status;
            this.statusClass = statusClass;
        }

        public String getProductCode() {
            return productCode;
        }

        public String getProductName() {
            return productName;
        }

        public int getSoldQuantity() {
            return soldQuantity;
        }

        public int getStockQuantity() {
            return stockQuantity;
        }

        public String getStatus() {
            return status;
        }

        public String getStatusClass() {
            return statusClass;
        }
    }

    public static class OrderSummaryRow {
        private final String label;
        private final String value;
        private final String note;
        private final String statusClass;

        public OrderSummaryRow(String label, String value, String note, String statusClass) {
            this.label = label;
            this.value = value;
            this.note = note;
            this.statusClass = statusClass;
        }

        public String getLabel() {
            return label;
        }

        public String getValue() {
            return value;
        }

        public String getNote() {
            return note;
        }

        public String getStatusClass() {
            return statusClass;
        }
    }

    public static class CountRow {
        private final String label;
        private final int value;

        public CountRow(String label, int value) {
            this.label = label;
            this.value = value;
        }

        public String getLabel() {
            return label;
        }

        public int getValue() {
            return value;
        }
    }

    public static class ChartPoint {
        private final String label;
        private final BigDecimal value;

        public ChartPoint(String label, BigDecimal value) {
            this.label = label;
            this.value = value == null ? BigDecimal.ZERO : value;
        }

        public String getLabel() {
            return label;
        }

        public BigDecimal getValue() {
            return value;
        }
    }
}
