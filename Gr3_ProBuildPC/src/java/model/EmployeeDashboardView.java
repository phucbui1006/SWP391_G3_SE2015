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
}
