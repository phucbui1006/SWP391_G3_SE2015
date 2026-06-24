package dal;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.AccountSummary;
import model.DashboardProduct;
import model.DashboardSummary;
import model.OrderHistoryItem;

public class AdminDashboardDAO extends DBContext {

    public DashboardSummary getSummary(LocalDate selectedDate) {
        DashboardSummary summary = new DashboardSummary();
        summary.setTotalRevenue(queryBigDecimal("""
                SELECT COALESCE(SUM(o.total_amount), 0) AS value
                FROM orders o
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                WHERE DATE(o.order_date) = ?
                  AND (os.status_name IS NULL
                       OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%')
                           AND LOWER(os.status_name) NOT LIKE LOWER('%huy%')))
                """, selectedDate));
        summary.setTotalOrders(queryInt("SELECT COUNT(*) AS value FROM orders WHERE DATE(order_date) = ?", selectedDate));
        summary.setActiveProducts(queryInt("SELECT COUNT(*) AS value FROM products WHERE UPPER(status) = 'ACTIVE'"));
        summary.setTotalBrands(queryInt("SELECT COUNT(*) AS value FROM brands"));
        summary.setWarrantyRequests(queryInt("SELECT COUNT(*) AS value FROM warranties WHERE DATE(request_date) = ?", selectedDate));
        summary.setImportedBatches(queryInt("SELECT COUNT(*) AS value FROM batch WHERE date = ?", selectedDate));
        return summary;
    }

    public List<DashboardProduct> getBestSellingProducts(LocalDate selectedDate, int limit) {
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
               WHERE DATE(o.order_date) = ?
                 AND (
                       os.status_name IS NULL
                       OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%'))
                     )
               GROUP BY p.product_id, p.product_name, p.status
               ORDER BY sold_quantity DESC
               LIMIT ?
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(selectedDate));
            ps.setInt(2, limit);

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

    public int countBestSellingProducts(LocalDate selectedDate) {
        String sql = """
                SELECT COUNT(*) AS value
                FROM (
                    SELECT p.product_id
                    FROM order_details od
                    INNER JOIN orders o ON o.order_id = od.order_id
                    INNER JOIN products p ON p.product_id = od.product_id
                    LEFT JOIN orders_status os ON os.status_id = o.status_id
                    WHERE DATE(o.order_date) = ?
                      AND (os.status_name IS NULL
                           OR (LOWER(os.status_name) NOT LIKE LOWER('%hủy%')))
                    GROUP BY p.product_id
                ) sold_products
                """;
        return queryInt(sql, selectedDate);
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

    public List<OrderHistoryItem> getLatestOrders(LocalDate selectedDate, int limit) {
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
                LEFT JOIN orders_status os ON os.status_id = o.status_id
                WHERE DATE(o.order_date) = ?
                ORDER BY o.order_date DESC, o.order_id DESC
                LIMIT ?
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(selectedDate));
            ps.setInt(2, limit);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderHistoryItem order = new OrderHistoryItem();
                    order.setOrderId(rs.getInt("order_id"));
                    order.setCustomerId(rs.getInt("customer_id"));
                    order.setStatusId(rs.getInt("status_id"));
                    Timestamp orderDate = rs.getTimestamp("order_date");
                    order.setOrderDate(orderDate);
                    order.setTotalAmount(nullToZero(rs.getBigDecimal("total_amount")));
                    order.setStatusName(rs.getString("status_name"));
                    order.setCustomerName(rs.getString("customer_name"));
                    orders.add(order);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orders;
    }

    public Map<String, Integer> getWarrantyStatusCounts(LocalDate selectedDate) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        String sql = """
                SELECT COALESCE(ws.status_name, 'Chưa cập nhật') AS status_name,
                       COUNT(w.warranty_id) AS total
                FROM warranties w
                LEFT JOIN warranty_status ws ON ws.status_id = w.status_id
                WHERE DATE(w.request_date) = ?
                GROUP BY COALESCE(ws.status_name, 'Chưa cập nhật')
                ORDER BY total DESC, status_name ASC
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(selectedDate));

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

    private int queryInt(String sql, LocalDate selectedDate) {
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(selectedDate));
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

    private BigDecimal queryBigDecimal(String sql, LocalDate selectedDate) {
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(selectedDate));
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
