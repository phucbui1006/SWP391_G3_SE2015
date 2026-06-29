/**
 * Frontend Validation for Order History page (Specifically for Shipment Update)
 */
function validateShipmentUpdateForm(form) {
    const deliveryNameInput = form.querySelector('input[name="deliveryName"]');
    const deliveryPhoneInput = form.querySelector('input[name="deliveryPhone"]');

    if (deliveryNameInput) {
        const nameVal = deliveryNameInput.value.trim();
        if (!nameVal) {
            alert("Vui lòng nhập tên người giao hàng.");
            deliveryNameInput.focus();
            return false;
        }
        if (nameVal.length < 2 || nameVal.length > 50) {
            alert("Tên người giao hàng phải từ 2 đến 50 ký tự.");
            deliveryNameInput.focus();
            return false;
        }
    }

    if (deliveryPhoneInput) {
        const phoneVal = deliveryPhoneInput.value.trim();
        if (!phoneVal) {
            alert("Vui lòng nhập số điện thoại người giao hàng.");
            deliveryPhoneInput.focus();
            return false;
        }
        if (typeof Validator !== 'undefined' && typeof Validator.validatePhone === 'function') {
            if (!Validator.validatePhone(phoneVal)) {
                alert("Số điện thoại không hợp lệ (phải là mạng di động, bắt đầu bằng 03, 05, 07, 08, 09 và có 10 chữ số).");
                deliveryPhoneInput.focus();
                return false;
            }
        } else {
            const phoneRegex = /^(0[35789])[0-9]{8}$/;
            if (!phoneRegex.test(phoneVal)) {
                alert("Số điện thoại không hợp lệ (phải là mạng di động, bắt đầu bằng 03, 05, 07, 08, 09 và có 10 chữ số).");
                deliveryPhoneInput.focus();
                return false;
            }
        }
    }

    return true;
}
