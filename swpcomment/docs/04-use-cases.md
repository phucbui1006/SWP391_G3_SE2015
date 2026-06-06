# Danh sách Mô tả Use Case (Use Case Descriptions) - Dự án PC Shop

Dưới đây là mô tả chi tiết các Use Case chính cho các Actor: Customer, Admin, Employee và Transport, dựa trên luồng chức năng của hệ thống.

---

## 1. Các Use Case Chung (Common)

### Login (Đăng nhập)
**Actor**
Customer, Admin, Employee, Transport

**Flow**
1. Người dùng chọn chức năng Đăng nhập.
2. Nhập Email / Username.
3. Nhập Password.
4. Click nút "Login".
5. Hệ thống xác thực thông tin tài khoản.
6. Đăng nhập thành công (Hệ thống chuyển hướng tới Home Page đối với Customer, hoặc Dashboard đối với Admin/Employee/Transport).

### Manage Personal Information (Quản lý thông tin cá nhân)
**Actor**
Customer, Admin, Employee, Transport

**Flow**
1. Người dùng truy cập trang Profile.
2. Chỉnh sửa thông tin cá nhân (Tên, Số điện thoại, Địa chỉ) hoặc chọn Đổi mật khẩu.
3. Click "Lưu thay đổi".
4. Hệ thống kiểm tra tính hợp lệ của dữ liệu.
5. Hệ thống cập nhật thông tin thành công.

---

## 2. Dành cho Customer (Khách hàng)

### Register (Đăng ký tài khoản)
**Actor**
Customer

**Flow**
1. Khách hàng chọn chức năng Đăng ký.
2. Nhập các thông tin bắt buộc (Họ tên, Email, Mật khẩu, Xác nhận mật khẩu).
3. Click "Register".
4. Hệ thống kiểm tra Email đã tồn tại hay chưa.
5. Hệ thống lưu tài khoản mới.
6. Đăng ký thành công và chuyển hướng về trang Đăng nhập.

### Add to Cart (Thêm sản phẩm vào giỏ)
**Actor**
Customer

**Flow**
1. Khách hàng xem danh sách sản phẩm hoặc chi tiết sản phẩm.
2. Chọn số lượng và các tùy chọn (nếu có).
3. Click "Add to Cart".
4. Hệ thống kiểm tra số lượng tồn kho.
5. Hệ thống thêm sản phẩm vào giỏ hàng hiện tại.
6. Hiển thị thông báo thêm thành công.

### Checkout / Payment (Thanh toán đơn hàng)
**Actor**
Customer

**Flow**
1. Khách hàng truy cập Giỏ hàng (Cart) và click "Thanh toán".
2. Hệ thống hiển thị form nhập thông tin giao hàng và chọn phương thức thanh toán.
3. Khách hàng điền thông tin và xác nhận.
4. Click "Đặt hàng".
5. Hệ thống xử lý thanh toán (nếu thanh toán online) hoặc ghi nhận thanh toán COD.
6. Hệ thống trừ số lượng tồn kho và tạo đơn hàng thành công.

### Build PC (Tự cấu hình máy tính)
**Actor**
Customer

**Flow**
1. Khách hàng chọn chức năng "Build PC".
2. Hệ thống hiển thị danh sách các nhóm linh kiện (CPU, Mainboard, RAM, VGA...).
3. Khách hàng chọn linh kiện, hệ thống tự động lọc và gợi ý các linh kiện tương thích (Compatible Components).
4. Khách hàng xem tổng giá trị cấu hình.
5. Click "Thêm tất cả vào giỏ hàng".
6. Hệ thống chuyển các linh kiện đã chọn vào giỏ.

### Warranty Request (Gửi yêu cầu bảo hành)
**Actor**
Customer

**Flow**
1. Khách hàng vào danh sách "Order History" (Lịch sử đơn hàng).
2. Chọn sản phẩm cần bảo hành và click "Yêu cầu bảo hành".
3. Nhập lý do, tình trạng lỗi và đính kèm hình ảnh (nếu có).
4. Click "Gửi yêu cầu".
5. Hệ thống lưu yêu cầu với trạng thái "Chờ xử lý".

---

## 3. Dành cho Admin (Quản trị viên)

### Product Management (Quản lý Sản phẩm)
**Actor**
Admin

**Flow**
1. Admin truy cập Dashboard -> Product List.
2. Click "Thêm sản phẩm mới" (hoặc chọn "Sửa" một sản phẩm có sẵn).
3. Nhập thông tin: Tên, Hình ảnh, Danh mục, Thương hiệu, Giá, Mô tả, Số lượng.
4. Click "Lưu".
5. Hệ thống kiểm tra và cập nhật dữ liệu vào cơ sở dữ liệu.
6. Hiển thị thông báo thành công.

### Manage Accounts (Quản lý Tài khoản)
**Actor**
Admin

**Flow**
1. Admin truy cập Dashboard -> User List.
2. Chọn "Thêm tài khoản mới" hoặc click vào một tài khoản để "Sửa/Khóa".
3. Thay đổi thông tin hoặc phân quyền (Customer, Employee, Transport).
4. Click "Lưu".
5. Hệ thống cập nhật quyền hạn/trạng thái tài khoản thành công.

### Export Revenue Report (Xuất báo cáo doanh thu)
**Actor**
Admin

**Flow**
1. Admin truy cập Dashboard -> Revenue Report.
2. Chọn khoảng thời gian cần thống kê (Ngày/Tháng/Năm).
3. Hệ thống hiển thị biểu đồ và số liệu tổng quan.
4. Click "Export Report".
5. Hệ thống trích xuất dữ liệu và tải xuống file (Excel/CSV/PDF) thành công.

---

## 4. Dành cho Employee (Nhân viên bảo hành/chăm sóc)

### Update Warranty Status (Cập nhật trạng thái bảo hành)
**Actor**
Employee

**Flow**
1. Employee truy cập Dashboard -> Quản lý bảo hành (Warranty Management).
2. Xem danh sách các yêu cầu bảo hành từ khách hàng.
3. Click vào một yêu cầu để xem chi tiết.
4. Chọn cập nhật trạng thái mới (Ví dụ: Đang kiểm tra, Đang sửa chữa, Đã hoàn thành, Từ chối).
5. Nhập ghi chú (nếu có) và click "Cập nhật".
6. Hệ thống lưu trạng thái và có thể gửi email/thông báo cho Customer.

---

## 5. Dành cho Transport (Nhân viên Vận chuyển)

### Update Order Status (Cập nhật trạng thái giao hàng)
**Actor**
Transport

**Flow**
1. Transport truy cập Dashboard -> Order List (Danh sách đơn hàng được phân công).
2. Click xem chi tiết đơn hàng (Địa chỉ, Số điện thoại người nhận).
3. Thực hiện quá trình giao hàng thực tế.
4. Chọn cập nhật trạng thái trên hệ thống (Đang lấy hàng, Đang giao, Giao thành công, Hoàn trả).
5. Click "Lưu cập nhật".
6. Hệ thống ghi nhận trạng thái mới của đơn hàng.