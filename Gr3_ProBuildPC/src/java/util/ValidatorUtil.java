package util;

import jakarta.servlet.http.Part;
import java.nio.file.Paths;
import java.util.Locale;
import java.util.regex.Pattern;

public class ValidatorUtil {
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^(0[35789])[0-9]{8}$");
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,31}$");
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
}
