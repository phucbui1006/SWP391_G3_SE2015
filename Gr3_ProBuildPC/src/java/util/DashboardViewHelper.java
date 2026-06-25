package util;

import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.DecimalFormat;

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

    public static String productStatusClass(String status) {
        return status != null && "ACTIVE".equalsIgnoreCase(status.trim()) ? "active" : "inactive";
    }

    public static String formatCurrency(BigDecimal value) {
        DecimalFormat formatter = new DecimalFormat("#,###");
        BigDecimal safeValue = value == null ? BigDecimal.ZERO : value;
        return formatter.format(safeValue) + "đ";
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
