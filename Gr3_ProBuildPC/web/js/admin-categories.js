document.addEventListener('DOMContentLoaded', function () {
    const addForm = document.getElementById('addCategoryForm');
    const editForm = document.getElementById('editCategoryForm');

    const addCategoryNameInput = document.getElementById('addCategoryName');
    const editCategoryIdInput = document.getElementById('editCategoryId');
    const editCategoryNameInput = document.getElementById('editCategoryName');

    function getCategoryNameError(value) {
        const rawValue = value || '';
        const name = rawValue.trim();

        if (name.length === 0) {
            return 'Tên danh mục không được để trống.';
        }

        if (name.length < 2 || name.length > 50) {
            return 'Tên danh mục phải từ 2 đến 50 ký tự.';
        }

        if (/\s{2,}/.test(name)) {
            return 'Tên danh mục không được chứa nhiều dấu cách liên tiếp.';
        }

        return '';
    }

    function applyValidationFeedback(inputElement, isValid, errorMessage) {
        if (!inputElement) {
            return;
        }

        const parent = inputElement.parentElement;
        let feedback = parent.querySelector('.error-feedback');

        if (!isValid) {
            inputElement.classList.add('is-invalid');

            if (!feedback) {
                feedback = document.createElement('small');
                feedback.className = 'error-feedback';
                parent.appendChild(feedback);
            }

            feedback.textContent = errorMessage;
        } else {
            clearValidationFeedback(inputElement);
        }
    }

    function clearValidationFeedback(inputElement) {
        if (!inputElement) {
            return;
        }

        const parent = inputElement.parentElement;

        inputElement.classList.remove('is-invalid');

        const feedback = parent.querySelector('.error-feedback');
        if (feedback) {
            feedback.remove();
        }
    }

    function validateCategoryNameInput(inputElement) {
        if (!inputElement) {
            return false;
        }

        const errorMessage = getCategoryNameError(inputElement.value);
        const isValid = errorMessage === '';

        applyValidationFeedback(inputElement, isValid, errorMessage);

        return isValid;
    }

    const validationRequests = new WeakMap();
    const validationTimers = new WeakMap();

    async function validateDuplicateName(inputElement, excludedCategoryId) {
        if (!validateCategoryNameInput(inputElement)) {
            return false;
        }

        const previousRequest = validationRequests.get(inputElement);
        if (previousRequest) {
            previousRequest.abort();
        }

        const controller = new AbortController();
        validationRequests.set(inputElement, controller);

        const params = new URLSearchParams({
            action: 'check-name',
            categoryName: inputElement.value.trim()
        });

        if (excludedCategoryId) {
            params.set('excludeId', excludedCategoryId);
        }

        try {
            const response = await fetch(window.categoryValidationUrl + '?' + params.toString(), {
                signal: controller.signal,
                headers: { Accept: 'application/json' }
            });

            if (!response.ok) {
                return true;
            }

            const result = await response.json();
            const isValid = !result.exists;
            applyValidationFeedback(
                inputElement,
                isValid,
                'Tên danh mục đã tồn tại trong hệ thống.'
            );
            return isValid;
        } catch (error) {
            return error.name === 'AbortError' ? false : true;
        } finally {
            if (validationRequests.get(inputElement) === controller) {
                validationRequests.delete(inputElement);
            }
        }
    }

    function scheduleRealtimeValidation(inputElement, getExcludedCategoryId) {
        clearTimeout(validationTimers.get(inputElement));

        const localError = getCategoryNameError(inputElement.value);
        applyValidationFeedback(inputElement, localError === '', localError);

        if (localError) {
            const previousRequest = validationRequests.get(inputElement);
            if (previousRequest) {
                previousRequest.abort();
            }
            return;
        }

        const timer = setTimeout(function () {
            validateDuplicateName(
                inputElement,
                getExcludedCategoryId ? getExcludedCategoryId() : ''
            );
        }, 300);
        validationTimers.set(inputElement, timer);
    }

    function resetModalForm(form) {
        if (!form) {
            return;
        }

        form.reset();

        const categoryNameInput = form.querySelector('input[name="categoryName"]');
        clearTimeout(validationTimers.get(categoryNameInput));
        const pendingRequest = validationRequests.get(categoryNameInput);
        if (pendingRequest) {
            pendingRequest.abort();
        }
        clearValidationFeedback(categoryNameInput);

        if (form === addForm && categoryNameInput) {
            categoryNameInput.value = '';
            categoryNameInput.defaultValue = '';
        }

        if (form === editForm) {
            if (categoryNameInput) {
                categoryNameInput.value = '';
                categoryNameInput.defaultValue = '';
            }

            if (editCategoryIdInput) {
                editCategoryIdInput.value = '';
                editCategoryIdInput.defaultValue = '';
            }
        }
    }

    document.addEventListener('click', function (event) {
        const btnEdit = event.target.closest('.category-actions .btn-edit');

        if (!btnEdit) {
            return;
        }

        const categoryId = btnEdit.getAttribute('data-id');
        const categoryName = btnEdit.getAttribute('data-name');

        if (editCategoryIdInput) {
            editCategoryIdInput.value = categoryId;
        }

        if (editCategoryNameInput) {
            editCategoryNameInput.value = categoryName;
            clearValidationFeedback(editCategoryNameInput);
        }
    });

    if (addCategoryNameInput) {
        addCategoryNameInput.addEventListener('input', function () {
            scheduleRealtimeValidation(addCategoryNameInput);
        });
    }

    if (editCategoryNameInput) {
        editCategoryNameInput.addEventListener('input', function () {
            scheduleRealtimeValidation(editCategoryNameInput, function () {
                return editCategoryIdInput ? editCategoryIdInput.value : '';
            });
        });
    }

    function handleModalClose() {
        resetModalForm(addForm);
        resetModalForm(editForm);
    }

    document.addEventListener('click', function (event) {
        const clickedCloseButton = event.target.closest('.btn-close-modal');
        const clickedOverlayOnly = event.target.classList.contains('brand-modal-overlay');

        if (clickedCloseButton || clickedOverlayOnly) {
            handleModalClose();

            if (clickedOverlayOnly) {
                window.location.hash = '';
            }
        }
    });

    document.addEventListener('keydown', function (event) {
        const isCategoryModalOpen = window.location.hash === '#addCategoryModal'
            || window.location.hash === '#editCategoryModal';

        if (event.key === 'Escape' && isCategoryModalOpen) {
            window.location.hash = '';
            handleModalClose();
        }
    });

    window.addEventListener('hashchange', function () {
        if (
            !window.location.hash ||
            (
                window.location.hash !== '#addCategoryModal' &&
                window.location.hash !== '#editCategoryModal'
            )
        ) {
            handleModalClose();
        }
    });

    if (addForm) {
        addForm.addEventListener('submit', async function (event) {
            event.preventDefault();
            clearTimeout(validationTimers.get(addCategoryNameInput));

            if (await validateDuplicateName(addCategoryNameInput, '')) {
                addForm.submit();
            }
        });
    }

    if (editForm) {
        editForm.addEventListener('submit', async function (event) {
            event.preventDefault();
            clearTimeout(validationTimers.get(editCategoryNameInput));

            const excludedCategoryId = editCategoryIdInput ? editCategoryIdInput.value : '';
            if (await validateDuplicateName(editCategoryNameInput, excludedCategoryId)) {
                editForm.submit();
            }
        });
    }
});
