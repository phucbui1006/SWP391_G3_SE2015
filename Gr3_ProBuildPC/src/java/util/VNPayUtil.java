package util;

import jakarta.servlet.http.HttpServletRequest;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

public class VNPayUtil {
    public static final String VNP_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static final String VNP_TMNCODE = "LKJE04GQ";
    public static final String VNP_HASHSECRET = "UDJOEW2E8HIIE1YDBKQ0IM5I6SMYZAVE";
    public static final String VNP_VERSION = "2.1.0";
    public static final String VNP_COMMAND = "pay";

    public static String getIpAddress(HttpServletRequest request) {
        String ipAddress;
        try {
            ipAddress = request.getHeader("X-FORWARDED-FOR");
            if (ipAddress == null || ipAddress.isEmpty() || "unknown".equalsIgnoreCase(ipAddress)) {
                ipAddress = request.getRemoteAddr();
            }
        } catch (Exception e) {
            ipAddress = "127.0.0.1";
        }
        return ipAddress;
    }

    public static String hmacSHA512(final String key, final String data) {
        try {
            final Mac hmac512 = Mac.getInstance("HmacSHA512");
            final SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            byte[] result = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(2 * result.length);
            for (byte b : result) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception ex) {
            return "";
        }
    }

    public static String buildPaymentUrl(HttpServletRequest request, int orderId, double amountVnd) {
        long amount = (long) (amountVnd * 100);

        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();
        String vnp_ReturnUrl = scheme + "://" + serverName + ":" + serverPort + contextPath + "/vnpay-return";

        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        String vnp_CreateDate = formatter.format(cld.getTime());

        // Dùng TreeMap để tự động sort key theo thứ tự alphabet
        Map<String, String> vnp_Params = new TreeMap<>();
        vnp_Params.put("vnp_Version", VNP_VERSION);
        vnp_Params.put("vnp_Command", VNP_COMMAND);
        vnp_Params.put("vnp_TmnCode", VNP_TMNCODE);
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", String.valueOf(orderId));
        vnp_Params.put("vnp_OrderInfo", "ThanhToanDonHang" + orderId); // Không có dấu cách
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", vnp_ReturnUrl);
        vnp_Params.put("vnp_IpAddr", getIpAddress(request));
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

        // Theo đặc tả chính thức VNPAY:
        // hashData: key=URLEncode(value) — key KHÔNG encode, value encode UTF-8 chuẩn (dùng + cho space)
        // query:    URLEncode(key)=URLEncode(value)
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        boolean first = true;

        for (Map.Entry<String, String> entry : vnp_Params.entrySet()) {
            String fieldName = entry.getKey();
            String fieldValue = entry.getValue();
            if (fieldValue != null && !fieldValue.isEmpty()) {
                if (!first) {
                    hashData.append('&');
                    query.append('&');
                }
                first = false;
                try {
                    // hashData: raw key + URLEncoded value (chuẩn Java, dùng + cho khoảng trắng)
                    hashData.append(fieldName)
                            .append('=')
                            .append(URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString()));

                    // query string: URLEncoded key + URLEncoded value
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.UTF_8.toString()))
                         .append('=')
                         .append(URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString()));
                } catch (Exception e) {
                    hashData.append(fieldName).append('=').append(fieldValue);
                    query.append(fieldName).append('=').append(fieldValue);
                }
            }
        }

        String vnp_SecureHash = hmacSHA512(VNP_HASHSECRET, hashData.toString());
        query.append("&vnp_SecureHash=").append(vnp_SecureHash);

        return VNP_URL + "?" + query.toString();
    }
}
