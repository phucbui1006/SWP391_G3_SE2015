document.addEventListener("DOMContentLoaded", function() {
    const forms = document.querySelectorAll('.brand-modal-form');
    forms.forEach(form => {
        const nameInput = form.querySelector('input[name="brandName"]');
        const fileInput = form.querySelector('input[name="imgFile"]');

        if (nameInput) {
            nameInput.addEventListener('blur', () => {
                const isValid = Validator.validateBrandName(nameInput.value);
                Validator.showFeedback(nameInput, isValid, 'Tên thương hiệu phải từ 2 đến 50 ký tự.');
            });
            nameInput.addEventListener('input', () => {
                if (nameInput.classList.contains('is-invalid')) {
                    const isValid = Validator.validateBrandName(nameInput.value);
                    Validator.showFeedback(nameInput, isValid, 'Tên thương hiệu phải từ 2 đến 50 ký tự.');
                }
            });
        }

        if (fileInput) {
            fileInput.addEventListener('change', () => {
                const file = fileInput.files[0];
                const isValid = Validator.validateFileSize(file, 2 * 1024 * 1024);
                Validator.showFeedback(fileInput, isValid, 'Dung lượng logo không được vượt quá 2MB.');
            });
        }

        form.addEventListener('submit', (e) => {
            let isFormValid = true;

            if (nameInput) {
                const isNameValid = Validator.validateBrandName(nameInput.value);
                Validator.showFeedback(nameInput, isNameValid, 'Tên thương hiệu phải từ 2 đến 50 ký tự.');
                if (!isNameValid) isFormValid = false;
            }

            if (fileInput && fileInput.files && fileInput.files[0]) {
                const isSizeValid = Validator.validateFileSize(fileInput.files[0], 2 * 1024 * 1024);
                Validator.showFeedback(fileInput, isSizeValid, 'Dung lượng logo không được vượt quá 2MB.');
                if (!isSizeValid) isFormValid = false;
            }

            if (!isFormValid) {
                e.preventDefault();
            }
        });
    });
});
