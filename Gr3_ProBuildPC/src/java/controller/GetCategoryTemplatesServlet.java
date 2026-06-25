package controller;

import dal.CategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import model.CategorySpecTemplate;

@WebServlet(name = "GetCategoryTemplatesServlet", urlPatterns = {"/GetCategoryTemplates"})
public class GetCategoryTemplatesServlet extends HttpServlet {

    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        String categoryIdRaw = request.getParameter("categoryId");
        PrintWriter out = response.getWriter();
        
        if (categoryIdRaw == null || categoryIdRaw.trim().isEmpty()) {
            out.write("[]");
            return;
        }
        
        try {
            int categoryId = Integer.parseInt(categoryIdRaw);
            List<CategorySpecTemplate> templates = categoryDAO.getTemplatesByCategoryId(categoryId);
            
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
                sb.append("\"displayOrder\":").append(t.getDisplayOrder());
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
