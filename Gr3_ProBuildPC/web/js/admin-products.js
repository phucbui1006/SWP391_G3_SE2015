
document.addEventListener("DOMContentLoaded", function () {

    var body = document.querySelector("body.admin-product-body");
    var contextPath = body ? body.getAttribute("data-ctx") || "" : "";

    var allowedImageTypes = ["png", "jpg", "jpeg", "webp"];
    var imageTypeMessage = "Định dạng file không hợp lệ. Chỉ chấp nhận .png, .jpg, .jpeg, .webp.";
    var imageSizeMessage = "Dung lượng file vượt quá 2MB. Vui lòng chọn ảnh nhỏ hơn.";


    /**
     * Validates 
     ảnh    */
    function validateImageFile(fileInput, isRequired) {
        var file = fileInput.files[0];
        if (!file) {
            if (isRequired) {
                Validator.showFeedback(fileInput, false, "Vui lòng chọn hình ảnh sản phẩm.");
                return false;
            }
            Validator.showFeedback(fileInput, true, "");
            return true;
        }

        var isTypeValid = Validator.validateFileType(file, allowedImageTypes);
        if (!isTypeValid) {
            Validator.showFeedback(fileInput, false, imageTypeMessage);
            fileInput.value = "";
            return false;
        }

        var isSizeValid = Validator.validateFileSize(file, 2 * 1024 * 1024);
        if (!isSizeValid) {
            Validator.showFeedback(fileInput, false, imageSizeMessage);
            fileInput.value = "";
            return false;
        }

        Validator.showFeedback(fileInput, true, "");
        return true;
    }

    /**
     * Cập nhật ảnh xem trước.
     */
    function updateImagePreview(fileInput, previewContainerId, previewImgId) {
        var file = fileInput.files[0];
        var container = document.getElementById(previewContainerId);
        var img = document.getElementById(previewImgId);
        if (file && container && img) {
            var reader = new FileReader();
            reader.onload = function (e) {
                img.src = e.target.result;
                container.style.display = "block";
            };
            reader.readAsDataURL(file);
        }
    }

    /**
     * Validates thời gian bảo hành.
     */
    function validateWarranty(value) {
        if (value === null || value === undefined || value === "")
            return false;
        var trimmed = value.trim();
        if (!/^\d+$/.test(trimmed))
            return false;
        var val = parseInt(trimmed, 10);
        return val > 0 && val <= 120;
    }

    function getProductNameError(value) {
        var name = (value || "").trim();
        if (name.length === 0) {
            return "Tên sản phẩm không được để trống.";
        }
        if (name.length < 3 || name.length > 255) {
            return "Tên sản phẩm phải từ 3 đến 255 ký tự.";
        }
        if (/\s{2,}/.test(name)) {
            return "Tên sản phẩm không được chứa nhiều dấu cách liên tiếp.";
        }
        return "";
    }

    /**
     * Validates thông số kĩ thuật của sản phẩm
     */
    function validateSpecificationFields(form) {
        var categoryInput = form.querySelector("select[name='categoryId']");
        var specButton = form.querySelector(".btn-load-specs");
        var specInputs = form.querySelectorAll("[name='spec_values[]']");
        var isValid = true;

        if (categoryInput && categoryInput.value && form.dataset.specsLoaded !== "true") {
            Validator.showFeedback(specButton, false, "Vui lòng tải và nhập thông số kỹ thuật theo danh mục.");
            return false;
        }

        Validator.showFeedback(specButton, true, "");

        specInputs.forEach(function (input) {
            var value = input.value.trim();
            var inputValid = !input.required || value !== "";

           // Lấy tên thông số từ label
            var specName = input.closest(".form-group")
                    .querySelector("label")
                    .textContent
                    .replace("*", "")
                    .trim();

            var message = "Thông số '" + specName + "' không được để trống.";
            if (inputValid && value.length > 255) {
                inputValid = false;
                message = "Thông số không được vượt quá 255 ký tự.";
            }

            if (input.type === "number" && (input.validity.badInput || value !== "")) {
                inputValid = !input.validity.badInput && /^[1-9]\d*$/.test(value);
                message = "Thông số phải là số nguyên từ 1 trở lên.";
            }

            Validator.showFeedback(input, inputValid, message);
            if (!inputValid) {
                isValid = false;
            }
        });

        return isValid;
    }

    /**
     * Validates toàn bộ dữ liệu của form thêm/sửa sản phẩm.
     * Nếu có lỗi sẽ hiển thị ngay dưới ô nhập.
     */
    function validateProductForm(form) {
        var isValid = true;

        // 1. Product Name
        var nameInp = form.querySelector("input[name='productName']");
        if (nameInp) {
            var nameOk = Validator.validateProductName(nameInp.value);
            Validator.showFeedback(nameInp, nameOk, getProductNameError(nameInp.value));
            if (!nameOk) {
                if (isValid)
                    nameInp.focus();
                isValid = false;
            }
        }

        // 2. Category
        var catInp = form.querySelector("select[name='categoryId']");
        if (catInp) {
            var catOk = catInp.value !== "";
            Validator.showFeedback(catInp, catOk, "Vui lòng chọn danh mục.");
            if (!catOk) {
                if (isValid)
                    catInp.focus();
                isValid = false;
            }
        }

        // 3. Brand
        var brandInp = form.querySelector("select[name='brandId']");
        if (brandInp) {
            var brandOk = brandInp.value !== "";
            Validator.showFeedback(brandInp, brandOk, "Vui lòng chọn thương hiệu.");
            if (!brandOk) {
                if (isValid)
                    brandInp.focus();
                isValid = false;
            }
        }

        // 4. Price (Must be positive, multiple of 1000, and max 1,000,000,000)
        var priceInp = form.querySelector("input[name='price']");
        if (priceInp) {
            var priceVal = parseFloat(priceInp.value);
            var priceOk = !isNaN(priceVal) && priceVal > 0 && (priceVal % 1000 === 0) && priceVal <= 1000000000;
            Validator.showFeedback(priceInp, priceOk, "Giá bán phải là số lớn hơn 0, nhỏ hơn hoặc bằng 1 tỷ và chia hết cho 1000.");
            if (!priceOk) {
                if (isValid)
                    priceInp.focus();
                isValid = false;
            }
        }

        // 5. Warranty Months (Must be strictly positive integer > 0, max 120)
        var warrantyInp = form.querySelector("input[name='warrantyMonths']");
        if (warrantyInp) {
            var warrantyOk = validateWarranty(warrantyInp.value);
            Validator.showFeedback(warrantyInp, warrantyOk, "Thời gian bảo hành phải là số nguyên dương lớn hơn 0 và không vượt quá 120 tháng.");
            if (!warrantyOk) {
                if (isValid)
                    warrantyInp.focus();
                isValid = false;
            }
        }

        // 6. Description
        var descInp = form.querySelector("textarea[name='description']");
        if (descInp) {
            var description = descInp.value.trim();
            var descOk = description !== "" && description.length <= 10000;
            Validator.showFeedback(descInp, descOk, description === ""
                    ? "Mô tả chi tiết không được để trống."
                    : "Mô tả chi tiết không được vượt quá 10.000 ký tự.");
            if (!descOk) {
                if (isValid)
                    descInp.focus();
                isValid = false;
            }
        }

        // 7. Required category specifications
        if (!validateSpecificationFields(form)) {
            isValid = false;
        }

        // 8. Image file (new image or preserved current image is required)
        var fileInp = form.querySelector("input[name='imgFile']");
        if (fileInp) {
            var currentImgVal = form.querySelector("input[name='currentImg']");
            var isImgReq = !currentImgVal || !currentImgVal.value || currentImgVal.value.trim() === "";
            var fileOk = validateImageFile(fileInp, isImgReq);
            if (!fileOk) {
                isValid = false;
            }
        }

        return isValid;
    }

    /**
     * Kiểm tra tên sản phẩm đã tồn tại hay chưa.
     *
     * Nếu sửa sản phẩm sẽ gửi thêm productId
     * để không kiểm tra trùng chính sản phẩm đang sửa.
     *
     * Trả về Promise<boolean>.
     */
    function checkProductNameDuplicate(form) {
        var nameInput = form.querySelector("input[name='productName']");
        var productIdInput = form.querySelector("input[name='productId']");

        if (!nameInput || !Validator.validateProductName(nameInput.value)) {
            return Promise.resolve(false);
        }

        var params = new URLSearchParams();
        params.set("action", "checkName");
        params.set("productName", nameInput.value.trim());
        if (productIdInput && productIdInput.value) {
            params.set("productId", productIdInput.value);
        }

        return fetch(contextPath + "/admin/products?" + params.toString(), {
            headers: {"X-Requested-With": "XMLHttpRequest"}
        }).then(function (response) {
            if (!response.ok) {
                throw new Error("Không thể kiểm tra tên sản phẩm.");
            }
            return response.json();
        }).then(function (data) {
            return data.duplicate === true;
        });
    }

    function handleProductFormSubmit(event, form) {
        event.preventDefault();

        var formValid = validateProductForm(form);
        var nameInput = form.querySelector("input[name='productName']");
        if (!nameInput || !Validator.validateProductName(nameInput.value)) {
            return;
        }

        var submitButton = form.querySelector("button[type='submit']");
        if (submitButton && submitButton.dataset.checkingName === "true") {
            return;
        }
        if (submitButton) {
            submitButton.dataset.checkingName = "true";
            submitButton.disabled = true;
        }

        checkProductNameDuplicate(form)
                .then(function (duplicate) {
                    if (duplicate) {
                        Validator.showFeedback(
                                nameInput,
                                false,
                                "Tên sản phẩm đã tồn tại trong hệ thống."
                                );
                        nameInput.focus();
                        nameInput.scrollIntoView({behavior: "smooth", block: "center"});
                        return;
                    }

                    if (formValid) {
                        HTMLFormElement.prototype.submit.call(form);
                    }
                })
                .catch(function () {

                    if (formValid) {
                        HTMLFormElement.prototype.submit.call(form);
                    }
                })
                .finally(function () {
                    if (submitButton) {
                        submitButton.dataset.checkingName = "false";
                        submitButton.disabled = false;
                    }
                });
    }

    /**
     * Gắn validate theo thời gian thực cho từng ô nhập.
     *
     * Khi người dùng nhập hoặc rời khỏi ô nhập,
     * hệ thống sẽ kiểm tra ngay và hiển thị lỗi nếu có.
     */
    function setupFieldValidation(form) {
        var nameInp = form.querySelector("input[name='productName']");
        var catInp = form.querySelector("select[name='categoryId']");
        var brandInp = form.querySelector("select[name='brandId']");
        var priceInp = form.querySelector("input[name='price']");
        var fileInp = form.querySelector("input[name='imgFile']");
        var descInp = form.querySelector("textarea[name='description']");
        var nameCheckTimer;
        var nameCheckVersion = 0;

        if (nameInp) {
            nameInp.addEventListener("input", function () {
                clearTimeout(nameCheckTimer);
                nameCheckVersion++;
                var currentVersion = nameCheckVersion;
                var nameOk = Validator.validateProductName(nameInp.value);
                Validator.showFeedback(nameInp, nameOk, getProductNameError(nameInp.value));

                if (!nameOk) {
                    return;
                }

                var checkedName = nameInp.value.trim();
                nameCheckTimer = setTimeout(function () {
                    checkProductNameDuplicate(form)
                            .then(function (duplicate) {
                                if (currentVersion === nameCheckVersion
                                        && nameInp.value.trim() === checkedName) {
                                    Validator.showFeedback(
                                            nameInp,
                                            !duplicate,
                                            "Tên sản phẩm đã tồn tại trong hệ thống."
                                    );
                                }
                            })
                            .catch(function () {
                                // Backend vẫn kiểm tra lại khi lưu nếu kết nối tạm thời lỗi.
                            });
                }, 300);
            });
        }

        if (catInp) {
            catInp.addEventListener("change", function () {
                Validator.showFeedback(catInp, catInp.value !== "", "Vui lòng chọn danh mục.");
            });
        }

        if (brandInp) {
            brandInp.addEventListener("change", function () {
                Validator.showFeedback(brandInp, brandInp.value !== "", "Vui lòng chọn thương hiệu.");
            });
        }

        if (priceInp) {
            priceInp.addEventListener("blur", function () {
                var priceVal = parseFloat(priceInp.value);
                var priceOk = !isNaN(priceVal) && priceVal > 0 && (priceVal % 1000 === 0) && priceVal <= 1000000000;
                Validator.showFeedback(priceInp, priceOk, "Giá bán phải là số lớn hơn 0, nhỏ hơn hoặc bằng 1 tỷ và chia hết cho 1000.");
            });
            priceInp.addEventListener("input", function () {
                var priceVal = parseFloat(priceInp.value);
                var priceOk = !isNaN(priceVal) && priceVal > 0 && (priceVal % 1000 === 0) && priceVal <= 1000000000;
                Validator.showFeedback(priceInp, priceOk, "Giá bán phải là số lớn hơn 0, nhỏ hơn hoặc bằng 1 tỷ và chia hết cho 1000.");
            });
        }

        var warrantyInp = form.querySelector("input[name='warrantyMonths']");
        if (warrantyInp) {
            warrantyInp.addEventListener("blur", function () {
                Validator.showFeedback(warrantyInp, validateWarranty(warrantyInp.value), "Thời gian bảo hành phải là số nguyên dương lớn hơn 0 và không vượt quá 120 tháng.");
            });
            warrantyInp.addEventListener("input", function () {
                Validator.showFeedback(warrantyInp, validateWarranty(warrantyInp.value), "Thời gian bảo hành phải là số nguyên dương lớn hơn 0 và không vượt quá 120 tháng.");
            });
        }

        if (fileInp) {
            fileInp.addEventListener("change", function () {
                var isNew = form.id === "addProductForm";
                var currentImgVal = form.querySelector("input[name='currentImg']");
                var isImgReq = !currentImgVal || !currentImgVal.value || currentImgVal.value.trim() === "";
                var fileOk = validateImageFile(fileInp, isImgReq);
                if (fileOk) {
                    fileInp.classList.remove("is-invalid");
                    var parent = fileInp.closest(".form-group");
                    if (parent) {
                        var errText = parent.querySelector(".form-error-text");
                        if (errText) {
                            errText.textContent = "";
                            errText.style.display = "none";
                        }
                    }
                    var prefix = isNew ? "add" : "edit";
                    updateImagePreview(fileInp, prefix + "ImgPreviewContainer", prefix + "ImgPreview");
                }
            });
        }

        if (descInp) {
            descInp.addEventListener("blur", function () {
                var value = descInp.value.trim();
                Validator.showFeedback(descInp, value !== "" && value.length <= 10000,
                        value === "" ? "Mô tả chi tiết không được để trống."
                        : "Mô tả chi tiết không được vượt quá 10.000 ký tự.");
            });
            descInp.addEventListener("input", function () {
                var value = descInp.value.trim();
                Validator.showFeedback(descInp, value !== "" && value.length <= 10000,
                        value === "" ? "Mô tả chi tiết không được để trống."
                        : "Mô tả chi tiết không được vượt quá 10.000 ký tự.");
            });
        }

        form.addEventListener("input", function (event) {
            if (event.target.matches("[name='spec_values[]']")) {
                validateSpecificationFields(form);
            }
        });

        form.addEventListener("change", function (event) {
            if (event.target.matches("[name='spec_values[]']")) {
                validateSpecificationFields(form);
            }
        });
    }


    /**
     *Tự động tạo (render) các ô nhập liệu thuộc tính sản phẩm
     */
    function renderSpecFields(templates, fieldsDiv, existingSpecs) {
        fieldsDiv.innerHTML = "";
        if (!templates || templates.length === 0) {
            return;
        }

        var specMap = existingSpecs || {};

        templates.forEach(function (template) {
            var formGroup = document.createElement("div");
            formGroup.className = "form-group";

            var label = document.createElement("label");
            label.textContent = template.specName;
            if (template.isRequired) {
                var requiredMark = document.createElement("span");
                requiredMark.textContent = " *";
                label.appendChild(requiredMark);
            }
            formGroup.appendChild(label);

            var hiddenName = document.createElement("input");
            hiddenName.type = "hidden";
            hiddenName.name = "spec_names[]";
            hiddenName.value = template.specName;
            formGroup.appendChild(hiddenName);

            var preValue = specMap[template.specName] || template.specValue || "";

            var inputElement;
            if (template.specType === "SELECT") {
                inputElement = document.createElement("select");
                inputElement.name = "spec_values[]";

                var defaultOpt = document.createElement("option");
                defaultOpt.value = "";
                defaultOpt.textContent = "-- Chọn " + template.specName + " --";
                inputElement.appendChild(defaultOpt);

                if (template.allowedValues) {
                    var options = template.allowedValues.split(",");
                    options.forEach(function (optVal) {
                        var opt = document.createElement("option");
                        opt.value = optVal.trim();
                        opt.textContent = optVal.trim();
                        if (optVal.trim() === preValue) {
                            opt.selected = true;
                        }
                        inputElement.appendChild(opt);
                    });
                }
            } else if (template.specType === "NUMBER") {
                inputElement = document.createElement("input");
                inputElement.type = "number";
                inputElement.name = "spec_values[]";
                inputElement.placeholder = "Nhập số lượng/thông số...";
                inputElement.value = preValue;
                inputElement.min = "1";
                inputElement.step = "1";
            } else {
                inputElement = document.createElement("input");
                inputElement.type = "text";
                inputElement.name = "spec_values[]";
                inputElement.placeholder = "Nhập thông tin...";
                inputElement.value = preValue;
            }

            if (template.isRequired) {
                inputElement.required = true;
            }

            formGroup.appendChild(inputElement);
            fieldsDiv.appendChild(formGroup);
        });
    }

    /**
     * Fetches category spec templates via AJAX.
     * @returns Promise<Array>
     */
    function fetchCategoryTemplates(categoryId, productId) {
        var url = contextPath + "/GetCategoryTemplates?categoryId=" + encodeURIComponent(categoryId);
        if (productId) {
            url += "&productId=" + encodeURIComponent(productId);
        }

        return fetch(url)
                .then(function (response) {
                    if (!response.ok) {
                        throw new Error("Không thể tải thông số kỹ thuật.");
                    }
                    return response.json();
                });
    }

    function loadSpecificationFields(form, categoryId, productId, button, container, fields) {
        if (!categoryId || !button || !container || !fields) {
            return Promise.resolve();
        }

        form.dataset.specsLoaded = "false";
        button.disabled = true;
        button.textContent = "Đang tải...";

        return fetchCategoryTemplates(categoryId, productId)
                .then(function (templates) {
                    renderSpecFields(templates, fields, {});
                    container.style.display = templates.length > 0 ? "block" : "none";
                    form.dataset.specsLoaded = "true";
                    Validator.showFeedback(button, true, "");
                    button.textContent = templates.length > 0
                            ? "Tải lại thông số kỹ thuật"
                            : "Danh mục không có thông số kỹ thuật";
                })
                .catch(function () {
                    form.dataset.specsLoaded = "false";
                    fields.innerHTML = "";
                    container.style.display = "none";
                    button.textContent = "Tải lại thông số kỹ thuật";
                    Validator.showFeedback(button, false, "Không thể tải thông số kỹ thuật. Vui lòng thử lại.");
                })
                .finally(function () {
                    button.disabled = false;
                });
    }

    // ══════════════════════════════════════════════════════════
    //  ADD PRODUCT MODAL – Spec Button Logic
    // ══════════════════════════════════════════════════════════

    var addCategorySelect = document.getElementById("addCategory");
    var addSpecBtn = document.getElementById("addSpecBtn");
    var addSpecsContainer = document.getElementById("dynamicSpecsContainer");
    var addSpecsFields = document.getElementById("dynamicSpecsFields");
    var addProductForm = document.getElementById("addProductForm");

    if (addCategorySelect && addSpecBtn && addProductForm) {
        addProductForm.dataset.specsLoaded = addProductForm.dataset.specsLoaded === "true"
                || addSpecsFields && addSpecsFields.querySelector("[name='spec_values[]']")
                ? "true" : "false";

        addCategorySelect.addEventListener("change", function () {
            if (this.value) {
                addSpecBtn.style.display = "inline-flex";
                addSpecBtn.textContent = "Tải thông số kĩ thuật";
            } else {
                addSpecBtn.style.display = "none";
            }

            addProductForm.dataset.specsLoaded = "false";
            if (addSpecsContainer)
                addSpecsContainer.style.display = "none";
            if (addSpecsFields)
                addSpecsFields.innerHTML = "";
            Validator.showFeedback(addSpecBtn, true, "");
        });

        addSpecBtn.addEventListener("click", function (e) {
            e.preventDefault();
            var categoryId = addCategorySelect.value;
            if (!categoryId)
                return;

            loadSpecificationFields(
                    addProductForm, categoryId, null,
                    addSpecBtn, addSpecsContainer, addSpecsFields
                    );
        });
    }

    // ══════════════════════════════════════════════════════════
    //  EDIT PRODUCT MODAL – Spec Button Logic
    // ══════════════════════════════════════════════════════════

    var editSpecBtn = document.getElementById("editSpecBtn");
    var editSpecsContainer = document.getElementById("editDynamicSpecsContainer");
    var editSpecsFields = document.getElementById("editDynamicSpecsFields");
    var editCategorySelect = document.getElementById("editCategory");
    var editProductForm = document.getElementById("editProductForm");
    var editOriginalCategoryId = editCategorySelect ? editCategorySelect.value : "";

    if (editSpecBtn && editCategorySelect && editProductForm) {
        editProductForm.dataset.specsLoaded = editProductForm.dataset.specsLoaded === "true"
                || editSpecsFields && editSpecsFields.querySelector("[name='spec_values[]']")
                ? "true" : "false";

        editCategorySelect.addEventListener("change", function () {
            editProductForm.dataset.specsLoaded = "false";
            editSpecBtn.style.display = this.value ? "inline-flex" : "none";
            editSpecBtn.textContent = "Tải thông số kĩ thuật";
            if (editSpecsContainer)
                editSpecsContainer.style.display = "none";
            if (editSpecsFields)
                editSpecsFields.innerHTML = "";
            Validator.showFeedback(editSpecBtn, true, "");
        });

        editSpecBtn.addEventListener("click", function (e) {
            e.preventDefault();
            var categoryId = editCategorySelect.value;
            var productId = categoryId === editOriginalCategoryId
                    ? document.getElementById("editProductId").value
                    : "";

            if (!categoryId)
                return;

            loadSpecificationFields(
                    editProductForm, categoryId, productId,
                    editSpecBtn, editSpecsContainer, editSpecsFields
                    );
        });
    }

    // ══════════════════════════════════════════════════════════
    //  MODAL OPEN HELPERS (exposed globally)
    // ══════════════════════════════════════════════════════════

    function clearFormFields(form) {
        if (!form)
            return;
        form.querySelectorAll("input").forEach(function (inp) {
            if (inp.name !== "action") {
                inp.value = "";
            }
        });
        form.querySelectorAll("select").forEach(function (sel) {
            sel.selectedIndex = 0;
            sel.value = "";
        });
        form.querySelectorAll("textarea").forEach(function (txt) {
            txt.value = "";
        });
    }

    window.openAddModal = function () {
        var addForm = document.getElementById("addProductForm");
        if (addForm) {
            addForm.reset();
            clearFormFields(addForm);
            // Clear all validation feedback
            addForm.querySelectorAll(".is-invalid").forEach(function (el) {
                Validator.clearFeedback(el);
            });
            addForm.querySelectorAll(".form-error-text").forEach(function (el) {
                el.textContent = "";
                el.style.display = "none";
            });
        }
        // Reset spec state
        if (addSpecBtn)
            addSpecBtn.style.display = "none";
        if (addSpecsContainer)
            addSpecsContainer.style.display = "none";
        if (addSpecsFields)
            addSpecsFields.innerHTML = "";
        if (addForm)
            addForm.dataset.specsLoaded = "false";

        // Re-enable submit
        var submitBtn = addForm ? addForm.querySelector("button[type='submit']") : null;
        if (submitBtn)
            submitBtn.disabled = false;
    };

    window.openPriceModal = function (productId, productName, currentPrice) {
        var priceForm = document.getElementById("priceProductForm");
        if (priceForm) {
            priceForm.querySelectorAll(".is-invalid").forEach(function (el) {
                Validator.clearFeedback(el);
            });
        }
        document.getElementById("priceProductId").value = productId;
        document.getElementById("priceProductName").textContent = productName;
        document.getElementById("quickPriceVal").value = currentPrice;
    };

    // ══════════════════════════════════════════════════════════
    //  FORM SUBMIT HANDLERS
    // ══════════════════════════════════════════════════════════

    // Add Product Form
    var addForm = document.getElementById("addProductForm");
    if (addForm) {
        setupFieldValidation(addForm);
        addForm.addEventListener("submit", function (e) {
            handleProductFormSubmit(e, addForm);
        });
    }

    // Edit Product Form
    var editForm = document.getElementById("editProductForm");
    if (editForm) {
        setupFieldValidation(editForm);
        editForm.addEventListener("submit", function (e) {
            handleProductFormSubmit(e, editForm);
        });
    }

    // Quick Price Form
    var priceForm = document.getElementById("priceProductForm");
    if (priceForm) {
        priceForm.addEventListener("submit", function (e) {
            var priceInp = document.getElementById("quickPriceVal");
            var priceOk = Validator.validatePrice(priceInp.value);
            Validator.showFeedback(priceInp, priceOk, "Giá bán phải là số và không nhỏ hơn 0.");
            if (!priceOk) {
                e.preventDefault();
                priceInp.focus();
            }
        });
    }

    // ══════════════════════════════════════════════════════════
    //  SEARCH FORM – Trim keyword on submit
    // ══════════════════════════════════════════════════════════

    var searchForm = document.getElementById("adminProductSearchForm");
    if (searchForm) {
        searchForm.addEventListener("submit", function () {
            var inp = document.getElementById("productSearchInput");
            if (inp) {
                inp.value = inp.value.trim();
            }
        });
    }

    // ══════════════════════════════════════════════════════════
    //  MODAL RESET ON CLOSE HANDLERS
    // ══════════════════════════════════════════════════════════

    function resetFormAndErrors(form) {
        if (!form)
            return;
        form.reset();
        clearFormFields(form);
        form.querySelectorAll(".is-invalid").forEach(function (el) {
            el.classList.remove("is-invalid");
        });
        form.querySelectorAll(".form-error-text").forEach(function (el) {
            el.textContent = "";
            el.style.display = "none";
        });

        // Reset dynamic specs elements
        var addSpecsContainer = document.getElementById("dynamicSpecsContainer");
        var addSpecsFields = document.getElementById("dynamicSpecsFields");
        var addSpecBtn = document.getElementById("addSpecBtn");
        if (addSpecsContainer)
            addSpecsContainer.style.display = "none";
        if (addSpecsFields)
            addSpecsFields.innerHTML = "";
        if (addSpecBtn) {
            addSpecBtn.style.display = "none";
            addSpecBtn.textContent = "Tải thông số kĩ thuật";
            addSpecBtn.disabled = false;
        }

        var editSpecsContainer = document.getElementById("editDynamicSpecsContainer");
        var editSpecsFields = document.getElementById("editDynamicSpecsFields");
        var editSpecBtn = document.getElementById("editSpecBtn");
        if (editSpecsContainer)
            editSpecsContainer.style.display = "none";
        if (editSpecsFields)
            editSpecsFields.innerHTML = "";
        form.dataset.specsLoaded = "false";
        if (editSpecBtn) {
            editSpecBtn.style.display = "inline-flex";
            editSpecBtn.textContent = "Tải thông số kĩ thuật";
            editSpecBtn.disabled = false;
        }

        // Reset image previews and currentImg fallbacks
        var addImgPreviewContainer = document.getElementById("addImgPreviewContainer");
        var addImgPreview = document.getElementById("addImgPreview");
        var addCurrentImg = document.getElementById("addCurrentImg");
        if (addImgPreviewContainer)
            addImgPreviewContainer.style.display = "none";
        if (addImgPreview)
            addImgPreview.src = "";
        if (addCurrentImg)
            addCurrentImg.value = "";

        var editImgPreviewContainer = document.getElementById("editImgPreviewContainer");
        var editImgPreview = document.getElementById("editImgPreview");
        var editCurrentImg = document.getElementById("editCurrentImg");
        if (editImgPreviewContainer)
            editImgPreviewContainer.style.display = "none";
        if (editImgPreview)
            editImgPreview.src = "";
        if (editCurrentImg)
            editCurrentImg.value = "";
    }

    // Bind click events on dismiss buttons (X icon and Cancel button)
    var dismissButtons = document.querySelectorAll(".product-modal .close-btn, .product-modal .btn-secondary");
    dismissButtons.forEach(function (btn) {
        btn.addEventListener("click", function () {
            var overlay = btn.closest(".product-modal-overlay");
            if (overlay) {
                overlay.classList.remove("server-open");
            }
            resetFormAndErrors(document.getElementById("addProductForm"));
            resetFormAndErrors(document.getElementById("editProductForm"));
        });
    });

    // Handle hashchange back actions
    window.addEventListener("hashchange", function () {
        var hash = window.location.hash;
        if (hash !== "#add-product-modal" && hash !== "#edit-product-modal") {
            resetFormAndErrors(document.getElementById("addProductForm"));
            resetFormAndErrors(document.getElementById("editProductForm"));
        }
    });

});
