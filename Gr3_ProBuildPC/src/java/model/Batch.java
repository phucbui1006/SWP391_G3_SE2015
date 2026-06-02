package model;

public class Batch {
    private int batchId;
    private int categoryId;
    private int brandId;
    private String batchName;

    public Batch() {
    }

    public Batch(int batchId, int categoryId, int brandId, String batchName) {
        this.batchId = batchId;
        this.categoryId = categoryId;
        this.brandId = brandId;
        this.batchName = batchName;
    }

    public int getBatchId() {
        return batchId;
    }

    public void setBatchId(int batchId) {
        this.batchId = batchId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public String getBatchName() {
        return batchName;
    }

    public void setBatchName(String batchName) {
        this.batchName = batchName;
    }
}