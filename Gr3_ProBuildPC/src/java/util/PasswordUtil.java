package util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class PasswordUtil {

    /**
     * Hashes the plaintext password using MD5.
     * Returns a 32-character hex string.
     */
    public static String hash(String password) {
        if (password == null) {
            throw new IllegalArgumentException("Password cannot be null");
        }
        
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            md.update(password.getBytes());
            byte[] digest = md.digest();
            
            StringBuilder sb = new StringBuilder();
            for (byte b : digest) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error hashing password with MD5", e);
        }
    }

    /**
     * Verifies the plaintext password against the stored formatted hash.
     * Supports backward compatibility for legacy PBKDF2 hashes and plaintext.
     */
    public static boolean verify(String password, String storedHash) {
        if (password == null || storedHash == null) {
            return false;
        }

        // 1. Support for existing PBKDF2 hashes (backward compatibility)
        if (storedHash.contains(":")) {
            String[] parts = storedHash.split(":");
            if (parts.length == 3) {
                try {
                    int iterations = Integer.parseInt(parts[0]);
                    byte[] salt = Base64.getDecoder().decode(parts[1]);
                    byte[] expectedHash = Base64.getDecoder().decode(parts[2]);
                    
                    byte[] testHash = pbkdf2(password.toCharArray(), salt, iterations, expectedHash.length * 8);

                    // Time-constant comparison to prevent timing attacks
                    int diff = expectedHash.length ^ testHash.length;
                    for (int i = 0; i < expectedHash.length && i < testHash.length; i++) {
                        diff |= expectedHash[i] ^ testHash[i];
                    }
                    if (diff == 0) return true;
                } catch (Exception e) {
                    // Ignore exception, will fallthrough to fallback checks
                }
            }
        } 
        
        // 2. Support for new MD5 hashes
        if (storedHash.length() == 32 && !storedHash.contains(":")) {
            return hash(password).equalsIgnoreCase(storedHash);
        }

        // 3. Fallback for plaintext (legacy accounts or simple test passwords)
        return password.equals(storedHash);
    }

    /**
     * Legacy PBKDF2 algorithm kept ONLY for verifying old passwords.
     */
    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int keyLength) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, keyLength);
            SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            return skf.generateSecret(spec).getEncoded();
        } catch (Exception e) {
            throw new RuntimeException("Error hashing password with PBKDF2", e);
        }
    }
}
