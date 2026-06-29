<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý yêu cầu bảo hành - Dashboard</title>
        
        <link rel="stylesheet" type="text/css" href="${ctx}/css/style.css">
        <link rel="stylesheet" type="text/css" href="${ctx}/css/manage-warranty.css">
    </head>
    <body class="dashboard-body manage-warranty-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="warranty-shell">
            <!-- Breadcrumbs -->
            <nav class="warranty-breadcrumb" aria-label="breadcrumb">
                <a href="${ctx}/Dashboard">Dashboard</a>
                <span>›</span>
                <strong>Quản lý bảo hành</strong>
            </nav>

            <!-- Hero Header -->
            <div class="warranty-hero">
                <div class="warranty-hero-copy">
                    <h1>Quản lý yêu cầu bảo hành</h1>
                </div>
            </div>

            <!-- Success/Error Alerts -->
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="alert-box success">
                    <c:out value="${sessionScope.successMsg}"/>
                </div>
                <c:remove var="successMsg" scope="session"/>
            </c:if>
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="alert-box error">
                    <c:out value="${sessionScope.errorMsg}"/>
                </div>
                <c:remove var="errorMsg" scope="session"/>
            </c:if>

            <!-- Dynamic Statistics Counters via JSTL -->
            <c:set var="totalCount" value="0"/>
            <c:set var="pendingCount" value="0"/>
            <c:set var="rejectedCount" value="0"/>
            <c:set var="acceptedCount" value="0"/>

            <c:forEach var="w" items="${adminWarrantyList}">
                <c:set var="totalCount" value="${totalCount + 1}"/>
                <c:choose>
                    <c:when test="${w.statusId == 1}"><c:set var="pendingCount" value="${pendingCount + 1}"/></c:when>
                    <c:when test="${w.statusId == 2}"><c:set var="rejectedCount" value="${rejectedCount + 1}"/></c:when>
                    <c:when test="${w.statusId == 3}"><c:set var="acceptedCount" value="${acceptedCount + 1}"/></c:when>
                </c:choose>
            </c:forEach>

            <!-- Unified Panel matching Brand style -->
            <div class="brand-table-panel">
                <!-- Toolbar matching Brand style -->
                <div class="brand-toolbar">
                    <form class="brand-search-form" action="${ctx}/ManageWarranty" method="get">
                        <input 
                            type="text" 
                            name="search" 
                            placeholder="Nhập mã yêu cầu (VD: 1)..." 
                            value="<c:out value="${searchQuery}"/>"
                        >

                        <select name="statusId" onchange="this.form.submit()">
                            <option value="" ${empty param.statusId ? 'selected' : ''}>Tất cả trạng thái</option>
                            <option value="1" ${param.statusId == '1' ? 'selected' : ''}>Chờ tiếp nhận</option>
                            <option value="2" ${param.statusId == '2' ? 'selected' : ''}>Từ chối</option>
                            <option value="3" ${param.statusId == '3' ? 'selected' : ''}>Chấp nhận</option>
                        </select>

                        <button type="submit">Tìm kiếm</button>
                    </form>

                    <a href="${ctx}/ManageWarranty" class="brand-add-button" style="background-color: #ed1c24; text-decoration: none;">Làm mới</a>
                </div>

                <!-- Table Wrapper matching Brand style -->
                <div class="brand-table-wrap">
                    <table class="warranty-table">
                        <thead>
                            <tr>
                                <th>Mã yêu cầu</th>
                                <th>Mã đơn hàng</th>
                                <th>Khách hàng</th>
                                <th>Sản phẩm</th>
                                <th>Ngày gửi</th>
                                <th>Trạng thái</th>
                                <th>Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty adminWarrantyList}">
                                    <c:forEach var="item" items="${adminWarrantyList}">
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
                                                <div style="max-width: 240px; font-weight: 500; margin: 0 auto; text-align: left;">
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
                                                                Nội dung: "<c:out value="${item.response}"/>"
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
                                            
                                            <td>
                                                <div class="btn-action-group">
                                                    <!-- Share button: view warranty details -->
                                                    <a 
                                                        class="btn-action btn-view" 
                                                        href="${ctx}/ManageWarranty?action=viewCondition&productId=${item.productId}&customerId=${item.customerId}&search=<c:out value="${searchQuery}"/>&statusFilter=${statusFilterId}"
                                                    >
                                                        Xem tình trạng
                                                    </a>
                                                    
                                                    <!-- Employee exclusive action button -->
                                                    <c:if test="${sessionScope.account.roleName == 'EMPLOYEE'}">
                                                        <a 
                                                            class="btn-action btn-edit" 
                                                            href="${ctx}/ManageWarranty?action=edit&warrantyId=${item.warrantyId}&search=<c:out value="${searchQuery}"/>&statusFilter=${statusFilterId}"
                                                        >
                                                            Xử lý
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7">
                                            <div class="empty-table-state" style="padding: 40px 0; text-align: center; color: #7a808c; font-weight: 700;">
                                                Không tìm thấy yêu cầu bảo hành nào.
                                            </div>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>

        <!-- MODAL 1: VIEW WARRANTY CONDITION -->
        <div id="conditionModal" class="modal-overlay ${not empty condItem ? 'active' : ''}">
            <div class="modal-card">
                <div class="modal-header">
                    <h3>🔍 Chi tiết tình trạng bảo hành sản phẩm</h3>
                    <a href="${ctx}/ManageWarranty?search=<c:out value="${searchQuery}"/>&statusFilter=${statusFilterId}" class="modal-close" style="text-decoration: none;">&times;</a>
                </div>
                <div class="modal-body">
                    <!-- Product & Purchase Info Grid -->
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

                    <!-- Coverage History Timeline -->
                    <div class="timeline-section">
                        <h4>📋 Lịch sử tiếp nhận & bảo hành sản phẩm này</h4>
                        <ul class="timeline-list" id="condTimeline">
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
                    <a href="${ctx}/ManageWarranty?search=<c:out value="${searchQuery}"/>&statusFilter=${statusFilterId}" class="btn-reset" style="text-decoration: none;">Đóng</a>
                </div>
            </div>
        </div>

        <!-- MODAL 2: UPDATE WARRANTY STATUS & NOTES (EMPLOYEE ONLY) -->
        <c:if test="${sessionScope.account.roleName == 'EMPLOYEE'}">
            <div id="editModal" class="modal-overlay ${not empty editWarranty ? 'active' : ''}">
                <div class="modal-card">
                    <form id="edit-warranty-form" action="${ctx}/ManageWarranty" method="post">
                        <input type="hidden" name="search" value="<c:out value="${searchQuery}"/>">
                        <input type="hidden" name="statusFilter" value="<c:out value="${statusFilterId}"/>">
                        
                        <div class="modal-header">
                            <h3>⚙ Cập nhật yêu cầu bảo hành</h3>
                            <a href="${ctx}/ManageWarranty?search=<c:out value="${searchQuery}"/>&statusFilter=${statusFilterId}" class="modal-close" style="text-decoration: none;">&times;</a>
                        </div>
                        <div class="modal-body">
                            <input type="hidden" id="editWarrantyId" name="warrantyId" value="${editWarranty.warrantyId}">
                            
                            <div class="info-grid" style="margin-bottom: 20px;">
                                <div class="info-item">
                                    <label>Mã yêu cầu</label>
                                    <span>#WR${editWarranty.warrantyId} (Đơn hàng #PB${editWarranty.orderId})</span>
                                </div>
                                <div class="info-item">
                                    <label>Sản phẩm</label>
                                    <span style="font-size:14px; font-weight:600;"><c:out value="${editWarranty.productName}"/></span>
                                </div>
                            </div>

                            <!-- Update Status Dropdown -->
                            <div class="form-group">
                                <label for="editStatusId">Thay đổi trạng thái</label>
                                <select id="editStatusId" name="statusId" class="filter-select" required>
                                    <option value="1" ${editWarranty.statusId == 1 ? 'selected' : ''}>Chờ tiếp nhận</option>
                                    <option value="2" ${editWarranty.statusId == 2 ? 'selected' : ''}>Từ chối</option>
                                    <option value="3" ${editWarranty.statusId == 3 ? 'selected' : ''}>Chấp nhận</option>
                                </select>
                            </div>

                            <!-- Response Textarea -->
                            <div class="form-group" style="margin-top: 15px;">
                                <label for="editResponse">Phản hồi của cửa hàng</label>
                                <textarea id="editResponse" name="response" class="filter-select" style="width: 100%; height: 100px; padding: 10px; border: 1px solid #ced4da; border-radius: 4px; box-sizing: border-box; resize: vertical;" required><c:out value="${editWarranty.response}"/></textarea>
                            </div>

                        </div>
                        <div class="modal-footer">
                            <a href="${ctx}/ManageWarranty?search=<c:out value="${searchQuery}"/>&statusFilter=${statusFilterId}" class="btn-reset" style="text-decoration: none;">Hủy bỏ</a>
                            <button type="submit" class="btn-search">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </div>
        </c:if>

        <jsp:include page="/includes/footer.jsp" />
        
        <script src="${ctx}/js/validator.js"></script>
        <script src="${ctx}/js/warranty.js"></script>
    </body>
</html>
