<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>

<%!
    private String h(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    User account = (User) session.getAttribute("account");

    String roleName = "";
    String fullName = "";
    String ctx = request.getContextPath();
    String placeholder = "Tìm kiếm linh kiện...";
    String searchAction = ctx + "/categories";
    String searchParamName = "keyword";
    String searchKeyword = request.getParameter("keyword");

    if (searchKeyword == null) {
    searchKeyword = "";
    }
    Object forwardServletPath = request.getAttribute("jakarta.servlet.forward.servlet_path");
    if (forwardServletPath == null) {
        forwardServletPath = request.getAttribute("javax.servlet.forward.servlet_path");
    }

    String currentPath = forwardServletPath instanceof String
            ? (String) forwardServletPath
            : request.getServletPath();
    boolean deliveryHistoryMode = "1".equals(request.getParameter("deliveryHistory"));

    if (currentPath == null) {
        currentPath = "";
    }

    if (account != null) {
        roleName = account.getRoleName();

        if (roleName != null) {
            roleName = roleName.trim().toUpperCase();
        } else {
            roleName = "";
        }

        fullName = account.getFullName();

         if ("CUSTOMER".equals(roleName)) {
            if ("/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath)) {
                placeholder = "Tìm kiếm mã đơn hàng...";
                searchAction = ctx + "/order-history";
            } else {
                placeholder = "Tìm kiếm linh kiện...";
                searchAction = ctx + "/home";
            }
        } else if ("EMPLOYEE".equals(roleName) || "STAFF".equals(roleName)) {
            if ("/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath)) {
                placeholder = "Tìm kiếm mã đơn hàng...";
                searchAction = ctx + "/order-history";
                searchParamName = "keyword";
            } else {
                placeholder = "Tìm kiếm yêu cầu bảo hành...";
                searchAction = ctx + "/ManageWarranty";
                searchParamName = "search";
                searchKeyword = request.getParameter("search");
                if (searchKeyword == null) {
                    searchKeyword = "";
                }
            }
        } else if ("SHIPMENT".equals(roleName)) {
            placeholder = "Tìm kiếm mã đơn hàng...";
            searchAction = ctx + "/order-history";
            searchParamName = "keyword";
        }
    } else {
        roleName = "CUSTOMER";
        placeholder = "Tìm kiếm linh kiện...";
        searchAction = ctx + "/categories";
    }

    Integer cartItemCount = (Integer) request.getAttribute("cartItemCount");
    Integer sessionCartItemCount = (Integer) session.getAttribute("sessionCartItemCount");

    if (sessionCartItemCount != null) {
        cartItemCount = sessionCartItemCount;
    }

    if (cartItemCount == null) {
        cartItemCount = 0;
    }
%>

<header class="main-header">
    <div class="header-top-line"></div>

    <nav class="header-menu">
        <% if ("CUSTOMER".equals(roleName)) { %>

        <a href="<%= ctx %>/home" class="menu-item <%= "/home".equals(currentPath) || "/Home".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-house"></i> Trang chủ</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/build-pc" class="menu-item <%= "/build-pc".equals(currentPath) || "/BuildPC".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-screwdriver-wrench"></i> Xây dựng cấu hình PC</a>
        <span class="menu-divider"></span>

        <div class="menu-dropdown">
            <button class="menu-item menu-dropdown-toggle" type="button">
                <i class="fa-solid fa-layer-group"></i> Sản phẩm
                <span class="menu-dropdown-arrow">▾</span>
            </button>
            <div class="menu-dropdown-list">
                <a href="<%= ctx %>/categories">Các danh mục sản phẩm</a>
                <a href="<%= ctx %>/brands">Các thương hiệu sản phẩm</a>
            </div>
        </div>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/order-history" class="menu-item <%= "/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-clipboard-list"></i> Lịch sử đơn hàng</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/warranty-lookup" class="menu-item <%= "/warranty-lookup".equals(currentPath) || "/WarrantyLookup".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-shield-halved"></i> Tra cứu bảo hành</a>   <span class="menu-divider"></span></span>
        <a href="<%= ctx %>/warranty-history" class="menu-item <%= "/warranty-history".equals(currentPath) || "/WarrantyHistory".equals(currentPath) ? "active" : "" %>">🛡 Lịch sử yêu cầu bảo hành</a>

        <% } else if ("ADMIN".equals(roleName)) { %>


        <a href="<%= ctx %>/Dashboard" class="menu-item <%= "/Dashboard".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-gauge-high"></i> Dashboard</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/order-history" class="menu-item <%= "/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-boxes-stacked"></i> Quản lý đơn hàng</a>
        <span class="menu-divider"></span>

        <div class="menu-dropdown">
            <button class="menu-item menu-dropdown-toggle" type="button" aria-expanded="false">
                <i class="fa-solid fa-users-gear"></i> Quản lý tài khoản
                <span class="menu-dropdown-arrow">▾</span>
            </button>
            <div class="menu-dropdown-list">
                <a href="<%= ctx %>/AccountManagement?type=user">Tài khoản khách hàng</a>
                <a href="<%= ctx %>/AccountManagement?type=staff">Tài khoản nhân viên</a>
            </div>
        </div>
        <span class="menu-divider"></span>

        <div class="menu-dropdown">
            <button class="menu-item menu-dropdown-toggle" type="button">
                <i class="fa-solid fa-microchip"></i> Sản phẩm
                <span class="menu-dropdown-arrow">▾</span>
            </button>
            <div class="menu-dropdown-list">
                <a href="<%= ctx %>/admin/products">Quản lý sản phẩm</a>
                <a href="<%= ctx %>/AdminBrands">Quản lý thương hiệu</a>
                <a href="<%= ctx %>/admin/categories">Quản lý các danh mục sản phẩm</a>
            </div>
        </div>
        <span class="menu-divider"></span>

        <a href="${pageContext.request.contextPath}/BatchServlet" class="menu-item <%= "/BatchServlet".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-warehouse"></i> Lô hàng</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/ManageWarranty" class="menu-item"><i class="fa-solid fa-shield-halved"></i> Bảo hành</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/views/revenue.jsp" class="menu-item"><i class="fa-solid fa-chart-line"></i> Thống kê doanh thu</a>
        <% } else if ("EMPLOYEE".equals(roleName) || "STAFF".equals(roleName)) { %>


        <a href="<%= ctx %>/Dashboard" class="menu-item <%= "/Dashboard".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-gauge-high"></i> Dashboard</a>
        <span class="menu-divider"></span>
        
        <a href="<%= ctx %>/order-history" class="menu-item <%= "/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-boxes-stacked"></i> Quản lý đơn hàng</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/ManageWarranty" class="menu-item"><i class="fa-solid fa-shield-heart"></i> Dịch vụ bảo hành</a>

        <% } else if ("SHIPMENT".equals(roleName)) { %>


        <a href="<%= ctx %>/Dashboard" class="menu-item <%= "/Dashboard".equals(currentPath) ? "active" : "" %>"><i class="fa-solid fa-gauge-high"></i> Dashboard</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/order-history" class="menu-item <%= ("/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath)) && !deliveryHistoryMode ? "active" : "" %>"><i class="fa-solid fa-box"></i> Đơn hàng của tôi</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/order-history?deliveryHistory=1" class="menu-item <%= ("/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath)) && deliveryHistoryMode ? "active" : "" %>"><i class="fa-solid fa-truck-fast"></i> Lịch sử giao hàng</a>
        <% } %>


    </nav>

    <div class="header-bottom">
        <a href="<%= ctx %>/home" style="text-decoration: none; color: inherit;">
            <div class="logo-box">
                <div class="logo-icon">P</div>
                <div>
                    <h2>ProBuild <span>PC</span></h2>
                    <p>BUILD YOUR PERFECT PC</p>
                </div>
            </div>
        </a>
        <% if (!"ADMIN".equals(roleName)) { %>
        <form class="search-box" action="<%= searchAction %>" method="get">
            <% if ("SHIPMENT".equals(roleName) && deliveryHistoryMode) { %>
            <input type="hidden" name="deliveryHistory" value="1">
            <% } %>
            <input class="search-input" type="text" name="<%= searchParamName %>" value="<%= h(searchKeyword) %>" placeholder="<%= h(placeholder) %>">
            <button class="search-submit" type="submit">Tìm kiếm</button>
        </form>
        <% } %>
        <div class="right-box">
            <% if ("CUSTOMER".equals(roleName) && account != null) { %>
            <a class="cart-box" href="<%= ctx %>/cart">
                <div class="cart-icon">
                    <i class="fa-solid fa-cart-shopping"></i>
                    <span><%= cartItemCount %></span>
                </div>
                <p>Giỏ hàng</p>
            </a>
            <% } %>

            <% if (account != null) { %>
            <div class="user-dropdown">
                <button class="dropdown-toggle" type="button">
                    <div class="user-icon"><i class="fa-solid fa-user"></i></div>
                    <div>
                        <h4><%= fullName %></h4>
                        <p>
                            <% if ("SHIPMENT".equals(roleName)) { %>
                            Tài xế vận chuyển
                            <% } else if ("ADMIN".equals(roleName)) { %>
                            Admin
                            <% } else if ("EMPLOYEE".equals(roleName) || "STAFF".equals(roleName)) { %>
                            Nhân viên
                            <% } else if ("CUSTOMER".equals(roleName)) { %>
                            Khách hàng
                            <% } %>
                        </p>
                    </div>
                </button>
                <div class="dropdown-menu">
                    <a href="<%= ctx %>/views/profile.jsp"><i class="fa-regular fa-id-card"></i> Thông tin cá nhân</a>
                    <% if ("CUSTOMER".equals(roleName)) { %>
                    <a href="<%= ctx %>/shipping-address"><i class="fa-solid fa-location-dot"></i> Địa chỉ giao hàng</a>
                    <% } %>
                    <a href="<%= ctx %>/Logout" class="menu-item logout"><i class="fa-solid fa-right-from-bracket"></i> Đăng xuất</a>

                </div>

            </div>
            <% } else { %>
            <!-- Nếu chưa đăng nhập -->
            <div class="login-buttons">
                <a href="<%= ctx %>/Login" class="login-btn">
                    <i class="fa-solid fa-user"></i> Đăng nhập
                </a>
                <a href="<%= ctx %>/Register" class="register-btn1">
                    Đăng ký
                </a>
            </div>
            <% } %>
        </div>
    </div>
</header>
