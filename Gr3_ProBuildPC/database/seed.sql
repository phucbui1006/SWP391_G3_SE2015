INSERT INTO Roles (role_id, role_name)
VALUES
(1, 'ADMIN'),
(2, 'EMPLOYEE'),
(3, 'SHIPMENT');

INSERT INTO categories (category_id, category_name)
VALUES
(1, 'CPU'),
(2, 'MAINBOARD'),
(3, 'RAM'),
(4, 'GPU'),
(5, 'SSD'),
(6, 'PSU'),
(7, 'CASE'),
(8, 'MONITOR'),
(9, 'KEYBOARD'),
(10, 'MOUSE');

INSERT INTO brands (brand_id, brand_name, img)
VALUES
(1, 'AMD', 'images/brands/amd.png'),
(2, 'ASUS', 'images/brands/asus.png'),
(3, 'Gigabyte', 'images/brands/gigabyte.png'),
(4, 'Intel', 'images/brands/intel.png'),
(5, 'Kingston', 'images/brands/kingston.png'),
(6, 'MSI', 'images/brands/msi.png');

INSERT INTO orders_status (status_id, status_name)
VALUES
(1, 'Chờ xác nhận'),
(2, 'Đã xác nhận'),
(3, 'Đang chuẩn bị hàng'),
(4, 'Đang giao hàng'),
(5, 'Đã giao hàng'),
(6, 'Đã hủy');

INSERT INTO warranty_status (status_id, status_name)
VALUES
(1, 'Chờ xác nhận'),
(2, 'Đã tiếp nhận'),
(3, 'Từ chối');

INSERT INTO users
(user_id, full_name, status, email, password, account_type)
VALUES
(1, 'Bui Phuc', 'ACTIVE', 'bui.phuc.admin@gmail.com', '123456', 'STAFF'),
(2, 'Nguyen Van Nam', 'ACTIVE', 'nguyenvannam@gmail.com', '123456', 'STAFF'),
(3, 'Tran Minh Quan', 'ACTIVE', 'tranminhquan@gmail.com', '123456', 'STAFF'),
(4, 'Le Hoang Anh', 'ACTIVE', 'lehoanganh@gmail.com', '123456', 'CUSTOMER'),
(5, 'Pham Thu Trang', 'ACTIVE', 'phamthutrang@gmail.com', '123456', 'CUSTOMER');

INSERT INTO customers
(customer_id, user_id)
VALUES
(1, 4),
(2, 5);

INSERT INTO staffs
(staff_id, user_id, role_id)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3);

INSERT INTO batch (batch_id, batch_name, brand_id, category_id)
VALUES
(1, 'AMD CPU Batch 2026', 1, 1),
(2, 'Intel CPU Batch 2026', 4, 1),
(3, 'ASUS Mainboard Batch 2026', 2, 2),
(4, 'Gigabyte Mainboard Batch 2026', 3, 2),
(5, 'Kingston RAM Batch 2026', 5, 3),
(6, 'MSI GPU Batch 2026', 6, 4);

INSERT INTO products
(product_id, product_name, price, quantity, batch_id, description, image_url, warranty_months)
VALUES

(1,
'AMD Ryzen 5 7600',
5500000,
20,
1,
'AMD Ryzen 5 7600 là bộ vi xử lý thuộc dòng Ryzen 7000 Series với 6 nhân 12 luồng, xung nhịp tối đa 5.1GHz. Hỗ trợ socket AM5, RAM DDR5 và PCIe 5.0, đáp ứng tốt nhu cầu chơi game, làm việc văn phòng và xử lý đa nhiệm.',
'images/products/amd-ryzen-5-7600.jpg',
36),

(2,
'AMD Ryzen 7 7700X',
8500000,
15,
1,
'AMD Ryzen 7 7700X sở hữu 8 nhân 16 luồng, kiến trúc Zen 4 hiện đại cùng hiệu năng mạnh mẽ cho gaming, livestream và sáng tạo nội dung. Hỗ trợ socket AM5 và bộ nhớ DDR5 thế hệ mới.',
'images/products/amd-ryzen-7-7700x.jpg',
36),

(3,
'Intel Core i5-12400F',
4200000,
25,
2,
'Intel Core i5-12400F là CPU thế hệ 12 với 6 nhân 12 luồng, mang lại hiệu năng ổn định cho học tập, làm việc và chơi game. Sử dụng socket LGA1700 và yêu cầu card đồ họa rời.',
'images/products/intel-core-i5-12400f.jpg',
36),

(4,
'ASUS PRIME B650M-A',
3800000,
10,
3,
'ASUS PRIME B650M-A là bo mạch chủ sử dụng chipset B650 hỗ trợ socket AM5, RAM DDR5 và nhiều công nghệ kết nối hiện đại, phù hợp cho các cấu hình AMD Ryzen mới.',
'images/products/asus-prime-b650m-a.jpg',
36),

(5,
'Kingston Fury Beast 16GB DDR5',
1500000,
30,
5,
'Kingston Fury Beast DDR5 16GB mang đến hiệu suất cao, độ ổn định tốt và khả năng tương thích với các nền tảng Intel và AMD thế hệ mới.',
'images/products/kingston-fury-beast-16gb-ddr5.jpg',
60),

(6,
'MSI GeForce RTX 4060 Ventus 2X',
9500000,
8,
6,
'MSI RTX 4060 Ventus 2X sử dụng kiến trúc NVIDIA Ada Lovelace, hỗ trợ Ray Tracing và DLSS 3, mang lại hiệu năng chơi game vượt trội ở độ phân giải Full HD và 2K.',
'images/products/msi-rtx-4060-ventus-2x.jpg',
36),
(7, 'AMD Ryzen 9 7900X', 11900000, 10, 1,
'AMD Ryzen 9 7900X là bộ vi xử lý cao cấp với 12 nhân 24 luồng, phù hợp cho gaming, stream và xử lý đồ họa chuyên nghiệp.',
'images/products/amd-ryzen-9-7900x.jpg', 36),

(8, 'Intel Core i7-13700K', 10500000, 12, 2,
'Intel Core i7-13700K thuộc thế hệ 13, cung cấp hiệu năng mạnh mẽ cho game thủ và người dùng chuyên nghiệp.',
'images/products/intel-core-i7-13700k.jpg', 36),

(9, 'Intel Core i9-13900K', 14900000, 8, 2,
'Intel Core i9-13900K là CPU flagship với hiệu năng hàng đầu cho các tác vụ nặng.',
'images/products/intel-core-i9-13900k.jpg', 36),

(10, 'ASUS ROG STRIX B650-A GAMING WIFI', 5900000, 8, 3,
'Bo mạch chủ cao cấp hỗ trợ AMD Ryzen AM5, DDR5 và WiFi tích hợp.',
'images/products/asus-rog-strix-b650a.jpg', 36),

(11, 'ASUS TUF GAMING B760M-PLUS WIFI', 4700000, 10, 3,
'Mainboard Intel B760 bền bỉ với khả năng hỗ trợ gaming ổn định.',
'images/products/asus-tuf-b760m.jpg', 36),

(12, 'Gigabyte B760M DS3H DDR4', 3200000, 15, 4,
'Mainboard Gigabyte hỗ trợ Intel thế hệ 12 và 13, phù hợp cấu hình tầm trung.',
'images/products/gigabyte-b760m-ds3h.jpg', 36),

(13, 'Gigabyte B650 Gaming X AX', 5200000, 10, 4,
'Bo mạch chủ AMD B650 hỗ trợ DDR5 và kết nối hiện đại.',
'images/products/gigabyte-b650-gamingx.jpg', 36),

(14, 'Kingston Fury Beast 32GB DDR5', 2800000, 20, 5,
'RAM Kingston DDR5 dung lượng 32GB cho hiệu suất đa nhiệm vượt trội.',
'images/products/kingston-fury-32gb.jpg', 60),

(15, 'Kingston Fury Beast 64GB DDR5', 5900000, 10, 5,
'RAM Kingston DDR5 64GB dành cho workstation và xử lý chuyên sâu.',
'images/products/kingston-fury-64gb.jpg', 60),

(16, 'MSI RTX 4070 Ventus 3X', 16500000, 6, 6,
'Card đồ họa RTX 4070 hỗ trợ DLSS 3 và Ray Tracing thế hệ mới.',
'images/products/msi-rtx4070.jpg', 36),

(17, 'MSI RTX 4070 Ti Gaming X Trio', 21900000, 4, 6,
'RTX 4070 Ti mang lại hiệu năng mạnh mẽ cho gaming 2K và 4K.',
'images/products/msi-rtx4070ti.jpg', 36),

(18, 'MSI RTX 4080 Super Gaming X Trio', 32900000, 3, 6,
'Card đồ họa cao cấp RTX 4080 Super dành cho game thủ và nhà sáng tạo nội dung.',
'images/products/msi-rtx4080super.jpg', 36)
;

INSERT INTO product_specifications
(product_id, specification_name, specification_value)
VALUES
(1, 'Socket', 'AM5'),
(1, 'RAM Support', 'DDR5'),

(2, 'Socket', 'AM5'),
(2, 'RAM Support', 'DDR5'),

(3, 'Socket', 'LGA1700'),
(3, 'RAM Support', 'DDR4'),

(4, 'Socket', 'AM5'),
(4, 'RAM Type', 'DDR5'),

(5, 'RAM Type', 'DDR5'),

(6, 'Interface', 'PCIe 4.0');

INSERT INTO address
(address_id, customer_id, recipient_name, phoneNumber, Address_detail)
VALUES
(1, 1, 'Le Van C', '0901234567',
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội'),

(2, 2, 'Pham Thu Trang', '0123456789',
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội'),

(3, 2, 'Cong ty TNHH ABC', '0987654321',
'Khu CNC Hòa Lạc, Thạch Thất, Hà Nội'),

(4, 2, 'Nha cua bo me', '0912345678',
'Khu CNC Hòa Lạc, Thạch Thất, Hà Nội');

INSERT INTO cart (cart_id, customer_id)
VALUES
(1, 1),
(2, 2);

INSERT INTO cart_items (cart_id, product_id, quantity)
VALUES
(1, 1, 1),  -- Ryzen 5 7600
(1, 5, 2),  -- Kingston DDR5

(2, 3, 1),  -- Intel i5-12400F
(2, 6, 1);  -- MSI RTX 4060

INSERT INTO orders
(order_id, customer_id, status_id, order_date, total_amount, shipping_address, payment_method, payment_status, note)
VALUES

(10000, 1, 5, NOW(), 8500000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD',
'Chưa thanh toán',
'Khách thanh toán khi nhận hàng'),

(10001, 2, 4, NOW(), 13700000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'VNPAY',
'Đã thanh toán',
'Thanh toán trực tuyến qua VNPAY');

INSERT INTO orders
(order_id, customer_id, status_id, order_date, total_amount, shipping_address, payment_method, payment_status, note)
VALUES
(10002, 1, 5, '2023-02-18 09:15:00', 8500000,
'Khu CNC Hòa Lạc, Thạch Thất, Hà Nội',
'COD',
'Đã thanh toán',
'Đơn test năm 2023 - CPU và RAM'),

(10003, 2, 5, '2023-06-07 15:40:00', 8900000,
'Đại học FPT Hà Nội, Khu CNC Hòa Lạc, Hà Nội',
'VNPAY',
'Đã thanh toán',
'Đơn test năm 2023 - combo Intel'),

(10004, 1, 6, '2023-11-25 20:05:00', 9500000,
'Khu CNC Hòa Lạc, Thạch Thất, Hà Nội',
'COD',
'Đã thanh toán',
'Đơn test đã hủy năm 2023'),

(10005, 2, 5, '2024-01-12 10:30:00', 13300000,
'Đại học FPT Hà Nội, Khu CNC Hòa Lạc, Hà Nội',
'VNPAY',
'Đã thanh toán',
'Đơn test năm 2024 - CPU và RAM'),

(10006, 1, 5, '2024-04-30 13:25:00', 15300000,
'Khu CNC Hòa Lạc, Thạch Thất, Hà Nội',
'COD',
'Đã thanh toán',
'Đơn test năm 2024 - bộ máy AMD'),

(10007, 2, 4, '2024-09-14 17:50:00', 22400000,
'Đại học FPT Hà Nội, Khu CNC Hòa Lạc, Hà Nội',
'VNPAY',
'Đã thanh toán',
'Đơn test đang giao năm 2024'),

(10008, 1, 5, '2025-03-03 08:10:00', 19900000,
'Khu CNC Hòa Lạc, Thạch Thất, Hà Nội',
'COD',
'Đã thanh toán',
'Đơn test năm 2025 - combo Ryzen 9'),

(10009, 2, 2, '2025-07-21 19:35:00', 20800000,
'Đại học FPT Hà Nội, Khu CNC Hòa Lạc, Hà Nội',
'VNPAY',
'Đã thanh toán',
'Đơn test đã xác nhận năm 2025'),

(10010, 1, 5, '2025-12-05 11:45:00', 29600000,
'Khu CNC Hòa Lạc, Thạch Thất, Hà Nội',
'VNPAY',
'Đã thanh toán',
'Đơn test năm 2025 - bộ máy GPU'),

(10011, 2, 1, '2026-02-16 14:20:00', 38800000,
'Đại học FPT Hà Nội, Khu CNC Hòa Lạc, Hà Nội',
'VNPAY',
'Chờ thanh toán',
'Đơn test chờ xác nhận năm 2026'),

(10012, 1, 3, '2026-05-09 16:05:00', 19300000,
'Khu CNC Hòa Lạc, Thạch Thất, Hà Nội',
'COD',
'Chưa thanh toán',
'Đơn test đang chuẩn bị năm 2026'),

(10013, 2, 4, '2026-06-10 09:55:00', 14800000,
'Đại học FPT Hà Nội, Khu CNC Hòa Lạc, Hà Nội',
'COD',
'Chưa thanh toán',
'Đơn test đang giao năm 2026');

INSERT INTO order_details
(order_id, product_id, quantity, unit_price, subtotal)
VALUES
-- Order 1
(10000, 1, 1, 5500000, 5500000),
(10000, 5, 2, 1500000, 3000000),

-- Order 2
(10001, 3, 1, 4200000, 4200000),
(10001, 6, 1, 9500000, 9500000);

INSERT INTO order_details
(order_id, product_id, quantity, unit_price, subtotal)
VALUES
-- Order 3
(10002, 1, 1, 5500000, 5500000),
(10002, 5, 2, 1500000, 3000000),

-- Order 4
(10003, 3, 1, 4200000, 4200000),
(10003, 12, 1, 3200000, 3200000),
(10003, 5, 1, 1500000, 1500000),

-- Order 5
(10004, 6, 1, 9500000, 9500000),

-- Order 6
(10005, 8, 1, 10500000, 10500000),
(10005, 14, 1, 2800000, 2800000),

-- Order 7
(10006, 2, 1, 8500000, 8500000),
(10006, 4, 1, 3800000, 3800000),
(10006, 5, 2, 1500000, 3000000),

-- Order 8
(10007, 16, 1, 16500000, 16500000),
(10007, 10, 1, 5900000, 5900000),

-- Order 9
(10008, 7, 1, 11900000, 11900000),
(10008, 13, 1, 5200000, 5200000),
(10008, 14, 1, 2800000, 2800000),

-- Order 10
(10009, 9, 1, 14900000, 14900000),
(10009, 15, 1, 5900000, 5900000),

-- Order 11
(10010, 17, 1, 21900000, 21900000),
(10010, 11, 1, 4700000, 4700000),
(10010, 5, 2, 1500000, 3000000),

-- Order 12
(10011, 18, 1, 32900000, 32900000),
(10011, 15, 1, 5900000, 5900000),

-- Order 13
(10012, 8, 1, 10500000, 10500000),
(10012, 12, 1, 3200000, 3200000),
(10012, 14, 2, 2800000, 5600000),

-- Order 14
(10013, 6, 1, 9500000, 9500000),
(10013, 4, 1, 3800000, 3800000),
(10013, 5, 1, 1500000, 1500000);

INSERT INTO reviews
(review_id, customer_id, product_id, rating, img, comment, date)
VALUES

(1, 1, 1, 5,
'images/reviews/ryzen7600-review.jpg',
'CPU hoạt động ổn định, nhiệt độ mát, hiệu năng chơi game rất tốt. Hoàn toàn hài lòng với mức giá.',
NOW()),

(2, 1, 5, 4,
'images/reviews/kingston-ddr5-review.jpg',
'RAM chạy ổn định, hỗ trợ XMP tốt. Đóng gói cẩn thận và giao hàng nhanh.',
NOW()),

(3, 2, 3, 5,
'images/reviews/i512400f-review.jpg',
'Hiệu năng rất tốt trong tầm giá, phù hợp cho cả học tập và chơi game. Rất đáng mua.',
NOW()),

(4, 2, 6, 5,
'images/reviews/msi4060-review.jpg',
'Card đồ họa hoạt động mượt mà, chơi game FPS cao và hỗ trợ DLSS rất hiệu quả.',
NOW());
