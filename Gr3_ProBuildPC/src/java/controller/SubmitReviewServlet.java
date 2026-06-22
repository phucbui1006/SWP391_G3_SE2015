package controller;

import dal.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import model.Review;
import model.User;

@WebServlet(name = "SubmitReviewServlet", urlPatterns = {"/submit-review"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 1024 * 1024 * 5,    // 5MB
        maxRequestSize = 1024 * 1024 * 15 // 15MB
)
public class SubmitReviewServlet extends HttpServlet {

    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        if (account == null || !account.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        String orderIdRaw = request.getParameter("orderId");
        String productIdRaw = request.getParameter("productId");
        String ratingRaw = request.getParameter("rating");
        String comment = request.getParameter("comment");
        String clearImagesRaw = request.getParameter("clearImages");
        String keepImagesRaw = request.getParameter("keepImages");

        try {
            int productId = Integer.parseInt(productIdRaw);
            int rating = Integer.parseInt(ratingRaw);
            int customerId = account.getCustomerId();

            // Get uploaded image parts with name "imgFiles"
            List<Part> imgParts = new ArrayList<>();
            for (Part part : request.getParts()) {
                if ("imgFiles".equals(part.getName()) && part.getSize() > 0) {
                    imgParts.add(part);
                }
            }

            // Process and save uploaded images
            List<String> uploadedImages = new ArrayList<>();
            for (Part part : imgParts) {
                String imgPath = saveUploadedReviewImage(part);
                if (imgPath != null) {
                    uploadedImages.add(imgPath);
                }
            }

            boolean clearImages = "true".equalsIgnoreCase(clearImagesRaw);

            // Check if there is an existing review
            Review existingReview = reviewDAO.getReviewByCustomerAndProduct(customerId, productId);
            boolean success;

            if (existingReview != null) {
                // Update existing review
                existingReview.setRating(rating);
                existingReview.setComment(comment);
                existingReview.setDate(new Date());
                
                List<String> finalImages = new ArrayList<>();
                if (keepImagesRaw != null && !keepImagesRaw.trim().isEmpty()) {
                    String[] parts = keepImagesRaw.split(",");
                    for (String p : parts) {
                        if (!p.trim().isEmpty()) {
                            finalImages.add(p.trim());
                        }
                    }
                }
                finalImages.addAll(uploadedImages);
                existingReview.setImages(finalImages);
                
                success = reviewDAO.updateReview(existingReview);
            } else {
                // Insert new review
                Review r = new Review();
                r.setCustomerId(customerId);
                r.setProductId(productId);
                r.setRating(rating);
                r.setComment(comment);
                r.setDate(new Date());
                r.setImages(uploadedImages);
                
                success = reviewDAO.addReview(r);
            }

            if (success) {
                session.setAttribute("orderHistorySuccess", "Gửi đánh giá sản phẩm thành công!");
            } else {
                session.setAttribute("orderHistoryError", "Có lỗi xảy ra khi lưu đánh giá. Vui lòng thử lại.");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("orderHistoryError", "Thông tin đánh giá không hợp lệ.");
        }

        redirectBack(request, response, orderIdRaw);
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, String orderId)
            throws IOException {
        String dest = request.getContextPath() + "/order-history";
        if (orderId != null && !orderId.trim().isEmpty()) {
            dest += "?selectedOrderId=" + orderId;
        }
        response.sendRedirect(dest);
    }

    private String saveUploadedReviewImage(Part filePart) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return null;
        }

        String submittedFileName = Paths.get(submittedName).getFileName().toString();
        int dotIndex = submittedFileName.lastIndexOf(".");
        String extension = dotIndex >= 0 ? submittedFileName.substring(dotIndex).toLowerCase(Locale.ROOT) : "";
        if (extension.isEmpty()) {
            return null;
        }

        String uploadPath = getServletContext().getRealPath("/images/reviews");
        if (uploadPath == null) {
            return null;
        }

        Files.createDirectories(Path.of(uploadPath));

        String baseName = submittedFileName.substring(0, submittedFileName.length() - extension.length());
        baseName = baseName.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-");
        baseName = baseName.replaceAll("^-|-$", "");

        if (baseName.isEmpty()) {
            baseName = "review";
        }

        String fileName = baseName + "-" + System.currentTimeMillis() + "-" + (int)(Math.random() * 1000) + extension;
        Path targetPath = Path.of(uploadPath, fileName);
        filePart.write(targetPath.toString());

        return "images/reviews/" + fileName;
    }
}
