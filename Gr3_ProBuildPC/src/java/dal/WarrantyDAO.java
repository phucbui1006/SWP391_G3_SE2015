/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

/**
 *
 * @author Admin
 */

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import model.Warranty;

public class WarrantyDAO extends DBContext {

    public ArrayList<Warranty> searchWarrantyByOrderId(int orderId, int userId) {
        ArrayList<Warranty> list = new ArrayList<>();

        String sql = "SELECT od.order_detail_id, o.order_id, o.user_id, "
                + "p.product_id, p.product_name, o.order_date, p.warranty_months, "
                + "DATE_ADD(o.order_date, INTERVAL p.warranty_months MONTH) AS warranty_end_date "
                + "FROM orders o "
                + "JOIN order_details od ON o.order_id = od.order_id "
                + "JOIN products p ON od.product_id = p.product_id "
                + "WHERE o.order_id = ? AND o.user_id = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, orderId);
            ps.setInt(2, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Warranty w = new Warranty();
                w.setOrderDetailId(rs.getInt("order_detail_id"));
                w.setOrderId(rs.getInt("order_id"));
                w.setUserId(rs.getInt("user_id"));
                w.setProductId(rs.getInt("product_id"));
                w.setProductName(rs.getString("product_name"));
                w.setOrderDate(rs.getTimestamp("order_date"));
                w.setWarrantyMonths(rs.getInt("warranty_months"));
                w.setWarrantyEndDate(rs.getTimestamp("warranty_end_date"));

                list.add(w);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean createWarrantyRequest(int orderDetailId, int userId, int productId, String requestContent) {
        String sql = "INSERT INTO warranties(order_detail_id, user_id, product_id, status_id, request_date, request) "
                + "VALUES (?, ?, ?, 1, NOW(), ?)";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, orderDetailId);
            ps.setInt(2, userId);
            ps.setInt(3, productId);
            ps.setString(4, requestContent);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public ArrayList<Warranty> getWarrantyRequestsByUser(int userId) {
        ArrayList<Warranty> list = new ArrayList<>();

        String sql = "SELECT w.warranty_id, w.order_detail_id, w.user_id, w.product_id, "
                + "w.status_id, w.request_date, w.request, "
                + "p.product_name, ws.status_name "
                + "FROM warranties w "
                + "JOIN products p ON w.product_id = p.product_id "
                + "LEFT JOIN warranty_status ws ON w.status_id = ws.status_id "
                + "WHERE w.user_id = ? "
                + "ORDER BY w.warranty_id DESC";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Warranty w = new Warranty();
                w.setWarrantyId(rs.getInt("warranty_id"));
                w.setOrderDetailId(rs.getInt("order_detail_id"));
                w.setUserId(rs.getInt("user_id"));
                w.setProductId(rs.getInt("product_id"));
                w.setStatusId(rs.getInt("status_id"));
                w.setRequestDate(rs.getTimestamp("request_date"));
                w.setRequest(rs.getString("request"));
                w.setProductName(rs.getString("product_name"));
                w.setStatusName(rs.getString("status_name"));

                list.add(w);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public ArrayList<Warranty> getAllWarrantyRequests() {
        ArrayList<Warranty> list = new ArrayList<>();

        String sql = "SELECT w.warranty_id, w.order_detail_id, w.user_id, w.product_id, "
                + "w.status_id, w.request_date, w.request, "
                + "p.product_name, u.full_name, ws.status_name "
                + "FROM warranties w "
                + "JOIN products p ON w.product_id = p.product_id "
                + "JOIN users u ON w.user_id = u.user_id "
                + "LEFT JOIN warranty_status ws ON w.status_id = ws.status_id "
                + "ORDER BY w.warranty_id DESC";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Warranty w = new Warranty();
                w.setWarrantyId(rs.getInt("warranty_id"));
                w.setOrderDetailId(rs.getInt("order_detail_id"));
                w.setUserId(rs.getInt("user_id"));
                w.setProductId(rs.getInt("product_id"));
                w.setStatusId(rs.getInt("status_id"));
                w.setRequestDate(rs.getTimestamp("request_date"));
                w.setRequest(rs.getString("request"));
                w.setProductName(rs.getString("product_name"));
                w.setCustomerName(rs.getString("full_name"));
                w.setStatusName(rs.getString("status_name"));

                list.add(w);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public boolean updateWarrantyStatus(int warrantyId, int statusId) {
        String sql = "UPDATE warranties SET status_id = ? WHERE warranty_id = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, statusId);
            ps.setInt(2, warrantyId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}