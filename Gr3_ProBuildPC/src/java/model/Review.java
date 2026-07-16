package model;

import java.util.Date;
import java.util.List;
import java.util.ArrayList;

public class Review {
    private int reviewId;
    private int customerId;
    private String reviewerName;
    private int rating;
    private int productId;
    private String comment;
    private Date date;
    private List<String> images = new ArrayList<>();

    public Review() {
    }

    public Review(int reviewId, int customerId, int rating, int productId, String comment, Date date) {
        this.reviewId = reviewId;
        this.customerId = customerId;
        this.rating = rating;
        this.productId = productId;
        this.comment = comment;
        this.date = date;
    }

    public int getReviewId() {
        return reviewId;
    }

    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
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

    public int getRating() {
        return rating;
    }

    public String getReviewerName() {
        return reviewerName;
    }

    public void setReviewerName(String reviewerName) {
        this.reviewerName = reviewerName;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }



    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public List<String> getImages() {
        return images;
    }

    public void setImages(List<String> images) {
        this.images = images;
    }
}
