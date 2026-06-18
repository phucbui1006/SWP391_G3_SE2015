package model;

public class Category {

    private int categoryId;
    private String categoryName;
    private int productCount;
    private String status;

    public Category() {
    }

    public Category(int categoryId, String categoryName, String status) {
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.status = status;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public int getProductCount() {
        return productCount;
    }

    public void setProductCount(int productCount) {
        this.productCount = productCount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
