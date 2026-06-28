package controller;

import dal.CategoryDAO;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import model.Category;
import model.CategorySpecTemplate;

@WebServlet(name = "AdminCategoryAddServlet", urlPatterns = {"/admin/category/add"})
public class AdminCategoryAddServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();

        // Initialize state for adding new category
        Category addCategory = new Category();
        addCategory.setCategoryName("");
        addCategory.setStatus("ACTIVE");

        List<CategorySpecTemplate> templates = new ArrayList<>();

        session.setAttribute("addCategory", addCategory);
        session.setAttribute("addTemplates", templates);
        session.removeAttribute("editingIndex"); // default no row is editing

        request.getRequestDispatcher("/views/add-category.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        Category addCategory = (Category) session.getAttribute("addCategory");
        List<CategorySpecTemplate> addTemplates = (List<CategorySpecTemplate>) session.getAttribute("addTemplates");

        if (addCategory == null || addTemplates == null) {
            response.sendRedirect(request.getContextPath() + "/admin/categories");
            return;
        }

        // Always read current form values to preserve input state across postbacks
        String categoryName = request.getParameter("categoryName");
        if (categoryName != null) {
            addCategory.setCategoryName(categoryName.trim());
        }

        // Parse all existing templates' values from parameters to update our session list
        for (int i = 0; i < addTemplates.size(); i++) {
            CategorySpecTemplate t = addTemplates.get(i);
            String specName = request.getParameter("specName_" + i);
            String specType = request.getParameter("specType_" + i);
            String allowedValues = request.getParameter("allowedValues_" + i);
            String isRequiredStr = request.getParameter("isRequired_" + i);
            String displayOrderStr = request.getParameter("displayOrder_" + i);

            if (specName != null) {
                t.setSpecName(specName.trim());
            }
            if (specType != null) {
                t.setSpecType(specType.trim().toUpperCase());
            }
            if (t.getSpecType() != null && ("TEXT".equals(t.getSpecType()) || "NUMBER".equals(t.getSpecType()))) {
                t.setAllowedValues(null);
            } else if (allowedValues != null) {
                t.setAllowedValues(allowedValues.trim());
            } else {
                t.setAllowedValues("");
            }
            t.setRequired("true".equals(isRequiredStr));
            if (displayOrderStr != null) {
                try {
                    t.setDisplayOrder(Integer.parseInt(displayOrderStr.trim()));
                } catch (NumberFormatException e) {
                    t.setDisplayOrder(-1);
                }
            }
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "saveCategory";
        }

        if (action.startsWith("editSpec_")) {
            int index = Integer.parseInt(action.substring("editSpec_".length()));
            session.setAttribute("editingIndex", index);
            request.getRequestDispatcher("/views/add-category.jsp").forward(request, response);
            return;
        }


        if (action.startsWith("toggleRequired_")) {
            int index = Integer.parseInt(action.substring("toggleRequired_".length()));
            CategorySpecTemplate t = addTemplates.get(index);
            t.setRequired(!t.isRequired());
            session.setAttribute("addTemplates", addTemplates);
            request.getRequestDispatcher("/views/add-category.jsp").forward(request, response);
            return;
        }

        if (action.startsWith("saveSpec_")) {
            session.removeAttribute("editingIndex");
            request.getRequestDispatcher("/views/add-category.jsp").forward(request, response);
            return;
        }

        if ("addSpec".equals(action)) {
            // Add a new empty template
            CategorySpecTemplate newTemplate = new CategorySpecTemplate();
            newTemplate.setSpecName("");
            newTemplate.setSpecType("TEXT");
            newTemplate.setAllowedValues("");
            newTemplate.setRequired(true);
            
            // Find max display order to suggest the next one
            int maxOrder = 0;
            for (CategorySpecTemplate t : addTemplates) {
                if (t.getDisplayOrder() > maxOrder) {
                    maxOrder = t.getDisplayOrder();
                }
            }
            newTemplate.setDisplayOrder(maxOrder + 1);

            addTemplates.add(newTemplate);
            session.setAttribute("addTemplates", addTemplates);
            // Automatically put the newly added row in editing mode
            session.setAttribute("editingIndex", addTemplates.size() - 1);

            request.getRequestDispatcher("/views/add-category.jsp").forward(request, response);
            return;
        }

        if ("saveCategory".equals(action)) {
            Integer editingIndex = (Integer) session.getAttribute("editingIndex");
            if (editingIndex != null) {
                request.setAttribute("error", "Vui lòng hoàn tất hoặc lưu dòng thuộc tính đang chỉnh sửa trước khi lưu danh mục.");
                request.getRequestDispatcher("/views/add-category.jsp").forward(request, response);
                return;
            }

            if (categoryDAO.addCategoryWithTemplates(addCategory.getCategoryName(), addTemplates)) {
                session.setAttribute("categorySuccess", "Thêm danh mục thành công.");
                // Clean up session
                session.removeAttribute("addCategory");
                session.removeAttribute("addTemplates");
                session.removeAttribute("editingIndex");
                response.sendRedirect(request.getContextPath() + "/admin/categories");
            } else {
                request.setAttribute("error", "Thêm danh mục thất bại. Tên danh mục có thể đã tồn tại hoặc lỗi dữ liệu.");
                request.getRequestDispatcher("/views/add-category.jsp").forward(request, response);
            }
            return;
        }

        if ("cancel".equals(action)) {
            session.removeAttribute("addCategory");
            session.removeAttribute("addTemplates");
            session.removeAttribute("editingIndex");
            response.sendRedirect(request.getContextPath() + "/admin/categories");
        }
    }

}
