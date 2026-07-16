// Tương tác trên trang Build PC: modal, kiểm tra số lượng và chặn thêm vào giỏ hàng.
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

    // Mở modal chọn linh kiện cho một slot Build PC.
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

    // Đóng modal chọn linh kiện.
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

    // Cho phép đóng modal bằng phím Escape.
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            document.querySelectorAll('.build-quick-view.is-open').forEach(function (modal) {
                modal.classList.remove('is-open');
                modal.setAttribute('aria-hidden', 'true');
            });
            document.body.classList.remove('build-modal-open');
        }
    });

    // Giữ ô nhập ở dạng số và giới hạn theo số lượng tồn kho có sẵn.
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

    // Gắn logic kiểm tra và tự submit cho từng ô nhập số lượng Build PC.
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

    // Ngăn thêm cấu hình Build PC vào giỏ hàng khi số lượng không hợp lệ.
    document.querySelectorAll('.build-add-cart-form').forEach(function (form) {
        form.addEventListener('submit', function (event) {
            if (!validateQuantity(form, true)) {
                event.preventDefault();
            }
        });
    });
})();
