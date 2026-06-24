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
import model.Warranty;

@WebServlet(name = "WarrantyHistoryServlet", urlPatterns = {"/warranty-history", "/WarrantyHistory"})
public class WarrantyHistoryServlet extends HttpServlet {

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

        // Load cart count for header compatibility
        CartDAO cartDAO = new CartDAO();
        int cartItemCount = cartDAO.getCartItemCountByCustomerId(account.getCustomerId());
        request.setAttribute("cartItemCount", cartItemCount);
        session.setAttribute("sessionCartItemCount", cartItemCount);

        String searchProduct = request.getParameter("searchProduct");
        String filterStatIdRaw = request.getParameter("filterStatusId");

        Integer filterStatusId = null;
        if (filterStatIdRaw != null && !filterStatIdRaw.trim().isEmpty()) {
            try {
                filterStatusId = Integer.parseInt(filterStatIdRaw);
            } catch (NumberFormatException e) {
                // ignore
            }
        }

        List<Warranty> warrantyList = warrantyDAO.getWarrantiesByProduct(
                account.getCustomerId(), 
                searchProduct, 
                filterStatusId
        );
        request.setAttribute("warrantyList", warrantyList);
        request.setAttribute("searchProduct", searchProduct != null ? searchProduct.trim() : "");
        request.setAttribute("filterStatusId", filterStatusId);

        request.getRequestDispatcher("/views/warranty-history.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
