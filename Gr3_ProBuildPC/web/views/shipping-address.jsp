<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Address" %>
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

    private int parseIntOrDefault(Object value, int fallback) {
        if (value == null) {
            return fallback;
        }

        try {
            return Integer.parseInt(String.valueOf(value));
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private String addressDetailOnly(String value, String fixedSuffix) {
        if (value == null) {
            return "";
        }

        String trimmedValue = value.trim();
        String suffix = fixedSuffix == null ? "" : fixedSuffix.trim();

        if (!suffix.isEmpty() && trimmedValue.toLowerCase().endsWith(suffix.toLowerCase())) {
            trimmedValue = trimmedValue.substring(0, trimmedValue.length() - suffix.length()).trim();
        }

        while (trimmedValue.endsWith(",")) {
            trimmedValue = trimmedValue.substring(0, trimmedValue.length() - 1).trim();
        }

        return trimmedValue;
    }
%>

<%
    User account = (User) session.getAttribute("account");
    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/Login");
        return;
    }

    List<Address> addresses = (List<Address>) request.getAttribute("addresses");
    if (addresses == null) {
        addresses = Collections.emptyList();
    }

    String formAction = String.valueOf(request.getAttribute("formAction") != null ? request.getAttribute("formAction") : "create");
    String formAddressId = String.valueOf(request.getAttribute("formAddressId") != null ? request.getAttribute("formAddressId") : "");
    String formRecipientName = String.valueOf(request.getAttribute("formRecipientName") != null ? request.getAttribute("formRecipientName") : "");
    String formPhoneNumber = String.valueOf(request.getAttribute("formPhoneNumber") != null ? request.getAttribute("formPhoneNumber") : "");
    String formAddressDetail = String.valueOf(request.getAttribute("formAddressDetail") != null ? request.getAttribute("formAddressDetail") : "");
    String fixedAddressSuffix = String.valueOf(request.getAttribute("fixedAddressSuffix") != null
            ? request.getAttribute("fixedAddressSuffix")
            : "Xã Hòa Lạc, Hà Nội");
    boolean editMode = "update".equalsIgnoreCase(formAction);
    int activeAddressId = parseIntOrDefault(request.getAttribute("activeAddressId"), -1);
%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>&#272;&#7883;a ch&#7881; giao h&#224;ng</title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body class="shipping-address-page">
        <jsp:include page="/includes/header.jsp" />

        <main class="shipping-address-shell">
            <div class="shipping-address-breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Trang ch&#7911;</a>
                <span class="shipping-address-breadcrumb-separator">/</span>
                <span class="active">&#272;&#7883;a ch&#7881; giao h&#224;ng</span>
            </div>

            <% if (request.getAttribute("successMsg") != null) { %>
            <div class="alert-message alert-success shipping-address-feedback">
                <%= request.getAttribute("successMsg") %>
            </div>
            <% } %>

            <% if (request.getAttribute("errorMsg") != null) { %>
            <div class="alert-message alert-danger shipping-address-feedback">
                <%= request.getAttribute("errorMsg") %>
            </div>
            <% } %>

            <div class="shipping-address-grid">
                <section class="shipping-address-panel">
                    <div class="shipping-address-panel-header">
                        <div>
                            <h1>&#272;&#7883;a ch&#7881; &#273;&#227; l&#432;u</h1>
                        </div>
                        <span class="shipping-address-count"><%= addresses.size() %> m&#7909;c</span>
                    </div>

                    <div class="shipping-address-panel-body">
                        <% if (addresses.isEmpty()) { %>
                        <div class="shipping-address-empty-state">
                            <div class="shipping-address-empty-icon">
                                <svg viewBox="0 0 24 24" aria-hidden="true">
                                    <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7Zm0 9.5A2.5 2.5 0 1 1 12 6.5a2.5 2.5 0 0 1 0 5Z"></path>
                                </svg>
                            </div>
                            <h3>Ch&#432;a c&#243; &#273;&#7883;a ch&#7881; giao h&#224;ng</h3>
                            <p>H&#227;y th&#234;m &#273;&#7883;a ch&#7881; &#273;&#7847;u ti&#234;n &#273;&#7875; s&#7861;n s&#224;ng cho c&#225;c &#273;&#417;n h&#224;ng ti&#7871;p theo.</p>
                        </div>
                        <% } else { %>
                        <div class="shipping-address-list">
                            <% for (Address address : addresses) { %>
                            <article class="shipping-address-card <%= address.getAddressId() == activeAddressId ? "is-editing" : "" %>"
                                     data-address-card
                                     data-address-id="<%= address.getAddressId() %>">
                                <div class="shipping-address-card-main">
                                    <div class="shipping-address-card-icon" aria-hidden="true">
                                        <svg viewBox="0 0 24 24">
                                            <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7Zm0 9.5A2.5 2.5 0 1 1 12 6.5a2.5 2.5 0 0 1 0 5Z"></path>
                                        </svg>
                                    </div>

                                    <div class="shipping-address-card-copy">
                                        <div class="shipping-address-name-row">
                                            <h3><%= h(address.getRecipientName()) %></h3>
                                            <span class="shipping-address-badge">&#272;ang ch&#7881;nh s&#7917;a</span>
                                        </div>

                                        <p class="shipping-address-phone"><%= h(address.getPhoneNumber()) %></p>
                                        <p class="shipping-address-detail"><%= h(address.getAddressDetail()) %></p>
                                    </div>
                                </div>

                                <div class="shipping-address-card-actions">
                                    <a href="${pageContext.request.contextPath}/shipping-address?editId=<%= address.getAddressId() %>"
                                       class="shipping-address-card-btn is-secondary"
                                       data-address-edit
                                       data-address-id="<%= address.getAddressId() %>"
                                       data-recipient-name="<%= h(address.getRecipientName()) %>"
                                       data-phone-number="<%= h(address.getPhoneNumber()) %>"
                                       data-address-detail="<%= h(addressDetailOnly(address.getAddressDetail(), fixedAddressSuffix)) %>">
                                        C&#7853;p nh&#7853;t
                                    </a>

                                    <form action="${pageContext.request.contextPath}/shipping-address"
                                          method="post"
                                          onsubmit="return confirm('B&#7841;n c&#243; ch&#7855;c mu&#7889;n x&#243;a &#273;&#7883;a ch&#7881; n&#224;y kh&#244;ng?');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="addressId" value="<%= address.getAddressId() %>">
                                        <button type="submit" class="shipping-address-card-btn is-danger">
                                            X&#243;a
                                        </button>
                                    </form>
                                </div>
                            </article>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                </section>

                <aside class="shipping-address-panel shipping-address-form-panel">
                    <div class="shipping-address-panel-header">
                        <div>
                            <span class="shipping-address-kicker">Th&#244;ng tin nh&#7853;n h&#224;ng</span>
                            <h2 data-form-heading><%= editMode ? "C&#7853;p nh&#7853;t &#273;&#7883;a ch&#7881;" : "Th&#234;m / C&#7853;p nh&#7853;t &#273;&#7883;a ch&#7881;" %></h2>
                        </div>

                        <button type="button"
                                class="shipping-address-reset-btn <%= editMode ? "is-visible" : "" %>"
                                data-address-reset>
                            Th&#234;m &#273;&#7883;a ch&#7881; m&#7899;i
                        </button>
                    </div>

                    <div class="shipping-address-panel-body">
                        <form id="shippingAddressForm"
                              action="${pageContext.request.contextPath}/shipping-address"
                              method="post"
                              class="shipping-address-form"
                              data-base-url="${pageContext.request.contextPath}/shipping-address"
                              data-default-recipient-name="<%= h(account.getFullName()) %>">
                            <input type="hidden" id="shippingAddressAction" name="action" value="<%= editMode ? "update" : "create" %>">
                            <input type="hidden" id="shippingAddressId" name="addressId" value="<%= h(formAddressId) %>">

                            <div class="shipping-address-field">
                                <label for="recipientName">T&#234;n ng&#432;&#7901;i nh&#7853;n <span>*</span></label>
                                <input type="text"
                                       id="recipientName"
                                       name="recipientName"
                                       value="<%= h(formRecipientName) %>"
                                       placeholder="Nh&#7853;p t&#234;n ng&#432;&#7901;i nh&#7853;n"
                                       required>
                            </div>

                            <div class="shipping-address-field">
                                <label for="phoneNumber">S&#7889; &#273;i&#7879;n tho&#7841;i <span>*</span></label>
                                <input type="text"
                                       id="phoneNumber"
                                       name="phoneNumber"
                                       value="<%= h(formPhoneNumber) %>"
                                       placeholder="Nh&#7853;p s&#7889; &#273;i&#7879;n tho&#7841;i"
                                       required>
                            </div>

                            <div class="shipping-address-field">
                                <label for="addressDetail">&#272;&#7883;a ch&#7881; chi ti&#7871;t <span>*</span></label>
                                <div class="shipping-address-detail-composer">
                                    <input type="text"
                                           id="addressDetail"
                                           name="addressDetail"
                                           value="<%= h(formAddressDetail) %>"
                                           placeholder="S&#7889; 12, Th&#244;n 4"
                                           required>
                                    <span class="shipping-address-detail-suffix">, <%= h(fixedAddressSuffix) %></span>
                                </div>
                                <p class="shipping-address-detail-example">
                                    V&#237; d&#7909;: S&#7889; 12, Th&#244;n 4, <strong><%= h(fixedAddressSuffix) %></strong>
                                </p>
                            </div>

                            <div class="shipping-address-form-actions">
                                <button type="submit" class="shipping-address-primary-btn">
                                    <span data-submit-label><%= editMode ? "L&#432;u thay &#273;&#7893;i" : "L&#432;u &#273;&#7883;a ch&#7881;" %></span>
                                </button>
                            </div>
                        </form>

                        <div class="shipping-address-note">
                            <strong>&#272;&#7883;a ch&#7881; c&#7889; &#273;&#7883;nh</strong>
                            <p>&#272;&#7883;a ch&#7881; giao h&#224;ng &#273;&#432;&#7907;c c&#7889; &#273;&#7883;nh t&#7841;i <strong><%= h(fixedAddressSuffix) %></strong>.</p>
                        </div>
                    </div>
                </aside>
            </div>
        </main>

        <script>
            (function () {
                const form = document.getElementById('shippingAddressForm');
                const actionInput = document.getElementById('shippingAddressAction');
                const addressIdInput = document.getElementById('shippingAddressId');
                const recipientInput = document.getElementById('recipientName');
                const phoneInput = document.getElementById('phoneNumber');
                const detailInput = document.getElementById('addressDetail');
                const submitLabel = document.querySelector('[data-submit-label]');
                const formHeading = document.querySelector('[data-form-heading]');
                const resetButton = document.querySelector('[data-address-reset]');
                const editButtons = document.querySelectorAll('[data-address-edit]');
                const addressCards = document.querySelectorAll('[data-address-card]');

                if (!form || !actionInput || !addressIdInput || !recipientInput || !phoneInput || !detailInput) {
                    return;
                }

                const baseUrl = form.dataset.baseUrl || window.location.pathname;
                const defaultRecipientName = form.dataset.defaultRecipientName || '';

                const setEditingCard = function (addressId) {
                    addressCards.forEach(function (card) {
                        const isActive = card.dataset.addressId === String(addressId);
                        card.classList.toggle('is-editing', isActive);

                        const badge = card.querySelector('.shipping-address-badge');
                        if (badge) {
                            badge.style.display = isActive ? 'inline-flex' : 'none';
                        }
                    });
                };

                const resetFormState = function () {
                    actionInput.value = 'create';
                    addressIdInput.value = '';
                    recipientInput.value = defaultRecipientName;
                    phoneInput.value = '';
                    detailInput.value = '';

                    if (submitLabel) {
                        submitLabel.textContent = 'L\u01b0u \u0111\u1ecba ch\u1ec9';
                    }

                    if (formHeading) {
                        formHeading.textContent = 'Th\u00eam / C\u1eadp nh\u1eadt \u0111\u1ecba ch\u1ec9';
                    }

                    if (resetButton) {
                        resetButton.classList.remove('is-visible');
                    }

                    setEditingCard('');

                    if (window.history && typeof window.history.replaceState === 'function') {
                        window.history.replaceState({}, document.title, baseUrl);
                    }
                };

                const switchToEditMode = function (button) {
                    if (!button) {
                        return;
                    }

                    actionInput.value = 'update';
                    addressIdInput.value = button.dataset.addressId || '';
                    recipientInput.value = button.dataset.recipientName || '';
                    phoneInput.value = button.dataset.phoneNumber || '';
                    detailInput.value = button.dataset.addressDetail || '';

                    if (submitLabel) {
                        submitLabel.textContent = 'L\u01b0u thay \u0111\u1ed5i';
                    }

                    if (formHeading) {
                        formHeading.textContent = 'C\u1eadp nh\u1eadt \u0111\u1ecba ch\u1ec9';
                    }

                    if (resetButton) {
                        resetButton.classList.add('is-visible');
                    }

                    setEditingCard(button.dataset.addressId || '');

                    if (window.history && typeof window.history.replaceState === 'function') {
                        window.history.replaceState({}, document.title, baseUrl + '?editId=' + encodeURIComponent(button.dataset.addressId || ''));
                    }

                    if (window.innerWidth < 992) {
                        form.scrollIntoView({behavior: 'smooth', block: 'start'});
                    }
                };

                editButtons.forEach(function (button) {
                    button.addEventListener('click', function (event) {
                        event.preventDefault();
                        switchToEditMode(button);
                    });
                });

                if (resetButton) {
                    resetButton.addEventListener('click', function () {
                        resetFormState();
                    });
                }
            })();
        </script>
    </body>
</html>
