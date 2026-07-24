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
    "/admin/categories",
    "/BatchServlet"
})
public class AdminValidationFilter implements Filter {

    private static final String BRAND_IMAGE_ADD_ERROR = "Vui lòng chọn logo PNG, JPG, JPEG hoặc WEBP, tối đa 2MB.";
    private static final String BRAND_IMAGE_UPDATE_ERROR = "Logo chỉ chấp nhận PNG, JPG, JPEG hoặc WEBP và tối đa 2MB.";

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

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
    public void destroy() {
    }

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

    private boolean validateCategory(HttpServletRequest req, HttpServletResponse res) throws IOException {
        String action = req.getParameter("action");
        String error = null;

        if ("add".equalsIgnoreCase(action)) {
            String categoryName = req.getParameter("categoryName");
            String nameError = ValidatorUtil.getCategoryNameError(categoryName);

            if (nameError != null) {
                return redirectCategoryNameError(req, res, "add", nameError, categoryName, null);
            }

        } else if ("update".equalsIgnoreCase(action)) {
            String categoryId = req.getParameter("categoryId");

            if (!ValidatorUtil.isValidCategoryId(categoryId)) {
                error = "Danh mục không hợp lệ.";
            } else {
                String categoryName = req.getParameter("categoryName");
                String nameError = ValidatorUtil.getCategoryNameError(categoryName);

                if (nameError != null) {
                    return redirectCategoryNameError(req, res, "edit", nameError, categoryName, categoryId);
                }
            }
        } else if ("delete".equalsIgnoreCase(action) || "activate".equalsIgnoreCase(action)) {
            if (!ValidatorUtil.isValidCategoryId(req.getParameter("categoryId"))) {
                error = "Danh mục không hợp lệ.";
            }
        } else {
            error = "Thao tác danh mục không hợp lệ.";
        }

        if (error != null) {
            req.getSession().setAttribute("categoryError", error);
            res.sendRedirect(req.getContextPath() + "/admin/categories");
            return false;
        }

        return true;
    }

    private boolean redirectCategoryNameError(HttpServletRequest req, HttpServletResponse res,
            String modal, String error, String categoryName, String categoryId) throws IOException {
        if ("add".equals(modal)) {
            req.getSession().setAttribute("addCategoryNameError", error);
            req.getSession().setAttribute("addCategoryOldName", categoryName);
            res.sendRedirect(req.getContextPath() + "/admin/categories#addCategoryModal");
        } else {
            req.getSession().setAttribute("editCategoryNameError", error);
            req.getSession().setAttribute("editCategoryOldName", categoryName);
            req.getSession().setAttribute("editCategoryOldId", categoryId);
            res.sendRedirect(req.getContextPath() + "/admin/categories#editCategoryModal");
        }

        return false;
    }

    private boolean validateBatch(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (!"addBatch".equalsIgnoreCase(action)) {
            return true;
        }

        String batchName = req.getParameter("batchName");
        String dateRaw = req.getParameter("date");
        String error = null;

        if (batchName == null || batchName.trim().isEmpty() || dateRaw == null || dateRaw.trim().isEmpty()) {
            error = "Vui lòng nhập đầy đủ tên lô hàng và ngày nhập.";
        } else if (!batchName.trim().matches("^[\\p{L}\\p{N}\\s\\-_/()]+$")) {
            error = "Tên lô hàng không được chứa ký tự đặc biệt.";
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
            req.getSession().setAttribute("batchError", error);
            req.getSession().setAttribute("enteredBatchName", batchName);
            req.getSession().setAttribute("enteredDate", dateRaw);
            res.sendRedirect(req.getContextPath() + "/BatchServlet#add-batch-modal");
            return false;
        }

        return true;
    }
}
