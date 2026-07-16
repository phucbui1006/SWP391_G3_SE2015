package model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class AdminDashboardView {
    private String formAction;
    private List<StatCard> statCards = new ArrayList<>();
    private List<ProductRow> bestSellingProducts = new ArrayList<>();
    private List<CountRow> accountSummaries = new ArrayList<>();
    private List<ChartPoint> revenueTimeline = new ArrayList<>();
    private List<ChartPoint> categorySoldProducts = new ArrayList<>();
    private List<ChartPoint> orderStatusCounts = new ArrayList<>();
    private List<ChartPoint> lowStockProductsChart = new ArrayList<>();
    private LocalDate chartStartDate;
    private LocalDate chartEndDate;
    private String chartPeriodLabel;

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

    public List<ChartPoint> getCategorySoldProducts() {
        return categorySoldProducts;
    }

    public void setCategorySoldProducts(List<ChartPoint> categorySoldProducts) {
        this.categorySoldProducts = categorySoldProducts == null ? new ArrayList<>() : categorySoldProducts;
    }

    public List<ChartPoint> getOrderStatusCounts() {
        return orderStatusCounts;
    }

    public void setOrderStatusCounts(List<ChartPoint> orderStatusCounts) {
        this.orderStatusCounts = orderStatusCounts == null ? new ArrayList<>() : orderStatusCounts;
    }

    public List<ChartPoint> getLowStockProductsChart() {
        return lowStockProductsChart;
    }

    public void setLowStockProductsChart(List<ChartPoint> lowStockProductsChart) {
        this.lowStockProductsChart = lowStockProductsChart == null ? new ArrayList<>() : lowStockProductsChart;
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
        private final String productName;
        private final int soldQuantity;

        public ProductRow(String productName, int soldQuantity) {
            this.productName = productName;
            this.soldQuantity = soldQuantity;
        }

        public String getProductName() {
            return productName;
        }

        public int getSoldQuantity() {
            return soldQuantity;
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
