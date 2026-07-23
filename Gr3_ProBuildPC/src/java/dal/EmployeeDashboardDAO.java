package dal;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.EmployeeDashboardView;

public class EmployeeDashboardDAO extends DBContext {
    
    public EmployeeDashboardView getDashboard(LocalDate startDate, LocalDate endDate) {
        EmployeeDashboardView view = new EmployeeDashboardView();
        view.setStartDate(startDate);
        view.setEndDate(endDate);
        loadOverallSummaryCounts(view);
        loadOrderChartData(view, startDate, endDate);
        loadWarrantyChartData(view, startDate, endDate);
        
        return view;
    }

    private void loadOverallSummaryCounts(EmployeeDashboardView view) {
        String orderSql = """
                          SELECT
                              SUM(CASE WHEN o.status_id = 1 THEN 1 ELSE 0 END) AS pending_total,
                              SUM(CASE WHEN o.status_id = 7 THEN 1 ELSE 0 END) AS failed_total
                          FROM orders o
                          """;

        try (PreparedStatement ps = connection.prepareStatement(orderSql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                view.setOverallPendingOrderCount(rs.getInt("pending_total"));
                view.setOverallFailedOrderCount(rs.getInt("failed_total"));
            }
        } catch (SQLException e) {
        }

        String warrantySql = """
                             SELECT COUNT(*) AS waiting_total
                             FROM warranties w
                             WHERE w.status_id = 1
                             """;

        try (PreparedStatement ps = connection.prepareStatement(warrantySql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                view.setOverallWaitingWarrantyCount(rs.getInt("waiting_total"));
            }
        } catch (SQLException e) {
        }
    }
    
    private void loadOrderChartData(EmployeeDashboardView view, LocalDate startDate, LocalDate endDate) {
        String sql = """
                     SELECT o.status_id, COUNT(*) AS total
                     FROM orders o
                     WHERE o.order_date >= ?
                       AND o.order_date < ?
                       AND o.status_id IN (1, 2, 6, 7)
                     GROUP BY o.status_id
                     """;

        int pending = 0;
        int confirmed = 0;
        int cancelled = 0;
        int failed = 0;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, 1, startDate, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int statusId = rs.getInt("status_id");
                    int total = rs.getInt("total");
                    if (statusId == 1) {
                        pending = total;
                    } else if (statusId == 2) {
                        confirmed = total;
                    } else if (statusId == 6) {
                        cancelled = total;
                    } else if (statusId == 7) {
                        failed = total;
                    }
                }
            }
        } catch (SQLException e) {
        }

        List<EmployeeDashboardView.ChartPoint> points = new ArrayList<>();
        points.add(new EmployeeDashboardView.ChartPoint("Chờ xác nhận", pending));
        points.add(new EmployeeDashboardView.ChartPoint("Đã xác nhận", confirmed));
        points.add(new EmployeeDashboardView.ChartPoint("Đã hủy", cancelled));
        points.add(new EmployeeDashboardView.ChartPoint("Giao hàng thất bại", failed));
        view.setOrderStatusCounts(points);
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
        int accepted = 0;
        
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
                        accepted = total;
                    }
                }
            }
        } catch (SQLException e) {
        }
        
        List<EmployeeDashboardView.ChartPoint> points = new ArrayList<>();
        points.add(new EmployeeDashboardView.ChartPoint("Chờ xác nhận", pending));
        points.add(new EmployeeDashboardView.ChartPoint("Đã tiếp nhận", accepted));
        points.add(new EmployeeDashboardView.ChartPoint("Đã từ chối", rejected));
        view.setWarrantyStatusCounts(points);
    }
    
    private void setDateRange(PreparedStatement ps, int startIndex,
            LocalDate startDate, LocalDate endDate) throws SQLException {
        ps.setDate(startIndex, Date.valueOf(startDate));
        ps.setDate(startIndex + 1, Date.valueOf(endDate.plusDays(1)));
    }
    
}
