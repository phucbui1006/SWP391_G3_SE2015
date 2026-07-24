package util;

import jakarta.servlet.http.Part;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.regex.Pattern;

public class ValidatorUtil {
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^(0[35789])[0-9]{8}$");
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z0-9]{8,31}$");
    private static final Pattern NAME_PATTERN = Pattern.compile("^[\\p{L}\\s]+$");
    private static final Pattern OTP_PATTERN = Pattern.compile("^\\d{6}$");

    private static final long MAX_BRAND_IMAGE_SIZE = 2 * 1024 * 1024; // 2MB

    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        String trimmed = email.trim();
        return trimmed.length() <= 100 && EMAIL_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidPhone(String phone) {
        if (phone == null) return false;
        String trimmed = phone.trim();
        return PHONE_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidPassword(String password) {
        if (password == null) return false;
        return PASSWORD_PATTERN.matcher(password).matches();
    }

    public static boolean isValidName(String name) {
        if (name == null) return false;
        String trimmed = name.trim();
        return trimmed.length() >= 2 && trimmed.length() <= 50 && NAME_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidOtpCode(String otp) {
        if (otp == null) return false;
        String trimmed = otp.trim();
        return OTP_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidBrandName(String brandName) {
        if (brandName == null) return false;
        int length = brandName.trim().length();
        return length >= 2 && length < 20;
    }

    public static String getCategoryNameError(String categoryName) {
        if (categoryName == null || categoryName.trim().isEmpty()) {
            return "Tên danh mục không được để trống.";
        }

        String trimmed = categoryName.trim();

        if (trimmed.length() < 2 || trimmed.length() > 100) {
            return "Tên danh mục phải từ 2 đến 100 ký tự.";
        }

        if (trimmed.matches(".*\\s{2,}.*")) {
            return "Tên danh mục không được chứa nhiều dấu cách liên tiếp.";
        }

        return null;
    }

    public static boolean isValidCategoryId(String categoryIdRaw) {
        if (categoryIdRaw == null || categoryIdRaw.trim().isEmpty()) {
            return false;
        }

        try {
            return Integer.parseInt(categoryIdRaw.trim()) > 0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static boolean isAllowedBrandImage(Part filePart, boolean required) {
        if (filePart == null || filePart.getSize() == 0) {
            return !required;
        }

        if (filePart.getSize() > MAX_BRAND_IMAGE_SIZE) {
            return false;
        }

        String submittedName = filePart.getSubmittedFileName();
        if (submittedName == null || submittedName.trim().isEmpty()) {
            return false;
        }

        String fileName = Paths.get(submittedName).getFileName().toString();
        String lowerName = fileName.toLowerCase(Locale.ROOT);

        return lowerName.endsWith(".png")
                || lowerName.endsWith(".jpg")
                || lowerName.endsWith(".jpeg")
                || lowerName.endsWith(".webp");
    }

    public static boolean isValidAddress(String address) {
        if (address == null || address.trim().isEmpty()) return false;
        String trimmed = address.trim();
        return trimmed.length() >= 5 && trimmed.length() <= 255;
    }

    public static boolean isValidNote(String note) {
        if (note == null) return true;
        String trimmed = note.trim();
        return trimmed.length() <= 1000;
    }

    public static boolean isValidSearchQuery(String query) {
        if (query == null || query.trim().isEmpty()) return false;
        String trimmed = query.trim();
        if (trimmed.matches(".*[<>='\"%].*")) return false;
        return trimmed.length() <= 100;
    }

    public static boolean isValidOrderSearchQuery(String query) {
        if (query == null || query.trim().isEmpty()) return false;
        String trimmed = query.trim();
        return trimmed.length() <= 20 && trimmed.matches("\\d+");
    }

    public static String safeTrimAndClean(String value) {
        if (value == null) return "";
        return value.trim().replaceAll("[<>='\"%]", "");
    }

    public static boolean isValidPrice(String priceStr) {
        if (priceStr == null || priceStr.trim().isEmpty()) return false;
        try {
            double price = Double.parseDouble(priceStr);
            return price > 0 && price <= 2000000000.0;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static boolean isValidQuantity(String qtyStr) {
        if (qtyStr == null || qtyStr.trim().isEmpty()) return false;
        try {
            int qty = Integer.parseInt(qtyStr);
            return qty >= 0 && qty <= 100000;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static String getPurchaseQuantityError(String quantityRaw) {
        if (quantityRaw == null || quantityRaw.trim().isEmpty()
                || !quantityRaw.trim().matches("^\\d+$")) {
            return "Số lượng phải là số nguyên từ 1 trở lên.";
        }

        try {
            int quantity = Integer.parseInt(quantityRaw.trim());
            if (quantity < 1) {
                return "Số lượng phải là số nguyên từ 1 trở lên.";
            }
        } catch (NumberFormatException e) {
            return "Số lượng phải là số nguyên từ 1 trở lên.";
        }

        return null;
    }

    public static Integer parsePurchaseQuantity(String quantityRaw) {
        if (getPurchaseQuantityError(quantityRaw) != null) {
            return null;
        }

        return Integer.valueOf(quantityRaw.trim());
    }

    public static int normalizeCartQuantity(String quantityRaw) {
        if (quantityRaw == null) return 1;

        String digitsOnly = quantityRaw.replaceAll("\\D+", "");
        if (digitsOnly.isEmpty()) return 1;

        try {
            int quantity = Integer.parseInt(digitsOnly);
            return quantity < 1 ? 1 : quantity;
        } catch (NumberFormatException e) {
            return Integer.MAX_VALUE;
        }
    }

    public static String getPurchaseStockError(int requestedQuantity, int stockQuantity) {
        if (requestedQuantity > stockQuantity) {
            return "Số lượng không được lớn hơn số lượng trong kho (" + stockQuantity + ").";
        }

        return null;
    }

    public static boolean isValidRating(String ratingStr) {
        if (ratingStr == null || ratingStr.trim().isEmpty()) return false;
        try {
            int rating = Integer.parseInt(ratingStr);
            return rating >= 1 && rating <= 5;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public static boolean isValidWarrantyRequestReason(String reason) {
        if (reason == null) return false;
        String trimmed = reason.trim();
        return trimmed.length() >= 10 && trimmed.length() <= 1000;
    }

    public static boolean isValidWarrantyResponse(String response) {
        if (response == null) return false;
        String trimmed = response.trim();
        return trimmed.length() >= 5 && trimmed.length() <= 1000;
    }
}
