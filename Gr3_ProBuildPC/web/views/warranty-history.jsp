<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Lịch sử yêu cầu bảo hành</title>
        <link rel="stylesheet" type="text/css" href="${ctx}/css/style.css">
        <link rel="stylesheet" type="text/css" href="${ctx}/css/warranty-history.css">
    </head>
    <body class="warranty-history-page">
        <jsp:include page="/includes/header.jsp" />

        <!-- Full-Width Background Wrapper -->
        <div class="history-shell-wrapper">
            <!-- Centered Content Wrapper -->
            <main class="history-shell">
                <nav class="history-breadcrumb site-breadcrumb" aria-label="breadcrumb">
                    <a href="${ctx}/home">Trang chủ</a>
                    <span>›</span>
                    <strong>Lịch sử bảo hành</strong>
                </nav>

                <!-- Top Search Card -->
                <div class="warranty-tracking-card">
                    <header class="tracking-header">
                        <h2>Tra cứu yêu cầu bảo hành</h2>
                        <p>Nhập mã yêu cầu hoặc chọn trạng thái để kiểm tra tiến độ xử lý bảo hành linh kiện.</p>
                    </header>

                    <!-- Filter & Search Bar (Compact Horizontal Row) -->
                    <form class="tracking-filter-form" action="${ctx}/warranty-history" method="get">
                        <div class="filter-form-row">
                            <div class="filter-form-group input-product">
                                <label for="searchProduct" class="filter-label">SẢN PHẨM</label>
                                <input 
                                    type="text" 
                                    id="searchProduct" 
                                    name="searchProduct" 
                                    value="<c:out value="${searchProduct}"/>" 
                                    placeholder="Nhập mã yêu cầu hoặc tên sản phẩm..."
                                    class="filter-input"
                                >
                            </div>

                            <div class="filter-form-group input-status">
                                <label for="status" class="filter-label">TRẠNG THÁI</label>
                                <select 
                                    id="status" 
                                    name="statusId" 
                                    class="filter-select"
                                >
                                    <option value="" ${empty param.statusId ? 'selected' : ''}>Tất cả trạng thái</option>
                                    <option value="1" ${param.statusId == '1' ? 'selected' : ''}>Chờ tiếp nhận</option>
                                    <option value="2" ${param.statusId == '2' ? 'selected' : ''}>Từ chối</option>
                                    <option value="3" ${param.statusId == '3' ? 'selected' : ''}>Chấp nhận</option>
                                </select>
                            </div>

                            <div class="filter-form-group filter-actions">
                                <button type="submit" class="btn-filter-submit">Tìm kiếm</button>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Bottom Results Card Container -->
                <div class="tracking-results-card">
                    <div class="tracking-results">
                        <c:choose>
                            <c:when test="${not empty clientWarrantyList}">
                                <div class="history-table-wrapper">
                                    <table class="history-table">
                                        <thead>
                                            <tr>
                                                <th>Mã yêu cầu</th>
                                                <th>Mã đơn hàng</th>
                                                <th>Khách hàng</th>
                                                <th>Sản phẩm</th>
                                                <th>Ngày gửi</th>
                                                <th>Trạng thái</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="item" items="${clientWarrantyList}">
                                                <tr>
                                                    <td>
                                                        <span class="req-id">#WR${item.warrantyId}</span>
                                                    </td>
                                                    <td>
                                                        <span class="order-link">#PB${item.orderId}</span>
                                                    </td>
                                                    <td>
                                                        <strong><c:out value="${item.customerName}"/></strong>
                                                    </td>
                                                    <td>
                                                        <div style="max-width: 250px; font-weight: 500;">
                                                            <c:out value="${item.productName}"/>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div style="font-size: 13px; color: #555;">
                                                            <div>Gửi: <fmt:formatDate value="${item.requestDate}" pattern="dd/MM/yyyy HH:mm" /></div>
                                                            <c:if test="${not empty item.responseDate}">
                                                                <div style="margin-top: 6px; font-size: 12px; color: #2b8a3e; font-weight: 500;">
                                                                    Phản hồi: <fmt:formatDate value="${item.responseDate}" pattern="dd/MM/yyyy HH:mm" />
                                                                </div>
                                                                <c:if test="${not empty item.response}">
                                                                    <div style="margin-top: 4px; font-size: 12px; color: #495057; font-style: italic;">
                                                                         phản hồi: "<c:out value="${item.response}"/>"
                                                                    </div>
                                                                </c:if>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <span class="status-badge status-${item.statusId}">
                                                            <c:out value="${item.statusName}"/>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>

                                <%
                                    Integer totalPagesObj = (Integer) request.getAttribute("totalPages");
                                    Integer currentPageObj = (Integer) request.getAttribute("currentPage");
                                    String pagingUrl = (String) request.getAttribute("pagingUrl");
                                    int totalPages = totalPagesObj != null ? totalPagesObj : 1;
                                    int currentPage = currentPageObj != null ? currentPageObj : 1;
                                    if (pagingUrl == null) pagingUrl = "";
                                    if (totalPages > 1) {
                                %>
                                <div class="home-pagination">
                                    <% if (currentPage > 1) { %>
                                    <a href="<%= pagingUrl + (currentPage - 1) %>">Trước</a>
                                    <% } %>

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
                                    <a class="<%= currentPage == 1 ? "active" : "" %>" href="<%= pagingUrl + 1 %>">1</a>
                                    <% if (fromPage > 2) { %>
                                    <span>...</span>
                                    <% } %>
                                    <% for (int i = fromPage; i <= toPage; i++) { %>
                                    <a class="<%= currentPage == i ? "active" : "" %>" href="<%= pagingUrl + i %>">
                                        <%= i %>
                                    </a>
                                    <% } %>
                                    <% if (toPage < totalPages - 1) { %>
                                    <span>...</span>
                                    <% } %>
                                    <% if (totalPages > 1) { %>
                                    <a class="<%= currentPage == totalPages ? "active" : "" %>" href="<%= pagingUrl + totalPages %>">
                                        <%= totalPages %>
                                    </a>
                                    <% } %>

                                    <% if (currentPage < totalPages) { %>
                                    <a href="<%= pagingUrl + (currentPage + 1) %>">Sau</a>
                                    <% } %>
                                </div>
                                <% } %>
                            </c:when>
                            <c:otherwise>
                                <div class="tracking-empty-state">
                                   
                                    <c:choose>
                                        <c:when test="${not empty searchProduct or not empty filterStatusId}">
                                            <h2>Không tìm thấy kết quả phù hợp</h2>
                                            <p>Không tìm thấy yêu cầu bảo hành nào khớp với sản phẩm hoặc trạng thái bạn đã chọn. Vui lòng thử lại với từ khóa khác.</p>
                                            <a href="${ctx}/warranty-history" class="btn-primary-red">Xóa bộ lọc</a>
                                        </c:when>
                                        <c:otherwise>
                                            <h2>Không tìm thấy yêu cầu bảo hành nào</h2>
                                            <p>Bạn chưa gửi bất kỳ yêu cầu bảo hành nào. Nếu sản phẩm của bạn bị lỗi hoặc gặp sự cố, bạn có thể tra cứu và gửi yêu cầu bảo hành ngay lập tức.</p>
                                            <a href="${ctx}/warranty-lookup" class="btn-primary-red">Tra cứu & gửi yêu cầu</a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </main>
        </div>

        <jsp:include page="/includes/footer.jsp" />
    </body>
</html>
