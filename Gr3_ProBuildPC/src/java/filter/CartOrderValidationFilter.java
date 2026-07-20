package filter;

import dal.AddressDAO;
import dal.CartDAO;
import dal.ProductDAO;
import dal.OrderHistoryDAO;
import model.Address;
import model.CartItem;
import model.Product;
import model.User;
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
import java.util.Map;
import util.ValidatorUtil;

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
        } else if ("/checkout".equalsIgnoreCase(path)) {
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

    private boolean validateItems(HttpServletRequest req, HttpServletResponse res, User account) throws IOException {
        boolean buildCheckout = "build".equalsIgnoreCase(req.getParameter("checkoutMode"));
        String[] selectedCartItemIdsRaw = req.getParameterValues("selectedCartItemIds");
        List<Integer> selectedCartItemIds = new ArrayList<>();
        if (selectedCartItemIdsRaw != null) {
            for (String val : selectedCartItemIdsRaw) {
                try {
                    int parsed = Integer.parseInt(val);
                    if (parsed > 0) selectedCartItemIds.add(parsed);
                } catch (NumberFormatException e) {}
            }
        }

        List<CartItem> checkoutItems = new ArrayList<>();

        if (buildCheckout) {
            Object snapshot = req.getSession().getAttribute("buildCheckoutItems");
            if (snapshot instanceof Map<?, ?>) {
                ProductDAO productDAO = new ProductDAO();
                for (Map.Entry<?, ?> entry : ((Map<?, ?>) snapshot).entrySet()) {
                    if (!(entry.getKey() instanceof Integer) || !(entry.getValue() instanceof Integer)) {
                        continue;
                    }

                    int productId = (Integer) entry.getKey();
                    int quantity = (Integer) entry.getValue();
                    Product product = productDAO.getProductById(productId);
                    if (product == null || quantity <= 0 || quantity > product.getQuantity()) {
                        return redirectBuildError(req, res,
                                "Số lượng hoặc tồn kho của cấu hình đã thay đổi. Vui lòng kiểm tra lại.");
                    }

                    CartItem item = new CartItem();
                    item.setProductId(productId);
                    item.setQuantity(quantity);
                    item.setProduct(product);
                    checkoutItems.add(item);
                }
            }
        } else if (!selectedCartItemIds.isEmpty()) {
            CartDAO cartDAO = new CartDAO();
            List<CartItem> allCartItems = cartDAO.getCartItemsByCustomerId(account.getCustomerId());
            java.util.Set<Integer> selectedIdSet = new java.util.LinkedHashSet<>(selectedCartItemIds);

            for (CartItem item : allCartItems) {
                if (selectedIdSet.contains(item.getCartItemId())) {
                    checkoutItems.add(item);
                }
            }
        } else {
            String productIdRaw = req.getParameter("productId");
            String quantityRaw = req.getParameter("quantity");
            Integer productId = null;
            if (productIdRaw != null) {
                try {
                    productId = Integer.parseInt(productIdRaw);
                } catch (NumberFormatException e) {}
            }

            if (productId != null && productId > 0) {
                String quantityError = ValidatorUtil.getPurchaseQuantityError(quantityRaw);
                if (quantityError != null) {
                    redirectToProductDetailWithQuantityError(
                            req, res, productId, quantityRaw, quantityError
                    );
                    return false;
                }

                int quantity = ValidatorUtil.parsePurchaseQuantity(quantityRaw);
                ProductDAO productDAO = new ProductDAO();
                Product product = productDAO.getProductById(productId);

                if (product != null && product.getQuantity() > 0) {
                    String stockError = ValidatorUtil.getPurchaseStockError(
                            quantity, product.getQuantity()
                    );
                    if (stockError != null) {
                        redirectToProductDetailWithQuantityError(
                                req, res, productId, quantityRaw, stockError
                        );
                        return false;
                    }

                    CartItem directItem = new CartItem();
                    directItem.setProductId(productId);
                    directItem.setQuantity(quantity);
                    directItem.setProduct(product);
                    checkoutItems.add(directItem);
                }
            }
        }

        if (checkoutItems.isEmpty()) {
            if (buildCheckout) {
                return redirectBuildError(req, res, "Không tìm thấy cấu hình để thanh toán.");
            }
            req.getSession().setAttribute("cartErrorMsg", "Không tìm thấy sản phẩm để thanh toán.");
            res.sendRedirect(req.getContextPath() + "/cart");
            return false;
        }

        for (CartItem item : checkoutItems) {
            Product product = item.getProduct();
            if (product == null || !product.isAvailableForSale()) {
                if (buildCheckout) {
                    return redirectBuildError(req, res, "Một linh kiện trong cấu hình hiện không còn kinh doanh.");
                }
                req.getSession().setAttribute("cartErrorMsg", "Sản phẩm hiện không còn kinh doanh.");
                res.sendRedirect(req.getContextPath() + "/cart");
                return false;
            }
        }

        return true;
    }

    private boolean redirectBuildError(HttpServletRequest req, HttpServletResponse res, String message)
            throws IOException {
        HttpSession session = req.getSession();
        session.setAttribute("buildPcMessage", message);
        session.setAttribute("buildPcMessageType", "error");
        res.sendRedirect(req.getContextPath() + "/build-pc");
        return false;
    }

    private void redirectToProductDetailWithQuantityError(
            HttpServletRequest request,
            HttpServletResponse response,
            int productId,
            String quantityRaw,
            String message) throws IOException {
        HttpSession session = request.getSession();
        session.setAttribute("productDetailQuantityError", message);

        Integer quantity = ValidatorUtil.parsePurchaseQuantity(quantityRaw);
        if (quantity != null) {
            session.setAttribute("productDetailQuantityValue", String.valueOf(quantity));
        }

        response.sendRedirect(
                request.getContextPath() + "/product-detail?id=" + productId
        );
    }

    private boolean validateCheckout(HttpServletRequest req, HttpServletResponse res) throws IOException, ServletException {
        HttpSession session = req.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;
        if (account == null || !account.isCustomer()) {
            res.sendRedirect(req.getContextPath() + "/Login");
            return false;
        }

        // Validate items first (both GET and POST need valid items)
        if (!validateItems(req, res, account)) {
            return false;
        }

        String action = req.getParameter("action");
        if ("placeOrder".equalsIgnoreCase(action) && "POST".equalsIgnoreCase(req.getMethod())) {
            // 1. Validate note
            String note = util.ValidatorUtil.safeTrimAndClean(req.getParameter("note"));
            if (!util.ValidatorUtil.isValidNote(note)) {
                req.setAttribute("errorMsg", "Ghi chú không hợp lệ (tối đa 1000 ký tự) hoặc chứa ký tự đặc biệt.");
                req.getRequestDispatcher("/checkout").forward(req, res);
                return false;
            }

            // 2. Validate address
            AddressDAO addressDAO = new AddressDAO();
            List<Address> savedAddresses = addressDAO.getAddressesByCustomerId(account.getCustomerId());
            String selectedAddressIdRaw = req.getParameter("selectedAddressId");
            Integer selectedAddressId = null;
            if (selectedAddressIdRaw != null) {
                try {
                    selectedAddressId = Integer.parseInt(selectedAddressIdRaw);
                } catch (NumberFormatException e) {}
            }

            Address selectedAddress = null;
            if (selectedAddressId != null) {
                for (Address addr : savedAddresses) {
                    if (addr.getAddressId() == selectedAddressId) {
                        selectedAddress = addr;
                        break;
                    }
                }
            }

            if (selectedAddress == null) {
                req.setAttribute("errorMsg", "Vui lòng chọn địa chỉ giao hàng hợp lệ.");
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
            if (keyword != null && !keyword.trim().isEmpty() && !util.ValidatorUtil.isValidOrderSearchQuery(keyword)) {
                HttpSession session = req.getSession(false);
                if (session != null) {
                    session.setAttribute("orderHistoryError", "Từ khóa tìm kiếm không hợp lệ (quá dài hoặc chứa ký tự đặc biệt).");
                }
                res.sendRedirect(req.getContextPath() + "/order-history");
                return false;
            }
        } else if ("POST".equalsIgnoreCase(req.getMethod())) {
            HttpSession session = req.getSession(false);
            User account = session != null ? (User) session.getAttribute("account") : null;
            if (account == null) {
                res.sendRedirect(req.getContextPath() + "/Login");
                return false;
            }

            String action = req.getParameter("action");
            String orderIdRaw = req.getParameter("orderId");
            Integer orderId = null;
            if (orderIdRaw != null) {
                try {
                    orderId = Integer.parseInt(orderIdRaw);
                } catch (NumberFormatException e) {}
            }

            if ("cancelOrder".equals(action)) {
                if (!account.isCustomer()) {
                    session.setAttribute("orderHistoryError", "Chỉ khách hàng mới có thể hủy đơn hàng của mình.");
                    res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, orderId));
                    return false;
                }
                if (orderId == null || orderId <= 0) {
                    session.setAttribute("orderHistoryError", "Đơn hàng cần hủy không hợp lệ.");
                    res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, null));
                    return false;
                }
            } else if ("updateShipmentStatus".equals(action)) {
                // Check authorization
                boolean isShipper = "SHIPMENT".equals(account.getRoleName());
                boolean isEmployee = account.isStaff() && !"SHIPMENT".equals(account.getRoleName()) && !"ADMIN".equals(account.getRoleName());
                boolean isAdmin = "ADMIN".equals(account.getRoleName());
                boolean canManage = isShipper || isEmployee || isAdmin;
                if (!canManage) {
                    session.setAttribute("orderHistoryError", "Tài khoản không có quyền cập nhật trạng thái giao hàng.");
                    res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, null));
                    return false;
                }

                if (orderId == null || orderId <= 0) {
                    session.setAttribute("orderHistoryError", "Thao tác cập nhật không hợp lệ.");
                    res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, orderId));
                    return false;
                }

                String shipmentStatusIdRaw = req.getParameter("shipmentStatusId");
                Integer shipmentStatusId = null;
                try {
                    shipmentStatusId = Integer.parseInt(shipmentStatusIdRaw);
                } catch (NumberFormatException e) {}

                if (shipmentStatusId == null || shipmentStatusId <= 0) {
                    session.setAttribute("orderHistoryError", "Trạng thái giao hàng không hợp lệ.");
                    res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, orderId));
                    return false;
                }

                // Check Shipper updates: Shipper can only update to 4, 5, 7
                if (isShipper) {
                    if (shipmentStatusId != 4 && shipmentStatusId != 5 && shipmentStatusId != 7) {
                        session.setAttribute("orderHistoryError", "Shipper chỉ được phép cập nhật thành: Đang giao hàng, Đã giao hàng, hoặc Giao hàng thất bại.");
                        res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, orderId));
                        return false;
                    }
                }

                // Check Employee updates: Employee can only update when current state is 7 (Giao hàng thất bại), and status to 2 or 6
                if (isEmployee) {
                    OrderHistoryDAO orderHistoryDAO = new OrderHistoryDAO();
                    String currentStatusName = orderHistoryDAO.findCurrentOrderStatusName(orderId);
                    if (currentStatusName == null || !currentStatusName.trim().equalsIgnoreCase("Giao hàng thất bại")) {
                        session.setAttribute("orderHistoryError", "Nhân viên chỉ được phép cập nhật đơn hàng khi trạng thái hiện tại là Giao hàng thất bại.");
                        res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, orderId));
                        return false;
                    }
                    if (shipmentStatusId != 2 && shipmentStatusId != 6) {
                        session.setAttribute("orderHistoryError", "Nhân viên chỉ được phép cập nhật sang Đã xác nhận hoặc Đã hủy.");
                        res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, orderId));
                        return false;
                    }
                }

                String deliveryName = req.getParameter("deliveryName");
                String deliveryPhone = req.getParameter("deliveryPhone");
                if (deliveryName == null || deliveryName.trim().isEmpty() || deliveryPhone == null || deliveryPhone.trim().isEmpty()) {
                    session.setAttribute("orderHistoryError", "Vui lòng nhập tên và số điện thoại người giao hàng.");
                    res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, orderId));
                    return false;
                }

                if (!deliveryPhone.trim().matches("^(0[35789])[0-9]{8}$")) {
                    session.setAttribute("orderHistoryError", "Số điện thoại không hợp lệ (phải là mạng di động, bắt đầu bằng 03, 05, 07, 08, 09 và có 10 chữ số).");
                    res.sendRedirect(req.getContextPath() + "/order-history" + buildRedirectQueryString(req, orderId));
                    return false;
                }
            }
        }
        return true;
    }

    private String buildRedirectQueryString(HttpServletRequest request, Integer selectedOrderId) {
        StringBuilder query = new StringBuilder();
        String keyword = request.getParameter("keyword");
        if (keyword != null && !keyword.trim().isEmpty()) {
            query.append("keyword=").append(java.net.URLEncoder.encode(keyword.trim(), java.nio.charset.StandardCharsets.UTF_8));
        }
        String statusId = request.getParameter("filterStatusId");
        if (statusId != null && !statusId.trim().isEmpty()) {
            if (query.length() > 0) query.append("&");
            query.append("statusId=").append(java.net.URLEncoder.encode(statusId.trim(), java.nio.charset.StandardCharsets.UTF_8));
        }
        String page = request.getParameter("page");
        if (page != null && !page.trim().isEmpty()) {
            if (query.length() > 0) query.append("&");
            query.append("page=").append(java.net.URLEncoder.encode(page.trim(), java.nio.charset.StandardCharsets.UTF_8));
        }
        String deliveryHistory = request.getParameter("deliveryHistory");
        if (deliveryHistory != null && !deliveryHistory.trim().isEmpty()) {
            if (query.length() > 0) query.append("&");
            query.append("deliveryHistory=").append(java.net.URLEncoder.encode(deliveryHistory.trim(), java.nio.charset.StandardCharsets.UTF_8));
        }
        if (selectedOrderId != null) {
            if (query.length() > 0) query.append("&");
            query.append("selectedOrderId=").append(selectedOrderId);
        }
        return query.length() == 0 ? "" : "?" + query.toString();
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
