package controller;

import dal.AdminDashboardDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.time.DayOfWeek;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.DashboardSummary;
import model.AccountSummary;
import model.RevenueRow;
import model.User;
import util.DashboardViewHelper;

@WebServlet(name = "RevenueServlet", urlPatterns = {"/RevenueServlet"})
public class RevenueServlet extends HttpServlet {

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
        
        DashboardSummary summary = dao.getSummary(startDate, endDate);
        Map<String, Integer> orderStatusCounts = dao.getOrderStatusCounts(startDate, endDate);
        AccountSummary accountSummary = dao.getAccountSummary();
        
        int successOrders = 0;
        if (orderStatusCounts != null) {
            for (Map.Entry<String, Integer> entry : orderStatusCounts.entrySet()) {
                String status = entry.getKey().toLowerCase();
                if (status.contains("giao") || status.contains("hoàn thành") || status.contains("thành công")) {
                    successOrders += entry.getValue();
                }
            }
        }

        List<RevenueRow> revenueList = dao.getRevenueStatistics(startDate, endDate, type);

        StringBuilder labels = new StringBuilder("[");
        StringBuilder data = new StringBuilder("[");
        for (int i = 0; i < revenueList.size(); i++) {
            RevenueRow row = revenueList.get(i);
            labels.append("'").append(row.getLabel()).append("'");
            data.append(row.getRevenue().toString());
            if (i < revenueList.size() - 1) {
                labels.append(", ");
                data.append(", ");
            }
        }
        labels.append("]");
        data.append("]");

        request.setAttribute("totalRevenue", DashboardViewHelper.formatCurrency(summary.getTotalRevenue()));
        request.setAttribute("totalOrders", summary.getTotalOrders());
        request.setAttribute("successOrders", successOrders);
        request.setAttribute("totalCustomers", accountSummary.getCustomers());
        
        request.setAttribute("revenueList", revenueList);
        request.setAttribute("chartLabels", labels.toString());
        request.setAttribute("chartData", data.toString());
        
        if (fromStr == null) {
            request.setAttribute("fromDate", startDate.toString());
        }
        if (toStr == null) {
            request.setAttribute("toDate", endDate.toString());
        }

        request.getRequestDispatcher("/views/revenue.jsp").forward(request, response);
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
