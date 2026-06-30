package dal;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.Warranty;
import model.WarrantyRequest;

public class WarrantyDAO extends DBContext {

    /**
     * Kiểm tra yêu cầu bảo hành có hiệu lực không.
     * Traversal: PRODUCTS → ORDER_DETAILS → ORDERS
     */
    public boolean isWarrantyRequestValid(int customerId, int productId) {
        String sql = """
                    SELECT COALESCE(o.received_date, o.order_date) AS warranty_start,
                           p.warranty_months
                    FROM orders o
                    INNER JOIN order_details od ON o.order_id = od.order_id
                    INNER JOIN products p ON od.product_id = p.product_id
                    INNER JOIN orders_status os ON o.status_id = os.status_id
                    WHERE o.customer_id = ?
                      AND od.product_id = ?
                      AND os.status_name = 'Đã giao hàng'
                    ORDER BY o.order_date DESC
                    LIMIT 1
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    java.sql.Timestamp warrantyStart = rs.getTimestamp("warranty_start");
                    int warrantyMonths = rs.getInt("warranty_months");
                    if (warrantyStart != null) {
                        java.util.Calendar cal = java.util.Calendar.getInstance();
                        cal.setTimeInMillis(warrantyStart.getTime());
                        cal.add(java.util.Calendar.MONTH, warrantyMonths);
                        java.util.Date endDate = cal.getTime();
                        java.util.Date now = new java.util.Date();

                        return endDate.after(now);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy trạng thái đơn hàng
     */
    public String getOrderStatus(int orderId, int customerId) {
        String sql = """
                    SELECT os.status_name
                    FROM orders o
                    INNER JOIN orders_status os ON o.status_id = os.status_id
                    WHERE o.order_id = ? AND o.customer_id = ?
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status_name");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tạo yêu cầu bảo hành (decoupled — không có order_detail_id)
     */
    public boolean createWarrantyRequest(Warranty warranty) {
        String sql = """
                    INSERT INTO warranties (customer_id, product_id, status_id, request_date, request)
                    VALUES (?, ?, ?, ?, ?)
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, warranty.getCustomerId());
            ps.setInt(2, warranty.getProductId());
            ps.setInt(3, warranty.getStatusId());
            ps.setTimestamp(4, new Timestamp(warranty.getRequestDate().getTime()));
            ps.setString(5, warranty.getRequest());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách warranty requests của khách hàng (Client History View).
     * Traversal: WARRANTIES → PRODUCTS → ORDER_DETAILS → ORDERS
     * Dùng subquery để resolve order_id thông qua product bridge.
     */
    public List<Warranty> getWarrantiesByProduct(int customerId, String searchProduct, Integer filterStatusId) {
        List<Warranty> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                    SELECT w.warranty_id,
                           w.customer_id,
                           w.product_id,
                           w.status_id,
                           w.request_date,
                           w.response_date,
                           w.request,
                           w.response,
                           p.product_name,
                           p.image_url,
                           b.brand_name,
                           c.category_name,
                           ws.status_name,
                           u.full_name AS customer_name,
                           COALESCE((
                               SELECT od.order_id
                               FROM order_details od
                               JOIN orders o ON od.order_id = o.order_id
                               WHERE od.product_id = w.product_id AND o.customer_id = w.customer_id
                               ORDER BY o.order_date DESC
                               LIMIT 1
                           ), 0) AS order_id
                    FROM warranties w
                    JOIN products p ON w.product_id = p.product_id
                    LEFT JOIN brands b ON p.brand_id = b.brand_id
                    LEFT JOIN categories c ON p.category_id = c.category_id
                    LEFT JOIN warranty_status ws ON w.status_id = ws.status_id
                    LEFT JOIN customers cust ON w.customer_id = cust.customer_id
                    LEFT JOIN users u ON cust.user_id = u.user_id
                    WHERE w.customer_id = ?
                """);

        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (searchProduct != null && !searchProduct.trim().isEmpty()) {
            String clean = searchProduct.trim();
            sql.append("""
                 AND (
                     p.product_name LIKE ?
                     OR CAST(w.warranty_id AS CHAR) LIKE ?
                     OR w.warranty_id = ?
                 )
            """);
            String likeParam = "%" + clean + "%";
            params.add(likeParam);
            params.add(likeParam);
            
            int numericId = -1;
            try {
                numericId = Integer.parseInt(clean);
            } catch (NumberFormatException e) {
                // ignore
            }
            params.add(numericId);
        }

        if (filterStatusId != null) {
            sql.append(" AND w.status_id = ? ");
            params.add(filterStatusId);
        }
        sql.append(" ORDER BY w.request_date DESC ");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            for (Object param : params) {
                ps.setObject(paramIndex++, param);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Warranty w = new Warranty();
                    w.setWarrantyId(rs.getInt("warranty_id"));
                    w.setCustomerId(rs.getInt("customer_id"));
                    w.setProductId(rs.getInt("product_id"));
                    w.setStatusId(rs.getInt("status_id"));
                    w.setRequestDate(rs.getTimestamp("request_date"));
                    w.setResponseDate(rs.getTimestamp("response_date"));
                    w.setRequest(rs.getString("request"));
                    w.setResponse(rs.getString("response"));
                    w.setProductName(rs.getString("product_name"));
                    w.setImageUrl(rs.getString("image_url"));
                    w.setBrandName(rs.getString("brand_name"));
                    w.setCategoryName(rs.getString("category_name"));
                    w.setCustomerName(rs.getString("customer_name"));
                    w.setOrderId(rs.getInt("order_id"));

                    String statusName = rs.getString("status_name");
                    if (statusName == null || statusName.trim().isEmpty()) {
                        if (w.getStatusId() == 1)
                            statusName = "Chờ tiếp nhận";
                        else if (w.getStatusId() == 2)
                            statusName = "Từ chối";
                        else if (w.getStatusId() == 3)
                            statusName = "Chấp nhận";
                    }
                    w.setStatusName(statusName);
                    w.setStoreResponse(w.getResponse() != null ? w.getResponse() : "");

                    list.add(w);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả warranties cho Admin view (decoupled — không dùng
     * order_detail_id).
     * Traversal: WARRANTIES → PRODUCTS → ORDER_DETAILS → ORDERS
     */
    public List<Warranty> getAllWarranties(String search, Integer statusId) {
        List<Warranty> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                    SELECT w.warranty_id,
                           w.customer_id,
                           w.product_id,
                           w.status_id,
                           w.request_date,
                           w.response_date,
                           w.request,
                           w.response,
                           p.product_name,
                           ws.status_name,
                           u.full_name AS customer_name,
                           COALESCE((
                               SELECT od.order_id
                               FROM order_details od
                               JOIN orders o ON od.order_id = o.order_id
                               WHERE od.product_id = w.product_id AND o.customer_id = w.customer_id
                               ORDER BY o.order_date DESC
                               LIMIT 1
                           ), 0) AS order_id
                    FROM warranties w
                    JOIN products p ON w.product_id = p.product_id
                    LEFT JOIN warranty_status ws ON w.status_id = ws.status_id
                    LEFT JOIN customers c ON w.customer_id = c.customer_id
                    LEFT JOIN users u ON c.user_id = u.user_id
                    WHERE 1=1
                """);

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            String digits = search.replaceAll("[^0-9]", "").trim();
            if (!digits.isEmpty()) {
                sql.append(" AND w.warranty_id = ? ");
                params.add(Integer.parseInt(digits));
            } else {
                sql.append(" AND (p.product_name LIKE ? OR u.full_name LIKE ?) ");
                params.add("%" + search.trim() + "%");
                params.add("%" + search.trim() + "%");
            }
        }

        if (statusId != null && statusId > 0) {
            sql.append(" AND w.status_id = ? ");
            params.add(statusId);
        }

        sql.append(" ORDER BY w.request_date DESC ");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Integer) {
                    ps.setInt(i + 1, (Integer) p);
                } else {
                    ps.setString(i + 1, (String) p);
                }
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Warranty w = new Warranty();
                    w.setWarrantyId(rs.getInt("warranty_id"));
                    w.setCustomerId(rs.getInt("customer_id"));
                    w.setProductId(rs.getInt("product_id"));
                    w.setStatusId(rs.getInt("status_id"));
                    w.setRequestDate(rs.getTimestamp("request_date"));
                    w.setResponseDate(rs.getTimestamp("response_date"));
                    w.setRequest(rs.getString("request"));
                    w.setResponse(rs.getString("response"));
                    w.setProductName(rs.getString("product_name"));
                    w.setCustomerName(rs.getString("customer_name"));
                    w.setOrderId(rs.getInt("order_id"));

                    String statusName = rs.getString("status_name");
                    if (statusName == null || statusName.trim().isEmpty()) {
                        if (w.getStatusId() == 1)
                            statusName = "Chờ tiếp nhận";
                        else if (w.getStatusId() == 2)
                            statusName = "Từ chối";
                        else if (w.getStatusId() == 3)
                            statusName = "Chấp nhận";
                    }
                    w.setStatusName(statusName);
                    w.setStoreResponse(w.getResponse() != null ? w.getResponse() : "");

                    list.add(w);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Cập nhật trạng thái bảo hành (auto response_date = NOW và cập nhật phản hồi)
     */
    public boolean updateWarrantyStatus(int warrantyId, int statusId, String response) {
        String sql = "UPDATE warranties SET status_id = ?, response = ?, response_date = CURRENT_TIMESTAMP WHERE warranty_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, statusId);
            ps.setString(2, response);
            ps.setInt(3, warrantyId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy chi tiết tình trạng bảo hành sản phẩm (cho Admin modal).
     * Traversal: PRODUCTS → ORDER_DETAILS → ORDERS
     */
    public Warranty getProductWarrantyCondition(int productId, int customerId) {
        String sql = """
                    SELECT od.product_id,
                           od.quantity,
                           od.unit_price,
                           p.product_name,
                           b.brand_name,
                           c.category_name,
                           o.order_id,
                           o.order_date,
                           o.received_date,
                           u.full_name AS customer_name,
                           p.warranty_months AS warranty_months,
                           DATE_ADD(COALESCE(o.received_date, o.order_date), INTERVAL p.warranty_months MONTH) AS warranty_end_date,
                           DATEDIFF(DATE_ADD(COALESCE(o.received_date, o.order_date), INTERVAL p.warranty_months MONTH), CURDATE()) AS remaining_days
                    FROM order_details od
                    INNER JOIN orders o ON od.order_id = o.order_id
                    INNER JOIN customers cust ON o.customer_id = cust.customer_id
                    INNER JOIN users u ON cust.user_id = u.user_id
                    INNER JOIN products p ON od.product_id = p.product_id
                    INNER JOIN brands b ON p.brand_id = b.brand_id
                    INNER JOIN categories c ON p.category_id = c.category_id
                    WHERE od.product_id = ?
                      AND o.customer_id = ?
                      AND o.status_id = 5
                """;

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Warranty item = new Warranty();
                    item.setProductId(rs.getInt("product_id"));
                    item.setQuantity(rs.getInt("quantity"));
                    item.setProductName(rs.getString("product_name"));
                    item.setBrandName(rs.getString("brand_name"));
                    item.setCategoryName(rs.getString("category_name"));
                    item.setWarrantyMonths(rs.getInt("warranty_months"));
                    item.setWarrantyEndDate(rs.getDate("warranty_end_date"));
                    item.setRemainingDays(rs.getLong("remaining_days"));
                    item.setCustomerName(rs.getString("customer_name"));
                    item.setOrderDate(rs.getTimestamp("received_date"));
                    item.setOrderId(rs.getInt("order_id"));

                    return item;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tra cứu warranty theo Order ID (Customer Warranty Lookup page).
     * Traversal: ORDERS → ORDER_DETAILS → PRODUCTS + LEFT JOIN WARRANTIES
     * Không dùng order_detail_id trong JOIN với warranties.
     */
    public List<Warranty> getWarrantyInfoByOrderId(int orderId, int customerId) {
        String sql = """
                    SELECT o.order_id,
                           o.customer_id,
                           o.order_date,
                           o.received_date,
                           o.total_amount,
                           o.payment_method,
                           o.payment_status,
                           os.status_name AS order_status_name,
                           od.product_id,
                           od.quantity,
                           p.product_name,
                           p.image_url,
                           w.warranty_id,
                           w.status_id,
                           w.response,
                           ws.status_name,
                           p.warranty_months AS warranty_months,
                           br.brand_name,
                           ca.category_name,
                           DATE_ADD(COALESCE(o.received_date, o.order_date), INTERVAL p.warranty_months MONTH) AS warranty_end_date,
                           DATEDIFF(DATE_ADD(COALESCE(o.received_date, o.order_date), INTERVAL p.warranty_months MONTH), CURDATE()) AS remaining_days
                    FROM orders o
                    INNER JOIN orders_status os ON o.status_id = os.status_id
                    INNER JOIN order_details od ON o.order_id = od.order_id
                    INNER JOIN products p ON od.product_id = p.product_id
                    INNER JOIN brands br ON p.brand_id = br.brand_id
                    INNER JOIN categories ca ON p.category_id = ca.category_id
                    LEFT JOIN warranties w ON p.product_id = w.product_id
                                          AND w.customer_id = o.customer_id
                    LEFT JOIN warranty_status ws ON w.status_id = ws.status_id
                    WHERE o.order_id = ?
                      AND o.customer_id = ?
                      AND o.status_id = 5
                    ORDER BY od.order_detail_id
                """;

        List<Warranty> list = new ArrayList<>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Warranty w = new Warranty();
                    w.setOrderId(rs.getInt("order_id"));
                    w.setCustomerId(rs.getInt("customer_id"));
                    w.setOrderDate(rs.getTimestamp("order_date"));
                    w.setDeliveryDate(rs.getTimestamp("received_date"));
                    w.setTotalAmount(rs.getBigDecimal("total_amount"));
                    w.setPaymentMethod(rs.getString("payment_method"));
                    w.setPaymentStatus(rs.getString("payment_status"));
                    w.setOrderStatusName(rs.getString("order_status_name"));
                    w.setProductId(rs.getInt("product_id"));
                    w.setQuantity(rs.getInt("quantity"));
                    w.setProductName(rs.getString("product_name"));
                    w.setImageUrl(rs.getString("image_url"));
                    w.setWarrantyMonths(rs.getInt("warranty_months"));
                    w.setBrandName(rs.getString("brand_name"));
                    w.setCategoryName(rs.getString("category_name"));
                    w.setWarrantyEndDate(rs.getDate("warranty_end_date"));
                    w.setRemainingDays(rs.getLong("remaining_days"));

                    // Warranty request fields
                    w.setWarrantyId(rs.getInt("warranty_id"));
                    w.setStatusId(rs.getInt("status_id"));
                    w.setResponse(rs.getString("response"));

                    String statusName = rs.getString("status_name");
                    if (statusName == null || statusName.trim().isEmpty()) {
                        if (w.getStatusId() == 1)
                            statusName = "Chờ tiếp nhận";
                        else if (w.getStatusId() == 2)
                            statusName = "Từ chối";
                        else if (w.getStatusId() == 3)
                            statusName = "Chấp nhận";
                    }
                    w.setStatusName(statusName);
                    w.setStoreResponse(w.getResponse() != null ? w.getResponse() : "");

                    list.add(w);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list.isEmpty() ? null : list;
    }

    /**
     * Lấy lịch sử bảo hành theo product_id + customer_id (thay thế
     * getWarrantyHistoryByOrderDetailId).
     * Decoupled: không dùng order_detail_id.
     */
    public List<Warranty> getWarrantyHistoryByProductAndCustomer(int productId, int customerId) {
        List<Warranty> list = new ArrayList<>();
        String sql = """
                    SELECT w.warranty_id,
                           w.customer_id,
                           w.product_id,
                           w.status_id,
                           w.request_date,
                           w.response_date,
                           w.request,
                           w.response,
                           ws.status_name
                    FROM warranties w
                    LEFT JOIN warranty_status ws ON w.status_id = ws.status_id
                    WHERE w.product_id = ?
                      AND w.customer_id = ?
                    ORDER BY w.request_date DESC
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, productId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Warranty w = new Warranty();
                    w.setWarrantyId(rs.getInt("warranty_id"));
                    w.setCustomerId(rs.getInt("customer_id"));
                    w.setProductId(rs.getInt("product_id"));
                    w.setStatusId(rs.getInt("status_id"));
                    w.setRequestDate(rs.getTimestamp("request_date"));
                    w.setResponseDate(rs.getTimestamp("response_date"));
                    w.setRequest(rs.getString("request"));
                    w.setResponse(rs.getString("response"));

                    String statusName = rs.getString("status_name");
                    if (statusName == null || statusName.trim().isEmpty()) {
                        if (w.getStatusId() == 1)
                            statusName = "Chờ tiếp nhận";
                        else if (w.getStatusId() == 2)
                            statusName = "Từ chối";
                        else if (w.getStatusId() == 3)
                            statusName = "Chấp nhận";
                    }
                    w.setStatusName(statusName);

                    w.setStoreResponse(w.getResponse() != null ? w.getResponse() : "");
                    list.add(w);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiểm tra đã có warranty request pending cho product này chưa
     */
    public boolean isWarrantyPendingOrActive(int customerId, int productId) {
        String sql = """
                    SELECT COUNT(*)
                    FROM warranties
                    WHERE customer_id = ?
                      AND product_id = ?
                      AND status_id = 1
                """;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy danh sách warranty requests của khách hàng (Client History View).
     * Decoupled: không có order_detail_id.
     * Traversal: WARRANTIES → PRODUCTS → ORDER_DETAILS → ORDERS
     */
    public List<WarrantyRequest> getWarrantyRequestsByCustomerId(int customerId, String searchKeyword,
            Integer statusId) {
        List<WarrantyRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                    SELECT w.warranty_id,
                           w.customer_id,
                           w.product_id,
                           w.status_id,
                           w.request_date,
                           w.response_date,
                           w.request,
                           w.response,
                           p.product_name,
                           p.image_url,
                           b.brand_name,
                           c.category_name,
                           ws.status_name,
                           u.full_name AS customer_name,
                           COALESCE((
                               SELECT od.order_id
                               FROM order_details od
                               JOIN orders o ON od.order_id = o.order_id
                               WHERE od.product_id = w.product_id AND o.customer_id = w.customer_id
                               ORDER BY o.order_date DESC
                               LIMIT 1
                           ), 0) AS order_id
                    FROM warranties w
                    JOIN products p ON w.product_id = p.product_id
                    LEFT JOIN brands b ON p.brand_id = b.brand_id
                    LEFT JOIN categories c ON p.category_id = c.category_id
                    LEFT JOIN warranty_status ws ON w.status_id = ws.status_id
                    LEFT JOIN customers cust ON w.customer_id = cust.customer_id
                    LEFT JOIN users u ON cust.user_id = u.user_id
                    WHERE w.customer_id = ?
                """);

        List<Object> params = new ArrayList<>();
        params.add(customerId);

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String clean = searchKeyword.trim();
            if (clean.matches("\\d+")) {
                sql.append(" AND w.warranty_id = ? ");
                params.add(Integer.parseInt(clean));
            } else {
                sql.append("""
                     AND (
                         p.product_name LIKE ?
                     )
                """);
                params.add("%" + clean + "%");
            }
        }

        if (statusId != null) {
            sql.append(" AND w.status_id = ? ");
            params.add(statusId);
        }

        sql.append(" ORDER BY w.request_date DESC ");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WarrantyRequest w = new WarrantyRequest();
                    w.setWarrantyId(rs.getInt("warranty_id"));
                    w.setCustomerId(rs.getInt("customer_id"));
                    w.setProductId(rs.getInt("product_id"));
                    w.setStatusId(rs.getInt("status_id"));
                    w.setRequestDate(rs.getTimestamp("request_date"));
                    w.setResponseDate(rs.getTimestamp("response_date"));
                    w.setRequest(rs.getString("request"));
                    w.setResponse(rs.getString("response"));
                    w.setProductName(rs.getString("product_name"));
                    w.setImageUrl(rs.getString("image_url"));
                    w.setBrandName(rs.getString("brand_name"));
                    w.setCategoryName(rs.getString("category_name"));

                    String statusName = rs.getString("status_name");
                    if (statusName == null || statusName.trim().isEmpty()) {
                        if (w.getStatusId() == 1)
                            statusName = "Chờ tiếp nhận";
                        else if (w.getStatusId() == 2)
                            statusName = "Từ chối";
                        else if (w.getStatusId() == 3)
                            statusName = "Chấp nhận";
                    }
                    w.setStatusName(statusName);
                    w.setCustomerName(rs.getString("customer_name"));
                    w.setOrderId(rs.getInt("order_id"));

                    list.add(w);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy tất cả warranty requests cho Admin/Employee dashboard.
     * Decoupled: không có order_detail_id.
     * Traversal: WARRANTIES → PRODUCTS → ORDER_DETAILS → ORDERS
     */
    public List<WarrantyRequest> getAllWarrantyRequestsForAdmin(String searchKeyword, Integer statusId) {
        List<WarrantyRequest> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("""
                    SELECT w.warranty_id,
                           w.customer_id,
                           w.product_id,
                           w.status_id,
                           w.request_date,
                           w.response_date,
                           w.request,
                           w.response,
                           p.product_name,
                           p.image_url,
                           ws.status_name,
                           u.full_name AS customer_name,
                           COALESCE((
                               SELECT od.order_id
                               FROM order_details od
                               JOIN orders o ON od.order_id = o.order_id
                               WHERE od.product_id = w.product_id AND o.customer_id = w.customer_id
                               ORDER BY o.order_date DESC
                               LIMIT 1
                           ), 0) AS order_id
                    FROM warranties w
                    JOIN products p ON w.product_id = p.product_id
                    JOIN customers cust ON w.customer_id = cust.customer_id
                    JOIN users u ON cust.user_id = u.user_id
                    LEFT JOIN warranty_status ws ON w.status_id = ws.status_id
                    WHERE 1=1
                """);

        List<Object> params = new ArrayList<>();

        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String digits = searchKeyword.replaceAll("[^0-9]", "").trim();
            if (!digits.isEmpty()) {
                sql.append(" AND w.warranty_id = ? ");
                params.add(Integer.parseInt(digits));
            } else {
                sql.append(" AND (p.product_name LIKE ? OR u.full_name LIKE ?) ");
                params.add("%" + searchKeyword.trim() + "%");
                params.add("%" + searchKeyword.trim() + "%");
            }
        }

        if (statusId != null && statusId > 0) {
            sql.append(" AND w.status_id = ? ");
            params.add(statusId);
        }

        sql.append(" ORDER BY w.request_date DESC ");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WarrantyRequest w = new WarrantyRequest();
                    w.setWarrantyId(rs.getInt("warranty_id"));
                    w.setCustomerId(rs.getInt("customer_id"));
                    w.setProductId(rs.getInt("product_id"));
                    w.setStatusId(rs.getInt("status_id"));
                    w.setRequestDate(rs.getTimestamp("request_date"));
                    w.setResponseDate(rs.getTimestamp("response_date"));
                    w.setRequest(rs.getString("request"));
                    w.setResponse(rs.getString("response"));
                    w.setProductName(rs.getString("product_name"));
                    w.setImageUrl(rs.getString("image_url"));

                    String statusName = rs.getString("status_name");
                    if (statusName == null || statusName.trim().isEmpty()) {
                        if (w.getStatusId() == 1)
                            statusName = "Chờ tiếp nhận";
                        else if (w.getStatusId() == 2)
                            statusName = "Từ chối";
                        else if (w.getStatusId() == 3)
                            statusName = "Chấp nhận";
                    }
                    w.setStatusName(statusName);
                    w.setCustomerName(rs.getString("customer_name"));
                    w.setOrderId(rs.getInt("order_id"));

                    list.add(w);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
