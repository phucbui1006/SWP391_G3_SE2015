function showQuantityError(message) {
    if (typeof Swal === 'undefined') {
        return;
    }

    Swal.fire({
        title: 'Số lượng không hợp lệ!',
        text: message,
        icon: 'warning',
        timer: 3000,
        showConfirmButton: false,
        toast: true,
        position: 'bottom-end'
    });
}

function isTypingNumberKey(event) {
    return event.key.length === 1 && /^\d$/.test(event.key);
}

function isControlKey(event) {
    return event.ctrlKey || event.metaKey || [
        'Backspace',
        'Delete',
        'Tab',
        'Enter',
        'Escape',
        'ArrowLeft',
        'ArrowRight',
        'ArrowUp',
        'ArrowDown',
        'Home',
        'End'
    ].indexOf(event.key) !== -1;
}

function validateQuantity(form, showError) {
    var quantityInput = form.querySelector('input[name="quantity"]');

    if (!quantityInput) {
        return true;
    }

    var maxQuantity = parseInt(
            quantityInput.dataset.maxQuantity || quantityInput.max || '1',
            10
            );

    var quantityText = quantityInput.value.trim();

    if (quantityText === '' || !/^\d+$/.test(quantityText)) {
        if (showError) {
            showQuantityError('Vui lòng chỉ nhập số cho số lượng.');
        }

        quantityInput.focus();
        return false;
    }

    var quantity = parseInt(quantityText, 10);

    if (quantity < 1) {
        if (showError) {
            showQuantityError('Số lượng phải lớn hơn hoặc bằng 1.');
        }

        quantityInput.focus();
        return false;
    }

    if (quantity > maxQuantity) {
        if (showError) {
            showQuantityError(
                    'Số lượng không được lớn hơn số lượng trong kho (' + maxQuantity + ').'
                    );
        }

        quantityInput.focus();
        return false;
    }

    return true;
}

document.addEventListener('DOMContentLoaded', function () {
    var purchaseForm = document.querySelector('.purchase-form');
    var quantityInput = document.querySelector('.purchase-form input[name="quantity"]');

    if (quantityInput) {
        quantityInput.addEventListener('beforeinput', function (event) {
            var insertedText = event.data;

            if (insertedText !== null && /[^0-9]/.test(insertedText)) {
                event.preventDefault();
                showQuantityError('Vui lòng chỉ nhập số cho số lượng.');
            }
        });

        quantityInput.addEventListener('keydown', function (event) {
            if (isControlKey(event) || isTypingNumberKey(event)) {
                return;
            }

            event.preventDefault();
            showQuantityError('Vui lòng chỉ nhập số cho số lượng.');
        });

        quantityInput.addEventListener('input', function () {
            var currentValue = quantityInput.value;
            var numericValue = currentValue.replace(/[^0-9]/g, '');

            if (currentValue !== numericValue) {
                quantityInput.value = numericValue;
                showQuantityError('Vui lòng chỉ nhập số cho số lượng.');
            }

            quantityInput.setAttribute(
                    'aria-invalid',
                    String(quantityInput.value !== '' && !/^\d+$/.test(quantityInput.value))
                    );
        });

        quantityInput.addEventListener('paste', function (event) {
            var pastedText = (event.clipboardData || window.clipboardData).getData('text');

            if (/^\d+$/.test(pastedText)) {
                return;
            }

            event.preventDefault();
            showQuantityError('Vui lòng chỉ nhập số cho số lượng.');
        });

        quantityInput.addEventListener('blur', function () {
            if (quantityInput.value.trim() === '') {
                quantityInput.value = '1';
                quantityInput.setAttribute('aria-invalid', 'false');
                return;
            }

            validateQuantity(purchaseForm, true);
        });
    }

    if (purchaseForm) {
        purchaseForm.addEventListener('submit', function (event) {
            if (!validateQuantity(purchaseForm, true)) {
                event.preventDefault();
            }
        });
    }
});
