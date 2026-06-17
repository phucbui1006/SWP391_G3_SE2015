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

@WebServlet(name = "CategoryServlet", urlPatterns = {"/categories"})
public class CategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String sort = request.getParameter("sort");
        if (sort == null || sort.trim().isEmpty()) {
            sort = "newest";
        }

        String keyword = request.getParameter("keyword");
        if (keyword != null) {
            keyword = keyword.trim();
        } else {
            keyword = "";
        }

        String contentKeyword = request.getParameter("contentKeyword");
        if (contentKeyword != null) {
            contentKeyword = contentKeyword.trim();
        } else {
            contentKeyword = "";
        }

        String activeKeyword = "";
        if (!contentKeyword.isEmpty()) {
            activeKeyword = contentKeyword;
        } else if (!keyword.isEmpty()) {
            activeKeyword = keyword;
        }

        String idRaw = request.getParameter("id");

        List<Category> categories = categoryDAO.getAllCategories();
        List<Product> products;
        Category selectedCategory = null;

        if (idRaw != null && !idRaw.trim().isEmpty()) {
            try {
                int categoryId = Integer.parseInt(idRaw);
                selectedCategory = categoryDAO.getCategoryById(categoryId);

                if (!activeKeyword.isEmpty()) {
                    products = productDAO.getProductsByCategoryAndKeyword(categoryId, activeKeyword, sort);
                } else {
                    products = productDAO.getProductsByCategoryId(categoryId, sort);
                }

            } catch (NumberFormatException e) {
                selectedCategory = null;

                if (!activeKeyword.isEmpty()) {
                    products = productDAO.searchProducts(activeKeyword, sort);
                } else {
                    products = productDAO.getAllProducts(sort);
                }
            }
        } else {
            if (!activeKeyword.isEmpty()) {
                products = productDAO.searchProducts(activeKeyword, sort);
            } else {
                products = productDAO.getAllProducts(sort);
            }
        }
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
        request.setAttribute("selectedCategory", selectedCategory);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("keyword", keyword);
        request.setAttribute("contentKeyword", contentKeyword);

        HttpSession session = request.getSession(false);

        if (session != null) {
            User account = (User) session.getAttribute("account");

            if (account != null && account.isCustomer()) {
                CartDAO cartDAO = new CartDAO();
                int cartItemCount = cartDAO.getCartItemCountByCustomerId(account.getCustomerId());
                request.setAttribute("cartItemCount", cartItemCount);
            }

            String cartMessage = (String) session.getAttribute("cartMessage");
            String cartMessageType = (String) session.getAttribute("cartMessageType");

            if (cartMessage != null) {
                request.setAttribute("cartMessage", cartMessage);
                request.setAttribute("cartMessageType", cartMessageType);

                session.removeAttribute("cartMessage");
                session.removeAttribute("cartMessageType");
            }
        }

        request.getRequestDispatcher("/views/categories.jsp").forward(request, response);
    }
}
