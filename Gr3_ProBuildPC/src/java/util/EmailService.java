package util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailService {

    private static final String FROM_EMAIL = "hoangdzvl2005@gmail.com";
    private static final String APP_PASSWORD = "fgbm ixbv kvoy csew";

    public static boolean sendOtpEmail(String toEmail, String otp) {
        try {
            Properties props = new Properties();

            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
            props.put("mail.debug", "true");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, "ProBuild PC", "UTF-8"));

            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail)
            );

            message.setSubject("Mã xác nhận đặt lại mật khẩu - ProBuild PC", "UTF-8");

            String content =  otp;

            message.setText(content, "UTF-8");

            Transport.send(message);

            System.out.println("Gửi email thành công tới: " + toEmail);
            return true;

        } catch (Exception e) {
            System.out.println("Lỗi gửi email:");
            e.printStackTrace();
            return false;
        }
    }

    public static boolean sendStaffWelcomeEmail(String toEmail, String password) {
        try {
            Properties props = new Properties();

            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
            props.put("mail.debug", "true");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, "ProBuild PC", "UTF-8"));

            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail)
            );

            message.setSubject("Tài khoản nhân viên - ProBuild PC", "UTF-8");

            String content = "Chào bạn,\n\n"
                           + "Tài khoản nhân viên của bạn đã được tạo thành công trên hệ thống ProBuild PC.\n\n"
                           + "Thông tin đăng nhập:\n"
                           + "- Email: " + toEmail + "\n"
                           + "- Mật khẩu tạm thời: " + password + "\n\n"
                           + "Lưu ý: Bạn sẽ được yêu cầu đổi mật khẩu ngay trong lần đăng nhập đầu tiên.\n\n"
                           + "Trân trọng,\nBan Quản Trị ProBuild PC";

            message.setText(content, "UTF-8");

            Transport.send(message);

            System.out.println("Gửi welcome email thành công tới: " + toEmail);
            return true;

        } catch (Exception e) {
            System.out.println("Lỗi gửi welcome email:");
            e.printStackTrace();
            return false;
        }
    }

    public static boolean sendAdminResetPasswordEmail(String toEmail, String password) {
        try {
            Properties props = new Properties();

            props.put("mail.smtp.host", "smtp.gmail.com");
            props.put("mail.smtp.port", "587");
            props.put("mail.smtp.auth", "true");
            props.put("mail.smtp.starttls.enable", "true");
            props.put("mail.smtp.ssl.trust", "smtp.gmail.com");
            props.put("mail.debug", "true");

            Session session = Session.getInstance(props, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL, "ProBuild PC", "UTF-8"));

            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(toEmail)
            );

            message.setSubject("Mật khẩu của bạn đã được đặt lại - ProBuild PC", "UTF-8");

            String content = "Chào bạn,\n\n"
                           + "Mật khẩu cho tài khoản của bạn đã được quản trị viên (Admin) đặt lại thành công.\n\n"
                           + "Thông tin đăng nhập mới của bạn:\n"
                           + "- Email: " + toEmail + "\n"
                           + "- Mật khẩu tạm thời: " + password + "\n\n"
                           + "Lưu ý: Vì lý do bảo mật, bạn sẽ được yêu cầu đổi mật khẩu mới trong lần đăng nhập tiếp theo.\n\n"
                           + "Trân trọng,\nBan Quản Trị ProBuild PC";

            message.setText(content, "UTF-8");

            Transport.send(message);

            System.out.println("Gửi email reset mật khẩu thành công tới: " + toEmail);
            return true;

        } catch (Exception e) {
            System.out.println("Lỗi gửi email reset mật khẩu:");
            e.printStackTrace();
            return false;
        }
    }
}
