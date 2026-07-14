document.addEventListener("DOMContentLoaded", function() {
    const forms = document.querySelectorAll('.brand-modal-form');
    const allowedLogoTypes = ['png', 'jpg', 'jpeg', 'webp'];
    const logoTypeMessage = 'Logo chỉ chấp nhận định dạng PNG, JPG, JPEG hoặc WEBP.';
    const logoSizeMessage = 'Dung lượng logo không được vượt quá 2MB.';
    const logoRequiredMessage = 'Vui lòng chọn logo thương hiệu.';
    const brandNameMessage = 'Tên thương hiệu chứa từ 2-20 kí tự.';
    const duplicateBrandMessage = 'Tên thương hiệu đã tồn tại.';

    const normalizeBrandName = (value) => (value || '').trim().toLowerCase();
    const existingBrands = Array.isArray(window.existingBrands) ? window.existingBrands : [];

    const showFieldFeedback = (input, isValid, message, insertAfterElement = input) => {
        const feedbackId = `${input.id || input.name}-feedback`;
        let feedback = document.getElementById(feedbackId);

        if (!isValid && !feedback) {
            feedback = document.createElement('small');
            feedback.className = 'error-feedback';
            feedback.id = feedbackId;
            feedback.style.color = '#ef4444';
            feedback.style.display = 'block';
            feedback.style.marginTop = '5px';
            feedback.style.fontWeight = '500';
            insertAfterElement.insertAdjacentElement('afterend', feedback);
        }

        if (!isValid) {
            input.classList.add('is-invalid');
            feedback.textContent = message;
            return false;
        }

        input.classList.remove('is-invalid');
        if (feedback) {
            feedback.remove();
        }
        return true;
    };

    const isDuplicateBrandName = (name, currentBrandId) => {
        const normalizedName = normalizeBrandName(name);
        if (!normalizedName) {
            return false;
        }

        return existingBrands.some(brand => {
            const brandId = Number(brand.id);
            return brandId !== currentBrandId && normalizeBrandName(brand.name) === normalizedName;
        });
    };

    const validateBrandNameInput = (nameInput, currentBrandId) => {
        const isNameValid = Validator.validateBrandName(nameInput.value);
        if (!isNameValid) {
            showFieldFeedback(nameInput, false, brandNameMessage);
            return false;
        }

        const isDuplicate = isDuplicateBrandName(nameInput.value, currentBrandId);
        return showFieldFeedback(nameInput, !isDuplicate, duplicateBrandMessage);
    };

    const validateLogoFile = (fileInput, isRequired = false) => {
        const fileNote = fileInput.parentElement.querySelector('.brand-file-note');
        const feedbackAnchor = fileNote || fileInput;
        const file = fileInput.files[0];
        if (!file) {
            return showFieldFeedback(fileInput, !isRequired, logoRequiredMessage, feedbackAnchor);
        }

        const isTypeValid = Validator.validateFileType(file, allowedLogoTypes);
        if (!isTypeValid) {
            return showFieldFeedback(fileInput, false, logoTypeMessage, feedbackAnchor);
        }

        const isSizeValid = Validator.validateFileSize(file, 2 * 1024 * 1024);
        return showFieldFeedback(fileInput, isSizeValid, logoSizeMessage, feedbackAnchor);
    };

    forms.forEach(form => {
        const nameInput = form.querySelector('input[name="brandName"]');
        const fileInput = form.querySelector('input[name="imgFile"]');
        const actionInput = form.querySelector('input[name="action"]');
        const submitButton = form.querySelector('button[type="submit"]');
        const isAddForm = actionInput && actionInput.value === 'add';
        const currentBrandId = Number(form.dataset.brandId || 0);

        if (nameInput) {
            nameInput.addEventListener('blur', () => {
                validateBrandNameInput(nameInput, currentBrandId);
            });
            nameInput.addEventListener('focusout', () => {
                validateBrandNameInput(nameInput, currentBrandId);
            });
            nameInput.addEventListener('input', () => {
                if (nameInput.classList.contains('is-invalid')) {
                    validateBrandNameInput(nameInput, currentBrandId);
                }
            });
        }

        if (submitButton && nameInput) {
            submitButton.addEventListener('click', () => {
                validateBrandNameInput(nameInput, currentBrandId);
                if (fileInput) {
                    validateLogoFile(fileInput, isAddForm);
                }
            });
        }

        if (fileInput) {
            fileInput.addEventListener('change', () => {
                validateLogoFile(fileInput, isAddForm);
            });
        }

        form.addEventListener('submit', (e) => {
            let isFormValid = true;

            if (nameInput) {
                const isNameValid = validateBrandNameInput(nameInput, currentBrandId);
                if (!isNameValid) isFormValid = false;
            }

            if (fileInput) {
                const isFileValid = validateLogoFile(fileInput, isAddForm);
                if (!isFileValid) isFormValid = false;
            }

            if (!isFormValid) {
                e.preventDefault();
            }
        });
    });
});
