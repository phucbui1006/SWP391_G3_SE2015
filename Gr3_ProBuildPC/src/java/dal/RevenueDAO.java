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
import model.Revenue;

public class RevenueDAO extends DBContext {

    public ArrayList<Revenue> getRevenueList(String fromDate, String toDate, String paymentMethod, String paymentStatus) {
        ArrayList<Revenue> list = new ArrayList<>();

        String sql = "SELECT order_id, user_id, order_date, payment_method, payment_status, total_amount "
                + "FROM orders "
                + "WHERE 1 = 1 ";

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql += " AND DATE(order_date) >= ? ";
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql += " AND DATE(order_date) <= ? ";
        }

        if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
            sql += " AND payment_method = ? ";
        }

        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            sql += " AND payment_status = ? ";
        }

        sql += " ORDER BY order_date DESC";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            int index = 1;

            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(index++, fromDate);
            }

            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(index++, toDate);
            }

            if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
                ps.setString(index++, paymentMethod);
            }

            if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
                ps.setString(index++, paymentStatus);
            }

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Revenue r = new Revenue();
                r.setOrderId(rs.getInt("order_id"));
                r.setUserId(rs.getInt("user_id"));
                r.setOrderDate(rs.getTimestamp("order_date"));
                r.setPaymentMethod(rs.getString("payment_method"));
                r.setPaymentStatus(rs.getString("payment_status"));
                r.setTotalAmount(rs.getDouble("total_amount"));

                list.add(r);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    public int getTotalOrders(String fromDate, String toDate, String paymentMethod, String paymentStatus) {
        return getRevenueList(fromDate, toDate, paymentMethod, paymentStatus).size();
    }

    public double getTotalRevenue(String fromDate, String toDate, String paymentMethod, String paymentStatus) {
        double total = 0;

        ArrayList<Revenue> list = getRevenueList(fromDate, toDate, paymentMethod, paymentStatus);

        for (Revenue r : list) {
            total += r.getTotalAmount();
        }

        return total;
    }

    public int getTotalProductsSold(String fromDate, String toDate, String paymentMethod, String paymentStatus) {
        int total = 0;

        String sql = "SELECT COALESCE(SUM(od.quantity), 0) AS total_products "
                + "FROM orders o "
                + "JOIN order_details od ON o.order_id = od.order_id "
                + "WHERE 1 = 1 ";

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql += " AND DATE(o.order_date) >= ? ";
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql += " AND DATE(o.order_date) <= ? ";
        }

        if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
            sql += " AND o.payment_method = ? ";
        }

        if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
            sql += " AND o.payment_status = ? ";
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            int index = 1;

            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(index++, fromDate);
            }

            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(index++, toDate);
            }

            if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
                ps.setString(index++, paymentMethod);
            }

            if (paymentStatus != null && !paymentStatus.trim().isEmpty()) {
                ps.setString(index++, paymentStatus);
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getInt("total_products");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return total;
    }

    public int getCompletedPayments(String fromDate, String toDate, String paymentMethod, String paymentStatus) {
        int total = 0;

        String sql = "SELECT COUNT(*) AS completed_payments "
                + "FROM orders "
                + "WHERE payment_status = 'Đã thanh toán' ";

        if (fromDate != null && !fromDate.trim().isEmpty()) {
            sql += " AND DATE(order_date) >= ? ";
        }

        if (toDate != null && !toDate.trim().isEmpty()) {
            sql += " AND DATE(order_date) <= ? ";
        }

        if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
            sql += " AND payment_method = ? ";
        }

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            int index = 1;

            if (fromDate != null && !fromDate.trim().isEmpty()) {
                ps.setString(index++, fromDate);
            }

            if (toDate != null && !toDate.trim().isEmpty()) {
                ps.setString(index++, toDate);
            }

            if (paymentMethod != null && !paymentMethod.trim().isEmpty()) {
                ps.setString(index++, paymentMethod);
            }

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                total = rs.getInt("completed_payments");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return total;
    }
}