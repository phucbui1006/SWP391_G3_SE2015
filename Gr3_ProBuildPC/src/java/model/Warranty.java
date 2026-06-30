package model;

import java.util.Date;
import java.math.BigDecimal;

public class Warranty {
    private int warrantyId;
    private int customerId;
    private int productId;
    private int statusId;
    private Date requestDate;
    private Date responseDate;
    private String request;
    private String productName;
    private String statusName;
    private String storeResponse;
    private String response;
    private String customerName;
    private int orderId;
    private int quantity;
    private String brandName;
    private String categoryName;
    private String imageUrl;
    private int warrantyMonths;
    private Date warrantyEndDate;
    private long remainingDays;
    private Date orderDate;
    private Date deliveryDate;
    private BigDecimal totalAmount;
    private String paymentMethod;
    private String paymentStatus;
    private String orderStatusName;

    public Warranty() {
    }

    public Warranty(int warrantyId, int customerId, int productId,
                    int statusId, Date requestDate, String request) {
        this.warrantyId = warrantyId;
        this.customerId = customerId;
        this.productId = productId;
        this.statusId = statusId;
        this.requestDate = requestDate;
        this.request = request;
    }

    public int getWarrantyId() {
        return warrantyId;
    }

    public void setWarrantyId(int warrantyId) {
        this.warrantyId = warrantyId;
    }



    public int getUserId() {
        return customerId;
    }

    public void setUserId(int userId) {
        this.customerId = userId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getStatusId() {
        return statusId;
    }

    public void setStatusId(int statusId) {
        this.statusId = statusId;
    }

    public Date getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(Date requestDate) {
        this.requestDate = requestDate;
    }

    public Date getResponseDate() {
        return responseDate;
    }

    public void setResponseDate(Date responseDate) {
        this.responseDate = responseDate;
    }


    public String getRequest() {
        return request;
    }

    public void setRequest(String request) {
        this.request = request;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getStatusName() {
        return statusName;
    }

    public void setStatusName(String statusName) {
        this.statusName = statusName;
    }

    public String getStoreResponse() {
        return storeResponse;
    }

    public void setStoreResponse(String storeResponse) {
        this.storeResponse = storeResponse;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getWarrantyMonths() {
        return warrantyMonths;
    }

    public void setWarrantyMonths(int warrantyMonths) {
        this.warrantyMonths = warrantyMonths;
    }

    public Date getWarrantyEndDate() {
        return warrantyEndDate;
    }

    public void setWarrantyEndDate(Date warrantyEndDate) {
        this.warrantyEndDate = warrantyEndDate;
    }

    public long getRemainingDays() {
        return remainingDays;
    }

    public void setRemainingDays(long remainingDays) {
        this.remainingDays = remainingDays;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public Date getDeliveryDate() {
        return deliveryDate;
    }

    public void setDeliveryDate(Date deliveryDate) {
        this.deliveryDate = deliveryDate;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getOrderStatusName() {
        return orderStatusName;
    }

    public void setOrderStatusName(String orderStatusName) {
        this.orderStatusName = orderStatusName;
    }

    public String getWarrantyState() {
        if (warrantyMonths <= 0) {
            return "no-warranty";
        }

        if (remainingDays < 0) {
            return "expired";
        }

        

        return "active";
    }

    public String getRemainingDaysLabel() {
        if (warrantyMonths <= 0) {
            return "Không bảo hành";
        }

        if (remainingDays < 0) {
            return "Hết hạn";
        }

        return "Còn " + remainingDays + " ngày";
    }

    public String getWarrantyStatusLabel() {
        String state = getWarrantyState();

        if ("expired".equals(state)) {
            return "Hết bảo hành";
        }

        if ("no-warranty".equals(state)) {
            return "Không bảo hành";
        }

        return "Còn bảo hành";
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }
}
