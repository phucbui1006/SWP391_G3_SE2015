package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import util.ValidatorUtil;

@WebFilter(filterName = "WarrantyValidationFilter", urlPatterns = {
    "/warranty-lookup",
    "/WarrantyLookup",
    "/ManageWarranty",
    "/manage-warranty"
})
public class WarrantyValidationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        boolean isValid = true;

        if ("/warranty-lookup".equalsIgnoreCase(path) || "/WarrantyLookup".equalsIgnoreCase(path)) {
            isValid = validateClientWarrantyRequest(req, res);
        } else if ("/ManageWarranty".equalsIgnoreCase(path) || "/manage-warranty".equalsIgnoreCase(path)) {
            isValid = validateAdminWarrantyRequest(req, res);
        }

        if (isValid) {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {}

    private boolean validateClientWarrantyRequest(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession();
        String action = req.getParameter("action");

        // We only validate the request creation action
        if (!"createRequest".equals(action)) {
            return true;
        }

        String orderIdRaw = req.getParameter("orderId");
        String productIdRaw = req.getParameter("productId");
        String requestReason = req.getParameter("request");

        String orderIdClean = orderIdRaw != null ? orderIdRaw.trim() : "";
        Integer orderId = parseInteger(orderIdClean);
        Integer productId = parseInteger(productIdRaw);

        String errorMsg = null;

        if (orderId == null) {
            errorMsg = "Mã đơn hàng không hợp lệ.";
        } else if (productId == null) {
            errorMsg = "Mã sản phẩm không hợp lệ.";
        } else if (requestReason == null || requestReason.trim().isEmpty()) {
            errorMsg = "Vui lòng nhập lý do bảo hành.";
        } else if (!ValidatorUtil.isValidWarrantyRequestReason(requestReason)) {
            errorMsg = "Lý do bảo hành phải từ 10 đến 1000 ký tự.";
        }

        if (errorMsg != null) {
            session.setAttribute("warrantyFailMessage", errorMsg);
            String redirectUrl = req.getContextPath() + "/warranty-lookup";
            if (orderIdRaw != null && !orderIdRaw.trim().isEmpty()) {
                // Ensure correct formatting of order ID when redirecting back
                String cleanOrderId = orderIdRaw.trim();
                if (!cleanOrderId.isEmpty()) {
                    redirectUrl += "?orderId=" + cleanOrderId;
                }
            }
            res.sendRedirect(redirectUrl);
            return false;
        }

        return true;
    }

    private boolean validateAdminWarrantyRequest(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession();
        
        String warrantyIdRaw = req.getParameter("warrantyId");
        String statusIdRaw = req.getParameter("statusId");
        String responseText = req.getParameter("response");
        String search = req.getParameter("search");
        String statusFilter = req.getParameter("statusFilter");

        if (search == null) {
            search = "";
        }
        if (statusFilter == null) {
            statusFilter = "";
        }

        Integer warrantyId = parseInteger(warrantyIdRaw);
        Integer statusId = parseInteger(statusIdRaw);

        String errorMsg = null;

        if (warrantyId == null) {
            errorMsg = "Dữ liệu mã yêu cầu không hợp lệ!";
        } else if (statusId == null || (statusId != 1 && statusId != 2 && statusId != 3)) {
            errorMsg = "Dữ liệu trạng thái không hợp lệ!";
        } else if (responseText == null || responseText.trim().isEmpty()) {
            errorMsg = "Vui lòng nhập phản hồi của cửa hàng.";
        } else if (!ValidatorUtil.isValidWarrantyResponse(responseText)) {
            errorMsg = "Phản hồi phải từ 5 đến 1000 ký tự.";
        }

        if (errorMsg != null) {
            session.setAttribute("errorMsg", errorMsg);
            String redirectUrl = req.getContextPath() + "/ManageWarranty?search=" 
                    + URLEncoder.encode(search, StandardCharsets.UTF_8.name()) 
                    + "&statusFilter=" + statusFilter;
            res.sendRedirect(redirectUrl);
            return false;
        }

        return true;
    }

    private Integer parseInteger(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
