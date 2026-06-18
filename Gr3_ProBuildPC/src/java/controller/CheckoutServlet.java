package controller;

import dal.AddressDAO;
import dal.CartDAO;
import dal.OrderDAO;
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
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import model.Address;
import model.CartItem;
import model.Product;
import model.User;
import util.VNPayUtil;

@WebServlet(name = "CheckoutServlet", urlPatterns = {"/checkout"})
public class CheckoutServlet extends HttpServlet {

    private static final String VIEW_PATH = "/views/checkout.jsp";
    private static final String CART_SUCCESS_FLASH = "cartSuccessMsg";
    private static final String CART_ERROR_FLASH = "cartErrorMsg";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = requireCustomer(request, response);
        if (account == null) {
            return;
        }

        renderCheckoutPage(request, response, account);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User account = requireCustomer(request, response);
        if (account == null) {
            return;
        }

        String action = safeTrim(request.getParameter("action"));
        if ("placeOrder".equalsIgnoreCase(action)) {
            handlePlaceOrder(request, response, account);
            return;
        }

        renderCheckoutPage(request, response, account);
    }

    private void handlePlaceOrder(HttpServletRequest request, HttpServletResponse response, User account)
            throws ServletException, IOException {
        CheckoutPayload payload = buildCheckoutPayload(request, account);

        if (payload == null || payload.getItems().isEmpty()) {
            setFlashMessage(request.getSession(), CART_ERROR_FLASH, "Khong tim thay san pham de thanh toan.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        if (hasUnavailableItems(payload.getItems())) {
            setFlashMessage(request.getSession(), CART_ERROR_FLASH, "San pham hien khong con kinh doanh.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        AddressDAO addressDAO = new AddressDAO();
        int customerId = account.getCustomerId();
        List<Address> savedAddresses = addressDAO.getAddressesByCustomerId(customerId);
        Integer selectedAddressId = parsePositiveInteger(request.getParameter("selectedAddressId"));
        Address selectedAddress = findAddressById(savedAddresses, selectedAddressId);

        if (selectedAddress == null) {
            request.setAttribute("errorMsg", "Vui long chon dia chi giao hang hop le.");
            renderCheckoutPage(request, response, account);
            return;
        }

        String paymentMethod = normalizePaymentMethod(request.getParameter("paymentMethod"));
        int statusId = "VNPAY".equals(paymentMethod) ? 1 : 2; // 1: Chờ xác nhận, 2: Đã xác nhận (auto-confirmed)
        String paymentStatus = "VNPAY".equals(paymentMethod) ? "Chờ thanh toán" : "Chưa thanh toán";
        String note = safeTrim(request.getParameter("note"));

        OrderDAO orderDAO = new OrderDAO();
        int orderId = orderDAO.createOrder(
                customerId,
                selectedAddress,
                paymentMethod,
                paymentStatus,
                statusId,
                note,
                payload.getItems(),
                payload.isCartCheckout() ? payload.getSelectedCartItemIds() : Collections.emptyList()
        );

        if (orderId == -1) {
            request.setAttribute("errorMsg", "Khong the tao don hang luc nay. Vui long thu lai.");
            renderCheckoutPage(request, response, account);
            return;
        }

        if ("VNPAY".equals(paymentMethod)) {
            BigDecimal totalAmount = calculateSubtotal(payload.getItems());
            orderDAO.setVnpayExpiresAt(orderId, 5); // Đặt thời hạn thanh toán 5 phút
            String paymentUrl = VNPayUtil.buildPaymentUrl(request, orderId, totalAmount.doubleValue());
            response.sendRedirect(paymentUrl);
        } else {
            setFlashMessage(request.getSession(), CART_SUCCESS_FLASH, "Da tao don hang thanh cong.");
            response.sendRedirect(request.getContextPath() + "/cart");
        }
    }

    private void renderCheckoutPage(HttpServletRequest request, HttpServletResponse response, User account)
            throws ServletException, IOException {
        CheckoutPayload payload = buildCheckoutPayload(request, account);

        if (payload == null || payload.getItems().isEmpty()) {
            setFlashMessage(request.getSession(), CART_ERROR_FLASH, "Vui long chon it nhat mot san pham de thanh toan.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        if (hasUnavailableItems(payload.getItems())) {
            setFlashMessage(request.getSession(), CART_ERROR_FLASH, "San pham hien khong con kinh doanh.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        AddressDAO addressDAO = new AddressDAO();
        int customerId = account.getCustomerId();
        List<Address> savedAddresses = addressDAO.getAddressesByCustomerId(customerId);
        Integer selectedAddressId = parsePositiveInteger(request.getParameter("selectedAddressId"));
        Address selectedAddress = resolveSelectedAddress(savedAddresses, selectedAddressId);

        BigDecimal subtotal = calculateSubtotal(payload.getItems());
        BigDecimal total = subtotal;

        request.setAttribute("checkoutItems", payload.getItems());
        request.setAttribute("checkoutSubtotal", subtotal);
        request.setAttribute("checkoutTotal", total);
        request.setAttribute("checkoutLineCount", payload.getItems().size());
        request.setAttribute("checkoutQuantityCount", calculateItemQuantity(payload.getItems()));
        request.setAttribute("savedAddresses", savedAddresses);
        request.setAttribute("selectedAddress", selectedAddress);
        request.setAttribute("selectedAddressId", selectedAddress != null ? selectedAddress.getAddressId() : null);
        request.setAttribute("selectedPaymentMethod", normalizePaymentMethod(request.getParameter("paymentMethod")));
        request.setAttribute("orderNote", safeTrim(request.getParameter("note")));
        request.setAttribute("checkoutMode", payload.getMode());
        request.setAttribute("selectedCartItemIds", payload.getSelectedCartItemIds());
        request.setAttribute("directProductId", payload.getProductId());
        request.setAttribute("directQuantity", payload.getDirectQuantity());
        request.setAttribute("canPlaceOrder", selectedAddress != null);

        CartDAO cartDAO = new CartDAO();
        request.setAttribute("cartItemCount", cartDAO.getCartItemCountByCustomerId(customerId));

        request.getRequestDispatcher(VIEW_PATH).forward(request, response);
    }

    private CheckoutPayload buildCheckoutPayload(HttpServletRequest request, User account) {
        List<Integer> selectedCartItemIds = parsePositiveIntegers(request.getParameterValues("selectedCartItemIds"));

        if (!selectedCartItemIds.isEmpty()) {
            CartDAO cartDAO = new CartDAO();
            List<CartItem> allCartItems = cartDAO.getCartItemsByCustomerId(account.getCustomerId());
            Set<Integer> selectedIdSet = new LinkedHashSet<>(selectedCartItemIds);
            List<CartItem> selectedItems = new ArrayList<>();
            List<Integer> resolvedIds = new ArrayList<>();

            for (CartItem item : allCartItems) {
                if (selectedIdSet.contains(item.getCartItemId())) {
                    selectedItems.add(item);
                    resolvedIds.add(item.getCartItemId());
                }
            }

            if (!selectedItems.isEmpty()) {
                return CheckoutPayload.forCartItems(selectedItems, resolvedIds);
            }
        }

        Integer productId = parsePositiveInteger(request.getParameter("productId"));
        Integer quantity = parsePositiveInteger(request.getParameter("quantity"));

        if (productId == null || quantity == null) {
            return null;
        }

        ProductDAO productDAO = new ProductDAO();
        Product product = productDAO.getProductById(productId);

        if (product == null || product.getQuantity() <= 0) {
            return null;
        }

        int appliedQuantity = Math.min(quantity, product.getQuantity());
        if (appliedQuantity <= 0) {
            return null;
        }

        CartItem directItem = new CartItem();
        directItem.setProductId(productId);
        directItem.setQuantity(appliedQuantity);
        directItem.setProduct(product);

        return CheckoutPayload.forDirectProduct(directItem, productId, appliedQuantity);
    }

    private BigDecimal calculateSubtotal(List<CartItem> items) {
        BigDecimal subtotal = BigDecimal.ZERO;

        for (CartItem item : items) {
            subtotal = subtotal.add(item.getLineTotal());
        }

        return subtotal;
    }

    private int calculateItemQuantity(List<CartItem> items) {
        int totalQuantity = 0;

        for (CartItem item : items) {
            totalQuantity += item.getQuantity();
        }

        return totalQuantity;
    }

    private boolean hasUnavailableItems(List<CartItem> items) {
        for (CartItem item : items) {
            Product product = item.getProduct();
            if (product == null || !product.isAvailableForSale()) {
                return true;
            }
        }

        return false;
    }

    private Address resolveSelectedAddress(List<Address> addresses, Integer selectedAddressId) {
        Address matchedAddress = findAddressById(addresses, selectedAddressId);
        if (matchedAddress != null) {
            return matchedAddress;
        }

        return addresses.isEmpty() ? null : addresses.get(0);
    }

    private Address findAddressById(List<Address> addresses, Integer addressId) {
        if (addresses == null || addressId == null) {
            return null;
        }

        for (Address address : addresses) {
            if (address.getAddressId() == addressId) {
                return address;
            }
        }

        return null;
    }

    private List<Integer> parsePositiveIntegers(String[] values) {
        List<Integer> parsedValues = new ArrayList<>();

        if (values == null) {
            return parsedValues;
        }

        for (String value : values) {
            Integer parsedValue = parsePositiveInteger(value);
            if (parsedValue != null && !parsedValues.contains(parsedValue)) {
                parsedValues.add(parsedValue);
            }
        }

        return parsedValues;
    }

    private Integer parsePositiveInteger(String value) {
        try {
            int parsedValue = Integer.parseInt(value);
            return parsedValue > 0 ? parsedValue : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String normalizePaymentMethod(String rawValue) {
        return "VNPAY".equalsIgnoreCase(safeTrim(rawValue)) ? "VNPAY" : "COD";
    }

    private String safeTrim(String value) {
        return value == null ? "" : value.trim();
    }

    private void setFlashMessage(HttpSession session, String key, String message) {
        session.setAttribute(key, message);
    }

    private User requireCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User account = session != null ? (User) session.getAttribute("account") : null;

        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/Login");
            return null;
        }

        if (!account.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/Dashboard");
            return null;
        }

        return account;
    }

    private static final class CheckoutPayload {

        private final String mode;
        private final List<CartItem> items;
        private final List<Integer> selectedCartItemIds;
        private final Integer productId;
        private final Integer directQuantity;

        private CheckoutPayload(
                String mode,
                List<CartItem> items,
                List<Integer> selectedCartItemIds,
                Integer productId,
                Integer directQuantity) {
            this.mode = mode;
            this.items = items;
            this.selectedCartItemIds = selectedCartItemIds;
            this.productId = productId;
            this.directQuantity = directQuantity;
        }

        private static CheckoutPayload forCartItems(List<CartItem> items, List<Integer> selectedCartItemIds) {
            return new CheckoutPayload("cart", items, selectedCartItemIds, null, null);
        }

        private static CheckoutPayload forDirectProduct(CartItem item, Integer productId, Integer quantity) {
            return new CheckoutPayload(
                    "direct",
                    Collections.singletonList(item),
                    Collections.emptyList(),
                    productId,
                    quantity
            );
        }

        public String getMode() {
            return mode;
        }

        public List<CartItem> getItems() {
            return items;
        }

        public List<Integer> getSelectedCartItemIds() {
            return selectedCartItemIds;
        }

        public Integer getProductId() {
            return productId;
        }

        public Integer getDirectQuantity() {
            return directQuantity;
        }

        public boolean isCartCheckout() {
            return "cart".equals(mode);
        }
    }
}
