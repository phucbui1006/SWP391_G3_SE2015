package dal;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.EmployeeDashboardView;
import model.OrderHistoryItem;

public class EmployeeDashboardDAO extends DBContext {

  
    public EmployeeDashboardView getDashboard(LocalDate startDate, LocalDate endDate) {
        EmployeeDashboardView view = new EmployeeDashboardView();
        view.setStartDate(startDate);
        view.setEndDate(endDate);
        loadWarrantyCounts(view, startDate, endDate);
        loadOrderCounts(view, startDate, endDate);

        List<EmployeeDashboardView.ChartPoint> orderPoints = new ArrayList<>();
        orderPoints.add(new EmployeeDashboardView.ChartPoint("Đã giao hàng", view.getDeliveredOrderCount()));
        orderPoints.add(new EmployeeDashboardView.ChartPoint("Đã hủy", view.getCancelledOrderCount()));
        orderPoints.add(new EmployeeDashboardView.ChartPoint("Giao hàng thất bại", view.getFailedOrderCount()));
        view.setOrderStatusCounts(orderPoints);

        loadWarrantyChartData(view, startDate, endDate);

        return view;
    }



    private void loadWarrantyCounts(EmployeeDashboardView view, LocalDate startDate, LocalDate endDate) {
        String sql = """
                     SELECT w.status_id, COUNT(*) AS total
                     FROM warranties w
                     WHERE w.status_id IN (1, 2, 3)
                       AND w.request_date >= ?
                       AND w.request_date < ?
                     GROUP BY w.status_id
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, 1, startDate, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int statusId = rs.getInt("status_id");
                    int total = rs.getInt("total");
                    if (statusId == 1) {
                        view.setWaitingWarrantyCount(total);
                    } else if (statusId == 2) {
                        view.setRejectedWarrantyCount(total);
                    } else if (statusId == 3) {
                        view.setAcceptedWarrantyCount(total);
                    }
                }
            }
        } catch (SQLException e) {
        }
    }



    private void loadOrderCounts(EmployeeDashboardView view, LocalDate startDate, LocalDate endDate) {
        String sql = """
                     SELECT o.status_id, COUNT(*) AS total
                     FROM orders o
                     WHERE o.order_date >= ?
                       AND o.order_date < ?
                       AND o.status_id IN (5, 6, 7)
                     GROUP BY o.status_id
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, 1, startDate, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int statusId = rs.getInt("status_id");
                    int total = rs.getInt("total");
                    if (statusId == 5) {
                        view.setDeliveredOrderCount(total);
                    } else if (statusId == 6) {
                        view.setCancelledOrderCount(total);
                    } else if (statusId == 7) {
                        view.setFailedOrderCount(total);
                    }
                }
            }
        } catch (SQLException e) {
        }
    }

    private void loadWarrantyChartData(EmployeeDashboardView view, LocalDate startDate, LocalDate endDate) {
        String sql = """
                     SELECT w.status_id, COUNT(*) AS total
                     FROM warranties w
                     WHERE w.request_date >= ?
                       AND w.request_date < ?
                       AND w.status_id IN (1, 2, 3)
                     GROUP BY w.status_id
                     """;

        int pending = 0;
        int rejected = 0;
        int completed = 0;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, 1, startDate, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int statusId = rs.getInt("status_id");
                    int total = rs.getInt("total");
                    if (statusId == 1) {
                        pending = total;
                    } else if (statusId == 2) {
                        rejected = total;
                    } else if (statusId == 3) {
                        completed = total;
                    }
                }
            }
        } catch (SQLException e) {
        }

        List<EmployeeDashboardView.ChartPoint> points = new ArrayList<>();
        points.add(new EmployeeDashboardView.ChartPoint("Chờ tiếp nhận", pending));
        points.add(new EmployeeDashboardView.ChartPoint("Hoàn thành", completed));
        points.add(new EmployeeDashboardView.ChartPoint("Từ chối", rejected));
        view.setWarrantyStatusCounts(points);
    }


    private void setDateRange(PreparedStatement ps, int startIndex,
            LocalDate startDate, LocalDate endDate) throws SQLException {
        ps.setDate(startIndex, Date.valueOf(startDate));
        ps.setDate(startIndex + 1, Date.valueOf(endDate.plusDays(1)));
    }

  
}
