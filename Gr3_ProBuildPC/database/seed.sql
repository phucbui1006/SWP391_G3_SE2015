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
(11, 3, 'Tốc độ',     'SELECT', '3200MHz,3600MHz,4800MHz,5200MHz,5600MHz,6000MHz,6200MHz,6400MHz,6600MHz', TRUE, 3),
(12, 4, 'Giao tiếp',        'SELECT', 'PCIe 3.0,PCIe 4.0,PCIe 5.0',  TRUE, 1),
(13, 4, 'Bộ nhớ đồ họa',    'SELECT', '4GB,6GB,8GB,12GB,16GB,24GB',   TRUE, 2),
(14, 5, 'Loại kết nối', 'SELECT', 'SATA III,NVMe M.2 PCIe 3.0,NVMe M.2 PCIe 4.0,NVMe M.2 PCIe 5.0', TRUE, 1),
(15, 5, 'Dung lượng',   'SELECT', '256GB,480GB,500GB,512GB,1TB,2TB,4TB',                              TRUE, 2),
(16, 5, 'Tốc độ đọc',   'TEXT',   NULL,                                                               FALSE, 3),
(17, 5, 'Tốc độ ghi',   'TEXT',   NULL,                                                               FALSE, 4),
(18, 6, 'Công suất',    'SELECT', '450W,550W,650W,750W,850W,1000W,1200W',              TRUE, 1),
(19, 6, 'Chuẩn hiệu suất', 'SELECT', '80 Plus,80 Plus Bronze,80 Plus Silver,80 Plus Gold,80 Plus Platinum', TRUE, 2),
(20, 6, 'Loại dây cáp',  'SELECT', 'Non-Modular,Semi-Modular,Full-Modular',            TRUE, 3),
(21, 7, 'Kích thước hỗ trợ', 'SELECT', 'ATX,Micro-ATX,Mini-ITX,E-ATX',                TRUE, 1),
(22, 7, 'Chất liệu',         'SELECT', 'Thép,Nhôm,Kính cường lực,Nhựa',               FALSE, 2),
(23, 7, 'Số quạt đi kèm',    'NUMBER',  NULL,                                          FALSE, 3),
(24, 8, 'Kích thước',     'SELECT', '21.5 inch,24 inch,24.5 inch,26.5 inch,27 inch,31.5 inch,32 inch,34 inch', TRUE, 1),
(25, 8, 'Độ phân giải',   'SELECT', 'Full HD,2K QHD,4K UHD',                           TRUE, 2),
(26, 8, 'Tấm nền',        'SELECT', 'IPS,VA,TN,OLED,QD-OLED',                          TRUE, 3),
(27, 8, 'Tần số quét',    'SELECT', '60Hz,75Hz,100Hz,120Hz,144Hz,165Hz,170Hz,175Hz,180Hz,240Hz,280Hz,360Hz,500Hz', TRUE, 4),
(28, 8, 'Cổng kết nối',   'TEXT',    NULL,                                              FALSE, 5),
(29, 9, 'Loại switch',   'SELECT', 'Membrane,Mechanical Red,Mechanical Blue,Mechanical Brown,Optical', FALSE, 1),
(30, 9, 'Kết nối',       'SELECT', 'USB,Wireless 2.4G,Bluetooth,USB + Bluetooth',                     TRUE, 2),
(31, 9, 'Layout',        'SELECT', 'Full-size,96%,TKL,75%,65%,60%',                                   TRUE, 3),
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
(4, 'Đang giao hàng'),
(5, 'Đã giao hàng'),
(6, 'Đã hủy'),
(7, 'Giao hàng thất bại');

INSERT INTO WARRANTY_STATUS (status_id, status_name)
VALUES
(1, 'Chờ tiếp nhận'),
(2, 'Từ chối'),
(3, 'Chấp nhận');

-- =========================
-- NGƯỜI DÙNG
-- =========================
INSERT INTO USERS
(user_id, full_name, status, email, password, account_type)
VALUES
(1, 'Bùi Phúc', 'ACTIVE', 'nguyenngoccham120705@gmail.com', MD5('123456'), 'STAFF'),
(2, 'Nguyễn Văn Nam', 'ACTIVE', 'nguyenvannam@gmail.com', MD5('123456'), 'STAFF'),
(3, 'Trần Minh Quân', 'ACTIVE', 'tranminhquan@gmail.com', MD5('123456'), 'STAFF'),
(4, 'Lê Hoàng Anh', 'ACTIVE', 'lehoanganh@gmail.com', MD5('123456'), 'CUSTOMER'),
(5, 'Phạm Thu Trang', 'ACTIVE', 'phamthutrang@gmail.com', MD5('123456'), 'CUSTOMER');

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
(product_id, category_id, brand_id, product_name, description, image_url, price, warranty_months, status)
VALUES
(1, 1, 1, 'AMD Ryzen 5 7600',
'AMD Ryzen 5 7600 có 6 nhân 12 luồng, hỗ trợ socket AM5, RAM DDR5 và mang lại hiệu năng chơi game tốt trong tầm giá.',
'images/products/amd-ryzen-5-7600.jpg', 5500000, 36, 'ACTIVE'),

(2, 1, 1, 'AMD Ryzen 7 7700X',
'AMD Ryzen 7 7700X có 8 nhân 16 luồng, phù hợp cho chơi game, livestream và sáng tạo nội dung trên nền tảng AM5.',
'images/products/amd-ryzen-7-7700x.jpg', 8500000, 36, 'ACTIVE'),

(3, 1, 4, 'Intel Core i5-12400F',
'Intel Core i5-12400F có 6 nhân 12 luồng, sử dụng socket LGA1700 và phù hợp cho học tập, làm việc văn phòng, chơi game.',
'images/products/intel-core-i5-12400f.jpg', 4200000, 36, 'ACTIVE'),

(4, 2, 2, 'ASUS PRIME B650M-A',
'ASUS PRIME B650M-A là bo mạch chủ AM5 hỗ trợ RAM DDR5, hoạt động ổn định cho các bộ máy dùng Ryzen 7000.',
'images/products/asus-prime-b650m-a.jpg', 3800000, 36, 'ACTIVE'),

(5, 3, 5, 'Kingston Fury Beast 16GB DDR5',
'Kingston Fury Beast 16GB DDR5 mang lại hiệu năng ổn định cho các nền tảng AMD và Intel đời mới.',
'images/products/kingston-fury-beast-16gb-ddr5.jpg', 1500000, 60, 'ACTIVE'),

(6, 4, 6, 'MSI GeForce RTX 4060 Ventus 2X',
'MSI GeForce RTX 4060 Ventus 2X hỗ trợ Ray Tracing, DLSS 3 và chơi game Full HD mượt mà.',
'images/products/msi-rtx-4060-ventus-2x.jpg', 9500000, 36, 'ACTIVE'),

(7, 1, 1, 'AMD Ryzen 9 7900X',
'AMD Ryzen 9 7900X có 12 nhân 24 luồng, phù hợp cho chơi game cao cấp, livestream và xử lý công việc chuyên nghiệp.',
'images/products/amd-ryzen-9-7900x.jpg', 11900000, 36, 'ACTIVE'),

(8, 1, 4, 'Intel Core i7-13700K',
'Intel Core i7-13700K mang lại hiệu năng mạnh cho chơi game và các tác vụ làm việc nặng trên nền tảng LGA1700.',
'images/products/intel-core-i7-13700k.jpg', 10500000, 36, 'ACTIVE'),

(9, 1, 4, 'Intel Core i9-13900K',
'Intel Core i9-13900K là bộ vi xử lý cao cấp dành cho đa nhiệm nặng, dựng hình và chơi game tần số quét cao.',
'images/products/intel-core-i9-13900k.jpg', 14900000, 36, 'ACTIVE'),

(10, 2, 2, 'ASUS ROG STRIX B650-A GAMING WIFI',
'ASUS ROG STRIX B650-A GAMING WIFI hỗ trợ AMD AM5, RAM DDR5, card đồ họa PCIe 4.0 và kết nối WiFi.',
'images/products/asus-rog-strix-b650a.jpg', 5900000, 36, 'ACTIVE'),

(11, 2, 2, 'ASUS TUF GAMING B760M-PLUS WIFI',
'ASUS TUF GAMING B760M-PLUS WIFI hỗ trợ CPU Intel LGA1700, RAM DDR5 và các cấu hình chơi game ổn định.',
'images/products/asus-tuf-b760m.jpg', 4700000, 36, 'ACTIVE'),

(12, 2, 3, 'Gigabyte B760M DS3H DDR5',
'Gigabyte B760M DS3H DDR5 hỗ trợ CPU Intel thế hệ 12 và 13 cùng bộ nhớ DDR5.',
'images/products/gigabyte-b760m-ds3h.jpg', 3200000, 36, 'ACTIVE'),

(13, 2, 3, 'Gigabyte B650 Gaming X AX',
'Gigabyte B650 Gaming X AX hỗ trợ CPU AMD AM5, RAM DDR5 và nhiều tính năng mở rộng hiện đại.',
'images/products/gigabyte-b650-gamingx.jpg', 5200000, 36, 'ACTIVE'),

(14, 3, 5, 'Kingston Fury Beast 32GB DDR5',
'Kingston Fury Beast 32GB DDR5 phù hợp cho chơi game, đa nhiệm và công việc sáng tạo nội dung.',
'images/products/kingston-fury-32gb.jpg', 2800000, 60, 'ACTIVE'),

(15, 3, 5, 'Kingston Fury Beast 64GB DDR5',
'Kingston Fury Beast 64GB DDR5 dành cho máy trạm, dựng phim, chỉnh ảnh và đa nhiệm nặng.',
'images/products/kingston-fury-64gb.jpg', 5900000, 60, 'ACTIVE'),

(16, 4, 6, 'MSI RTX 4070 Ventus 3X',
'MSI RTX 4070 Ventus 3X hỗ trợ DLSS 3 và Ray Tracing, phù hợp cho chơi game 2K hiệu năng cao.',
'images/products/msi-rtx4070.jpg', 16500000, 36, 'ACTIVE'),

(17, 4, 6, 'MSI RTX 4070 Ti Gaming X Trio',
'MSI RTX 4070 Ti Gaming X Trio mang lại hiệu năng mạnh cho chơi game 2K và 4K.',
'images/products/msi-rtx4070ti.jpg', 21900000, 36, 'ACTIVE'),

(18, 4, 6, 'MSI RTX 4080 Super Gaming X Trio',
'MSI RTX 4080 Super Gaming X Trio là card đồ họa cao cấp dành cho chơi game 4K và sáng tạo nội dung.',
'images/products/msi-rtx4080super.jpg', 32900000, 36, 'ACTIVE'),

(19, 5, 8, 'Samsung 980 Pro 1TB',
'Ổ cứng SSD Samsung 980 Pro 1TB PCIe 4.0 NVMe siêu tốc, lý tưởng cho hệ thống gaming và render.',
'images/products/samsung-980-pro-1tb.jpg', 2300000, 12, 'ACTIVE'),

(20, 5, 5, 'Kingston NV2 500GB',
'Ổ cứng SSD Kingston NV2 500GB PCIe 4.0, giải pháp lưu trữ tiết kiệm và hiệu quả.',
'images/products/kingston-nv2-500gb.jpg', 950000, 12, 'ACTIVE'),

(21, 6, 7, 'Corsair RM850x 850W',
'Nguồn máy tính Corsair RM850x 850W 80 Plus Gold Full Modular, hiệu năng cao và yên tĩnh.',
'images/products/corsair-rm850x.jpg', 3500000, 12, 'ACTIVE'),

(22, 6, 3, 'Gigabyte P650B 650W',
'Nguồn máy tính Gigabyte P650B 650W 80 Plus Bronze, phù hợp cho cấu hình tầm trung.',
'images/products/gigabyte-p650b.jpg', 1200000, 12, 'ACTIVE'),

(23, 7, 7, 'Corsair 4000D Airflow',
'Vỏ case Corsair 4000D Airflow Tempered Glass, tối ưu luồng gió làm mát hệ thống.',
'images/products/corsair-4000d.jpg', 1900000, 12, 'ACTIVE'),

(24, 7, 12, 'NZXT H510',
'Vỏ case NZXT H510 Mid Tower thiết kế tối giản, tinh tế, tích hợp sẵn quản lý cáp.',
'images/products/nzxt-h510.jpg', 1800000, 12, 'ACTIVE'),

(25, 8, 9, 'Dell UltraSharp U2720Q',
'Màn hình Dell UltraSharp U2720Q 27 inch 4K IPS, màu sắc chuẩn xác cho thiết kế đồ họa.',
'images/products/dell-u2720q.jpg', 12500000, 12, 'ACTIVE'),

(26, 8, 2, 'ASUS TUF Gaming VG27AQ',
'Màn hình ASUS TUF Gaming VG27AQ 27 inch 2K 165Hz IPS, mượt mà cho trải nghiệm gaming.',
'images/products/asus-tuf-vg27aq.jpg', 7500000, 12, 'ACTIVE'),

(27, 9, 10, 'Logitech G Pro X Keyboard',
'Bàn phím cơ Logitech G Pro X chuyên game, switch thay thế được.',
'images/products/logitech-g-pro-x-kb.jpg', 3200000, 12, 'ACTIVE'),

(28, 10, 10, 'Logitech G502 Hero',
'Chuột gaming Logitech G502 Hero cảm biến 25K cao cấp, thiết kế công thái học.',
'images/products/logitech-g502-hero.jpg', 1100000, 12, 'ACTIVE'),

(29, 10, 11, 'Razer DeathAdder V3 Pro',
'Chuột không dây siêu nhẹ Razer DeathAdder V3 Pro, thiết kế ergonomic hàng đầu.',
'images/products/razer-dav3-pro.jpg', 3500000, 12, 'ACTIVE');

-- =========================
-- MỞ RỘNG CATALOG: 20 SẢN PHẨM / DANH MỤC
-- Chỉ thêm dữ liệu vào cấu trúc hiện có. Danh sách URL ảnh đầy đủ nằm tại database/product-image-manifest.md.
-- =========================
INSERT INTO PRODUCTS
(product_id, category_id, brand_id, product_name, description, image_url, price, warranty_months, status)
SELECT
    plan.id_offset + numbers.number_value AS product_id,
    plan.category_id,
    CASE plan.category_id
        WHEN 1 THEN IF(MOD(numbers.number_value, 2) = 0, 4, 1)
        WHEN 2 THEN ELT(MOD(numbers.number_value - 1, 3) + 1, 2, 3, 6)
        WHEN 3 THEN IF(MOD(numbers.number_value, 2) = 0, 7, 5)
        WHEN 4 THEN ELT(MOD(numbers.number_value - 1, 3) + 1, 6, 2, 3)
        WHEN 5 THEN IF(MOD(numbers.number_value, 2) = 0, 5, 8)
        WHEN 6 THEN IF(MOD(numbers.number_value, 2) = 0, 3, 7)
        WHEN 7 THEN IF(MOD(numbers.number_value, 2) = 0, 12, 7)
        WHEN 8 THEN ELT(MOD(numbers.number_value - 1, 3) + 1, 9, 2, 6)
        WHEN 9 THEN ELT(MOD(numbers.number_value - 1, 3) + 1, 10, 11, 7)
        ELSE IF(MOD(numbers.number_value, 2) = 0, 11, 10)
    END AS brand_id,
    CONCAT(plan.name_prefix, ' ', LPAD(numbers.number_value, 2, '0')) AS product_name,
    CONCAT(plan.name_prefix, ' ', LPAD(numbers.number_value, 2, '0'),
           ' là sản phẩm chính hãng dành cho nhiều nhu cầu sử dụng tại ProBuild PC.') AS description,
    CONCAT('images/products/', plan.image_prefix, '-', LPAD(numbers.number_value, 2, '0'), '.jpg') AS image_url,
    plan.base_price + (numbers.number_value - 1) * plan.price_step AS price,
    plan.warranty_months,
    'ACTIVE'
FROM (
    SELECT 1 AS number_value UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16
    UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19
) numbers
JOIN (
    SELECT 1 AS category_id, 14 AS add_count, 29 AS id_offset, 'CPU Performance Series' AS name_prefix, 'cpu-performance' AS image_prefix, 3200000 AS base_price, 450000 AS price_step, 36 AS warranty_months
    UNION ALL SELECT 2, 15, 43, 'Mainboard Gaming Series', 'mainboard-gaming', 2400000, 280000, 36
    UNION ALL SELECT 3, 17, 58, 'RAM Gaming DDR5 Series', 'ram-gaming-ddr5', 950000, 180000, 60
    UNION ALL SELECT 4, 16, 75, 'Graphics Gaming Series', 'graphics-gaming', 7200000, 1300000, 36
    UNION ALL SELECT 5, 18, 91, 'SSD NVMe Series', 'ssd-nvme', 850000, 220000, 36
    UNION ALL SELECT 6, 18, 109, 'Power Supply Series', 'power-supply', 900000, 190000, 36
    UNION ALL SELECT 7, 18, 127, 'PC Case Airflow Series', 'pc-case-airflow', 850000, 160000, 24
    UNION ALL SELECT 8, 18, 145, 'Gaming Monitor Series', 'gaming-monitor', 2900000, 480000, 36
    UNION ALL SELECT 9, 19, 163, 'Mechanical Keyboard Series', 'mechanical-keyboard', 650000, 150000, 24
    UNION ALL SELECT 10, 18, 182, 'Gaming Mouse Series', 'gaming-mouse', 350000, 120000, 24
) plan ON numbers.number_value <= plan.add_count;


-- Chuẩn hóa catalog mở rộng bằng tên model thực tế đang có trên thị trường.
UPDATE PRODUCTS product
JOIN (
    SELECT 30 AS product_id, 1 AS brand_id, 'AMD Ryzen 5 7600X' AS product_name, 'images/products/amd-ryzen-5-7600x.jpg' AS image_url
    UNION ALL SELECT 31 AS product_id, 4 AS brand_id, 'Intel Core i5-13400F' AS product_name, 'images/products/intel-core-i5-13400f.jpg' AS image_url
    UNION ALL SELECT 32 AS product_id, 1 AS brand_id, 'AMD Ryzen 7 7700' AS product_name, 'images/products/amd-ryzen-7-7700.jpg' AS image_url
    UNION ALL SELECT 33 AS product_id, 4 AS brand_id, 'Intel Core i5-13600K' AS product_name, 'images/products/intel-core-i5-13600k.jpg' AS image_url
    UNION ALL SELECT 34 AS product_id, 1 AS brand_id, 'AMD Ryzen 7 7800X3D' AS product_name, 'images/products/amd-ryzen-7-7800x3d.jpg' AS image_url
    UNION ALL SELECT 35 AS product_id, 4 AS brand_id, 'Intel Core i7-14700K' AS product_name, 'images/products/intel-core-i7-14700k.jpg' AS image_url
    UNION ALL SELECT 36 AS product_id, 1 AS brand_id, 'AMD Ryzen 9 7900' AS product_name, 'images/products/amd-ryzen-9-7900.jpg' AS image_url
    UNION ALL SELECT 37 AS product_id, 4 AS brand_id, 'Intel Core i9-14900K' AS product_name, 'images/products/intel-core-i9-14900k.jpg' AS image_url
    UNION ALL SELECT 38 AS product_id, 1 AS brand_id, 'AMD Ryzen 9 7950X' AS product_name, 'images/products/amd-ryzen-9-7950x.jpg' AS image_url
    UNION ALL SELECT 39 AS product_id, 4 AS brand_id, 'Intel Core i3-12100F' AS product_name, 'images/products/intel-core-i3-12100f.jpg' AS image_url
    UNION ALL SELECT 40 AS product_id, 1 AS brand_id, 'AMD Ryzen 5 7500F' AS product_name, 'images/products/amd-ryzen-5-7500f.jpg' AS image_url
    UNION ALL SELECT 41 AS product_id, 4 AS brand_id, 'Intel Core i5-14400F' AS product_name, 'images/products/intel-core-i5-14400f.jpg' AS image_url
    UNION ALL SELECT 42 AS product_id, 1 AS brand_id, 'AMD Ryzen 7 9700X' AS product_name, 'images/products/amd-ryzen-7-9700x.jpg' AS image_url
    UNION ALL SELECT 43 AS product_id, 4 AS brand_id, 'Intel Core i9-12900K' AS product_name, 'images/products/intel-core-i9-12900k.jpg' AS image_url
    UNION ALL SELECT 44 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming B650-Plus WiFi' AS product_name, 'images/products/asus-tuf-gaming-b650-plus-wifi.jpg' AS image_url
    UNION ALL SELECT 45 AS product_id, 6 AS brand_id, 'MSI PRO B760M-A WiFi DDR5' AS product_name, 'images/products/msi-pro-b760m-a-wifi-ddr5.jpg' AS image_url
    UNION ALL SELECT 46 AS product_id, 3 AS brand_id, 'Gigabyte B650 AORUS Elite AX' AS product_name, 'images/products/gigabyte-b650-aorus-elite-ax.jpg' AS image_url
    UNION ALL SELECT 47 AS product_id, 2 AS brand_id, 'ASUS PRIME B760-Plus' AS product_name, 'images/products/asus-prime-b760-plus.jpg' AS image_url
    UNION ALL SELECT 48 AS product_id, 6 AS brand_id, 'MSI MAG B650 Tomahawk WiFi' AS product_name, 'images/products/msi-mag-b650-tomahawk-wifi.jpg' AS image_url
    UNION ALL SELECT 49 AS product_id, 3 AS brand_id, 'Gigabyte Z790 AORUS Elite AX' AS product_name, 'images/products/gigabyte-z790-aorus-elite-ax.jpg' AS image_url
    UNION ALL SELECT 50 AS product_id, 2 AS brand_id, 'ASUS ROG Strix X670E-E Gaming WiFi' AS product_name, 'images/products/asus-rog-strix-x670e-e-gaming-wifi.jpg' AS image_url
    UNION ALL SELECT 51 AS product_id, 6 AS brand_id, 'MSI PRO Z790-P WiFi' AS product_name, 'images/products/msi-pro-z790-p-wifi.jpg' AS image_url
    UNION ALL SELECT 52 AS product_id, 3 AS brand_id, 'Gigabyte B650M DS3H' AS product_name, 'images/products/gigabyte-b650m-ds3h.jpg' AS image_url
    UNION ALL SELECT 53 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming Z790-Plus WiFi' AS product_name, 'images/products/asus-tuf-gaming-z790-plus-wifi.jpg' AS image_url
    UNION ALL SELECT 54 AS product_id, 6 AS brand_id, 'MSI MPG X670E Carbon WiFi' AS product_name, 'images/products/msi-mpg-x670e-carbon-wifi.jpg' AS image_url
    UNION ALL SELECT 55 AS product_id, 3 AS brand_id, 'Gigabyte B760 Gaming X AX' AS product_name, 'images/products/gigabyte-b760-gaming-x-ax.jpg' AS image_url
    UNION ALL SELECT 56 AS product_id, 2 AS brand_id, 'ASUS PRIME X670-P WiFi' AS product_name, 'images/products/asus-prime-x670-p-wifi.jpg' AS image_url
    UNION ALL SELECT 57 AS product_id, 6 AS brand_id, 'MSI MAG Z790 Tomahawk WiFi' AS product_name, 'images/products/msi-mag-z790-tomahawk-wifi.jpg' AS image_url
    UNION ALL SELECT 58 AS product_id, 3 AS brand_id, 'Gigabyte X670 AORUS Elite AX' AS product_name, 'images/products/gigabyte-x670-aorus-elite-ax.jpg' AS image_url
    UNION ALL SELECT 59 AS product_id, 5 AS brand_id, 'Kingston Fury Beast 8GB DDR5 5200' AS product_name, 'images/products/kingston-fury-beast-8gb-ddr5-5200.jpg' AS image_url
    UNION ALL SELECT 60 AS product_id, 7 AS brand_id, 'Corsair Vengeance 16GB DDR5 5200' AS product_name, 'images/products/corsair-vengeance-16gb-ddr5-5200.jpg' AS image_url
    UNION ALL SELECT 61 AS product_id, 5 AS brand_id, 'Kingston Fury Beast RGB 16GB DDR5 5600' AS product_name, 'images/products/kingston-fury-beast-rgb-16gb-ddr5-5600.jpg' AS image_url
    UNION ALL SELECT 62 AS product_id, 7 AS brand_id, 'Corsair Vengeance RGB 32GB DDR5 6000' AS product_name, 'images/products/corsair-vengeance-rgb-32gb-ddr5-6000.jpg' AS image_url
    UNION ALL SELECT 63 AS product_id, 5 AS brand_id, 'Kingston Fury Renegade 32GB DDR5 6000' AS product_name, 'images/products/kingston-fury-renegade-32gb-ddr5-6000.jpg' AS image_url
    UNION ALL SELECT 64 AS product_id, 7 AS brand_id, 'Corsair Dominator Platinum RGB 32GB DDR5 6200' AS product_name, 'images/products/corsair-dominator-platinum-rgb-32gb-ddr5-6200.jpg' AS image_url
    UNION ALL SELECT 65 AS product_id, 5 AS brand_id, 'Kingston Fury Beast 32GB DDR5 5200' AS product_name, 'images/products/kingston-fury-beast-32gb-ddr5-5200.jpg' AS image_url
    UNION ALL SELECT 66 AS product_id, 7 AS brand_id, 'Corsair Vengeance 64GB DDR5 5600' AS product_name, 'images/products/corsair-vengeance-64gb-ddr5-5600.jpg' AS image_url
    UNION ALL SELECT 67 AS product_id, 5 AS brand_id, 'Kingston Fury Renegade RGB 64GB DDR5 6000' AS product_name, 'images/products/kingston-fury-renegade-rgb-64gb-ddr5-6000.jpg' AS image_url
    UNION ALL SELECT 68 AS product_id, 7 AS brand_id, 'Corsair Dominator Titanium 64GB DDR5 6600' AS product_name, 'images/products/corsair-dominator-titanium-64gb-ddr5-6600.jpg' AS image_url
    UNION ALL SELECT 69 AS product_id, 5 AS brand_id, 'Kingston ValueRAM 16GB DDR5 4800' AS product_name, 'images/products/kingston-valueram-16gb-ddr5-4800.jpg' AS image_url
    UNION ALL SELECT 70 AS product_id, 7 AS brand_id, 'Corsair Vengeance 32GB DDR5 5600' AS product_name, 'images/products/corsair-vengeance-32gb-ddr5-5600.jpg' AS image_url
    UNION ALL SELECT 71 AS product_id, 5 AS brand_id, 'Kingston Fury Impact 32GB DDR5 5600' AS product_name, 'images/products/kingston-fury-impact-32gb-ddr5-5600.jpg' AS image_url
    UNION ALL SELECT 72 AS product_id, 7 AS brand_id, 'Corsair Vengeance RGB 64GB DDR5 6000' AS product_name, 'images/products/corsair-vengeance-rgb-64gb-ddr5-6000.jpg' AS image_url
    UNION ALL SELECT 73 AS product_id, 5 AS brand_id, 'Kingston Fury Beast RGB 32GB DDR5 6000' AS product_name, 'images/products/kingston-fury-beast-rgb-32gb-ddr5-6000.jpg' AS image_url
    UNION ALL SELECT 74 AS product_id, 7 AS brand_id, 'Corsair Dominator Platinum 64GB DDR5 5600' AS product_name, 'images/products/corsair-dominator-platinum-64gb-ddr5-5600.jpg' AS image_url
    UNION ALL SELECT 75 AS product_id, 5 AS brand_id, 'Kingston Fury Renegade 16GB DDR5 6400' AS product_name, 'images/products/kingston-fury-renegade-16gb-ddr5-6400.jpg' AS image_url
    UNION ALL SELECT 76 AS product_id, 2 AS brand_id, 'ASUS Dual GeForce RTX 4060 OC 8GB' AS product_name, 'images/products/asus-dual-geforce-rtx-4060-oc-8gb.jpg' AS image_url
    UNION ALL SELECT 77 AS product_id, 3 AS brand_id, 'Gigabyte GeForce RTX 4060 Eagle OC 8GB' AS product_name, 'images/products/gigabyte-geforce-rtx-4060-eagle-oc-8gb.jpg' AS image_url
    UNION ALL SELECT 78 AS product_id, 6 AS brand_id, 'MSI GeForce RTX 4060 Ti Ventus 2X 8GB' AS product_name, 'images/products/msi-geforce-rtx-4060-ti-ventus-2x-8gb.jpg' AS image_url
    UNION ALL SELECT 79 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming GeForce RTX 4070 Super 12GB' AS product_name, 'images/products/asus-tuf-gaming-geforce-rtx-4070-super-12gb.jpg' AS image_url
    UNION ALL SELECT 80 AS product_id, 3 AS brand_id, 'Gigabyte GeForce RTX 4070 Super Gaming OC 12GB' AS product_name, 'images/products/gigabyte-geforce-rtx-4070-super-gaming-oc-12gb.jpg' AS image_url
    UNION ALL SELECT 81 AS product_id, 6 AS brand_id, 'MSI GeForce RTX 4070 Super Gaming X Slim 12GB' AS product_name, 'images/products/msi-geforce-rtx-4070-super-gaming-x-slim-12gb.jpg' AS image_url
    UNION ALL SELECT 82 AS product_id, 2 AS brand_id, 'ASUS ProArt GeForce RTX 4070 Ti Super 16GB' AS product_name, 'images/products/asus-proart-geforce-rtx-4070-ti-super-16gb.jpg' AS image_url
    UNION ALL SELECT 83 AS product_id, 3 AS brand_id, 'Gigabyte GeForce RTX 4070 Ti Super Windforce OC 16GB' AS product_name, 'images/products/gigabyte-geforce-rtx-4070-ti-super-windforce-oc-16gb.jpg' AS image_url
    UNION ALL SELECT 84 AS product_id, 6 AS brand_id, 'MSI GeForce RTX 4070 Ti Super Ventus 3X 16GB' AS product_name, 'images/products/msi-geforce-rtx-4070-ti-super-ventus-3x-16gb.jpg' AS image_url
    UNION ALL SELECT 85 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming GeForce RTX 4080 Super 16GB' AS product_name, 'images/products/asus-tuf-gaming-geforce-rtx-4080-super-16gb.jpg' AS image_url
    UNION ALL SELECT 86 AS product_id, 3 AS brand_id, 'Gigabyte GeForce RTX 4080 Super Aero OC 16GB' AS product_name, 'images/products/gigabyte-geforce-rtx-4080-super-aero-oc-16gb.jpg' AS image_url
    UNION ALL SELECT 87 AS product_id, 6 AS brand_id, 'MSI GeForce RTX 4080 Super Ventus 3X 16GB' AS product_name, 'images/products/msi-geforce-rtx-4080-super-ventus-3x-16gb.jpg' AS image_url
    UNION ALL SELECT 88 AS product_id, 2 AS brand_id, 'ASUS ROG Strix GeForce RTX 4090 OC 24GB' AS product_name, 'images/products/asus-rog-strix-geforce-rtx-4090-oc-24gb.jpg' AS image_url
    UNION ALL SELECT 89 AS product_id, 3 AS brand_id, 'Gigabyte GeForce RTX 4090 Gaming OC 24GB' AS product_name, 'images/products/gigabyte-geforce-rtx-4090-gaming-oc-24gb.jpg' AS image_url
    UNION ALL SELECT 90 AS product_id, 6 AS brand_id, 'MSI GeForce RTX 4090 Suprim X 24GB' AS product_name, 'images/products/msi-geforce-rtx-4090-suprim-x-24gb.jpg' AS image_url
    UNION ALL SELECT 91 AS product_id, 3 AS brand_id, 'Gigabyte Radeon RX 7800 XT Gaming OC 16GB' AS product_name, 'images/products/gigabyte-radeon-rx-7800-xt-gaming-oc-16gb.jpg' AS image_url
    UNION ALL SELECT 92 AS product_id, 8 AS brand_id, 'Samsung 990 Pro 1TB' AS product_name, 'images/products/samsung-990-pro-1tb.jpg' AS image_url
    UNION ALL SELECT 93 AS product_id, 5 AS brand_id, 'Kingston NV2 1TB' AS product_name, 'images/products/kingston-nv2-1tb.jpg' AS image_url
    UNION ALL SELECT 94 AS product_id, 7 AS brand_id, 'Corsair MP600 Core XT 1TB' AS product_name, 'images/products/corsair-mp600-core-xt-1tb.jpg' AS image_url
    UNION ALL SELECT 95 AS product_id, 8 AS brand_id, 'Samsung 980 500GB' AS product_name, 'images/products/samsung-980-500gb.jpg' AS image_url
    UNION ALL SELECT 96 AS product_id, 5 AS brand_id, 'Kingston KC3000 1TB' AS product_name, 'images/products/kingston-kc3000-1tb.jpg' AS image_url
    UNION ALL SELECT 97 AS product_id, 7 AS brand_id, 'Corsair MP600 Pro LPX 2TB' AS product_name, 'images/products/corsair-mp600-pro-lpx-2tb.jpg' AS image_url
    UNION ALL SELECT 98 AS product_id, 8 AS brand_id, 'Samsung 990 Evo 1TB' AS product_name, 'images/products/samsung-990-evo-1tb.jpg' AS image_url
    UNION ALL SELECT 99 AS product_id, 5 AS brand_id, 'Kingston Fury Renegade 2TB' AS product_name, 'images/products/kingston-fury-renegade-2tb.jpg' AS image_url
    UNION ALL SELECT 100 AS product_id, 7 AS brand_id, 'Corsair MP700 Pro 2TB' AS product_name, 'images/products/corsair-mp700-pro-2tb.jpg' AS image_url
    UNION ALL SELECT 101 AS product_id, 8 AS brand_id, 'Samsung 870 Evo 1TB' AS product_name, 'images/products/samsung-870-evo-1tb.jpg' AS image_url
    UNION ALL SELECT 102 AS product_id, 5 AS brand_id, 'Kingston A400 480GB' AS product_name, 'images/products/kingston-a400-480gb.jpg' AS image_url
    UNION ALL SELECT 103 AS product_id, 7 AS brand_id, 'Corsair MP600 Elite 1TB' AS product_name, 'images/products/corsair-mp600-elite-1tb.jpg' AS image_url
    UNION ALL SELECT 104 AS product_id, 8 AS brand_id, 'Samsung 990 Pro 2TB' AS product_name, 'images/products/samsung-990-pro-2tb.jpg' AS image_url
    UNION ALL SELECT 105 AS product_id, 5 AS brand_id, 'Kingston NV3 2TB' AS product_name, 'images/products/kingston-nv3-2tb.jpg' AS image_url
    UNION ALL SELECT 106 AS product_id, 7 AS brand_id, 'Corsair MP600 Mini 1TB' AS product_name, 'images/products/corsair-mp600-mini-1tb.jpg' AS image_url
    UNION ALL SELECT 107 AS product_id, 8 AS brand_id, 'Samsung 870 QVO 2TB' AS product_name, 'images/products/samsung-870-qvo-2tb.jpg' AS image_url
    UNION ALL SELECT 108 AS product_id, 5 AS brand_id, 'Kingston KC600 2TB' AS product_name, 'images/products/kingston-kc600-2tb.jpg' AS image_url
    UNION ALL SELECT 109 AS product_id, 7 AS brand_id, 'Corsair MP700 Elite 2TB' AS product_name, 'images/products/corsair-mp700-elite-2tb.jpg' AS image_url
    UNION ALL SELECT 110 AS product_id, 7 AS brand_id, 'Corsair CV550 550W' AS product_name, 'images/products/corsair-cv550-550w.jpg' AS image_url
    UNION ALL SELECT 111 AS product_id, 3 AS brand_id, 'Gigabyte P650G 650W' AS product_name, 'images/products/gigabyte-p650g-650w.jpg' AS image_url
    UNION ALL SELECT 112 AS product_id, 6 AS brand_id, 'MSI MAG A650BN 650W' AS product_name, 'images/products/msi-mag-a650bn-650w.jpg' AS image_url
    UNION ALL SELECT 113 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming 750B 750W' AS product_name, 'images/products/asus-tuf-gaming-750b-750w.jpg' AS image_url
    UNION ALL SELECT 114 AS product_id, 7 AS brand_id, 'Corsair CX650 650W' AS product_name, 'images/products/corsair-cx650-650w.jpg' AS image_url
    UNION ALL SELECT 115 AS product_id, 3 AS brand_id, 'Gigabyte UD750GM 750W' AS product_name, 'images/products/gigabyte-ud750gm-750w.jpg' AS image_url
    UNION ALL SELECT 116 AS product_id, 6 AS brand_id, 'MSI MAG A750GL PCIE5 750W' AS product_name, 'images/products/msi-mag-a750gl-pcie5-750w.jpg' AS image_url
    UNION ALL SELECT 117 AS product_id, 2 AS brand_id, 'ASUS ROG Strix 850G 850W' AS product_name, 'images/products/asus-rog-strix-850g-850w.jpg' AS image_url
    UNION ALL SELECT 118 AS product_id, 7 AS brand_id, 'Corsair RM750e 750W' AS product_name, 'images/products/corsair-rm750e-750w.jpg' AS image_url
    UNION ALL SELECT 119 AS product_id, 3 AS brand_id, 'Gigabyte UD850GM PG5 850W' AS product_name, 'images/products/gigabyte-ud850gm-pg5-850w.jpg' AS image_url
    UNION ALL SELECT 120 AS product_id, 6 AS brand_id, 'MSI MPG A850G PCIE5 850W' AS product_name, 'images/products/msi-mpg-a850g-pcie5-850w.jpg' AS image_url
    UNION ALL SELECT 121 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming 1000G 1000W' AS product_name, 'images/products/asus-tuf-gaming-1000g-1000w.jpg' AS image_url
    UNION ALL SELECT 122 AS product_id, 7 AS brand_id, 'Corsair RM1000x 1000W' AS product_name, 'images/products/corsair-rm1000x-1000w.jpg' AS image_url
    UNION ALL SELECT 123 AS product_id, 3 AS brand_id, 'Gigabyte AORUS P1200W 1200W' AS product_name, 'images/products/gigabyte-aorus-p1200w-1200w.jpg' AS image_url
    UNION ALL SELECT 124 AS product_id, 6 AS brand_id, 'MSI MEG Ai1000P PCIE5 1000W' AS product_name, 'images/products/msi-meg-ai1000p-pcie5-1000w.jpg' AS image_url
    UNION ALL SELECT 125 AS product_id, 2 AS brand_id, 'ASUS ROG Thor 1200P2 1200W' AS product_name, 'images/products/asus-rog-thor-1200p2-1200w.jpg' AS image_url
    UNION ALL SELECT 126 AS product_id, 7 AS brand_id, 'Corsair SF850L 850W' AS product_name, 'images/products/corsair-sf850l-850w.jpg' AS image_url
    UNION ALL SELECT 127 AS product_id, 6 AS brand_id, 'MSI MAG A550BN 550W' AS product_name, 'images/products/msi-mag-a550bn-550w.jpg' AS image_url
    UNION ALL SELECT 128 AS product_id, 7 AS brand_id, 'Corsair 3000D Airflow' AS product_name, 'images/products/corsair-3000d-airflow.jpg' AS image_url
    UNION ALL SELECT 129 AS product_id, 12 AS brand_id, 'NZXT H5 Flow' AS product_name, 'images/products/nzxt-h5-flow.jpg' AS image_url
    UNION ALL SELECT 130 AS product_id, 6 AS brand_id, 'MSI MAG Forge 100R' AS product_name, 'images/products/msi-mag-forge-100r.jpg' AS image_url
    UNION ALL SELECT 131 AS product_id, 2 AS brand_id, 'ASUS Prime AP201' AS product_name, 'images/products/asus-prime-ap201.jpg' AS image_url
    UNION ALL SELECT 132 AS product_id, 7 AS brand_id, 'Corsair 5000D Airflow' AS product_name, 'images/products/corsair-5000d-airflow.jpg' AS image_url
    UNION ALL SELECT 133 AS product_id, 12 AS brand_id, 'NZXT H6 Flow' AS product_name, 'images/products/nzxt-h6-flow.jpg' AS image_url
    UNION ALL SELECT 134 AS product_id, 6 AS brand_id, 'MSI MPG Gungnir 110R' AS product_name, 'images/products/msi-mpg-gungnir-110r.jpg' AS image_url
    UNION ALL SELECT 135 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming GT301' AS product_name, 'images/products/asus-tuf-gaming-gt301.jpg' AS image_url
    UNION ALL SELECT 136 AS product_id, 7 AS brand_id, 'Corsair 7000D Airflow' AS product_name, 'images/products/corsair-7000d-airflow.jpg' AS image_url
    UNION ALL SELECT 137 AS product_id, 12 AS brand_id, 'NZXT H7 Flow' AS product_name, 'images/products/nzxt-h7-flow.jpg' AS image_url
    UNION ALL SELECT 138 AS product_id, 6 AS brand_id, 'MSI MAG Pano M100R PZ' AS product_name, 'images/products/msi-mag-pano-m100r-pz.jpg' AS image_url
    UNION ALL SELECT 139 AS product_id, 2 AS brand_id, 'ASUS ROG Strix Helios' AS product_name, 'images/products/asus-rog-strix-helios.jpg' AS image_url
    UNION ALL SELECT 140 AS product_id, 7 AS brand_id, 'Corsair iCUE 4000X RGB' AS product_name, 'images/products/corsair-icue-4000x-rgb.jpg' AS image_url
    UNION ALL SELECT 141 AS product_id, 12 AS brand_id, 'NZXT H9 Flow' AS product_name, 'images/products/nzxt-h9-flow.jpg' AS image_url
    UNION ALL SELECT 142 AS product_id, 6 AS brand_id, 'MSI MPG Velox 100R' AS product_name, 'images/products/msi-mpg-velox-100r.jpg' AS image_url
    UNION ALL SELECT 143 AS product_id, 2 AS brand_id, 'ASUS A21 Case' AS product_name, 'images/products/asus-a21-case.jpg' AS image_url
    UNION ALL SELECT 144 AS product_id, 7 AS brand_id, 'Corsair 2500D Airflow' AS product_name, 'images/products/corsair-2500d-airflow.jpg' AS image_url
    UNION ALL SELECT 145 AS product_id, 12 AS brand_id, 'NZXT H5 Elite' AS product_name, 'images/products/nzxt-h5-elite.jpg' AS image_url
    UNION ALL SELECT 146 AS product_id, 9 AS brand_id, 'Dell P2422H' AS product_name, 'images/products/dell-p2422h.jpg' AS image_url
    UNION ALL SELECT 147 AS product_id, 2 AS brand_id, 'ASUS VA24EHF' AS product_name, 'images/products/asus-va24ehf.jpg' AS image_url
    UNION ALL SELECT 148 AS product_id, 6 AS brand_id, 'MSI PRO MP243X' AS product_name, 'images/products/msi-pro-mp243x.jpg' AS image_url
    UNION ALL SELECT 149 AS product_id, 3 AS brand_id, 'Gigabyte G24F 2' AS product_name, 'images/products/gigabyte-g24f-2.jpg' AS image_url
    UNION ALL SELECT 150 AS product_id, 9 AS brand_id, 'Dell G2524H' AS product_name, 'images/products/dell-g2524h.jpg' AS image_url
    UNION ALL SELECT 151 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming VG249Q3A' AS product_name, 'images/products/asus-tuf-gaming-vg249q3a.jpg' AS image_url
    UNION ALL SELECT 152 AS product_id, 6 AS brand_id, 'MSI G274F' AS product_name, 'images/products/msi-g274f.jpg' AS image_url
    UNION ALL SELECT 153 AS product_id, 3 AS brand_id, 'Gigabyte M27Q' AS product_name, 'images/products/gigabyte-m27q.jpg' AS image_url
    UNION ALL SELECT 154 AS product_id, 9 AS brand_id, 'Dell UltraSharp U2723QE' AS product_name, 'images/products/dell-ultrasharp-u2723qe.jpg' AS image_url
    UNION ALL SELECT 155 AS product_id, 2 AS brand_id, 'ASUS ROG Strix XG27ACS' AS product_name, 'images/products/asus-rog-strix-xg27acs.jpg' AS image_url
    UNION ALL SELECT 156 AS product_id, 6 AS brand_id, 'MSI MAG 274QRF QD E2' AS product_name, 'images/products/msi-mag-274qrf-qd-e2.jpg' AS image_url
    UNION ALL SELECT 157 AS product_id, 3 AS brand_id, 'Gigabyte GS27Q X' AS product_name, 'images/products/gigabyte-gs27q-x.jpg' AS image_url
    UNION ALL SELECT 158 AS product_id, 9 AS brand_id, 'Dell Alienware AW2725DF' AS product_name, 'images/products/dell-alienware-aw2725df.jpg' AS image_url
    UNION ALL SELECT 159 AS product_id, 2 AS brand_id, 'ASUS ROG Swift PG27AQDM' AS product_name, 'images/products/asus-rog-swift-pg27aqdm.jpg' AS image_url
    UNION ALL SELECT 160 AS product_id, 6 AS brand_id, 'MSI MPG 271QRX QD-OLED' AS product_name, 'images/products/msi-mpg-271qrx-qd-oled.jpg' AS image_url
    UNION ALL SELECT 161 AS product_id, 3 AS brand_id, 'Gigabyte AORUS FO32U2P' AS product_name, 'images/products/gigabyte-aorus-fo32u2p.jpg' AS image_url
    UNION ALL SELECT 162 AS product_id, 9 AS brand_id, 'Dell UltraSharp U3223QE' AS product_name, 'images/products/dell-ultrasharp-u3223qe.jpg' AS image_url
    UNION ALL SELECT 163 AS product_id, 2 AS brand_id, 'ASUS ProArt PA329CV' AS product_name, 'images/products/asus-proart-pa329cv.jpg' AS image_url
    UNION ALL SELECT 164 AS product_id, 10 AS brand_id, 'Logitech G413 SE' AS product_name, 'images/products/logitech-g413-se.jpg' AS image_url
    UNION ALL SELECT 165 AS product_id, 11 AS brand_id, 'Razer BlackWidow V3' AS product_name, 'images/products/razer-blackwidow-v3.jpg' AS image_url
    UNION ALL SELECT 166 AS product_id, 7 AS brand_id, 'Corsair K70 RGB Pro' AS product_name, 'images/products/corsair-k70-rgb-pro.jpg' AS image_url
    UNION ALL SELECT 167 AS product_id, 2 AS brand_id, 'ASUS ROG Strix Scope II 96 Wireless' AS product_name, 'images/products/asus-rog-strix-scope-ii-96-wireless.jpg' AS image_url
    UNION ALL SELECT 168 AS product_id, 10 AS brand_id, 'Logitech G515 Lightspeed TKL' AS product_name, 'images/products/logitech-g515-lightspeed-tkl.jpg' AS image_url
    UNION ALL SELECT 169 AS product_id, 11 AS brand_id, 'Razer Huntsman V2 TKL' AS product_name, 'images/products/razer-huntsman-v2-tkl.jpg' AS image_url
    UNION ALL SELECT 170 AS product_id, 7 AS brand_id, 'Corsair K65 RGB Mini' AS product_name, 'images/products/corsair-k65-rgb-mini.jpg' AS image_url
    UNION ALL SELECT 171 AS product_id, 2 AS brand_id, 'ASUS ROG Falchion RX Low Profile' AS product_name, 'images/products/asus-rog-falchion-rx-low-profile.jpg' AS image_url
    UNION ALL SELECT 172 AS product_id, 10 AS brand_id, 'Logitech G915 TKL' AS product_name, 'images/products/logitech-g915-tkl.jpg' AS image_url
    UNION ALL SELECT 173 AS product_id, 11 AS brand_id, 'Razer DeathStalker V2 Pro' AS product_name, 'images/products/razer-deathstalker-v2-pro.jpg' AS image_url
    UNION ALL SELECT 174 AS product_id, 7 AS brand_id, 'Corsair K100 RGB' AS product_name, 'images/products/corsair-k100-rgb.jpg' AS image_url
    UNION ALL SELECT 175 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming K3 Gen II' AS product_name, 'images/products/asus-tuf-gaming-k3-gen-ii.jpg' AS image_url
    UNION ALL SELECT 176 AS product_id, 10 AS brand_id, 'Logitech G Pro X TKL Lightspeed' AS product_name, 'images/products/logitech-g-pro-x-tkl-lightspeed.jpg' AS image_url
    UNION ALL SELECT 177 AS product_id, 11 AS brand_id, 'Razer BlackWidow V4 75 Percent' AS product_name, 'images/products/razer-blackwidow-v4-75-percent.jpg' AS image_url
    UNION ALL SELECT 178 AS product_id, 7 AS brand_id, 'Corsair K70 Core RGB' AS product_name, 'images/products/corsair-k70-core-rgb.jpg' AS image_url
    UNION ALL SELECT 179 AS product_id, 2 AS brand_id, 'ASUS ROG Azoth' AS product_name, 'images/products/asus-rog-azoth.jpg' AS image_url
    UNION ALL SELECT 180 AS product_id, 10 AS brand_id, 'Logitech MX Mechanical' AS product_name, 'images/products/logitech-mx-mechanical.jpg' AS image_url
    UNION ALL SELECT 181 AS product_id, 11 AS brand_id, 'Razer Ornata V3' AS product_name, 'images/products/razer-ornata-v3.jpg' AS image_url
    UNION ALL SELECT 182 AS product_id, 7 AS brand_id, 'Corsair K55 RGB Pro XT' AS product_name, 'images/products/corsair-k55-rgb-pro-xt.jpg' AS image_url
    UNION ALL SELECT 183 AS product_id, 10 AS brand_id, 'Logitech G102 Lightsync' AS product_name, 'images/products/logitech-g102-lightsync.jpg' AS image_url
    UNION ALL SELECT 184 AS product_id, 11 AS brand_id, 'Razer Cobra' AS product_name, 'images/products/razer-cobra.jpg' AS image_url
    UNION ALL SELECT 185 AS product_id, 7 AS brand_id, 'Corsair Katar Pro XT' AS product_name, 'images/products/corsair-katar-pro-xt.jpg' AS image_url
    UNION ALL SELECT 186 AS product_id, 2 AS brand_id, 'ASUS TUF Gaming M3 Gen II' AS product_name, 'images/products/asus-tuf-gaming-m3-gen-ii.jpg' AS image_url
    UNION ALL SELECT 187 AS product_id, 10 AS brand_id, 'Logitech G304 Lightspeed' AS product_name, 'images/products/logitech-g304-lightspeed.jpg' AS image_url
    UNION ALL SELECT 188 AS product_id, 11 AS brand_id, 'Razer Basilisk V3' AS product_name, 'images/products/razer-basilisk-v3.jpg' AS image_url
    UNION ALL SELECT 189 AS product_id, 7 AS brand_id, 'Corsair Sabre RGB Pro' AS product_name, 'images/products/corsair-sabre-rgb-pro.jpg' AS image_url
    UNION ALL SELECT 190 AS product_id, 2 AS brand_id, 'ASUS ROG Keris Wireless AimPoint' AS product_name, 'images/products/asus-rog-keris-wireless-aimpoint.jpg' AS image_url
    UNION ALL SELECT 191 AS product_id, 10 AS brand_id, 'Logitech G502 X Plus' AS product_name, 'images/products/logitech-g502-x-plus.jpg' AS image_url
    UNION ALL SELECT 192 AS product_id, 11 AS brand_id, 'Razer Viper V3 Pro' AS product_name, 'images/products/razer-viper-v3-pro.jpg' AS image_url
    UNION ALL SELECT 193 AS product_id, 7 AS brand_id, 'Corsair M65 RGB Ultra Wireless' AS product_name, 'images/products/corsair-m65-rgb-ultra-wireless.jpg' AS image_url
    UNION ALL SELECT 194 AS product_id, 2 AS brand_id, 'ASUS ROG Harpe Ace Aim Lab Edition' AS product_name, 'images/products/asus-rog-harpe-ace-aim-lab-edition.jpg' AS image_url
    UNION ALL SELECT 195 AS product_id, 10 AS brand_id, 'Logitech G Pro X Superlight 2' AS product_name, 'images/products/logitech-g-pro-x-superlight-2.jpg' AS image_url
    UNION ALL SELECT 196 AS product_id, 11 AS brand_id, 'Razer Naga V2 Pro' AS product_name, 'images/products/razer-naga-v2-pro.jpg' AS image_url
    UNION ALL SELECT 197 AS product_id, 7 AS brand_id, 'Corsair Dark Core RGB Pro SE' AS product_name, 'images/products/corsair-dark-core-rgb-pro-se.jpg' AS image_url
    UNION ALL SELECT 198 AS product_id, 2 AS brand_id, 'ASUS ROG Chakram X Origin' AS product_name, 'images/products/asus-rog-chakram-x-origin.jpg' AS image_url
    UNION ALL SELECT 199 AS product_id, 10 AS brand_id, 'Logitech MX Master 3S' AS product_name, 'images/products/logitech-mx-master-3s.jpg' AS image_url
    UNION ALL SELECT 200 AS product_id, 11 AS brand_id, 'Razer Orochi V2' AS product_name, 'images/products/razer-orochi-v2.jpg' AS image_url
) catalog ON catalog.product_id = product.product_id
SET product.brand_id = catalog.brand_id,
    product.product_name = catalog.product_name,
    product.description = CONCAT(catalog.product_name, ' chính hãng, bảo hành tại ProBuild PC.'),
    product.image_url = catalog.image_url;

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
(23, 'Chất liệu', 'Kính cường lực'),
(23, 'Số quạt đi kèm', '2'),

(24, 'Kích thước hỗ trợ', 'ATX'),
(24, 'Chất liệu', 'Kính cường lực'),
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

-- Thông số cho sản phẩm mở rộng, sinh theo template sẵn có của từng danh mục.
INSERT INTO PRODUCT_SPECIFICATIONS
(product_id, specification_name, specification_value)
SELECT
    product.product_id,
    template.spec_name,
CASE
        WHEN product.category_id = 1 AND template.spec_name = 'Chân cắm' THEN IF(MOD(product.product_id, 2) = 0, 'AM5', 'LGA1700')
        WHEN product.category_id = 1 AND template.spec_name = 'Hỗ trợ RAM' THEN 'DDR5'
        WHEN product.category_id = 1 AND template.spec_name = 'Số nhân' THEN ELT(product.product_id - 29, '6', '10', '8', '14', '8', '20', '12', '24', '16', '4', '6', '10', '8', '16')
        WHEN product.category_id = 1 AND template.spec_name = 'Số luồng' THEN ELT(product.product_id - 29, '12', '16', '16', '20', '16', '28', '24', '32', '32', '8', '12', '16', '16', '24')
        WHEN product.category_id = 2 AND template.spec_name = 'Chân cắm' THEN IF(MOD(product.product_id, 2) = 0, 'AM5', 'LGA1700')
        WHEN product.category_id = 2 AND template.spec_name = 'Loại RAM' THEN 'DDR5'
        WHEN product.category_id = 2 AND template.spec_name = 'Kích thước bo mạch' THEN ELT(product.product_id - 43, 'ATX', 'Micro-ATX', 'ATX', 'ATX', 'ATX', 'ATX', 'ATX', 'ATX', 'Micro-ATX', 'ATX', 'ATX', 'ATX', 'ATX', 'ATX', 'ATX')
        WHEN product.category_id = 2 AND template.spec_name = 'Giao tiếp GPU' THEN ELT(product.product_id - 43, 'PCIe 4.0', 'PCIe 4.0', 'PCIe 4.0', 'PCIe 5.0', 'PCIe 4.0', 'PCIe 5.0', 'PCIe 5.0', 'PCIe 5.0', 'PCIe 4.0', 'PCIe 5.0', 'PCIe 5.0', 'PCIe 4.0', 'PCIe 5.0', 'PCIe 5.0', 'PCIe 5.0')
        WHEN product.category_id = 3 AND template.spec_name = 'Loại RAM' THEN 'DDR5'
        WHEN product.category_id = 3 AND template.spec_name = 'Dung lượng' THEN ELT(product.product_id - 58, '8GB', '16GB', '16GB', '32GB', '32GB', '32GB', '32GB', '64GB', '64GB', '64GB', '16GB', '32GB', '32GB', '64GB', '32GB', '64GB', '16GB')
        WHEN product.category_id = 3 AND template.spec_name = 'Tốc độ' THEN ELT(product.product_id - 58, '5200MHz', '5200MHz', '5600MHz', '6000MHz', '6000MHz', '6200MHz', '5200MHz', '5600MHz', '6000MHz', '6600MHz', '4800MHz', '5600MHz', '5600MHz', '6000MHz', '6000MHz', '5600MHz', '6400MHz')
        WHEN product.category_id = 4 AND template.spec_name = 'Giao tiếp' THEN 'PCIe 4.0'
        WHEN product.category_id = 4 AND template.spec_name = 'Bộ nhớ đồ họa' THEN ELT(product.product_id - 75, '8GB', '8GB', '8GB', '12GB', '12GB', '12GB', '16GB', '16GB', '16GB', '16GB', '16GB', '16GB', '24GB', '24GB', '24GB', '16GB')
        WHEN product.category_id = 5 AND template.spec_name = 'Loại kết nối' THEN ELT(product.product_id - 91, 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 3.0', 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 5.0', 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 5.0', 'SATA III', 'SATA III', 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 4.0', 'NVMe M.2 PCIe 4.0', 'SATA III', 'SATA III', 'NVMe M.2 PCIe 5.0')
        WHEN product.category_id = 5 AND template.spec_name = 'Dung lượng' THEN ELT(product.product_id - 91, '1TB', '1TB', '1TB', '500GB', '1TB', '2TB', '1TB', '2TB', '2TB', '1TB', '480GB', '1TB', '2TB', '2TB', '1TB', '2TB', '2TB', '2TB')
        WHEN product.category_id = 5 AND template.spec_name = 'Tốc độ đọc' THEN ELT(product.product_id - 91, '7450 MB/s', '3500 MB/s', '5000 MB/s', '3100 MB/s', '7000 MB/s', '7100 MB/s', '5000 MB/s', '7300 MB/s', '12400 MB/s', '560 MB/s', '500 MB/s', '7000 MB/s', '7450 MB/s', '6000 MB/s', '4800 MB/s', '560 MB/s', '550 MB/s', '10000 MB/s')
        WHEN product.category_id = 5 AND template.spec_name = 'Tốc độ ghi' THEN ELT(product.product_id - 91, '6900 MB/s', '2100 MB/s', '4400 MB/s', '2600 MB/s', '6000 MB/s', '6800 MB/s', '4200 MB/s', '7000 MB/s', '11800 MB/s', '530 MB/s', '450 MB/s', '6500 MB/s', '6900 MB/s', '5000 MB/s', '4800 MB/s', '530 MB/s', '520 MB/s', '8500 MB/s')
        WHEN product.category_id = 6 AND template.spec_name = 'Công suất' THEN ELT(product.product_id - 109, '550W', '650W', '650W', '750W', '650W', '750W', '750W', '850W', '750W', '850W', '850W', '1000W', '1000W', '1200W', '1000W', '1200W', '850W', '550W')
        WHEN product.category_id = 6 AND template.spec_name = 'Chuẩn hiệu suất' THEN ELT(product.product_id - 109, '80 Plus Bronze', '80 Plus Gold', '80 Plus Bronze', '80 Plus Bronze', '80 Plus Bronze', '80 Plus Gold', '80 Plus Gold', '80 Plus Gold', '80 Plus Gold', '80 Plus Gold', '80 Plus Gold', '80 Plus Gold', '80 Plus Gold', '80 Plus Platinum', '80 Plus Platinum', '80 Plus Platinum', '80 Plus Gold', '80 Plus Bronze')
        WHEN product.category_id = 6 AND template.spec_name = 'Loại dây cáp' THEN ELT(product.product_id - 109, 'Non-Modular', 'Full-Modular', 'Non-Modular', 'Non-Modular', 'Non-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Full-Modular', 'Non-Modular')
        WHEN product.category_id = 7 AND template.spec_name = 'Kích thước hỗ trợ' THEN ELT(product.product_id - 127, 'ATX', 'ATX', 'ATX', 'Micro-ATX', 'ATX', 'ATX', 'ATX', 'ATX', 'E-ATX', 'ATX', 'Micro-ATX', 'E-ATX', 'ATX', 'E-ATX', 'ATX', 'ATX', 'Micro-ATX', 'ATX')
        WHEN product.category_id = 7 AND template.spec_name = 'Chất liệu' THEN ELT(product.product_id - 127, 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực', 'Kính cường lực')
        WHEN product.category_id = 7 AND template.spec_name = 'Số quạt đi kèm' THEN ELT(product.product_id - 127, '2', '2', '2', '0', '2', '3', '4', '3', '3', '2', '4', '4', '3', '3', '4', '0', '2', '2')
        WHEN product.category_id = 8 AND template.spec_name = 'Kích thước' THEN ELT(product.product_id - 145, '24 inch', '24 inch', '24 inch', '24 inch', '24.5 inch', '24 inch', '27 inch', '27 inch', '27 inch', '27 inch', '27 inch', '27 inch', '26.5 inch', '26.5 inch', '26.5 inch', '31.5 inch', '31.5 inch', '32 inch')
        WHEN product.category_id = 8 AND template.spec_name = 'Độ phân giải' THEN ELT(product.product_id - 145, 'Full HD', 'Full HD', 'Full HD', 'Full HD', 'Full HD', 'Full HD', 'Full HD', '2K QHD', '4K UHD', '2K QHD', '2K QHD', '2K QHD', '2K QHD', '2K QHD', '2K QHD', '4K UHD', '4K UHD', '4K UHD')
        WHEN product.category_id = 8 AND template.spec_name = 'Tấm nền' THEN ELT(product.product_id - 145, 'IPS', 'IPS', 'IPS', 'IPS', 'IPS', 'IPS', 'IPS', 'IPS', 'IPS', 'IPS', 'IPS', 'IPS', 'QD-OLED', 'OLED', 'QD-OLED', 'QD-OLED', 'IPS', 'IPS')
        WHEN product.category_id = 8 AND template.spec_name = 'Tần số quét' THEN ELT(product.product_id - 145, '60Hz', '100Hz', '100Hz', '180Hz', '280Hz', '180Hz', '180Hz', '170Hz', '60Hz', '180Hz', '180Hz', '240Hz', '360Hz', '240Hz', '360Hz', '240Hz', '60Hz', '60Hz')
        WHEN product.category_id = 8 AND template.spec_name = 'Cổng kết nối' THEN 'HDMI, DisplayPort'
        WHEN product.category_id = 9 AND template.spec_name = 'Loại switch' THEN ELT(product.product_id - 163, 'Mechanical Brown', 'Mechanical Blue', 'Mechanical Red', 'Mechanical Red', 'Mechanical Brown', 'Optical', 'Mechanical Red', 'Optical', 'Mechanical Brown', 'Optical', 'Optical', 'Mechanical Red', 'Mechanical Red', 'Mechanical Brown', 'Mechanical Red', 'Mechanical Red', 'Mechanical Brown', 'Membrane', 'Membrane')
        WHEN product.category_id = 9 AND template.spec_name = 'Kết nối' THEN ELT(product.product_id - 163, 'USB', 'USB', 'USB', 'USB + Bluetooth', 'Wireless 2.4G', 'USB', 'USB', 'USB + Bluetooth', 'Wireless 2.4G', 'Wireless 2.4G', 'USB', 'USB', 'Wireless 2.4G', 'USB', 'USB', 'USB + Bluetooth', 'Bluetooth', 'USB', 'USB')
        WHEN product.category_id = 9 AND template.spec_name = 'Layout' THEN ELT(product.product_id - 163, 'Full-size', 'Full-size', 'Full-size', '96%', 'TKL', 'TKL', '60%', '65%', 'TKL', 'TKL', 'Full-size', 'TKL', 'TKL', '75%', 'Full-size', '75%', 'Full-size', 'Full-size', 'Full-size')
        WHEN product.category_id = 10 AND template.spec_name = 'Kết nối' THEN ELT(product.product_id - 182, 'USB', 'USB', 'USB', 'USB', 'Wireless 2.4G', 'USB', 'USB', 'Wireless 2.4G', 'Wireless 2.4G', 'Wireless 2.4G', 'Wireless 2.4G', 'Wireless 2.4G', 'Wireless 2.4G', 'Wireless 2.4G', 'Wireless 2.4G', 'Wireless 2.4G', 'Bluetooth', 'Wireless 2.4G')
        WHEN product.category_id = 10 AND template.spec_name = 'DPI tối đa' THEN ELT(product.product_id - 182, '8000', '8500', '18000', '8000', '12000', '26000', '18000', '36000', '25600', '35000', '26000', '36000', '32000', '30000', '18000', '36000', '8000', '18000')
        WHEN product.category_id = 10 AND template.spec_name = 'Trọng lượng' THEN ELT(product.product_id - 182, '85g', '58g', '73g', '59g', '99g', '101g', '74g', '75g', '106g', '54g', '110g', '54g', '60g', '134g', '133g', '127g', '141g', '60g')
        ELSE 'N/A'
    END
FROM PRODUCTS product
JOIN CATEGORY_SPEC_TEMPLATES template ON template.category_id = product.category_id
WHERE product.product_id BETWEEN 30 AND 200;

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
(batch_item_id, batch_id, product_id, import_quantity, quantity, price)
VALUES
(1, 1, 1, 20, 20, 4800000),
(2, 1, 2, 15, 15, 7300000),
(3, 1, 7, 10, 10, 10200000),

(4, 2, 3, 25, 25, 3600000),
(5, 2, 8, 12, 12, 9200000),
(6, 2, 9, 8, 8, 13200000),

(7, 3, 4, 10, 10, 3200000),
(8, 3, 10, 8, 8, 5100000),
(9, 3, 11, 10, 10, 4000000),

(10, 4, 12, 15, 15, 2700000),
(11, 4, 13, 10, 10, 4500000),

(12, 5, 5, 30, 30, 1200000),
(13, 5, 14, 20, 20, 2350000),
(14, 5, 15, 10, 10, 5100000),

(16, 6, 6, 8, 8, 8300000),
(17, 6, 16, 6, 6, 14500000),
(18, 6, 17, 4, 4, 19500000),
(19, 6, 18, 3, 3, 29800000);

-- Tồn kho cho toàn bộ sản phẩm mở rộng để có thể hiển thị và bán ngay.
INSERT INTO BATCH (batch_id, batch_name, `date`)
VALUES (7, 'Lô mở rộng catalog 2026', '2026-03-01');

INSERT INTO BATCH_ITEMS
(batch_item_id, batch_id, product_id, import_quantity, quantity, price)
SELECT
    product.product_id + 100,
    7,
    product.product_id,
    12 + MOD(product.product_id, 19),
    12 + MOD(product.product_id, 19),
    ROUND(product.price * 0.82, 0)
FROM PRODUCTS product
WHERE product.product_id BETWEEN 19 AND 200;

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

(10012, 1, 2, '2026-05-09 16:05:00', 19300000,
'Khu Công nghệ cao Hòa Lạc, Thạch Thất, Hà Nội',
'COD', 'Chưa thanh toán', 'Đơn hàng đã xác nhận trong năm 2026', NULL),

(10013, 2, 4, '2026-06-10 09:55:00', 14800000,
'Đại học FPT Hà Nội, Khu Công nghệ cao Hòa Lạc, Hà Nội',
'COD', 'Chưa thanh toán', 'Đơn hàng COD đang giao trong năm 2026', NULL);

INSERT INTO ORDER_DETAILS
(order_detail_id, order_id, product_id, quantity, unit_price, warranty_months, subtotal)
VALUES
(1, 10000, 1, 1, 5500000, 36, 5500000),
(2, 10000, 5, 2, 1500000, 60, 3000000),

(3, 10001, 3, 1, 4200000, 36, 4200000),
(4, 10001, 6, 1, 9500000, 36, 9500000),

(5, 10002, 1, 1, 5500000, 36, 5500000),
(6, 10002, 5, 2, 1500000, 60, 3000000),

(7, 10003, 3, 1, 4200000, 36, 4200000),
(8, 10003, 12, 1, 3200000, 36, 3200000),
(9, 10003, 5, 1, 1500000, 60, 1500000),

(10, 10004, 6, 1, 9500000, 36, 9500000),

(11, 10005, 8, 1, 10500000, 36, 10500000),
(12, 10005, 14, 1, 2800000, 60, 2800000),

(13, 10006, 2, 1, 8500000, 36, 8500000),
(14, 10006, 4, 1, 3800000, 36, 3800000),
(15, 10006, 5, 2, 1500000, 60, 3000000),

(16, 10007, 16, 1, 16500000, 36, 16500000),
(17, 10007, 10, 1, 5900000, 36, 5900000),

(18, 10008, 7, 1, 11900000, 36, 11900000),
(19, 10008, 13, 1, 5200000, 36, 5200000),
(20, 10008, 14, 1, 2800000, 60, 2800000),

(21, 10009, 9, 1, 14900000, 36, 14900000),
(22, 10009, 15, 1, 5900000, 60, 5900000),

(23, 10010, 17, 1, 21900000, 36, 21900000),
(24, 10010, 11, 1, 4700000, 36, 4700000),
(25, 10010, 5, 2, 1500000, 60, 3000000),

(26, 10011, 18, 1, 32900000, 36, 32900000),
(27, 10011, 15, 1, 5900000, 60, 5900000),

(28, 10012, 8, 1, 10500000, 36, 10500000),
(29, 10012, 12, 1, 3200000, 36, 3200000),
(30, 10012, 14, 2, 2800000, 60, 5600000),

(31, 10013, 6, 1, 9500000, 36, 9500000),
(32, 10013, 4, 1, 3800000, 36, 3800000),
(33, 10013, 5, 1, 1500000, 60, 1500000);

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
(warranty_id, customer_id, order_id, product_id, status_id, request_date, request)
VALUES
(1, 1, 10000, 1, 2, '2026-03-01 10:30:00',
'CPU có nhiệt độ cao hơn mong đợi khi chơi game, cần kiểm tra bảo hành.'),

(2, 2, 10003, 12, 1, '2026-06-01 16:45:00',
'Cổng USB trên bo mạch chủ hoạt động không ổn định, cần kiểm tra.');

