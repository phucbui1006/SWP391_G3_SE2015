<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>

<%!
    private static class BuildPart {
        final String category;
        final String icon;
        final String image;
        final String name;
        final String description;
        final long price;

        BuildPart(String category, String icon, String image, String name, String description, long price) {
            this.category = category;
            this.icon = icon;
            this.image = image;
            this.name = name;
            this.description = description;
            this.price = price;
        }
    }
%>

<%
    String ctx = request.getContextPath();
    Locale vietnameseLocale = new Locale("vi", "VN");
    NumberFormat currencyFormatter = NumberFormat.getNumberInstance(vietnameseLocale);
    currencyFormatter.setMinimumFractionDigits(0);
    currencyFormatter.setMaximumFractionDigits(0);

    BuildPart[] parts = new BuildPart[] {
        new BuildPart("CPU", "▣", "images/products/intel-core-i7-13700k.jpg", "Intel Core i5-14600KF", "14 nhân 20 luồng, up to 5.3GHz, 24MB Cache", 6590000),
        new BuildPart("MAINBOARD", "▤", "images/products/asus-tuf-b760m.jpg", "ASUS TUF GAMING B760M-PLUS WIFI DDR5", "Micro-ATX, Socket LGA1700, Intel B760, 4 x DDR5", 4290000),
        new BuildPart("RAM", "▰", "images/products/kingston-fury-32gb.jpg", "G.Skill Ripjaws S5 16GB (2x8GB) DDR5 5600MHz", "DDR5, 16GB (2x8GB), 5600MHz, Black", 1990000),
        new BuildPart("VGA", "▧", "images/products/msi-rtx-4060-ventus-2x.jpg", "ASUS Dual GeForce RTX 4060 OC 8GB GDDR6", "8GB GDDR6, 128-bit, HDMI + DP", 8990000),
        new BuildPart("SSD", "▯", "images/products/kingston-fury-beast-16gb-ddr5.jpg", "Western Digital Blue SN580 1TB NVMe PCIe 4.0", "M.2 NVMe PCIe 4.0, 1TB, đọc 4150MB/s, ghi 4150MB/s", 2190000),
        new BuildPart("NGUỒN (PSU)", "◈", "images/products/asus-prime-b650m-a.jpg", "Corsair CV650 650W 80 Plus Bronze", "650W, 80 Plus Bronze, Non Modular", 1490000),
        new BuildPart("CASE", "▥", "images/products/gigabyte-b760m-ds3h.jpg", "Deepcool CH370 Black", "Mid Tower, ATX, M-ATX, ITX", 1290000),
        new BuildPart("TẢN NHIỆT", "❄", "images/products/amd-ryzen-5-7600.jpg", "Deepcool AK400", "Tản khí, 1 fan 120mm, 4 ống đồng", 690000)
    };

    long total = 0;
    for (BuildPart part : parts) {
        total += part.price;
    }
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Build PC - ProBuild PC</title>
        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
        <link rel="stylesheet" href="<%= ctx %>/css/build-pc.css">
    </head>

    <body class="build-pc-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="build-pc-shell">
            <section class="build-pc-main">
                <div class="build-pc-heading">
                    <div>
                        <h1>BUILD PC</h1>
                        <p>Tự tay lựa chọn linh kiện để tạo nên cấu hình PC theo nhu cầu của bạn.</p>
                    </div>
                </div>

                <div class="build-part-list">
                    <% for (BuildPart part : parts) { %>
                    <article class="build-part-row" data-build-part data-unit-price="<%= part.price %>">
                        <div class="build-part-type">
                            <span class="build-part-icon" aria-hidden="true"><%= part.icon %></span>
                            <strong><%= part.category %></strong>
                        </div>

                        <div class="build-part-product">
                            <img src="<%= ctx %>/<%= part.image %>" alt="<%= part.name %>">
                            <div>
                                <h2><%= part.name %></h2>
                                <strong data-line-price><%= currencyFormatter.format(part.price) %>đ</strong>
                            </div>
                        </div>

                        <div class="build-quantity">
                            <button class="build-qty-btn" type="button" data-qty-minus aria-label="Giảm số lượng <%= part.category %>">−</button>
                            <input class="build-qty-input" type="number" value="1" min="1" step="1" inputmode="numeric" aria-label="Số lượng <%= part.category %>" data-qty-input>
                            <button class="build-qty-btn" type="button" data-qty-plus aria-label="Tăng số lượng <%= part.category %>">+</button>
                        </div>

                        <div class="build-part-actions">
                            <a class="build-change-btn" href="#">
                                <span aria-hidden="true">✎</span>
                                Thay đổi
                            </a>
                            <button class="build-delete-btn" type="button" title="Xóa linh kiện <%= part.category %>">
                                <span aria-hidden="true">×</span>
                                Xóa
                            </button>
                        </div>
                    </article>
                    <% } %>
                </div>

                <button class="build-add-more" type="button">
                    <span aria-hidden="true">+</span>
                    Thêm linh kiện khác (Tùy chọn)
                </button>
            </section>

            <aside class="build-summary">
                <div class="build-summary-card">
                    <h2>TỔNG TIỀN</h2>
                    <strong class="build-total" data-build-total><%= currencyFormatter.format(total) %>đ</strong>

                    <div class="build-cart-action">
                        <button class="build-cart-btn" type="button">
                            <span aria-hidden="true">🛒</span>
                            Thêm cấu hình vào giỏ hàng
                        </button>
                    </div>

                    <div class="build-benefits">
                        <div>
                            <span aria-hidden="true">ⓘ</span>
                            <strong>Tư vấn miễn phí</strong>
                            <small>Hỗ trợ 24/7</small>
                        </div>
                        <div>
                            <span aria-hidden="true">♢</span>
                            <strong>Bảo hành chính hãng</strong>
                            <small>Đầy đủ</small>
                        </div>
                        <div>
                            <span aria-hidden="true">▱</span>
                            <strong>Giao hàng toàn quốc</strong>
                            <small>Nhanh chóng</small>
                        </div>
                    </div>
                </div>
            </aside>
        </main>

        <jsp:include page="/includes/footer.jsp" />

        <script>
            (function () {
                const rows = document.querySelectorAll('[data-build-part]');
                const totalElement = document.querySelector('[data-build-total]');
                const formatter = new Intl.NumberFormat('vi-VN', {
                    minimumFractionDigits: 0,
                    maximumFractionDigits: 0
                });

                const formatCurrency = function (amount) {
                    return formatter.format(Math.round(amount)) + 'đ';
                };

                const normalizeQuantity = function (input) {
                    let quantity = parseInt(input.value, 10);

                    if (Number.isNaN(quantity) || quantity < 1) {
                        quantity = 1;
                    }

                    input.value = quantity;
                    return quantity;
                };

                const updateTotals = function () {
                    let total = 0;

                    rows.forEach(function (row) {
                        const unitPrice = Number(row.dataset.unitPrice) || 0;
                        const input = row.querySelector('[data-qty-input]');
                        const linePrice = row.querySelector('[data-line-price]');
                        const quantity = normalizeQuantity(input);
                        const lineTotal = unitPrice * quantity;

                        total += lineTotal;

                        if (linePrice) {
                            linePrice.textContent = formatCurrency(lineTotal);
                        }
                    });

                    if (totalElement) {
                        totalElement.textContent = formatCurrency(total);
                    }
                };

                rows.forEach(function (row) {
                    const input = row.querySelector('[data-qty-input]');
                    const minusButton = row.querySelector('[data-qty-minus]');
                    const plusButton = row.querySelector('[data-qty-plus]');

                    if (!input || !minusButton || !plusButton) {
                        return;
                    }

                    minusButton.addEventListener('click', function () {
                        input.value = Math.max(1, normalizeQuantity(input) - 1);
                        updateTotals();
                    });

                    plusButton.addEventListener('click', function () {
                        input.value = normalizeQuantity(input) + 1;
                        updateTotals();
                    });

                    input.addEventListener('input', updateTotals);
                    input.addEventListener('change', updateTotals);
                });

                updateTotals();
            })();
        </script>
    </body>
</html>
