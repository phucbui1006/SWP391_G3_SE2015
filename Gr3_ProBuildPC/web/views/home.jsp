<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>

<%
    User account = (User) session.getAttribute("account");
    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ProBuild PC</title>

        <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    </head>

    <body class="home-page">

        <div class="top-strip"></div>

        <header class="site-header">
            <div class="header-inner">

                <a class="brand" href="<%= ctx %>/home">
                    <span class="brand-mark">P</span>

                    <span class="brand-text">
                        <strong><span>ProBuild</span> PC</strong>
                        <small>BUILD YOUR PERFECT PC</small>
                    </span>
                </a>

                <form class="home-search-box" action="#" method="get">
                    <input type="text" name="q" placeholder="Tìm kiếm sản phẩm, danh mục, thương hiệu...">
                    <button type="submit">🔍</button>
                </form>

                <nav class="header-actions">

                    <a href="#" class="header-link">
                        <span>🛡</span>
                        <b>Dịch vụ bảo hành</b>
                    </a>

                    <a href="#" class="header-link cart-link">
                        <span>🛒</span>
                        <b>Giỏ hàng</b>
                        <em>0</em>
                    </a>

                    <% if (account == null) { %>

                    <a href="<%= ctx %>/Login" class="header-link">
                        <span>👤</span>
                        <b>Đăng nhập</b>
                    </a>

                    <a href="<%= ctx %>/Register" class="register-btn">
                        Đăng ký
                    </a>

                    <% } else { %>

                    <a href="<%= ctx %>/Dashboard" class="header-link">
                        <span>👤</span>
                        <b><%= account.getFullName() %></b>
                    </a>

                    <a href="<%= ctx %>/Logout" class="register-btn">
                        Đăng xuất
                    </a>

                    <% } %>

                </nav>
            </div>
        </header>

        <nav class="main-nav">
            <a class="active" href="<%= ctx %>/home">🏠 Trang chủ</a>
            <a href="#">Sản phẩm ▾</a>
            <a href="#">Build PC</a>
            <a href="#">Thương hiệu</a>
        </nav>

        <main class="page-shell">

            <aside class="sidebar">
                <h2>DANH MỤC SẢN PHẨM</h2>

                <ul class="category-list">
                    <li><span>▣ CPU - Bộ vi xử lý</span><em>120</em></li>
                    <li><span>▣ Mainboard</span><em>98</em></li>
                    <li><span>▣ VGA - Card màn hình</span><em>85</em></li>
                    <li><span>▣ RAM - Bộ nhớ trong</span><em>64</em></li>
                    <li><span>▣ SSD - Ổ cứng</span><em>42</em></li>
                    <li><span>▣ HDD - Ổ cứng</span><em>36</em></li>
                    <li><span>▣ Nguồn PSU</span><em>28</em></li>
                    <li><span>▣ Vỏ case</span><em>55</em></li>
                    <li><span>▣ Tản nhiệt</span><em>50</em></li>
                    <li><span>▣ Fan - Quạt tản nhiệt</span><em>72</em></li>
                    <li><span>▣ Màn hình</span><em>34</em></li>
                    <li><span>▣ Phụ kiện</span><em>90</em></li>
                </ul>

                <a class="all-categories" href="#">▦ Xem tất cả danh mục</a>
            </aside>

            <section class="content">

                <section class="hero-banner">
                    <div class="hero-copy">
                        <p>BUILD PC</p>

                        <h1>
                            ĐỈNH CAO HIỆU NĂNG<br>
                            NÂNG TẦM TRẢI NGHIỆM
                        </h1>

                        <span>
                            Linh kiện chính hãng - Giá tốt nhất<br>
                            Bảo hành uy tín - Hỗ trợ tận tâm
                        </span>

                        <a href="#">MUA NGAY</a>
                    </div>
                </section>

                <section class="service-row">
                    <article>
                        <span>🛡</span>
                        <div>
                            <strong>Hàng chính hãng</strong>
                            <small>100% chính hãng</small>
                        </div>
                    </article>

                    <article>
                        <span>🔄</span>
                        <div>
                            <strong>Bảo hành uy tín</strong>
                            <small>Bảo hành chính hãng</small>
                        </div>
                    </article>

                    <article>
                        <span>🚚</span>
                        <div>
                            <strong>Giao hàng toàn Thạch Thất</strong>
                            <small>Miễn phí đơn từ 1 triệu</small>
                        </div>
                    </article>

                    <article>
                        <span>🎧</span>
                        <div>
                            <strong>Hỗ trợ 24/7</strong>
                            <small>Tư vấn tận tâm</small>
                        </div>
                    </article>
                </section>

                <section class="filter-row">
                    <div class="filters">

                        <label>
                            Danh mục:
                            <select>
                                <option>Tất cả</option>
                                <option>CPU</option>
                                <option>Mainboard</option>
                                <option>VGA</option>
                                <option>RAM</option>
                            </select>
                        </label>

                        <label>
                            Thương hiệu:
                            <select>
                                <option>Tất cả</option>
                                <option>Intel</option>
                                <option>AMD</option>
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

                <section class="product-grid">

                    <article class="product-card">
                        <button class="wish-btn">♡</button>
                        <figure>
                            <img src="<%= ctx %>/images/products/intel-core-i5-12400f.jpg" alt="Intel Core i5">
                        </figure>
                        <h3>Intel Core i5-14600KF</h3>
                        <strong>6.890.000đ</strong>

                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button">🛒</button>
                        </div>
                    </article>

                    <article class="product-card">
                        <button class="wish-btn">♡</button>
                        <figure>
                            <img src="<%= ctx %>/images/products/msi-rtx-4060-ventus-2x.jpg" alt="RTX 4060">
                        </figure>
                        <h3>ASUS TUF RTX 4060 8GB</h3>
                        <strong>8.990.000đ</strong>

                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button">🛒</button>
                        </div>
                    </article>

                    <article class="product-card">
                        <button class="wish-btn">♡</button>
                        <figure>
                            <img src="<%= ctx %>/images/products/kingston-fury-beast-16gb-ddr5.jpg" alt="RAM DDR5">
                        </figure>
                        <h3>G.Skill Ripjaws S5 16GB DDR5 6000MHz</h3>
                        <strong>2.490.000đ</strong>

                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button">🛒</button>
                        </div>
                    </article>

                    <article class="product-card">
                        <button class="wish-btn">♡</button>
                        <figure>
                            <img src="<%= ctx %>/images/products/kingston-fury-beast-16gb-ddr5.jpg" alt="SSD">
                        </figure>
                        <h3>Kingston NV2 1TB NVMe PCIe 4.0</h3>
                        <strong>1.690.000đ</strong>

                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button">🛒</button>
                        </div>
                    </article>

                    <article class="product-card">
                        <button class="wish-btn">♡</button>
                        <figure>
                            <img src="<%= ctx %>/images/products/asus-prime-b650m-a.jpg" alt="Mainboard">
                        </figure>
                        <h3>MSI B760M Mortar WiFi DDR5</h3>
                        <strong>4.590.000đ</strong>

                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button">🛒</button>
                        </div>
                    </article>

                    <article class="product-card">
                        <button class="wish-btn">♡</button>
                        <figure class="psu-demo">
                            ⚡
                        </figure>
                        <h3>Corsair RM750e 750W 80 Plus Gold</h3>
                        <strong>1.990.000đ</strong>

                        <div class="product-actions">
                            <a href="#">Xem chi tiết</a>
                            <button type="button">🛒</button>
                        </div>
                    </article>

                </section>

                <nav class="home-pagination">
                    <a href="#">‹</a>
                    <a href="#" class="active">1</a>
                    <a href="#">2</a>
                    <a href="#">3</a>
                    <a href="#">4</a>
                    <a href="#">5</a>
                    <span>...</span>
                    <a href="#">10</a>
                    <a href="#">›</a>
                </nav>

            </section>
        </main>

    </body>
</html>