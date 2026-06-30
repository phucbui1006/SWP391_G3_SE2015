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
import model.WarrantyRequest;

public class EmployeeDashboardDAO extends DBContext {

    private static final int WAITING_WARRANTY_STATUS_ID = 1;
    private static final int RECEIVED_WARRANTY_STATUS_ID = 2;

    public EmployeeDashboardView getDashboard(LocalDate startDate, LocalDate endDate) {
        EmployeeDashboardView view = new EmployeeDashboardView();
        view.setStartDate(startDate);
        view.setEndDate(endDate);
        view.setWarranties(getPendingWarranties(startDate, endDate));
        view.setOrders(getFailedOrders(startDate, endDate));
        loadWarrantyCounts(view, startDate, endDate);
        loadOrderCounts(view, startDate, endDate);
        return view;
    }

    private List<WarrantyRequest> getPendingWarranties(LocalDate startDate, LocalDate endDate) {
        List<WarrantyRequest> warranties = new ArrayList<>();
        String sql = """
                     SELECT w.warranty_id,
                            w.customer_id,
                            w.product_id,
                            w.status_id,
                            w.request_date,
                            p.product_name,
                            ws.status_name,
                            u.full_name AS customer_name
                     FROM warranties w
                     INNER JOIN products p ON p.product_id = w.product_id
                     INNER JOIN customers c ON c.customer_id = w.customer_id
                     INNER JOIN users u ON u.user_id = c.user_id
                     LEFT JOIN warranty_status ws ON ws.status_id = w.status_id
                     WHERE w.status_id = ?
                       AND w.request_date >= ?
                       AND w.request_date < ?
                     ORDER BY w.request_date DESC, w.warranty_id DESC
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, WAITING_WARRANTY_STATUS_ID);
            setDateRange(ps, 2, startDate, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    warranties.add(mapWarranty(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return warranties;
    }

    private void loadWarrantyCounts(EmployeeDashboardView view, LocalDate startDate, LocalDate endDate) {
        String sql = """
                     SELECT w.status_id, COUNT(*) AS total
                     FROM warranties w
                     WHERE w.status_id IN (?, ?)
                       AND w.request_date >= ?
                       AND w.request_date < ?
                     GROUP BY w.status_id
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, WAITING_WARRANTY_STATUS_ID);
            ps.setInt(2, RECEIVED_WARRANTY_STATUS_ID);
            setDateRange(ps, 3, startDate, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int statusId = rs.getInt("status_id");
                    if (statusId == WAITING_WARRANTY_STATUS_ID) {
                        view.setWaitingWarrantyCount(rs.getInt("total"));
                    } else if (statusId == RECEIVED_WARRANTY_STATUS_ID) {
                        view.setReceivedWarrantyCount(rs.getInt("total"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private List<OrderHistoryItem> getFailedOrders(LocalDate startDate, LocalDate endDate) {
        List<OrderHistoryItem> orders = new ArrayList<>();
        String sql = """
                     SELECT o.order_id,
                            o.customer_id,
                            o.status_id,
                            o.order_date,
                            o.total_amount,
                            os.status_name,
                            u.full_name AS customer_name
                     FROM orders o
                     INNER JOIN customers c ON c.customer_id = o.customer_id
                     INNER JOIN users u ON u.user_id = c.user_id
                     INNER JOIN orders_status os ON os.status_id = o.status_id
                     WHERE LOWER(os.status_name) IN (LOWER(?), LOWER(?))
                       AND o.order_date >= ?
                       AND o.order_date < ?
                     ORDER BY o.order_date DESC, o.order_id DESC
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, "Giao hàng thất bại");
            ps.setString(2, "Giao hang that bai");
            setDateRange(ps, 3, startDate, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    orders.add(mapOrder(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return orders;
    }

    private void loadOrderCounts(EmployeeDashboardView view, LocalDate startDate, LocalDate endDate) {
        String sql = """
                     SELECT os.status_name, COUNT(*) AS total
                     FROM orders o
                     INNER JOIN orders_status os ON os.status_id = o.status_id
                     WHERE o.order_date >= ?
                       AND o.order_date < ?
                       AND (
                           LOWER(os.status_name) IN (LOWER(?), LOWER(?))
                           OR LOWER(os.status_name) IN (LOWER(?), LOWER(?))
                       )
                     GROUP BY os.status_id, os.status_name
                     """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setDateRange(ps, 1, startDate, endDate);
            ps.setString(3, "Giao hàng thất bại");
            ps.setString(4, "Giao hang that bai");
            ps.setString(5, "Đã hủy");
            ps.setString(6, "Da huy");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String statusName = rs.getString("status_name");
                    if (isCancelledStatus(statusName)) {
                        view.setCancelledOrderCount(rs.getInt("total"));
                    } else {
                        view.setFailedOrderCount(rs.getInt("total"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private WarrantyRequest mapWarranty(ResultSet rs) throws SQLException {
        WarrantyRequest warranty = new WarrantyRequest();
        warranty.setWarrantyId(rs.getInt("warranty_id"));
        warranty.setCustomerId(rs.getInt("customer_id"));
        warranty.setProductId(rs.getInt("product_id"));
        warranty.setStatusId(rs.getInt("status_id"));
        warranty.setRequestDate(rs.getTimestamp("request_date"));
        warranty.setProductName(rs.getString("product_name"));
        warranty.setStatusName(rs.getString("status_name"));
        warranty.setCustomerName(rs.getString("customer_name"));
        return warranty;
    }

    private OrderHistoryItem mapOrder(ResultSet rs) throws SQLException {
        OrderHistoryItem order = new OrderHistoryItem();
        order.setOrderId(rs.getInt("order_id"));
        order.setCustomerId(rs.getInt("customer_id"));
        order.setStatusId(rs.getInt("status_id"));
        order.setOrderDate(rs.getTimestamp("order_date"));
        BigDecimal totalAmount = rs.getBigDecimal("total_amount");
        order.setTotalAmount(totalAmount == null ? BigDecimal.ZERO : totalAmount);
        order.setStatusName(rs.getString("status_name"));
        order.setCustomerName(rs.getString("customer_name"));
        return order;
    }

    private void setDateRange(PreparedStatement ps, int startIndex,
            LocalDate startDate, LocalDate endDate) throws SQLException {
        ps.setDate(startIndex, Date.valueOf(startDate));
        ps.setDate(startIndex + 1, Date.valueOf(endDate.plusDays(1)));
    }

    private boolean isCancelledStatus(String statusName) {
        if (statusName == null) {
            return false;
        }
        String value = statusName.trim().toLowerCase();
        return value.equals("đã hủy") || value.equals("da huy");
    }
}
