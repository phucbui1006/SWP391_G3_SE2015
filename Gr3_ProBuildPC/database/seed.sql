INSERT INTO Roles (role_id, role_name)
VALUES
(1, 'CUSTOMER'),
(2, 'EMPLOYEE'),
(3, 'ADMIN'),
(4, 'SHIPMENT');

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
(user_id, role_id, full_name, status, email, password)
VALUES
(1, 3, 'Bui Phuc', 1, 'bui.phuc.admin@gmail.com', '123456'),
(2, 2, 'Nguyen Van Nam', 1, 'nguyenvannam@gmail.com', '123456'),
(3, 4, 'Tran Minh Quan', 1, 'tranminhquan@gmail.com', '123456'),
(4, 1, 'Le Hoang Anh', 1, 'lehoanganh@gmail.com', '123456'),
(5, 1, 'Pham Thu Trang', 1, 'phamthutrang@gmail.com', '123456');

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
36);

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
(address_id, user_id, recipient_name, phoneNumber, Address_detail)
VALUES
(1, 4, 'Le Van C', '0901234567',
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội'),

(2, 5, 'Pham Thi D', '0912345678',
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội');

INSERT INTO cart (cart_id, user_id)
VALUES
(1, 4),
(2, 5);

INSERT INTO cart_items (cart_id, product_id, quantity)
VALUES
(1, 1, 1),  -- Ryzen 5 7600
(1, 5, 2),  -- Kingston DDR5

(2, 3, 1),  -- Intel i5-12400F
(2, 6, 1);  -- MSI RTX 4060

INSERT INTO orders
(order_id, user_id, status_id, order_date, total_amount, shipping_address, payment_method, payment_status, note)
VALUES

(1, 4, 5, NOW(), 8500000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD',
'Chưa thanh toán',
'Khách thanh toán khi nhận hàng'),

(2, 5, 4, NOW(), 13700000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'VNPAY',
'Đã thanh toán',
'Thanh toán trực tuyến qua VNPAY');

INSERT INTO order_details
(order_id, product_id, quantity, unit_price, subtotal)
VALUES
-- Order 1
(1, 1, 1, 5500000, 5500000),
(1, 5, 2, 1500000, 3000000),

-- Order 2
(2, 3, 1, 4200000, 4200000),
(2, 6, 1, 9500000, 9500000);

INSERT INTO reviews
(review_id, user_id, product_id, rating, img, comment, date)
VALUES

(1, 4, 1, 5,
'images/reviews/ryzen7600-review.jpg',
'CPU hoạt động ổn định, nhiệt độ mát, hiệu năng chơi game rất tốt. Hoàn toàn hài lòng với mức giá.',
NOW()),

(2, 4, 5, 4,
'images/reviews/kingston-ddr5-review.jpg',
'RAM chạy ổn định, hỗ trợ XMP tốt. Đóng gói cẩn thận và giao hàng nhanh.',
NOW()),

(3, 5, 3, 5,
'images/reviews/i512400f-review.jpg',
'Hiệu năng rất tốt trong tầm giá, phù hợp cho cả học tập và chơi game. Rất đáng mua.',
NOW()),

(4, 5, 6, 5,
'images/reviews/msi4060-review.jpg',
'Card đồ họa hoạt động mượt mà, chơi game FPS cao và hỗ trợ DLSS rất hiệu quả.',
NOW());
