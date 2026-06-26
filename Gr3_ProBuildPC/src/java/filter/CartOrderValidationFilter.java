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
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebFilter(filterName = "CartOrderValidationFilter", urlPatterns = {
    "/submit-review",
    "/checkout",
    "/order-history",
    "/OrderHistory"
})
public class CartOrderValidationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        boolean isValid = true;

        if ("/submit-review".equalsIgnoreCase(path) && "POST".equalsIgnoreCase(req.getMethod())) {
            isValid = validateSubmitReview(req, res);
        } else if ("/checkout".equalsIgnoreCase(path) && "POST".equalsIgnoreCase(req.getMethod())) {
            isValid = validateCheckout(req, res);
        } else if (("/order-history".equalsIgnoreCase(path) || "/OrderHistory".equalsIgnoreCase(path))) {
            isValid = validateOrderHistory(req, res);
        }

        if (isValid) {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {}

    private boolean validateCheckout(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        String action = req.getParameter("action");
        if ("placeOrder".equalsIgnoreCase(action)) {
            String note = util.ValidatorUtil.safeTrimAndClean(req.getParameter("note"));
            if (!util.ValidatorUtil.isValidNote(note)) {
                req.setAttribute("errorMsg", "Ghi chú không hợp lệ (tối đa 1000 ký tự) hoặc chứa ký tự đặc biệt.");
                req.getRequestDispatcher("/checkout").forward(req, res);
                return false;
            }
        }
        return true;
    }

    private boolean validateOrderHistory(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        // Validate Search in GET
        if ("GET".equalsIgnoreCase(req.getMethod())) {
            String keyword = req.getParameter("keyword");
            if (keyword != null && !keyword.trim().isEmpty() && !util.ValidatorUtil.isValidSearchQuery(keyword)) {
                HttpSession session = req.getSession(false);
                if (session != null) {
                    session.setAttribute("orderHistoryError", "Từ khóa tìm kiếm không hợp lệ (quá dài hoặc chứa ký tự đặc biệt).");
                }
                res.sendRedirect(req.getContextPath() + "/order-history");
                return false;
            }
        }
        return true;
    }

    private boolean validateSubmitReview(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String productIdRaw = req.getParameter("productId");
        String ratingRaw = req.getParameter("rating");
        String orderIdRaw = req.getParameter("orderId");
        
        HttpSession session = req.getSession(false);

        if (productIdRaw == null || ratingRaw == null) {
            if (session != null) session.setAttribute("orderHistoryError", "Thông tin đánh giá không đầy đủ.");
            redirectBack(req, res, orderIdRaw);
            return false;
        }

        try {
            int rating = Integer.parseInt(ratingRaw);
            if (rating < 1 || rating > 5) {
                if (session != null) session.setAttribute("orderHistoryError", "Đánh giá sao phải từ 1 đến 5.");
                redirectBack(req, res, orderIdRaw);
                return false;
            }

            // Get uploaded image parts with name "imgFiles"
            List<Part> imgParts = new ArrayList<>();
            try {
                for (Part part : req.getParts()) {
                    if ("imgFiles".equals(part.getName()) && part.getSize() > 0) {
                        imgParts.add(part);
                    }
                }
            } catch (Exception e) {
                // If the request is not multipart or getParts fails
            }

            // Validate image count (max 5)
            if (imgParts.size() > 5) {
                if (session != null) session.setAttribute("orderHistoryError", "Bạn chỉ được đăng tải tối đa 5 hình ảnh.");
                redirectBack(req, res, orderIdRaw);
                return false;
            }

            // Validate file size and format
            for (Part part : imgParts) {
                // Size validation: <= 2MB
                if (part.getSize() > 2 * 1024 * 1024) {
                    if (session != null) session.setAttribute("orderHistoryError", "Kích thước mỗi ảnh không được vượt quá 2MB.");
                    redirectBack(req, res, orderIdRaw);
                    return false;
                }

                // Type validation: must be an image
                String contentType = part.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    if (session != null) session.setAttribute("orderHistoryError", "Định dạng tệp không hợp lệ. Chỉ chấp nhận định dạng hình ảnh.");
                    redirectBack(req, res, orderIdRaw);
                    return false;
                }
            }

        } catch (NumberFormatException e) {
            if (session != null) session.setAttribute("orderHistoryError", "Thông tin đánh giá không hợp lệ.");
            redirectBack(req, res, orderIdRaw);
            return false;
        }

        return true;
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, String orderId)
            throws IOException {
        String dest = request.getContextPath() + "/order-history";
        if (orderId != null && !orderId.trim().isEmpty()) {
            dest += "?selectedOrderId=" + orderId;
        }
        response.sendRedirect(dest);
    }
}
