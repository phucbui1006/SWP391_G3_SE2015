package filter;

import dal.BrandDAO;
import dal.CategoryDAO;
import dal.ProductDAO;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import model.Brand;
import model.Category;
import model.Product;
import model.CategorySpecTemplate;

@WebFilter(filterName = "ProductValidationFilter", urlPatterns = {"/admin/products"})
public class ProductValidationFilter implements Filter {

    private static final int PAGE_SIZE = 8;
    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        if (!"POST".equalsIgnoreCase(req.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        String action = req.getParameter("action");
        if ("add".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
            Map<String, String> errors = new HashMap<>();

            String productName = req.getParameter("productName");
            String categoryIdRaw = req.getParameter("categoryId");
            String brandIdRaw = req.getParameter("brandId");
            String priceRaw = req.getParameter("price");
            String warrantyMonthsRaw = req.getParameter("warrantyMonths");
            String description = req.getParameter("description");
            String currentImg = req.getParameter("currentImg");

            String[] specNames = req.getParameterValues("spec_names[]");
            String[] specValues = req.getParameterValues("spec_values[]");

            Integer categoryId = parseId(categoryIdRaw);
            Integer brandId = parseId(brandIdRaw);

            Part filePart = null;
            try {
                filePart = req.getPart("imgFile");
            } catch (Exception e) {
                errors.put("imgFile", "Lỗi xử lý tệp tin tải lên.");
            }

            String savedImgPath = util.ProductValidator.validate(
                action, productName, categoryId, brandId, priceRaw, 
                warrantyMonthsRaw, description, currentImg, filePart, 
                specNames, specValues, categoryDAO, req.getServletContext(), errors
            );

            // Expose the saved image path to both Servlet (savedProductImg) and JSP (enteredCurrentImg)
            if (savedImgPath != null) {
                req.setAttribute("savedProductImg", savedImgPath);
                req.setAttribute("enteredCurrentImg", savedImgPath);
            }

            // If validation errors are present, block Servlet and forward back to the JSP form
            if (!errors.isEmpty()) {
                req.setAttribute("errors", errors);
                // Set first error message in request for backward compatibility in alert boxes
                req.setAttribute("error", errors.values().iterator().next());
                
                // Preserve the inputs to repopulate the form
                req.setAttribute("enteredProductId", parseId(req.getParameter("productId")));
                req.setAttribute("enteredProductName", productName);
                req.setAttribute("enteredCategoryId", categoryId);
                req.setAttribute("enteredBrandId", brandId);
                req.setAttribute("enteredPrice", priceRaw);
                req.setAttribute("enteredWarrantyMonths", warrantyMonthsRaw);
                req.setAttribute("enteredDescription", description);
                req.setAttribute("enteredCurrentImg", savedImgPath != null ? savedImgPath : currentImg);
                req.setAttribute("failedAction", action);
                
                req.setAttribute("enteredSpecNames", specNames);
                req.setAttribute("enteredSpecValues", specValues);

                if (categoryId != null) {
                    List<CategorySpecTemplate> specTemplates = categoryDAO.getTemplatesByCategoryId(categoryId);
                    req.setAttribute("specTemplates", specTemplates);
                }

                // Populate dependencies and return to administration view
                populatePageDataWithDefaults(req);
                req.getRequestDispatcher("/views/admin-products.jsp").forward(req, res);
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}

    private Integer parseId(String val) {
        if (val == null || val.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(val.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private void populatePageDataWithDefaults(HttpServletRequest request) {
        String keyword = "";
        Integer categoryId = null;
        Integer brandId = null;
        String status = "ALL";
        String sort = "newest";
        int currentPage = 1;

        int totalProducts = productDAO.countProductsForAdmin(keyword, categoryId, brandId, status);
        int totalPages = totalProducts == 0 ? 1 : (int) Math.ceil((double) totalProducts / PAGE_SIZE);

        List<Product> products = productDAO.getProductsForAdmin(keyword, categoryId, brandId, status, sort, currentPage, PAGE_SIZE);
        List<Category> categories = categoryDAO.getAllCategories();
        List<Brand> brands = brandDAO.getActiveBrands();

        int startItem = totalProducts == 0 ? 0 : 1;
        int endItem = Math.min(PAGE_SIZE, totalProducts);

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.setAttribute("keyword", "");
        request.setAttribute("categoryId", null);
        request.setAttribute("brandId", null);
        request.setAttribute("status", "ALL");
        request.setAttribute("sort", "newest");
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);
    }


}
