# Hướng Dẫn Chi Tiết: Bố Cục & Các Bước Triển Khai Code Từ Sơ Đồ Cây (Tree Structure)

Tài liệu này phân tích chi tiết cấu trúc sơ đồ cây (Tree UI-Flow) của dự án **PC Shop**, giải thích rõ ràng bố cục của từng nhánh và hướng dẫn lập trình viên/AI các bước cụ thể cần phải làm để hoàn thiện mã nguồn cho từng chức năng.

---

## 1. TỔNG QUAN BỐ CỤC HỆ THỐNG
Hệ thống được chia thành 2 phân vùng giao diện lớn dựa trên đối tượng sử dụng:
1.  **Phân vùng Khách hàng (Home Page - Public & Customer):** Nằm bên ngoài hệ thống, phục vụ khách vãng lai và khách mua hàng trực tuyến.
2.  **Phân vùng Quản trị (Dashboard - Admin, Employee, Transport):** Nằm sau lớp bảo mật đăng nhập, phục vụ việc vận hành doanh nghiệp.

---

## 2. CHI TIẾT CÁC NHÁNH PHẢI TRIỂN KHAI

### NHÁNH 1: HOME PAGE (Giao Diện Khách Hàng)

Nhánh này tập trung vào trải nghiệm mua sắm mượt mà, tối ưu SEO, tìm kiếm và tính năng đặc trưng "Tự cấu hình máy tính".

#### 1. Nhóm Xem Sản Phẩm & Đánh Giá
* **Màn hình cần làm:** `Product List` (Danh sách) và `Product Detail` (Chi tiết).
* **Công việc cụ thể phải làm:**
    * **UI/UX:** Thiết kế bộ lọc (Filter) theo Khoảng giá, Thương hiệu, Danh mục linh kiện. Thêm tính năng Phân trang (Pagination) và Sắp xếp (Sort theo giá tăng/giảm, bán chạy).
    * **Logic (API):** Code API lấy danh sách sản phẩm có truyền kèm tham số filter. API chi tiết sản phẩm phải lấy thêm danh sách `Feedback` liên quan.
    * **Chức năng Feedback:** Chỉ cho phép người dùng đã mua sản phẩm đó đánh giá (Form gồm số sao và bình luận).

#### 2. Nhóm Giỏ Hàng & Thanh Toán (Luồng Mua Hàng Chính)
* **Màn hình cần làm:** `Cart` -> `Checkout`.
* **Công việc cụ thể phải làm:**
    * **Giỏ hàng (Cart):** Lưu thông tin sản phẩm khách chọn vào LocalStorage (nếu chưa login) hoặc đồng bộ vào DB (nếu đã login). Code chức năng tăng/giảm số lượng, xóa sản phẩm và tính tổng tiền realtime.
    * **Thanh toán (Checkout):** Tạo form nhập thông tin người nhận (Tên, SĐT, Địa chỉ giao hàng). Tích hợp 2 phương thức thanh toán: COD (Tiền mặt) và Online (VNPAY Gateway). Nếu chọn VNPAY, phải viết mã băm checksum bảo mật và callback URL để nhận kết quả trả về.

#### 3. Tính Năng Đặc Biệt: Build PC (Tự cấu hình máy)
* **Màn hình cần làm:** `Build PC` -> `Compatible Components`.
* **Công việc cụ thể phải làm:**
    * **Thuật toán lọc linh kiện (Quan trọng):** Khi khách chọn Mainboard hoặc CPU trước, hệ thống phải tự động lọc các linh kiện còn lại dựa trên tính tương thích (Ví dụ: Cùng loại Socket, cùng chuẩn RAM DDR4/DDR5).
    * **Giao diện:** Thiết kế giao diện hiển thị theo từng hàng (CPU, Main, RAM, SSD, VGA, Nguồn, Vỏ case). Mỗi hàng có nút "Chọn" để mở pop-up danh sách linh kiện tương thích, có hiển thị giá tiền và tổng tiền cộng dồn bên dưới.
    * **Kết thúc luồng:** Nút "Thêm toàn bộ vào giỏ hàng" để chuyển tất cả linh kiện đã chọn vào `Cart`.

#### 4. Nhóm Tài Khoản & Bảo Hành của Khách Hàng
* **Màn hình cần làm:** `Register`, `Login`, `Forget Password`, `User Profile`, `My Order`, `Warranty Check`.
* **Công việc cụ thể phải làm:**
    * **Xác thực:** Mã hóa mật khẩu bằng Bcrypt trước khi lưu. Thiết kế luồng quên mật khẩu gửi mã OTP/Token qua Email.
    * **Lịch sử đơn hàng (My Order):** Xem trạng thái đơn hàng (Chờ duyệt, Đang giao, Thành công). Khi click vào một đơn hàng, xem được `Order Detail` và bấm nút "Gửi yêu cầu bảo hành" nếu sản phẩm bị lỗi.
    * **Tra cứu bảo hành (Warranty Check):** Cho phép nhập Mã đơn hàng + Mã sản phẩm để kiểm tra thời hạn và trạng thái bảo hành trực tiếp mà không cần đăng nhập phức tạp.

---

### NHÁNH 2: DASHBOARD (Giao Diện Quản Trị)

Nhánh này đòi hỏi tính bảo mật cao, phân quyền chặt chẽ (Role-based Access Control - RBAC) bằng Token/Session.

#### 1. Quản Lý Tài Khoản (Dành riêng cho Admin)
* **Màn hình cần làm:** `Manage Accounts` -> `User List` -> `New User` / `User Detail`.
* **Công việc cụ thể phải làm:** Code bảng hiển thị toàn bộ người dùng trong hệ thống. Cho phép Admin khóa/mở khóa tài khoản (Active/Inactive), đổi vai trò của nhân viên (Employee, Transport).

#### 2. Quản Lý Dữ Liệu Gốc (Sản phẩm, Danh mục, Thương hiệu, Lô hàng)
* **Màn hình cần làm:** `Product`, `Category`, `Brand`, `Batch Management`.
* **Công việc cụ thể phải làm:**
    * **Sản phẩm:** Form thêm/sửa sản phẩm với đầy đủ trường thông tin và thông số kỹ thuật (Spec kỹ thuật rất quan trọng để phục vụ tính năng Build PC).
    * **Danh mục & Thương hiệu:** Thiết kế giao diện CRUD (Thêm, Sửa, Xóa) tích hợp gọn gàng trên cùng một màn hình (Table + Modal) để tối ưu trải nghiệm.
    * **Quản lý Lô hàng (Batch):** Lưu vết các đợt nhập hàng (Ngày nhập, Giá nhập, Số lượng). Khi thêm một lô hàng mới, hệ thống phải tự động cộng dồn số lượng vào tổng tồn kho của sản phẩm đó trong Database.

#### 3. Quản Lý Đơn Hàng & Vận Chuyển (Admin + Transport)
* **Màn hình cần làm:** `Order Management` -> `Order List`.
* **Công việc cụ thể phải làm:**
    * **Admin:** Duyệt đơn hàng mới, phân công đơn hàng cho nhân viên vận chuyển (`Transport`).
    * **Transport:** Xem danh sách các đơn hàng mình được giao. Khi đi giao hàng thực tế, sử dụng giao diện này để bấm cập nhật trạng thái đơn sang: *Đang giao*, *Giao thành công* hoặc *Thất bại/Hoàn trả*.

#### 4. Quản Lý Bảo Hành & Chăm Sóc Khách Hàng (Employee)
* **Màn hình cần làm:** `Warranty Management`, `Feedback Management`.
* **Công việc cụ thể phải làm:**
    * **Bảo hành:** Tiếp nhận các yêu cầu bảo hành gửi từ khách hàng. Nhân viên kiểm tra sản phẩm thực tế và cập nhật trạng thái xử lý (*Đang sửa, Đã đổi mới, Đã hoàn trả khách, Từ chối bảo hành*).
    * **Feedback:** Xem danh sách các đánh giá của khách hàng về sản phẩm để kiểm soát chất lượng dịch vụ.

#### 5. Báo Cáo Doanh Thu (Admin)
* **Màn hình cần làm:** `Revenue Report`.
* **Công việc cụ thể phải làm:** Vẽ biểu đồ doanh thu (Dùng Chart.js hoặc Recharts) thống kê theo ngày, tháng, năm. Viết tính năng kết xuất dữ liệu (Export) ra file Excel/CSV để lưu trữ nội bộ.

---

## 3. THỨ TỰ ƯU TIÊN KHI LẬP TRÌNH (ROADMAP)

Để dự án chạy mượt mà, bạn nên hướng dẫn AI hoặc đội ngũ code theo thứ tự "Xây móng trước, xây nhà sau" như sau:

1.  **Giai đoạn 1 (Database & Auth):** Thiết kế toàn bộ Database Schema -> Code các API Đăng ký, Đăng nhập, Phân quyền.
2.  **Giai đoạn 2 (Dữ liệu nền tảng):** Làm các trang Admin trước (`Category`, `Brand`, `Product Management`) để có dữ liệu đổ ra trang chủ.
3.  **Giai đoạn 3 (Giao diện mua sắm công khai):** Làm `Homepage`, `Product List`, `Product Detail`, `Cart`.
4.  **Giai đoạn 4 (Nghiệp vụ cốt lõi):** Làm tính năng `Build PC` (Cần kết nối chặt chẽ dữ liệu thông số kỹ thuật của sản phẩm ở Giai đoạn 2).
5.  **Giai đoạn 5 (Thanh toán & Vận hành):** Làm luồng `Checkout` (Tích hợp VNPAY) -> Màn hình `Order Management` của Admin/Transport -> Cuối cùng là `Warranty` và `Revenue Report`.