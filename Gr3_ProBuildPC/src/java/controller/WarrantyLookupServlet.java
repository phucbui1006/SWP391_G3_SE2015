package controller;

import dal.CartDAO;
import dal.WarrantyDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;
import model.Warranty;
import java.util.List;

@WebServlet(name = "WarrantyLookupServlet", urlPatterns = {"/warranty-lookup", "/WarrantyLookup"})
public class WarrantyLookupServlet extends HttpServlet {

    private final WarrantyDAO warrantyDAO = new WarrantyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        if (!account.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return;
        }

        loadCartCount(request, session, account);

        String orderIdInput = normalizeText(request.getParameter("orderId"));

        if (!orderIdInput.isEmpty()) {
            Integer orderId = parseOrderId(orderIdInput);

            if (orderId == null) {
                request.setAttribute(
                        "warrantyLookupError",
                        "Mã đơn hàng không hợp lệ. Vui lòng nhập số order ID trong hệ thống."
                );
            } else {
                List<Warranty> result = warrantyDAO.getWarrantyInfoByOrderId(
                        orderId,
                        account.getCustomerId()
                );

                if (result == null || result.isEmpty()) {
                    request.setAttribute(
                            "warrantyLookupError",
                            "Không tìm thấy đơn hàng thuộc tài khoản của bạn."
                    );
                } else {
                    request.setAttribute("warrantyItems", result);
                }
            }
        }

        request.setAttribute("orderIdInput", orderIdInput);
        request.getRequestDispatcher("/views/warranty-lookup.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        if (!account.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return;
        }

        String action = normalizeText(request.getParameter("action"));
        String orderIdRaw = normalizeText(request.getParameter("orderId"));
        Integer orderId = parseOrderId(orderIdRaw);

        if (!"createRequest".equals(action)) {
            session.setAttribute("warrantyFailMessage", "Hành động không hợp lệ.");
            redirectBack(response, request, orderId);
            return;
        }

        try {
            int productId = Integer.parseInt(request.getParameter("productId"));
            String requestReason = normalizeText(request.getParameter("request"));

            if (requestReason.isEmpty()) {
                session.setAttribute("warrantyFailMessage", "Vui lòng nhập lý do bảo hành.");
                redirectBack(response, request, orderId);
                return;
            }

            WarrantyDAO warrantyDAO = new WarrantyDAO();

            if (orderId == null) {
                session.setAttribute("warrantyFailMessage", "Mã đơn hàng không hợp lệ.");
                redirectBack(response, request, orderId);
                return;
            }
            String orderStatus = warrantyDAO.getOrderStatus(orderId, account.getCustomerId());
            if (orderStatus == null || !"Đã giao hàng".equalsIgnoreCase(orderStatus.trim())) {
                session.setAttribute(
                        "warrantyFailMessage",
                        "Chỉ áp dụng bảo hành cho đơn hàng đã giao hàng thành công."
                );
                redirectBack(response, request, orderId);
                return;
            }

            boolean valid = warrantyDAO.isWarrantyRequestValid(
                    account.getCustomerId(),
                    orderId,
                    productId
            );

            if (!valid) {
                session.setAttribute(
                        "warrantyFailMessage",
                        "Sản phẩm đã hết hạn bảo hành hoặc thông tin không hợp lệ."
                );
                redirectBack(response, request, orderId);
                return;
            }

            if (warrantyDAO.hasPendingWarrantyRequest(account.getCustomerId(), orderId, productId)) {
                session.setAttribute(
                        "warrantyFailMessage",
                        "Sản phẩm này đã có yêu cầu bảo hành ở trạng thái Chờ tiếp nhận."
                );
                redirectBack(response, request, orderId);
                return;
            }

            Warranty warranty = new Warranty();
            warranty.setCustomerId(account.getCustomerId());
            warranty.setOrderId(orderId);
            warranty.setProductId(productId);
            warranty.setStatusId(1);
            warranty.setRequestDate(new java.util.Date());
            warranty.setRequest(requestReason);

            boolean success = warrantyDAO.createWarrantyRequest(warranty);

            if (success) {
                session.setAttribute(
                        "warrantySuccessMessage",
                        "Gửi yêu cầu bảo hành thành công! Chúng tôi sẽ liên hệ lại sớm nhất."
                );
            } else {
                session.setAttribute(
                        "warrantyFailMessage",
                        "Gửi yêu cầu bảo hành thất bại. Vui lòng thử lại sau."
                );
            }

        } catch (NumberFormatException e) {
            session.setAttribute("warrantyFailMessage", "Tham số không hợp lệ.");
        }

        redirectBack(response, request, orderId);
    }

    private void loadCartCount(HttpServletRequest request, HttpSession session, User account) {
        CartDAO cartDAO = new CartDAO();
        int cartItemCount = cartDAO.getCartItemCountByCustomerId(account.getCustomerId());

        request.setAttribute("cartItemCount", cartItemCount);
        session.setAttribute("sessionCartItemCount", cartItemCount);
    }

    private void redirectBack(HttpServletResponse response, HttpServletRequest request, Integer orderId)
            throws IOException {

        String url = request.getContextPath() + "/warranty-lookup";

        if (orderId != null) {
            url += "?orderId=" + orderId;
        }

        response.sendRedirect(url);
    }

    private String normalizeText(String value) {
        return value == null ? "" : value.trim();
    }

    private Integer parseOrderId(String value) {
        String digits = value == null ? "" : value.trim();

        if (digits.isEmpty() || !digits.matches("[0-9]+")) {
            return null;
        }

        try {
            long parsedValue = Long.parseLong(digits);

            if (parsedValue <= 0 || parsedValue > Integer.MAX_VALUE) {
                return null;
            }

            return (int) parsedValue;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
