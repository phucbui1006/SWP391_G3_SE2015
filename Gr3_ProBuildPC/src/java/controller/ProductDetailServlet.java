package controller;

import dal.CartDAO;
import dal.ProductDAO;
import dal.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import model.Product;
import model.Review;
import model.User;

@WebServlet(name = "ProductDetailServlet", urlPatterns = {"/product-detail"})
public class ProductDetailServlet extends HttpServlet {

    private final ProductDAO productDAO = new ProductDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        int selectedRating = 0;

        String ratingRaw = request.getParameter("rating");
        if (ratingRaw != null && !ratingRaw.trim().isEmpty()) {
            try {
                selectedRating = Integer.parseInt(ratingRaw);
            } catch (NumberFormatException e) {
                selectedRating = 0;
            }
        }

        if (selectedRating < 0 || selectedRating > 5) {
            selectedRating = 0;
        }

        String idRaw = request.getParameter("id");

        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            int productId = Integer.parseInt(idRaw);

            Product product = productDAO.getProductById(productId);

            if (product == null) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }

            List<Review> allReviews = reviewDAO.getReviewsByProductId(productId);
            List<Review> reviews;

            if (selectedRating == 0) {
                reviews = allReviews;
            } else {
                reviews = reviewDAO.getReviewsByProductIdAndRating(productId, selectedRating);
            }

            request.setAttribute("selectedRating", selectedRating);
            double avgRating = productDAO.getAverageRating(productId);

            List<Product> similarProducts = productDAO.getSimilarProducts(productId);

            request.setAttribute("product", product);
            request.setAttribute("reviews", reviews);
            request.setAttribute("allReviews", allReviews);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("similarProducts", similarProducts);

            HttpSession session = request.getSession(false);
            if (session != null) {
                User account = (User) session.getAttribute("account");

                if (account != null && account.isCustomer()) {
                    CartDAO cartDAO = new CartDAO();
                    request.setAttribute(
                            "cartItemCount",
                            cartDAO.getCartItemCountByCustomerId(account.getCustomerId())
                    );
                }
            }

            request.getRequestDispatcher("/views/product-detail.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }
}
