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
import model.ProductSpecification;
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

            boolean hasImage = "true".equals(request.getParameter("hasImage"));
            if (hasImage) {
                List<Review> filteredReviews = new java.util.ArrayList<>();
                for (Review r : reviews) {
                    if (r.getImages() != null && !r.getImages().isEmpty()) {
                        filteredReviews.add(r);
                    }
                }
                reviews = filteredReviews;
            }

            int page = 1;
            String pageRaw = request.getParameter("page");
            if (pageRaw != null && !pageRaw.trim().isEmpty()) {
                try {
                    page = Integer.parseInt(pageRaw);
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            int pageSize = 5;
            int totalReviewsCount = reviews.size();
            int totalPages = (int) Math.ceil((double) totalReviewsCount / pageSize);

            if (page < 1) page = 1;
            if (page > totalPages && totalPages > 0) page = totalPages;

            int startIndex = (page - 1) * pageSize;
            int endIndex = Math.min(startIndex + pageSize, totalReviewsCount);
            
            List<Review> pagedReviews = new java.util.ArrayList<>();
            if (totalReviewsCount > 0) {
                pagedReviews = reviews.subList(startIndex, endIndex);
            }

            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("selectedRating", selectedRating);
            request.setAttribute("hasImage", hasImage);
            double avgRating = productDAO.getAverageRating(productId);

            List<Product> similarProducts = productDAO.getSimilarProducts(productId);
            List<ProductSpecification> specList = productDAO.getSpecificationsByProductId(productId);

            request.setAttribute("product", product);
            request.setAttribute("specifications", specList);
            request.setAttribute("reviews", pagedReviews);
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
