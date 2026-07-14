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

        if (name.length < 2 || name.length > 100) {
            return 'Tên danh mục phải từ 2 đến 100 ký tự.';
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

    function resetModalForm(form) {
        if (!form) {
            return;
        }

        form.reset();

        const categoryNameInput = form.querySelector('input[name="categoryName"]');
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
            clearValidationFeedback(addCategoryNameInput);
        });
    }

    if (editCategoryNameInput) {
        editCategoryNameInput.addEventListener('input', function () {
            clearValidationFeedback(editCategoryNameInput);
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
        addForm.addEventListener('submit', function (event) {
            const isValid = validateCategoryNameInput(addCategoryNameInput);

            if (!isValid) {
                event.preventDefault();
            }
        });
    }

    if (editForm) {
        editForm.addEventListener('submit', function (event) {
            const isValid = validateCategoryNameInput(editCategoryNameInput);

            if (!isValid) {
                event.preventDefault();
            }
        });
    }
});
