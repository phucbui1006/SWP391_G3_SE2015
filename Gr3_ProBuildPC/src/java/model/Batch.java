package model;

import java.sql.Date;

public class Batch {
    private int batchId;
    private int categoryId;
    private int brandId;
    private String batchName;
    private Date date;
    private boolean isEdited;

    public Batch() {
    }

    public Batch(int batchId, int categoryId, int brandId, String batchName) {
        this.batchId = batchId;
        this.categoryId = categoryId;
        this.brandId = brandId;
        this.batchName = batchName;
        this.isEdited = false;
    }

    public Batch(int batchId, String batchName, Date date) {
        this.batchId = batchId;
        this.batchName = batchName;
        this.date = date;
        this.isEdited = false;
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

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public boolean isEdited() {
        return isEdited;
    }

    public void setEdited(boolean isEdited) {
        this.isEdited = isEdited;
    }
}
