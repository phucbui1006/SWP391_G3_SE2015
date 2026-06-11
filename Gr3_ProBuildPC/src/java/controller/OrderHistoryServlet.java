package controller;

import dal.OrderHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import model.OrderHistoryItem;
import model.OrderStatus;
import model.User;

@WebServlet(name = "OrderHistoryServlet", urlPatterns = {"/order-history", "/OrderHistory"})
public class OrderHistoryServlet extends HttpServlet {

    private static final int PAGE_SIZE = 5;
    private static final String VIEW_PATH = "/views/order-history.jsp";
    private static final String SUCCESS_FLASH = "orderHistorySuccess";
    private static final String ERROR_FLASH = "orderHistoryError";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = requireOrderAccess(request, response);
        if (account == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String keyword = normalizeText(request.getParameter("keyword"));
        Integer selectedStatusId = parsePositiveInteger(request.getParameter("statusId"));
        int page = parsePositiveInt(request.getParameter("page"), 1);
        Integer customerUserId = account.isCustomer() ? account.getUserId() : null;

        OrderHistoryDAO orderHistoryDAO = new OrderHistoryDAO();
        int totalOrders = orderHistoryDAO.countOrders(customerUserId, keyword, selectedStatusId);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<OrderHistoryItem> orders = orderHistoryDAO.getOrders(customerUserId, keyword, selectedStatusId, page, PAGE_SIZE);
        OrderHistoryItem selectedOrder = resolveSelectedOrder(
                orderHistoryDAO,
                orders,
                parsePositiveInteger(request.getParameter("selectedOrderId")),
                customerUserId
        );

        List<OrderStatus> statusOptions = orderHistoryDAO.getOrderStatuses();
        HttpSession session = request.getSession(false);
        moveFlashToRequest(session, request, SUCCESS_FLASH, "success");
        moveFlashToRequest(session, request, ERROR_FLASH, "error");

        request.setAttribute("orders", orders);
        request.setAttribute("selectedOrder", selectedOrder);
        request.setAttribute("statusOptions", statusOptions);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatusId", selectedStatusId);
        request.setAttribute("page", page);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalOrders", totalOrders);
        request.setAttribute("canManageShipment", canManageShipment(account));
        request.setAttribute("isCustomerView", account.isCustomer());

        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User account = requireOrderAccess(request, response);
        if (account == null) {
            return;
        }

        HttpSession session = request.getSession();
        String action = normalizeText(request.getParameter("action"));
        Integer orderId = parsePositiveInteger(request.getParameter("orderId"));

        if ("cancelOrder".equals(action)) {
            handleCancelOrder(request, response, session, account, orderId);
            return;
        }

        if (!canManageShipment(account)) {
            session.setAttribute(ERROR_FLASH, "Tai khoan khong co quyen cap nhat trang thai giao hang.");
            response.sendRedirect(request.getContextPath() + "/order-history" + buildQueryString(request, null));
            return;
        }

        if (!"updateShipmentStatus".equals(action) || orderId == null) {
            session.setAttribute(ERROR_FLASH, "Thao tac cap nhat khong hop le.");
            response.sendRedirect(request.getContextPath() + "/order-history" + buildQueryString(request, orderId));
            return;
        }

        Integer shipmentStatusId = parsePositiveInteger(request.getParameter("shipmentStatusId"));
        if (shipmentStatusId == null) {
            session.setAttribute(ERROR_FLASH, "Trang thai giao hang khong hop le.");
            response.sendRedirect(request.getContextPath() + "/order-history" + buildQueryString(request, orderId));
            return;
        }

        OrderHistoryDAO orderHistoryDAO = new OrderHistoryDAO();
        if (orderHistoryDAO.updateShipmentStatus(orderId, shipmentStatusId)) {
            session.setAttribute(SUCCESS_FLASH, "Cap nhat trang thai giao hang thanh cong.");
        } else {
            session.setAttribute(ERROR_FLASH, "Khong the cap nhat trang thai giao hang.");
        }

        response.sendRedirect(request.getContextPath() + "/order-history" + buildQueryString(request, orderId));
    }

    private void handleCancelOrder(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session,
            User account,
            Integer orderId) throws IOException {
        if (!account.isCustomer()) {
            session.setAttribute(ERROR_FLASH, "Chi khach hang moi co the huy don hang cua minh.");
            response.sendRedirect(request.getContextPath() + "/order-history" + buildQueryString(request, orderId));
            return;
        }

        if (orderId == null) {
            session.setAttribute(ERROR_FLASH, "Don hang can huy khong hop le.");
            response.sendRedirect(request.getContextPath() + "/order-history" + buildQueryString(request, null));
            return;
        }

        OrderHistoryDAO orderHistoryDAO = new OrderHistoryDAO();
        boolean cancelled = orderHistoryDAO.cancelWaitingOrder(orderId, account.getCustomerId());
        if (cancelled) {
            session.setAttribute(SUCCESS_FLASH, "Da huy don hang thanh cong.");
        } else {
            session.setAttribute(ERROR_FLASH, "Chi co the huy don hang dang o trang thai Cho xac nhan.");
        }

        response.sendRedirect(request.getContextPath() + "/order-history" + buildQueryString(request, orderId));
    }

    private OrderHistoryItem resolveSelectedOrder(
            OrderHistoryDAO orderHistoryDAO,
            List<OrderHistoryItem> orders,
            Integer selectedOrderId,
            Integer customerUserId) {
        if (selectedOrderId != null) {
            for (OrderHistoryItem order : orders) {
                if (order.getOrderId() == selectedOrderId) {
                    return order;
                }
            }

            OrderHistoryItem order = orderHistoryDAO.getOrderById(selectedOrderId, customerUserId);
            if (order != null) {
                return order;
            }
        }

        return orders.isEmpty() ? null : orders.get(0);
    }

    private User requireOrderAccess(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return null;
        }

        if (account.isCustomer() || isAdmin(account) || isShipment(account)) {
            return account;
        }

        response.sendRedirect(request.getContextPath() + "/Dashboard");
        return null;
    }

    private boolean canManageShipment(User account) {
        return isShipment(account);
    }

    private boolean isAdmin(User account) {
        return hasRole(account, "ADMIN");
    }

    private boolean isShipment(User account) {
        return hasRole(account, "SHIPMENT");
    }

    private boolean hasRole(User account, String expectedRole) {
        if (account == null || account.getRoleName() == null) {
            return false;
        }

        return expectedRole.equals(account.getRoleName().trim().toUpperCase());
    }

    private void moveFlashToRequest(HttpSession session, HttpServletRequest request, String sessionKey, String requestKey) {
        if (session == null) {
            return;
        }

        Object value = session.getAttribute(sessionKey);
        if (value != null) {
            request.setAttribute(requestKey, value);
            session.removeAttribute(sessionKey);
        }
    }

    private String buildQueryString(HttpServletRequest request, Integer selectedOrderId) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", normalizeText(request.getParameter("keyword")));
        appendQueryParam(query, "statusId", normalizeText(request.getParameter("filterStatusId")));
        appendQueryParam(query, "page", normalizeText(request.getParameter("page")));

        if (selectedOrderId != null) {
            appendQueryParam(query, "selectedOrderId", String.valueOf(selectedOrderId));
        }

        return query.length() == 0 ? "" : "?" + query;
    }

    private void appendQueryParam(StringBuilder query, String name, String value) {
        if (value == null || value.trim().isEmpty()) {
            return;
        }

        if (query.length() > 0) {
            query.append("&");
        }

        query.append(name)
                .append("=")
                .append(URLEncoder.encode(value.trim(), StandardCharsets.UTF_8));
    }

    private Integer parsePositiveInteger(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private int parsePositiveInt(String value, int defaultValue) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String normalizeText(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        return value.trim();
    }
}
