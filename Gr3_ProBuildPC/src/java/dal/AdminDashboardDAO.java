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

public class AdminDashboardDAO extends DBContext {

    public DashboardSummary getSummary(LocalDate startDate, LocalDate endDate) {
        DashboardSummary summary = new DashboardSummary();
        summary.setTotalRevenue(queryBigDecimal("""
                SELECT COALESCE(SUM(o.total_amount), 0) AS value
                FROM orders o
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                WHERE o.order_date >= ?
                  AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                  AND (os.status_name IS NULL
                       OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%')
                           AND LOWER(os.status_name) NOT LIKE LOWER('%huy%')))
                """, startDate, endDate));
        summary.setTotalOrders(queryInt("""
                SELECT COUNT(*) AS value
                FROM orders
                WHERE order_date >= ? AND order_date < DATE_ADD(?, INTERVAL 1 DAY)
                """, startDate, endDate));
        summary.setActiveProducts(queryInt("SELECT COUNT(*) AS value FROM products WHERE UPPER(status) = 'ACTIVE'"));
        summary.setTotalBrands(queryInt("SELECT COUNT(*) AS value FROM brands"));
        summary.setAcceptedWarrantyRequests(queryInt(
                "SELECT COUNT(*) AS value FROM warranties WHERE status_id = 3"));
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
                  AND (os.status_name IS NULL
                       OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%')
                           AND LOWER(os.status_name) NOT LIKE LOWER('%huy%')))
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

    public Map<String, BigDecimal> getCategoryRevenue(LocalDate startDate, LocalDate endDate) {
        Map<String, BigDecimal> revenueByCategory = new LinkedHashMap<>();
        String sql = """
                SELECT c.category_name,
                       COALESCE(SUM(od.subtotal), 0) AS revenue
                FROM order_details od
                INNER JOIN orders o ON o.order_id = od.order_id
                INNER JOIN products p ON p.product_id = od.product_id
                INNER JOIN categories c ON c.category_id = p.category_id
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                WHERE o.order_date >= ?
                  AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                  AND (os.status_name IS NULL
                       OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%')
                           AND LOWER(os.status_name) NOT LIKE LOWER('%huy%')))
                GROUP BY c.category_id, c.category_name
                HAVING revenue > 0
                ORDER BY revenue DESC, c.category_name
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(startDate));
            ps.setDate(2, Date.valueOf(endDate));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    revenueByCategory.put(rs.getString("category_name"),
                            nullToZero(rs.getBigDecimal("revenue")));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return revenueByCategory;
    }

    public List<DashboardProduct> getBestSellingProducts(LocalDate startDate, LocalDate endDate, int limit) {
        List<DashboardProduct> products = new ArrayList<>();
        String sql = """
                SELECT p.product_id,
                      p.product_name,
                      p.status,
                      COALESCE(SUM(od.quantity), 0) AS sold_quantity
               FROM order_details od
               INNER JOIN orders o ON o.order_id = od.order_id
               INNER JOIN products p ON p.product_id = od.product_id
               LEFT JOIN orders_status os ON os.status_id = o.status_id
               WHERE o.order_date >= ?
                 AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                 AND (
                       os.status_name IS NULL
                       OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%')
                           AND LOWER(os.status_name) NOT LIKE LOWER('%huy%'))
                     )
               GROUP BY p.product_id, p.product_name, p.status
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

    public int countBestSellingProducts(LocalDate startDate, LocalDate endDate) {
        String sql = """
                SELECT COUNT(*) AS value
                FROM (
                    SELECT p.product_id
                    FROM order_details od
                    INNER JOIN orders o ON o.order_id = od.order_id
                    INNER JOIN products p ON p.product_id = od.product_id
                    LEFT JOIN orders_status os ON os.status_id = o.status_id
                    WHERE o.order_date >= ?
                      AND o.order_date < DATE_ADD(?, INTERVAL 1 DAY)
                      AND (os.status_name IS NULL
                           OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%')
                               AND LOWER(os.status_name) NOT LIKE LOWER('%huy%')))
                    GROUP BY p.product_id
                ) sold_products
                """;
        return queryInt(sql, startDate, endDate);
    }

    public List<DashboardProduct> getLowStockProducts(int limit) {
        List<DashboardProduct> products = new ArrayList<>();
        String sql = """
                SELECT p.product_id,
                       p.product_name,
                       p.status,
                       COALESCE(stock.quantity, 0) AS stock_quantity,
                       0 AS sold_quantity
                FROM products p
                LEFT JOIN (
                    SELECT product_id, SUM(quantity) AS quantity
                    FROM batch_items
                    GROUP BY product_id
                ) stock ON stock.product_id = p.product_id
                WHERE COALESCE(stock.quantity, 0) <= 5
                ORDER BY stock_quantity ASC, p.product_id DESC
                LIMIT ?
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    public List<DashboardProduct> getAllLowStockProducts() {
        List<DashboardProduct> products = new ArrayList<>();
        String sql = """
                SELECT p.product_id,
                       p.product_name,
                       p.status,
                       COALESCE(stock.quantity, 0) AS stock_quantity,
                       0 AS sold_quantity
                FROM products p
                LEFT JOIN (
                    SELECT product_id, SUM(quantity) AS quantity
                    FROM batch_items
                    GROUP BY product_id
                ) stock ON stock.product_id = p.product_id
                WHERE COALESCE(stock.quantity, 0) <= 5
                ORDER BY stock_quantity ASC, p.product_id DESC
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    products.add(mapProduct(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return products;
    }

    public int countLowStockProducts() {
        String sql = """
                SELECT COUNT(*) AS value
                FROM products p
                LEFT JOIN (
                    SELECT product_id, SUM(quantity) AS quantity
                    FROM batch_items
                    GROUP BY product_id
                ) stock ON stock.product_id = p.product_id
                WHERE COALESCE(stock.quantity, 0) <= 5
                """;
        return queryInt(sql);
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

    public Map<String, Integer> getWarrantyStatusCounts(LocalDate startDate, LocalDate endDate) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        String sql = """
                SELECT COALESCE(ws.status_name, 'Chưa cập nhật') AS status_name,
                       COUNT(w.warranty_id) AS total
                FROM warranties w
                LEFT JOIN warranty_status ws ON ws.status_id = w.status_id
                WHERE w.request_date >= ?
                  AND w.request_date < DATE_ADD(?, INTERVAL 1 DAY)
                GROUP BY COALESCE(ws.status_name, 'Chưa cập nhật')
                ORDER BY total DESC, status_name ASC
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

    private DashboardProduct mapProduct(ResultSet rs) throws SQLException {
        DashboardProduct product = new DashboardProduct();
        product.setProductId(rs.getInt("product_id"));
        product.setProductName(rs.getString("product_name"));
        product.setStatus(rs.getString("status"));
        product.setStockQuantity(rs.getInt("stock_quantity"));
        product.setSoldQuantity(rs.getInt("sold_quantity"));
        return product;
    }

    private DashboardProduct mapBestSellingProduct(ResultSet rs) throws SQLException {
        DashboardProduct product = new DashboardProduct();
        product.setProductId(rs.getInt("product_id"));
        product.setProductName(rs.getString("product_name"));
        product.setStatus(rs.getString("status"));
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
