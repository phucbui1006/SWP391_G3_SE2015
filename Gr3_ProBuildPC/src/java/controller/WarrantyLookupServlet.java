package controller;

import dal.CartDAO;
import dal.WarrantyLookupDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;
import model.WarrantyLookupResult;

@WebServlet(name = "WarrantyLookupServlet", urlPatterns = {"/warranty-lookup", "/WarrantyLookup"})
public class WarrantyLookupServlet extends HttpServlet {

    private final WarrantyLookupDAO warrantyLookupDAO = new WarrantyLookupDAO();

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

        CartDAO cartDAO = new CartDAO();
        int cartItemCount = cartDAO.getCartItemCountByCustomerId(account.getCustomerId());
        request.setAttribute("cartItemCount", cartItemCount);
        session.setAttribute("sessionCartItemCount", cartItemCount);

        String orderIdInput = normalizeText(request.getParameter("orderId"));
        if (!orderIdInput.isEmpty()) {
            Integer orderId = parseOrderId(orderIdInput);

            if (orderId == null) {
                request.setAttribute("warrantyLookupError", "Mã đơn hàng không hợp lệ. Vui lòng nhập số order ID trong hệ thống.");
            } else {
                WarrantyLookupResult result = warrantyLookupDAO.findByOrderIdAndCustomerId(orderId, account.getCustomerId());

                if (result == null) {
                    request.setAttribute("warrantyLookupError", "Không tìm thấy đơn hàng thuộc tài khoản của bạn.");
                } else {
                    request.setAttribute("warrantyLookupResult", result);
                }
            }
        }

        request.setAttribute("orderIdInput", orderIdInput);
        request.getRequestDispatcher("/views/warranty-lookup.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private String normalizeText(String value) {
        return value == null ? "" : value.trim();
    }

    private Integer parseOrderId(String value) {
        String digits = value == null ? "" : value.replaceAll("[^0-9]", "");

        if (digits.isEmpty()) {
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
