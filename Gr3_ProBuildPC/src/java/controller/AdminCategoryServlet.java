package controller;

import dal.CategoryDAO;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

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
        String status = normalizeStatusFilter(request.getParameter("status"));
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

        int totalCategories = categoryDAO.countCategories(keyword, status);

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

        List<Category> categories = categoryDAO.getCategories(keyword, status, sort, currentPage, PAGE_SIZE);

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
        request.setAttribute("status", status);
        request.setAttribute("sort", sort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCategories", totalCategories);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);

        // Flash messages from session (after redirect from POST)
        HttpSession session = request.getSession(false);
        if (session != null) {
            String successMsg = (String) session.getAttribute("categorySuccess");
            String errorMsg = (String) session.getAttribute("categoryError");

            if (successMsg != null) {
                request.setAttribute("success", successMsg);
                session.removeAttribute("categorySuccess");
            }

            if (errorMsg != null) {
                request.setAttribute("error", errorMsg);
                session.removeAttribute("categoryError");
            }
        }

        request.getRequestDispatcher("/views/category-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("add".equalsIgnoreCase(action)) {
            handleAdd(request, session);
        } else if ("update".equalsIgnoreCase(action)) {
            handleUpdate(request, session);
        } else {
            boolean isSuccess = handleStatusChange(request, session);
            if ("XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"success\": " + isSuccess + "}");
                return;
            }
            // Redirect back preserving filters
            String keyword = request.getParameter("keyword");
            String status = normalizeStatusFilter(request.getParameter("status"));
            String sort = request.getParameter("sort");
            String page = request.getParameter("page");
            response.sendRedirect(request.getContextPath() + "/admin/categories" + buildQuery(keyword, status, sort, page));
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }

    private void handleAdd(HttpServletRequest request, HttpSession session) {
        String categoryName = normalizeText(request.getParameter("categoryName"));

        if (categoryDAO.addCategory(categoryName)) {
            session.setAttribute("categorySuccess", "Thêm danh mục thành công.");
        } else {
            session.setAttribute("categoryError", "Không thể thêm danh mục. Tên có thể đã tồn tại.");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpSession session) {
        Integer categoryId = parseId(request.getParameter("categoryId"));
        String categoryName = normalizeText(request.getParameter("categoryName"));
        String newStatus = normalizeText(request.getParameter("status"));

        if (categoryId == null) {
            session.setAttribute("categoryError", "Danh mục không hợp lệ.");
            return;
        }

        // Update category name
        if (categoryName != null) {
            if (!categoryDAO.updateCategoryName(categoryId, categoryName)) {
                session.setAttribute("categoryError", "Không thể cập nhật danh mục. Tên có thể đã tồn tại.");
                return;
            }
        }

        // Update category status if provided
        if (newStatus != null) {
            categoryDAO.updateCategoryStatus(categoryId, newStatus.toUpperCase());
        }

        session.setAttribute("categorySuccess", "Cập nhật danh mục thành công.");
    }

    private boolean handleStatusChange(HttpServletRequest request, HttpSession session) {
        String categoryIdRaw = request.getParameter("categoryId");
        String action = request.getParameter("action");
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));

        try {
            int categoryId = Integer.parseInt(categoryIdRaw);

            if ("delete".equalsIgnoreCase(action)) {
                if (categoryDAO.updateCategoryStatus(categoryId, "INACTIVE")) {
                    if (!isAjax) {
                        session.setAttribute("categorySuccess", "Vô hiệu hóa danh mục thành công.");
                    }
                    return true;
                } else {
                    if (!isAjax) {
                        session.setAttribute("categoryError", "Không thể vô hiệu hóa danh mục.");
                    }
                    return false;
                }
            } else if ("activate".equalsIgnoreCase(action)) {
                if (categoryDAO.updateCategoryStatus(categoryId, "ACTIVE")) {
                    if (!isAjax) {
                        session.setAttribute("categorySuccess", "Kích hoạt danh mục thành công.");
                    }
                    return true;
                } else {
                    if (!isAjax) {
                        session.setAttribute("categoryError", "Không thể kích hoạt danh mục.");
                    }
                    return false;
                }
            }

        } catch (Exception e) {
            if (!isAjax) {
                session.setAttribute("categoryError", "Lỗi thao tác trên danh mục.");
            }
            return false;
        }
        return false;
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

    private String normalizeStatusFilter(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "ALL";
        }

        String status = value.trim().toUpperCase();
        if ("ACTIVE".equals(status) || "INACTIVE".equals(status)) {
            return status;
        }

        return "ALL";
    }

    private String buildQuery(String keyword, String status, String sort, String page) {
        StringBuilder query = new StringBuilder("?");
        appendQueryParam(query, "keyword", keyword == null ? "" : keyword.trim());
        appendQueryParam(query, "status", normalizeStatusFilter(status));
        appendQueryParam(query, "sort", sort == null || sort.trim().isEmpty() ? "newest" : sort.trim());
        appendQueryParam(query, "page", page == null || page.trim().isEmpty() ? "1" : page.trim());
        return query.toString();
    }

    private void appendQueryParam(StringBuilder query, String name, String value) {
        if (query.length() > 1) {
            query.append("&");
        }

        query.append(URLEncoder.encode(name, StandardCharsets.UTF_8));
        query.append("=");
        query.append(URLEncoder.encode(value, StandardCharsets.UTF_8));
    }
}
