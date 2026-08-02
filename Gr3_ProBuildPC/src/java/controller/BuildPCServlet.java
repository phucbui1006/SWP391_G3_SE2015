package controller;

import dal.BuildPCDAO;
import dal.CartDAO;
import dal.ProductDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.BuildPCSlot;
import model.Product;
import model.ProductSpecification;
import model.User;

@WebServlet(name = "BuildPCServlet", urlPatterns = {"/build-pc", "/BuildPC"})
public class BuildPCServlet extends HttpServlet {

    private static final String SESSION_SELECTED_BUILD = "selectedBuild";
    private static final String SESSION_SELECTED_BUILD_QUANTITIES = "selectedBuildQuantities";
    private static final String SESSION_BUILD_CHECKOUT_ITEMS = "buildCheckoutItems";
    private static final String BUILD_MESSAGE = "buildPcMessage";
    private static final String BUILD_MESSAGE_TYPE = "buildPcMessageType";
    private static final int MAX_BUILD_QUANTITY_DIGITS = 9;

    private static final int CPU_CATEGORY_ID = 1;
    private static final int MAINBOARD_CATEGORY_ID = 2;
    private static final int RAM_CATEGORY_ID = 3;
    private static final int GPU_CATEGORY_ID = 4;
    private static final int SSD_CATEGORY_ID = 5;
    private static final int CASE_CATEGORY_ID = 7;
    private static final int MONITOR_CATEGORY_ID = 8;
    private static final int KEYBOARD_CATEGORY_ID = 9;
    private static final int MOUSE_CATEGORY_ID = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "view";
        }

        switch (action) {
            case "select":
                handleSelect(request, response);
                break;
            case "remove":
                handleRemove(request, response);
                break;
            case "updateQuantity":
                handleUpdateQuantity(request, response);
                break;
            case "clear":
                handleClear(request, response);
                break;
            case "buyNow":
                handleBuyNow(request, response);
                break;
            case "view":
            default:
                showBuildPC(request, response);
                break;
        }
    }

    // Hiển thị trang Build PC với các linh kiện và số lượng đã chọn hiện tại.
    private void showBuildPC(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BuildPCDAO buildPCDAO = new BuildPCDAO();
        Map<String, Integer> selectedBuild = getSelectedBuild(session);
        Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
        Map<String, Product> selectedProducts = buildPCDAO.getSelectedBuild(selectedBuild);
        List<BuildPCSlot> buildSlots = createBuildSlots(buildPCDAO, selectedBuild, selectedProducts, selectedQuantities);

        request.setAttribute("buildSlots", buildSlots);
        request.setAttribute("selectedProductSpecifications", loadSelectedSpecifications(selectedProducts));
        request.setAttribute("buildTotal", calculateBuildTotal(selectedProducts, selectedQuantities));
        request.setAttribute("cartItemCount", getCartItemCount(session));
        moveFlash(session, request, BUILD_MESSAGE, "buildPcMessage");
        moveFlash(session, request, BUILD_MESSAGE_TYPE, "buildPcMessageType");

        request.getRequestDispatcher("/views/build-pc.jsp").forward(request, response);
    }

    private Map<Integer, List<ProductSpecification>> loadSelectedSpecifications(
            Map<String, Product> selectedProducts) {
        Map<Integer, List<ProductSpecification>> specifications = new LinkedHashMap<>();
        ProductDAO productDAO = new ProductDAO();
        for (Product product : selectedProducts.values()) {
            if (product != null && !specifications.containsKey(product.getProductId())) {
                specifications.put(product.getProductId(),
                        productDAO.getSpecificationsByProductId(product.getProductId()));
            }
        }
        return specifications;
    }

    // Lưu một linh kiện đã chọn vào cấu hình Build PC hiện tại.
    private void handleSelect(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        String slot = normalizeSlot(request.getParameter("slot"));
        Integer productId = parsePositiveInteger(request.getParameter("productId"));

        if (slot == null || productId == null) {
            setFlash(session, "Thông tin linh kiện không hợp lệ.", "error");
            response.sendRedirect(request.getContextPath() + "/build-pc");
            return;
        }

        BuildPCDAO buildPCDAO = new BuildPCDAO();
        Product product = buildPCDAO.getProductById(productId);

        if (product == null || product.getCategoryId() != getCategoryIdBySlot(slot)) {
            setFlash(session, "Linh kiện đã chọn không tồn tại hoặc đã hết hàng.", "error");
            response.sendRedirect(request.getContextPath() + "/build-pc");
            return;
        }

        Map<String, Integer> selectedBuild = getSelectedBuild(session);

        if (!buildPCDAO.isProductCompatibleWithSelectedBuild(productId, selectedBuild, slot)) {
            setFlash(session, "Linh kiện này không tương thích với cấu hình hiện tại.", "error");
            response.sendRedirect(request.getContextPath() + "/build-pc");
            return;
        }

        Integer previousProductId = selectedBuild.get(slot);
        boolean productChanged = previousProductId == null || previousProductId.intValue() != productId.intValue();

        selectedBuild.put(slot, productId);
        session.setAttribute(SESSION_SELECTED_BUILD, selectedBuild);

        Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
        if (productChanged || !selectedQuantities.containsKey(slot)) {
            selectedQuantities.put(slot, 1);
            session.setAttribute(SESSION_SELECTED_BUILD_QUANTITIES, selectedQuantities);
        }

        setFlash(session, "Đã chọn " + product.getProductName() + ".", "success");

        response.sendRedirect(request.getContextPath() + "/build-pc");
    }

    // Xóa một slot linh kiện khỏi cấu hình Build PC hiện tại.
    private void handleRemove(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        String slot = normalizeSlot(request.getParameter("slot"));

        if (slot != null) {
            Map<String, Integer> selectedBuild = getSelectedBuild(session);
            selectedBuild.remove(slot);
            session.setAttribute(SESSION_SELECTED_BUILD, selectedBuild);

            Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
            selectedQuantities.remove(slot);
            session.setAttribute(SESSION_SELECTED_BUILD_QUANTITIES, selectedQuantities);

            setFlash(session, "Đã xóa linh kiện khỏi cấu hình.", "success");
        }

        response.sendRedirect(request.getContextPath() + "/build-pc");
    }

    // Cập nhật số lượng cho linh kiện đã chọn, bị giới hạn bởi tồn kho có sẵn.
    private void handleUpdateQuantity(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        String slot = normalizeSlot(request.getParameter("slot"));
        String quantityRaw = request.getParameter("quantity");
        Integer quantity = parseBuildQuantity(quantityRaw);

        if (slot == null || quantity == null) {
            respondQuantityError(request, response, session,
                    "Số lượng phải là số nguyên từ 1 trở lên.");
            return;
        }

        Map<String, Integer> selectedBuild = getSelectedBuild(session);
        if (!selectedBuild.containsKey(slot)) {
            respondQuantityError(request, response, session,
                    "Vui lòng chọn linh kiện trước khi chỉnh số lượng.");
            return;
        }

        Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
        BuildPCDAO buildPCDAO = new BuildPCDAO();
        int productId = selectedBuild.get(slot);
        int availableQuantity = buildPCDAO.getAvailableQuantity(productId);

        if (availableQuantity <= 0) {
            respondQuantityError(request, response, session,
                    "Linh kiện này đã hết hàng.");
            return;
        }

        if (quantity > availableQuantity) {
            respondQuantityError(request, response, session,
                    "Số lượng không được lớn hơn số lượng trong kho (" + availableQuantity + ").");
            return;
        }

        selectedQuantities.put(slot, quantity);
        session.setAttribute(SESSION_SELECTED_BUILD_QUANTITIES, selectedQuantities);

        response.sendRedirect(request.getContextPath() + "/build-pc");
    }

    // Reset cấu hình Build PC hiện tại và các số lượng đã chọn.
    private void handleClear(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        session.removeAttribute(SESSION_SELECTED_BUILD);
        session.removeAttribute(SESSION_SELECTED_BUILD_QUANTITIES);
        setFlash(session, "Đã reset toàn bộ cấu hình Build PC.", "success");
        response.sendRedirect(request.getContextPath() + "/build-pc");
    }

    private void handleBuyNow(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null) {
            setFlash(session, "Bạn cần đăng nhập để mua cấu hình.", "error");
            response.sendRedirect(request.getContextPath() + "/Login");
            return;
        }

        if (!account.isCustomer()) {
            setFlash(session, "Chỉ tài khoản khách hàng mới có thể mua cấu hình.", "error");
            response.sendRedirect(request.getContextPath() + "/build-pc");
            return;
        }

        Map<String, Integer> selectedBuild = getSelectedBuild(session);
        Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
        Map<Integer, Integer> checkoutItems = new LinkedHashMap<>();

        for (Map.Entry<String, Integer> entry : selectedBuild.entrySet()) {
            checkoutItems.put(entry.getValue(),
                    getSelectedQuantity(selectedQuantities, entry.getKey()));
        }

        session.setAttribute(SESSION_BUILD_CHECKOUT_ITEMS, checkoutItems);
        response.sendRedirect(request.getContextPath() + "/checkout?checkoutMode=build");
    }

    // Xây dựng danh sách slot hiển thị trên trang, bao gồm các sản phẩm phù hợp theo tính tương thích.
    private List<BuildPCSlot> createBuildSlots(BuildPCDAO dao, Map<String, Integer> selectedBuild,
            Map<String, Product> selectedProducts, Map<String, Integer> selectedQuantities) {
        List<BuildPCSlot> slots = new ArrayList<>();

        slots.add(createSlot(dao, selectedBuild, "CPU", "Bộ vi xử lý (CPU)", CPU_CATEGORY_ID, true));
        slots.add(createSlot(dao, selectedBuild, "Mainboard", "Bo mạch chủ", MAINBOARD_CATEGORY_ID, true));
        slots.add(createSlot(dao, selectedBuild, "RAM", "Bộ nhớ RAM", RAM_CATEGORY_ID, true));
        slots.add(createSlot(dao, selectedBuild, "GPU", "Card đồ họa", GPU_CATEGORY_ID, true));
        slots.add(createSlot(dao, selectedBuild, "SSD", "Ổ cứng SSD", SSD_CATEGORY_ID, false));
        slots.add(createSlot(dao, selectedBuild, "Case", "Vỏ máy tính", CASE_CATEGORY_ID, false));
        slots.add(createSlot(dao, selectedBuild, "Monitor", "Màn hình", MONITOR_CATEGORY_ID, false));
        slots.add(createSlot(dao, selectedBuild, "Keyboard", "Bàn phím", KEYBOARD_CATEGORY_ID, false));
        slots.add(createSlot(dao, selectedBuild, "Mouse", "Chuột", MOUSE_CATEGORY_ID, false));

        for (BuildPCSlot slot : slots) {
            slot.setSelectedProduct(selectedProducts.get(slot.getKey()));
            slot.setQuantity(getSelectedQuantity(selectedQuantities, slot.getKey()));
        }

        return slots;
    }

    // Tạo một slot và nạp danh sách sản phẩm phù hợp với loại slot đó.
    private BuildPCSlot createSlot(BuildPCDAO dao, Map<String, Integer> selectedBuild,
            String key, String displayName, int categoryId, boolean requiresCompatibility) {
        BuildPCSlot slot = new BuildPCSlot(key, displayName, categoryId, requiresCompatibility);
        List<Product> products = requiresCompatibility
                ? dao.getProductsByCategoryCompatibleWithBuild(categoryId, selectedBuild, key)
                : dao.getProductsByCategory(categoryId);
        slot.setAvailableProducts(products);
        return slot;
    }

    // Đọc các ID linh kiện đã chọn từ session.
    @SuppressWarnings("unchecked")
    private Map<String, Integer> getSelectedBuild(HttpSession session) {
        Object value = session.getAttribute(SESSION_SELECTED_BUILD);

        if (value instanceof Map<?, ?>) {
            return new LinkedHashMap<>((Map<String, Integer>) value);
        }

        return new LinkedHashMap<>();
    }

    // Đọc các số lượng đã chọn từ session.
    @SuppressWarnings("unchecked")
    private Map<String, Integer> getSelectedQuantities(HttpSession session) {
        Object value = session.getAttribute(SESSION_SELECTED_BUILD_QUANTITIES);

        if (value instanceof Map<?, ?>) {
            return new LinkedHashMap<>((Map<String, Integer>) value);
        }

        return new LinkedHashMap<>();
    }

    // Tính tổng tiền.
    private BigDecimal calculateBuildTotal(Map<String, Product> selectedProducts, Map<String, Integer> selectedQuantities) {
        BigDecimal total = BigDecimal.ZERO;

        for (Map.Entry<String, Product> entry : selectedProducts.entrySet()) {
            Product product = entry.getValue();
            if (product.getPrice() != null) {
                total = total.add(product.getPrice().multiply(BigDecimal.valueOf(getSelectedQuantity(selectedQuantities, entry.getKey()))));
            }
        }

        return total;
    }

    // Trả về số lượng an toàn, mặc định là 1 khi thiếu hoặc không hợp lệ.
    private int getSelectedQuantity(Map<String, Integer> selectedQuantities, String slot) {
        Integer quantity = selectedQuantities.get(slot);
        return quantity == null || quantity < 1 ? 1 : quantity;
    }

    // Ánh xạ key slot trên giao diện với category id tương ứng.
    private int getCategoryIdBySlot(String slot) {
        switch (slot) {
            case "CPU":
                return CPU_CATEGORY_ID;
            case "Mainboard":
                return MAINBOARD_CATEGORY_ID;
            case "RAM":
                return RAM_CATEGORY_ID;
            case "GPU":
                return GPU_CATEGORY_ID;
            case "SSD":
                return SSD_CATEGORY_ID;
            case "Case":
                return CASE_CATEGORY_ID;
            case "Monitor":
                return MONITOR_CATEGORY_ID;
            case "Keyboard":
                return KEYBOARD_CATEGORY_ID;
            case "Mouse":
                return MOUSE_CATEGORY_ID;
            default:
                return -1;
        }
    }

    // Kiểm tra và chuẩn hóa tên slot nhận từ request.
    private String normalizeSlot(String slot) {
        if (slot == null) {
            return null;
        }

        switch (slot) {
            case "CPU":
            case "Mainboard":
            case "RAM":
            case "GPU":
            case "SSD":
            case "Case":
            case "Monitor":
            case "Keyboard":
            case "Mouse":
                return slot;
            default:
                return null;
        }
    }

    // Parse một số nguyên dương từ tham số request.
    private Integer parsePositiveInteger(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // Parse giá trị số lượng Build PC chỉ chấp nhận số và phạm vi dương.
    private Integer parseBuildQuantity(String value) {
        if (value == null) {
            return null;
        }

        String trimmed = value.trim();
        if (trimmed.isEmpty() || !trimmed.matches("^\\d+$") || trimmed.length() > MAX_BUILD_QUANTITY_DIGITS) {
            return null;
        }

        try {
            int parsedValue = Integer.parseInt(trimmed);
            return parsedValue >= 1 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // Lấy số lượng mục giỏ hàng của khách hàng đang đăng nhập.
    private int getCartItemCount(HttpSession session) {
        User account = (User) session.getAttribute("account");

        if (account == null || !account.isCustomer()) {
            return 0;
        }

        CartDAO cartDAO = new CartDAO();
        return cartDAO.getCartItemCountByCustomerId(account.getCustomerId());
    }

    // Chuyển thông báo flash một lần từ session sang request.
    private void moveFlash(HttpSession session, HttpServletRequest request, String sessionKey, String requestKey) {
        Object value = session.getAttribute(sessionKey);
        if (value != null) {
            request.setAttribute(requestKey, value);
            session.removeAttribute(sessionKey);
        }
    }

    // Lưu một thông báo flash cho lần render trang tiếp theo.
    private void setFlash(HttpSession session, String message, String type) {
        session.setAttribute(BUILD_MESSAGE, message);
        session.setAttribute(BUILD_MESSAGE_TYPE, type);
    }

    private void respondQuantityError(HttpServletRequest request, HttpServletResponse response,
            HttpSession session, String message) throws IOException {
        setFlash(session, message, "error");
        response.sendRedirect(request.getContextPath() + "/build-pc");
    }

}
