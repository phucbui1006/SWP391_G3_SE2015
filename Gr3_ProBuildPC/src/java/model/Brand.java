package model;

public class Brand {
    private int brandId;
    private String brandName;
    private String img;
    private int productCount;
    private String status;

    public Brand() {
    }

    public Brand(int brandId, String brandName, String img) {
        this.brandId = brandId;
        this.brandName = brandName;
        this.img = img;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    public String getImg() {
        return img;
    }

    public void setImg(String img) {
        this.img = img;
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
