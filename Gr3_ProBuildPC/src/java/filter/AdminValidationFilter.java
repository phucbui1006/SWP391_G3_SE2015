package filter;

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
import util.ValidatorUtil;

@WebFilter(filterName = "AdminValidationFilter", urlPatterns = {
    "/AdminBrands",
    "/admin/products",
    "/admin/categories",
    "/BatchServlet"
})
public class AdminValidationFilter implements Filter {

    private static final String BRAND_IMAGE_ADD_ERROR = "Vui lòng chọn logo PNG, JPG, JPEG hoặc WEBP, tối đa 2MB.";
    private static final String BRAND_IMAGE_UPDATE_ERROR = "Logo chỉ chấp nhận PNG, JPG, JPEG hoặc WEBP và tối đa 2MB.";

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

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        boolean isValid = true;

        if ("/AdminBrands".equalsIgnoreCase(path)) {
            isValid = validateBrand(req, res);
        } else if ("/admin/products".equalsIgnoreCase(path)) {
            isValid = validateProduct(req, res);
        } else if ("/admin/categories".equalsIgnoreCase(path)) {
            isValid = validateCategory(req, res);
        } else if ("/BatchServlet".equalsIgnoreCase(path)) {
            isValid = validateBatch(req, res);
        }

        if (isValid) {
            chain.doFilter(request, response);
        }
    }

    @Override
    public void destroy() {}

    private boolean validateBrand(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (!"add".equalsIgnoreCase(action) && !"update".equalsIgnoreCase(action)) {
            return true;
        }

        String error = null;
        if (!ValidatorUtil.isValidBrandName(req.getParameter("brandName"))) {
            error = "Tên thương hiệu chứa từ 2-20 kí tự.";
        } else {
            boolean imageRequired = "add".equalsIgnoreCase(action);
            try {
                Part imagePart = req.getPart("imgFile");
                if (!ValidatorUtil.isAllowedBrandImage(imagePart, imageRequired)) {
                    error = getBrandImageError(imageRequired);
                }
            } catch (IllegalStateException e) {
                error = getBrandImageError(imageRequired);
            }
        }

        if (error == null) {
            return true;
        }

        req.getSession().setAttribute("brandError", error);
        res.sendRedirect(req.getContextPath() + "/AdminBrands");
        return false;
    }

    private String getBrandImageError(boolean imageRequired) {
        return imageRequired ? BRAND_IMAGE_ADD_ERROR : BRAND_IMAGE_UPDATE_ERROR;
    }

    private boolean validateProduct(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (!"add".equalsIgnoreCase(action) && !"update".equalsIgnoreCase(action)) {
            return true;
        }

        String productName = req.getParameter("productName");
        String categoryIdStr = req.getParameter("categoryId");
        String brandIdStr = req.getParameter("brandId");
        String priceRaw = req.getParameter("price");
        String warrantyMonthsRaw = req.getParameter("warrantyMonths");

        String error = null;

        if (productName == null || productName.trim().length() < 3 || productName.trim().length() > 255) {
            error = "Tên sản phẩm phải từ 3 đến 255 ký tự.";
        } else if (categoryIdStr == null || brandIdStr == null || categoryIdStr.trim().isEmpty() || brandIdStr.trim().isEmpty()) {
            error = "Danh mục hoặc thương hiệu không hợp lệ.";
        } else {
            try {
                java.math.BigDecimal price = new java.math.BigDecimal(priceRaw);
                if (price.compareTo(java.math.BigDecimal.ZERO) < 0) {
                    error = "Giá bán không được nhỏ hơn 0.";
                }
            } catch (Exception e) {
                error = "Giá bán không hợp lệ.";
            }

            if (error == null && warrantyMonthsRaw != null && !warrantyMonthsRaw.trim().isEmpty()) {
                try {
                    int warrantyMonths = Integer.parseInt(warrantyMonthsRaw);
                    if (warrantyMonths < 0) {
                        error = "Thời gian bảo hành không được nhỏ hơn 0.";
                    }
                } catch (Exception e) {
                    error = "Thời gian bảo hành không hợp lệ.";
                }
            }
        }

        if (error == null) {
            try {
                Part filePart = req.getPart("imgFile");
                if (filePart != null && filePart.getSize() > 0) {
                    if (filePart.getSize() > 2 * 1024 * 1024) {
                        error = "File không hợp lệ hoặc vượt quá 2MB!";
                    } else {
                        String submittedName = filePart.getSubmittedFileName();
                        if (submittedName == null || !filePart.getContentType().startsWith("image/") || 
                            (!submittedName.toLowerCase().endsWith(".png") && 
                             !submittedName.toLowerCase().endsWith(".jpg") && 
                             !submittedName.toLowerCase().endsWith(".jpeg") && 
                             !submittedName.toLowerCase().endsWith(".webp"))) {
                            error = "File không hợp lệ hoặc vượt quá 2MB!";
                        }
                    }
                }
            } catch (Exception e) {
                // Ignore if not multipart or parsing fails
            }
        }

        if (error != null) {
            req.getSession().setAttribute("productError", error);
            // Must preserve inputs manually in filter if we redirect back
            // To simplify, we just redirect. The user will have to re-enter.
            // But this is an Admin CRUD. We'll accept redirect for now.
            res.sendRedirect(req.getContextPath() + "/admin/products");
            return false;
        }

        return true;
    }

    private boolean validateCategory(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (!"add".equalsIgnoreCase(action) && !"update".equalsIgnoreCase(action)) {
            return true;
        }

        String categoryName = req.getParameter("categoryName");
        String error = null;

        if (categoryName == null || categoryName.trim().length() < 2 || categoryName.trim().length() > 100) {
            error = "Tên danh mục phải từ 2 đến 100 ký tự.";
        }

        if ("update".equalsIgnoreCase(action) && error == null) {
            String newStatus = req.getParameter("status");
            if (newStatus == null || (!"ACTIVE".equalsIgnoreCase(newStatus.trim()) && !"INACTIVE".equalsIgnoreCase(newStatus.trim()))) {
                error = "Trạng thái không hợp lệ.";
            }
        }

        if (error != null) {
            req.getSession().setAttribute("categoryError", error);
            res.sendRedirect(req.getContextPath() + "/admin/categories");
            return false;
        }

        return true;
    }

    private boolean validateBatch(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (!"addBatch".equalsIgnoreCase(action) && !"updateBatch".equalsIgnoreCase(action)) {
            return true;
        }

        String batchName = req.getParameter("batchName");
        String dateRaw = req.getParameter("date");
        String error = null;

        if (batchName == null || batchName.trim().isEmpty() || dateRaw == null || dateRaw.trim().isEmpty()) {
            error = "Vui lòng nhập đầy đủ tên lô hàng và ngày nhập.";
        } else if (!batchName.trim().matches("^[\\p{L}\\p{N}\\s]+$")) {
            error = "Tên lô hàng không được chứa kí tự đặc biệt";
        } else {
            try {
                java.sql.Date inputDate = java.sql.Date.valueOf(dateRaw);
                java.sql.Date currentDate = java.sql.Date.valueOf(java.time.LocalDate.now());
                if (inputDate.after(currentDate)) {
                    error = "Ngày nhập lô hàng không được lớn hơn ngày hiện tại.";
                }
            } catch (IllegalArgumentException e) {
                error = "Ngày nhập không hợp lệ.";
            }
        }

        if (error != null) {
            req.setAttribute("error", error);
            // Must forward to keep other data loaded in servlet, but this is a filter.
            // Normally batch validation might forward back, but BatchServlet loads data before forwarding.
            // We'll redirect with error in session or simply use session flash message.
            req.getSession().setAttribute("batchError", error);
            res.sendRedirect(req.getContextPath() + "/BatchServlet");
            return false;
        }

        return true;
    }
}
