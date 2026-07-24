document.addEventListener("DOMContentLoaded", function() {
    // Setup real-time validation for Profile Fields
    Validator.setupRealTimeValidation([
        {
            selector: '#fullName',
            validateFn: (val) => Validator.validateName(val),
            getErrorMsg: () => 'Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.'
        },
        {
            selector: '#currentPassword',
            validateFn: (val) => {
                const newPwd = document.getElementById("newPassword").value;
                const confPwd = document.getElementById("confirmPassword").value;
                if (newPwd || confPwd || val) {
                    return val.trim().length > 0;
                }
                return true;
            },
            getErrorMsg: () => 'Vui lòng nhập mật khẩu cũ để xác nhận thay đổi!'
        },
        {
            selector: '#newPassword',
            validateFn: (val) => {
                const currPwd = document.getElementById("currentPassword").value;
                const confPwd = document.getElementById("confirmPassword").value;
                if (currPwd || confPwd || val) {
                    if (!val) return false;
                    return Validator.validatePassword(val);
                }
                return true;
            },
            getErrorMsg: (val) => {
                if (!val) return 'Vui lòng nhập mật khẩu mới!';
                return 'Mật khẩu mới từ 8-31 ký tự, không chứa tiếng Việt có dấu, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.';
            }
        },
        {
            selector: '#confirmPassword',
            validateFn: (val) => {
                const newPwd = document.getElementById("newPassword").value;
                const currPwd = document.getElementById("currentPassword").value;
                if (newPwd || currPwd || val) {
                    return val === newPwd;
                }
                return true;
            },
            getErrorMsg: () => 'Xác nhận mật khẩu mới không khớp!'
        }
    ]);

    // Cross-field triggers for real-time password validation
    const currentPasswordInput = document.getElementById("currentPassword");
    const newPasswordInput = document.getElementById("newPassword");
    const confirmPasswordInput = document.getElementById("confirmPassword");

    const revalidatePassFields = (e) => {
        const isInput = e && e.type === 'input';

        // Only re-validate elements that already have validation feedback (touched/invalid) or have value
        if (newPasswordInput.value || currentPasswordInput.value || confirmPasswordInput.value) {
            if (newPasswordInput.classList.contains('is-invalid') || (!isInput && newPasswordInput.value)) {
                const pwdStrength = Validator.validatePassword(newPasswordInput.value);
                if (!newPasswordInput.value) {
                    Validator.showFeedback(newPasswordInput, false, 'Vui lòng nhập mật khẩu mới!');
                } else {
                    Validator.showFeedback(newPasswordInput, pwdStrength, 'Mật khẩu mới từ 8-31 ký tự, không chứa tiếng Việt có dấu, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.');
                }
            }

            if (confirmPasswordInput.classList.contains('is-invalid') || (!isInput && confirmPasswordInput.value)) {
                const isMatch = confirmPasswordInput.value === newPasswordInput.value;
                Validator.showFeedback(confirmPasswordInput, isMatch, 'Xác nhận mật khẩu mới không khớp!');
            }

            if (currentPasswordInput.classList.contains('is-invalid') || (!isInput && currentPasswordInput.value)) {
                const hasCurr = currentPasswordInput.value.trim().length > 0;
                Validator.showFeedback(currentPasswordInput, hasCurr, 'Vui lòng nhập mật khẩu cũ để xác nhận thay đổi!');
            }
        } else {
            // All are empty, clear all feedback
            Validator.clearFeedback(currentPasswordInput);
            Validator.clearFeedback(newPasswordInput);
            Validator.clearFeedback(confirmPasswordInput);
        }
    };

    if (newPasswordInput && confirmPasswordInput && currentPasswordInput) {
        newPasswordInput.addEventListener('input', revalidatePassFields);
        newPasswordInput.addEventListener('blur', revalidatePassFields);
        confirmPasswordInput.addEventListener('input', revalidatePassFields);
        confirmPasswordInput.addEventListener('blur', revalidatePassFields);
        currentPasswordInput.addEventListener('input', revalidatePassFields);
        currentPasswordInput.addEventListener('blur', revalidatePassFields);
    }
});

function validateForm() {
    const nameInput = document.getElementById("fullName");
    const currentPasswordInput = document.getElementById("currentPassword");
    const newPasswordInput = document.getElementById("newPassword");
    const confirmPasswordInput = document.getElementById("confirmPassword");

    Validator.clearFeedback(currentPasswordInput);
    Validator.clearFeedback(newPasswordInput);
    Validator.clearFeedback(confirmPasswordInput);

    const isNameValid = Validator.validateName(nameInput.value);
    Validator.showFeedback(nameInput, isNameValid, 'Họ và tên từ 2 đến 50 ký tự, không chứa số hay ký tự đặc biệt.');

    const newPwd = newPasswordInput.value;
    const confPwd = confirmPasswordInput.value;
    const currPwd = currentPasswordInput.value;

    let isPasswordValid = true;

    if (newPwd || confPwd || currPwd) {
        if (!currPwd) {
            Validator.showFeedback(currentPasswordInput, false, 'Vui lòng nhập mật khẩu cũ để xác nhận thay đổi!');
            isPasswordValid = false;
        } else {
            Validator.showFeedback(currentPasswordInput, true);
        }

        if (!newPwd) {
            Validator.showFeedback(newPasswordInput, false, 'Vui lòng nhập mật khẩu mới!');
            isPasswordValid = false;
        } else {
            const pwdStrength = Validator.validatePassword(newPwd);
            Validator.showFeedback(newPasswordInput, pwdStrength, 'Mật khẩu mới từ 8-31 ký tự, không chứa tiếng Việt có dấu, chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số.');
            if (!pwdStrength) {
                isPasswordValid = false;
            }
        }

        if (newPwd !== confPwd) {
            Validator.showFeedback(confirmPasswordInput, false, 'Xác nhận mật khẩu mới không khớp!');
            isPasswordValid = false;
        } else {
            Validator.showFeedback(confirmPasswordInput, true);
        }
    }

    return isNameValid && isPasswordValid;
}

function toggleProfilePass(inputId, icon) {
    const inputField = document.getElementById(inputId);
    if (inputField.type === "password") {
        inputField.type = "text";
        icon.classList.remove("fa-eye");
        icon.classList.add("fa-eye-slash");
    } else {
        inputField.type = "password";
        icon.classList.remove("fa-eye-slash");
        icon.classList.add("fa-eye");
    }
}

// Expose functions globally
window.validateForm = validateForm;
window.toggleProfilePass = toggleProfilePass;
