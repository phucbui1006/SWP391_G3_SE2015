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
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Locale;
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

    private static final int PAGE_SIZE = 8;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = requireAdmin(request, response);
        if (session == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        populatePageData(request);

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

        int totalProducts = productDAO.countProductsForAdmin(keyword, categoryId, brandId, status);
        int totalPages = totalProducts == 0 ? 1 : (int) Math.ceil((double) totalProducts / PAGE_SIZE);

        if (currentPage < 1 || currentPage > totalPages) {
            currentPage = 1;
        }

        List<Product> products = productDAO.getProductsForAdmin(keyword, categoryId, brandId, status, sort, currentPage, PAGE_SIZE);
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
        String productName = normalizeText(request.getParameter("productName"));
        String categoryIdRaw = request.getParameter("categoryId");
        String brandIdRaw = request.getParameter("brandId");
        String priceRaw = request.getParameter("price");
        String warrantyMonthsRaw = request.getParameter("warrantyMonths");
        String description = normalizeText(request.getParameter("description"));
        String currentImg = normalizeText(request.getParameter("currentImg"));

        Integer categoryId = parseId(categoryIdRaw);
        Integer brandId = parseId(brandIdRaw);
        BigDecimal price = null;
        Integer warrantyMonths = null;
        
        // Process and save the image immediately
        String imageUrl = (String) request.getAttribute("savedProductImg");
        if (imageUrl == null) {
            Part filePart = request.getPart("imgFile");
            if (filePart != null && filePart.getSize() > 0) {
                imageUrl = saveUploadedProductImage(filePart);
            }
        }
        if (imageUrl == null) {
            imageUrl = normalizeProductImagePath(currentImg);
        }

        // Save entered data for re-rendering on error
        request.setAttribute("failedAction", "add");
        request.setAttribute("enteredProductName", productName != null ? productName : "");
        request.setAttribute("enteredCategoryId", categoryId);
        request.setAttribute("enteredBrandId", brandId);
        request.setAttribute("enteredPrice", priceRaw != null ? priceRaw.trim() : "");
        request.setAttribute("enteredDescription", description != null ? description : "");
        request.setAttribute("enteredWarrantyMonths", warrantyMonthsRaw != null ? warrantyMonthsRaw.trim() : "");
        request.setAttribute("enteredCurrentImg", imageUrl);

        String[] specNames = request.getParameterValues("spec_names[]");
        String[] specValues = request.getParameterValues("spec_values[]");

        if (categoryId != null) {
            List<CategorySpecTemplate> specTemplates = categoryDAO.getTemplatesByCategoryId(categoryId);
            request.setAttribute("specTemplates", specTemplates != null ? specTemplates : new java.util.ArrayList<>());
            request.setAttribute("enteredSpecNames", specNames);
            request.setAttribute("enteredSpecValues", specValues);
        }

        // Validate product name
        if (productName == null || productName.length() < 3 || productName.length() > 255) {
            request.setAttribute("error", "Tên sản phẩm phải từ 3 đến 255 ký tự.");
            return false;
        }

        // Validate category and brand
        if (categoryId == null || brandId == null) {
            request.setAttribute("error", "Danh mục hoặc thương hiệu không hợp lệ.");
            return false;
        }

        // Validate price
        if (priceRaw == null || priceRaw.trim().isEmpty()) {
            request.setAttribute("error", "Giá bán không được để trống.");
            return false;
        }
        
        try {
            price = new BigDecimal(priceRaw.trim());
            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("error", "Giá bán phải lớn hơn 0.");
                return false;
            }
            if (price.compareTo(new BigDecimal("1000000000")) >= 0) {
                request.setAttribute("error", "Giá bán phải nhỏ hơn 1 tỉ.");
                return false;
            }
            if (price.remainder(new BigDecimal("1000")).compareTo(BigDecimal.ZERO) != 0) {
                request.setAttribute("error", "Giá bán phải chia hết cho 1000.");
                return false;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Giá bán phải là số hợp lệ.");
            return false;
        }

        // Validate warranty months
        if (warrantyMonthsRaw == null || warrantyMonthsRaw.trim().isEmpty()) {
            request.setAttribute("error", "Bảo hành không được để trống.");
            return false;
        }
        
        try {
            warrantyMonths = Integer.parseInt(warrantyMonthsRaw.trim());
            if (warrantyMonths < 0) {
                request.setAttribute("error", "Bảo hành phải lớn hơn hoặc bằng 0.");
                return false;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Bảo hành phải là số hợp lệ.");
            return false;
        }

        // Validate description
        if (description == null || description.trim().isEmpty()) {
            request.setAttribute("error", "Mô tả chi tiết không được để trống.");
            return false;
        }

        // Validate specifications for required fields
        String specError = validateSpecifications(categoryId, specNames, specValues);
        if (specError != null) {
            request.setAttribute("error", specError);
            return false;
        }



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
        String productIdRaw = request.getParameter("productId");
        String productName = normalizeText(request.getParameter("productName"));
        String categoryIdRaw = request.getParameter("categoryId");
        String brandIdRaw = request.getParameter("brandId");
        String priceRaw = request.getParameter("price");
        String warrantyMonthsRaw = request.getParameter("warrantyMonths");
        String description = normalizeText(request.getParameter("description"));
        String currentImg = normalizeText(request.getParameter("currentImg"));

        Integer productId = parseId(productIdRaw);
        Integer categoryId = parseId(categoryIdRaw);
        Integer brandId = parseId(brandIdRaw);
        BigDecimal price = null;
        Integer warrantyMonths = null;

        // Process and save the image immediately
        String imageUrl = (String) request.getAttribute("savedProductImg");
        if (imageUrl == null) {
            Part filePart = request.getPart("imgFile");
            if (filePart != null && filePart.getSize() > 0) {
                imageUrl = saveUploadedProductImage(filePart);
            }
        }
        if (imageUrl == null) {
            imageUrl = normalizeProductImagePath(currentImg);
        }

        // Save entered data for re-rendering on error
        request.setAttribute("failedAction", "update");
        request.setAttribute("enteredProductId", productId);
        request.setAttribute("enteredProductName", productName != null ? productName : "");
        request.setAttribute("enteredCategoryId", categoryId);
        request.setAttribute("enteredBrandId", brandId);
        request.setAttribute("enteredPrice", priceRaw != null ? priceRaw.trim() : "");
        request.setAttribute("enteredDescription", description != null ? description : "");
        request.setAttribute("enteredWarrantyMonths", warrantyMonthsRaw != null ? warrantyMonthsRaw.trim() : "");
        request.setAttribute("enteredCurrentImg", imageUrl);

        String[] specNames = request.getParameterValues("spec_names[]");
        String[] specValues = request.getParameterValues("spec_values[]");

        // If no specifications are submitted, reuse the existing specifications if the category did not change
        if (productId != null && (specNames == null || specNames.length == 0)) {
            Product originalProduct = productDAO.getProductById(productId);
            if (originalProduct == null) {
                originalProduct = productDAO.getProductByIdForAdmin(productId);
            }
            if (originalProduct != null && originalProduct.getCategoryId() == categoryId) {
                List<model.ProductSpecification> existingSpecs = productDAO.getSpecificationsByProductId(productId);
                if (existingSpecs != null && !existingSpecs.isEmpty()) {
                    specNames = new String[existingSpecs.size()];
                    specValues = new String[existingSpecs.size()];
                    for (int i = 0; i < existingSpecs.size(); i++) {
                        specNames[i] = existingSpecs.get(i).getSpecificationName();
                        specValues[i] = existingSpecs.get(i).getSpecificationValue();
                    }
                }
            }
        }

        if (categoryId != null) {
            List<CategorySpecTemplate> specTemplates = categoryDAO.getTemplatesByCategoryId(categoryId);
            request.setAttribute("specTemplates", specTemplates != null ? specTemplates : new java.util.ArrayList<>());
            request.setAttribute("enteredSpecNames", specNames);
            request.setAttribute("enteredSpecValues", specValues);
        }

        // Validate product ID
        if (productId == null) {
            request.setAttribute("error", "Sản phẩm không hợp lệ.");
            return false;
        }

        // Validate product name
        if (productName == null || productName.length() < 3 || productName.length() > 255) {
            request.setAttribute("error", "Tên sản phẩm phải từ 3 đến 255 ký tự.");
            return false;
        }

        // Validate category and brand
        if (categoryId == null || brandId == null) {
            request.setAttribute("error", "Danh mục hoặc thương hiệu không hợp lệ.");
            return false;
        }

        // Validate price
        if (priceRaw == null || priceRaw.trim().isEmpty()) {
            request.setAttribute("error", "Giá bán không được để trống.");
            return false;
        }
        
        try {
            price = new BigDecimal(priceRaw.trim());
            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("error", "Giá bán phải lớn hơn 0.");
                return false;
            }
            if (price.compareTo(new BigDecimal("1000000000")) >= 0) {
                request.setAttribute("error", "Giá bán phải nhỏ hơn 1 tỉ.");
                return false;
            }
            if (price.remainder(new BigDecimal("1000")).compareTo(BigDecimal.ZERO) != 0) {
                request.setAttribute("error", "Giá bán phải chia hết cho 1000.");
                return false;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Giá bán phải là số hợp lệ.");
            return false;
        }

        // Validate warranty months
        if (warrantyMonthsRaw == null || warrantyMonthsRaw.trim().isEmpty()) {
            request.setAttribute("error", "Bảo hành không được để trống.");
            return false;
        }
        
        try {
            warrantyMonths = Integer.parseInt(warrantyMonthsRaw.trim());
            if (warrantyMonths < 0) {
                request.setAttribute("error", "Bảo hành phải lớn hơn hoặc bằng 0.");
                return false;
            }
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Bảo hành phải là số hợp lệ.");
            return false;
        }

        // Validate description
        if (description == null || description.trim().isEmpty()) {
            request.setAttribute("error", "Mô tả chi tiết không được để trống.");
            return false;
        }

        // Validate specifications for required fields
        String specError = validateSpecifications(categoryId, specNames, specValues);
        if (specError != null) {
            request.setAttribute("error", specError);
            return false;
        }

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

        if (productId == null) {
            request.setAttribute("error", "Sản phẩm không hợp lệ.");
            return false;
        }

        if (productDAO.updateProductStatus(productId, newStatus)) {
            String statusMsg = "ACTIVE".equals(newStatus) ? "Kích hoạt" : "Vô hiệu hóa";
            session.setAttribute("productSuccess", statusMsg + " sản phẩm thành công.");
            return true;
        } else {
            request.setAttribute("error", "Không thể thay đổi trạng thái sản phẩm.");
            return false;
        }
    }

    //Lưu ảnh sản phẩm
    private String saveUploadedProductImage(Part filePart) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return null;
        }

        String submittedFileName = Paths.get(submittedName).getFileName().toString();
        String extension = getFileExtension(submittedFileName);
        if (extension.isEmpty()) {
            return null;
        }

        String uploadPath = getServletContext().getRealPath("/images/products");
        if (uploadPath == null) {
            return null;
        }

        Files.createDirectories(Path.of(uploadPath));

        String baseName = submittedFileName.substring(0, submittedFileName.length() - extension.length());
        baseName = baseName.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-");
        baseName = baseName.replaceAll("^-|-$", "");

        if (baseName.isEmpty()) {
            baseName = "product";
        }

        String fileName = baseName + "-" + System.currentTimeMillis() + extension;
        Path targetPath = Path.of(uploadPath, fileName);
        filePart.write(targetPath.toString());

        return "images/products/" + fileName;
    }

    private String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf(".");
        if (dotIndex < 0) {
            return "";
        }
        return fileName.substring(dotIndex).toLowerCase(Locale.ROOT);
    }

    private String normalizeProductImagePath(String value) {
        String img = normalizeText(value);
        if (img == null) {
            return null;
        }

        img = img.replace("\\", "/");

        while (img.startsWith("/")) {
            img = img.substring(1);
        }

        if (!img.contains("/")) {
            img = "images/products/" + img;
        }

        return img;
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

    private String validateSpecifications(Integer categoryId, String[] specNames, String[] specValues) {
        if (categoryId == null) {
            return null;
        }

        List<CategorySpecTemplate> specTemplates = categoryDAO.getTemplatesByCategoryId(categoryId);
        if (specTemplates == null || specTemplates.isEmpty()) {
            return null;
        }

        // Check for required specifications
        for (CategorySpecTemplate template : specTemplates) {
            if (template.isRequired()) {
                boolean found = false;
                if (specNames != null && specValues != null) {
                    for (int i = 0; i < specNames.length && i < specValues.length; i++) {
                        if (template.getSpecName().equalsIgnoreCase(specNames[i])) {
                            String value = specValues[i];
                            if (value != null && !value.trim().isEmpty()) {
                                found = true;
                                break;
                            }
                        }
                    }
                }
                if (!found) {
                    return "Thông số kỹ thuật '" + template.getSpecName() + "' là bắt buộc.";
                }
            }
        }

        return null;
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
