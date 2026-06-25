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
    private List<OrderSummaryRow> orderSummaries = new ArrayList<>();
    private List<CountRow> warrantyStatusCounts = new ArrayList<>();
    private List<CountRow> accountSummaries = new ArrayList<>();
    private String bestSellingFooterMessage;
    private String lowStockFooterMessage;
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

    public List<OrderSummaryRow> getOrderSummaries() {
        return orderSummaries;
    }

    public void setOrderSummaries(List<OrderSummaryRow> orderSummaries) {
        this.orderSummaries = orderSummaries == null ? new ArrayList<>() : orderSummaries;
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

    public String getLowStockFooterMessage() {
        return lowStockFooterMessage;
    }

    public void setLowStockFooterMessage(String lowStockFooterMessage) {
        this.lowStockFooterMessage = lowStockFooterMessage;
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
}
