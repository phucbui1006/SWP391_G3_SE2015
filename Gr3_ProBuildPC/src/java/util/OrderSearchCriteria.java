package util;

public final class OrderSearchCriteria {

    private final String keyword;
    private final Integer orderId;

    private OrderSearchCriteria(String keyword, Integer orderId) {
        this.keyword = keyword;
        this.orderId = orderId;
    }

    public static OrderSearchCriteria fromKeyword(String value) {
        if (value == null || value.trim().isEmpty()) {
            return new OrderSearchCriteria(null, null);
        }

        String keyword = value.trim();
        return new OrderSearchCriteria(keyword, parseOrderId(keyword));
    }

    public boolean hasKeyword() {
        return keyword != null;
    }

    public String getKeyword() {
        return keyword;
    }

    public Integer getOrderId() {
        return orderId;
    }

    private static Integer parseOrderId(String keyword) {
        return parsePositiveInt(keyword);
    }

    private static Integer parsePositiveInt(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
