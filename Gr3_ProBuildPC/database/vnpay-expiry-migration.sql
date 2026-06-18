-- Thêm cột vnpay_expires_at vào bảng ORDERS để theo dõi thời gian hết hạn thanh toán VNPAY
ALTER TABLE ORDERS ADD COLUMN vnpay_expires_at DATETIME NULL DEFAULT NULL;
