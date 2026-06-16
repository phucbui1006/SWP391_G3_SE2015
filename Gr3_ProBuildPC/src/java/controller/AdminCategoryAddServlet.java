package controller;

import dal.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminCategoryAddServlet", urlPatterns = {"/admin/category/add"})
public class AdminCategoryAddServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        request.getRequestDispatcher("/views/category-add.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String categoryName = normalizeText(request.getParameter("categoryName"));

        // BE Validation: check category name length
        if (categoryName == null || categoryName.length() < 2 || categoryName.length() > 100) {
            request.setAttribute("error", "Tên danh mục phải từ 2 đến 100 ký tự.");
            request.setAttribute("categoryName", categoryName);
            request.getRequestDispatcher("/views/category-add.jsp").forward(request, response);
            return;
        }

        // Add Category
        if (!categoryDAO.addCategory(categoryName)) {
            request.setAttribute("error", "Không thể thêm danh mục. Tên có thể đã tồn tại.");
            request.setAttribute("categoryName", categoryName);
            request.getRequestDispatcher("/views/category-add.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }

    private String normalizeText(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }
}
