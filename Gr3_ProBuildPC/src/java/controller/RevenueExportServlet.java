package controller;

import dal.AdminDashboardDAO;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
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

        LocalDate startDate = parseDate(fromStr, weekStart);
        LocalDate endDate = parseDate(toStr, weekEnd);

        if (startDate.isAfter(endDate)) {
            LocalDate temp = startDate;
            startDate = endDate;
            endDate = temp;
        }

        AdminDashboardDAO dao = new AdminDashboardDAO();
        List<RevenueRow> revenueList = dao.getRevenueStatistics(startDate, endDate, type);

        response.setContentType("text/csv; charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"revenue_report.csv\"");
        response.setCharacterEncoding("UTF-8");

        try (PrintWriter out = response.getWriter()) {
            // Write UTF-8 BOM so Excel opens it with the correct encoding
            out.write('\ufeff');
            
            // Header
            out.println("STT,Thời gian,Số đơn,Doanh thu (VND),Trung bình/Đơn (VND)");
            
            // Data rows
            for (int i = 0; i < revenueList.size(); i++) {
                RevenueRow row = revenueList.get(i);
                out.printf("%d,\"%s\",%d,\"%s\",\"%s\"\n",
                        (i + 1),
                        row.getLabel(),
                        row.getOrderCount(),
                        row.getFormattedRevenue().replace("₫", "").trim(),
                        row.getFormattedAverage().replace("₫", "").trim());
            }
        }
    }

    private LocalDate parseDate(String value, LocalDate defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException e) {
            return defaultValue;
        }
    }
}
