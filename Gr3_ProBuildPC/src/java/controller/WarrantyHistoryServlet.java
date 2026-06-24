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
        
        // Securely parse the logged-in customer's ID from session.
        Integer customerId = (Integer) session.getAttribute("userId");
        if (customerId == null) {
            User account = (User) session.getAttribute("account");
            if (account != null) {
                customerId = account.getCustomerId();
            }
        }

        // If null, handle clean fallback redirect.
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        // Load cart count for header compatibility
        CartDAO cartDAO = new CartDAO();
        int cartItemCount = cartDAO.getCartItemCountByCustomerId(customerId);
        request.setAttribute("cartItemCount", cartItemCount);
        session.setAttribute("sessionCartItemCount", cartItemCount);

        // Read search and status query parameters
        String search = request.getParameter("search");
        if (search == null) {
            search = request.getParameter("searchProduct");
        }
        
        String statusRaw = request.getParameter("status");
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

        // Call the active DAL method
        List<WarrantyRequest> list = warrantyDAO.getWarrantyRequestsByCustomerId(
                customerId, 
                search, 
                statusId
        );

        // Bind the output list using request-scope binding explicitly
        request.setAttribute("clientWarrantyList", list);
        request.setAttribute("warrantyList", list); // keep original name for JSP compat
        request.setAttribute("searchProduct", search != null ? search.trim() : "");
        request.setAttribute("filterStatusId", statusId);

        // Forward smoothly to the client history view page
        request.getRequestDispatcher("/views/warranty-history.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
