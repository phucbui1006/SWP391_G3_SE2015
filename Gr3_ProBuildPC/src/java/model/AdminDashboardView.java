package model;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class AdminDashboardView {
    private LocalDate selectedDate;
    private String formAction;
    private String warrantyAllUrl;
    private List<StatCard> statCards = new ArrayList<>();
    private List<ProductRow> bestSellingProducts = new ArrayList<>();
    private List<ProductRow> lowStockProducts = new ArrayList<>();
    private List<OrderRow> latestOrders = new ArrayList<>();
    private List<CountRow> warrantyStatusCounts = new ArrayList<>();
    private List<CountRow> accountSummaries = new ArrayList<>();
    private String bestSellingFooterMessage;
    private String bestSellingFooterUrl;
    private String lowStockFooterMessage;
    private String lowStockFooterUrl;
    private String latestOrdersFooterMessage;
    private String latestOrdersFooterUrl;
    private String warrantyFooterMessage;
    private boolean showWarrantyFooter;

    public LocalDate getSelectedDate() {
        return selectedDate;
    }

    public void setSelectedDate(LocalDate selectedDate) {
        this.selectedDate = selectedDate;
    }

    public String getFormAction() {
        return formAction;
    }

    public void setFormAction(String formAction) {
        this.formAction = formAction;
    }

    public String getWarrantyAllUrl() {
        return warrantyAllUrl;
    }

    public void setWarrantyAllUrl(String warrantyAllUrl) {
        this.warrantyAllUrl = warrantyAllUrl;
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

    public List<OrderRow> getLatestOrders() {
        return latestOrders;
    }

    public void setLatestOrders(List<OrderRow> latestOrders) {
        this.latestOrders = latestOrders == null ? new ArrayList<>() : latestOrders;
    }

    public List<CountRow> getWarrantyStatusCounts() {
        return warrantyStatusCounts;
    }

    public void setWarrantyStatusCounts(List<CountRow> warrantyStatusCounts) {
        this.warrantyStatusCounts = warrantyStatusCounts == null ? new ArrayList<>() : warrantyStatusCounts;
    }

    public List<CountRow> getAccountSummaries() {
        return accountSummaries;
    }

    public void setAccountSummaries(List<CountRow> accountSummaries) {
        this.accountSummaries = accountSummaries == null ? new ArrayList<>() : accountSummaries;
    }

    public String getBestSellingFooterMessage() {
        return bestSellingFooterMessage;
    }

    public void setBestSellingFooterMessage(String bestSellingFooterMessage) {
        this.bestSellingFooterMessage = bestSellingFooterMessage;
    }

    public String getBestSellingFooterUrl() {
        return bestSellingFooterUrl;
    }

    public void setBestSellingFooterUrl(String bestSellingFooterUrl) {
        this.bestSellingFooterUrl = bestSellingFooterUrl;
    }

    public String getLowStockFooterMessage() {
        return lowStockFooterMessage;
    }

    public void setLowStockFooterMessage(String lowStockFooterMessage) {
        this.lowStockFooterMessage = lowStockFooterMessage;
    }

    public String getLowStockFooterUrl() {
        return lowStockFooterUrl;
    }

    public void setLowStockFooterUrl(String lowStockFooterUrl) {
        this.lowStockFooterUrl = lowStockFooterUrl;
    }

    public String getLatestOrdersFooterMessage() {
        return latestOrdersFooterMessage;
    }

    public void setLatestOrdersFooterMessage(String latestOrdersFooterMessage) {
        this.latestOrdersFooterMessage = latestOrdersFooterMessage;
    }

    public String getLatestOrdersFooterUrl() {
        return latestOrdersFooterUrl;
    }

    public void setLatestOrdersFooterUrl(String latestOrdersFooterUrl) {
        this.latestOrdersFooterUrl = latestOrdersFooterUrl;
    }

    public String getWarrantyFooterMessage() {
        return warrantyFooterMessage;
    }

    public void setWarrantyFooterMessage(String warrantyFooterMessage) {
        this.warrantyFooterMessage = warrantyFooterMessage;
    }

    public boolean isShowWarrantyFooter() {
        return showWarrantyFooter;
    }

    public void setShowWarrantyFooter(boolean showWarrantyFooter) {
        this.showWarrantyFooter = showWarrantyFooter;
    }

    public static class StatCard {
        private final String iconClass;
        private final String icon;
        private final String label;
        private final String value;

        public StatCard(String iconClass, String icon, String label, String value) {
            this.iconClass = iconClass;
            this.icon = icon;
            this.label = label;
            this.value = value;
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

    public static class OrderRow {
        private final String orderCode;
        private final String customerName;
        private final String totalAmount;
        private final String status;
        private final String statusClass;
        private final String orderDate;

        public OrderRow(String orderCode, String customerName, String totalAmount, String status,
                String statusClass, String orderDate) {
            this.orderCode = orderCode;
            this.customerName = customerName;
            this.totalAmount = totalAmount;
            this.status = status;
            this.statusClass = statusClass;
            this.orderDate = orderDate;
        }

        public String getOrderCode() {
            return orderCode;
        }

        public String getCustomerName() {
            return customerName;
        }

        public String getTotalAmount() {
            return totalAmount;
        }

        public String getStatus() {
            return status;
        }

        public String getStatusClass() {
            return statusClass;
        }

        public String getOrderDate() {
            return orderDate;
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
}
