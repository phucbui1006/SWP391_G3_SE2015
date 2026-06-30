package model;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class EmployeeDashboardView {
    private String formAction;
    private LocalDate startDate;
    private LocalDate endDate;
    private List<WarrantyRequest> warranties = new ArrayList<>();
    private List<OrderHistoryItem> orders = new ArrayList<>();
    private int waitingWarrantyCount;
    private int receivedWarrantyCount;
    private int failedOrderCount;
    private int cancelledOrderCount;
    private List<SummaryCard> summaryCards = new ArrayList<>();
    private List<WarrantyRow> warrantyRows = new ArrayList<>();
    private List<OrderRow> orderRows = new ArrayList<>();

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

    public List<WarrantyRequest> getWarranties() {
        return warranties;
    }

    public void setWarranties(List<WarrantyRequest> warranties) {
        this.warranties = warranties == null ? new ArrayList<>() : warranties;
    }

    public List<OrderHistoryItem> getOrders() {
        return orders;
    }

    public void setOrders(List<OrderHistoryItem> orders) {
        this.orders = orders == null ? new ArrayList<>() : orders;
    }

    public int getWarrantyTotal() {
        return warranties.size();
    }

    public int getOrderTotal() {
        return orders.size();
    }

    public int getTotalWorkCount() {
        return getWarrantyTotal() + getOrderTotal();
    }

    public int getWaitingWarrantyCount() {
        return waitingWarrantyCount;
    }

    public void setWaitingWarrantyCount(int waitingWarrantyCount) {
        this.waitingWarrantyCount = waitingWarrantyCount;
    }

    public int getReceivedWarrantyCount() {
        return receivedWarrantyCount;
    }

    public void setReceivedWarrantyCount(int receivedWarrantyCount) {
        this.receivedWarrantyCount = receivedWarrantyCount;
    }

    public int getFailedOrderCount() {
        return failedOrderCount;
    }

    public void setFailedOrderCount(int failedOrderCount) {
        this.failedOrderCount = failedOrderCount;
    }

    public int getCancelledOrderCount() {
        return cancelledOrderCount;
    }

    public void setCancelledOrderCount(int cancelledOrderCount) {
        this.cancelledOrderCount = cancelledOrderCount;
    }

    public List<SummaryCard> getSummaryCards() {
        return summaryCards;
    }

    public void setSummaryCards(List<SummaryCard> summaryCards) {
        this.summaryCards = summaryCards == null ? new ArrayList<>() : summaryCards;
    }

    public List<WarrantyRow> getWarrantyRows() {
        return warrantyRows;
    }

    public void setWarrantyRows(List<WarrantyRow> warrantyRows) {
        this.warrantyRows = warrantyRows == null ? new ArrayList<>() : warrantyRows;
    }

    public List<OrderRow> getOrderRows() {
        return orderRows;
    }

    public void setOrderRows(List<OrderRow> orderRows) {
        this.orderRows = orderRows == null ? new ArrayList<>() : orderRows;
    }

    public static class SummaryCard {
        private final String iconClass;
        private final String icon;
        private final String label;
        private final int value;
        private final String unit;

        public SummaryCard(String iconClass, String icon, String label, int value, String unit) {
            this.iconClass = iconClass;
            this.icon = icon;
            this.label = label;
            this.value = value;
            this.unit = unit;
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

        public String getUnit() {
            return unit;
        }
    }

    public static class WarrantyRow {
        private final int warrantyId;
        private final String customerName;
        private final String productName;
        private final String requestDate;
        private final String status;
        private final String statusClass;
        private final String detailUrl;

        public WarrantyRow(int warrantyId, String customerName, String productName,
                String requestDate, String status, String statusClass, String detailUrl) {
            this.warrantyId = warrantyId;
            this.customerName = customerName;
            this.productName = productName;
            this.requestDate = requestDate;
            this.status = status;
            this.statusClass = statusClass;
            this.detailUrl = detailUrl;
        }

        public int getWarrantyId() {
            return warrantyId;
        }

        public String getCustomerName() {
            return customerName;
        }

        public String getProductName() {
            return productName;
        }

        public String getRequestDate() {
            return requestDate;
        }

        public String getStatus() {
            return status;
        }

        public String getStatusClass() {
            return statusClass;
        }

        public String getDetailUrl() {
            return detailUrl;
        }
    }

    public static class OrderRow {
        private final int orderId;
        private final String customerName;
        private final String orderDate;
        private final String totalAmount;
        private final String status;
        private final String statusClass;
        private final String detailUrl;

        public OrderRow(int orderId, String customerName, String orderDate,
                String totalAmount, String status, String statusClass, String detailUrl) {
            this.orderId = orderId;
            this.customerName = customerName;
            this.orderDate = orderDate;
            this.totalAmount = totalAmount;
            this.status = status;
            this.statusClass = statusClass;
            this.detailUrl = detailUrl;
        }

        public int getOrderId() {
            return orderId;
        }

        public String getCustomerName() {
            return customerName;
        }

        public String getOrderDate() {
            return orderDate;
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

        public String getDetailUrl() {
            return detailUrl;
        }
    }
}
