package util;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.util.List;
import model.AdminDashboardView;
import model.DashboardProduct;

public final class DashboardViewHelper {

    private DashboardViewHelper() {
    }

    public static String defaultText(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    public static String formatCurrency(BigDecimal value) {
        DecimalFormat formatter = new DecimalFormat("#,###");
        BigDecimal safeValue = value == null ? BigDecimal.ZERO : value;
        return formatter.format(safeValue) + "đ";
    }

    public static String toJsonString(String value) {
        String safeValue = value == null ? "" : value;
        StringBuilder result = new StringBuilder("\"");
        for (int i = 0; i < safeValue.length(); i++) {
            char character = safeValue.charAt(i);
            switch (character) {
                case '\\' -> result.append("\\\\");
                case '"' -> result.append("\\\"");
                case '\n' -> result.append("\\n");
                case '\r' -> result.append("\\r");
                case '\t' -> result.append("\\t");
                case '<' -> result.append("\\u003c");
                case '>' -> result.append("\\u003e");
                case '&' -> result.append("\\u0026");
                case '\u2028' -> result.append("\\u2028");
                case '\u2029' -> result.append("\\u2029");
                default -> result.append(character);
            }
        }
        return result.append('"').toString();
    }

    public static String chartPointLabelsToJson(List<AdminDashboardView.ChartPoint> points) {
        StringBuilder result = new StringBuilder("[");
        if (points != null) {
            for (int i = 0; i < points.size(); i++) {
                if (i > 0) {
                    result.append(",");
                }
                result.append(toJsonString(points.get(i).getLabel()));
            }
        }
        return result.append("]").toString();
    }

    public static String chartPointValuesToJson(List<AdminDashboardView.ChartPoint> points) {
        StringBuilder result = new StringBuilder("[");
        if (points != null) {
            for (int i = 0; i < points.size(); i++) {
                if (i > 0) {
                    result.append(",");
                }
                result.append(points.get(i).getValue().toPlainString());
            }
        }
        return result.append("]").toString();
    }

    public static String productNamesToJson(List<DashboardProduct> products) {
        StringBuilder result = new StringBuilder("[");
        if (products != null) {
            for (int i = 0; i < products.size(); i++) {
                if (i > 0) {
                    result.append(",");
                }
                result.append(toJsonString(products.get(i).getProductName()));
            }
        }
        return result.append("]").toString();
    }

    public static String productSoldQuantitiesToJson(List<DashboardProduct> products) {
        StringBuilder result = new StringBuilder("[");
        if (products != null) {
            for (int i = 0; i < products.size(); i++) {
                if (i > 0) {
                    result.append(",");
                }
                result.append(products.get(i).getSoldQuantity());
            }
        }
        return result.append("]").toString();
    }

}
