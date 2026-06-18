package controller;

import dal.CategoryDAO;
import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import model.Category;
import model.Product;

@WebServlet(name = "AdminCategoryDetailServlet", urlPatterns = {"/admin/category/detail"})
public class AdminCategoryDetailServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        Integer categoryId = parseId(request.getParameter("id"));
        if (categoryId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        Category category = categoryDAO.getCategoryById(categoryId);
        if (category == null) {
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        String productStatus = request.getParameter("productStatus");
        if (productStatus == null || productStatus.trim().isEmpty()) {
            productStatus = "ALL";
        } else {
            productStatus = productStatus.trim().toUpperCase();
            if (!"ACTIVE".equals(productStatus) && !"INACTIVE".equals(productStatus)) {
                productStatus = "ALL";
            }
        }

        int pageSize = 4;
        String productPageRaw = request.getParameter("productPage");
        int currentProductPage = 1;
        try {
            if (productPageRaw != null && !productPageRaw.trim().isEmpty()) {
                currentProductPage = Integer.parseInt(productPageRaw);
            }
        } catch (NumberFormatException e) {
            currentProductPage = 1;
        }
        if (currentProductPage < 1) {
            currentProductPage = 1;
        }

        List<Product> allProducts = productDAO.getProductsByCategoryIdForAdmin(categoryId, productStatus);
        int totalFilteredProducts = allProducts.size();
        int totalProductPages = (int) Math.ceil((double) totalFilteredProducts / pageSize);
        if (totalProductPages == 0) {
            totalProductPages = 1;
        }
        if (currentProductPage > totalProductPages) {
            currentProductPage = totalProductPages;
        }

        int fromIndex = (currentProductPage - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalFilteredProducts);

        List<Product> pagingProducts;
        if (allProducts.isEmpty()) {
            pagingProducts = java.util.Collections.emptyList();
        } else {
            pagingProducts = allProducts.subList(fromIndex, toIndex);
        }

        int totalProductsInCategory = productDAO.getProductsByCategoryIdForAdmin(categoryId, "ALL").size();

        request.setAttribute("category", category);
        request.setAttribute("products", pagingProducts);
        request.setAttribute("productStatus", productStatus);
        request.setAttribute("totalProductsInCategory", totalProductsInCategory);
        request.setAttribute("currentProductPage", currentProductPage);
        request.setAttribute("totalProductPages", totalProductPages);
        request.setAttribute("totalFilteredProducts", totalFilteredProducts);

        request.getRequestDispatcher("/views/category-detail.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        Integer categoryId = parseId(request.getParameter("categoryId"));
        Integer productId = parseId(request.getParameter("productId"));
        String productStatus = request.getParameter("productStatus");

        if (categoryId != null && productId != null && action != null) {
            // BE Validation: Verify if product belongs to this category before updating its status
            if (productDAO.verifyProductInCategory(productId, categoryId)) {
                if ("deleteProduct".equalsIgnoreCase(action)) {
                    productDAO.deleteProduct(productId);
                } else if ("activateProduct".equalsIgnoreCase(action)) {
                    productDAO.activateProduct(productId);
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/category/detail?id=" + categoryId + "&productStatus=" + productStatus);
    }

    private Integer parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}

