package controller;

import dal.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import model.CategorySpecTemplate;
import model.User;

@WebServlet(name = "GetCategoryTemplatesServlet", urlPatterns = {"/GetCategoryTemplates"})
public class GetCategoryTemplatesServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User account = session == null ? null : (User) session.getAttribute("account");
        if (account == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        if (account.getRoleName() == null
                || !"ADMIN".equalsIgnoreCase(account.getRoleName().trim())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        
        String categoryIdRaw = request.getParameter("categoryId");
        String productIdRaw = request.getParameter("productId");
        PrintWriter out = response.getWriter();
        
        if (categoryIdRaw == null || categoryIdRaw.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdRaw);
            Integer productId = null;
            if (productIdRaw != null && !productIdRaw.trim().isEmpty()) {
                try {
                    productId = Integer.parseInt(productIdRaw.trim());
                } catch (NumberFormatException e) {
                    productId = null;
                }
            }
            List<CategorySpecTemplate> templates = categoryDAO.getTemplatesWithValues(categoryId, productId);
            
            StringBuilder sb = new StringBuilder();
            sb.append("[");
            for (int i = 0; i < templates.size(); i++) {
                CategorySpecTemplate t = templates.get(i);
                sb.append("{");
                sb.append("\"templateId\":").append(t.getTemplateId()).append(",");
                sb.append("\"categoryId\":").append(t.getCategoryId()).append(",");
                sb.append("\"specName\":\"").append(escapeJson(t.getSpecName())).append("\",");
                sb.append("\"specType\":\"").append(escapeJson(t.getSpecType())).append("\",");
                sb.append("\"allowedValues\":\"").append(escapeJson(t.getAllowedValues())).append("\",");
                sb.append("\"isRequired\":").append(t.isRequired()).append(",");
                sb.append("\"displayOrder\":").append(t.getDisplayOrder()).append(",");
                sb.append("\"specValue\":\"").append(escapeJson(t.getSpecValue())).append("\"");
                sb.append("}");
                if (i < templates.size() - 1) {
                    sb.append(",");
                }
            }
            sb.append("]");
            
            out.write(sb.toString());
        } catch (NumberFormatException e) {
            out.write("[]");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
