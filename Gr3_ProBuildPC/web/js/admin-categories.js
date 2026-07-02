document.addEventListener('DOMContentLoaded', function () {
    const addForm = document.getElementById('addCategoryForm');
    const editForm = document.getElementById('editCategoryForm');

    const addCategoryNameInput = document.getElementById('addCategoryName');
    const editCategoryIdInput = document.getElementById('editCategoryId');
    const editCategoryNameInput = document.getElementById('editCategoryName');

    // 1. Populate modal on clicking Edit
    document.addEventListener('click', function (event) {
        const btnEdit = event.target.closest('.category-actions .btn-edit');
        if (btnEdit) {
            const categoryId = btnEdit.getAttribute('data-id');
            const categoryName = btnEdit.getAttribute('data-name');
            
            if (editCategoryIdInput) {
                editCategoryIdInput.value = categoryId;
            }
            if (editCategoryNameInput) {
                editCategoryNameInput.value = categoryName;
                // Clear any leftover validation styles when opening
                clearValidationFeedback(editCategoryNameInput);
            }
        }
    });

    // Helper functions for custom yellow/orange warning validation styling
    function applyValidationFeedback(inputElement, isValid, errorMessage) {
        if (!inputElement) return;

        let parent = inputElement.parentElement;
        let feedback = parent.querySelector('.error-feedback');

        if (!isValid) {
            // Apply inline yellow warning highlight
            inputElement.classList.add('is-invalid');
            inputElement.style.borderColor = '#ff9f0a';
            inputElement.style.boxShadow = '0 0 0 2px rgba(255, 159, 10, 0.2)';
            
            if (!feedback) {
                feedback = document.createElement('small');
                feedback.className = 'error-feedback';
                feedback.style.color = '#ff9f0a'; // Use matching warning color for text
                feedback.style.display = 'block';
                feedback.style.marginTop = '5px';
                feedback.style.fontWeight = '600';
                parent.appendChild(feedback);
            }
            feedback.textContent = errorMessage;
        } else {
            clearValidationFeedback(inputElement);
        }
    }

    function clearValidationFeedback(inputElement) {
        if (!inputElement) return;

        let parent = inputElement.parentElement;
        inputElement.classList.remove('is-invalid');
        inputElement.style.borderColor = '';
        inputElement.style.boxShadow = '';
        
        const feedback = parent.querySelector('.error-feedback');
        if (feedback) {
            feedback.remove();
        }
    }

    function resetModalForm(form) {
        if (!form) return;
        form.reset();
        form.querySelectorAll('input').forEach(input => {
            clearValidationFeedback(input);
        });
    }

    // 2. Real-time validation for Add & Edit
    if (addCategoryNameInput) {
        addCategoryNameInput.addEventListener('blur', function () {
            const value = (addCategoryNameInput.value || '').trim();
            const isValid = value.length >= 2 && value.length <= 100;
            const msg = !value ? 'Tên danh mục không được để trống.' : 'Tên danh mục phải từ 2 đến 100 ký tự.';
            applyValidationFeedback(addCategoryNameInput, isValid, msg);
        });

        addCategoryNameInput.addEventListener('input', function () {
            if (addCategoryNameInput.classList.contains('is-invalid')) {
                const value = (addCategoryNameInput.value || '').trim();
                const isValid = value.length >= 2 && value.length <= 100;
                const msg = !value ? 'Tên danh mục không được để trống.' : 'Tên danh mục phải từ 2 đến 100 ký tự.';
                applyValidationFeedback(addCategoryNameInput, isValid, msg);
            }
        });
    }

    if (editCategoryNameInput) {
        editCategoryNameInput.addEventListener('blur', function () {
            const value = (editCategoryNameInput.value || '').trim();
            const isValid = value.length >= 2 && value.length <= 100;
            const msg = !value ? 'Tên danh mục không được để trống.' : 'Tên danh mục phải từ 2 đến 100 ký tự.';
            applyValidationFeedback(editCategoryNameInput, isValid, msg);
        });

        editCategoryNameInput.addEventListener('input', function () {
            if (editCategoryNameInput.classList.contains('is-invalid')) {
                const value = (editCategoryNameInput.value || '').trim();
                const isValid = value.length >= 2 && value.length <= 100;
                const msg = !value ? 'Tên danh mục không được để trống.' : 'Tên danh mục phải từ 2 đến 100 ký tự.';
                applyValidationFeedback(editCategoryNameInput, isValid, msg);
            }
        });
    }

    // 3. Close & Reset Actions
    function handleModalClose() {
        resetModalForm(addForm);
        resetModalForm(editForm);
    }

    // Listen to close buttons
    document.addEventListener('click', function (event) {
        if (event.target.closest('.btn-close-modal') || event.target.closest('.brand-modal-overlay')) {
            handleModalClose();
        }
    });

    // Listen to hashchange event (when hash goes empty e.g. clicking Hủy/Close target)
    window.addEventListener('hashchange', function () {
        if (!window.location.hash || (window.location.hash !== '#addCategoryModal' && window.location.hash !== '#editCategoryModal')) {
            handleModalClose();
        }
    });

    // 4. Form Submit validation
    if (addForm) {
        addForm.addEventListener('submit', function (event) {
            if (addCategoryNameInput) {
                const value = (addCategoryNameInput.value || '').trim();
                const isValid = value.length >= 2 && value.length <= 100;
                const msg = !value ? 'Tên danh mục không được để trống.' : 'Tên danh mục phải từ 2 đến 100 ký tự.';
                applyValidationFeedback(addCategoryNameInput, isValid, msg);

                if (!isValid) {
                    event.preventDefault();
                }
            }
        });
    }

    if (editForm) {
        editForm.addEventListener('submit', function (event) {
            if (editCategoryNameInput) {
                const value = (editCategoryNameInput.value || '').trim();
                const isValid = value.length >= 2 && value.length <= 100;
                const msg = !value ? 'Tên danh mục không được để trống.' : 'Tên danh mục phải từ 2 đến 100 ký tự.';
                applyValidationFeedback(editCategoryNameInput, isValid, msg);

                if (!isValid) {
                    event.preventDefault();
                }
            }
        });
    }

});
