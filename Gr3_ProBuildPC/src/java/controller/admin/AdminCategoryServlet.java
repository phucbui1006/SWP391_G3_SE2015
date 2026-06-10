package controller.admin;

import dal.CategoryDAO;
import java.io.IOException;
import java.util.ArrayList;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Category;

@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
public class AdminCategoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String keyword = request.getParameter("keyword");
        String sort = request.getParameter("sort");

        if (sort == null || sort.isEmpty()) {
            sort = "newest";
        }

        int page = 1;
        int pageSize = 8;

        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }
        } catch (Exception e) {
            page = 1;
        }

        CategoryDAO dao = new CategoryDAO();

        int totalCategories = dao.countCategories(keyword);
        int totalPages = (int) Math.ceil((double) totalCategories / pageSize);

        if (totalPages == 0) {
            totalPages = 1;
        }

        if (page < 1) {
            page = 1;
        }

        if (page > totalPages) {
            page = totalPages;
        }

        ArrayList<Category> categories = dao.getCategories(keyword, sort, page, pageSize);

        int startItem = totalCategories == 0 ? 0 : (page - 1) * pageSize + 1;
        int endItem = Math.min(page * pageSize, totalCategories);

        request.setAttribute("categories", categories);
        request.setAttribute("keyword", keyword);
        request.setAttribute("sort", sort);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCategories", totalCategories);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);

        request.getRequestDispatcher("/views/category-list.jsp").forward(request, response);
    }
}