/**
 * Centralized Frontend Validation Library for ProBuildPC
 * Exposes namespace 'Validator' to validate common inputs (email, password, phone, otp, names, etc.)
 * and display standard validation feedback.
 */
const Validator = {
    // Regex Patterns
    patterns: {
        email: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
        phone: /^(0[35789])[0-9]{8}$/,
        password: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,31}$/,
        otp: /^\d{6}$/,
        name: /^[\p{L}\s]+$/u,
        orderId: /^[pP]?[bB]?[0-9]+$/,
        search: /^[^<>='\"%]+$/
    },

    // Validation Predicates
    validateEmail(email) {
        if (!email) return false;
        const trimmed = email.trim();
        return trimmed.length <= 100 && this.patterns.email.test(trimmed);
    },

    validatePhone(phone) {
        if (!phone) return false;
        const trimmed = phone.trim();
        return this.patterns.phone.test(trimmed);
    },

    validatePassword(password) {
        if (!password) return false;
        // 8 to 31 characters, must contain at least: one uppercase letter, one lowercase letter, and one number.
        return this.patterns.password.test(password);
    },

    validateOTP(otp) {
        if (!otp) return false;
        const trimmed = otp.trim();
        return this.patterns.otp.test(trimmed);
    },

    validateName(name) {
        if (!name) return false;
        const trimmed = name.trim();
        return trimmed.length >= 2 && trimmed.length <= 50 && this.patterns.name.test(trimmed);
    },

    validateOrderId(orderId) {
        if (!orderId) return false;
        const trimmed = orderId.trim();
        if (!this.patterns.orderId.test(trimmed)) return false;
        const digits = trimmed.replace(/[^0-9]/g, '');
        if (!digits) return false;
        const idVal = parseInt(digits, 10);
        return idVal > 0 && idVal <= 2147483647;
    },

    validateBrandName(name) {
        if (!name) return false;
        const trimmed = name.trim();
        return trimmed.length >= 2 && trimmed.length < 20;
    },

    validateProductName(name) {
        if (!name) return false;
        const trimmed = name.trim();
        return trimmed.length >= 3
            && trimmed.length <= 255
            && !/\s{2,}/.test(trimmed);
    },

    validateFileSize(file, maxBytes = 2 * 1024 * 1024) {
        if (!file) return true; // Optional file is considered valid
        return file.size <= maxBytes;
    },

    validateFileType(file, allowedExtensions = ['png', 'jpg', 'jpeg', 'webp']) {
        if (!file) return true; // Optional file is considered valid

        const fileName = file.name || '';
        const extension = fileName.split('.').pop().toLowerCase();
        return allowedExtensions.includes(extension);
    },

    validateAddress(address) {
        if (!address) return false;
        const trimmed = address.trim();
        return trimmed.length >= 5 && trimmed.length <= 255;
    },

    validateNote(note) {
        if (!note) return true;
        return note.trim().length <= 1000;
    },

    validateSearchQuery(query) {
        if (!query) return false;
        const trimmed = query.trim();
        return trimmed.length > 0 && trimmed.length <= 100 && this.patterns.search.test(trimmed);
    },

    validatePrice(priceStr) {
        if (!priceStr) return false;
        const price = parseFloat(priceStr);
        return !isNaN(price) && price > 0 && price <= 2000000000;
    },

    validateQuantity(qtyStr) {
        if (!qtyStr) return false;
        const qty = parseInt(qtyStr, 10);
        return !isNaN(qty) && qty >= 0 && qty <= 100000;
    },

    validateBuildQuantity(qtyStr, maxQuantity = 1) {
        if (qtyStr === null || qtyStr === undefined) return false;
        const trimmed = String(qtyStr).trim();
        if (!/^[1-9][0-9]*$/.test(trimmed) || trimmed.length > 9) return false;

        const qty = Number(trimmed);
        const max = Number(maxQuantity);
        return Number.isSafeInteger(qty)
                && qty >= 1
                && Number.isSafeInteger(max)
                && max >= 1
                && qty <= max;
    },

    validateRating(ratingStr) {
        if (!ratingStr) return false;
        const rating = parseInt(ratingStr, 10);
        return !isNaN(rating) && rating >= 1 && rating <= 5;
    },

    // UI Feedback Helpers
    showFeedback(inputElement, isValid, errorMessage) {
        if (typeof inputElement === 'string') {
            inputElement = document.getElementById(inputElement);
        }
        if (!inputElement) return isValid;

        let parent = inputElement.parentElement;
        // Traverse up if inside common input wrappers
        if (parent && (
            parent.classList.contains('input-group') || 
            parent.classList.contains('profile-input-wrapper') || 
            parent.classList.contains('shipping-address-detail-composer') ||
            parent.classList.contains('search-input-group') ||
            parent.classList.contains('warranty-search-row')
        )) {
            parent = parent.parentElement;
        }

        let feedback = parent.querySelector('.error-feedback');
        if (!isValid) {
            inputElement.classList.add('is-invalid');
            if (!feedback) {
                feedback = document.createElement('small');
                feedback.className = 'error-feedback';
                feedback.style.color = '#ef4444';
                feedback.style.display = 'block';
                feedback.style.marginTop = '5px';
                feedback.style.fontWeight = '500';
                parent.appendChild(feedback);
            }
            feedback.textContent = errorMessage;
        } else {
            inputElement.classList.remove('is-invalid');
            if (feedback) {
                feedback.remove();
            }
        }
        return isValid;
    },

    clearFeedback(inputElement) {
        if (typeof inputElement === 'string') {
            inputElement = document.getElementById(inputElement);
        }
        if (!inputElement) return;

        let parent = inputElement.parentElement;
        if (parent && (
            parent.classList.contains('input-group') || 
            parent.classList.contains('profile-input-wrapper') || 
            parent.classList.contains('shipping-address-detail-composer') ||
            parent.classList.contains('search-input-group') ||
            parent.classList.contains('warranty-search-row')
        )) {
            parent = parent.parentElement;
        }

        inputElement.classList.remove('is-invalid');
        const feedback = parent.querySelector('.error-feedback');
        if (feedback) {
            feedback.remove();
        }
    },

    // Helper to setup real-time validation on multiple fields
    setupRealTimeValidation(config) {
        config.forEach(item => {
            const elements = document.querySelectorAll(item.selector);
            elements.forEach(element => {
                const validate = () => {
                    const isValid = item.validateFn(element.value, element);
                    const errorMsg = !isValid ? item.getErrorMsg(element.value, element) : '';
                    this.showFeedback(element, isValid, errorMsg);
                };
                element.addEventListener('blur', validate);
                element.addEventListener('input', () => {
                    if (element.classList.contains('is-invalid')) {
                        validate();
                    }
                });
            });
        });
    }
};

// Expose on window object
window.Validator = Validator;
