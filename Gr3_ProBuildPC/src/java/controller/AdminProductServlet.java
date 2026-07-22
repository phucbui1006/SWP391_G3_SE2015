package controller;

import dal.BrandDAO;
import dal.CategoryDAO;
import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import model.Brand;
import model.Category;
import model.Product;
import model.User;
import model.CategorySpecTemplate;

@WebServlet(name = "AdminProductServlet", urlPatterns = {"/admin/products"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 2 * 1024 * 1024,
        maxRequestSize = 4 * 1024 * 1024
)
public class AdminProductServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final BrandDAO brandDAO = new BrandDAO();

    private static final int PAGE_SIZE = 5;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = requireAdmin(request, response);
        if (session == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");
        if ("checkName".equalsIgnoreCase(action)) {
            handleProductNameCheck(request, response);
            return;
        }

        populatePageData(request);

        Integer editId = parseId(request.getParameter("productId"));

        if ("edit".equalsIgnoreCase(action) && editId != null) {
            Product editProduct = productDAO.getProductByIdForAdmin(editId);

            if (editProduct != null) {
                request.setAttribute("failedAction", "update");
                request.setAttribute("enteredProductId", editProduct.getProductId());
                request.setAttribute("enteredProductName", editProduct.getProductName());
                request.setAttribute("enteredCategoryId", editProduct.getCategoryId());
                request.setAttribute("enteredBrandId", editProduct.getBrandId());
                request.setAttribute("enteredPrice", String.valueOf(editProduct.getPrice()));
                request.setAttribute("enteredWarrantyMonths", String.valueOf(editProduct.getWarrantyMonths()));
                request.setAttribute("enteredDescription", editProduct.getDescription());
                request.setAttribute("enteredCurrentImg", editProduct.getImageUrl());

                List<CategorySpecTemplate> specTemplates
                        = categoryDAO.getTemplatesWithValues(editProduct.getCategoryId(), editProduct.getProductId());
                request.setAttribute("specTemplates", specTemplates);
            }
        }
        // Flash messages
        String successMsg = (String) session.getAttribute("productSuccess");
        String errorMsg = (String) session.getAttribute("productError");

        if (successMsg != null) {
            request.setAttribute("success", successMsg);
            session.removeAttribute("productSuccess");
        }
        if (errorMsg != null) {
            request.setAttribute("error", errorMsg);
            session.removeAttribute("productError");
        }

        request.getRequestDispatcher("/views/admin-products.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = requireAdmin(request, response);
        if (session == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");
        boolean isSuccess = true;

        if ("add".equalsIgnoreCase(action)) {
            isSuccess = handleAdd(request, session);
        } else if ("update".equalsIgnoreCase(action)) {
            isSuccess = handleUpdate(request, session);
        } else if ("delete".equalsIgnoreCase(action)) {
            isSuccess = handleStatusChange(request, session, "INACTIVE");
        } else if ("activate".equalsIgnoreCase(action)) {
            isSuccess = handleStatusChange(request, session, "ACTIVE");
        } else {
            session.setAttribute("productError", "Thao tác không hợp lệ.");
            isSuccess = false;
        }

        if ("XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"success\": " + isSuccess + "}");
            return;
        }

        if (!isSuccess) {
            if ("add".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
                populatePageDataWithDefaults(request);
            } else {
                populatePageData(request);
            }
            String err = (String) request.getAttribute("error");
            if (err == null) {
                err = (String) session.getAttribute("productError");
                session.removeAttribute("productError");
            }
            request.setAttribute("error", err);
            request.getRequestDispatcher("/views/admin-products.jsp").forward(request, response);
            return;
        }

        if ("add".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
            response.sendRedirect(request.getContextPath() + "/admin/products");
            return;
        }

        // Redirect preserving parameters on success for other actions (PRG pattern)
        String keyword = request.getParameter("keyword");
        String categoryId = request.getParameter("categoryId");
        String brandId = request.getParameter("brandId");
        String status = request.getParameter("status");
        String sort = request.getParameter("sort");
        String page = request.getParameter("page");

        response.sendRedirect(request.getContextPath() + "/admin/products" + buildQuery(keyword, categoryId, brandId, status, sort, page));
    }

    //Hiển thị bảng sản phẩm và phân trang
    private void populatePageData(HttpServletRequest request) {
        String keyword = request.getParameter("keyword");
        String categoryIdRaw = request.getParameter("categoryId");
        String brandIdRaw = request.getParameter("brandId");
        String status = normalizeStatusFilter(request.getParameter("status"));
        String sort = request.getParameter("sort");
        String pageRaw = request.getParameter("page");

        if (keyword == null) {
            keyword = "";
        } else {
            keyword = keyword.trim();
        }

        Integer categoryId = parseId(categoryIdRaw);
        Integer brandId = parseId(brandIdRaw);

        if (sort == null || sort.trim().isEmpty()) {
            sort = "oldest";
        }

        int currentPage = 1;
        try {
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                currentPage = Integer.parseInt(pageRaw);
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }

        int totalProducts = productDAO.countProductsForAdmin(keyword, categoryId, brandId, status);
        int totalPages = totalProducts == 0 ? 1 : (int) Math.ceil((double) totalProducts / PAGE_SIZE);

        if (currentPage < 1 || currentPage > totalPages) {
            currentPage = 1;
        }
////Lấy sản phẩm khi có ID
       List<Product> products = productDAO.getProductsForAdmin(keyword, categoryId, brandId, status, sort, currentPage, PAGE_SIZE);
//        List<Product> filteredList = new ArrayList<>();
//        
//        for (Product p : products) {
//            if (p.getProductId() == 1) {
//                filteredList.add(p);
//               
//                
//            } 
//            products = filteredList;
//        }
        List<Category> categories = categoryDAO.getAllCategories();
        List<Brand> brands = brandDAO.getActiveBrands();

        int startItem = totalProducts == 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1;
        int endItem = Math.min(currentPage * PAGE_SIZE, totalProducts);

        request.setAttribute("products", products);
        request.setAttribute("categories", categories);
        request.setAttribute("brands", brands);
        request.setAttribute("keyword", keyword);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("brandId", brandId);
        request.setAttribute("status", status);
        request.setAttribute("sort", sort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalProducts", totalProducts);
        request.setAttribute("startItem", startItem);
        request.setAttribute("endItem", endItem);
    }

    /**
     * Populate page data with CLEAN defaults (no filters applied). Used when
     * forwarding back from add/update validation failures to prevent the
     * product form's categoryId/brandId from corrupting the dashboard filters.
     */
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

    //Thêm sản phẩm
    private boolean handleAdd(HttpServletRequest request, HttpSession session) throws IOException, ServletException {
        if (!Boolean.TRUE.equals(request.getAttribute("productValidationPassed"))) {
            request.setAttribute("error", "Dữ liệu sản phẩm chưa được kiểm tra hợp lệ.");
            return false;
        }

        String productName = normalizeText(request.getParameter("productName"));
        Integer categoryId = parseId(request.getParameter("categoryId"));
        Integer brandId = parseId(request.getParameter("brandId"));
        String priceRaw = request.getParameter("price");
        String warrantyMonthsRaw = request.getParameter("warrantyMonths");
        String description = normalizeText(request.getParameter("description"));
        String imageUrl = (String) request.getAttribute("savedProductImg");
        BigDecimal price = new BigDecimal(priceRaw.trim());
        int warrantyMonths = Integer.parseInt(warrantyMonthsRaw.trim());
        String[] specNames = request.getParameterValues("spec_names[]");
        String[] specValues = request.getParameterValues("spec_values[]");

        request.setAttribute("failedAction", "add");
        request.setAttribute("enteredProductName", productName);
        request.setAttribute("enteredCategoryId", categoryId);
        request.setAttribute("enteredBrandId", brandId);
        request.setAttribute("enteredPrice", priceRaw.trim());
        request.setAttribute("enteredDescription", description);
        request.setAttribute("enteredWarrantyMonths", warrantyMonthsRaw.trim());
        request.setAttribute("enteredCurrentImg", imageUrl);
        request.setAttribute("enteredSpecNames", specNames);
        request.setAttribute("enteredSpecValues", specValues);

        if (productDAO.addProduct(productName, categoryId, brandId, price, description, imageUrl, warrantyMonths, specNames, specValues)) {
            session.setAttribute("productSuccess", "Thêm sản phẩm mới thành công.");
            return true;
        } else {
            request.setAttribute("error", "Không thể thêm sản phẩm. Vui lòng kiểm tra lại thông tin.");
            return false;
        }
    }

    //Cập nhật thông tin sản phẩm
    private boolean handleUpdate(HttpServletRequest request, HttpSession session) throws IOException, ServletException {
        if (!Boolean.TRUE.equals(request.getAttribute("productValidationPassed"))) {
            request.setAttribute("error", "Dữ liệu sản phẩm chưa được kiểm tra hợp lệ.");
            return false;
        }

        Integer productId = parseId(request.getParameter("productId"));
        String productName = normalizeText(request.getParameter("productName"));
        Integer categoryId = parseId(request.getParameter("categoryId"));
        Integer brandId = parseId(request.getParameter("brandId"));
        String priceRaw = request.getParameter("price");
        String warrantyMonthsRaw = request.getParameter("warrantyMonths");
        String description = normalizeText(request.getParameter("description"));
        String imageUrl = (String) request.getAttribute("savedProductImg");
        BigDecimal price = new BigDecimal(priceRaw.trim());
        int warrantyMonths = Integer.parseInt(warrantyMonthsRaw.trim());
        String[] specNames = request.getParameterValues("spec_names[]");
        String[] specValues = request.getParameterValues("spec_values[]");

        request.setAttribute("failedAction", "update");
        request.setAttribute("enteredProductId", productId);
        request.setAttribute("enteredProductName", productName);
        request.setAttribute("enteredCategoryId", categoryId);
        request.setAttribute("enteredBrandId", brandId);
        request.setAttribute("enteredPrice", priceRaw.trim());
        request.setAttribute("enteredDescription", description);
        request.setAttribute("enteredWarrantyMonths", warrantyMonthsRaw.trim());
        request.setAttribute("enteredCurrentImg", imageUrl);
        request.setAttribute("enteredSpecNames", specNames);
        request.setAttribute("enteredSpecValues", specValues);

        if (productDAO.updateProduct(productId, productName, categoryId, brandId, price, description, imageUrl, warrantyMonths, specNames, specValues)) {
            session.setAttribute("productSuccess", "Cập nhật sản phẩm thành công.");
            return true;
        } else {
            request.setAttribute("error", "Không thể cập nhật sản phẩm. Vui lòng kiểm tra lại.");
            return false;
        }
    }

    //Thay đổi trạng thái sản phẩm
    private boolean handleStatusChange(HttpServletRequest request, HttpSession session, String newStatus) {
        Integer productId = parseId(request.getParameter("productId"));
        boolean isAjax = "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"));

        if (productId == null) {
            if (!isAjax) {
                request.setAttribute("error", "Sản phẩm không hợp lệ.");
            }
            return false;
        }

        if (productDAO.updateProductStatus(productId, newStatus)) {
            if (!isAjax) {
                String statusMsg = "ACTIVE".equals(newStatus) ? "Kích hoạt" : "Vô hiệu hóa";
                session.setAttribute("productSuccess", statusMsg + " sản phẩm thành công.");
            }
            return true;
        } else {
            if (!isAjax) {
                request.setAttribute("error", "Không thể thay đổi trạng thái sản phẩm.");
            }
            return false;
        }
    }

    private HttpSession requireAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return null;
        }
        User user = (User) session.getAttribute("account");
        String roleName = user.getRoleName();
        if (roleName == null || !"ADMIN".equalsIgnoreCase(roleName.trim())) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return null;
        }
        return session;
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

    private void handleProductNameCheck(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String productName = normalizeText(request.getParameter("productName"));
        Integer productId = parseId(request.getParameter("productId"));
        boolean duplicate = false;

        if (util.ProductValidator.validateProductName(productName) == null) {
            duplicate = productId == null
                    ? productDAO.existsByProductName(productName)
                    : productDAO.existsByProductNameExceptId(productName, productId);
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"duplicate\":" + duplicate + "}");
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

    private String buildQuery(String keyword, String categoryId, String brandId, String status, String sort, String page) {
        StringBuilder query = new StringBuilder("?");
        appendQueryParam(query, "keyword", keyword == null ? "" : keyword.trim());
        appendQueryParam(query, "categoryId", categoryId == null ? "" : categoryId.trim());
        appendQueryParam(query, "brandId", brandId == null ? "" : brandId.trim());
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
