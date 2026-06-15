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
                searchAction = ctx + "/categories";
            }
        } else if ("EMPLOYEE".equals(roleName)) {
            placeholder = "Tìm kiếm yêu cầu bảo hành...";
        } else if ("SHIPMENT".equals(roleName)) {
            placeholder = "Tìm kiếm mã đơn hàng...";
            searchAction = ctx + "/order-history";
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

        <a href="<%= ctx %>/home" class="menu-item <%= "/home".equals(currentPath) || "/Home".equals(currentPath) ? "active" : "" %>">🏠 Trang chủ</a>
        <span class="menu-divider"></span>

        <a href="#" class="menu-item">🛠 BUILD PC</a>
        <span class="menu-divider"></span>

        <div class="menu-dropdown">
            <button class="menu-item menu-dropdown-toggle" type="button">
                📦 Danh mục sản phẩm
                <span class="menu-dropdown-arrow">▾</span>
            </button>
            <div class="menu-dropdown-list">
                <a href="<%= ctx %>/categories">Sản phẩm</a>
                <a href="<%= ctx %>/brands">Các thương hiệu sản phẩm</a>
            </div>
        </div>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/order-history" class="menu-item <%= "/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath) ? "active" : "" %>">📋 Lịch sử đơn hàng</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/warranty-lookup" class="menu-item <%= "/warranty-lookup".equals(currentPath) || "/WarrantyLookup".equals(currentPath) ? "active" : "" %>">🛡 Tra cứu bảo hành</a>
        <% } else if ("ADMIN".equals(roleName)) { %>

        <a href="<%= ctx %>/Dashboard" class="menu-item <%= "/Dashboard".equals(currentPath) ? "active" : "" %>">🛡 Dashboard</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/order-history" class="menu-item <%= "/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath) ? "active" : "" %>">📦 Quản lý đơn hàng</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/AccountManagement" class="menu-item">👥 Tài khoản người dùng</a>
        <span class="menu-divider"></span>

        <div class="menu-dropdown">
            <button class="menu-item menu-dropdown-toggle" type="button">
                📦 Sản phẩm
                <span class="menu-dropdown-arrow">▾</span>
            </button>
            <div class="menu-dropdown-list">
                <a href="#">Quản lý sản phẩm</a>
                <a href="<%= ctx %>/AdminBrands">Quản lý thương hiệu</a>
                <a href="<%= ctx %>/admin/categories">Quản lý các loại sản phẩm</a>
            </div>
        </div>
        <span class="menu-divider"></span>

        <a href="${pageContext.request.contextPath}/BatchServlet" class="menu-item <%= "/BatchServlet".equals(currentPath) ? "active" : "" %>">🏬 Lô hàng</a>
        <span class="menu-divider"></span>

        <a href="#" class="menu-item">🛡 Bảo hành</a>
        <span class="menu-divider"></span>

        <a href="#" class="menu-item">📊 Thống kê doanh thu</a>
        <% } else if ("EMPLOYEE".equals(roleName)) { %>

        <a href="<%= ctx %>/Dashboard" class="menu-item <%= "/Dashboard".equals(currentPath) ? "active" : "" %>">🏠 Dashboard</a>
        <span class="menu-divider"></span>

        <a href="#" class="menu-item">🛡 Dịch vụ bảo hành</a>

        <% } else if ("SHIPMENT".equals(roleName)) { %>

        <a href="<%= ctx %>/Dashboard" class="menu-item <%= "/Dashboard".equals(currentPath) ? "active" : "" %>">🏠 Dashboard</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/order-history" class="menu-item <%= ("/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath)) && !deliveryHistoryMode ? "active" : "" %>">📦 Đơn hàng của tôi</a>
        <span class="menu-divider"></span>

        <a href="<%= ctx %>/order-history?deliveryHistory=1" class="menu-item <%= ("/order-history".equals(currentPath) || "/OrderHistory".equals(currentPath)) && deliveryHistoryMode ? "active" : "" %>">🚚 Lịch sử giao hàng</a>
        <% } %>


    </nav>

    <div class="header-bottom">
        <div class="logo-box">
            <div class="logo-icon">P</div>
            <div>
                <h2>ProBuild <span>PC</span></h2>
                <p>BUILD YOUR PERFECT PC</p>
            </div>
        </div>
        <% if (!"ADMIN".equals(roleName)) { %>
        <form class="search-box" action="<%= searchAction %>" method="get">
            <% if ("SHIPMENT".equals(roleName) && deliveryHistoryMode) { %>
            <input type="hidden" name="deliveryHistory" value="1">
            <% } %>
            <input class="search-input" type="text" name="keyword" value="<%= h(searchKeyword) %>" placeholder="<%= h(placeholder) %>">
            <button class="search-submit" type="submit">Tìm kiếm</button>
        </form>
        <% } %>
        <div class="right-box">
            <% if ("CUSTOMER".equals(roleName) && account != null) { %>
            <a class="cart-box" href="<%= ctx %>/cart">
                <div class="cart-icon">
                    🛒
                    <span><%= cartItemCount %></span>
                </div>
                <p>Giỏ hàng</p>
            </a>
            <% } %>

            <% if (account != null) { %>
            <div class="user-dropdown">
                <button class="dropdown-toggle" type="button">
                    <div class="user-icon">👤</div>
                    <div>
                        <h4><%= fullName %></h4>
                        <p>
                            <% if ("SHIPMENT".equals(roleName)) { %>
                            Tài xế vận chuyển
                            <% } else if ("ADMIN".equals(roleName)) { %>
                            Admin
                            <% } else if ("EMPLOYEE".equals(roleName)) { %>
                            Nhân viên
                            <% } else if ("CUSTOMER".equals(roleName)) { %>
                            Khách hàng
                            <% } %>
                        </p>
                    </div>
                </button>
                <div class="dropdown-menu">
                    <a href="<%= ctx %>/views/profile.jsp">📋 Thông tin cá nhân</a>
                    <% if ("CUSTOMER".equals(roleName)) { %>
                    <a href="<%= ctx %>/shipping-address">📍 Địa chỉ giao hàng</a>
                    <% } %>
                    <a href="<%= ctx %>/Logout" class="menu-item logout">Đăng xuất</a>

                </div>

            </div>
            <% } else { %>
            <!-- Nếu chưa đăng nhập -->
            <div class="login-buttons">
                <a href="<%= ctx %>/Login" class="login-btn">
                    👤 Đăng nhập
                </a>
                <a href="<%= ctx %>/Register" class="register-btn1">
                    Đăng ký
                </a>
            </div>
            <% } %>
        </div>
    </div>
</header>
