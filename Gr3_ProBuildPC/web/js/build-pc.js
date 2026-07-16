// Build PC page interactions: modal, quantity validation, and cart submission guard.
(function () {
    function validateQuantity(form, showFeedback) {
        var firstInvalidInput = null;
        document.querySelectorAll('.build-qty-input').forEach(function (input) {
            var maxQuantity = parseInt(input.dataset.maxQuantity || input.max || '1', 10);
            var isValid = window.Validator.validateBuildQuantity(input.value, maxQuantity);
            if (showFeedback) {
                window.Validator.showFeedback(input, isValid, 'Số lượng phải từ 1 đến ' + maxQuantity + '.');
            }
            if (!isValid && !firstInvalidInput) {
                firstInvalidInput = input;
            }
        });

        if (firstInvalidInput) {
            firstInvalidInput.focus();
            return false;
        }

        return true;
    }

    // Open the quick-select modal for a Build PC slot.
    document.querySelectorAll('.build-open-quick-view').forEach(function (button) {
        button.addEventListener('click', function () {
            var modal = document.getElementById(button.getAttribute('data-build-modal'));
            if (modal) {
                modal.classList.add('is-open');
                modal.setAttribute('aria-hidden', 'false');
                document.body.classList.add('build-modal-open');
            }
        });
    });

    // Close the quick-select modal.
    document.querySelectorAll('[data-build-close]').forEach(function (button) {
        button.addEventListener('click', function () {
            var modal = button.closest('.build-quick-view');
            if (modal) {
                modal.classList.remove('is-open');
                modal.setAttribute('aria-hidden', 'true');
                document.body.classList.remove('build-modal-open');
            }
        });
    });

    // Allow closing the modal with the Escape key.
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            document.querySelectorAll('.build-quick-view.is-open').forEach(function (modal) {
                modal.classList.remove('is-open');
                modal.setAttribute('aria-hidden', 'true');
            });
            document.body.classList.remove('build-modal-open');
        }
    });

    // Keep the input numeric-only and clamp it to the available stock limit.
    function sanitizeBuildQuantityInput(input) {
        var maxQuantity = parseInt(input.dataset.maxQuantity || input.max || '1', 10);
        var digits = String(input.value || '').replace(/\D/g, '');

        if (digits === '') {
            input.value = '';
            return;
        }

        var numericValue = parseInt(digits, 10);
        if (!Number.isFinite(numericValue)) {
            input.value = '';
            return;
        }

        if (maxQuantity > 0 && numericValue > maxQuantity) {
            input.value = String(maxQuantity);
            return;
        }

        input.value = String(numericValue);
    }

    // Bind validation and auto-submit behavior for each Build PC quantity input.
    document.querySelectorAll('.build-qty-input').forEach(function (input) {
        var baseWidth = 114;
        var digitWidth = 14;

        function resizeQuantityInput() {
            var length = Math.max(input.value.length, 1);
            input.style.width = Math.max(baseWidth, length * digitWidth + 48) + 'px';
        }

        function validateQuantityInput() {
            var maxQuantity = parseInt(input.dataset.maxQuantity || input.max || '1', 10);
            var isValid = window.Validator.validateBuildQuantity(input.value, maxQuantity);
            window.Validator.showFeedback(input, isValid, 'Số lượng phải từ 1 đến ' + maxQuantity + '.');
            return isValid;
        }

        input.addEventListener('input', function () {
            sanitizeBuildQuantityInput(input);
            resizeQuantityInput();
            if (input.classList.contains('is-invalid')) {
                validateQuantityInput();
            }
        });

        input.addEventListener('blur', function () {
            sanitizeBuildQuantityInput(input);
            if (validateQuantityInput()) {
                input.form.submit();
            }
        });

        input.addEventListener('keydown', function (event) {
            var allowedKeys = ['Backspace', 'Delete', 'Tab', 'ArrowLeft', 'ArrowRight', 'Home', 'End', 'Enter', 'Escape'];
            if (allowedKeys.indexOf(event.key) !== -1 || event.ctrlKey || event.metaKey) {
                return;
            }

            if (!/^\d$/.test(event.key)) {
                event.preventDefault();
            }
        });

        input.addEventListener('keydown', function (event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                sanitizeBuildQuantityInput(input);
                if (validateQuantityInput()) {
                    input.form.submit();
                }
            }
        });

        input.form.addEventListener('submit', function (event) {
            sanitizeBuildQuantityInput(input);
            if (!validateQuantityInput()) {
                event.preventDefault();
            }
        });

        resizeQuantityInput();
    });

    // Prevent adding the Build PC configuration to cart when a quantity is invalid.
    document.querySelectorAll('.build-add-cart-form').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!validateQuantity(form, true)) {
                event.preventDefault();
            }
        });
    });
})();
