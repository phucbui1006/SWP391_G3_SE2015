package model;

public class Address {
    private int addressId;
    private int customerId;
    private String recipientName;
    private String phoneNumber;
    private String addressDetail;

    public Address() {
    }

    public Address(int addressId, int customerId, String recipientName, String phoneNumber, String addressDetail) {
        this.addressId = addressId;
        this.customerId = customerId;
        this.recipientName = recipientName;
        this.phoneNumber = phoneNumber;
        this.addressDetail = addressDetail;
    }

    public int getAddressId() {
        return addressId;
    }

    public void setAddressId(int addressId) {
        this.addressId = addressId;
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

    public String getRecipientName() {
        return recipientName;
    }

    public void setRecipientName(String recipientName) {
        this.recipientName = recipientName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getAddressDetail() {
        return addressDetail;
    }

    public void setAddressDetail(String addressDetail) {
        this.addressDetail = addressDetail;
    }
}
