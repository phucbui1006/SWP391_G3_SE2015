// Tương tác trên trang Build PC: modal, kiểm tra số lượng và chặn thêm vào giỏ hàng.
(function () {
    var activeModalTrigger = null;

    function closeBuildModal(modal) {
        if (!modal) return;
        modal.classList.remove('is-open');
        modal.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('build-modal-open');
        if (activeModalTrigger) {
            activeModalTrigger.focus();
            activeModalTrigger = null;
        }
    }

    // Mở modal chọn linh kiện cho một slot Build PC.
    document.querySelectorAll('.build-open-quick-view').forEach(function (button) {
        button.addEventListener('click', function () {
            var modal = document.getElementById(button.getAttribute('data-build-modal'));
            if (modal) {
                activeModalTrigger = button;
                modal.classList.add('is-open');
                modal.setAttribute('aria-hidden', 'false');
                document.body.classList.add('build-modal-open');
                var closeButton = modal.querySelector('[data-build-close]:not(.build-quick-backdrop)');
                if (closeButton) closeButton.focus();
            }
        });
    });

    // Đóng modal chọn linh kiện.
    document.querySelectorAll('[data-build-close]').forEach(function (button) {
        button.addEventListener('click', function () {
            var modal = button.closest('.build-quick-view');
            closeBuildModal(modal);
        });
    });

    // Cho phép đóng modal bằng phím Escape.
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closeBuildModal(document.querySelector('.build-quick-view.is-open'));
        }
    });

    var quantityInputs = Array.prototype.slice.call(document.querySelectorAll('.build-qty-input'));
    var buildTotalElement = document.querySelector('[data-build-total]');

    function updateBuildTotal() {
        if (!buildTotalElement) return;

        var total = quantityInputs.reduce(function (sum, input) {
            var price = Number(input.dataset.unitPrice || 0);
            var quantityValue = input.classList.contains('is-invalid')
                    ? input.dataset.savedQuantity
                    : input.value;
            var quantity = parseInt(quantityValue, 10);
            if (!Number.isFinite(price) || !Number.isInteger(quantity) || quantity < 1) {
                return sum;
            }
            return sum + (price * quantity);
        }, 0);

        buildTotalElement.textContent = new Intl.NumberFormat('vi-VN', {
            maximumFractionDigits: 0
        }).format(total) + 'đ';
    }

    function getQuantityError(input) {
        var maxQuantity = parseInt(input.dataset.maxQuantity || input.max || '1', 10);
        var value = String(input.value || '').trim();
        if (!/^[1-9][0-9]*$/.test(value)) {
            return 'Số lượng phải là số nguyên từ 1 trở lên.';
        }
        return 'Số lượng không được lớn hơn số lượng trong kho (' + maxQuantity + ').';
    }

    function persistQuantity(input) {
        if (input._pendingQuantityUpdate) {
            return input._pendingQuantityUpdate;
        }

        var maxQuantity = parseInt(input.dataset.maxQuantity || input.max || '1', 10);
        var isValid = window.Validator.validateBuildQuantity(input.value, maxQuantity);
        window.Validator.showFeedback(input, isValid, getQuantityError(input));
        if (!isValid) {
            return Promise.resolve(false);
        }

        if (input.dataset.savedQuantity === input.value) {
            return Promise.resolve(true);
        }

        var formData = new FormData(input.form);
        var endpoint = input.form.getAttribute('action');
        input._pendingQuantityUpdate = fetch(endpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: new URLSearchParams(formData).toString()
        }).then(function (response) {
            var contentType = response.headers.get('content-type') || '';
            if (contentType.indexOf('application/json') === -1) {
                throw new Error('Máy chủ không trả về dữ liệu cập nhật số lượng hợp lệ.');
            }

            return response.json().then(function (data) {
                if (!response.ok || !data.success) {
                    throw new Error(data.message || 'Không thể cập nhật số lượng.');
                }
                input.dataset.savedQuantity = String(data.quantity);
                window.Validator.clearFeedback(input);
                updateBuildTotal();
                return true;
            });
        }).catch(function (error) {
            window.Validator.showFeedback(input, false, error.message);
            updateBuildTotal();
            input.focus();
            return false;
        }).finally(function () {
            input._pendingQuantityUpdate = null;
        });

        return input._pendingQuantityUpdate;
    }

    function flushQuantities() {
        return Promise.all(quantityInputs.map(persistQuantity)).then(function (results) {
            return results.every(function (result) { return result; });
        });
    }

    // Lưu bằng AJAX để việc chọn linh kiện tiếp theo không chạy trước request cập nhật số lượng.
    quantityInputs.forEach(function (input) {
        input.dataset.savedQuantity = input.value;

        var maxQuantity = parseInt(input.dataset.maxQuantity || input.max || '1', 10);
        var isValid = window.Validator.validateBuildQuantity(input.value, maxQuantity);
        window.Validator.showFeedback(input, isValid, getQuantityError(input));
        if (!isValid) {
            return Promise.resolve(false);
        }

        if (input.dataset.savedQuantity === input.value) {
            return Promise.resolve(true);
        }

        var formData = new FormData(input.form);
        input._pendingQuantityUpdate = fetch(input.form.action, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: new URLSearchParams(formData).toString()
        }).then(function (response) {
            return response.json().then(function (data) {
                if (!response.ok || !data.success) {
                    throw new Error(data.message || 'Không thể cập nhật số lượng.');
                }
                input.dataset.savedQuantity = String(data.quantity);
                window.Validator.clearFeedback(input);
                return true;
            });
        }).catch(function (error) {
            window.Validator.showFeedback(input, false, error.message);
            input.focus();
            return false;
        }).finally(function () {
            input._pendingQuantityUpdate = null;
        });

        return input._pendingQuantityUpdate;
    }

    function flushQuantities() {
        return Promise.all(quantityInputs.map(persistQuantity)).then(function (results) {
            return results.every(function (result) { return result; });
        });
    }

    // Lưu bằng AJAX để việc chọn linh kiện tiếp theo không chạy trước request cập nhật số lượng.
    quantityInputs.forEach(function (input) {
        input.dataset.savedQuantity = input.value;

        function validateQuantityInput() {
            var maxQuantity = parseInt(input.dataset.maxQuantity || input.max || '1', 10);
            var isValid = window.Validator.validateBuildQuantity(input.value, maxQuantity);
            window.Validator.showFeedback(input, isValid, getQuantityError(input));
            return isValid;
        }

        input.addEventListener('input', function () {
            if (validateQuantityInput()) updateBuildTotal();
        });

        input.addEventListener('blur', function () {
            persistQuantity(input);
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
                if (validateQuantityInput()) {
                    persistQuantity(input);
                }
            }
        });

        input.form.addEventListener('submit', function (event) {
            event.preventDefault();
            persistQuantity(input);
        });
    });

    updateBuildTotal();

    var resumeClick = false;
    document.addEventListener('click', function (event) {
        var action = event.target.closest('button[type="submit"], [data-add-to-cart-btn]');
        if (!action || action.closest('.build-quantity') || resumeClick) {
            return;
        }

        var submittedForm = action.form;
        var actionInput = submittedForm && submittedForm.querySelector('input[name="action"]');
        var submittedAction = actionInput ? actionInput.value : '';
        if (submittedAction === 'remove' || submittedAction === 'clear') {
            return;
        }

        event.preventDefault();
        event.stopImmediatePropagation();
        flushQuantities().then(function (success) {
            if (!success) return;
            resumeClick = true;
            action.click();
            resumeClick = false;
        });
    }, true);

})();
