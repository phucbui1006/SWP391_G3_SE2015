package model;

import java.util.ArrayList;
import java.util.List;

public class BuildPCSlot {
    private String key;
    private String displayName;
    private int categoryId;
    private boolean compatibilityChecked;
    private int quantity;
    private Product selectedProduct;
    private List<Product> availableProducts;

    public BuildPCSlot() {
        quantity = 1;
        availableProducts = new ArrayList<>();
    }

    public BuildPCSlot(String key, String displayName, int categoryId, boolean compatibilityChecked) {
        this.key = key;
        this.displayName = displayName;
        this.categoryId = categoryId;
        this.compatibilityChecked = compatibilityChecked;
        this.quantity = 1;
        this.availableProducts = new ArrayList<>();
    }

    public String getKey() {
        return key;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public boolean isCompatibilityChecked() {
        return compatibilityChecked;
    }

    public void setCompatibilityChecked(boolean compatibilityChecked) {
        this.compatibilityChecked = compatibilityChecked;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity < 1 ? 1 : quantity;
    }

    public Product getSelectedProduct() {
        return selectedProduct;
    }

    public void setSelectedProduct(Product selectedProduct) {
        this.selectedProduct = selectedProduct;
    }

    public List<Product> getAvailableProducts() {
        return availableProducts;
    }

    public void setAvailableProducts(List<Product> availableProducts) {
        this.availableProducts = availableProducts;
    }

    public boolean isSelected() {
        return selectedProduct != null;
    }
}
