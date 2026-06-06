package controller;

import dal.BrandDAO;
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
import java.util.Locale;
import java.util.List;
import model.Brand;
import model.User;

@WebServlet(name = "AdminBrandServlet", urlPatterns = {"/AdminBrands"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 2 * 1024 * 1024,
        maxRequestSize = 4 * 1024 * 1024
)
public class AdminBrandServlet extends HttpServlet {

    private final BrandDAO brandDAO = new BrandDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = requireAdmin(request, response);
        if (session == null) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String keyword = request.getParameter("keyword");
        List<Brand> brands = brandDAO.getBrands(keyword);

        request.setAttribute("brands", brands);
        request.setAttribute("keyword", keyword);

        String success = (String) session.getAttribute("brandSuccess");
        String error = (String) session.getAttribute("brandError");

        if (success != null) {
            request.setAttribute("success", success);
            session.removeAttribute("brandSuccess");
        }

        if (error != null) {
            request.setAttribute("error", error);
            session.removeAttribute("brandError");
        }

        request.getRequestDispatcher("/views/admin-brands.jsp").forward(request, response);
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

        if ("add".equals(action)) {
            addBrand(request, session);
        } else if ("update".equals(action)) {
            updateBrand(request, session);
        } else if ("delete".equals(action)) {
            deleteBrand(request, session);
        } else {
            session.setAttribute("brandError", "Thao tác không hợp lệ.");
        }

        response.sendRedirect(request.getContextPath() + "/AdminBrands");
    }

    private HttpSession requireAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return null;
        }

        User user = (User) session.getAttribute("account");
        String roleName = user.getRoleName();
        if (roleName == null || !"ADMIN".equals(roleName.trim().toUpperCase())) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return null;
        }

        return session;
    }

    private void addBrand(HttpServletRequest request, HttpSession session)
            throws IOException, ServletException {
        String brandName = normalizeText(request.getParameter("brandName"));
        String img = saveUploadedBrandImage(request.getPart("imgFile"));

        if (brandName == null || img == null) {
            session.setAttribute("brandError", "Vui lòng nhập đầy đủ tên thương hiệu và chọn logo.");
            return;
        }

        if (brandDAO.addBrand(brandName, img)) {
            session.setAttribute("brandSuccess", "Thêm thương hiệu thành công.");
        } else {
            session.setAttribute("brandError", "Không thể thêm thương hiệu. Tên hoặc logo có thể đã tồn tại.");
        }
    }

    private void updateBrand(HttpServletRequest request, HttpSession session)
            throws IOException, ServletException {
        Integer brandId = parseId(request.getParameter("brandId"));
        String brandName = normalizeText(request.getParameter("brandName"));
        String img = saveUploadedBrandImage(request.getPart("imgFile"));

        if (img == null) {
            img = normalizeImagePath(request.getParameter("currentImg"));
        }

        if (brandId == null || brandName == null || img == null) {
            session.setAttribute("brandError", "Thông tin cập nhật thương hiệu chưa hợp lệ.");
            return;
        }

        if (brandDAO.updateBrand(brandId, brandName, img)) {
            session.setAttribute("brandSuccess", "Cập nhật thương hiệu thành công.");
        } else {
            session.setAttribute("brandError", "Không thể cập nhật thương hiệu. Tên hoặc logo có thể đã tồn tại.");
        }
    }

    private void deleteBrand(HttpServletRequest request, HttpSession session) {
        Integer brandId = parseId(request.getParameter("brandId"));

        if (brandId == null) {
            session.setAttribute("brandError", "Thương hiệu cần xóa không hợp lệ.");
            return;
        }

        if (brandDAO.hasBatches(brandId)) {
            session.setAttribute("brandError", "Không thể xóa thương hiệu đang được dùng trong lô hàng hoặc sản phẩm.");
            return;
        }

        if (brandDAO.deleteBrand(brandId)) {
            session.setAttribute("brandSuccess", "Xóa thương hiệu thành công.");
        } else {
            session.setAttribute("brandError", "Không thể xóa thương hiệu.");
        }
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

    private String normalizeImagePath(String value) {
        String img = normalizeText(value);

        if (img == null) {
            return null;
        }

        img = img.replace("\\", "/");

        while (img.startsWith("/")) {
            img = img.substring(1);
        }

        if (!img.contains("/")) {
            img = "images/brands/" + img;
        }

        return img;
    }

    private String saveUploadedBrandImage(Part filePart) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String contentType = filePart.getContentType();
        if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("image/")) {
            return null;
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return null;
        }

        String submittedFileName = Paths.get(submittedName).getFileName().toString();
        String extension = getAllowedImageExtension(submittedFileName);

        if (extension == null) {
            return null;
        }

        String uploadPath = getServletContext().getRealPath("/images/brands");
        if (uploadPath == null) {
            return null;
        }

        Files.createDirectories(Path.of(uploadPath));

        String baseName = submittedFileName.substring(0, submittedFileName.length() - extension.length());
        baseName = baseName.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-");
        baseName = baseName.replaceAll("^-|-$", "");

        if (baseName.isEmpty()) {
            baseName = "brand";
        }

        String fileName = baseName + "-" + System.currentTimeMillis() + extension;
        Path targetPath = Path.of(uploadPath, fileName);
        filePart.write(targetPath.toString());

        return "images/brands/" + fileName;
    }

    private String getAllowedImageExtension(String fileName) {
        if (fileName == null) {
            return null;
        }

        String lowerName = fileName.toLowerCase(Locale.ROOT);

        if (lowerName.endsWith(".png")) {
            return ".png";
        } else if (lowerName.endsWith(".jpg")) {
            return ".jpg";
        } else if (lowerName.endsWith(".jpeg")) {
            return ".jpeg";
        } else if (lowerName.endsWith(".webp")) {
            return ".webp";
        }

        return null;
    }
}
