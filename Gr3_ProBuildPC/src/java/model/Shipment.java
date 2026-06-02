package model;

public class Shipment {
    private int shipmentId;
    private int orderId;
    private String trackingCode;
    private String shipmentStatus;
    private String note;

    public Shipment() {
    }

    public Shipment(int shipmentId, int orderId, String trackingCode, String shipmentStatus, String note) {
        this.shipmentId = shipmentId;
        this.orderId = orderId;
        this.trackingCode = trackingCode;
        this.shipmentStatus = shipmentStatus;
        this.note = note;
    }

    public int getShipmentId() {
        return shipmentId;
    }

    public void setShipmentId(int shipmentId) {
        this.shipmentId = shipmentId;
    }

    public int getOrderId() {
        return orderId;
    }

    public void setOrderId(int orderId) {
        this.orderId = orderId;
    }

    public String getTrackingCode() {
        return trackingCode;
    }

    public void setTrackingCode(String trackingCode) {
        this.trackingCode = trackingCode;
    }

    public String getShipmentStatus() {
        return shipmentStatus;
    }

    public void setShipmentStatus(String shipmentStatus) {
        this.shipmentStatus = shipmentStatus;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}