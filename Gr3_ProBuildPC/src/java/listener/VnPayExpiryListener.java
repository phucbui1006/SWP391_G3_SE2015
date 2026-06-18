package listener;

import dal.OrderDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Background job chạy mỗi 1 phút, tự động hủy các đơn VNPAY
 * đã quá thời hạn thanh toán (vnpay_expires_at < NOW()).
 */
@WebListener
public class VnPayExpiryListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "vnpay-expiry-job");
            t.setDaemon(true);
            return t;
        });

        // Chạy lần đầu sau 1 phút, sau đó mỗi 1 phút
        scheduler.scheduleAtFixedRate(() -> {
            try {
                OrderDAO dao = new OrderDAO();
                List<Integer> cancelled = dao.cancelExpiredVnpayOrders();
                if (!cancelled.isEmpty()) {
                    System.out.println("[VnPayExpiry] Auto-cancelled " + cancelled.size()
                            + " expired VNPAY order(s): " + cancelled);
                }
            } catch (Exception e) {
                System.err.println("[VnPayExpiry] Error during expiry check: " + e.getMessage());
            }
        }, 1, 1, TimeUnit.MINUTES);

        System.out.println("[VnPayExpiry] Background expiry job started.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
        }
    }
}
