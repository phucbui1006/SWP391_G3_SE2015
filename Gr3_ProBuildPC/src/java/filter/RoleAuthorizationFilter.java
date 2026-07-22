package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;
import model.User;

/**
 * Central route authorization. UI visibility is not a security boundary, so every
 * protected route is checked again before its servlet is invoked.
 */
@WebFilter(filterName = "RoleAuthorizationFilter", urlPatterns = {"/*"})
public class RoleAuthorizationFilter implements Filter {

    private static final Set<String> ADMIN_ONLY_PATHS = Set.of(
            "/accountmanagement",
            "/adminbrands",
            "/admin/products",
            "/admin/categories",
            "/batchservlet",
            "/batchitemservlet",
            "/revenueservlet",
            "/revenueexportservlet",
            "/getcategorytemplates"
    );

    private static final Set<String> CUSTOMER_FACING_PATHS = Set.of(
            "/home",
            "/build-pc",
            "/buildpc",
            "/categories",
            "/brands",
            "/product-detail",
            "/cart",
            "/checkout",
            "/shipping-address",
            "/warranty-lookup",
            "/warrantylookup",
            "/warranty-history",
            "/warrantyhistory",
            "/submit-review",
            "/vnpay-retry"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        String path = getPath(req);
        User account = getAccount(req);

        // JSPs are implementation views and must only be reached through a servlet forward.
        if (path.startsWith("/views/") || path.startsWith("/includes/")) {
            res.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (ADMIN_ONLY_PATHS.contains(path)) {
            if (account == null) {
                redirectLogin(req, res);
            } else if (!hasRole(account, "ADMIN")) {
                denyOrRedirect(req, res, account);
            } else {
                chain.doFilter(request, response);
            }
            return;
        }

        if ("/dashboard".equals(path)) {
            if (account == null) {
                redirectLogin(req, res);
            } else if (account.isCustomer()) {
                res.sendRedirect(req.getContextPath() + "/home");
            } else if (account.isStaff()) {
                chain.doFilter(request, response);
            } else {
                denyOrRedirect(req, res, account);
            }
            return;
        }

        if ("/managewarranty".equals(path) || "/manage-warranty".equals(path)) {
            if (account == null) {
                redirectLogin(req, res);
            } else if (hasRole(account, "ADMIN") || hasRole(account, "EMPLOYEE")) {
                chain.doFilter(request, response);
            } else {
                denyOrRedirect(req, res, account);
            }
            return;
        }

        // Guests may browse the storefront. Once logged in, only customers may use it.
        if (CUSTOMER_FACING_PATHS.contains(path) && account != null && !account.isCustomer()) {
            denyOrRedirect(req, res, account);
            return;
        }

        chain.doFilter(request, response);
    }

    private String getPath(HttpServletRequest request) {
        String path = request.getServletPath();
        if (path == null || path.isEmpty()) {
            path = "/";
        }
        int pathParameterIndex = path.indexOf(';');
        if (pathParameterIndex >= 0) {
            path = path.substring(0, pathParameterIndex);
        }
        while (path.length() > 1 && path.endsWith("/")) {
            path = path.substring(0, path.length() - 1);
        }
        return path.toLowerCase(java.util.Locale.ROOT);
    }

    private User getAccount(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute("account");
        return value instanceof User ? (User) value : null;
    }

    private boolean hasRole(User account, String expectedRole) {
        return account != null
                && account.getRoleName() != null
                && expectedRole.equalsIgnoreCase(account.getRoleName().trim());
    }

    private void redirectLogin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/Login");
    }

    private void denyOrRedirect(HttpServletRequest request, HttpServletResponse response, User account)
            throws IOException {
        if (isAjaxRequest(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String target = account != null && account.isCustomer() ? "/home" : "/Dashboard";
        response.sendRedirect(request.getContextPath() + target);
    }

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        String accept = request.getHeader("Accept");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith)
                || (accept != null && accept.toLowerCase(java.util.Locale.ROOT).contains("application/json"));
    }
}
