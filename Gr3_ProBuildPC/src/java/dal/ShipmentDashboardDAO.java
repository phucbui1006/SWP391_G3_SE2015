package dal;

import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import model.ShipmentDashboardView;

public class ShipmentDashboardDAO extends DBContext {

    public ShipmentDashboardView getDashboard(LocalDate startDate, LocalDate endDate) {
        ShipmentDashboardView view = new ShipmentDashboardView();
        view.setStartDate(startDate);
        view.setEndDate(endDate);

        loadOverallSummaryCounts(view);
        loadStatusCounts(view, startDate, endDate);
        return view;
    }

    private void loadOverallSummaryCounts(ShipmentDashboardView view) {
        String sql = """
                     SELECT
                         COUNT(*) AS all_total,
                         SUM(CASE WHEN o.status_id = 2 THEN 1 ELSE 0 END) AS confirmed_total,
                         SUM(CASE WHEN o.status_id = 7 THEN 1 ELSE 0 END) AS failed_total,
                         SUM(CASE WHEN o.status_id = 4 THEN 1 ELSE 0 END) AS shipping_total
                     FROM orders o
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                view.setOverallOrderCount(rs.getInt("all_total"));
                view.setOverallConfirmedOrderCount(rs.getInt("confirmed_total"));
                view.setOverallFailedOrderCount(rs.getInt("failed_total"));
                view.setOverallShippingOrderCount(rs.getInt("shipping_total"));
            }
        } catch (SQLException e) {
        }
    }

    private void loadStatusCounts(ShipmentDashboardView view,
            LocalDate startDate, LocalDate endDate) {
        String sql = """
                     SELECT o.status_id, COUNT(*) AS total
                     FROM orders o
                     WHERE o.order_date >= ?
                       AND o.order_date < ?
                       AND o.status_id IN (4, 5, 7)
                     GROUP BY o.status_id
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, startDate, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int statusId = rs.getInt("status_id");
                    int total = rs.getInt("total");
                    if (statusId == 4) {
                        view.setShippingOrderCount(total);
                    } else if (statusId == 5) {
                        view.setDeliveredOrderCount(total);
                    } else if (statusId == 7) {
                        view.setFailedOrderCount(total);
                    }
                }
            }
        } catch (SQLException e) {
        }

        int totalOrders = view.getShippingOrderCount()
                + view.getDeliveredOrderCount()
                + view.getFailedOrderCount();
        view.setTotalOrderCount(totalOrders);

        List<ShipmentDashboardView.ChartPoint> points = new ArrayList<>();
        points.add(new ShipmentDashboardView.ChartPoint(
                "Đang giao hàng", view.getShippingOrderCount()));
        points.add(new ShipmentDashboardView.ChartPoint(
                "Đã giao hàng", view.getDeliveredOrderCount()));
        points.add(new ShipmentDashboardView.ChartPoint(
                "Giao hàng thất bại", view.getFailedOrderCount()));
        view.setOrderStatusCounts(points);
    }

    private void setDateRange(PreparedStatement ps,
            LocalDate startDate, LocalDate endDate) throws SQLException {
        ps.setDate(1, Date.valueOf(startDate));
        ps.setDate(2, Date.valueOf(endDate.plusDays(1)));
    }

}
