package controller;

import dal.CategoryDAO;
import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.Category;

@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
public class AdminCategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String keyword = request.getParameter("keyword");
        String sort = request.getParameter("sort");
        String pageRaw = request.getParameter("page");

        if (keyword == null) {
            keyword = "";
        } else {
            keyword = keyword.trim();
        }

        if (sort == null || sort.trim().isEmpty()) {
            sort = "newest";
        }

        int currentPage = 1;

        try {
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                currentPage = Integer.parseInt(pageRaw);
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }

        int totalCategories = categoryDAO.countCategories(keyword);

        int totalPages;
        if (totalCategories == 0) {
            totalPages = 1;
        } else {
            totalPages = (int) Math.ceil((double) totalCategories / PAGE_SIZE);
        }

        if (currentPage < 1) {
            currentPage = 1;
        }

        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        List<Category> categories = categoryDAO.getCategories(keyword, sort, currentPage, PAGE_SIZE);

        int startItem;
        int endItem;

        if (totalCategories == 0) {
            startItem = 0;
            endItem = 0;
        } else {
            startItem = (currentPage - 1) * PAGE_SIZE + 1;
            endItem = Math.min(currentPage * PAGE_SIZE, totalCategories);
        }

        request.setAttribute("categories", categories);
        request.setAttribute("keyword", keyword);
        request.setAttribute("sort", sort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCategories", totalCategories);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);

        request.getRequestDispatcher("/views/category-list.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        String categoryIdRaw = request.getParameter("categoryId");
        String action = request.getParameter("action");

        try {
            int categoryId = Integer.parseInt(categoryIdRaw);

            if ("delete".equalsIgnoreCase(action)) {
                categoryDAO.updateCategoryStatus(categoryId, "INACTIVE");
            } else if ("activate".equalsIgnoreCase(action)) {
                categoryDAO.updateCategoryStatus(categoryId, "ACTIVE");
            }

        } catch (Exception e) {
        }

        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }
}