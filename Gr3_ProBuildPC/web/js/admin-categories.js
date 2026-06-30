document.addEventListener('DOMContentLoaded', function () {
    var addForm = document.getElementById('addCategoryForm');
    var editForm = document.getElementById('editCategoryForm');

    function ensureErrorBox(form) {
        var errorBox = form.querySelector('.category-form-error');
        if (!errorBox) {
            errorBox = document.createElement('div');
            errorBox.className = 'category-form-error category-alert error';
            errorBox.style.marginBottom = '16px';
            form.insertBefore(errorBox, form.firstChild);
        }
        return errorBox;
    }

    function clearFormError(form) {
        var errorBox = form.querySelector('.category-form-error');
        if (errorBox) {
            errorBox.remove();
        }
    }

    function validateCategoryName(form) {
        var nameInput = form.querySelector('input[name="categoryName"]');
        var isValid = true;

        if (!nameInput) {
            return true;
        }

        var value = (nameInput.value || '').trim();
        if (!value) {
            Validator.showFeedback(nameInput, false, 'Tên danh mục không được để trống.');
            isValid = false;
        } else if (value.length < 2 || value.length > 100) {
            Validator.showFeedback(nameInput, false, 'Tên danh mục phải có độ dài từ 2 đến 100 ký tự.');
            isValid = false;
        } else {
            Validator.showFeedback(nameInput, true, '');
        }

        return isValid;
    }

    function validateSpecRow(row) {
        var rowValid = true;
        var specNameInput = row.querySelector('input[name^="specName_"]');
        var specTypeInput = row.querySelector('select[name^="specType_"], input[name^="specType_"]');
        var allowedValuesInput = row.querySelector('input[name^="allowedValues_"]');
        var displayOrderInput = row.querySelector('input[name^="displayOrder_"]');

        if (!specNameInput) {
            return true;
        }

        var specName = (specNameInput.value || '').trim();
        if (!specName) {
            Validator.showFeedback(specNameInput, false, 'Tên thuộc tính không được để trống.');
            rowValid = false;
        } else if (specName.length > 255) {
            Validator.showFeedback(specNameInput, false, 'Tên thuộc tính không được vượt quá 255 ký tự.');
            rowValid = false;
        } else {
            Validator.showFeedback(specNameInput, true, '');
        }

        var specType = specTypeInput ? (specTypeInput.value || '').trim().toUpperCase() : '';
        if (specType !== 'TEXT' && specType !== 'SELECT' && specType !== 'NUMBER') {
            if (specTypeInput) {
                Validator.showFeedback(specTypeInput, false, 'Kiểu dữ liệu thuộc tính không hợp lệ.');
            }
            rowValid = false;
        } else if (specTypeInput) {
            Validator.showFeedback(specTypeInput, true, '');
        }

        if (specType === 'SELECT') {
            var allowedValues = (allowedValuesInput ? allowedValuesInput.value : '') || '';
            if (!allowedValues.trim()) {
                if (allowedValuesInput) {
                    Validator.showFeedback(allowedValuesInput, false, 'Đối với kiểu SELECT, giá trị cho phép không được để trống.');
                }
                rowValid = false;
            } else if (allowedValues.length > 500) {
                if (allowedValuesInput) {
                    Validator.showFeedback(allowedValuesInput, false, 'Giá trị cho phép không được vượt quá 500 ký tự.');
                }
                rowValid = false;
            } else if (allowedValuesInput) {
                Validator.showFeedback(allowedValuesInput, true, '');
            }
        } else if (allowedValuesInput) {
            Validator.showFeedback(allowedValuesInput, true, '');
        }

        if (!displayOrderInput) {
            return rowValid;
        }

        var displayOrderValue = (displayOrderInput.value || '').trim();
        var displayOrder = parseInt(displayOrderValue, 10);
        if (!/^-?\d+$/.test(displayOrderValue) || isNaN(displayOrder) || displayOrder < 0) {
            Validator.showFeedback(displayOrderInput, false, 'Thứ tự hiển thị phải là số không âm.');
            rowValid = false;
        } else {
            Validator.showFeedback(displayOrderInput, true, '');
        }

        return rowValid;
    }

    function validateAllRows(form) {
        var rows = Array.prototype.slice.call(form.querySelectorAll('tbody tr'));
        var valid = true;
        var specRows = rows.filter(function (row) {
            return row.querySelector('input[name^="specName_"]') || row.querySelector('select[name^="specType_"]');
        });

        specRows.forEach(function (row) {
            if (!validateSpecRow(row)) {
                valid = false;
            }
        });

        return valid;
    }

    function validateCategoryForm(form, actionValue) {
        clearFormError(form);

        var isValid = true;
        if (!validateCategoryName(form)) {
            isValid = false;
        }

        if (actionValue === 'saveCategory') {
            if (!validateAllRows(form)) {
                isValid = false;
            }
        } else if (actionValue && actionValue.indexOf('saveSpec_') === 0) {
            var rowIndex = parseInt(actionValue.replace('saveSpec_', ''), 10);
            var targetRow = form.querySelectorAll('tbody tr')[rowIndex];
            if (targetRow && !validateSpecRow(targetRow)) {
                isValid = false;
            }
        }

        if (!isValid) {
            var errorBox = ensureErrorBox(form);
            errorBox.innerHTML = '<i class="fa-solid fa-triangle-exclamation" style="margin-right:6px;"></i>Vui lòng sửa các trường không hợp lệ trước khi lưu.';
            return false;
        }

        return true;
    }

    function attachValidation(form) {
        if (!form) {
            return;
        }

        form.addEventListener('submit', function (event) {
            var submitter = event.submitter;
            var actionValue = '';
            if (submitter && submitter.getAttribute('name') === 'action') {
                actionValue = submitter.value || '';
            }

            if (actionValue === 'addSpec' || actionValue === 'cancel') {
                clearFormError(form);
                return;
            }

            if (actionValue.indexOf('editSpec_') === 0 || actionValue.indexOf('toggleRequired_') === 0) {
                clearFormError(form);
                return;
            }

            if (!validateCategoryForm(form, actionValue)) {
                event.preventDefault();
            }
        });
    }

    attachValidation(addForm);
    attachValidation(editForm);
});
