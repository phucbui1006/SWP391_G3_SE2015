<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC</title>
        <link rel="stylesheet" href="../css/style.css">
    </head>
    <body class="home-page">
        <div class="top-strip"></div>

        <header class="site-header">
            <div class="header-inner">
                <a class="brand" href="home.jsp" aria-label="ProBuild PC">
                    <span class="brand-mark">P</span>
                    <span class="brand-text">
                        <strong><span>ProBuild</span> PC</strong>
                        <small>BUILD YOUR PERFECT PC</small>
                    </span>
                </a>

                <form class="search-box" action="#" method="get">
                    <input type="text" name="q" placeholder="Tìm kiếm sản phẩm, danh mục, thương hiệu...">
                    <button type="submit" aria-label="Tìm kiếm"></button>
                </form>

                <nav class="header-actions" aria-label="Tài khoản và giỏ hàng">
                    <a href="#" class="header-link">
                        <span class="line-icon shield"></span>
                        <span>Dịch vụ bảo hành</span>
                    </a>
                    <a href="#" class="header-link cart-link">
                        <span class="line-icon cart"></span>
                        <span>Giỏ hàng</span>
                        <em>0</em>
                    </a>
                    <a href="login.jsp" class="header-link">
                        <span class="line-icon user"></span>
                        <span>Đăng nhập</span>
                    </a>
                    <a href="register.jsp" class="register-btn">Đăng ký</a>
                </nav>
            </div>
        </header>

        <nav class="main-nav" aria-label="Điều hướng chính">
            <a class="active" href="home.jsp"><span class="nav-home-icon"></span>Trang chủ</a>
            <a href="#">Sản phẩm <span class="chevron"></span></a>
            <a href="#">Build PC</a>
            <a href="#">Thương hiệu</a>
        </nav>

        <main class="page-shell">
            <aside class="sidebar">
                <h2>DANH MỤC SẢN PHẨM</h2>
                <ul class="category-list">
                    <li><span class="cat-icon cpu"></span><span>CPU - Bộ vi xử lý</span><em>120</em></li>
                    <li><span class="cat-icon board"></span><span>Mainboard</span><em>98</em></li>
                    <li><span class="cat-icon vga"></span><span>VGA - Card màn hình</span><em>85</em></li>
                    <li><span class="cat-icon ram"></span><span>RAM - Bộ nhớ trong</span><em>64</em></li>
                    <li><span class="cat-icon drive"></span><span>SSD - Ổ cứng</span><em>42</em></li>
                    <li><span class="cat-icon drive"></span><span>HDD - Ổ cứng</span><em>36</em></li>
                    <li><span class="cat-icon psu"></span><span>Nguồn (PSU)</span><em>28</em></li>
                    <li><span class="cat-icon case"></span><span>Vỏ case</span><em>55</em></li>
                    <li><span class="cat-icon fan"></span><span>Tản nhiệt</span><em>50</em></li>
                    <li><span class="cat-icon fan"></span><span>Fan - Quạt tản nhiệt</span><em>72</em></li>
                    <li><span class="cat-icon monitor"></span><span>Màn hình</span><em>34</em></li>
                    <li><span class="cat-icon accessory"></span><span>Phụ kiện</span><em>90</em></li>
                </ul>
                <a class="all-categories" href="#"><span class="grid-icon"></span>Xem tất cả danh mục</a>
            </aside>

            <section class="content">
                <section class="hero-banner" aria-label="Build PC">
                    <div class="hero-copy">
                        <p>BUILD PC</p>
                        <h1>ĐỈNH CAO HIỆU NĂNG<br>NÂNG TẦM TRẢI NGHIỆM</h1>
                        <span>Linh kiện chính hãng - Giá tốt nhất<br>Bảo hành uy tín - Hỗ trợ tận tâm</span>
                        <a href="#">MUA NGAY</a>
                    </div>
                    <div class="hero-art" aria-hidden="true">
                        <div class="monitor-art">
                            <div class="screen-city"></div>
                            <div class="stand"></div>
                            <div class="keyboard"></div>
                        </div>
                        <div class="pc-case">
                            <span></span><span></span><span></span>
                        </div>
                        <div class="mouse"></div>
                    </div>
                    <div class="banner-dots">
                        <span class="active"></span><span></span><span></span><span></span>
                    </div>
                </section>

                <section class="service-row" aria-label="Dịch vụ">
                    <article>
                        <span class="service-icon shield"></span>
                        <div>
                            <strong>Hàng chính hãng</strong>
                            <small>100% chính hãng</small>
                        </div>
                    </article>
                    <article>
                        <span class="service-icon refresh"></span>
                        <div>
                            <strong>Bảo hành uy tín</strong>
                            <small>Bảo hành chính hãng</small>
                        </div>
                    </article>
                    <article>
                        <span class="service-icon truck"></span>
                        <div>
                            <strong>Giao hàng toàn Thạch Thất</strong>
                            <small>Miễn phí đơn từ 1 triệu</small>
                        </div>
                    </article>
                    <article>
                        <span class="service-icon headset"></span>
                        <div>
                            <strong>Hỗ trợ 24/7</strong>
                            <small>Tư vấn tận tâm</small>
                        </div>
                    </article>
                </section>

                <section class="filter-row" aria-label="Bộ lọc sản phẩm">
                    <div class="filters">
                        <label>
                            Danh mục:
                            <select>
                                <option>Tất cả</option>
                                <option>CPU</option>
                                <option>Mainboard</option>
                                <option>VGA</option>
                            </select>
                        </label>
                        <label>
                            Thương hiệu:
                            <select>
                                <option>Tất cả</option>
                                <option>Intel</option>
                                <option>ASUS</option>
                                <option>MSI</option>
                            </select>
                        </label>
                        <label>
                            Khoảng giá:
                            <select>
                                <option>Tất cả</option>
                                <option>Dưới 2 triệu</option>
                                <option>2 - 5 triệu</option>
                                <option>Trên 5 triệu</option>
                            </select>
                        </label>
                    </div>
                    <label class="sort-box">
                        Sắp xếp:
                        <select>
                            <option>Mới nhất</option>
                            <option>Giá tăng dần</option>
                            <option>Giá giảm dần</option>
                        </select>
                    </label>
                </section>

                <section class="product-grid" aria-label="Sản phẩm nổi bật">
                    <article class="product-card">
                        <button class="wish-btn" type="button" aria-label="Thêm vào yêu thích"></button>
                        <figure><img src="../images/products/intel-core-i5-12400f.jpg" alt="Intel Core i5-12400F"></figure>
                        <h3>Intel Core i5-14600KF</h3>
                        <strong>6.890.000đ</strong>
                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button" aria-label="Thêm vào giỏ hàng"></button>
                        </div>
                    </article>
                    <article class="product-card">
                        <button class="wish-btn" type="button" aria-label="Thêm vào yêu thích"></button>
                        <figure><img src="../images/products/msi-rtx-4060-ventus-2x.jpg" alt="ASUS TUF RTX 4060 8GB"></figure>
                        <h3>ASUS TUF RTX 4060 8GB</h3>
                        <strong>8.990.000đ</strong>
                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button" aria-label="Thêm vào giỏ hàng"></button>
                        </div>
                    </article>
                    <article class="product-card">
                        <button class="wish-btn" type="button" aria-label="Thêm vào yêu thích"></button>
                        <figure><img src="../images/products/kingston-fury-beast-16gb-ddr5.jpg" alt="G.Skill Ripjaws S5 DDR5 6000MHz"></figure>
                        <h3>G.Skill Ripjaws S5 16GB DDR5 6000MHz</h3>
                        <strong>2.490.000đ</strong>
                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button" aria-label="Thêm vào giỏ hàng"></button>
                        </div>
                    </article>
                    <article class="product-card">
                        <button class="wish-btn" type="button" aria-label="Thêm vào yêu thích"></button>
                        <figure><img src="../images/products/kingston-fury-beast-16gb-ddr5.jpg" alt="Kingston NV2 1TB NVMe PCIe 4.0"></figure>
                        <h3>Kingston NV2 1TB NVMe PCIe 4.0</h3>
                        <strong>1.690.000đ</strong>
                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button" aria-label="Thêm vào giỏ hàng"></button>
                        </div>
                    </article>
                    <article class="product-card">
                        <button class="wish-btn" type="button" aria-label="Thêm vào yêu thích"></button>
                        <figure><img src="../images/products/asus-prime-b650m-a.jpg" alt="MSI B760M Mortar WiFi DDR5"></figure>
                        <h3>MSI B760M Mortar WiFi DDR5</h3>
                        <strong>4.590.000đ</strong>
                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button" aria-label="Thêm vào giỏ hàng"></button>
                        </div>
                    </article>
                    <article class="product-card">
                        <button class="wish-btn" type="button" aria-label="Thêm vào yêu thích"></button>
                        <figure><span class="product-psu"></span></figure>
                        <h3>Corsair RM750e 750W 80 Plus Gold</h3>
                        <strong>1.990.000đ</strong>
                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button" aria-label="Thêm vào giỏ hàng"></button>
                        </div>
                    </article>
                </section>

                <nav class="home-pagination" aria-label="Phân trang">
                    <a href="#" aria-label="Trang trước" class="arrow-prev"></a>
                    <a href="#" class="active">1</a>
                    <a href="#">2</a>
                    <a href="#">3</a>
                    <a href="#">4</a>
                    <a href="#">5</a>
                    <span>...</span>
                    <a href="#">10</a>
                    <a href="#" aria-label="Trang sau" class="arrow-next"></a>
                </nav>
            </section>
        </main>
    </body>
</html>
