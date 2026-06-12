package util;

import java.text.Normalizer;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class OrderSearchCriteria {

    private static final Pattern PB_ORDER_CODE_PATTERN = Pattern.compile("pb\\D*0*(\\d+)");
    private static final Pattern NUMBER_PATTERN = Pattern.compile("0*(\\d+)");

    private final String keyword;
    private final String compactKeyword;
    private final Integer orderId;

    private OrderSearchCriteria(String keyword, String compactKeyword, Integer orderId) {
        this.keyword = keyword;
        this.compactKeyword = compactKeyword;
        this.orderId = orderId;
    }

    public static OrderSearchCriteria fromKeyword(String value) {
        if (value == null || value.trim().isEmpty()) {
            return new OrderSearchCriteria(null, null, null);
        }

        String keyword = value.trim().toLowerCase(Locale.ROOT);
        String compactKeyword = compact(keyword);
        return new OrderSearchCriteria(keyword, compactKeyword, parseOrderId(keyword, compactKeyword));
    }

    public boolean hasKeyword() {
        return keyword != null;
    }

    public String getKeyword() {
        return keyword;
    }

    public String getCompactKeyword() {
        return compactKeyword;
    }

    public Integer getOrderId() {
        return orderId;
    }

    private static String compact(String value) {
        String withoutAccents = Normalizer.normalize(value, Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "");
        return withoutAccents.replaceAll("[^a-z0-9]", "");
    }

    private static Integer parseOrderId(String keyword, String compactKeyword) {
        Integer pbOrderId = parseFirstMatch(compactKeyword, PB_ORDER_CODE_PATTERN);
        if (pbOrderId != null) {
            return pbOrderId;
        }

        if (compactKeyword != null && compactKeyword.matches("\\d+")) {
            return parsePositiveInt(compactKeyword);
        }

        Matcher matcher = NUMBER_PATTERN.matcher(keyword);
        if (matcher.find()) {
            return parsePositiveInt(matcher.group(1));
        }

        return null;
    }

    private static Integer parseFirstMatch(String value, Pattern pattern) {
        if (value == null) {
            return null;
        }

        Matcher matcher = pattern.matcher(value);
        if (!matcher.find()) {
            return null;
        }

        return parsePositiveInt(matcher.group(1));
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
