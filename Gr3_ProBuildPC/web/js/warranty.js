/**
 * Frontend Validation for Warranty Module
 * Uses centralized Validator library.
 */
document.addEventListener("DOMContentLoaded", function () {
    // ══════════════════════════════════════════════════════════
    // 1. CLIENT WARRANTY REQUEST FORM VALIDATION
    // ══════════════════════════════════════════════════════════
    const claimForms = document.querySelectorAll(".wl-claim-form");

    claimForms.forEach(form => {
        const requestInput = form.querySelector("textarea[name='request']");

        if (requestInput) {
            // Real-time validation on blur
            requestInput.addEventListener("blur", () => {
                const val = requestInput.value.trim();
                const isValid = val.length >= 10 && val.length <= 1000;
                Validator.showFeedback(
                    requestInput,
                    isValid,
                    "Lý do bảo hành phải từ 10 đến 1000 ký tự."
                );
            });

            // Real-time validation on input (only if it was marked invalid before)
            requestInput.addEventListener("input", () => {
                if (requestInput.classList.contains("is-invalid")) {
                    const val = requestInput.value.trim();
                    const isValid = val.length >= 10 && val.length <= 1000;
                    Validator.showFeedback(
                        requestInput,
                        isValid,
                        "Lý do bảo hành phải từ 10 đến 1000 ký tự."
                    );
                }
            });
        }

        form.addEventListener("submit", (e) => {
            if (requestInput) {
                const val = requestInput.value.trim();
                const isValid = val.length >= 10 && val.length <= 1000;
                Validator.showFeedback(
                    requestInput,
                    isValid,
                    "Lý do bảo hành phải từ 10 đến 1000 ký tự."
                );

                if (!isValid) {
                    e.preventDefault();
                    requestInput.focus();
                    return;
                }
            }

            // Disable button and display spinner on valid submission
            const btn = form.querySelector('button[type="submit"]');
            if (btn) {
                btn.disabled = true;
                btn.innerHTML = '<span class="wl-btn-spinner"></span> Đang gửi...';
            }
        });
    });

    // ══════════════════════════════════════════════════════════
    // 2. EMPLOYEE WARRANTY UPDATE FORM VALIDATION
    // ══════════════════════════════════════════════════════════
    const editForm = document.getElementById("edit-warranty-form");
    if (editForm) {
        const responseInput = editForm.querySelector("textarea[name='response']");
        const statusSelect = editForm.querySelector("select[name='statusId']");

        if (responseInput) {
            // Real-time validation on blur
            responseInput.addEventListener("blur", () => {
                const val = responseInput.value.trim();
                const isValid = val.length >= 5 && val.length <= 1000;
                Validator.showFeedback(
                    responseInput,
                    isValid,
                    "Phản hồi của cửa hàng phải từ 5 đến 1000 ký tự."
                );
            });

            // Real-time validation on input
            responseInput.addEventListener("input", () => {
                if (responseInput.classList.contains("is-invalid")) {
                    const val = responseInput.value.trim();
                    const isValid = val.length >= 5 && val.length <= 1000;
                    Validator.showFeedback(
                        responseInput,
                        isValid,
                        "Phản hồi của cửa hàng phải từ 5 đến 1000 ký tự."
                    );
                }
            });
        }

        editForm.addEventListener("submit", (e) => {
            let isFormValid = true;

            // Validate response text
            if (responseInput) {
                const val = responseInput.value.trim();
                const isValid = val.length >= 5 && val.length <= 1000;
                Validator.showFeedback(
                    responseInput,
                    isValid,
                    "Phản hồi của cửa hàng phải từ 5 đến 1000 ký tự."
                );
                if (!isValid) {
                    isFormValid = false;
                    responseInput.focus();
                }
            }

            // Validate status value selection
            if (statusSelect) {
                const val = statusSelect.value;
                const isValid = val === "1" || val === "2" || val === "3";
                Validator.showFeedback(
                    statusSelect,
                    isValid,
                    "Vui lòng lựa chọn trạng thái bảo hành hợp lệ."
                );
                if (!isValid) {
                    isFormValid = false;
                    if (isFormValid) statusSelect.focus();
                }
            }

            if (!isFormValid) {
                e.preventDefault();
            }
        });
    }
});
