<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<fmt:setLocale value="vi_VN" />

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="orderIdInput" value="${requestScope.orderIdInput}" />
<c:set var="warrantyItems" value="${requestScope.warrantyItems}" />
<c:set var="orderInfo" value="${warrantyItems[0]}" />
<c:set var="isDelivered" value="${not empty orderInfo && orderInfo.orderStatusName == 'Đã giao hàng'}" />

<c:set var="statusClass" value="neutral" />
<c:if test="${not empty orderInfo.orderStatusName}">
    <c:set var="statusNameLower" value="${fn:toLowerCase(orderInfo.orderStatusName)}" />
    <c:choose>
        <c:when test="${fn:contains(statusNameLower, 'hủy')}">
            <c:set var="statusClass" value="cancelled" />
        </c:when>
        <c:when test="${fn:contains(statusNameLower, 'giao') || fn:contains(statusNameLower, 'hoàn')}">
            <c:set var="statusClass" value="complete" />
        </c:when>
        <c:when test="${fn:contains(statusNameLower, 'chờ') || fn:contains(statusNameLower, 'đang')}">
            <c:set var="statusClass" value="processing" />
        </c:when>
        <c:when test="${fn:contains(statusNameLower, 'xác nhận')}">
            <c:set var="statusClass" value="confirmed" />
        </c:when>
    </c:choose>
</c:if>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tra cứu bảo hành – ProBuild PC</title>
        <meta name="description" content="Tra cứu thời hạn bảo hành linh kiện PC theo mã đơn hàng tại ProBuild PC.">
        <link rel="stylesheet" type="text/css" href="${ctx}/css/style.css">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    </head>

    <body class="warranty-lookup-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="wl-shell">
            <div class="wl-container">
                <!-- 1. Breadcrumbs & Header sitting directly on the flat light background -->
                <nav class="wl-breadcrumb site-breadcrumb" aria-label="breadcrumb">
                    <a href="${ctx}/home">Trang chủ</a>
                    <span class="wl-breadcrumb-sep">›</span>
                    <span>Kiểm tra bảo hành</span>
                </nav>

                <header class="wl-page-header">
                    <h1 id="warranty-page-title">Kiểm tra bảo hành</h1>
                    <p class="wl-subtitle">Nhập mã đơn hàng để tra cứu trạng thái bảo hành từng linh kiện.</p>
                </header>

                <!-- 2. Two-Column Grid Layout -->
                <div class="wl-grid">
                    <!-- Left Column: Search & Results -->
                    <div class="wl-main-col">
                        <!-- Search Box Card -->
                        <div class="wl-card wl-search-card">
                            <form class="wl-search-form" id="warranty-search-form" action="${ctx}/warranty-lookup" method="get" autocomplete="off" novalidate>
                                <label for="orderId" class="wl-search-label">Nhập mã đơn hàng <span class="wl-required">*</span></label>
                                <div class="wl-search-input-wrapper">
                                    <div class="wl-search-field-container">
                                        <svg class="wl-search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                                        <input
                                            id="orderId"
                                            name="orderId"
                                            type="text"
                                            value="${fn:escapeXml(orderIdInput)}"
                                            placeholder="VD: 10006"
                                            maxlength="12"
                                            aria-describedby="orderIdFeedback"
                                            required>
                                    </div>
                                    <button type="submit" id="warranty-search-btn">
                                        Kiểm tra
                                    </button>
                                </div>
                                <small id="orderIdFeedback" class="wl-search-error" role="alert" hidden></small>
                            </form>
                        </div>

                        <!-- Alerts -->
                        <c:if test="${not empty warrantyLookupError}">
                            <div class="wl-alert wl-alert--error" role="alert">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                <c:out value="${warrantyLookupError}" />
                            </div>
                        </c:if>

                        <c:if test="${not empty sessionScope.warrantySuccessMessage}">
                            <div class="wl-alert wl-alert--success" role="alert">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                                <c:out value="${sessionScope.warrantySuccessMessage}" />
                            </div>
                            <c:remove var="warrantySuccessMessage" scope="session" />
                        </c:if>

                        <c:if test="${not empty sessionScope.warrantyFailMessage}">
                            <div class="wl-alert wl-alert--error" role="alert">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                <c:out value="${sessionScope.warrantyFailMessage}" />
                            </div>
                            <c:remove var="warrantyFailMessage" scope="session" />
                        </c:if>

                        <!-- Results Content -->
                        <c:choose>
                            <c:when test="${not empty warrantyItems}">
                                <!-- Order summary card -->
                                <section class="wl-order-strip" id="order-summary">
                                    <div class="wl-order-strip-main">
                                        <div class="wl-order-id-badge">
                                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                                            <strong>${orderInfo.orderId}</strong>
                                        </div>

                                        <div class="wl-strip-divider"></div>

                                        <div class="wl-order-detail-item">
                                            <span class="wl-detail-label">Ngày nhận</span>
                                            <span class="wl-detail-value">
                                                <c:choose>
                                                    <c:when test="${not empty orderInfo.deliveryDate}">
                                                        <fmt:formatDate value="${orderInfo.deliveryDate}" pattern="dd/MM/yyyy" />
                                                    </c:when>
                                                    <c:otherwise>Chưa cập nhật</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>

                                        <div class="wl-strip-divider"></div>

                                        <div class="wl-order-detail-item">
                                            <span class="wl-detail-label">Thanh toán</span>
                                            <span class="wl-detail-value">
                                                <c:choose>
                                                    <c:when test="${orderInfo.paymentMethod == 'COD'}">Thanh toán khi nhận hàng</c:when>
                                                    <c:when test="${orderInfo.paymentMethod == 'VNPAY'}">Thanh toán qua VNPAY</c:when>
                                                    <c:otherwise>${empty orderInfo.paymentMethod ? 'Chưa cập nhật' : orderInfo.paymentMethod}</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>

                                        <div class="wl-strip-divider"></div>

                                        <div class="wl-order-detail-item">
                                            <span class="wl-detail-label">Tổng giá trị</span>
                                            <span class="wl-detail-value wl-detail-value--price">
                                                <fmt:formatNumber value="${orderInfo.totalAmount}" type="number" groupingUsed="true" />đ
                                            </span>
                                        </div>
                                    </div>

                                    <span class="wl-order-status-pill wl-order-status--${statusClass}">
                                        <c:out value="${empty orderInfo.orderStatusName ? 'Chưa cập nhật' : orderInfo.orderStatusName}" />
                                    </span>
                                </section>

                                <c:if test="${!isDelivered}">
                                    <div class="wl-notice wl-notice--warn" id="delivery-notice">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                        <span>Bảo hành chỉ áp dụng cho đơn hàng đã giao thành công. Đơn hàng này hiện chưa đủ điều kiện.</span>
                                    </div>
                                </c:if>

                                <section class="wl-products" id="warranty-products">
                                    <div class="wl-products-header">
                                        <h2>Danh sách linh kiện</h2>
                                        <span class="wl-product-count">${fn:length(warrantyItems)} sản phẩm</span>
                                    </div>

                                    <div class="wl-product-list">
                                        <c:forEach items="${warrantyItems}" var="item">
                                            <c:choose>
                                                <c:when test="${empty item.imageUrl}">
                                                    <c:set var="imageSrc" value="${ctx}/images/background.jpg" />
                                                </c:when>
                                                <c:when test="${fn:startsWith(item.imageUrl, 'http://') || fn:startsWith(item.imageUrl, 'https://')}">
                                                    <c:set var="imageSrc" value="${item.imageUrl}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="imageSrc" value="${ctx}/${item.imageUrl}" />
                                                </c:otherwise>
                                            </c:choose>
                                            
                                            <c:set var="isWarrantyValid" value="${item.remainingDays > 0 && item.warrantyMonths > 0 && not empty item.warrantyEndDate}" />

                                            <article class="wl-product-card" id="product-${item.productId}">
                                                <div class="wl-product-info">
                                                    <img class="wl-product-img"
                                                         src="${fn:escapeXml(imageSrc)}"
                                                         alt="${fn:escapeXml(empty item.productName ? 'Sản phẩm' : item.productName)}"
                                                         loading="lazy">

                                                    <div class="wl-product-text">
                                                        <h3 class="wl-product-name" title="${fn:escapeXml(empty item.productName ? 'Sản phẩm' : item.productName)}">
                                                            <c:out value="${empty item.productName ? 'Sản phẩm' : item.productName}" />
                                                        </h3>
                                                        <div class="wl-product-meta">
                                                            <span class="wl-meta-tag"><c:out value="${empty item.categoryName ? 'Khác' : item.categoryName}" /></span>
                                                            <span class="wl-meta-tag"><c:out value="${empty item.brandName ? 'Khác' : item.brandName}" /></span>
                                                            <span class="wl-meta-tag wl-meta-tag--qty">SL: ${item.quantity}</span>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="wl-warranty-timeline">
                                                    <div class="wl-timeline-top">
                                                        <span class="wl-remaining-days wl-state-${item.warrantyState}">
                                                            <c:out value="${item.remainingDaysLabel}" />
                                                        </span>
                                                        <span class="wl-warranty-badge wl-state-${item.warrantyState}">
                                                            <c:out value="${item.warrantyStatusLabel}" />
                                                        </span>
                                                    </div>
                                                    <div class="wl-timeline-bottom">
                                                        <span>Hết hạn: 
                                                            <c:choose>
                                                                <c:when test="${not empty item.warrantyEndDate}">
                                                                    <fmt:formatDate value="${item.warrantyEndDate}" pattern="dd/MM/yyyy" />
                                                                </c:when>
                                                                <c:otherwise>Chưa có dữ liệu</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                        <span class="wl-timeline-sep">•</span>
                                                        <span>${item.warrantyMonths} tháng bảo hành</span>
                                                    </div>
                                                </div>

                                                <div class="wl-product-action">
                                                    <c:choose>
                                                        <c:when test="${isDelivered && isWarrantyValid}">
                                                            <c:choose>
                                                                <c:when test="${item.statusId == 1}">
                                                                    <span class="wl-status-badge wl-status-badge--pending">
                                                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                                                        <c:out value="${item.statusName}" />
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    
                                                                    <form class="wl-claim-form"
                                                                          action="${ctx}/warranty-lookup"
                                                                          method="post"
                                                                          novalidate>

                                                                        <input type="hidden" name="action" value="createRequest">
                                                                        <input type="hidden" name="orderId" value="${orderInfo.orderId}">
                                                                        <input type="hidden" name="productId" value="${item.productId}">

                                                                        <textarea
                                                                            name="request"
                                                                            class="wl-claim-textarea"
                                                                            rows="2"
                                                                            placeholder="Mô tả lỗi sản phẩm..."
                                                                            minlength="10"
                                                                            maxlength="1000"
                                                                            required></textarea>

                                                                        <button type="submit" class="wl-btn wl-btn--primary">
                                                                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
                                                                            Gửi yêu cầu
                                                                        </button>
                                                                    </form>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:when test="${isDelivered && !isWarrantyValid}">
                                                            <span class="wl-status-badge wl-status-badge--expired">
                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                                                Hết hạn bảo hành
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="wl-status-badge wl-status-badge--locked">
                                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                                                Chờ giao hàng
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </article>
                                        </c:forEach>
                                    </div>

                                    <p class="wl-footnote">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                        Thời gian bảo hành được tính từ ngày nhận hàng. Nếu chưa có ngày nhận, hệ thống sử dụng ngày đặt hàng để tính toán.
                                    </p>
                                </section>
                            </c:when>
                            <c:otherwise>
                                <!-- ═══════════════ EMPTY STATE ALERT CARD ═══════════════ -->
                                <div class="wl-empty-alert-card" id="warranty-empty">
                                    <div class="wl-empty-alert-icon">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                            <circle cx="12" cy="12" r="10"/>
                                            <line x1="12" y1="16" x2="12" y2="12"/>
                                            <line x1="12" y1="8" x2="12.01" y2="8"/>
                                        </svg>
                                    </div>
                                    <div class="wl-empty-alert-content">
                                        Chưa có đơn hàng để hiển thị - Nhập order ID trong hệ thống để xem ngày hết hạn bảo hành của từng linh kiện.
                                    </div>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Right Column: Sidebar (Warranty Policy) -->
                    <div class="wl-side-col">
                        <div class="wl-card wl-policy-card" id="warranty-policy">
                            <h3 class="wl-policy-title">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                                </svg>
                                Chính sách bảo hành
                            </h3>
                            <div class="wl-policy-list">
                                <div class="wl-policy-item">
                                    <div class="wl-policy-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                                    </div>
                                    <p>Sản phẩm được bảo hành theo chính sách của nhà sản xuất.</p>
                                </div>
                                <div class="wl-policy-item">
                                    <div class="wl-policy-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                    </div>
                                    <p>Thời gian bảo hành có thể khác nhau tùy thuộc vào từng sản phẩm.</p>
                                </div>
                                <div class="wl-policy-item">
                                    <div class="wl-policy-icon">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                                    </div>
                                    <p>Vui lòng liên hệ <strong>0368.176.253</strong> nếu bạn cần hỗ trợ thêm.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <jsp:include page="/includes/footer.jsp" />

        <script src="${ctx}/js/validator.js"></script>
        <script src="${ctx}/js/warranty.js"></script>
    </body>
</html>
