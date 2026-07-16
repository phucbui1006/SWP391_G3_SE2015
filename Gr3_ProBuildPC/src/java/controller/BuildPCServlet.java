package controller;

import dal.BuildPCDAO;
import dal.CartDAO;
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
import model.CartItem;
import model.Product;
import model.User;

@WebServlet(name = "BuildPCServlet", urlPatterns = {"/build-pc", "/BuildPC"})
public class BuildPCServlet extends HttpServlet {

    private static final String SESSION_SELECTED_BUILD = "selectedBuild";
    private static final String SESSION_SELECTED_BUILD_QUANTITIES = "selectedBuildQuantities";
    private static final String SESSION_CART_ITEM_COUNT = "sessionCartItemCount";
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
            case "addToCart":
                handleAddToCart(request, response);
                break;
            case "view":
            default:
                showBuildPC(request, response);
                break;
        }
    }

    /**
     * Hiển thị trang Build PC với các linh kiện và số lượng đã chọn hiện tại.
     */
    private void showBuildPC(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        BuildPCDAO buildPCDAO = new BuildPCDAO();
        Map<String, Integer> selectedBuild = getSelectedBuild(session);
        Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
        Map<String, Product> selectedProducts = buildPCDAO.getSelectedBuild(selectedBuild);
        List<BuildPCSlot> buildSlots = createBuildSlots(buildPCDAO, selectedBuild, selectedProducts, selectedQuantities);

        request.setAttribute("buildSlots", buildSlots);
        request.setAttribute("buildTotal", calculateBuildTotal(selectedProducts, selectedQuantities));
        request.setAttribute("cartItemCount", getCartItemCount(session));
        moveFlash(session, request, BUILD_MESSAGE, "buildPcMessage");
        moveFlash(session, request, BUILD_MESSAGE_TYPE, "buildPcMessageType");

        request.getRequestDispatcher("/views/build-pc.jsp").forward(request, response);
    }

    /**
     * Lưu một linh kiện đã chọn vào cấu hình Build PC hiện tại.
     */
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

        selectedBuild.put(slot, productId);
        session.setAttribute(SESSION_SELECTED_BUILD, selectedBuild);

        Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
        if (!selectedQuantities.containsKey(slot)) {
            selectedQuantities.put(slot, 1);
            session.setAttribute(SESSION_SELECTED_BUILD_QUANTITIES, selectedQuantities);
        }

        setFlash(session, "Đã chọn " + product.getProductName() + ".", "success");

        response.sendRedirect(request.getContextPath() + "/build-pc");
    }

    /**
     * Xóa một slot linh kiện khỏi cấu hình Build PC hiện tại.
     */
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

    /**
     * Cập nhật số lượng cho linh kiện đã chọn, bị giới hạn bởi tồn kho có sẵn.
     */
    private void handleUpdateQuantity(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        String slot = normalizeSlot(request.getParameter("slot"));
        Integer quantity = parseBuildQuantity(request.getParameter("quantity"));
        Integer delta = parseInteger(request.getParameter("delta"));

        if (slot == null || (quantity == null && delta == null)) {
            setFlash(session, "Số lượng linh kiện không hợp lệ.", "error");
            response.sendRedirect(request.getContextPath() + "/build-pc");
            return;
        }

        Map<String, Integer> selectedBuild = getSelectedBuild(session);
        if (!selectedBuild.containsKey(slot)) {
            setFlash(session, "Vui lòng chọn linh kiện trước khi chỉnh số lượng.", "error");
            response.sendRedirect(request.getContextPath() + "/build-pc");
            return;
        }

        Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
        if (delta != null) {
            quantity = getSelectedQuantity(selectedQuantities, slot) + delta;
        }

        if (quantity == null || quantity < 1) {
            quantity = 1;
        }

        BuildPCDAO buildPCDAO = new BuildPCDAO();
        int productId = selectedBuild.get(slot);
        int availableQuantity = buildPCDAO.getAvailableQuantity(productId);

        if (availableQuantity <= 0) {
            setFlash(session, "Linh kiện này đã hết hàng.", "error");
            response.sendRedirect(request.getContextPath() + "/build-pc");
            return;
        }

        if (quantity > availableQuantity) {
            quantity = availableQuantity;
        }

        int appliedQuantity = quantity;
        selectedQuantities.put(slot, appliedQuantity);
        session.setAttribute(SESSION_SELECTED_BUILD_QUANTITIES, selectedQuantities);

        if (appliedQuantity < quantity) {
            setFlash(session, "Số lượng vượt tồn kho. Hệ thống đã đặt về mức tối đa có thể mua.", "error");
        }

        response.sendRedirect(request.getContextPath() + "/build-pc");
    }

    /**
     * Reset cấu hình Build PC hiện tại và các số lượng đã chọn.
     */
    private void handleClear(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        session.removeAttribute(SESSION_SELECTED_BUILD);
        session.removeAttribute(SESSION_SELECTED_BUILD_QUANTITIES);
        setFlash(session, "Đã reset toàn bộ cấu hình Build PC.", "success");
        response.sendRedirect(request.getContextPath() + "/build-pc");
    }

    /**
     * Thêm cấu hình Build PC hiện tại vào giỏ hàng của khách sau khi kiểm tra tồn kho và tính tương thích.
     */
    private void handleAddToCart(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        boolean ajaxRequest = isAjaxRequest(request);

        if (account == null) {
            String message = "Bạn cần đăng nhập để thêm cấu hình vào giỏ hàng.";
            if (ajaxRequest) {
                writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, false, message, getCartItemCount(session));
            } else {
                setFlash(session, message, "error");
                response.sendRedirect(request.getContextPath() + "/Login");
            }
            return;
        }

        if (!account.isCustomer()) {
            String message = "Tài khoản nhân viên không thể thêm sản phẩm vào giỏ hàng.";
            respondAddToCartError(request, response, session, ajaxRequest, message);
            return;
        }

        Map<String, Integer> selectedBuild = getSelectedBuild(session);
        Map<String, Integer> selectedQuantities = getSelectedQuantities(session);
        if (selectedBuild.isEmpty()) {
            String message = "Bạn chưa chọn linh kiện nào để thêm vào giỏ hàng.";
            respondAddToCartError(request, response, session, ajaxRequest, message);
            return;
        }

        BuildPCDAO buildPCDAO = new BuildPCDAO();
        CartDAO cartDAO = new CartDAO();
        int customerId = account.getCustomerId();
        List<CartItem> currentCartItems = cartDAO.getCartItemsByCustomerId(customerId);

        for (Map.Entry<String, Integer> entry : selectedBuild.entrySet()) {
            Product product = buildPCDAO.getProductById(entry.getValue());
            int availableQuantity = buildPCDAO.getAvailableQuantity(entry.getValue());
            int currentQuantity = getCurrentCartQuantity(currentCartItems, entry.getValue());
            int requestedQuantity = getSelectedQuantity(selectedQuantities, entry.getKey());

            if (product == null || availableQuantity <= 0) {
                String message = "Một linh kiện trong cấu hình đã hết hàng hoặc ngừng kinh doanh.";
                respondAddToCartError(request, response, session, ajaxRequest, message);
                return;
            }

            if (!isValidSelectedQuantity(selectedQuantities, entry.getKey(), availableQuantity)) {
                String message = "Số lượng linh kiện không hợp lệ. Vui lòng kiểm tra lại cấu hình.";
                respondAddToCartError(request, response, session, ajaxRequest, message);
                return;
            }

            if (!buildPCDAO.isProductCompatibleWithSelectedBuild(entry.getValue(), selectedBuild, entry.getKey())) {
                String message = "Cấu hình hiện tại có linh kiện không tương thích. Vui lòng kiểm tra lại.";
                respondAddToCartError(request, response, session, ajaxRequest, message);
                return;
            }

            if (currentQuantity + requestedQuantity > availableQuantity) {
                String message = product.getProductName() + " đã đạt số lượng tối đa trong giỏ hàng.";
                respondAddToCartError(request, response, session, ajaxRequest, message);
                return;
            }
        }

        for (Map.Entry<String, Integer> entry : selectedBuild.entrySet()) {
            int productId = entry.getValue();
            int requestedQuantity = getSelectedQuantity(selectedQuantities, entry.getKey());
            CartItem existingItem = findCartItemByProductId(currentCartItems, productId);
            boolean success;

            if (existingItem != null) {
                success = cartDAO.updateCartItemQuantity(existingItem.getCartItemId(), existingItem.getQuantity() + requestedQuantity);
                existingItem.setQuantity(existingItem.getQuantity() + requestedQuantity);
            } else {
                success = cartDAO.addCartItemForCustomer(customerId, productId, requestedQuantity) > 0;
            }

            if (!success) {
                String message = "Không thể thêm cấu hình vào giỏ hàng lúc này.";
                respondAddToCartError(request, response, session, ajaxRequest, message);
                return;
            }
        }

        List<CartItem> refreshedCartItems = cartDAO.getCartItemsByCustomerId(customerId);
        int cartItemCount = calculateCartItemCount(refreshedCartItems);
        session.setAttribute(SESSION_CART_ITEM_COUNT, cartItemCount);

        String message = "Đã thêm cấu hình Build PC vào giỏ hàng.";
        if (ajaxRequest) {
            writeJson(response, HttpServletResponse.SC_OK, true, message, cartItemCount);
        } else {
            setFlash(session, message, "success");
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    /**
     * Xây dựng danh sách slot hiển thị trên trang, bao gồm các sản phẩm phù hợp theo tính tương thích.
     */
    private List<BuildPCSlot> createBuildSlots(BuildPCDAO dao, Map<String, Integer> selectedBuild,
            Map<String, Product> selectedProducts, Map<String, Integer> selectedQuantities) {
        List<BuildPCSlot> slots = new ArrayList<>();

        BuildPCSlot cpu = new BuildPCSlot("CPU", "Bộ vi xử lý (CPU)", CPU_CATEGORY_ID, true);
        cpu.setAvailableProducts(dao.getProductsByCategoryCompatibleWithBuild(CPU_CATEGORY_ID, selectedBuild, "CPU"));
        slots.add(cpu);

        BuildPCSlot mainboard = new BuildPCSlot("Mainboard", "Bo mạch chủ", MAINBOARD_CATEGORY_ID, true);
        mainboard.setAvailableProducts(dao.getProductsByCategoryCompatibleWithBuild(MAINBOARD_CATEGORY_ID, selectedBuild, "Mainboard"));
        slots.add(mainboard);

        BuildPCSlot ram = new BuildPCSlot("RAM", "Bộ nhớ RAM", RAM_CATEGORY_ID, true);
        ram.setAvailableProducts(dao.getProductsByCategoryCompatibleWithBuild(RAM_CATEGORY_ID, selectedBuild, "RAM"));
        slots.add(ram);

        BuildPCSlot gpu = new BuildPCSlot("GPU", "Card đồ họa", GPU_CATEGORY_ID, true);
        gpu.setAvailableProducts(dao.getProductsByCategoryCompatibleWithBuild(GPU_CATEGORY_ID, selectedBuild, "GPU"));
        slots.add(gpu);

        slots.add(createAccessorySlot(dao, "SSD", "Ổ cứng SSD", SSD_CATEGORY_ID));
        slots.add(createAccessorySlot(dao, "Case", "Vỏ máy tính", CASE_CATEGORY_ID));
        slots.add(createAccessorySlot(dao, "Monitor", "Màn hình", MONITOR_CATEGORY_ID));
        slots.add(createAccessorySlot(dao, "Keyboard", "Bàn phím", KEYBOARD_CATEGORY_ID));
        slots.add(createAccessorySlot(dao, "Mouse", "Chuột", MOUSE_CATEGORY_ID));

        for (BuildPCSlot slot : slots) {
            slot.setSelectedProduct(selectedProducts.get(slot.getKey()));
            slot.setQuantity(getSelectedQuantity(selectedQuantities, slot.getKey()));
        }

        return slots;
    }

    /**
     * Tạo slot không cần kiểm tra tương thích như SSD, case, màn hình, bàn phím hoặc chuột.
     */
    private BuildPCSlot createAccessorySlot(BuildPCDAO dao, String key, String displayName, int categoryId) {
        BuildPCSlot slot = new BuildPCSlot(key, displayName, categoryId, false);
        // Phụ kiện không kiểm tra tương thích, chỉ cần ACTIVE và còn hàng.
        slot.setAvailableProducts(dao.getProductsByCategory(categoryId));
        return slot;
    }

    /**
     * Đọc các ID linh kiện đã chọn từ session.
     */
    @SuppressWarnings("unchecked")
    private Map<String, Integer> getSelectedBuild(HttpSession session) {
        Object value = session.getAttribute(SESSION_SELECTED_BUILD);

        if (value instanceof Map<?, ?>) {
            return new LinkedHashMap<>((Map<String, Integer>) value);
        }

        return new LinkedHashMap<>();
    }

    /**
     * Đọc các số lượng đã chọn từ session.
     */
    @SuppressWarnings("unchecked")
    private Map<String, Integer> getSelectedQuantities(HttpSession session) {
        Object value = session.getAttribute(SESSION_SELECTED_BUILD_QUANTITIES);

        if (value instanceof Map<?, ?>) {
            return new LinkedHashMap<>((Map<String, Integer>) value);
        }

        return new LinkedHashMap<>();
    }

    /**
     * Tính tổng giá trị của cấu hình Build PC hiện tại.
     */
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

    /**
     * Trả về số lượng an toàn, mặc định là 1 khi thiếu hoặc không hợp lệ.
     */
    private int getSelectedQuantity(Map<String, Integer> selectedQuantities, String slot) {
        Integer quantity = selectedQuantities.get(slot);
        return quantity == null || quantity < 1 ? 1 : quantity;
    }

    private boolean isValidSelectedQuantity(Map<String, Integer> selectedQuantities, String slot, int availableQuantity) {
        Integer quantity = selectedQuantities.get(slot);
        if (quantity == null) {
            quantity = 1;
        }
        return quantity >= 1 && quantity <= availableQuantity;
    }

    /**
     * Xác nhận rằng số lượng đã lưu là dương và không vượt quá tồn kho.
     */
    private boolean isValidSelectedQuantity(Map<String, Integer> selectedQuantities, String slot, int availableQuantity) {
        Integer quantity = selectedQuantities.get(slot);
        if (quantity == null) {
            quantity = 1;
        }
        return quantity >= 1 && quantity <= availableQuantity;
    }

    /**
     * Ánh xạ key slot trên giao diện với category id tương ứng.
     */
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

    /**
     * Kiểm tra và chuẩn hóa tên slot nhận từ request.
     */
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

    /**
     * Parse một số nguyên dương từ tham số request.
     */
    private Integer parsePositiveInteger(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

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

    /**
     * Parse giá trị số lượng Build PC chỉ chấp nhận số và phạm vi dương.
     */
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

    /**
     * Parse một số nguyên tổng quát cho cập nhật theo delta.
     */
    private Integer parseInteger(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * Tìm mục giỏ hàng tương ứng với sản phẩm trong giỏ hiện tại.
     */
    private CartItem findCartItemByProductId(List<CartItem> cartItems, int productId) {
        for (CartItem item : cartItems) {
            if (item.getProductId() == productId) {
                return item;
            }
        }

        return null;
    }

    /**
     * Lấy số lượng sản phẩm đã có trong giỏ hàng.
     */
    private int getCurrentCartQuantity(List<CartItem> cartItems, int productId) {
        CartItem item = findCartItemByProductId(cartItems, productId);
        return item == null ? 0 : item.getQuantity();
    }

    /**
     * Tính tổng số lượng trong giỏ để lấy số lượng mục giỏ hàng.
     */
    private int calculateCartItemCount(List<CartItem> cartItems) {
        int count = 0;

        for (CartItem item : cartItems) {
            count += item.getQuantity();
        }

        return count;
    }

    /**
     * Lấy số lượng mục giỏ hàng của khách hàng đang đăng nhập.
     */
    private int getCartItemCount(HttpSession session) {
        User account = (User) session.getAttribute("account");

        if (account == null || !account.isCustomer()) {
            return 0;
        }

        CartDAO cartDAO = new CartDAO();
        return cartDAO.getCartItemCountByCustomerId(account.getCustomerId());
    }

    /**
     * Chuyển thông báo flash một lần từ session sang request.
     */
    private void moveFlash(HttpSession session, HttpServletRequest request, String sessionKey, String requestKey) {
        Object value = session.getAttribute(sessionKey);
        if (value != null) {
            request.setAttribute(requestKey, value);
            session.removeAttribute(sessionKey);
        }
    }

    /**
     * Lưu một thông báo flash cho lần render trang tiếp theo.
     */
    private void setFlash(HttpSession session, String message, String type) {
        session.setAttribute(BUILD_MESSAGE, message);
        session.setAttribute(BUILD_MESSAGE_TYPE, type);
    }
}
