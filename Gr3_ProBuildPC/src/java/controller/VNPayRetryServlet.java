package controller;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import model.User;
import util.VNPayUtil;

/**
 * Servlet cho phép khách hàng tiếp tục thanh toán VNPAY
 * với một đơn hàng đang ở trạng thái "Chờ thanh toán".
 */
@WebServlet(name = "VNPayRetryServlet", urlPatterns = {"/vnpay-retry"})
public class VNPayRetryServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        if (account == null || !account.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(request.getParameter("orderId"));
        } catch (NumberFormatException e) {
            session.setAttribute("orderHistoryError", "Mã đơn hàng không hợp lệ.");
            response.sendRedirect(request.getContextPath() + "/order-history");
            return;
        }

        OrderDAO orderDAO = new OrderDAO();

        // Gia hạn thêm 5 phút từ thời điểm hiện tại
        orderDAO.setVnpayExpiresAt(orderId, 5);

        // Lấy lại tổng tiền của đơn hàng
        BigDecimal totalAmount = orderDAO.getOrderTotalAmount(orderId);

        // Tạo URL thanh toán mới (cùng orderId)
        String paymentUrl = VNPayUtil.buildPaymentUrl(request, orderId, totalAmount.doubleValue());
        response.sendRedirect(paymentUrl);
    }
}
