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
import jakarta.servlet.http.HttpSession;
import model.RevenueRow;
import model.User;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import util.DashboardViewHelper;

@WebServlet(name = "RevenueExportServlet", urlPatterns = {"/RevenueExportServlet"})
public class RevenueExportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User user = (User) session.getAttribute("account");
        if (user.getRoleName() == null || !user.getRoleName().trim().toUpperCase().equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

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
        String suffix = "TheoNgay";
        if ("month".equalsIgnoreCase(type)) {
            suffix = "TheoThang";
        } else if ("year".equalsIgnoreCase(type)) {
            suffix = "TheoNam";
        }
        String currentDateStr = LocalDate.now().format(DateTimeFormatter.ofPattern("ddMMyyyy"));
        String fileName = "DoanhThu" + suffix + "_" + currentDateStr + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (Workbook workbook = new XSSFWorkbook(); OutputStream out = response.getOutputStream()) {
            Sheet sheet = workbook.createSheet("Thống kê doanh thu");

            // Header Font & Style
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.BLACK.getIndex());

            CellStyle headerCellStyle = workbook.createCellStyle();
            headerCellStyle.setFont(headerFont);
            headerCellStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            headerCellStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerCellStyle.setBorderBottom(BorderStyle.THIN);
            headerCellStyle.setBorderTop(BorderStyle.THIN);
            headerCellStyle.setBorderLeft(BorderStyle.THIN);
            headerCellStyle.setBorderRight(BorderStyle.THIN);

            // Data Style
            CellStyle dataStyle = workbook.createCellStyle();
            dataStyle.setBorderBottom(BorderStyle.THIN);
            dataStyle.setBorderTop(BorderStyle.THIN);
            dataStyle.setBorderLeft(BorderStyle.THIN);
            dataStyle.setBorderRight(BorderStyle.THIN);
            
            // Currency Data Style
            CellStyle currencyStyle = workbook.createCellStyle();
            currencyStyle.cloneStyleFrom(dataStyle);
            // Optionally could use a data format, but we'll use string format to match dashboard view

            // Create Header Row
            Row headerRow = sheet.createRow(0);
            String[] columns = {"STT", "Thời gian", "Số đơn", "Doanh thu", "Trung bình/Đơn"};
            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerCellStyle);
            }

            long totalOrders = 0;
            BigDecimal totalRevenue = BigDecimal.ZERO;

            // Create Data Rows
            int rowNum = 1;
            for (RevenueRow r : revenueList) {
                Row row = sheet.createRow(rowNum++);
                
                Cell cell0 = row.createCell(0);
                cell0.setCellValue(rowNum - 1);
                cell0.setCellStyle(dataStyle);

                Cell cell1 = row.createCell(1);
                cell1.setCellValue(r.getLabel());
                cell1.setCellStyle(dataStyle);

                Cell cell2 = row.createCell(2);
                cell2.setCellValue(r.getOrderCount());
                cell2.setCellStyle(dataStyle);

                Cell cell3 = row.createCell(3);
                cell3.setCellValue(r.getFormattedRevenue());
                cell3.setCellStyle(currencyStyle);
                
                Cell cell4 = row.createCell(4);
                cell4.setCellValue(r.getFormattedAverage());
                cell4.setCellStyle(currencyStyle);

                totalOrders += r.getOrderCount();
                totalRevenue = totalRevenue.add(r.getRevenue());
            }

            // Create Total Row
            Row totalRow = sheet.createRow(rowNum);
            
            Cell totalCell0 = totalRow.createCell(0);
            totalCell0.setCellStyle(headerCellStyle);
            
            Cell totalCell1 = totalRow.createCell(1);
            totalCell1.setCellValue("Tổng Cộng");
            totalCell1.setCellStyle(headerCellStyle);
            
            Cell totalCell2 = totalRow.createCell(2);
            totalCell2.setCellValue(totalOrders);
            totalCell2.setCellStyle(headerCellStyle);
            
            Cell totalCell3 = totalRow.createCell(3);
            totalCell3.setCellValue(DashboardViewHelper.formatCurrency(totalRevenue));
            totalCell3.setCellStyle(headerCellStyle);
            
            Cell totalCell4 = totalRow.createCell(4);
            totalCell4.setCellStyle(headerCellStyle); // Trống hoặc ghi chú thêm

            // Tự động giãn cột (Auto-size)
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            workbook.write(out);
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
