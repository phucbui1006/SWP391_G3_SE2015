CREATE DATABASE db1;


USE db1;

CREATE TABLE ROLES (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE
);

-- =========================
-- USERS
-- =========================
CREATE TABLE USERS (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    account_type VARCHAR(20) NOT NULL
);

-- =========================
-- CUSTOMERS
-- =========================
CREATE TABLE CUSTOMERS (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,

    CONSTRAINT FK_CUSTOMERS_USERS
        FOREIGN KEY (user_id)
        REFERENCES USERS(user_id)
);

-- =========================
-- STAFFS
-- =========================
CREATE TABLE STAFFS (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    role_id INT NOT NULL,

    CONSTRAINT FK_STAFFS_USERS
        FOREIGN KEY (user_id)
        REFERENCES USERS(user_id),

    CONSTRAINT FK_STAFFS_ROLES
        FOREIGN KEY (role_id)
        REFERENCES ROLES(role_id)
);

-- =========================
-- ADDRESS
-- =========================
CREATE TABLE Address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    recipient_name VARCHAR(100),
    phoneNumber VARCHAR(20) NULL,
    Address_detail VARCHAR(255),

    CONSTRAINT FK_ADDRESS_CUSTOMERS
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMERS(customer_id)
);

-- =========================
-- CATEGORIES
-- =========================
CREATE TABLE CATEGORIES (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

-- =========================
-- BRANDS
-- =========================
CREATE TABLE BRANDS (
    brand_id INT AUTO_INCREMENT PRIMARY KEY,
    brand_name VARCHAR(100) UNIQUE NOT NULL,
    img VARCHAR(255) UNIQUE NOT NULL
);

-- =========================
-- BATCH
-- =========================
CREATE TABLE Batch (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    brand_id INT,
    batch_name VARCHAR(255) NOT NULL,

    CONSTRAINT FK_BATCH_CATEGORY
        FOREIGN KEY (category_id)
        REFERENCES CATEGORIES(category_id),

    CONSTRAINT FK_BATCH_BRAND
        FOREIGN KEY (brand_id)
        REFERENCES BRANDS(brand_id)
);

-- =========================
-- PRODUCTS
-- =========================
CREATE TABLE PRODUCTS (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    price DECIMAL(18,2) NOT NULL,
    quantity INT,
    batch_id INT,
    description TEXT NULL,
    image_url VARCHAR(255) NULL,
    warranty_months INT,
    product_name VARCHAR(255) NOT NULL,

    CONSTRAINT FK_PRODUCTS_BATCH
        FOREIGN KEY (batch_id)
        REFERENCES Batch(batch_id)
);

-- =========================
-- PRODUCT_SPECIFICATIONS
-- =========================
CREATE TABLE PRODUCT_SPECIFICATIONS (
    spec_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    specification_name VARCHAR(255) NOT NULL,
    specification_value VARCHAR(255) NOT NULL,

    CONSTRAINT FK_PRODUCT_SPECIFICATIONS_PRODUCTS
        FOREIGN KEY (product_id)
        REFERENCES PRODUCTS(product_id)
);

-- =========================
-- COMPATIBILITY_RULES
-- =========================
CREATE TABLE COMPATIBILITY_RULES (
    rule_id INT AUTO_INCREMENT PRIMARY KEY,
    source_category_id INT,
    target_category_id INT,
    source_spec_name VARCHAR(255),
    target_spec_name VARCHAR(255),
    comparison_operator VARCHAR(50),

    CONSTRAINT FK_COMPATIBILITY_SOURCE_CATEGORY
        FOREIGN KEY (source_category_id)
        REFERENCES CATEGORIES(category_id),

    CONSTRAINT FK_COMPATIBILITY_TARGET_CATEGORY
        FOREIGN KEY (target_category_id)
        REFERENCES CATEGORIES(category_id)
);

-- =========================
-- CART
-- =========================
CREATE TABLE Cart (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL UNIQUE,

    CONSTRAINT FK_CART_CUSTOMERS
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMERS(customer_id)
);

-- =========================
-- CART_ITEMS
-- =========================
CREATE TABLE CART_ITEMS (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT,
    product_id INT,
    quantity INT NOT NULL,

    CONSTRAINT FK_CART_ITEMS_CART
        FOREIGN KEY (cart_id)
        REFERENCES Cart(cart_id),

    CONSTRAINT FK_CART_ITEMS_PRODUCTS
        FOREIGN KEY (product_id)
        REFERENCES PRODUCTS(product_id)
);

-- =========================
-- REVIEWS
-- =========================
CREATE TABLE REVIEWS (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    product_id INT NOT NULL,
    img VARCHAR(255),
    comment TEXT NULL,
    date DATETIME,

    CONSTRAINT FK_REVIEWS_CUSTOMERS
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMERS(customer_id),

    CONSTRAINT FK_REVIEWS_PRODUCTS
        FOREIGN KEY (product_id)
        REFERENCES PRODUCTS(product_id)
);

-- =========================
-- ORDERS_STATUS
-- =========================
CREATE TABLE ORDERS_STATUS (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) UNIQUE NOT NULL
);

-- =========================
-- ORDERS
-- =========================
CREATE TABLE ORDERS (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    status_id INT,
    order_date DATETIME,
    total_amount DECIMAL(18,2),
    shipping_address VARCHAR(255) NOT NULL,
    payment_method VARCHAR(100) NOT NULL,
    payment_status VARCHAR(50) DEFAULT 'UNPAID',
    note TEXT NULL,

    CONSTRAINT FK_ORDERS_CUSTOMERS
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMERS(customer_id),

    CONSTRAINT FK_ORDERS_STATUS
        FOREIGN KEY (status_id)
        REFERENCES ORDERS_STATUS(status_id)
);

-- =========================
-- ORDER_DETAILS
-- =========================
CREATE TABLE ORDER_DETAILS (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    subtotal DECIMAL(18,2) NOT NULL,

    CONSTRAINT FK_ORDER_DETAILS_ORDERS
        FOREIGN KEY (order_id)
        REFERENCES ORDERS(order_id),

    CONSTRAINT FK_ORDER_DETAILS_PRODUCTS
        FOREIGN KEY (product_id)
        REFERENCES PRODUCTS(product_id)
);

-- =========================
-- PAYMENTS
-- =========================
CREATE TABLE PAYMENTS (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE NOT NULL,
    payment_status VARCHAR(50),
    payment_provider VARCHAR(100) NULL,
    amount DECIMAL(18,2) NOT NULL,

    CONSTRAINT FK_PAYMENTS_ORDERS
        FOREIGN KEY (order_id)
        REFERENCES ORDERS(order_id)
);

-- =========================
-- SHIPMENTS
-- =========================
CREATE TABLE SHIPMENTS (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE NOT NULL,
    tracking_code VARCHAR(100) UNIQUE,
    shipment_status VARCHAR(50),
    note TEXT NULL,

    CONSTRAINT FK_SHIPMENTS_ORDERS
        FOREIGN KEY (order_id)
        REFERENCES ORDERS(order_id)
);

-- =========================
-- WARRANTY_STATUS
-- =========================
CREATE TABLE WARRANTY_STATUS (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) UNIQUE NOT NULL
);

-- =========================
-- WARRANTIES
-- =========================
CREATE TABLE WARRANTIES (
    warranty_id INT AUTO_INCREMENT PRIMARY KEY,
    order_detail_id INT NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    status_id INT,
    request_date DATETIME NOT NULL,
    request TEXT,

    CONSTRAINT FK_WARRANTIES_ORDER_DETAILS
        FOREIGN KEY (order_detail_id)
        REFERENCES ORDER_DETAILS(order_detail_id),

    CONSTRAINT FK_WARRANTIES_CUSTOMERS
        FOREIGN KEY (customer_id)
        REFERENCES CUSTOMERS(customer_id),

    CONSTRAINT FK_WARRANTIES_PRODUCTS
        FOREIGN KEY (product_id)
        REFERENCES PRODUCTS(product_id),

    CONSTRAINT FK_WARRANTIES_STATUS
        FOREIGN KEY (status_id)
        REFERENCES WARRANTY_STATUS(status_id)
);
