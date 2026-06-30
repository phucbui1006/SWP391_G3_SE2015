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
    private List<SummaryCard> summaryCards = new ArrayList<>();
    private List<FilterTab> filterTabs = new ArrayList<>();
    private List<OrderRow> orderRows = new ArrayList<>();
    private List<PageLink> pageLinks = new ArrayList<>();
    private String previousPageUrl;
    private String nextPageUrl;

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

    public List<SummaryCard> getSummaryCards() {
        return summaryCards;
    }

    public void setSummaryCards(List<SummaryCard> summaryCards) {
        this.summaryCards = summaryCards == null ? new ArrayList<>() : summaryCards;
    }

    public List<FilterTab> getFilterTabs() {
        return filterTabs;
    }

    public void setFilterTabs(List<FilterTab> filterTabs) {
        this.filterTabs = filterTabs == null ? new ArrayList<>() : filterTabs;
    }

    public List<OrderRow> getOrderRows() {
        return orderRows;
    }

    public void setOrderRows(List<OrderRow> orderRows) {
        this.orderRows = orderRows == null ? new ArrayList<>() : orderRows;
    }

    public List<PageLink> getPageLinks() {
        return pageLinks;
    }

    public void setPageLinks(List<PageLink> pageLinks) {
        this.pageLinks = pageLinks == null ? new ArrayList<>() : pageLinks;
    }

    public String getPreviousPageUrl() {
        return previousPageUrl;
    }

    public void setPreviousPageUrl(String previousPageUrl) {
        this.previousPageUrl = previousPageUrl;
    }

    public String getNextPageUrl() {
        return nextPageUrl;
    }

    public void setNextPageUrl(String nextPageUrl) {
        this.nextPageUrl = nextPageUrl;
    }

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
        private final int pageNumber;
        private final String url;
        private final boolean active;

        public PageLink(int pageNumber, String url, boolean active) {
            this.pageNumber = pageNumber;
            this.url = url;
            this.active = active;
        }

        public int getPageNumber() {
            return pageNumber;
        }

        public String getUrl() {
            return url;
        }

        public boolean isActive() {
            return active;
        }
    }
}
