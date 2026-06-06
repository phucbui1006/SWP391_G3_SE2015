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
        }

        String idRaw = request.getParameter("id");

        List<Category> categories = categoryDAO.getAllCategories();
        List<Product> products;
        Category selectedCategory = null;

        if (idRaw != null && !idRaw.trim().isEmpty()) {
            try {
                int categoryId = Integer.parseInt(idRaw);

                selectedCategory = categoryDAO.getCategoryById(categoryId);

                if (keyword != null && !keyword.isEmpty()) {
                    products = productDAO.getProductsByCategoryAndKeyword(categoryId, keyword, sort);
                } else {
                    products = productDAO.getProductsByCategoryId(categoryId, sort);
                }
            } catch (NumberFormatException e) {
                if (keyword != null && !keyword.isEmpty()) {
                    products = productDAO.getProductsByKeyword(keyword, sort);
                } else {
                    products = productDAO.getAllProducts(sort);
                }
            }
        } else {
            if (keyword != null && !keyword.isEmpty()) {
                products = productDAO.getProductsByKeyword(keyword, sort);
            } else {
                products = productDAO.getAllProducts(sort);
            }
        }

        request.setAttribute("categories", categories);
        request.setAttribute("products", products);
        request.setAttribute("selectedCategory", selectedCategory);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("keyword", keyword);

        HttpSession session = request.getSession(false);
        if (session != null) {
            User account = (User) session.getAttribute("account");
            if (account != null) {
                CartDAO cartDAO = new CartDAO();
                request.setAttribute("cartItemCount", cartDAO.getCartItemCountByUserId(account.getUserId()));
            }
        }

        request.getRequestDispatcher("/views/categories.jsp").forward(request, response);
    }
}
