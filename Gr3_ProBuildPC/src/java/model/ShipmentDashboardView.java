package model;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ShipmentDashboardView {
    private List<OrderHistoryItem> orders = new ArrayList<>();
    private List<OrderStatus> statusOptions = new ArrayList<>();
    private Map<Integer, Integer> statusCounts = new LinkedHashMap<>();
    private Integer selectedStatusId;
    private boolean todayOnly;
    private int allActiveCount;
    private int todayCount;
    private int page = 1;
    private int totalPages = 1;
    private int totalOrders;

    public List<OrderHistoryItem> getOrders() {
        return orders;
    }

    public void setOrders(List<OrderHistoryItem> orders) {
        this.orders = orders == null ? new ArrayList<>() : orders;
    }

    public List<OrderStatus> getStatusOptions() {
        return statusOptions;
    }

    public void setStatusOptions(List<OrderStatus> statusOptions) {
        this.statusOptions = statusOptions == null ? new ArrayList<>() : statusOptions;
    }

    public Map<Integer, Integer> getStatusCounts() {
        return statusCounts;
    }

    public void setStatusCounts(Map<Integer, Integer> statusCounts) {
        this.statusCounts = statusCounts == null ? new LinkedHashMap<>() : statusCounts;
    }

    public Integer getSelectedStatusId() {
        return selectedStatusId;
    }

    public void setSelectedStatusId(Integer selectedStatusId) {
        this.selectedStatusId = selectedStatusId;
    }

    public boolean isTodayOnly() {
        return todayOnly;
    }

    public void setTodayOnly(boolean todayOnly) {
        this.todayOnly = todayOnly;
    }

    public int getAllActiveCount() {
        return allActiveCount;
    }

    public void setAllActiveCount(int allActiveCount) {
        this.allActiveCount = allActiveCount;
    }

    public int getTodayCount() {
        return todayCount;
    }

    public void setTodayCount(int todayCount) {
        this.todayCount = todayCount;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }

    public int getTotalOrders() {
        return totalOrders;
    }

    public void setTotalOrders(int totalOrders) {
        this.totalOrders = totalOrders;
    }
}
