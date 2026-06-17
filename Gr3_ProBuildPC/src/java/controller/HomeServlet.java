package controller;

import dal.CartDAO;
import dal.CategoryDAO;
import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Category;
import model.Product;
import model.User;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home", "/Home"})
public class HomeServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        if (!allowHomeAccess(request, response)) {
            return;
        }

        String keyword = request.getParameter("keyword");
        String normalizedKeyword = keyword == null ? "" : keyword.trim();

        List<Category> categories = categoryDAO.getAllCategories();
        List<Product> products = normalizedKeyword.isEmpty()
                ? productDAO.getAllProducts("newest")
                : productDAO.searchProducts(normalizedKeyword, "newest");

        int pageSize = 12;
        String pageRaw = request.getParameter("page");
        int currentPage = 1;

        try {
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                currentPage = Integer.parseInt(pageRaw);
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }

        if (currentPage < 1) {
            currentPage = 1;
        }

        int totalProducts = products == null ? 0 : products.size();
        int totalPages = (int) Math.ceil((double) totalProducts / pageSize);

        if (totalPages == 0) {
            totalPages = 1;
        }

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        int fromIndex = (currentPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalProducts);
        List<Product> pagingProducts;

        if (products == null || products.isEmpty()) {
            pagingProducts = new java.util.ArrayList<>();
        } else {
            pagingProducts = products.subList(fromIndex, toIndex);
        }

        request.setAttribute("categories", categories);
        request.setAttribute("products", pagingProducts);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("productDAO", productDAO);
        request.setAttribute("keyword", normalizedKeyword);

        HttpSession session = request.getSession(false);
        if (session != null) {
            User account = (User) session.getAttribute("account");
            if (account != null && account.isCustomer()) {
                CartDAO cartDAO = new CartDAO();
                request.setAttribute("cartItemCount", cartDAO.getCartItemCountByCustomerId(account.getCustomerId()));
            }
        }

        request.getRequestDispatcher("/views/home.jsp").forward(request, response);
    }

    private boolean allowHomeAccess(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        if (account == null || account.isCustomer()) {
            return true;
        }

        if (account.isStaff()) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return false;
        }

        response.sendRedirect(request.getContextPath() + "/Login");
        return false;
    }
}
