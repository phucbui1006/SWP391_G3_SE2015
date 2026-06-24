SET NAMES utf8mb4;

DROP DATABASE IF EXISTS db1;
CREATE DATABASE db1
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE db1;

-- =========================
-- VAI TRÒ
-- =========================
CREATE TABLE ROLES (
    role_id   INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE
);

-- =========================
-- NGƯỜI DÙNG
-- =========================
CREATE TABLE USERS (
    user_id      INT AUTO_INCREMENT PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    status       ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
    email        VARCHAR(255) NOT NULL UNIQUE,
    password     VARCHAR(255) NOT NULL,
    account_type VARCHAR(20) NOT NULL
);

-- =========================
-- KHÁCH HÀNG
-- =========================
CREATE TABLE CUSTOMERS (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL UNIQUE,

    CONSTRAINT FK_CUSTOMERS_USERS
        FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- =========================
-- NHÂN VIÊN
-- =========================
CREATE TABLE STAFFS (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id  INT NOT NULL UNIQUE,
    role_id  INT NOT NULL,

    CONSTRAINT FK_STAFFS_USERS
        FOREIGN KEY (user_id) REFERENCES USERS(user_id),

    CONSTRAINT FK_STAFFS_ROLES
        FOREIGN KEY (role_id) REFERENCES ROLES(role_id)
);

-- =========================
-- ĐỊA CHỈ
-- =========================
CREATE TABLE ADDRESS (
    address_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_id    INT NOT NULL,
    recipient_name VARCHAR(100),
    phone_number   VARCHAR(20),
    address_detail VARCHAR(255),

    CONSTRAINT FK_ADDRESS_CUSTOMERS
        FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- =========================
-- DANH MỤC
-- =========================
CREATE TABLE CATEGORIES (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    status        ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE'
);

-- =========================
-- THÔNG SỐ DANH MỤC (TEMPLATE)
-- =========================
CREATE TABLE CATEGORY_SPEC_TEMPLATES (
    template_id    INT AUTO_INCREMENT PRIMARY KEY,
    category_id    INT NOT NULL,
    spec_name      VARCHAR(255) NOT NULL,
    spec_type      ENUM('TEXT', 'SELECT', 'NUMBER') NOT NULL,
    allowed_values VARCHAR(500) NULL,
    is_required    BOOLEAN DEFAULT TRUE,
    display_order  INT DEFAULT 0,

    CONSTRAINT FK_TEMPLATE_CATEGORY
        FOREIGN KEY (category_id) REFERENCES CATEGORIES(category_id),

    CONSTRAINT UQ_CATEGORY_SPEC
        UNIQUE (category_id, spec_name)
);

-- =========================
-- THƯƠNG HIỆU
-- =========================
CREATE TABLE BRANDS (
    brand_id   INT AUTO_INCREMENT PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE,
    img        VARCHAR(255),
    status     ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE'
);

-- =========================
-- SẢN PHẨM
-- =========================
CREATE TABLE PRODUCTS (
    product_id      INT AUTO_INCREMENT PRIMARY KEY,
    category_id     INT NOT NULL,
    brand_id        INT NOT NULL,
    product_name    VARCHAR(255) NOT NULL,
    description     TEXT,
    image_url       VARCHAR(255),
    price           DECIMAL(18, 2) NOT NULL,
    status          ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',

    CONSTRAINT FK_PRODUCTS_CATEGORY
        FOREIGN KEY (category_id) REFERENCES CATEGORIES(category_id),

    CONSTRAINT FK_PRODUCTS_BRAND
        FOREIGN KEY (brand_id) REFERENCES BRANDS(brand_id)
);

-- =========================
-- THÔNG SỐ SẢN PHẨM
-- =========================
CREATE TABLE PRODUCT_SPECIFICATIONS (
    spec_id             INT AUTO_INCREMENT PRIMARY KEY,
    product_id          INT NOT NULL,
    specification_name  VARCHAR(255) NOT NULL,
    specification_value VARCHAR(255) NOT NULL,

    CONSTRAINT FK_SPEC_PRODUCTS
        FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);

-- =========================
-- QUY TẮC TƯƠNG THÍCH
-- =========================
CREATE TABLE COMPATIBILITY_RULES (
    rule_id             INT AUTO_INCREMENT PRIMARY KEY,
    source_category_id  INT,
    target_category_id  INT,
    source_spec_name    VARCHAR(255),
    target_spec_name    VARCHAR(255),
    comparison_operator VARCHAR(50),

    CONSTRAINT FK_COMPAT_SOURCE
        FOREIGN KEY (source_category_id) REFERENCES CATEGORIES(category_id),

    CONSTRAINT FK_COMPAT_TARGET
        FOREIGN KEY (target_category_id) REFERENCES CATEGORIES(category_id)
);

-- =========================
-- LÔ NHẬP
-- =========================
CREATE TABLE BATCH (
    batch_id   INT AUTO_INCREMENT PRIMARY KEY,
    batch_name VARCHAR(255) NOT NULL,
    date       DATE NOT NULL
);

-- =========================
-- CHI TIẾT LÔ NHẬP
-- import_quantity: số lượng nhập ban đầu (không thay đổi)
-- quantity: số lượng tồn kho (trừ khi bán, cộng khi hủy)
-- warranty_months: thời gian bảo hành theo lô
-- =========================
CREATE TABLE BATCH_ITEMS (
    batch_item_id   INT AUTO_INCREMENT PRIMARY KEY,
    batch_id        INT NOT NULL,
    product_id      INT NOT NULL,
    import_quantity INT NOT NULL,
    quantity        INT NOT NULL,
    price           DECIMAL(18, 2) NOT NULL,
    warranty_months INT NOT NULL DEFAULT 0,

    CONSTRAINT FK_BATCH_ITEMS_BATCH
        FOREIGN KEY (batch_id) REFERENCES BATCH(batch_id),

    CONSTRAINT FK_BATCH_ITEMS_PRODUCT
        FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id),

    CONSTRAINT UQ_BATCH_PRODUCT
        UNIQUE (batch_id, product_id)
);

-- =========================
-- GIỎ HÀNG
-- =========================
CREATE TABLE CART (
    cart_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,

    CONSTRAINT FK_CART_CUSTOMERS
        FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id)
);

-- =========================
-- CHI TIẾT GIỎ HÀNG
-- =========================
CREATE TABLE CART_ITEMS (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id      INT NOT NULL,
    product_id   INT NOT NULL,
    quantity     INT NOT NULL,

    CONSTRAINT FK_CART_ITEMS_CART
        FOREIGN KEY (cart_id) REFERENCES CART(cart_id),

    CONSTRAINT FK_CART_ITEMS_PRODUCTS
        FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);

-- =========================
-- ĐÁNH GIÁ
-- =========================
CREATE TABLE REVIEWS (
    review_id   INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id  INT NOT NULL,
    rating      INT NOT NULL,
    comment     TEXT,
    date        DATETIME,

    CONSTRAINT FK_REVIEWS_CUSTOMERS
        FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),

    CONSTRAINT FK_REVIEWS_PRODUCTS
        FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);

-- =========================
-- ẢNH ĐÁNH GIÁ
-- =========================
CREATE TABLE REVIEW_IMAGES (
    image_id  INT AUTO_INCREMENT PRIMARY KEY,
    review_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,

    CONSTRAINT FK_REVIEW_IMAGES_REVIEWS
        FOREIGN KEY (review_id) REFERENCES REVIEWS(review_id) ON DELETE CASCADE
);

-- =========================
-- TRẠNG THÁI ĐƠN HÀNG
-- =========================
CREATE TABLE ORDERS_STATUS (
    status_id   INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE
);

-- =========================
-- ĐƠN HÀNG
-- =========================
CREATE TABLE ORDERS (
    order_id         INT AUTO_INCREMENT PRIMARY KEY,
    customer_id      INT NOT NULL,
    status_id        INT,
    order_date       DATETIME,
    total_amount     DECIMAL(18, 2),
    shipping_address VARCHAR(255) NOT NULL,
    payment_method   VARCHAR(100) NOT NULL,
    payment_status   VARCHAR(50) DEFAULT 'Chưa thanh toán',
    note             TEXT,
    vnpay_expires_at DATETIME NULL DEFAULT NULL,

    CONSTRAINT FK_ORDERS_CUSTOMERS
        FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),

    CONSTRAINT FK_ORDERS_STATUS
        FOREIGN KEY (status_id) REFERENCES ORDERS_STATUS(status_id)
) AUTO_INCREMENT = 10000;

-- =========================
-- CHI TIẾT ĐƠN HÀNG
-- =========================
CREATE TABLE ORDER_DETAILS (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT NOT NULL,
    unit_price      DECIMAL(18, 2) NOT NULL,
    subtotal        DECIMAL(18, 2) NOT NULL,

    CONSTRAINT FK_ORDER_DETAILS_ORDERS
        FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),

    CONSTRAINT FK_ORDER_DETAILS_PRODUCTS
        FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id)
);

-- =========================
-- THANH TOÁN
-- =========================
CREATE TABLE PAYMENTS (
    payment_id       INT AUTO_INCREMENT PRIMARY KEY,
    order_id         INT NOT NULL UNIQUE,
    payment_status   VARCHAR(50),
    payment_provider VARCHAR(100),
    amount           DECIMAL(18, 2) NOT NULL,

    CONSTRAINT FK_PAYMENTS_ORDERS
        FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
);

-- =========================
-- VẬN CHUYỂN
-- =========================
CREATE TABLE SHIPMENTS (
    shipment_id     INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL UNIQUE,
    tracking_code   VARCHAR(100) UNIQUE,
    shipment_status VARCHAR(50),
    note            TEXT,

    CONSTRAINT FK_SHIPMENTS_ORDERS
        FOREIGN KEY (order_id) REFERENCES ORDERS(order_id)
);

-- =========================
-- TRẠNG THÁI BẢO HÀNH
-- =========================
CREATE TABLE WARRANTY_STATUS (
    status_id   INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE
);

-- =========================
-- BẢO HÀNH
-- KHÔNG NỐI ORDERS
-- KHÔNG NỐI ORDER_DETAILS
-- Chỉ nối CUSTOMERS, PRODUCTS, WARRANTY_STATUS
-- =========================
CREATE TABLE WARRANTIES (
    warranty_id  INT AUTO_INCREMENT PRIMARY KEY,
    customer_id  INT NOT NULL,
    product_id   INT NOT NULL,
    status_id    INT,
    request_date DATETIME NOT NULL,
    request      TEXT,

    CONSTRAINT FK_WARRANTIES_CUSTOMERS
        FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),

    CONSTRAINT FK_WARRANTIES_PRODUCTS
        FOREIGN KEY (product_id) REFERENCES PRODUCTS(product_id),

    CONSTRAINT FK_WARRANTIES_STATUS
        FOREIGN KEY (status_id) REFERENCES WARRANTY_STATUS(status_id)
);