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
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import util.VNPayUtil;

@WebServlet(name = "VNPayReturnServlet", urlPatterns = {"/vnpay-return"})
public class VNPayReturnServlet extends HttpServlet {

    private static final String VIEW_PATH = "/views/vnpay-result.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements();) {
            String fieldName = params.nextElement();
            String fieldValue = request.getParameter(fieldName);
            if (fieldValue != null && fieldValue.length() > 0) {
                fields.put(fieldName, fieldValue);
            }
        }

        String secureHash = request.getParameter("vnp_SecureHash");
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
        boolean isSignatureValid = checkSign.equalsIgnoreCase(secureHash);

        String responseCode = request.getParameter("vnp_ResponseCode");
        String txnRef = request.getParameter("vnp_TxnRef");
        String rawAmount = request.getParameter("vnp_Amount");
        String bankCode = request.getParameter("vnp_BankCode");
        String transactionNo = request.getParameter("vnp_TransactionNo");

        int orderId = parseOrderId(txnRef);
        BigDecimal amount = parseAmount(rawAmount);

        OrderDAO orderDAO = new OrderDAO();
        boolean isSuccess = false;
        String message;

        if (!isSignatureValid) {
            message = "Chữ ký giao dịch không hợp lệ. Vui lòng không thay đổi dữ liệu đường dẫn.";
        } else if (orderId <= 0) {
            message = "Không xác định được đơn hàng cần thanh toán.";
        } else if ("00".equals(responseCode)) {
            if (orderDAO.confirmVnpayPayment(orderId, amount)) {
                isSuccess = true;
                message = "Thanh toán đơn hàng #" + orderId + " thành công qua VNPAY.";
            } else if (orderDAO.isVnpayOrderExpiredOrCancelled(orderId)) {
                orderDAO.cancelPendingVnpayOrder(orderId, "Thất bại");
                message = "Đơn hàng #" + orderId + " đã hết thời gian thanh toán hoặc đã bị hủy. Số lượng sản phẩm đã được hoàn lại kho.";
            } else {
                message = "Thanh toán thành công nhưng không thể cập nhật trạng thái đơn hàng. Vui lòng liên hệ bộ phận hỗ trợ.";
            }
        } else {
            boolean cancelled = orderDAO.cancelPendingVnpayOrder(orderId, "Thất bại");
            if (cancelled) {
                message = "Giao dịch thanh toán đơn hàng #" + orderId + " đã bị hủy hoặc thất bại. Số lượng sản phẩm đã được hoàn lại kho.";
            } else if (orderDAO.isVnpayOrderExpiredOrCancelled(orderId)) {
                orderDAO.cancelPendingVnpayOrder(orderId, "Thất bại");
                message = "Đơn hàng #" + orderId + " đã hết thời gian thanh toán hoặc đã bị hủy trước đó.";
            } else {
                message = "Giao dịch thanh toán của đơn hàng #" + orderId + " không thành công.";
            }
        }

        request.setAttribute("isSuccess", isSuccess);
        request.setAttribute("message", message);
        request.setAttribute("orderId", orderId);
        request.setAttribute("amount", amount);
        request.setAttribute("bankCode", bankCode);
        request.setAttribute("transactionNo", transactionNo);

        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    private int parseOrderId(String txnRef) {
        try {
            return Integer.parseInt(txnRef);
        } catch (Exception e) {
            return -1;
        }
    }

    private BigDecimal parseAmount(String rawAmount) {
        if (rawAmount == null) {
            return BigDecimal.ZERO;
        }

        try {
            return new BigDecimal(rawAmount).divide(new BigDecimal(100));
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }

    private String encode(String value) {
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.toString()).replace("+", "%20");
        } catch (Exception e) {
            return "";
        }
    }
}
