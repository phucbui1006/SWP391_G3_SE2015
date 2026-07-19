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
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 2 * 1024 * 1024, // File tối đa 50MB
        maxRequestSize = 20 * 1024 * 1024 // Tổng request tối đa 20MB
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
        String status = normalizeStatusFilter(request.getParameter("status"));
        String sort = normalizeSort(request.getParameter("sort"));
        List<Brand> brands = brandDAO.getBrands(keyword, status, sort);
        List<Brand> allBrands = brandDAO.getBrands(null, "ALL", "newest");

        request.setAttribute("brands", brands);
        request.setAttribute("allBrands", allBrands);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedSort", sort);

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
        } else if ("activate".equals(action)) {
            activateBrand(request, session);
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

        if (img == null) {
            session.setAttribute("brandError", "Không thể lưu logo thương hiệu.");
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

        if (brandId == null || img == null) {
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

        if (brandDAO.deleteBrand(brandId)) {
            session.setAttribute("brandSuccess", "Vô hiệu hóa thương hiệu thành công.");
        } else {
            session.setAttribute("brandError", "Không thể vô hiệu hóa thương hiệu.");
        }
    }

    private void activateBrand(HttpServletRequest request, HttpSession session) {
        Integer brandId = parseId(request.getParameter("brandId"));

        if (brandId == null) {
            session.setAttribute("brandError", "Thương hiệu cần kích hoạt không hợp lệ.");
            return;
        }

        if (brandDAO.activateBrand(brandId)) {
            session.setAttribute("brandSuccess", "Kích hoạt thương hiệu thành công.");
        } else {
            session.setAttribute("brandError", "Không thể kích hoạt thương hiệu.");
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

    private String normalizeStatusFilter(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "ALL";
        }

        String status = value.trim().toUpperCase();
        if ("ACTIVE".equals(status) || "INACTIVE".equals(status)) {
            return status;
        }

        return "ALL";
    }

    private String normalizeSort(String value) {
        if ("product_count_asc".equals(value) || "product_count_desc".equals(value)) {
            return value;
        }

        return "newest";
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

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return null;
        }

        String submittedFileName = Paths.get(submittedName).getFileName().toString();
        String extension = getFileExtension(submittedFileName);
        if (extension.isEmpty()) {
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

    private String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf(".");
        if (dotIndex < 0) {
            return "";
        }

        return fileName.substring(dotIndex).toLowerCase(Locale.ROOT);
    }
}
