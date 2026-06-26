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
        maxFileSize = 2 * 1024 * 1024, // 2MB constraint
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
            // For add/update failures, use clean defaults to avoid product form
            // parameters (categoryId, brandId) from corrupting dashboard filters
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

    //Thêm sản phẩm, kiểm tra điều kiện
    private boolean handleAdd(HttpServletRequest request, HttpSession session) throws IOException, ServletException {
        String productName = normalizeText(request.getParameter("productName"));
        Integer categoryId = parseId(request.getParameter("categoryId"));
        Integer brandId = parseId(request.getParameter("brandId"));
        String priceRaw = request.getParameter("price");
        String warrantyMonthsRaw = request.getParameter("warrantyMonths");
        String description = normalizeText(request.getParameter("description"));

        // Read spec data early so it can be preserved on validation failure
        String[] specNames = request.getParameterValues("spec_names[]");
        String[] specValues = request.getParameterValues("spec_values[]");

        request.setAttribute("enteredProductName", productName);
        request.setAttribute("enteredCategoryId", categoryId);
        request.setAttribute("enteredBrandId", brandId);
        request.setAttribute("enteredPrice", priceRaw);
        request.setAttribute("enteredWarrantyMonths", warrantyMonthsRaw);
        request.setAttribute("enteredDescription", description);
        request.setAttribute("failedAction", "add");
        request.setAttribute("enteredSpecNames", specNames);
        request.setAttribute("enteredSpecValues", specValues);

        // Attach spec templates for server-side re-rendering if category is selected
        if (categoryId != null) {
            List<CategorySpecTemplate> specTemplates = categoryDAO.getTemplatesByCategoryId(categoryId);
            if (specTemplates != null) {
                specTemplates.removeIf(t -> "INACTIVE".equalsIgnoreCase(t.getStatus()));
            }
            request.setAttribute("specTemplates", specTemplates);
        }

        if (productName == null || productName.length() < 3 || productName.length() > 255) {
            request.setAttribute("error", "Tên sản phẩm phải từ 3 đến 255 ký tự.");
            return false;
        }

        BigDecimal price;
        try {
            price = new BigDecimal(priceRaw);
        } catch (Exception e) {
            price = BigDecimal.ZERO;
        }

        int warrantyMonths = 0;
        try {
            if (warrantyMonthsRaw != null && !warrantyMonthsRaw.trim().isEmpty()) {
                warrantyMonths = Integer.parseInt(warrantyMonthsRaw);
            }
        } catch (Exception e) {
        }

        Part filePart = request.getPart("imgFile");
        String imageUrl = null;
        if (filePart != null && filePart.getSize() > 0) {
            String submittedName = filePart.getSubmittedFileName();
            String extension = getAllowedImageExtension(submittedName);
            if (extension == null || !filePart.getContentType().startsWith("image/")) {
                request.setAttribute("error", "File không hợp lệ hoặc vượt quá 2MB!");
                return false;
            }

            imageUrl = saveUploadedProductImage(filePart);
            if (imageUrl == null) {
                request.setAttribute("error", "Không thể lưu hình ảnh sản phẩm.");
                return false;
            }
        }

        String specError = validateProductSpecifications(categoryId, specNames, specValues);
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
        Integer productId = parseId(request.getParameter("productId"));
        String productName = normalizeText(request.getParameter("productName"));
        Integer categoryId = parseId(request.getParameter("categoryId"));
        Integer brandId = parseId(request.getParameter("brandId"));
        String priceRaw = request.getParameter("price");
        String warrantyMonthsRaw = request.getParameter("warrantyMonths");
        String description = normalizeText(request.getParameter("description"));
        String currentImg = normalizeText(request.getParameter("currentImg"));

        // Read spec data early so it can be preserved on validation failure
        String[] specNames = request.getParameterValues("spec_names[]");
        String[] specValues = request.getParameterValues("spec_values[]");

        // Store entered inputs to return on forward
        request.setAttribute("enteredProductId", productId);
        request.setAttribute("enteredProductName", productName);
        request.setAttribute("enteredCategoryId", categoryId);
        request.setAttribute("enteredBrandId", brandId);
        request.setAttribute("enteredPrice", priceRaw);
        request.setAttribute("enteredWarrantyMonths", warrantyMonthsRaw);
        request.setAttribute("enteredDescription", description);
        request.setAttribute("enteredCurrentImg", currentImg);
        request.setAttribute("failedAction", "update");
        request.setAttribute("enteredSpecNames", specNames);
        request.setAttribute("enteredSpecValues", specValues);

        // Attach spec templates for server-side re-rendering if category is selected
        if (categoryId != null) {
            List<CategorySpecTemplate> specTemplates = categoryDAO.getTemplatesByCategoryId(categoryId);
            if (specTemplates != null) {
                specTemplates.removeIf(t -> "INACTIVE".equalsIgnoreCase(t.getStatus()));
            }
            request.setAttribute("specTemplates", specTemplates);
        }

        if (productId == null) {
            request.setAttribute("error", "Sản phẩm không hợp lệ.");
            return false;
        }
        if (productName == null || productName.length() < 3 || productName.length() > 255) {
            request.setAttribute("error", "Tên sản phẩm phải từ 3 đến 255 ký tự.");
            return false;
        }
        if (categoryId == null || brandId == null) {
            request.setAttribute("error", "Danh mục hoặc thương hiệu không hợp lệ.");
            return false;
        }
        if (description == null || description.trim().isEmpty()) {
            request.setAttribute("error", "Mô tả chi tiết không được để trống.");
            return false;
        }

        BigDecimal price;
        try {
            price = new BigDecimal(priceRaw);
        } catch (Exception e) {
            price = BigDecimal.ZERO;
        }

        int warrantyMonths = 0;
        try {
            if (warrantyMonthsRaw != null && !warrantyMonthsRaw.trim().isEmpty()) {
                warrantyMonths = Integer.parseInt(warrantyMonthsRaw);
            }
        } catch (Exception e) {
        }

        Part filePart = request.getPart("imgFile");
        String imageUrl = null;

        if (filePart != null && filePart.getSize() > 0) {
            String submittedName = filePart.getSubmittedFileName();
            String extension = getAllowedImageExtension(submittedName);
            if (extension == null || !filePart.getContentType().startsWith("image/")) {
                request.setAttribute("error", "File không hợp lệ hoặc vượt quá 2MB!");
                return false;
            }

            String newImg = saveUploadedProductImage(filePart);
            if (newImg == null) {
                request.setAttribute("error", "Không thể lưu hình ảnh sản phẩm.");
                return false;
            }
            imageUrl = newImg;
        }

        if (imageUrl == null) {
            imageUrl = normalizeProductImagePath(currentImg);
        }

        String specError = validateProductSpecifications(categoryId, specNames, specValues);
        if (specError != null) {
            request.setAttribute("error", specError);
            return false;
        }

        if (productDAO.updateProduct(productId, productName, categoryId, brandId, price, description, imageUrl, specNames, specValues)) {
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

    //Kiểm tra file ảnh
    private String getAllowedImageExtension(String fileName) {
        if (fileName == null) {
            return null;
        }
        String lowerName = fileName.toLowerCase(Locale.ROOT);
        if (lowerName.endsWith(".png")) {
            return ".png";
        }
        if (lowerName.endsWith(".jpg")) {
            return ".jpg";
        }
        if (lowerName.endsWith(".jpeg")) {
            return ".jpeg";
        }
        if (lowerName.endsWith(".webp")) {
            return ".webp";
        }
        return null;
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

    private String validateProductSpecifications(Integer categoryId, String[] specNames, String[] specValues) {
        if (categoryId == null) {
            return null;
        }

        List<CategorySpecTemplate> templates = categoryDAO.getTemplatesByCategoryId(categoryId);
        if (templates != null) {
            templates.removeIf(t -> "INACTIVE".equalsIgnoreCase(t.getStatus()));
        }
        if (templates == null || templates.isEmpty()) {
            return null; // Category has no spec templates
        }

        if (specNames == null || specValues == null || specNames.length == 0 || specValues.length == 0) {
            return "Vui lòng lựa chọn và nhập đầy đủ thông số kỹ thuật theo danh mục.";
        }

        int specLength = Math.min(specNames.length, specValues.length);

        for (CategorySpecTemplate template : templates) {
            boolean found = false;
            String value = null;

            // Find corresponding value in specNames & specValues
            for (int i = 0; i < specLength; i++) {
                String name = specNames[i];
                if (name != null && name.trim().equalsIgnoreCase(template.getSpecName())) {
                    found = true;
                    value = specValues[i];
                    break;
                }
            }

            // Enforce non-empty validation only if the template is required
            if (template.isRequired()) {
                if (!found || value == null || value.trim().isEmpty()) {
                    return "Thông số '" + template.getSpecName() + "' không được để trống.";
                }
            }

            // Check numeric type validation and enforce strictly positive numbers (> 0) only if value is provided
            if (found && value != null && !value.trim().isEmpty()) {
                if ("NUMBER".equalsIgnoreCase(template.getSpecType())) {
                    try {
                        double val = Double.parseDouble(value.trim());
                        if (val <= 0) {
                            return "Thông số kỹ thuật dạng số phải lớn hơn 0.";
                        }
                    } catch (NumberFormatException e) {
                        return "Thông số '" + template.getSpecName() + "' phải là một số hợp lệ.";
                    }

                    // Validate allowed values of the template configuration
                    String allowed = template.getAllowedValues();
                    if (allowed != null && !allowed.trim().isEmpty()) {
                        String[] values = allowed.split(",");
                        for (String valStr : values) {
                            try {
                                double parsed = Double.parseDouble(valStr.trim());
                                if (parsed <= 0) {
                                    return "Các giá trị cấu hình cho thông số dạng số phải lớn hơn 0.";
                                }
                            } catch (NumberFormatException e) {
                                return "Các giá trị cấu hình cho thông số dạng số phải lớn hơn 0.";
                            }
                        }
                    }
                }
            }
        }
        return null;
    }
}
