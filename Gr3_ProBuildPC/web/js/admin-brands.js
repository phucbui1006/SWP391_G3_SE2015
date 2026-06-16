document.addEventListener("DOMContentLoaded", function() {
    const forms = document.querySelectorAll('.brand-modal-form');
    const allowedLogoTypes = ['png', 'jpg', 'jpeg', 'webp'];
    const logoTypeMessage = 'Logo chỉ chấp nhận định dạng PNG, JPG, JPEG hoặc WEBP.';
    const logoSizeMessage = 'Dung lượng logo không được vượt quá 2MB.';

    const validateLogoFile = (fileInput) => {
        const file = fileInput.files[0];
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

        if (nameInput) {
            nameInput.addEventListener('blur', () => {
                const isValid = Validator.validateBrandName(nameInput.value);
                Validator.showFeedback(nameInput, isValid, 'Tên thương hiệu phải từ 2 đến 20 ký tự.');
            });
            nameInput.addEventListener('input', () => {
                if (nameInput.classList.contains('is-invalid')) {
                    const isValid = Validator.validateBrandName(nameInput.value);
                    Validator.showFeedback(nameInput, isValid, 'Tên thương hiệu phải từ 2 đến 20 ký tự.');
                }
            });
        }

        if (fileInput) {
            fileInput.addEventListener('change', () => {
                validateLogoFile(fileInput);
            });
        }

        form.addEventListener('submit', (e) => {
            let isFormValid = true;

            if (nameInput) {
                const isNameValid = Validator.validateBrandName(nameInput.value);
                Validator.showFeedback(nameInput, isNameValid, 'Tên thương hiệu phải từ 2 đến 20 ký tự.');
                if (!isNameValid) isFormValid = false;
            }

            if (fileInput && fileInput.files && fileInput.files[0]) {
                const isFileValid = validateLogoFile(fileInput);
                if (!isFileValid) isFormValid = false;
            }

            if (!isFormValid) {
                e.preventDefault();
            }
        });
    });
});
