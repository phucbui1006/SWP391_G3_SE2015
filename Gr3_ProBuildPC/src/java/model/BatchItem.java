package model;

import java.math.BigDecimal;

public class BatchItem {
    private int batchItemId;
    private int batchId;
    private int productId;
    private int importQuantity;
    private int quantity;
    private BigDecimal price;
    private boolean isEdited;

    public BatchItem() {
    }

    public BatchItem(int batchItemId, int batchId, int productId,
                     int importQuantity, int quantity, BigDecimal price) {
        this.batchItemId = batchItemId;
        this.batchId = batchId;
        this.productId = productId;
        this.importQuantity = importQuantity;
        this.quantity = quantity;
        this.price = price;
        this.isEdited = false;
    }

    public int getBatchItemId() {
        return batchItemId;
    }

    public void setBatchItemId(int batchItemId) {
        this.batchItemId = batchItemId;
    }

    public int getBatchId() {
        return batchId;
    }

    public void setBatchId(int batchId) {
        this.batchId = batchId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getImportQuantity() {
        return importQuantity;
    }

    public void setImportQuantity(int importQuantity) {
        this.importQuantity = importQuantity;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public boolean isEdited() {
        return isEdited;
    }

    public void setEdited(boolean isEdited) {
        this.isEdited = isEdited;
    }
}
