package model;

public class ProductSpecification {
    private int specId;
    private int productId;
    private String specificationName;
    private String specificationValue;

    public ProductSpecification() {
    }

    public ProductSpecification(int specId, int productId, String specificationName, String specificationValue) {
        this.specId = specId;
        this.productId = productId;
        this.specificationName = specificationName;
        this.specificationValue = specificationValue;
    }

    public int getSpecId() {
        return specId;
    }

    public void setSpecId(int specId) {
        this.specId = specId;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getSpecificationName() {
        return specificationName;
    }

    public void setSpecificationName(String specificationName) {
        this.specificationName = specificationName;
    }

    public String getSpecificationValue() {
        return specificationValue;
    }

    public void setSpecificationValue(String specificationValue) {
        this.specificationValue = specificationValue;
    }
}