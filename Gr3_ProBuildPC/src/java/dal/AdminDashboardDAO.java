package dal;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.AccountSummary;
import model.DashboardProduct;
import model.DashboardSummary;
import model.RevenueRow;

public class AdminDashboardDAO extends DBContext {

    private static final String NOT_CANCELLED_ORDER_CONDITION = """
            AND (os.status_name IS NULL
                 OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%')
                     AND LOWER(os.status_name) NOT LIKE LOWER('%huy%')))
            """;

    public DashboardSummary getSummary(LocalDate startDate, LocalDate endDate) {
        DashboardSummary summary = new DashboardSummary();
        summary.setTotalRevenue(queryBigDecimal("""
                SELECT COALESCE(SUM(o.total_amount), 0) AS value
                FROM orders o
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                WHERE o.order_date >= ?
                  AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                """ + NOT_CANCELLED_ORDER_CONDITION, startDate, endDate));
        summary.setTotalOrders(queryInt("""
                SELECT COUNT(*) AS value
                FROM orders
                WHERE order_date >= ? AND order_date < DATE_ADD(?, INTERVAL 1 DAY)
                """, startDate, endDate));
        summary.setImportedBatches(queryInt("""
                SELECT COUNT(*) AS value FROM batch WHERE date BETWEEN ? AND ?
                """, startDate, endDate));
        return summary;
    }

    public Map<LocalDate, BigDecimal> getRevenueByDay(LocalDate startDate, LocalDate endDate) {
        Map<LocalDate, BigDecimal> revenueByDay = new LinkedHashMap<>();
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            revenueByDay.put(date, BigDecimal.ZERO);
        }

        String sql = """
                SELECT DATE(o.order_date) AS revenue_date,
                       COALESCE(SUM(o.total_amount), 0) AS revenue
                FROM orders o
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                WHERE o.order_date >= ?
                  AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                """ + NOT_CANCELLED_ORDER_CONDITION + """
                GROUP BY DATE(o.order_date)
                ORDER BY revenue_date
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    revenueByDay.put(rs.getDate("revenue_date").toLocalDate(),
                            nullToZero(rs.getBigDecimal("revenue")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return revenueByDay;
    }

    public List<RevenueRow> getRevenueStatistics(LocalDate startDate, LocalDate endDate, String groupBy) {
        List<RevenueRow> list = new ArrayList<>();
        String dateFormat;
        java.time.format.DateTimeFormatter javaFormatter;

        if ("year".equalsIgnoreCase(groupBy)) {
            dateFormat = "%Y";
            javaFormatter = java.time.format.DateTimeFormatter.ofPattern("yyyy");
        } else if ("month".equalsIgnoreCase(groupBy)) {
            dateFormat = "%m-%Y";
            javaFormatter = java.time.format.DateTimeFormatter.ofPattern("MM-yyyy");
        } else {
            dateFormat = "%d-%m-%Y";
            javaFormatter = java.time.format.DateTimeFormatter.ofPattern("dd-MM-yyyy");
        }

        Map<String, RevenueRow> sqlData = new LinkedHashMap<>();

        String sql = """
                SELECT DATE_FORMAT(o.order_date, ?) AS label,
                       COUNT(o.order_id) AS order_count,
                       COALESCE(SUM(o.total_amount), 0) AS revenue,
                       COALESCE(SUM((SELECT SUM(quantity) FROM order_details WHERE order_id = o.order_id)), 0) AS products_sold
                FROM orders o
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                WHERE o.order_date >= ?
                  AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                """ + NOT_CANCELLED_ORDER_CONDITION + """
                GROUP BY DATE_FORMAT(o.order_date, ?)
                ORDER BY MIN(o.order_date) ASC
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, dateFormat);
            ps.setDate(2, Date.valueOf(startDate));
            ps.setDate(3, Date.valueOf(endDate));
            ps.setString(4, dateFormat);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String label = rs.getString("label");
                    sqlData.put(label, new RevenueRow(
                        label,
                        rs.getInt("order_count"),
                        nullToZero(rs.getBigDecimal("revenue")),
                        rs.getInt("products_sold")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Bù lấp các khoảng thời gian bị thiếu
        if ("year".equalsIgnoreCase(groupBy)) {
            for (int y = startDate.getYear(); y <= endDate.getYear(); y++) {
                String label = String.valueOf(y);
                list.add(sqlData.getOrDefault(label, new RevenueRow(label, 0, BigDecimal.ZERO)));
            }
        } else if ("month".equalsIgnoreCase(groupBy)) {
            LocalDate current = startDate.withDayOfMonth(1);
            LocalDate endMonth = endDate.withDayOfMonth(1);
            while (!current.isAfter(endMonth)) {
                String label = current.format(javaFormatter);
                list.add(sqlData.getOrDefault(label, new RevenueRow(label, 0, BigDecimal.ZERO)));
                current = current.plusMonths(1);
            }
        } else { // default is day
            LocalDate current = startDate;
            while (!current.isAfter(endDate)) {
                String label = current.format(javaFormatter);
                list.add(sqlData.getOrDefault(label, new RevenueRow(label, 0, BigDecimal.ZERO)));
                current = current.plusDays(1);
            }
        }

        return list;
    }

    public Map<String, Integer> getCategorySoldQuantities(LocalDate startDate, LocalDate endDate) {
        Map<String, Integer> soldQuantitiesByCategory = new LinkedHashMap<>();
        String sql = """
                SELECT c.category_name,
                       COALESCE(SUM(od.quantity), 0) AS sold_quantity
                FROM order_details od
                INNER JOIN orders o ON o.order_id = od.order_id
                INNER JOIN products p ON p.product_id = od.product_id
                INNER JOIN categories c ON c.category_id = p.category_id
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                WHERE o.order_date >= ?
                  AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                """ + NOT_CANCELLED_ORDER_CONDITION + """
                GROUP BY c.category_id, c.category_name
                HAVING sold_quantity > 0
                ORDER BY sold_quantity DESC, c.category_name
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    soldQuantitiesByCategory.put(rs.getString("category_name"),
                            rs.getInt("sold_quantity"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return soldQuantitiesByCategory;
    }

    public List<DashboardProduct> getBestSellingProducts(LocalDate startDate, LocalDate endDate, int limit) {
        List<DashboardProduct> products = new ArrayList<>();
        String sql = """
                SELECT p.product_name,
                      COALESCE(SUM(od.quantity), 0) AS sold_quantity
               FROM order_details od
               INNER JOIN orders o ON o.order_id = od.order_id
               INNER JOIN products p ON p.product_id = od.product_id
               LEFT JOIN orders_status os ON os.status_id = o.status_id
               WHERE o.order_date >= ?
                 AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
               """ + NOT_CANCELLED_ORDER_CONDITION + """
               GROUP BY p.product_id, p.product_name
               ORDER BY sold_quantity DESC
               LIMIT ?
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));
            ps.setInt(3, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapBestSellingProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    public Map<String, Integer> getOrderStatusCounts(LocalDate startDate, LocalDate endDate) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        String sql = """
                SELECT os.status_name,
                       COUNT(o.order_id) AS total
                FROM orders_status os
                LEFT JOIN orders o ON o.status_id = os.status_id
                    AND o.order_date >= ?
                    AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                GROUP BY os.status_id, os.status_name
                ORDER BY os.status_id ASC
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    counts.put(rs.getString("status_name"), rs.getInt("total"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return counts;
    }

    public AccountSummary getAccountSummary() {
        AccountSummary summary = new AccountSummary();
        summary.setCustomers(queryInt("SELECT COUNT(*) AS value FROM users WHERE UPPER(account_type) = 'CUSTOMER'"));
        summary.setEmployees(queryInt("""
                SELECT COUNT(*) AS value
                FROM users u
                INNER JOIN staffs s ON s.user_id = u.user_id
                INNER JOIN roles r ON r.role_id = s.role_id
                WHERE UPPER(r.role_name) = 'EMPLOYEE'
                """));
        summary.setTransports(queryInt("""
                SELECT COUNT(*) AS value
                FROM users u
                INNER JOIN staffs s ON s.user_id = u.user_id
                INNER JOIN roles r ON r.role_id = s.role_id
                WHERE UPPER(r.role_name) IN ('SHIPMENT', 'TRANSPORT')
                """));
        summary.setLocked(queryInt("SELECT COUNT(*) AS value FROM users WHERE UPPER(COALESCE(status, '')) <> 'ACTIVE'"));
        summary.setActive(queryInt("SELECT COUNT(*) AS value FROM users WHERE UPPER(COALESCE(status, 'ACTIVE')) = 'ACTIVE'"));
        return summary;
    }

    private DashboardProduct mapBestSellingProduct(ResultSet rs) throws SQLException {
        DashboardProduct product = new DashboardProduct();
        product.setProductName(rs.getString("product_name"));
        product.setSoldQuantity(rs.getInt("sold_quantity"));
        return product;
    }

    private int queryInt(String sql) {
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("value");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private int queryInt(String sql, LocalDate startDate, LocalDate endDate) {
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("value");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private BigDecimal queryBigDecimal(String sql, LocalDate startDate, LocalDate endDate) {
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return nullToZero(rs.getBigDecimal("value"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    private BigDecimal nullToZero(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

}
