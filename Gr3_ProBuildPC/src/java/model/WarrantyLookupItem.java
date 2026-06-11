package model;

import java.util.Date;

public class WarrantyLookupItem {
    private int orderDetailId;
    private int productId;
    private int quantity;
    private String productName;
    private String brandName;
    private String categoryName;
    private String imageUrl;
    private int warrantyMonths;
    private Date warrantyEndDate;
    private long remainingDays;

    public int getOrderDetailId() {
        return orderDetailId;
    }

    public void setOrderDetailId(int orderDetailId) {
        this.orderDetailId = orderDetailId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
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

    public String getWarrantyState() {
        if (warrantyMonths <= 0) {
            return "no-warranty";
        }

        if (remainingDays < 0) {
            return "expired";
        }

        if (remainingDays <= 30) {
            return "expiring";
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

        if (remainingDays == 0) {
            return "Hết hạn hôm nay";
        }

        return "Còn " + remainingDays + " ngày";
    }

    public String getWarrantyStatusLabel() {
        String state = getWarrantyState();

        if ("expired".equals(state)) {
            return "Hết bảo hành";
        }

        if ("expiring".equals(state)) {
            return "Sắp hết hạn";
        }

        if ("no-warranty".equals(state)) {
            return "Không bảo hành";
        }

        return "Còn bảo hành";
    }
}
