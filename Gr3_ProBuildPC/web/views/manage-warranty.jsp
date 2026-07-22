<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Warranty" %>
<%@ page import="model.WarrantyRequest" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%!
    private String h(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String defaultText(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }
    private String formatDate(Date value, SimpleDateFormat formatter) {
        return value == null ? "--/--/----" : formatter.format(value);
    }
    private String formatTime(Date value, SimpleDateFormat formatter) {
        return value == null ? "--:--" : formatter.format(value);
    }
    private String statusClass(int statusId) {
        if (statusId == 2) return "cancelled";
        if (statusId == 3) return "completed";
        return "waiting";
    }
    private String appendParam(String query, String name, String value) {
        if (value == null || value.trim().isEmpty()) return query;
        StringBuilder builder = new StringBuilder(query == null ? "" : query);
        if (builder.length() > 0) builder.append("&");
        builder.append(name).append("=").append(java.net.URLEncoder.encode(value.trim(), java.nio.charset.StandardCharsets.UTF_8));
        return builder.toString();
    }
    private String buildWarrantyLink(String ctx, String search, Integer statusId, int page, int selectedWarrantyId) {
        String query = "";
        query = appendParam(query, "search", search);
        if (statusId != null && statusId > 0) query = appendParam(query, "statusFilter", String.valueOf(statusId));
        query = appendParam(query, "page", String.valueOf(page));
        query = appendParam(query, "selectedWarrantyId", String.valueOf(selectedWarrantyId));
        return ctx + "/ManageWarranty" + (query.isEmpty() ? "" : "?" + query);
    }
    private String buildPageLink(String ctx, String search, Integer statusId, int page, Integer selectedWarrantyId) {
        String query = "";
        query = appendParam(query, "search", search);
        if (statusId != null && statusId > 0) query = appendParam(query, "statusFilter", String.valueOf(statusId));
        query = appendParam(query, "page", String.valueOf(page));
        if (selectedWarrantyId != null) query = appendParam(query, "selectedWarrantyId", String.valueOf(selectedWarrantyId));
        return ctx + "/ManageWarranty" + (query.isEmpty() ? "" : "?" + query);
    }
%>
<%
    List<WarrantyRequest> warrantyList = (List<WarrantyRequest>) request.getAttribute("adminWarrantyList");
    if (warrantyList == null) warrantyList = Collections.emptyList();
    
    WarrantyRequest selectedWarranty = (WarrantyRequest) request.getAttribute("selectedWarranty");
    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) searchQuery = "";
    Integer statusFilterId = (Integer) request.getAttribute("statusFilterId");
    
    Integer pageVal = (Integer) request.getAttribute("page");
    int currentPage = pageVal == null ? 1 : pageVal;
    Integer totalPagesVal = (Integer) request.getAttribute("totalPages");
    int totalPages = totalPagesVal == null ? 1 : totalPagesVal;
    Integer totalWarrantiesVal = (Integer) request.getAttribute("totalWarranties");
    int totalWarranties = totalWarrantiesVal == null ? 0 : totalWarrantiesVal;
    
    Integer selectedWarrantyId = selectedWarranty == null ? null : selectedWarranty.getWarrantyId();
    Warranty condItem = (Warranty) request.getAttribute("condItem");
    List<Warranty> condHistory = (List<Warranty>) request.getAttribute("condHistory");
    if (condHistory == null) condHistory = Collections.emptyList();
    
    SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat timeFormatter = new SimpleDateFormat("HH:mm");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý yêu cầu bảo hành - Dashboard</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/manage-warranty.css?v=203">
        <script src="${pageContext.request.contextPath}/js/validator.js"></script>
        <script src="${pageContext.request.contextPath}/js/warranty.js"></script>
    </head>
    <body class="order-history-body manage-warranty-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="order-history-page">
            <nav class="order-history-breadcrumb site-breadcrumb" aria-label="Breadcrumb">
                <a href="<%= ctx %>/Dashboard">Dashboard</a>
                <span>›</span>
                <strong>Quản lý yêu cầu bảo hành</strong>
            </nav>

            <section class="order-history-heading">
                <div>
                    <h1>Quản lý yêu cầu bảo hành</h1>
                    <p>Theo dõi và xử lý các yêu cầu bảo hành của khách hàng</p>
                </div>
                <form class="order-history-filter" action="<%= ctx %>/ManageWarranty" method="get">
                    <input type="search" id="searchKeyword" name="search" value="<%= h(searchQuery) %>" placeholder="Tìm mã YC, đơn hàng, SP..." maxlength="100">
                    <select name="statusFilter">
                        <option value="">Tất cả trạng thái</option>
                        <option value="1" <%= statusFilterId != null && statusFilterId == 1 ? "selected" : "" %>>Chờ tiếp nhận</option>
                        <option value="2" <%= statusFilterId != null && statusFilterId == 2 ? "selected" : "" %>>Từ chối</option>
                        <option value="3" <%= statusFilterId != null && statusFilterId == 3 ? "selected" : "" %>>Chấp nhận</option>
                    </select>
                    <button type="submit">Tìm</button>
                </form>
            </section>

            <c:if test="${not empty sessionScope.successMsg}">
                <div class="order-history-alert success">
                    <c:out value="${sessionScope.successMsg}"/>
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="order-history-alert error">
                    <c:out value="${sessionScope.errorMsg}"/>
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>

            <section class="order-history-layout">
                <!-- Left Panel: List of Warranty Requests -->
                <aside class="order-list-panel">
                    <div class="order-panel-title">
                        <h2>Danh sách yêu cầu</h2>
                        <span><%= totalWarranties %> yêu cầu</span>
                    </div>

                    <div class="order-card-list">
                        <% if (warrantyList.isEmpty()) { %>
                        <div class="order-history-empty">
                            <strong>Chưa có yêu cầu bảo hành nào</strong>
                            <span>Thử đổi bộ lọc hoặc từ khóa tìm kiếm.</span>
                        </div>
                        <% } %>

                        <% for (WarrantyRequest item : warrantyList) { %>
                        <%
                            boolean active = selectedWarrantyId != null && selectedWarrantyId == item.getWarrantyId();
                            String stClass = statusClass(item.getStatusId());
                        %>
                        <a class="order-list-card <%= active ? "active" : "" %>"
                           href="<%= buildWarrantyLink(ctx, searchQuery, statusFilterId, currentPage, item.getWarrantyId()) %>">
                            <span class="order-card-icon" aria-hidden="true"><i class="fa-solid fa-shield-halved"></i></span>
                            <span class="order-card-main">
                                <strong>#WR<%= item.getWarrantyId() %></strong>
                                <small>Đơn #PB<%= item.getOrderId() %> · <%= formatDate(item.getRequestDate(), dateFormatter) %></small>
                                <em><%= h(defaultText(item.getCustomerName(), "Khách hàng")) %></em>
                            </span>
                            <span class="order-status-pill <%= stClass %>"><%= h(item.getStatusName()) %></span>
                            <span class="order-card-arrow" aria-hidden="true">›</span>
                        </a>
                        <% } %>
                    </div>

                    <!-- Pagination -->
                    <% if (totalPages > 1) { %>
                    <div class="order-history-pagination">
                        <a class="prev <%= currentPage <= 1 ? "disabled" : "" %>"
                           href="<%= currentPage <= 1 ? "#" : buildPageLink(ctx, searchQuery, statusFilterId, currentPage - 1, selectedWarrantyId) %>"
                           aria-label="Trang trước">‹</a>
                        <%
                            int fromPage = Math.max(2, currentPage - 2);
                            int toPage = Math.min(totalPages - 1, currentPage + 2);
                            if (currentPage <= 4) {
                                fromPage = 2;
                                toPage = Math.min(totalPages - 1, 5);
                            } else if (currentPage >= totalPages - 3) {
                                fromPage = Math.max(2, totalPages - 4);
                                toPage = totalPages - 1;
                            }
                        %>
                        <a class="<%= currentPage == 1 ? "active" : "" %>"
                           href="<%= buildPageLink(ctx, searchQuery, statusFilterId, 1, selectedWarrantyId) %>">1</a>
                        <% if (fromPage > 2) { %>
                        <span>...</span>
                        <% } %>
                        <% for (int pageNumber = fromPage; pageNumber <= toPage; pageNumber++) { %>
                        <a class="<%= pageNumber == currentPage ? "active" : "" %>"
                           href="<%= buildPageLink(ctx, searchQuery, statusFilterId, pageNumber, selectedWarrantyId) %>"><%= pageNumber %></a>
                        <% } %>
                        <% if (toPage < totalPages - 1) { %>
                        <span>...</span>
                        <% } %>
                        <% if (totalPages > 1) { %>
                        <a class="<%= currentPage == totalPages ? "active" : "" %>"
                           href="<%= buildPageLink(ctx, searchQuery, statusFilterId, totalPages, selectedWarrantyId) %>"><%= totalPages %></a>
                        <% } %>
                        <a class="next <%= currentPage >= totalPages ? "disabled" : "" %>"
                           href="<%= currentPage >= totalPages ? "#" : buildPageLink(ctx, searchQuery, statusFilterId, currentPage + 1, selectedWarrantyId) %>"
                           aria-label="Trang sau">›</a>
                    </div>
                    <% } %>
                </aside>

                <!-- Right Panel: Selected Warranty Detail -->
                <section class="order-detail-panel">
                    <% if (selectedWarranty == null) { %>
                    <div class="order-history-empty detail-empty">
                        <strong>Chọn một yêu cầu bảo hành</strong>
                        <span>Chi tiết yêu cầu bảo hành sẽ hiển thị tại đây.</span>
                    </div>
                    <% } else { %>
                    <div class="order-detail-header">
                        <h2>Yêu cầu bảo hành #WR<%= selectedWarranty.getWarrantyId() %></h2>
                        <div class="order-detail-actions">
                            <a href="<%= ctx %>/ManageWarranty?action=viewCondition&productId=<%= selectedWarranty.getProductId() %>&customerId=<%= selectedWarranty.getCustomerId() %>&search=<%= h(searchQuery) %>&statusFilter=<%= statusFilterId != null ? statusFilterId : "" %>&page=<%= currentPage %>&selectedWarrantyId=<%= selectedWarranty.getWarrantyId() %>" class="btn-action btn-view" style="text-decoration:none; padding: 6px 14px; border-radius: 6px; font-size: 13px; font-weight: 700; background: #e0e7ff; color: #3730a3;">
                                🔍 Xem tình trạng
                            </a>
                        </div>
                    </div>

                    <!-- Summary Card -->
                    <article class="order-summary-card">
                        <div class="order-summary-icon" aria-hidden="true"><i class="fa-solid fa-shield-halved"></i></div>
                        <div>
                            <strong>Mã YC: #WR<%= selectedWarranty.getWarrantyId() %> (Đơn hàng #PB<%= selectedWarranty.getOrderId() %>)</strong>
                            <span>Khách hàng: <%= h(defaultText(selectedWarranty.getCustomerName(), "Khách hàng")) %></span>
                            <span>Ngày gửi: <%= formatDate(selectedWarranty.getRequestDate(), dateFormatter) %> · <%= formatTime(selectedWarranty.getRequestDate(), timeFormatter) %></span>
                        </div>
                        <span class="order-status-pill <%= statusClass(selectedWarranty.getStatusId()) %>">
                            <%= h(selectedWarranty.getStatusName()) %>
                        </span>
                    </article>

                    <!-- Info Grid -->
                    <div class="order-info-grid">
                        <section class="order-info-box">
                            <div class="order-box-title">
                                <h3>Thông tin chung</h3>
                            </div>
                            <p><span>Khách hàng</span><strong><%= h(defaultText(selectedWarranty.getCustomerName(), "Chưa cập nhật")) %></strong></p>
                            <p><span>Mã đơn hàng</span><strong>#PB<%= selectedWarranty.getOrderId() %></strong></p>
                            <p><span>Sản phẩm</span><strong><%= h(selectedWarranty.getProductName()) %></strong></p>
                        </section>

                        <section class="order-info-box">
                            <div class="order-box-title">
                                <h3>Nội dung yêu cầu</h3>
                            </div>
                            <p><span>Mô tả sự cố</span><strong style="font-weight:500; font-style:italic;"><%= h(defaultText(selectedWarranty.getRequest(), "Không có mô tả")) %></strong></p>
                            <% if (selectedWarranty.getResponseDate() != null) { %>
                            <p><span>Ngày xử lý</span><strong><%= formatDate(selectedWarranty.getResponseDate(), dateFormatter) %> <%= formatTime(selectedWarranty.getResponseDate(), timeFormatter) %></strong></p>
                            <p><span>Phản hồi CH</span><strong><%= h(defaultText(selectedWarranty.getResponse(), "Chưa có phản hồi")) %></strong></p>
                            <% } %>
                        </section>
                    </div>

                    <!-- Processing Form (Employee Only) -->
                    <c:if test="${sessionScope.account.roleName == 'EMPLOYEE'}">
                    <form id="edit-warranty-form" class="warranty-process-form" action="<%= ctx %>/ManageWarranty" method="post" novalidate>
                        <input type="hidden" name="warrantyId" value="<%= selectedWarranty.getWarrantyId() %>">
                        <input type="hidden" name="search" value="<%= h(searchQuery) %>">
                        <input type="hidden" name="statusFilter" value="<%= statusFilterId != null ? statusFilterId : "" %>">
                        <input type="hidden" name="page" value="<%= currentPage %>">
                        <input type="hidden" name="selectedWarrantyId" value="<%= selectedWarranty.getWarrantyId() %>">

                        <div class="warranty-process-header">
                            <h3>⚙ Xử lý yêu cầu bảo hành</h3>
                        </div>

                        <div class="warranty-process-body">
                            <div class="form-group-row">
                                <label class="form-label-wrap">
                                    <span>Cập nhật trạng thái</span>
                                    <select name="statusId" required class="form-control-select">
                                        <% if (selectedWarranty.getStatusId() == 1) { %>
                                        <option value="" disabled selected>-- Chọn trạng thái xử lý --</option>
                                        <% } %>
                                        <option value="3" <%= selectedWarranty.getStatusId() == 3 ? "selected" : "" %>>Chấp nhận</option>
                                        <option value="2" <%= selectedWarranty.getStatusId() == 2 ? "selected" : "" %>>Từ chối</option>
                                    </select>
                                </label>
                            </div>

                            <div class="form-group-row">
                                <label class="form-label-wrap">
                                    <span>Phản hồi của cửa hàng</span>
                                    <textarea name="response" class="form-control-textarea" minlength="5" maxlength="1000" required placeholder="Nhập nội dung phản hồi cho khách hàng..."><%= h(selectedWarranty.getResponse()) %></textarea>
                                </label>
                            </div>

                            <div class="form-actions-row">
                                <button type="submit" class="btn-save-warranty">Lưu thay đổi</button>
                            </div>
                        </div>
                    </form>
                    </c:if>

                    <!-- Product Condition & Timeline Details -->
                    <c:if test="${not empty condItem}">
                    <div class="order-products-box">
                        <h3>Chi tiết tình trạng bảo hành & Lịch sử</h3>
                        
                        <div class="info-grid" style="margin-bottom: 20px; background:#f9fafb; padding:16px; border-radius:8px;">
                            <div class="info-item">
                                <label style="font-size:12px; color:#6b7280; font-weight:600;">Sản phẩm</label>
                                <span style="font-size:14px; font-weight:700;"><c:out value="${condItem.productName}"/></span>
                            </div>
                            <div class="info-item">
                                <label style="font-size:12px; color:#6b7280; font-weight:600;">Thương hiệu / Loại</label>
                                <span><c:out value="${condItem.brandName}"/> / <c:out value="${condItem.categoryName}"/></span>
                            </div>
                            <div class="info-item">
                                <label style="font-size:12px; color:#6b7280; font-weight:600;">Thời hạn bảo hành</label>
                                <span><c:out value="${condItem.warrantyMonths}"/> tháng</span>
                            </div>
                            <div class="info-item">
                                <label style="font-size:12px; color:#6b7280; font-weight:600;">Ngày hết hạn</label>
                                <span><fmt:formatDate value="${condItem.warrantyEndDate}" pattern="dd/MM/yyyy" /></span>
                            </div>
                            <div class="info-item">
                                <label style="font-size:12px; color:#6b7280; font-weight:600;">Tình trạng</label>
                                <c:set var="wState" value="${condItem.warrantyState}"/>
                                <span class="remaining-${wState}" style="font-weight:700;">
                                    <c:out value="${condItem.warrantyStatusLabel}"/> (<c:out value="${condItem.remainingDaysLabel}"/>)
                                </span>
                            </div>
                        </div>

                        <c:if test="${not empty condHistory}">
                        <div class="timeline-section" style="margin-top: 15px;">
                            <h4 style="font-size:14px; font-weight:700; color:#111827; margin-bottom:12px;">📋 Lịch sử tiếp nhận sản phẩm này</h4>
                            <ul class="timeline-list">
                                <c:forEach var="hist" items="${condHistory}" varStatus="loop">
                                    <li class="timeline-item ${loop.first ? 'active' : ''}">
                                        <div class="timeline-header">
                                            <span class="timeline-date"><fmt:formatDate value="${hist.requestDate}" pattern="dd/MM/yyyy HH:mm" /></span>
                                            <span class="status-badge status-${hist.statusId}">#WR${hist.warrantyId} - <c:out value="${hist.statusName}"/></span>
                                        </div>
                                        <div class="timeline-request">
                                            <strong>Khách mô tả:</strong> <c:out value="${hist.request}"/>
                                        </div>
                                        <c:if test="${not empty hist.responseDate}">
                                            <div class="timeline-response">
                                                <strong>Phản hồi ngày:</strong> <fmt:formatDate value="${hist.responseDate}" pattern="dd/MM/yyyy HH:mm" />
                                                <c:if test="${not empty hist.response}">
                                                    <div style="margin-top: 4px; font-weight: 500;">
                                                        Nội dung: "<c:out value="${hist.response}"/>"
                                                    </div>
                                                </c:if>
                                            </div>
                                        </c:if>
                                    </li>
                                </c:forEach>
                            </ul>
                        </div>
                        </c:if>
                    </div>
                    </c:if>
                    <% } %>
                </section>
            </section>
        </main>

        <!-- Modals for viewCondition / edit if requested directly via action -->
        <c:if test="${not empty param.action && param.action == 'viewCondition'}">
        <div id="conditionModal" class="modal-overlay active">
            <div class="modal-card">
                <div class="modal-header">
                    <h3>🔍 Chi tiết tình trạng bảo hành sản phẩm</h3>
                    <a href="<%= ctx %>/ManageWarranty?search=<%= h(searchQuery) %>&statusFilter=<%= statusFilterId != null ? statusFilterId : "" %>&page=<%= currentPage %>&selectedWarrantyId=<%= selectedWarrantyId != null ? selectedWarrantyId : "" %>" class="modal-close" style="text-decoration: none;">&times;</a>
                </div>
                <div class="modal-body">
                    <div class="info-grid">
                        <div class="info-item">
                            <label>Sản phẩm</label>
                            <span><c:out value="${condItem.productName}"/></span>
                        </div>
                        <div class="info-item">
                            <label>Mã đơn hàng</label>
                            <span>#PB<c:out value="${condItem.orderId}"/></span>
                        </div>
                        <div class="info-item">
                            <label>Khách hàng</label>
                            <span><c:out value="${condItem.customerName}"/></span>
                        </div>
                        <div class="info-item">
                            <label>Thương hiệu / Loại</label>
                            <span><c:out value="${condItem.brandName}"/> / <c:out value="${condItem.categoryName}"/></span>
                        </div>
                        <div class="info-item">
                            <label>Ngày nhận hàng</label>
                            <span><fmt:formatDate value="${condItem.orderDate}" pattern="dd/MM/yyyy" /></span>
                        </div>
                        <div class="info-item">
                            <label>Thời hạn bảo hành</label>
                            <span><c:out value="${condItem.warrantyMonths}"/> tháng</span>
                        </div>
                        <div class="info-item">
                            <label>Ngày hết hạn</label>
                            <span><fmt:formatDate value="${condItem.warrantyEndDate}" pattern="dd/MM/yyyy" /></span>
                        </div>
                        <div class="info-item">
                            <label>Tình trạng bảo hành</label>
                            <c:set var="wState" value="${condItem.warrantyState}"/>
                            <span class="remaining-${wState}">
                                <c:out value="${condItem.warrantyStatusLabel}"/> (<c:out value="${condItem.remainingDaysLabel}"/>)
                            </span>
                        </div>
                    </div>

                    <div class="timeline-section">
                        <h4>📋 Lịch sử tiếp nhận & bảo hành sản phẩm này</h4>
                        <ul class="timeline-list">
                            <c:choose>
                                <c:when test="${not empty condHistory}">
                                    <c:forEach var="hist" items="${condHistory}" varStatus="loop">
                                        <li class="timeline-item ${loop.first ? 'active' : ''}">
                                            <div class="timeline-header">
                                                <span class="timeline-date"><fmt:formatDate value="${hist.requestDate}" pattern="dd/MM/yyyy HH:mm" /></span>
                                                <span class="status-badge status-${hist.statusId}">#WR${hist.warrantyId} - <c:out value="${hist.statusName}"/></span>
                                            </div>
                                            <div class="timeline-request">
                                                <strong>Khách mô tả:</strong> <c:out value="${hist.request}"/>
                                            </div>
                                            <c:if test="${not empty hist.responseDate}">
                                                <div class="timeline-response">
                                                    <strong>Phản hồi ngày:</strong> <fmt:formatDate value="${hist.responseDate}" pattern="dd/MM/yyyy HH:mm" />
                                                    <c:if test="${not empty hist.response}">
                                                        <div style="margin-top: 4px; font-weight: 500;">
                                                            Nội dung: "<c:out value="${hist.response}"/>"
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:if>
                                        </li>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <p style="color:#868e96; font-style:italic;">Không có lịch sử yêu cầu bảo hành trước đây cho sản phẩm này.</p>
                                </c:otherwise>
                            </c:choose>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <a href="<%= ctx %>/ManageWarranty?search=<%= h(searchQuery) %>&statusFilter=<%= statusFilterId != null ? statusFilterId : "" %>&page=<%= currentPage %>&selectedWarrantyId=<%= selectedWarrantyId != null ? selectedWarrantyId : "" %>" class="btn-reset" style="text-decoration: none;">Đóng</a>
                </div>
            </div>
        </div>
        </c:if>

        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
