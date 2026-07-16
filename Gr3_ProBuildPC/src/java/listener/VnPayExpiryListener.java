package listener;

import dal.OrderDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class VnPayExpiryListener implements ServletContextListener {

    private static final long CHECK_INTERVAL_SECONDS = 5;

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "vnpay-expiry-job");
            t.setDaemon(true);
            return t;
        });

        scheduler.scheduleAtFixedRate(() -> {
            try {
                OrderDAO dao = new OrderDAO();
                List<Integer> cancelled = dao.cancelExpiredVnpayOrders();
                if (!cancelled.isEmpty()) {
                    System.out.println("[VnPayExpiry] Auto-cancelled expired VNPAY order(s): " + cancelled);
                }
            } catch (Exception e) {
                System.err.println("[VnPayExpiry] Error during expiry check: " + e.getMessage());
            }
        }, 0, CHECK_INTERVAL_SECONDS, TimeUnit.SECONDS);

        System.out.println("[VnPayExpiry] Background expiry job started.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
        }
    }
}
