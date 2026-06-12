package controller;

import dal.OrderHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.OrderHistoryItem;
import model.OrderStatus;
import model.User;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/Dashboard"})
public class DashboardServlet extends HttpServlet {

    private static final int SHIPMENT_PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        User user = (User) session.getAttribute("account");

        if (user.getRoleName() == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        if (user.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if (hasRole(user, "SHIPMENT")) {
            prepareShipmentDashboard(request);
        }

        request.getRequestDispatcher("/views/dashboard.jsp").forward(request, response);
    }

    private void prepareShipmentDashboard(HttpServletRequest request) {
        Integer selectedStatusId = parsePositiveInteger(request.getParameter("statusId"));
        int page = parsePositiveInt(request.getParameter("page"), 1);

        OrderHistoryDAO orderHistoryDAO = new OrderHistoryDAO();
        List<OrderStatus> statusOptions = orderHistoryDAO.getOrderStatuses();

        int totalOrders = orderHistoryDAO.countOrders(null, null, selectedStatusId, false, false);
        int totalPages = Math.max(1, (int) Math.ceil(totalOrders / (double) SHIPMENT_PAGE_SIZE));
        if (page > totalPages) {
            page = totalPages;
        }

        List<OrderHistoryItem> shipmentOrders = orderHistoryDAO.getOrders(
                null,
                null,
                selectedStatusId,
                page,
                SHIPMENT_PAGE_SIZE,
                false,
                false
        );

        Map<Integer, Integer> shipmentStatusCounts = new LinkedHashMap<>();
        int allActiveOrders = orderHistoryDAO.countOrders(null, null, null, false, false);
        for (OrderStatus status : statusOptions) {
            shipmentStatusCounts.put(
                    status.getStatusId(),
                    orderHistoryDAO.countOrders(null, null, status.getStatusId(), false, false)
            );
        }

        request.setAttribute("shipmentOrders", shipmentOrders);
        request.setAttribute("shipmentStatusOptions", statusOptions);
        request.setAttribute("shipmentStatusCounts", shipmentStatusCounts);
        request.setAttribute("shipmentAllActiveCount", allActiveOrders);
        request.setAttribute("shipmentSelectedStatusId", selectedStatusId);
        request.setAttribute("shipmentPage", page);
        request.setAttribute("shipmentTotalPages", totalPages);
        request.setAttribute("shipmentTotalOrders", totalOrders);
    }

    private boolean hasRole(User user, String expectedRole) {
        return user != null
                && user.getRoleName() != null
                && expectedRole.equals(user.getRoleName().trim().toUpperCase());
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
