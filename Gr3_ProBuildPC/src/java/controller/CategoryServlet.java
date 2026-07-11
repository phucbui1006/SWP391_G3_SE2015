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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
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

        String ctx = request.getContextPath();

        String sort = request.getParameter("sort");
        if (sort == null || sort.trim().isEmpty()) {
            sort = "newest";
        } else {
            sort = sort.trim();
        }

        String keyword = request.getParameter("keyword");
        if (keyword == null) {
            keyword = "";
        } else {
            keyword = keyword.trim();
        }

        String contentKeyword = request.getParameter("contentKeyword");
        if (contentKeyword == null) {
            contentKeyword = "";
        } else {
            contentKeyword = contentKeyword.trim();
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
                int categoryId = Integer.parseInt(idRaw.trim());
                selectedCategory = categoryDAO.getCategoryById(categoryId);

                if (!activeKeyword.isEmpty()) {
                    products = productDAO.getProductsByCategory(categoryId, sort, activeKeyword);
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

        if (products == null) {
            products = new ArrayList<>();
        }

        int pageSize = 12;
        int currentPage = 1;

        String pageRaw = request.getParameter("page");

        try {
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                currentPage = Integer.parseInt(pageRaw.trim());
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }

        if (currentPage < 1) {
            currentPage = 1;
        }

        int totalProducts = products.size();
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

        if (products.isEmpty()) {
            pagingProducts = new ArrayList<>();
        } else {
            pagingProducts = products.subList(fromIndex, toIndex);
        }

        String title = "Tất cả sản phẩm";
        if (selectedCategory != null) {
            title = "Danh mục: " + selectedCategory.getCategoryName();
        }

        String clearSearchUrl = ctx + "/categories?sort=" + encode(sort);

        String pagingUrl = ctx + "/categories?";

        if (selectedCategory != null) {
            pagingUrl += "id=" + selectedCategory.getCategoryId() + "&";
        }

        if (!keyword.isEmpty()) {
            pagingUrl += "keyword=" + encode(keyword) + "&";
        }

        if (!contentKeyword.isEmpty()) {
            pagingUrl += "contentKeyword=" + encode(contentKeyword) + "&";
        }

        pagingUrl += "sort=" + encode(sort) + "&page=";

        request.setAttribute("ctx", ctx);
        request.setAttribute("categories", categories);
        request.setAttribute("products", pagingProducts);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("selectedCategory", selectedCategory);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("keyword", keyword);
        request.setAttribute("contentKeyword", contentKeyword);
        request.setAttribute("searchValue", contentKeyword);
        request.setAttribute("title", title);
        request.setAttribute("clearSearchUrl", clearSearchUrl);
        request.setAttribute("pagingUrl", pagingUrl);

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

            if (cartMessageType == null) {
                cartMessageType = "success";
            }

            if (cartMessage != null) {
                request.setAttribute("cartMessage", cartMessage);
                request.setAttribute("cartMessageType", cartMessageType);

                session.removeAttribute("cartMessage");
                session.removeAttribute("cartMessageType");
            }
        }

        request.getRequestDispatcher("/views/categories.jsp").forward(request, response);
    }

    private String encode(String value) {
        if (value == null) {
            return "";
        }

        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
