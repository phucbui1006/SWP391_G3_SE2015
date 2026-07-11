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
import java.util.List;
import model.User;
import model.WarrantyRequest;

@WebServlet(name = "WarrantyHistoryServlet", urlPatterns = {"/warranty-history", "/WarrantyHistory"})
public class WarrantyHistoryServlet extends HttpServlet {

    private final WarrantyDAO warrantyDAO = new WarrantyDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        
        Integer customerId = (Integer) session.getAttribute("userId");
        if (customerId == null) {
            User account = (User) session.getAttribute("account");
            if (account != null) {
                customerId = account.getCustomerId();
            }
        }

        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        int cartItemCount = cartDAO.getCartItemCountByCustomerId(customerId);
        request.setAttribute("cartItemCount", cartItemCount);
        session.setAttribute("sessionCartItemCount", cartItemCount);

        String search = request.getParameter("search");
        if (search == null) {
            search = request.getParameter("searchProduct");
        }
        
        String parsedSearchKeyword = "";
        if (search != null && !search.trim().isEmpty()) {
            String clean = search.trim();
            // Match pattern like #WR3, WR3, #3, or 3 (case-insensitive)
            if (clean.matches("^(?i)#?(?:WR)?\\d+$")) {
                parsedSearchKeyword = clean.replaceAll("^(?i)#?(?:WR)?", "");
            } else {
                parsedSearchKeyword = clean;
            }
        }

        String statusRaw = request.getParameter("statusId");
        if (statusRaw == null) {
            statusRaw = request.getParameter("status");
        }
        if (statusRaw == null) {
            statusRaw = request.getParameter("filterStatusId");
        }

        Integer statusId = null;
        if (statusRaw != null && !statusRaw.trim().isEmpty()) {
            try {
                statusId = Integer.parseInt(statusRaw);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        List<WarrantyRequest> list = warrantyDAO.getWarrantyRequestsByCustomerId(
                customerId, 
                parsedSearchKeyword, 
                statusId
        );

        request.setAttribute("clientWarrantyList", list);
        request.setAttribute("warrantyList", list); 
        request.setAttribute("searchProduct", search != null ? search.trim() : "");
        request.setAttribute("filterStatusId", statusId);

        request.getRequestDispatcher("/views/warranty-history.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
