package controller;

import dal.AdminDashboardDAO;
import java.io.IOException;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.time.DayOfWeek;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.RevenueRow;
import java.io.PrintWriter;
import util.DashboardViewHelper;
@WebServlet(name = "RevenueExportServlet", urlPatterns = {"/RevenueExportServlet"})
public class RevenueExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        LocalDate referenceDate = LocalDate.now();
        LocalDate weekStart = referenceDate.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
        LocalDate weekEnd = weekStart.plusDays(6);

        String fromStr = request.getParameter("fromDate");
        String toStr = request.getParameter("toDate");
        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "day";
        }

        LocalDate startDate = parseDate(fromStr, weekStart, false, type);
        LocalDate endDate = parseDate(toStr, weekEnd, true, type);

        if (startDate.isAfter(endDate)) {
            LocalDate temp = startDate;
            startDate = endDate;
            endDate = temp;
        }

        AdminDashboardDAO dao = new AdminDashboardDAO();
        List<RevenueRow> revenueList = dao.getRevenueStatistics(startDate, endDate, type);

        // Định dạng Tên File
        String currentDateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("ddMMyyyy"));
        String fileName = "ProBuildPC_DoanhThu_" + currentDateStr + ".xls";

        response.setContentType("application/vnd.ms-excel; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (PrintWriter out = response.getWriter()) {
            out.println("<html><head><meta charset=\"UTF-8\"></head><body>");
            out.println("<table border='1'>");
            
            // Header
            out.println("<tr style=\"background-color: #d1d5db;\">");
            out.println("<th>STT</th><th>Thời gian</th><th>Số đơn</th><th>Tổng SP bán ra</th><th>Doanh thu</th><th>Trung bình/Đơn</th>");
            out.println("</tr>");

            long totalOrders = 0;
            BigDecimal totalRevenue = BigDecimal.ZERO;
            long totalProducts = 0;

            // Data Rows
            int rowNum = 1;
            for (RevenueRow r : revenueList) {
                // Bỏ qua những ngày không có đơn hàng / không có doanh thu
                if (r.getOrderCount() == 0 && r.getRevenue().compareTo(BigDecimal.ZERO) <= 0) {
                    continue;
                }
                
                out.println("<tr>");
                out.printf("<td style=\"text-align: center;\">%d</td>", rowNum++);
                out.printf("<td>%s</td>", r.getLabel() != null ? r.getLabel() : "");
                out.printf("<td style=\"text-align: center;\">%d</td>", r.getOrderCount());
                out.printf("<td style=\"text-align: center;\">%d</td>", r.getProductsSold());
                out.printf("<td>%s</td>", r.getFormattedRevenue() != null ? r.getFormattedRevenue() : "0");
                out.printf("<td>%s</td>", r.getFormattedAverage() != null ? r.getFormattedAverage() : "0");
                out.println("</tr>");

                totalOrders += r.getOrderCount();
                totalRevenue = totalRevenue.add(r.getRevenue());
                totalProducts += r.getProductsSold();
            }

            // Total Row
            out.println("<tr>");
            out.println("<td></td>");
            out.println("<td><b>Tổng Cộng</b></td>");
            out.printf("<td style=\"text-align: center;\"><b>%d</b></td>", totalOrders);
            out.printf("<td style=\"text-align: center;\"><b>%d</b></td>", totalProducts);
            out.printf("<td><b>%s</b></td>", DashboardViewHelper.formatCurrency(totalRevenue));
            out.println("<td></td>");
            out.println("</tr>");

            out.println("</table>");
            out.println("</body></html>");
        }
    }

    private LocalDate parseDate(String value, LocalDate defaultValue, boolean isEnd, String type) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            String v = value.trim();
            if ("year".equalsIgnoreCase(type)) {
                int year = Integer.parseInt(v);
                if (isEnd) {
                    return LocalDate.of(year, 12, 31);
                } else {
                    return LocalDate.of(year, 1, 1);
                }
            } else if ("month".equalsIgnoreCase(type)) {
                String[] parts = v.split("-");
                int year = Integer.parseInt(parts[0]);
                int month = Integer.parseInt(parts[1]);
                if (isEnd) {
                    return LocalDate.of(year, month, 1).with(TemporalAdjusters.lastDayOfMonth());
                } else {
                    return LocalDate.of(year, month, 1);
                }
            } else {
                return LocalDate.parse(v);
            }
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
