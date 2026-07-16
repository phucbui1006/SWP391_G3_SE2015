package util;

import dal.CategoryDAO;
import model.CategorySpecTemplate;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

public final class ProductValidator {

    private ProductValidator() {
    }

    public static String validate(
            String action,
            String productName,
            Integer categoryId,
            Integer brandId,
            String priceRaw,
            String warrantyMonthsRaw,
            String description,
            String currentImg,
            Part filePart,
            String[] specNames,
            String[] specValues,
            CategoryDAO categoryDAO,
            jakarta.servlet.ServletContext servletContext,
            Map<String, String> errors
    ) {
        // 1. Validate Product Name
        String nameError = validateProductName(productName);
        if (nameError != null) {
            errors.put("productName", nameError);
        }

        // 2. Validate Category ID & Brand ID
        if (categoryId == null) {
            errors.put("categoryId", "Danh mục không hợp lệ.");
        }
        if (brandId == null) {
            errors.put("brandId", "Thương hiệu không hợp lệ.");
        }

        // 3. Validate Price
        String priceError = validatePrice(priceRaw);
        if (priceError != null) {
            errors.put("price", priceError);
        }

        // 4. Validate Warranty Months
        String warrantyError = validateWarrantyMonths(warrantyMonthsRaw);
        if (warrantyError != null) {
            errors.put("warrantyMonths", warrantyError);
        }

        // 5. Validate Description
        String descError = validateDescription(description);
        if (descError != null) {
            errors.put("description", descError);
        }

        // 6. Validate Image File
        String imgError = validateImageFile(filePart, action, currentImg);
        if (imgError != null) {
            errors.put("imgFile", imgError);
        }

        // 7. Validate Dynamic Specifications before writing any uploaded file.
        validateSpecifications(categoryId, specNames, specValues, categoryDAO, errors);

        if (!errors.isEmpty()) {
            return null;
        }

        String savedImgPath = null;
        try {
            if (filePart != null && filePart.getSize() > 0) {
                savedImgPath = saveUploadedProductImage(filePart, servletContext);
                if (savedImgPath == null) {
                    errors.put("imgFile", "Không thể lưu hình ảnh sản phẩm.");
                }
            } else if (currentImg != null && !currentImg.trim().isEmpty()) {
                savedImgPath = currentImg.trim();
            }
        } catch (Exception e) {
            errors.put("imgFile", "Lỗi xử lý tệp tin tải lên.");
        }

        return savedImgPath;
    }

    public static String validateProductName(String name) {
        if (name == null || name.trim().isEmpty()) {
            return "Tên sản phẩm không được để trống.";
        }
        if (name.trim().length() < 3 || name.trim().length() > 255) {
            return "Tên sản phẩm phải từ 3 đến 255 ký tự.";
        }
        return null;
    }

    public static String validatePrice(String priceRaw) {
        if (priceRaw == null || priceRaw.trim().isEmpty()) {
            return "Giá bán không được để trống.";
        }
        try {
            BigDecimal price = new BigDecimal(priceRaw.trim());
            BigDecimal maxPrice = new BigDecimal("1000000000");
            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                return "Giá bán phải lớn hơn 0.";
            } else if (price.compareTo(maxPrice) > 0) {
                return "Giá bán không được vượt quá 1.000.000.000 VND (1 Tỷ).";
            } else if (price.remainder(BigDecimal.valueOf(1000)).compareTo(BigDecimal.ZERO) != 0) {
                return "Giá bán phải chia hết cho 1000.";
            }
        } catch (NumberFormatException | ArithmeticException e) {
            return "Giá bán không hợp lệ hoặc quá lớn.";
        }
        return null;
    }

    public static String validateWarrantyMonths(String warrantyMonthsRaw) {
        if (warrantyMonthsRaw == null || warrantyMonthsRaw.trim().isEmpty()) {
            return "Thời gian bảo hành không được để trống.";
        }
        try {
            long valLong = Long.parseLong(warrantyMonthsRaw.trim());
            if (valLong <= 0) {
                return "Thời gian bảo hành phải lớn hơn 0.";
            } else if (valLong > 120) {
                return "Thời gian bảo hành không được vượt quá 120 tháng (10 năm).";
            }
        } catch (NumberFormatException e) {
            return "Thời gian bảo hành không hợp lệ hoặc quá lớn.";
        }
        return null;
    }

    public static String validateDescription(String description) {
        if (description == null || description.trim().isEmpty()) {
            return "Mô tả chi tiết không được để trống.";
        }
        if (description.trim().length() > 10000) {
            return "Mô tả chi tiết không được vượt quá 10.000 ký tự.";
        }
        return null;
    }

    public static String validateImageFile(Part filePart, String action, String currentImg) {
        if (filePart == null || filePart.getSize() == 0) {
            if ("add".equalsIgnoreCase(action)
                    || currentImg == null || currentImg.trim().isEmpty()) {
                return "Vui lòng chọn hình ảnh sản phẩm.";
            }
            return null;
        }

        if (filePart.getSize() > 2 * 1024 * 1024) {
            return "File không hợp lệ hoặc vượt quá 2MB!";
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || filePart.getContentType() == null
                || !filePart.getContentType().startsWith("image/")
                || (!submittedName.toLowerCase().endsWith(".png")
                && !submittedName.toLowerCase().endsWith(".jpg")
                && !submittedName.toLowerCase().endsWith(".jpeg")
                && !submittedName.toLowerCase().endsWith(".webp"))) {
            return "File không hợp lệ hoặc vượt quá 2MB!";
        }

        return null;
    }

    public static void validateSpecifications(
            Integer categoryId,
            String[] specNames,
            String[] specValues,
            CategoryDAO categoryDAO,
            Map<String, String> errors
    ) {
        if (categoryId == null || categoryDAO == null) {
            return;
        }

        List<CategorySpecTemplate> templates = categoryDAO.getTemplatesByCategoryId(categoryId);
        if (templates == null || templates.isEmpty()) {
            return;
        }

        Map<String, String> submittedSpecs = new HashMap<>();
        Set<String> duplicateNames = new HashSet<>();
        int nameCount = specNames == null ? 0 : specNames.length;
        int valueCount = specValues == null ? 0 : specValues.length;

        if (nameCount != valueCount) {
            errors.put("specifications", "Dữ liệu thông số kỹ thuật không hợp lệ.");
        }

        int specLength = Math.min(nameCount, valueCount);
        for (int i = 0; i < specLength; i++) {
            String name = specNames[i] == null ? "" : specNames[i].trim();
            if (name.isEmpty()) {
                continue;
            }

            String normalizedName = name.toLowerCase(Locale.ROOT);
            if (submittedSpecs.containsKey(normalizedName)) {
                duplicateNames.add(normalizedName);
            } else {
                submittedSpecs.put(normalizedName, specValues[i]);
            }
        }

        if (!duplicateNames.isEmpty()) {
            errors.put("specifications", "Thông số kỹ thuật bị trùng lặp.");
        }

        Set<String> validTemplateNames = new HashSet<>();
        for (CategorySpecTemplate template : templates) {
            String normalizedTemplateName = template.getSpecName().trim().toLowerCase(Locale.ROOT);
            validTemplateNames.add(normalizedTemplateName);
            String rawValue = submittedSpecs.get(normalizedTemplateName);
            String value = rawValue == null ? "" : rawValue.trim();
            String errorKey = "spec_" + template.getTemplateId();

            if (template.isRequired() && value.isEmpty()) {
                errors.put(errorKey, "Thông số '" + template.getSpecName() + "' không được để trống.");
                continue;
            }

            if (value.isEmpty()) {
                continue;
            }

            if (value.length() > 255) {
                errors.put(errorKey, "Thông số '" + template.getSpecName() + "' không được vượt quá 255 ký tự.");
                continue;
            }

            if ("NUMBER".equalsIgnoreCase(template.getSpecType())) {
                try {
                    BigDecimal numericValue = new BigDecimal(value);
                    if (numericValue.compareTo(BigDecimal.ZERO) <= 0) {
                        errors.put(errorKey, "Thông số '" + template.getSpecName() + "' phải lớn hơn 0.");
                    }
                } catch (NumberFormatException e) {
                    errors.put(errorKey, "Thông số '" + template.getSpecName() + "' phải là một số hợp lệ.");
                }
            } else if ("SELECT".equalsIgnoreCase(template.getSpecType())
                    && !isAllowedValue(value, template.getAllowedValues())) {
                errors.put(errorKey, "Giá trị của thông số '" + template.getSpecName() + "' không hợp lệ.");
            }
        }

        for (String submittedName : submittedSpecs.keySet()) {
            if (!validTemplateNames.contains(submittedName)) {
                errors.put("specifications", "Có thông số kỹ thuật không thuộc danh mục đã chọn.");
                break;
            }
        }
    }

    private static boolean isAllowedValue(String value, String allowedValues) {
        if (allowedValues == null || allowedValues.trim().isEmpty()) {
            return false;
        }

        for (String allowedValue : allowedValues.split(",")) {
            if (allowedValue.trim().equalsIgnoreCase(value)) {
                return true;
            }
        }
        return false;
    }

    private static String saveUploadedProductImage(Part filePart, jakarta.servlet.ServletContext context) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return null;
        }

        String submittedFileName = java.nio.file.Paths.get(submittedName).getFileName().toString();
        String extension = "";
        int dotIndex = submittedFileName.lastIndexOf(".");
        if (dotIndex >= 0) {
            extension = submittedFileName.substring(dotIndex).toLowerCase(java.util.Locale.ROOT);
        }
        if (extension.isEmpty()) {
            return null;
        }

        String uploadPath = context.getRealPath("/images/products");
        if (uploadPath == null) {
            return null;
        }

        java.nio.file.Files.createDirectories(java.nio.file.Path.of(uploadPath));

        String baseName = submittedFileName.substring(0, submittedFileName.length() - extension.length());
        baseName = baseName.toLowerCase(java.util.Locale.ROOT).replaceAll("[^a-z0-9]+", "-");
        baseName = baseName.replaceAll("^-|-$", "");

        if (baseName.isEmpty()) {
            baseName = "product";
        }

        String fileName = baseName + "-" + System.currentTimeMillis() + extension;
        java.nio.file.Path targetPath = java.nio.file.Path.of(uploadPath, fileName);
        filePart.write(targetPath.toString());

        return "images/products/" + fileName;
    }
}
