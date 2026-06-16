package controller;

import dal.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.Category;

@WebServlet(name = "AdminCategoryEditServlet", urlPatterns = {"/admin/category/edit"})
public class AdminCategoryEditServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

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

        request.setAttribute("category", category);
        request.getRequestDispatcher("/views/category-edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        Integer categoryId = parseId(request.getParameter("categoryId"));
        String categoryName = normalizeText(request.getParameter("categoryName"));
        String status = normalizeText(request.getParameter("status"));

        if (categoryId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        // BE Validation: check category name length
        if (categoryName == null || categoryName.length() < 2 || categoryName.length() > 100) {
            request.setAttribute("error", "Tên danh mục phải từ 2 đến 100 ký tự.");
            reloadForm(request, response, categoryId);
            return;
        }

        // BE Validation: check status
        if (status == null || (!"ACTIVE".equalsIgnoreCase(status) && !"INACTIVE".equalsIgnoreCase(status))) {
            request.setAttribute("error", "Trạng thái không hợp lệ.");
            reloadForm(request, response, categoryId);
            return;
        }

        status = status.toUpperCase();

        // Update category name
        if (!categoryDAO.updateCategoryName(categoryId, categoryName)) {
            request.setAttribute("error", "Không thể cập nhật danh mục. Tên có thể đã tồn tại.");
            reloadForm(request, response, categoryId);
            return;
        }

        // Update category status
        categoryDAO.updateCategoryStatus(categoryId, status);

        response.sendRedirect(request.getContextPath() + "/admin/category/detail?id=" + categoryId);
    }

    private void reloadForm(HttpServletRequest request, HttpServletResponse response, Integer categoryId)
            throws ServletException, IOException {

        Category category = null;
        if (categoryId != null) {
            category = categoryDAO.getCategoryById(categoryId);
        }

        if (category == null) {
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        String categoryName = normalizeText(request.getParameter("categoryName"));
        if (categoryName != null) {
            category.setCategoryName(categoryName);
        }

        String status = normalizeText(request.getParameter("status"));
        if (status != null) {
            category.setStatus(status.toUpperCase());
        }

        request.setAttribute("category", category);
        request.getRequestDispatcher("/views/category-edit.jsp").forward(request, response);
    }

    private Integer parseId(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalizeText(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        return value.trim();
    }
}
