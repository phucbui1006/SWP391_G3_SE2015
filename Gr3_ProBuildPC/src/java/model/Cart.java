package model;

public class Cart {
    private int cartId;
    private int customerId;

    public Cart() {
    }

    public Cart(int cartId, int customerId) {
        this.cartId = cartId;
        this.customerId = customerId;
    }

    public int getCartId() {
        return cartId;
    }

    public void setCartId(int cartId) {
        this.cartId = cartId;
    }

    public int getUserId() {
        return customerId;
    }

    public void setUserId(int userId) {
        this.customerId = userId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }
}
