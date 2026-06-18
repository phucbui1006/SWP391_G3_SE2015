document.addEventListener("DOMContentLoaded", function() {
    const forms = document.querySelectorAll('.brand-modal-form');
    const allowedLogoTypes = ['png', 'jpg', 'jpeg', 'webp'];
    const logoTypeMessage = 'Logo chỉ chấp nhận định dạng PNG, JPG, JPEG hoặc WEBP.';
    const logoSizeMessage = 'Dung lượng logo không được vượt quá 2MB.';
    const logoRequiredMessage = 'Vui lòng chọn logo thương hiệu.';

    const validateLogoFile = (fileInput, isRequired = false) => {
        const file = fileInput.files[0];
        if (!file) {
            Validator.showFeedback(fileInput, !isRequired, logoRequiredMessage);
            return !isRequired;
        }

        const isTypeValid = Validator.validateFileType(file, allowedLogoTypes);
        if (!isTypeValid) {
            Validator.showFeedback(fileInput, false, logoTypeMessage);
            return false;
        }

        const isSizeValid = Validator.validateFileSize(file, 2 * 1024 * 1024);
        Validator.showFeedback(fileInput, isSizeValid, logoSizeMessage);
        return isSizeValid;
    };

    forms.forEach(form => {
        const nameInput = form.querySelector('input[name="brandName"]');
        const fileInput = form.querySelector('input[name="imgFile"]');
        const actionInput = form.querySelector('input[name="action"]');
        const isAddForm = actionInput && actionInput.value === 'add';

        if (nameInput) {
            nameInput.addEventListener('blur', () => {
                const isValid = Validator.validateBrandName(nameInput.value);
                Validator.showFeedback(nameInput, isValid, 'Tên thương hiệu chứa từ 2-20 kí tự.');
            });
            nameInput.addEventListener('input', () => {
                if (nameInput.classList.contains('is-invalid')) {
                    const isValid = Validator.validateBrandName(nameInput.value);
                    Validator.showFeedback(nameInput, isValid, 'Tên thương hiệu chứa từ 2-20 kí tự.');
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
                const isNameValid = Validator.validateBrandName(nameInput.value);
                Validator.showFeedback(nameInput, isNameValid, 'Tên thương hiệu chứa từ 2-20 kí tự.');
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
