package controller;

import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import model.ProductSpecification;

@WebServlet(name = "GetProductSpecsServlet", urlPatterns = {"/GetProductSpecs"})
public class GetProductSpecsServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        String productIdRaw = request.getParameter("productId");
        PrintWriter out = response.getWriter();

        if (productIdRaw == null || productIdRaw.trim().isEmpty()) {
            out.write("[]");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdRaw);
            List<ProductSpecification> specs = productDAO.getSpecificationsByProductId(productId);

            StringBuilder sb = new StringBuilder();
            sb.append("[");
            for (int i = 0; i < specs.size(); i++) {
                ProductSpecification s = specs.get(i);
                sb.append("{");
                sb.append("\"specId\":").append(s.getSpecId()).append(",");
                sb.append("\"productId\":").append(s.getProductId()).append(",");
                sb.append("\"specificationName\":\"").append(escapeJson(s.getSpecificationName())).append("\",");
                sb.append("\"specificationValue\":\"").append(escapeJson(s.getSpecificationValue())).append("\"");
                sb.append("}");
                if (i < specs.size() - 1) {
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
