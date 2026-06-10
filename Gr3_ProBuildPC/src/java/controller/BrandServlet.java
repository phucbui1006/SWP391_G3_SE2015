package controller;

import dal.BrandDAO;
import dal.CartDAO;
import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Brand;
import model.Product;
import model.User;

@WebServlet(name = "BrandServlet", urlPatterns = {"/brands"})
public class BrandServlet extends HttpServlet {

    private final BrandDAO brandDAO = new BrandDAO();
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        Integer brandId = parseInt(request.getParameter("brandId"));
        String priceRange = normalize(request.getParameter("priceRange"), "all");
        String sort = normalize(request.getParameter("sort"), "newest");
        String keyword = normalize(request.getParameter("keyword"), "");

        List<Brand> brands = brandDAO.getActiveBrands();
        Brand selectedBrand = brandId == null ? null : brandDAO.getBrandById(brandId);
        if (selectedBrand != null && !"ACTIVE".equalsIgnoreCase(selectedBrand.getStatus())) {
            selectedBrand = null;
            brandId = null;
        }
        List<Product> products = productDAO.getProductsByBrand(brandId, priceRange, sort, keyword);

        request.setAttribute("brands", brands);
        request.setAttribute("products", products);
        request.setAttribute("selectedBrand", selectedBrand);
        request.setAttribute("selectedBrandId", brandId);
        request.setAttribute("selectedPriceRange", priceRange);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("keyword", keyword);

        setCartCount(request);
        request.getRequestDispatcher("/views/brands.jsp").forward(request, response);
    }

    private Integer parseInt(String value) {
        try {
            return value == null || value.trim().isEmpty() ? null : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalize(String value, String defaultValue) {
        return value == null || value.trim().isEmpty() ? defaultValue : value.trim();
    }

    private void setCartCount(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }

        User account = (User) session.getAttribute("account");
        if (account != null && account.isCustomer()) {
            request.setAttribute("cartItemCount", new CartDAO().getCartItemCountByCustomerId(account.getCustomerId()));
        }
    }
}
