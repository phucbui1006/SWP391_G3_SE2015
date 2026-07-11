package controller;

import dal.CartDAO;
import dal.ProductDAO;
import dal.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
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

        String idRaw = request.getParameter("id");

        if (idRaw == null || idRaw.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        try {
            int productId = Integer.parseInt(idRaw);

            int selectedRating = parseRating(request.getParameter("rating"));

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

            double avgRating = productDAO.getAverageRating(productId);
            int fullStars = (int) avgRating;

            List<Product> similarProducts = productDAO.getSimilarProducts(productId);
            List<ProductSpecification> specList =
                    productDAO.getSpecificationsByProductId(productId);

            int count1 = 0;
            int count2 = 0;
            int count3 = 0;
            int count4 = 0;
            int count5 = 0;

            if (allReviews != null) {
                for (Review r : allReviews) {
                    switch (r.getRating()) {
                        case 5:
                            count5++;
                            break;
                        case 4:
                            count4++;
                            break;
                        case 3:
                            count3++;
                            break;
                        case 2:
                            count2++;
                            break;
                        case 1:
                            count1++;
                            break;
                    }
                }
            }

            int totalAllReviews = allReviews == null ? 0 : allReviews.size();

            int pct1 = calculatePercent(count1, totalAllReviews);
            int pct2 = calculatePercent(count2, totalAllReviews);
            int pct3 = calculatePercent(count3, totalAllReviews);
            int pct4 = calculatePercent(count4, totalAllReviews);
            int pct5 = calculatePercent(count5, totalAllReviews);

            int maxQuantity = product.getQuantity() > 0 ? product.getQuantity() : 1;

            String currentUrl = request.getContextPath()
                    + "/product-detail?id=" + productId;

            if (selectedRating > 0) {
                currentUrl += "&rating=" + selectedRating;
            }

            request.setAttribute("product", product);
            request.setAttribute("specifications", specList);
            request.setAttribute("reviews", reviews);
            request.setAttribute("allReviews", allReviews);
            request.setAttribute("avgRating", avgRating);
            request.setAttribute("fullStars", fullStars);
            request.setAttribute("similarProducts", similarProducts);

            request.setAttribute("selectedRating", selectedRating);
            request.setAttribute("totalAllReviews", totalAllReviews);

            request.setAttribute("count1", count1);
            request.setAttribute("count2", count2);
            request.setAttribute("count3", count3);
            request.setAttribute("count4", count4);
            request.setAttribute("count5", count5);

            request.setAttribute("pct1", pct1);
            request.setAttribute("pct2", pct2);
            request.setAttribute("pct3", pct3);
            request.setAttribute("pct4", pct4);
            request.setAttribute("pct5", pct5);

            request.setAttribute("maxQuantity", maxQuantity);
            request.setAttribute("currentUrl", currentUrl);

            handleSessionMessage(request);

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

            request.getRequestDispatcher("/views/product-detail.jsp")
                    .forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/home");
        }
    }

    private int parseRating(String ratingRaw) {
        if (ratingRaw == null || ratingRaw.trim().isEmpty()) {
            return 0;
        }

        try {
            int rating = Integer.parseInt(ratingRaw);

            if (rating < 1 || rating > 5) {
                return 0;
            }

            return rating;
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private int calculatePercent(int count, int total) {
        if (total == 0) {
            return 0;
        }

        return count * 100 / total;
    }

    private void handleSessionMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null) {
            return;
        }

        String cartMessage = (String) session.getAttribute("cartMessage");
        String cartMessageType = (String) session.getAttribute("cartMessageType");

        if (cartMessageType == null) {
            cartMessageType = "success";
        }

        request.setAttribute("cartMessage", cartMessage);
        request.setAttribute("cartMessageType", cartMessageType);

        session.removeAttribute("cartMessage");
        session.removeAttribute("cartMessageType");
    }
}