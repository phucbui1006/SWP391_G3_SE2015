package model;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class EmployeeDashboardView {
    private String formAction;
    private LocalDate startDate;
    private LocalDate endDate;
    private int waitingWarrantyCount;
    private int rejectedWarrantyCount;
    private int acceptedWarrantyCount;
    private int failedOrderCount;
    private int cancelledOrderCount;
    private int deliveredOrderCount;
    private List<ChartPoint> warrantyStatusCounts = new ArrayList<>();
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



    public int getWaitingWarrantyCount() {
        return waitingWarrantyCount;
    }

    public void setWaitingWarrantyCount(int waitingWarrantyCount) {
        this.waitingWarrantyCount = waitingWarrantyCount;
    }

    public int getRejectedWarrantyCount() {
        return rejectedWarrantyCount;
    }

    public void setRejectedWarrantyCount(int rejectedWarrantyCount) {
        this.rejectedWarrantyCount = rejectedWarrantyCount;
    }

    public int getAcceptedWarrantyCount() {
        return acceptedWarrantyCount;
    }

    public void setAcceptedWarrantyCount(int acceptedWarrantyCount) {
        this.acceptedWarrantyCount = acceptedWarrantyCount;
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



    public int getDeliveredOrderCount() {
        return deliveredOrderCount;
    }

    public void setDeliveredOrderCount(int deliveredOrderCount) {
        this.deliveredOrderCount = deliveredOrderCount;
    }


    public List<ChartPoint> getWarrantyStatusCounts() {
        return warrantyStatusCounts;
    }

    public void setWarrantyStatusCounts(List<ChartPoint> warrantyStatusCounts) {
        this.warrantyStatusCounts = warrantyStatusCounts == null ? new ArrayList<>() : warrantyStatusCounts;
    }

    public List<ChartPoint> getOrderStatusCounts() {
        return orderStatusCounts;
    }

    public void setOrderStatusCounts(List<ChartPoint> orderStatusCounts) {
        this.orderStatusCounts = orderStatusCounts == null ? new ArrayList<>() : orderStatusCounts;
    }

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


}
