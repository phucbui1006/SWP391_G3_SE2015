/**
 * Frontend validation for warranty lookup, request and response forms.
 * Backend validation remains the source of truth; these checks improve UX.
 */
document.addEventListener("DOMContentLoaded", function () {
    const validator = window.Validator;

    if (!validator) {
        return;
    }

    const getLengthMessage = (value, fieldName, minLength, maxLength) => {
        if (!value.trim()) {
            return `Vui lòng nhập ${fieldName}.`;
        }
        return `${fieldName.charAt(0).toUpperCase() + fieldName.slice(1)} phải từ ${minLength} đến ${maxLength} ký tự.`;
    };

    const validateTextLength = (input, fieldName, minLength, maxLength) => {
        const value = input.value.trim();
        const isValid = value.length >= minLength && value.length <= maxLength;

        validator.showFeedback(
                input,
                isValid,
                getLengthMessage(value, fieldName, minLength, maxLength)
                );
        input.setAttribute("aria-invalid", String(!isValid));
        return isValid;
    };

    const bindTextValidation = (input, validate) => {
        input.addEventListener("blur", validate);
        input.addEventListener("input", () => {
            if (input.classList.contains("is-invalid")) {
                validate();
            }
        });
    };

    const searchForm = document.getElementById("warranty-search-form");
    if (searchForm) {
        const orderIdInput = searchForm.querySelector("input[name='orderId']");
        const orderIdFeedback = document.getElementById("orderIdFeedback");

        const validateOrderId = () => {
            const value = orderIdInput.value.trim();
            const matchesFormat = /^(?:PB)?[0-9]+$/i.test(value);
            const digits = value.replace(/[^0-9]/g, "");
            const numericId = Number(digits);
            const isValid = matchesFormat
                    && Number.isInteger(numericId)
                    && numericId > 0
                    && numericId <= 2147483647;
            let message = "";

            if (!value) {
                message = "Vui lòng nhập mã đơn hàng.";
            } else if (!isValid) {
                message = "Mã đơn hàng phải là số dương hoặc bắt đầu bằng PB (ví dụ: PB10006).";
            }

            orderIdInput.classList.toggle("is-invalid", !isValid);
            orderIdInput.setAttribute("aria-invalid", String(!isValid));

            if (orderIdFeedback) {
                orderIdFeedback.textContent = message;
                orderIdFeedback.hidden = isValid;
            }

            return isValid;
        };

        orderIdInput.addEventListener("blur", validateOrderId);
        orderIdInput.addEventListener("input", () => {
            if (orderIdInput.classList.contains("is-invalid")) {
                validateOrderId();
            }
        });

        searchForm.addEventListener("submit", event => {
            if (!validateOrderId()) {
                event.preventDefault();
                orderIdInput.focus();
                return;
            }

            orderIdInput.value = orderIdInput.value.trim();
            const submitButton = searchForm.querySelector("button[type='submit']");
            if (submitButton) {
                submitButton.disabled = true;
                submitButton.textContent = "Đang kiểm tra...";
            }
        });
    }

    // Customer warranty request forms
    document.querySelectorAll(".wl-claim-form").forEach(form => {
        const requestInput = form.querySelector("textarea[name='request']");
        if (!requestInput) {
            return;
        }

        const validateRequest = () => validateTextLength(
                    requestInput,
                    "lý do bảo hành",
                    10,
                    1000
                    );

        bindTextValidation(requestInput, validateRequest);

        form.addEventListener("submit", event => {
            if (!validateRequest()) {
                event.preventDefault();
                requestInput.focus();
                return;
            }

            requestInput.value = requestInput.value.trim();
            const submitButton = form.querySelector("button[type='submit']");
            if (submitButton) {
                submitButton.disabled = true;
                submitButton.innerHTML = '<span class="wl-btn-spinner"></span> Đang gửi...';
            }
        });
    });

    // Employee warranty response form
    const editForm = document.getElementById("edit-warranty-form") || document.querySelector(".warranty-process-form");
    if (editForm) {
        const responseInput = editForm.querySelector("textarea[name='response']");
        const statusSelect = editForm.querySelector("select[name='statusId']");

        const validateResponse = () => {
            if (!responseInput) return true;
            return validateTextLength(
                    responseInput,
                    "phản hồi của cửa hàng",
                    5,
                    1000
                    );
        };

        const validateStatus = () => {
            if (!statusSelect) return true;
            const isValid = ["2", "3"].includes(statusSelect.value);
            validator.showFeedback(
                    statusSelect,
                    isValid,
                    "Vui lòng lựa chọn trạng thái bảo hành hợp lệ (Chấp nhận hoặc Từ chối)."
                    );
            statusSelect.setAttribute("aria-invalid", String(!isValid));
            return isValid;
        };

        if (responseInput) {
            bindTextValidation(responseInput, validateResponse);
        }
        if (statusSelect) {
            statusSelect.addEventListener("blur", validateStatus);
            statusSelect.addEventListener("change", validateStatus);
        }

        editForm.addEventListener("submit", event => {
            const isStatusValid = validateStatus();
            const isResponseValid = validateResponse();

            if (!isStatusValid || !isResponseValid) {
                event.preventDefault();
                if (!isStatusValid && statusSelect) {
                    statusSelect.focus();
                } else if (!isResponseValid && responseInput) {
                    responseInput.focus();
                }
                return;
            }

            if (responseInput) {
                responseInput.value = responseInput.value.trim();
            }
            const submitButton = editForm.querySelector("button[type='submit']");
            if (submitButton) {
                submitButton.disabled = true;
                submitButton.textContent = "Đang lưu...";
            }
        });
    }
});
