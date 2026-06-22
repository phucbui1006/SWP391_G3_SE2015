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
    "/AdminBrands"
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
}
