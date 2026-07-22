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
import util.ValidatorUtil;

@WebServlet(name = "AdminCategoryServlet", urlPatterns = {"/admin/categories"})
public class AdminCategoryServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        if ("check-name".equalsIgnoreCase(request.getParameter("action"))) {
            handleCheckName(request, response);
            return;
        }

        response.setContentType("text/html;charset=UTF-8");

        String keyword = request.getParameter("keyword");
        String status = normalizeStatusFilter(request.getParameter("status"));
        String sort = normalizeSort(request.getParameter("sort"));
        String pageRaw = request.getParameter("page");

        if (keyword == null) {
            keyword = "";
        } else {
            keyword = keyword.trim();
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
            moveFlashAttribute(session, request, "categorySuccess", "success");
            moveFlashAttribute(session, request, "categoryError", "error");
            moveFlashAttribute(session, request, "addCategoryNameError", "addCategoryNameError");
            moveFlashAttribute(session, request, "addCategoryOldName", "addCategoryOldName");
            moveFlashAttribute(session, request, "editCategoryNameError", "editCategoryNameError");
            moveFlashAttribute(session, request, "editCategoryOldName", "editCategoryOldName");
            moveFlashAttribute(session, request, "editCategoryOldId", "editCategoryOldId");
        }

        request.getRequestDispatcher("/views/category-management.jsp").forward(request, response);
    }

    private void handleCheckName(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String rawCategoryName = request.getParameter("categoryName");
        String validationError = ValidatorUtil.getCategoryNameError(rawCategoryName);
        boolean exists = false;

        if (validationError == null) {
            String categoryName = normalizeText(rawCategoryName);
            Integer excludedCategoryId = parseId(request.getParameter("excludeId"));
            exists = categoryDAO.categoryNameExists(categoryName, excludedCategoryId);
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"exists\":" + exists + "}");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("add".equalsIgnoreCase(action)) {
            handleAdd(request, session);
            redirectAfterCategoryForm(request, response, session, "addCategoryNameError", "addCategoryModal");
        } else if ("update".equalsIgnoreCase(action)) {
            handleUpdate(request, session);
            redirectAfterCategoryForm(request, response, session, "editCategoryNameError", "editCategoryModal");
        } else {
            handleStatusChange(request, session);
            String keyword = request.getParameter("keyword");
            String status = normalizeStatusFilter(request.getParameter("status"));
            String sort = normalizeSort(request.getParameter("sort"));
            String page = request.getParameter("page");
            response.sendRedirect(request.getContextPath() + "/admin/categories" + buildQuery(keyword, status, sort, page));
        }
    }

    private void handleAdd(HttpServletRequest request, HttpSession session) {
        String rawCategoryName = request.getParameter("categoryName");
        String nameError = ValidatorUtil.getCategoryNameError(rawCategoryName);

        if (nameError != null) {
            setAddCategoryError(session, nameError, rawCategoryName);
            return;
        }

        String categoryName = normalizeText(rawCategoryName);

        if (categoryDAO.categoryNameExists(categoryName, null)) {
            setAddCategoryError(session, "Tên danh mục đã tồn tại.", categoryName);
            return;
        }

        if (categoryDAO.addCategory(categoryName)) {
            session.setAttribute("categorySuccess", "Thêm danh mục thành công.");
        } else {
            session.setAttribute("categoryError", "Không thể thêm danh mục. Vui lòng thử lại.");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpSession session) {
        Integer categoryId = parseId(request.getParameter("categoryId"));

        if (categoryId == null) {
            session.setAttribute("categoryError", "Danh mục không hợp lệ.");
            return;
        }

        String rawCategoryName = request.getParameter("categoryName");
        String nameError = ValidatorUtil.getCategoryNameError(rawCategoryName);

        if (nameError != null) {
            setEditCategoryError(session, nameError, rawCategoryName, categoryId);
            return;
        }

        String categoryName = normalizeText(rawCategoryName);

        if (categoryDAO.categoryNameExists(categoryName, categoryId)) {
            setEditCategoryError(session, "Tên danh mục đã tồn tại.", categoryName, categoryId);
            return;
        }

        if (!categoryDAO.updateCategoryName(categoryId, categoryName)) {
            session.setAttribute("categoryError", "Không thể cập nhật danh mục. Vui lòng thử lại.");
            return;
        }

        session.setAttribute("categorySuccess", "Cập nhật danh mục thành công.");
    }

    private void handleStatusChange(HttpServletRequest request, HttpSession session) {
        String categoryIdRaw = request.getParameter("categoryId");
        String action = request.getParameter("action");

        try {
            int categoryId = Integer.parseInt(categoryIdRaw);

            if ("delete".equalsIgnoreCase(action)) {
                if (categoryDAO.updateCategoryStatus(categoryId, "INACTIVE")) {
                    session.setAttribute("categorySuccess", "Vô hiệu hóa danh mục thành công.");
                } else {
                    session.setAttribute("categoryError", "Không thể vô hiệu hóa danh mục.");
                }
            } else if ("activate".equalsIgnoreCase(action)) {
                if (categoryDAO.updateCategoryStatus(categoryId, "ACTIVE")) {
                    session.setAttribute("categorySuccess", "Kích hoạt danh mục thành công.");
                } else {
                    session.setAttribute("categoryError", "Không thể kích hoạt danh mục.");
                }
            } else {
                session.setAttribute("categoryError", "Thao tác danh mục không hợp lệ.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("categoryError", "Danh mục không hợp lệ.");
        }
    }

    private void moveFlashAttribute(HttpSession session, HttpServletRequest request,
            String sessionAttribute, String requestAttribute) {
        Object value = session.getAttribute(sessionAttribute);

        if (value != null) {
            request.setAttribute(requestAttribute, value);
            session.removeAttribute(sessionAttribute);
        }
    }

    private void redirectAfterCategoryForm(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, String errorAttribute, String modalId) throws IOException {
        String redirect = request.getContextPath() + "/admin/categories";

        if (session.getAttribute(errorAttribute) != null) {
            redirect += "#" + modalId;
        }

        response.sendRedirect(redirect);
    }

    private void setAddCategoryError(HttpSession session, String error, String categoryName) {
        session.setAttribute("addCategoryNameError", error);
        session.setAttribute("addCategoryOldName", categoryName == null ? "" : categoryName);
    }

    private void setEditCategoryError(HttpSession session, String error, String categoryName, int categoryId) {
        session.setAttribute("editCategoryNameError", error);
        session.setAttribute("editCategoryOldName", categoryName == null ? "" : categoryName);
        session.setAttribute("editCategoryOldId", String.valueOf(categoryId));
    }

    private Integer parseId(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalizeText(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }

        return value.trim().replaceAll("\\s+", " ");
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

    private String normalizeSort(String value) {
        if (value != null && "oldest".equalsIgnoreCase(value.trim())) {
            return "oldest";
        }

        return "newest";
    }

    private String buildQuery(String keyword, String status, String sort, String page) {
        StringBuilder query = new StringBuilder("?");
        appendQueryParam(query, "keyword", keyword == null ? "" : keyword.trim());
        appendQueryParam(query, "status", normalizeStatusFilter(status));
        appendQueryParam(query, "sort", normalizeSort(sort));
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
