package model;

import java.util.Date;

public class Warranty {
    private int warrantyId;
    private int orderDetailId;
    private int userId;
    private int productId;
    private int statusId;
    private Date requestDate;
    private String request;

    public Warranty() {
    }

    public Warranty(int warrantyId, int orderDetailId, int userId, int productId,
                    int statusId, Date requestDate, String request) {
        this.warrantyId = warrantyId;
        this.orderDetailId = orderDetailId;
        this.userId = userId;
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

    public int getOrderDetailId() {
        return orderDetailId;
    }

    public void setOrderDetailId(int orderDetailId) {
        this.orderDetailId = orderDetailId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
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

    public String getRequest() {
        return request;
    }

    public void setRequest(String request) {
        this.request = request;
    }
}