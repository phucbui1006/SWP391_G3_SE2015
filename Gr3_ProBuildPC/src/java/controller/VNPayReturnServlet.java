package controller;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import util.VNPayUtil;

@WebServlet(name = "VNPayReturnServlet", urlPatterns = {"/vnpay-return"})
public class VNPayReturnServlet extends HttpServlet {

    private static final String VIEW_PATH = "/views/vnpay-result.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Collect parameters for signature verification
        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements();) {
            String fieldName = params.nextElement();
            String fieldValue = request.getParameter(fieldName);
            if (fieldValue != null && fieldValue.length() > 0) {
                fields.put(fieldName, fieldValue);
            }
        }

        String vnp_SecureHash = request.getParameter("vnp_SecureHash");
        fields.remove("vnp_SecureHashType");
        fields.remove("vnp_SecureHash");

        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder signData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = fields.get(fieldName);
            signData.append(encode(fieldName));
            signData.append('=');
            signData.append(encode(fieldValue));
            if (itr.hasNext()) {
                signData.append('&');
            }
        }

        String checkSign = VNPayUtil.hmacSHA512(VNPayUtil.VNP_HASHSECRET, signData.toString());
        boolean isSignatureValid = checkSign.equalsIgnoreCase(vnp_SecureHash);

        String responseCode = request.getParameter("vnp_ResponseCode");
        String txnRef = request.getParameter("vnp_TxnRef");
        String rawAmount = request.getParameter("vnp_Amount");
        String bankCode = request.getParameter("vnp_BankCode");
        String transactionNo = request.getParameter("vnp_TransactionNo");

        int orderId = -1;
        try {
            orderId = Integer.parseInt(txnRef);
        } catch (Exception e) {
            // Ignore
        }

        BigDecimal amount = BigDecimal.ZERO;
        if (rawAmount != null) {
            try {
                // VNPay amount is sent as amount * 100
                amount = new BigDecimal(rawAmount).divide(new BigDecimal(100));
            } catch (Exception e) {
                // Ignore
            }
        }

        OrderDAO orderDAO = new OrderDAO();
        boolean isSuccess = false;
        String message = "";

        if (isSignatureValid) {
            if ("00".equals(responseCode)) {
                // Payment Success: Update order status to 2 (Đã xác nhận), payment_status to 'Đã thanh toán'
                boolean updated = orderDAO.updateOrderStatusAndPaymentStatus(orderId, 2, "Đã thanh toán");
                if (updated) {
                    orderDAO.createPaymentRecord(orderId, "Đã thanh toán", "VNPAY", amount);
                    isSuccess = true;
                    message = "Thanh toán đơn hàng #" + orderId + " thành công qua VNPAY!";
                } else {
                    message = "Thanh toán thành công nhưng không thể cập nhật trạng thái đơn hàng. Vui lòng liên hệ bộ phận hỗ trợ.";
                }
            } else {
                // Payment Failed / Cancelled: Update order status to 6 (Đã hủy), payment_status to 'Thất bại'
                orderDAO.updateOrderStatusAndPaymentStatus(orderId, 6, "Thất bại");
                orderDAO.releaseStock(orderId);
                message = "Giao dịch thanh toán đơn hàng #" + orderId + " đã bị hủy hoặc thất bại.";
            }
        } else {
            message = "Chữ ký giao dịch không hợp lệ. Vui lòng không thay đổi dữ liệu đường dẫn.";
        }

        request.setAttribute("isSuccess", isSuccess);
        request.setAttribute("message", message);
        request.setAttribute("orderId", orderId);
        request.setAttribute("amount", amount);
        request.setAttribute("bankCode", bankCode);
        request.setAttribute("transactionNo", transactionNo);

        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    private String encode(String value) {
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.toString()).replace("+", "%20");
        } catch (Exception e) {
            return "";
        }
    }
}
