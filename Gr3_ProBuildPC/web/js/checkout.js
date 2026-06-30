/**
 * Frontend Validation for Checkout Page
 */
function validateCheckoutForm(form) {
    // 1. Validate Address
    const addressIdInput = form.querySelector('[data-checkout-selected-address-id]');
    if (!addressIdInput || !addressIdInput.value || parseInt(addressIdInput.value, 10) <= 0) {
        alert("Vui lòng chọn địa chỉ giao hàng hợp lệ trước khi đặt hàng.");
        const toggleButton = document.querySelector('[data-checkout-address-toggle]');
        if (toggleButton) {
            toggleButton.focus();
        }
        return false;
    }

    // 2. Validate Note
    const noteInput = form.querySelector('[data-checkout-note]');
    if (noteInput) {
        const noteValue = noteInput.value;
        if (!Validator.validateNote(noteValue)) {
            alert("Ghi chú quá dài (tối đa 1000 ký tự).");
            noteInput.focus();
            return false;
        }
    }

    return true;
}

// Attach character counter for note real-time
document.addEventListener("DOMContentLoaded", function () {
    const noteField = document.querySelector('[data-checkout-note]');
    const noteCountElement = document.querySelector('[data-checkout-note-count]');
    if (noteField && noteCountElement) {
        noteField.addEventListener('input', function () {
            noteCountElement.textContent = String(noteField.value.length);
            if (noteField.value.length > 1000) {
                noteCountElement.style.color = '#ef4444';
            } else {
                noteCountElement.style.color = '';
            }
        });
    }
});
