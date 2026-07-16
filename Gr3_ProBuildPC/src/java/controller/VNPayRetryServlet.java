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
        boolean extended = orderDAO.extendVnpayExpiresAtForCustomer(orderId, account.getCustomerId(), 5);

        if (!extended) {
            if (orderDAO.isVnpayOrderExpiredOrCancelled(orderId)) {
                orderDAO.cancelPendingVnpayOrder(orderId, "Thất bại");
            }
            session.setAttribute("orderHistoryError", "Đơn hàng không còn ở trạng thái chờ thanh toán hoặc đã hết hạn.");
            response.sendRedirect(request.getContextPath() + "/order-history?selectedOrderId=" + orderId);
            return;
        }

        BigDecimal totalAmount = orderDAO.getOrderTotalAmountForCustomer(orderId, account.getCustomerId());
        if (totalAmount.compareTo(BigDecimal.ZERO) <= 0) {
            session.setAttribute("orderHistoryError", "Không thể lấy thông tin thanh toán của đơn hàng này.");
            response.sendRedirect(request.getContextPath() + "/order-history?selectedOrderId=" + orderId);
            return;
        }

        String paymentUrl = VNPayUtil.buildPaymentUrl(request, orderId, totalAmount.doubleValue());
        response.sendRedirect(paymentUrl);
    }
}
