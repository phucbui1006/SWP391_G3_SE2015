package util;

import dal.CategoryDAO;
import model.CategorySpecTemplate;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class ProductValidator {

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

        // 6. Validate & Save Image File
        String savedImgPath = null;
        try {
            String imgError = validateImageFile(filePart, action, currentImg);
            if (imgError != null) {
                errors.put("imgFile", imgError);
            } else if (filePart != null && filePart.getSize() > 0) {
                // Valid new image upload - save it immediately
                savedImgPath = saveUploadedProductImage(filePart, servletContext);
            } else {
                // Use preserved current image path
                if (currentImg != null && !currentImg.trim().isEmpty()) {
                    savedImgPath = currentImg.trim();
                }
            }
        } catch (Exception e) {
            errors.put("imgFile", "Lỗi xử lý tệp tin tải lên.");
        }

        // 7. Validate Dynamic Specifications
        validateSpecifications(categoryId, specNames, specValues, categoryDAO, errors);

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
        return null;
    }

    public static String validateImageFile(Part filePart, String action, String currentImg) {
        if (filePart == null || filePart.getSize() == 0) {
            if ("add".equalsIgnoreCase(action)) {
                if (currentImg == null || currentImg.trim().isEmpty()) {
                    return "Vui lòng chọn hình ảnh sản phẩm.";
                }
            }
            return null;
        }

        if (filePart.getSize() > 2 * 1024 * 1024) {
            return "File không hợp lệ hoặc vượt quá 2MB!";
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || filePart.getContentType() == null || 
            !filePart.getContentType().startsWith("image/") ||
            (!submittedName.toLowerCase().endsWith(".png") &&
             !submittedName.toLowerCase().endsWith(".jpg") &&
             !submittedName.toLowerCase().endsWith(".jpeg") &&
             !submittedName.toLowerCase().endsWith(".webp"))) {
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
        if (templates != null && !templates.isEmpty()) {
            if (specNames == null || specValues == null || specNames.length == 0 || specValues.length == 0) {
                errors.put("specifications", "Vui lòng lựa chọn và nhập đầy đủ thông số kỹ thuật theo danh mục.");
                return;
            }

            int specLength = Math.min(specNames.length, specValues.length);

            for (CategorySpecTemplate template : templates) {
                boolean found = false;
                String specValue = null;

                // Find matching specification
                for (int i = 0; i < specLength; i++) {
                    String name = specNames[i];
                    if (name != null && name.trim().equalsIgnoreCase(template.getSpecName())) {
                        found = true;
                        specValue = specValues[i];
                        break;
                    }
                }

                // Enforce required constraint
                if (template.isRequired()) {
                    if (!found || specValue == null || specValue.trim().isEmpty()) {
                        errors.put("spec_" + template.getTemplateId(), "Thông số '" + template.getSpecName() + "' không được để trống.");
                    }
                }

                // Validate dynamic numeric spec template values (> 0)
                if (found && specValue != null && !specValue.trim().isEmpty()) {
                    if ("NUMBER".equalsIgnoreCase(template.getSpecType())) {
                        try {
                            double val = Double.parseDouble(specValue.trim());
                            if (val <= 0) {
                                errors.put("spec_" + template.getTemplateId(), "Thông số '" + template.getSpecName() + "' phải lớn hơn 0.");
                            }
                        } catch (NumberFormatException e) {
                            errors.put("spec_" + template.getTemplateId(), "Thông số '" + template.getSpecName() + "' phải là một số hợp lệ.");
                        }
                    }
                }
            }
        }
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
