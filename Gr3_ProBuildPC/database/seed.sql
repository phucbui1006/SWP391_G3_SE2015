SET NAMES utf8mb4;

-- =========================
-- DỮ LIỆU DANH MỤC
-- =========================
INSERT INTO ROLES (role_id, role_name)
VALUES
(1, 'ADMIN'),
(2, 'EMPLOYEE'),
(3, 'SHIPMENT');

INSERT INTO CATEGORIES (category_id, category_name, status)
VALUES
(1, 'Bộ vi xử lý', 'ACTIVE'),
(2, 'Bo mạch chủ', 'ACTIVE'),
(3, 'Bộ nhớ RAM', 'ACTIVE'),
(4, 'Card đồ họa', 'ACTIVE'),
(5, 'Ổ cứng SSD', 'ACTIVE'),
(6, 'Nguồn máy tính', 'ACTIVE'),
(7, 'Vỏ máy tính', 'ACTIVE'),
(8, 'Màn hình', 'ACTIVE'),
(9, 'Bàn phím', 'ACTIVE'),
(10, 'Chuột', 'ACTIVE');

INSERT INTO CATEGORY_SPEC_TEMPLATES
(template_id, category_id, spec_name, spec_type, allowed_values, is_required, display_order)
VALUES
(1,  1, 'Chân cắm',    'SELECT', 'AM5,LGA1700,LGA1200,AM4',  TRUE, 1),
(2,  1, 'Hỗ trợ RAM',  'SELECT', 'DDR4,DDR5',                TRUE, 2),
(3,  1, 'Số nhân',      'NUMBER', NULL,                       TRUE, 3),
(4,  1, 'Số luồng',     'NUMBER', NULL,                       TRUE, 4),
(5,  2, 'Chân cắm',           'SELECT', 'AM5,LGA1700,LGA1200,AM4',        TRUE, 1),
(6,  2, 'Loại RAM',            'SELECT', 'DDR4,DDR5',                      TRUE, 2),
(7,  2, 'Kích thước bo mạch',  'SELECT', 'ATX,Micro-ATX,Mini-ITX,E-ATX',   TRUE, 3),
(8,  2, 'Giao tiếp GPU',       'SELECT', 'PCIe 4.0,PCIe 5.0,PCIe 3.0',    TRUE, 4),
(9,  3, 'Loại RAM',   'SELECT', 'DDR4,DDR5',                                    TRUE, 1),
(10, 3, 'Dung lượng', 'SELECT', '8GB,16GB,32GB,64GB',                           TRUE, 2),
(11, 3, 'Tốc độ',     'SELECT', '3200MHz,3600MHz,4800MHz,5200MHz,5600MHz,6000MHz', TRUE, 3),
(12, 4, 'Giao tiếp',        'SELECT', 'PCIe 3.0,PCIe 4.0,PCIe 5.0',  TRUE, 1),
(13, 4, 'Bộ nhớ đồ họa',    'SELECT', '4GB,6GB,8GB,12GB,16GB,24GB',   TRUE, 2),
(14, 5, 'Loại kết nối', 'SELECT', 'SATA III,NVMe M.2 PCIe 3.0,NVMe M.2 PCIe 4.0,NVMe M.2 PCIe 5.0', TRUE, 1),
(15, 5, 'Dung lượng',   'SELECT', '256GB,512GB,1TB,2TB,4TB',                                          TRUE, 2),
(16, 5, 'Tốc độ đọc',   'TEXT',   NULL,                                                               FALSE, 3),
(17, 5, 'Tốc độ ghi',   'TEXT',   NULL,                                                               FALSE, 4),
(18, 6, 'Công suất',    'SELECT', '450W,550W,650W,750W,850W,1000W,1200W',              TRUE, 1),
(19, 6, 'Chuẩn hiệu suất', 'SELECT', '80 Plus,80 Plus Bronze,80 Plus Silver,80 Plus Gold,80 Plus Platinum', TRUE, 2),
(20, 6, 'Loại dây cáp',  'SELECT', 'Non-Modular,Semi-Modular,Full-Modular',            TRUE, 3),
(21, 7, 'Kích thước hỗ trợ', 'SELECT', 'ATX,Micro-ATX,Mini-ITX,E-ATX',                TRUE, 1),
(22, 7, 'Chất liệu',         'SELECT', 'Thép,Nhôm,Kính cường lực,Nhựa',               FALSE, 2),
(23, 7, 'Số quạt đi kèm',    'NUMBER',  NULL,                                          FALSE, 3),
(24, 8, 'Kích thước',     'SELECT', '21.5 inch,24 inch,27 inch,32 inch,34 inch',       TRUE, 1),
(25, 8, 'Độ phân giải',   'SELECT', 'Full HD,2K QHD,4K UHD',                           TRUE, 2),
(26, 8, 'Tấm nền',        'SELECT', 'IPS,VA,TN,OLED',                                 TRUE, 3),
(27, 8, 'Tần số quét',    'SELECT', '60Hz,75Hz,144Hz,165Hz,240Hz,360Hz',               TRUE, 4),
(28, 8, 'Cổng kết nối',   'TEXT',    NULL,                                              FALSE, 5),
(29, 9, 'Loại switch',   'SELECT', 'Membrane,Mechanical Red,Mechanical Blue,Mechanical Brown,Optical', FALSE, 1),
(30, 9, 'Kết nối',       'SELECT', 'USB,Wireless 2.4G,Bluetooth,USB + Bluetooth',                     TRUE, 2),
(31, 9, 'Layout',        'SELECT', 'Full-size,TKL,75%,65%,60%',                                       TRUE, 3),
(32, 10, 'Kết nối',  'SELECT', 'USB,Wireless 2.4G,Bluetooth,USB + Bluetooth',  TRUE, 1),
(33, 10, 'DPI tối đa', 'NUMBER', NULL,                                         FALSE, 2),
(34, 10, 'Trọng lượng', 'TEXT',  NULL,                                         FALSE, 3);

INSERT INTO BRANDS (brand_id, brand_name, img, status)
VALUES
(1, 'AMD', 'images/brands/amd.png', 'ACTIVE'),
(2, 'ASUS', 'images/brands/asus.png', 'ACTIVE'),
(3, 'Gigabyte', 'images/brands/gigabyte.png', 'ACTIVE'),
(4, 'Intel', 'images/brands/intel.png', 'ACTIVE'),
(5, 'Kingston', 'images/brands/kingston.png', 'ACTIVE'),
(6, 'MSI', 'images/brands/msi.png', 'ACTIVE'),
(7, 'Corsair', 'images/brands/corsair.png', 'ACTIVE'),
(8, 'Samsung', 'images/brands/samsung.png', 'ACTIVE'),
(9, 'Dell', 'images/brands/dell.png', 'ACTIVE'),
(10, 'Logitech', 'images/brands/logitech.png', 'ACTIVE'),
(11, 'Razer', 'images/brands/razer.png', 'ACTIVE'),
(12, 'NZXT', 'images/brands/nzxt.png', 'ACTIVE');

INSERT INTO ORDERS_STATUS (status_id, status_name)
VALUES
(1, 'Chờ xác nhận'),
(2, 'Đã xác nhận'),
(3, 'Đang chuẩn bị hàng'),
(4, 'Đang giao hàng'),
(5, 'Đã giao hàng'),
(6, 'Đã hủy'),
(7, 'Giao hàng thất bại');

INSERT INTO WARRANTY_STATUS (status_id, status_name)
VALUES
(1, 'Chờ tiếp nhận'),
(2, 'Đã tiếp nhận'),
(3, 'Từ chối'),
(4, 'Hoàn tất');

-- =========================
-- NGƯỜI DÙNG
-- =========================
INSERT INTO USERS
(user_id, full_name, status, email, password, account_type)
VALUES
(1, 'Bùi Phúc', 'ACTIVE', 'nguyenngoccham120705@gmail.com', '10000:ADiFKmTgiJQB3hGjYWMkzg==:NDFF0ZdDpzVNqTquOBe+qsL0TyMPekXLzin0kJuOt9M=', 'STAFF'),
(2, 'Nguyễn Văn Nam', 'ACTIVE', 'nguyenvannam@gmail.com', '10000:tVcPKMs6RKo5wpJVQSZiPg==:6QK0yCsLw0hdgwHBn4kNrbUb6lk9J10GjfwFAzVNpx0=', 'STAFF'),
(3, 'Trần Minh Quân', 'ACTIVE', 'tranminhquan@gmail.com', '10000:cCoBKOOvKdQd9149/OvPOA==:l+I8TAaTyGQB42so2sh3BNqt0HjC/Q5pjH32yCa6sag=', 'STAFF'),
(4, 'Lê Hoàng Anh', 'ACTIVE', 'lehoanganh@gmail.com', '10000:oOwR9cRBPIYGzREAAHrQWA==:YUujHK8Rsdb0SM/0uXqH+/BN0aQBAUib8ui5nEBxpqY=', 'CUSTOMER'),
(5, 'Phạm Thu Trang', 'ACTIVE', 'phamthutrang@gmail.com', '10000:0Vi4JR9Wkh4FykRLuHGylw==:TOL2YJLA7c1XICTniSDbsBmMBQtKDdrtYDWbbx7qWGo=', 'CUSTOMER');

INSERT INTO CUSTOMERS (customer_id, user_id)
VALUES
(1, 4),
(2, 5);

INSERT INTO STAFFS (staff_id, user_id, role_id)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3);

INSERT INTO ADDRESS
(address_id, customer_id, recipient_name, phone_number, address_detail)
VALUES
(1, 1, 'Lê Hoàng Anh', '0901234567', 'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội'),
(2, 2, 'Phạm Thu Trang', '0123456789', 'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội'),
(3, 2, 'Công ty TNHH ABC', '0987654321', 'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội'),
(4, 1, 'Nhà riêng Lê Hoàng Anh', '0912345678', 'Cầu Giấy, Hà Nội');

-- =========================
-- SẢN PHẨM
-- warranty_months lưu ở BATCH_ITEMS
-- =========================
INSERT INTO PRODUCTS
(product_id, category_id, brand_id, product_name, description, image_url, price, status)
VALUES
(1, 1, 1, 'AMD Ryzen 5 7600',
'AMD Ryzen 5 7600 có 6 nhân 12 luồng, hỗ trợ socket AM5, RAM DDR5 và mang lại hiệu năng chơi game tốt trong tầm giá.',
'images/products/amd-ryzen-5-7600.jpg', 5500000, 'ACTIVE'),

(2, 1, 1, 'AMD Ryzen 7 7700X',
'AMD Ryzen 7 7700X có 8 nhân 16 luồng, phù hợp cho chơi game, livestream và sáng tạo nội dung trên nền tảng AM5.',
'images/products/amd-ryzen-7-7700x.jpg', 8500000, 'ACTIVE'),

(3, 1, 4, 'Intel Core i5-12400F',
'Intel Core i5-12400F có 6 nhân 12 luồng, sử dụng socket LGA1700 và phù hợp cho học tập, làm việc văn phòng, chơi game.',
'images/products/intel-core-i5-12400f.jpg', 4200000, 'ACTIVE'),

(4, 2, 2, 'ASUS PRIME B650M-A',
'ASUS PRIME B650M-A là bo mạch chủ AM5 hỗ trợ RAM DDR5, hoạt động ổn định cho các bộ máy dùng Ryzen 7000.',
'images/products/asus-prime-b650m-a.jpg', 3800000, 'ACTIVE'),

(5, 3, 5, 'Kingston Fury Beast 16GB DDR5',
'Kingston Fury Beast 16GB DDR5 mang lại hiệu năng ổn định cho các nền tảng AMD và Intel đời mới.',
'images/products/kingston-fury-beast-16gb-ddr5.jpg', 1500000, 'ACTIVE'),

(6, 4, 6, 'MSI GeForce RTX 4060 Ventus 2X',
'MSI GeForce RTX 4060 Ventus 2X hỗ trợ Ray Tracing, DLSS 3 và chơi game Full HD mượt mà.',
'images/products/msi-rtx-4060-ventus-2x.jpg', 9500000, 'ACTIVE'),

(7, 1, 1, 'AMD Ryzen 9 7900X',
'AMD Ryzen 9 7900X có 12 nhân 24 luồng, phù hợp cho chơi game cao cấp, livestream và xử lý công việc chuyên nghiệp.',
'images/products/amd-ryzen-9-7900x.jpg', 11900000, 'ACTIVE'),

(8, 1, 4, 'Intel Core i7-13700K',
'Intel Core i7-13700K mang lại hiệu năng mạnh cho chơi game và các tác vụ làm việc nặng trên nền tảng LGA1700.',
'images/products/intel-core-i7-13700k.jpg', 10500000, 'ACTIVE'),

(9, 1, 4, 'Intel Core i9-13900K',
'Intel Core i9-13900K là bộ vi xử lý cao cấp dành cho đa nhiệm nặng, dựng hình và chơi game tần số quét cao.',
'images/products/intel-core-i9-13900k.jpg', 14900000, 'ACTIVE'),

(10, 2, 2, 'ASUS ROG STRIX B650-A GAMING WIFI',
'ASUS ROG STRIX B650-A GAMING WIFI hỗ trợ AMD AM5, RAM DDR5, card đồ họa PCIe 4.0 và kết nối WiFi.',
'images/products/asus-rog-strix-b650a.jpg', 5900000, 'ACTIVE'),

(11, 2, 2, 'ASUS TUF GAMING B760M-PLUS WIFI',
'ASUS TUF GAMING B760M-PLUS WIFI hỗ trợ CPU Intel LGA1700, RAM DDR5 và các cấu hình chơi game ổn định.',
'images/products/asus-tuf-b760m.jpg', 4700000, 'ACTIVE'),

(12, 2, 3, 'Gigabyte B760M DS3H DDR5',
'Gigabyte B760M DS3H DDR5 hỗ trợ CPU Intel thế hệ 12 và 13 cùng bộ nhớ DDR5.',
'images/products/gigabyte-b760m-ds3h.jpg', 3200000, 'ACTIVE'),

(13, 2, 3, 'Gigabyte B650 Gaming X AX',
'Gigabyte B650 Gaming X AX hỗ trợ CPU AMD AM5, RAM DDR5 và nhiều tính năng mở rộng hiện đại.',
'images/products/gigabyte-b650-gamingx.jpg', 5200000, 'ACTIVE'),

(14, 3, 5, 'Kingston Fury Beast 32GB DDR5',
'Kingston Fury Beast 32GB DDR5 phù hợp cho chơi game, đa nhiệm và công việc sáng tạo nội dung.',
'images/products/kingston-fury-32gb.jpg', 2800000, 'ACTIVE'),

(15, 3, 5, 'Kingston Fury Beast 64GB DDR5',
'Kingston Fury Beast 64GB DDR5 dành cho máy trạm, dựng phim, chỉnh ảnh và đa nhiệm nặng.',
'images/products/kingston-fury-64gb.jpg', 5900000, 'ACTIVE'),

(16, 4, 6, 'MSI RTX 4070 Ventus 3X',
'MSI RTX 4070 Ventus 3X hỗ trợ DLSS 3 và Ray Tracing, phù hợp cho chơi game 2K hiệu năng cao.',
'images/products/msi-rtx4070.jpg', 16500000, 'ACTIVE'),

(17, 4, 6, 'MSI RTX 4070 Ti Gaming X Trio',
'MSI RTX 4070 Ti Gaming X Trio mang lại hiệu năng mạnh cho chơi game 2K và 4K.',
'images/products/msi-rtx4070ti.jpg', 21900000, 'ACTIVE'),

(18, 4, 6, 'MSI RTX 4080 Super Gaming X Trio',
'MSI RTX 4080 Super Gaming X Trio là card đồ họa cao cấp dành cho chơi game 4K và sáng tạo nội dung.',
'images/products/msi-rtx4080super.jpg', 32900000, 'ACTIVE'),

(19, 5, 8, 'Samsung 980 Pro 1TB',
'Ổ cứng SSD Samsung 980 Pro 1TB PCIe 4.0 NVMe siêu tốc, lý tưởng cho hệ thống gaming và render.',
'images/products/samsung-980-pro-1tb.jpg', 2300000, 'ACTIVE'),

(20, 5, 5, 'Kingston NV2 500GB',
'Ổ cứng SSD Kingston NV2 500GB PCIe 4.0, giải pháp lưu trữ tiết kiệm và hiệu quả.',
'images/products/kingston-nv2-500gb.jpg', 950000, 'ACTIVE'),

(21, 6, 7, 'Corsair RM850x 850W',
'Nguồn máy tính Corsair RM850x 850W 80 Plus Gold Full Modular, hiệu năng cao và yên tĩnh.',
'images/products/corsair-rm850x.jpg', 3500000, 'ACTIVE'),

(22, 6, 3, 'Gigabyte P650B 650W',
'Nguồn máy tính Gigabyte P650B 650W 80 Plus Bronze, phù hợp cho cấu hình tầm trung.',
'images/products/gigabyte-p650b.jpg', 1200000, 'ACTIVE'),

(23, 7, 7, 'Corsair 4000D Airflow',
'Vỏ case Corsair 4000D Airflow Tempered Glass, tối ưu luồng gió làm mát hệ thống.',
'images/products/corsair-4000d.jpg', 1900000, 'ACTIVE'),

(24, 7, 12, 'NZXT H510',
'Vỏ case NZXT H510 Mid Tower thiết kế tối giản, tinh tế, tích hợp sẵn quản lý cáp.',
'images/products/nzxt-h510.jpg', 1800000, 'ACTIVE'),

(25, 8, 9, 'Dell UltraSharp U2720Q',
'Màn hình Dell UltraSharp U2720Q 27 inch 4K IPS, màu sắc chuẩn xác cho thiết kế đồ họa.',
'images/products/dell-u2720q.jpg', 12500000, 'ACTIVE'),

(26, 8, 2, 'ASUS TUF Gaming VG27AQ',
'Màn hình ASUS TUF Gaming VG27AQ 27 inch 2K 165Hz IPS, mượt mà cho trải nghiệm gaming.',
'images/products/asus-tuf-vg27aq.jpg', 7500000, 'ACTIVE'),

(27, 9, 10, 'Logitech G Pro X Keyboard',
'Bàn phím cơ Logitech G Pro X chuyên game, switch thay thế được.',
'images/products/logitech-g-pro-x-kb.jpg', 3200000, 'ACTIVE'),

(28, 10, 10, 'Logitech G502 Hero',
'Chuột gaming Logitech G502 Hero cảm biến 25K cao cấp, thiết kế công thái học.',
'images/products/logitech-g502-hero.jpg', 1100000, 'ACTIVE'),

(29, 10, 11, 'Razer DeathAdder V3 Pro',
'Chuột không dây siêu nhẹ Razer DeathAdder V3 Pro, thiết kế ergonomic hàng đầu.',
'images/products/razer-dav3-pro.jpg', 3500000, 'ACTIVE');

-- =========================
-- THÔNG SỐ SẢN PHẨM
-- =========================
INSERT INTO PRODUCT_SPECIFICATIONS
(product_id, specification_name, specification_value)
VALUES
(1, 'Chân cắm', 'AM5'),
(1, 'Hỗ trợ RAM', 'DDR5'),
(1, 'Số nhân', '6'),
(1, 'Số luồng', '12'),

(2, 'Chân cắm', 'AM5'),
(2, 'Hỗ trợ RAM', 'DDR5'),
(2, 'Số nhân', '8'),
(2, 'Số luồng', '16'),

(3, 'Chân cắm', 'LGA1700'),
(3, 'Hỗ trợ RAM', 'DDR5'),
(3, 'Số nhân', '6'),
(3, 'Số luồng', '12'),

(4, 'Chân cắm', 'AM5'),
(4, 'Loại RAM', 'DDR5'),
(4, 'Kích thước bo mạch', 'Micro-ATX'),
(4, 'Giao tiếp GPU', 'PCIe 4.0'),

(5, 'Loại RAM', 'DDR5'),
(5, 'Dung lượng', '16GB'),
(5, 'Tốc độ', '5200MHz'),

(6, 'Giao tiếp', 'PCIe 4.0'),
(6, 'Bộ nhớ đồ họa', '8GB'),

(7, 'Chân cắm', 'AM5'),
(7, 'Hỗ trợ RAM', 'DDR5'),
(7, 'Số nhân', '12'),
(7, 'Số luồng', '24'),

(8, 'Chân cắm', 'LGA1700'),
(8, 'Hỗ trợ RAM', 'DDR5'),
(8, 'Số nhân', '16'),
(8, 'Số luồng', '24'),

(9, 'Chân cắm', 'LGA1700'),
(9, 'Hỗ trợ RAM', 'DDR5'),
(9, 'Số nhân', '24'),
(9, 'Số luồng', '32'),

(10, 'Chân cắm', 'AM5'),
(10, 'Loại RAM', 'DDR5'),
(10, 'Kích thước bo mạch', 'ATX'),
(10, 'Giao tiếp GPU', 'PCIe 4.0'),

(11, 'Chân cắm', 'LGA1700'),
(11, 'Loại RAM', 'DDR5'),
(11, 'Kích thước bo mạch', 'Micro-ATX'),
(11, 'Giao tiếp GPU', 'PCIe 4.0'),

(12, 'Chân cắm', 'LGA1700'),
(12, 'Loại RAM', 'DDR5'),
(12, 'Kích thước bo mạch', 'Micro-ATX'),
(12, 'Giao tiếp GPU', 'PCIe 4.0'),

(13, 'Chân cắm', 'AM5'),
(13, 'Loại RAM', 'DDR5'),
(13, 'Kích thước bo mạch', 'ATX'),
(13, 'Giao tiếp GPU', 'PCIe 4.0'),

(14, 'Loại RAM', 'DDR5'),
(14, 'Dung lượng', '32GB'),
(14, 'Tốc độ', '5600MHz'),

(15, 'Loại RAM', 'DDR5'),
(15, 'Dung lượng', '64GB'),
(15, 'Tốc độ', '5600MHz'),

(16, 'Giao tiếp', 'PCIe 4.0'),
(16, 'Bộ nhớ đồ họa', '12GB'),

(17, 'Giao tiếp', 'PCIe 4.0'),
(17, 'Bộ nhớ đồ họa', '12GB'),

(18, 'Giao tiếp', 'PCIe 4.0'),
(18, 'Bộ nhớ đồ họa', '16GB'),

(19, 'Loại kết nối', 'NVMe M.2 PCIe 4.0'),
(19, 'Dung lượng', '1TB'),
(19, 'Tốc độ đọc', '7000 MB/s'),
(19, 'Tốc độ ghi', '5000 MB/s'),

(20, 'Loại kết nối', 'NVMe M.2 PCIe 4.0'),
(20, 'Dung lượng', '500GB'),
(20, 'Tốc độ đọc', '3500 MB/s'),
(20, 'Tốc độ ghi', '2100 MB/s'),

(21, 'Công suất', '850W'),
(21, 'Chuẩn hiệu suất', '80 Plus Gold'),
(21, 'Loại dây cáp', 'Full-Modular'),

(22, 'Công suất', '650W'),
(22, 'Chuẩn hiệu suất', '80 Plus Bronze'),
(22, 'Loại dây cáp', 'Non-Modular'),

(23, 'Kích thước hỗ trợ', 'ATX'),
(23, 'Chất liệu', 'Thép, Kính cường lực'),
(23, 'Số quạt đi kèm', '2'),

(24, 'Kích thước hỗ trợ', 'ATX'),
(24, 'Chất liệu', 'Thép, Kính cường lực'),
(24, 'Số quạt đi kèm', '2'),

(25, 'Kích thước', '27 inch'),
(25, 'Độ phân giải', '4K UHD'),
(25, 'Tấm nền', 'IPS'),
(25, 'Tần số quét', '60Hz'),
(25, 'Cổng kết nối', 'HDMI, DisplayPort, USB-C'),

(26, 'Kích thước', '27 inch'),
(26, 'Độ phân giải', '2K QHD'),
(26, 'Tấm nền', 'IPS'),
(26, 'Tần số quét', '165Hz'),
(26, 'Cổng kết nối', 'HDMI, DisplayPort'),

(27, 'Loại switch', 'Mechanical Blue'),
(27, 'Kết nối', 'USB'),
(27, 'Layout', 'TKL'),

(28, 'Kết nối', 'USB'),
(28, 'DPI tối đa', '25600'),
(28, 'Trọng lượng', '121g'),

(29, 'Kết nối', 'Wireless 2.4G'),
(29, 'DPI tối đa', '30000'),
(29, 'Trọng lượng', '63g');

INSERT INTO COMPATIBILITY_RULES
(rule_id, source_category_id, target_category_id, source_spec_name, target_spec_name, comparison_operator)
VALUES
(1, 1, 2, 'Chân cắm', 'Chân cắm', '='),
(2, 1, 2, 'Hỗ trợ RAM', 'Loại RAM', '='),
(3, 2, 3, 'Loại RAM', 'Loại RAM', '='),
(4, 2, 4, 'Giao tiếp GPU', 'Giao tiếp', '=');

-- =========================
-- LÔ NHẬP KHO
-- import_quantity: số lượng nhập ban đầu
-- quantity: số lượng tồn kho hiện tại
-- warranty_months: thời gian bảo hành theo lô
-- =========================
INSERT INTO BATCH (batch_id, batch_name, `date`)
VALUES
(1, 'Lô CPU AMD 2026', '2026-01-05'),
(2, 'Lô CPU Intel 2026', '2026-01-08'),
(3, 'Lô bo mạch chủ ASUS 2026', '2026-01-12'),
(4, 'Lô bo mạch chủ Gigabyte 2026', '2026-01-15'),
(5, 'Lô RAM và ổ cứng Kingston 2026', '2026-02-01'),
(6, 'Lô card đồ họa MSI 2026', '2026-02-08');

INSERT INTO BATCH_ITEMS
(batch_item_id, batch_id, product_id, import_quantity, quantity, price, warranty_months)
VALUES
(1, 1, 1, 20, 20, 4800000, 36),
(2, 1, 2, 15, 15, 7300000, 36),
(3, 1, 7, 10, 10, 10200000, 36),

(4, 2, 3, 25, 25, 3600000, 36),
(5, 2, 8, 12, 12, 9200000, 36),
(6, 2, 9, 8, 8, 13200000, 36),

(7, 3, 4, 10, 10, 3200000, 36),
(8, 3, 10, 8, 8, 5100000, 36),
(9, 3, 11, 10, 10, 4000000, 36),

(10, 4, 12, 15, 15, 2700000, 36),
(11, 4, 13, 10, 10, 4500000, 36),

(12, 5, 5, 30, 30, 1200000, 60),
(13, 5, 14, 20, 20, 2350000, 60),
(14, 5, 15, 10, 10, 5100000, 60),

(16, 6, 6, 8, 8, 8300000, 36),
(17, 6, 16, 6, 6, 14500000, 36),
(18, 6, 17, 4, 4, 19500000, 36),
(19, 6, 18, 3, 3, 29800000, 36);

-- =========================
-- GIỎ HÀNG
-- =========================
INSERT INTO CART (cart_id, customer_id)
VALUES
(1, 1),
(2, 2);

INSERT INTO CART_ITEMS (cart_item_id, cart_id, product_id, quantity)
VALUES
(1, 1, 1, 1),
(2, 1, 5, 2),
(3, 2, 3, 1),
(4, 2, 6, 1);

-- =========================
-- ĐƠN HÀNG
-- =========================
INSERT INTO ORDERS
(order_id, customer_id, status_id, order_date, total_amount, shipping_address, payment_method, payment_status, note, received_date)
VALUES
(10000, 1, 5, '2026-01-15 10:00:00', 8500000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD', 'Đã thanh toán', 'Khách hàng đã thanh toán khi nhận hàng', '2026-01-16 10:00:00'),

(10001, 2, 4, '2026-01-18 14:30:00', 13700000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'VNPAY', 'Đã thanh toán', 'Thanh toán trực tuyến qua VNPAY', NULL),

(10002, 1, 5, '2023-02-18 09:15:00', 8500000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD', 'Đã thanh toán', 'Đơn hàng CPU và RAM trong năm 2023', '2023-02-19 10:00:00'),

(10003, 2, 5, '2023-06-07 15:40:00', 8900000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Hà Nội',
'VNPAY', 'Đã thanh toán', 'Đơn hàng combo Intel trong năm 2023', '2023-06-08 10:00:00'),

(10004, 1, 6, '2023-11-25 20:05:00', 9500000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD', 'Đã hủy', 'Đơn hàng card đồ họa đã hủy trong năm 2023', NULL),

(10005, 2, 5, '2024-01-12 10:30:00', 13300000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Hà Nội',
'VNPAY', 'Đã thanh toán', 'Đơn hàng CPU và RAM trong năm 2024', '2024-01-13 10:00:00'),

(10006, 1, 5, '2024-04-30 13:25:00', 15300000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD', 'Đã thanh toán', 'Đơn hàng cấu hình AMD trong năm 2024', '2024-05-01 10:00:00'),

(10007, 2, 4, '2024-09-14 17:50:00', 22400000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Hà Nội',
'VNPAY', 'Đã thanh toán', 'Đơn hàng đang giao trong năm 2024', NULL),

(10008, 1, 5, '2025-03-03 08:10:00', 19900000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD', 'Đã thanh toán', 'Đơn hàng combo Ryzen 9 trong năm 2025', '2025-03-04 10:00:00'),

(10009, 2, 2, '2025-07-21 19:35:00', 20800000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Hà Nội',
'VNPAY', 'Đã thanh toán', 'Đơn hàng đã xác nhận trong năm 2025', NULL),

(10010, 1, 5, '2025-12-05 11:45:00', 29600000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'VNPAY', 'Đã thanh toán', 'Đơn hàng cấu hình card đồ họa trong năm 2025', '2025-12-06 10:00:00'),

(10011, 2, 1, '2026-02-16 14:20:00', 38800000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Hà Nội',
'VNPAY', 'Chờ thanh toán', 'Đơn hàng chờ xác nhận trong năm 2026', NULL),

(10012, 1, 3, '2026-05-09 16:05:00', 19300000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD', 'Chưa thanh toán', 'Đơn hàng đang chuẩn bị trong năm 2026', NULL),

(10013, 2, 4, '2026-06-10 09:55:00', 14800000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Hà Nội',
'COD', 'Chưa thanh toán', 'Đơn hàng COD đang giao trong năm 2026', NULL);

INSERT INTO ORDER_DETAILS
(order_detail_id, order_id, product_id, quantity, unit_price, subtotal)
VALUES
(1, 10000, 1, 1, 5500000, 5500000),
(2, 10000, 5, 2, 1500000, 3000000),

(3, 10001, 3, 1, 4200000, 4200000),
(4, 10001, 6, 1, 9500000, 9500000),

(5, 10002, 1, 1, 5500000, 5500000),
(6, 10002, 5, 2, 1500000, 3000000),

(7, 10003, 3, 1, 4200000, 4200000),
(8, 10003, 12, 1, 3200000, 3200000),
(9, 10003, 5, 1, 1500000, 1500000),

(10, 10004, 6, 1, 9500000, 9500000),

(11, 10005, 8, 1, 10500000, 10500000),
(12, 10005, 14, 1, 2800000, 2800000),

(13, 10006, 2, 1, 8500000, 8500000),
(14, 10006, 4, 1, 3800000, 3800000),
(15, 10006, 5, 2, 1500000, 3000000),

(16, 10007, 16, 1, 16500000, 16500000),
(17, 10007, 10, 1, 5900000, 5900000),

(18, 10008, 7, 1, 11900000, 11900000),
(19, 10008, 13, 1, 5200000, 5200000),
(20, 10008, 14, 1, 2800000, 2800000),

(21, 10009, 9, 1, 14900000, 14900000),
(22, 10009, 15, 1, 5900000, 5900000),

(23, 10010, 17, 1, 21900000, 21900000),
(24, 10010, 11, 1, 4700000, 4700000),
(25, 10010, 5, 2, 1500000, 3000000),

(26, 10011, 18, 1, 32900000, 32900000),
(27, 10011, 15, 1, 5900000, 5900000),

(28, 10012, 8, 1, 10500000, 10500000),
(29, 10012, 12, 1, 3200000, 3200000),
(30, 10012, 14, 2, 2800000, 5600000),

(31, 10013, 6, 1, 9500000, 9500000),
(32, 10013, 4, 1, 3800000, 3800000),
(33, 10013, 5, 1, 1500000, 1500000);

INSERT INTO PAYMENTS
(payment_id, order_id, payment_status, payment_provider, amount)
VALUES
(1, 10000, 'Đã thanh toán', 'COD', 8500000),
(2, 10001, 'Đã thanh toán', 'VNPAY', 13700000),
(3, 10002, 'Đã thanh toán', 'COD', 8500000),
(4, 10003, 'Đã thanh toán', 'VNPAY', 8900000),
(5, 10004, 'Đã hủy', 'COD', 9500000),
(6, 10005, 'Đã thanh toán', 'VNPAY', 13300000),
(7, 10006, 'Đã thanh toán', 'COD', 15300000),
(8, 10007, 'Đã thanh toán', 'VNPAY', 22400000),
(9, 10008, 'Đã thanh toán', 'COD', 19900000),
(10, 10009, 'Đã thanh toán', 'VNPAY', 20800000),
(11, 10010, 'Đã thanh toán', 'VNPAY', 29600000),
(12, 10011, 'Chờ thanh toán', 'VNPAY', 38800000),
(13, 10012, 'Chưa thanh toán', 'COD', 19300000),
(14, 10013, 'Chưa thanh toán', 'COD', 14800000);

INSERT INTO SHIPMENTS
(shipment_id, order_id, tracking_code, shipment_status, note)
VALUES
(1, 10000, 'TRK10000', 'Đã giao hàng', 'Giao hàng thành công'),
(2, 10001, 'TRK10001', 'Đang giao hàng', 'Đã bàn giao cho nhân viên giao hàng'),
(3, 10002, 'TRK10002', 'Đã giao hàng', 'Giao hàng thành công'),
(4, 10003, 'TRK10003', 'Đã giao hàng', 'Giao hàng thành công'),
(5, 10005, 'TRK10005', 'Đã giao hàng', 'Giao hàng thành công'),
(6, 10006, 'TRK10006', 'Đã giao hàng', 'Giao hàng thành công'),
(7, 10007, 'TRK10007', 'Đang giao hàng', 'Đơn hàng đang được vận chuyển'),
(8, 10008, 'TRK10008', 'Đã giao hàng', 'Giao hàng thành công'),
(9, 10010, 'TRK10010', 'Đã giao hàng', 'Giao hàng thành công'),
(10, 10013, 'TRK10013', 'Đang giao hàng', 'Đơn hàng COD đang được vận chuyển');

-- =========================
-- ĐÁNH GIÁ VÀ BẢO HÀNH
-- WARRANTIES không có order_detail_id
-- =========================
INSERT INTO REVIEWS
(review_id, customer_id, product_id, rating, comment, date)
VALUES
(1, 1, 1, 5,
'CPU chạy ổn định, nhiệt độ mát và hiệu năng chơi game rất tốt trong tầm giá.',
'2026-01-20 09:00:00'),

(2, 1, 5, 4,
'RAM hoạt động ổn định, đóng gói cẩn thận và giao hàng nhanh.',
'2026-01-20 09:10:00'),

(3, 2, 3, 5,
'Hiệu năng rất tốt trong tầm giá, phù hợp cho học tập, làm việc văn phòng và chơi game.',
'2026-01-22 15:00:00'),

(4, 2, 6, 5,
'Card đồ họa chạy mượt, DLSS hoạt động hiệu quả trong các trò chơi hỗ trợ.',
'2026-01-22 15:15:00');

INSERT INTO REVIEW_IMAGES (image_id, review_id, image_url)
VALUES
(1, 1, 'images/reviews/ryzen7600-review.jpg'),
(2, 2, 'images/reviews/kingston-ddr5-review.jpg'),
(3, 3, 'images/reviews/i512400f-review.jpg'),
(4, 4, 'images/reviews/msi4060-review.jpg');

INSERT INTO WARRANTIES
(warranty_id, customer_id, product_id, status_id, request_date, request)
VALUES
(1, 1, 1, 2, '2026-03-01 10:30:00',
'CPU có nhiệt độ cao hơn mong đợi khi chơi game, cần kiểm tra bảo hành.'),

(2, 2, 12, 1, '2026-06-01 16:45:00',
'Cổng USB trên bo mạch chủ hoạt động không ổn định, cần kiểm tra.');