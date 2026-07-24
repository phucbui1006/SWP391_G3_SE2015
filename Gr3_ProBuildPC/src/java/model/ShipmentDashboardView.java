package model;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ShipmentDashboardView {

    private String formAction;
    private LocalDate startDate;
    private LocalDate endDate;
    private int totalOrderCount;
    private int shippingOrderCount;
    private int deliveredOrderCount;
    private int failedOrderCount;
    private int overallOrderCount;
    private int overallConfirmedOrderCount;
    private int overallFailedOrderCount;
    private int overallShippingOrderCount;
    private List<ChartPoint> orderStatusCounts = new ArrayList<>();
    private List<SummaryCard> summaryCards = new ArrayList<>();

    public String getFormAction() {
        return formAction;
    }

    public void setFormAction(String formAction) {
        this.formAction = formAction;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public int getTotalOrderCount() {
        return totalOrderCount;
    }

    public void setTotalOrderCount(int totalOrderCount) {
        this.totalOrderCount = totalOrderCount;
    }

    public int getShippingOrderCount() {
        return shippingOrderCount;
    }

    public void setShippingOrderCount(int shippingOrderCount) {
        this.shippingOrderCount = shippingOrderCount;
    }

    public int getDeliveredOrderCount() {
        return deliveredOrderCount;
    }

    public void setDeliveredOrderCount(int deliveredOrderCount) {
        this.deliveredOrderCount = deliveredOrderCount;
    }

    public int getFailedOrderCount() {
        return failedOrderCount;
    }

    public void setFailedOrderCount(int failedOrderCount) {
        this.failedOrderCount = failedOrderCount;
    }

    public int getOverallOrderCount() {
        return overallOrderCount;
    }

    public void setOverallOrderCount(int overallOrderCount) {
        this.overallOrderCount = overallOrderCount;
    }

    public int getOverallConfirmedOrderCount() {
        return overallConfirmedOrderCount;
    }

    public void setOverallConfirmedOrderCount(int overallConfirmedOrderCount) {
        this.overallConfirmedOrderCount = overallConfirmedOrderCount;
    }

    public int getOverallFailedOrderCount() {
        return overallFailedOrderCount;
    }

    public void setOverallFailedOrderCount(int overallFailedOrderCount) {
        this.overallFailedOrderCount = overallFailedOrderCount;
    }

    public int getOverallShippingOrderCount() {
        return overallShippingOrderCount;
    }

    public void setOverallShippingOrderCount(int overallShippingOrderCount) {
        this.overallShippingOrderCount = overallShippingOrderCount;
    }

    public List<ChartPoint> getOrderStatusCounts() {
        return orderStatusCounts;
    }

    public void setOrderStatusCounts(List<ChartPoint> orderStatusCounts) {
        this.orderStatusCounts = orderStatusCounts == null ? new ArrayList<>() : orderStatusCounts;
    }

    public List<SummaryCard> getSummaryCards() {
        return summaryCards;
    }

    public void setSummaryCards(List<SummaryCard> summaryCards) {
        this.summaryCards = summaryCards == null ? new ArrayList<>() : summaryCards;
    }

    //Biểu đồ
    public static class ChartPoint {

        private final String label;
        private final int value;

        public ChartPoint(String label, int value) {
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

    //Ô thống kê
    public static class SummaryCard {

        private final String iconClass;
        private final String icon;
        private final String label;
        private final int value;

        public SummaryCard(String iconClass, String icon, String label, int value) {
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

        public int getValue() {
            return value;
        }
    }

    public static class FilterTab {
        private final String label;
        private final String url;
        private final boolean active;

        public FilterTab(String label, String url, boolean active) {
            this.label = label;
            this.url = url;
            this.active = active;
        }

        public String getLabel() {
            return label;
        }

        public String getUrl() {
            return url;
        }

        public boolean isActive() {
            return active;
        }
    }

    public static class OrderRow {
        private final String orderCode;
        private final String customerName;
        private final String shippingAddress;
        private final String status;
        private final String statusClass;

        public OrderRow(String orderCode, String customerName, String shippingAddress,
                String status, String statusClass) {
            this.orderCode = orderCode;
            this.customerName = customerName;
            this.shippingAddress = shippingAddress;
            this.status = status;
            this.statusClass = statusClass;
        }

        public String getOrderCode() {
            return orderCode;
        }

        public String getCustomerName() {
            return customerName;
        }

        public String getShippingAddress() {
            return shippingAddress;
        }

        public String getStatus() {
            return status;
        }

        public String getStatusClass() {
            return statusClass;
        }
    }

    public static class PageLink {
        private final String label;
        private final String url;
        private final boolean active;
        private final boolean clickable;

        public PageLink(String label, String url, boolean active, boolean clickable) {
            this.label = label;
            this.url = url;
            this.active = active;
            this.clickable = clickable;
        }

        public String getLabel() {
            return label;
        }

        public String getUrl() {
            return url;
        }

        public boolean isActive() {
            return active;
        }

        public boolean isClickable() {
            return clickable;
        }
    }
}
