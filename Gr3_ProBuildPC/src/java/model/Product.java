package model;

import java.math.BigDecimal;

public class Product {
    private int productId;
    private BigDecimal price;
    private int quantity;
    private int batchId;
    private String description;
    private String imageUrl;
    private int warrantyMonths;
    private String productName;
    private String brandName;
    private String categoryName;

    public Product() {
    }

    public Product(int productId, BigDecimal price, int quantity, int batchId,
                   String description, String imageUrl, int warrantyMonths, String productName) {
        this.productId = productId;
        this.price = price;
        this.quantity = quantity;
        this.batchId = batchId;
        this.description = description;
        this.imageUrl = imageUrl;
        this.warrantyMonths = warrantyMonths;
        this.productName = productName;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public int getBatchId() {
        return batchId;
    }

    public void setBatchId(int batchId) {
        this.batchId = batchId;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
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
}
