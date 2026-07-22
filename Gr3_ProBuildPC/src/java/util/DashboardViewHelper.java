package util;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;
import java.util.List;
import model.AdminDashboardView;

public final class DashboardViewHelper {

    private DashboardViewHelper() {
    }

    public static String h(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }

    public static String defaultText(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    public static String statusClass(String status) {
        String value = status == null ? "" : status.toLowerCase();
        if (value.contains("hủy") || value.contains("huy")) {
            return "cancelled";
        }
        if (value.contains("đã giao") || value.contains("da giao")) {
            return "delivered";
        }
        if (value.contains("đang giao") || value.contains("dang giao")) {
            return "shipping";
        }
        if (value.contains("chuẩn bị") || value.contains("chuan bi")) {
            return "preparing";
        }
        if (value.contains("xác nhận") || value.contains("xac nhan")) {
            return value.contains("chờ") || value.contains("cho ") ? "pending" : "confirmed";
        }
        return "all";
    }

    public static String statusIcon(String status) {
        String cssClass = statusClass(status);
        if ("pending".equals(cssClass)) {
            return "fa-solid fa-hourglass-half";
        }
        if ("confirmed".equals(cssClass) || "delivered".equals(cssClass)) {
            return "fa-solid fa-check";
        }
        if ("preparing".equals(cssClass)) {
            return "fa-solid fa-box-open";
        }
        if ("shipping".equals(cssClass)) {
            return "fa-solid fa-truck-fast";
        }
        if ("cancelled".equals(cssClass)) {
            return "fa-solid fa-xmark";
        }
        return "fa-solid fa-box";
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

    public static String productNamesToJson(List<AdminDashboardView.ProductRow> products) {
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

    public static String productSoldQuantitiesToJson(List<AdminDashboardView.ProductRow> products) {
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

    public static String buildShipmentLink(String ctx, Integer statusId, boolean todayOnly, int page) {
        StringBuilder query = new StringBuilder();
        if (statusId != null) {
            appendParam(query, "statusId", String.valueOf(statusId));
        }
        if (todayOnly) {
            appendParam(query, "today", "1");
        }
        if (page > 1) {
            appendParam(query, "page", String.valueOf(page));
        }
        return ctx + "/Dashboard" + (query.length() == 0 ? "" : "?" + query);
    }

    private static void appendParam(StringBuilder query, String name, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        if (query.length() > 0) {
            query.append("&");
        }

        query.append(name)
                .append("=")
                .append(URLEncoder.encode(value.trim(), StandardCharsets.UTF_8));
    }
}
