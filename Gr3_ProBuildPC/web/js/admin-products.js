/**
 * Admin Products – Client-side Validation & Dynamic Specification Management
 * Mirrors the structure of admin-brands.js using the centralized Validator library.
 */
document.addEventListener("DOMContentLoaded", function () {

    // ── Context path injected from JSP via data attribute ──
    var body = document.querySelector("body.admin-product-body");
    var contextPath = body ? body.getAttribute("data-ctx") || "" : "";

    // ── File validation constants ──
    var allowedImageTypes = ["png", "jpg", "jpeg", "webp"];
    var imageTypeMessage = "Định dạng file không hợp lệ. Chỉ chấp nhận .png, .jpg, .jpeg, .webp.";
    var imageSizeMessage = "Dung lượng file vượt quá 2MB. Vui lòng chọn ảnh nhỏ hơn.";

    // ══════════════════════════════════════════════════════════
    //  FORM VALIDATION  (using centralized Validator library)
    // ══════════════════════════════════════════════════════════

    /**
     * Validates an image file input using Validator helpers.
     * Returns true if valid or if no file is selected (optional).
     */
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
     * Validates warranty period.
     * Must not be empty, must be a valid integer, and must be > 0.
     */
    function validateWarranty(value) {
        if (value === null || value === undefined || value === "") return false;
        var trimmed = value.trim();
        if (!/^\d+$/.test(trimmed)) return false;
        var val = parseInt(trimmed, 10);
        return val > 0;
    }

    /**
     * Full-form validation for Add/Edit product forms.
     * Uses Validator.showFeedback() consistent with admin-brands.js pattern.
     */
    function validateProductForm(form, isNew) {
        var isValid = true;

        // 1. Product Name
        var nameInp = form.querySelector("input[name='productName']");
        if (nameInp) {
            var nameOk = Validator.validateProductName(nameInp.value);
            Validator.showFeedback(nameInp, nameOk, "Tên sản phẩm phải từ 3 đến 255 ký tự.");
            if (!nameOk) {
                if (isValid) nameInp.focus();
                isValid = false;
            }
        }

        // 2. Category
        var catInp = form.querySelector("select[name='categoryId']");
        if (catInp) {
            var catOk = catInp.value !== "";
            Validator.showFeedback(catInp, catOk, "Vui lòng chọn danh mục.");
            if (!catOk) {
                if (isValid) catInp.focus();
                isValid = false;
            }
        }

        // 3. Brand
        var brandInp = form.querySelector("select[name='brandId']");
        if (brandInp) {
            var brandOk = brandInp.value !== "";
            Validator.showFeedback(brandInp, brandOk, "Vui lòng chọn thương hiệu.");
            if (!brandOk) {
                if (isValid) brandInp.focus();
                isValid = false;
            }
        }

        // 4. Price
        var priceInp = form.querySelector("input[name='price']");
        if (priceInp) {
            var priceOk = Validator.validatePrice(priceInp.value);
            Validator.showFeedback(priceInp, priceOk, "Giá bán phải là số và không nhỏ hơn 0.");
            if (!priceOk) {
                if (isValid) priceInp.focus();
                isValid = false;
            }
        }

        // 5. Warranty Months
        var warrantyInp = form.querySelector("input[name='warrantyMonths']");
        if (warrantyInp) {
            var warrantyOk = validateWarranty(warrantyInp.value);
            Validator.showFeedback(warrantyInp, warrantyOk, "Thời gian bảo hành phải là số nguyên dương lớn hơn 0.");
            if (!warrantyOk) {
                if (isValid) warrantyInp.focus();
                isValid = false;
            }
        }

        // 6. Image file (required only for new products — optional)
        var fileInp = form.querySelector("input[name='imgFile']");
        if (fileInp) {
            var fileOk = validateImageFile(fileInp, false);
            if (!fileOk) isValid = false;
        }

        return isValid;
    }

    // ── Setup real-time validation with blur/input events ──
    function setupFieldValidation(form) {
        var nameInp = form.querySelector("input[name='productName']");
        var catInp = form.querySelector("select[name='categoryId']");
        var brandInp = form.querySelector("select[name='brandId']");
        var priceInp = form.querySelector("input[name='price']");
        var fileInp = form.querySelector("input[name='imgFile']");

        if (nameInp) {
            nameInp.addEventListener("blur", function () {
                Validator.showFeedback(nameInp, Validator.validateProductName(nameInp.value), "Tên sản phẩm phải từ 3 đến 255 ký tự.");
            });
            nameInp.addEventListener("input", function () {
                if (nameInp.classList.contains("is-invalid")) {
                    Validator.showFeedback(nameInp, Validator.validateProductName(nameInp.value), "Tên sản phẩm phải từ 3 đến 255 ký tự.");
                }
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
                Validator.showFeedback(priceInp, Validator.validatePrice(priceInp.value), "Giá bán phải là số và không nhỏ hơn 0.");
            });
            priceInp.addEventListener("input", function () {
                if (priceInp.classList.contains("is-invalid")) {
                    Validator.showFeedback(priceInp, Validator.validatePrice(priceInp.value), "Giá bán phải là số và không nhỏ hơn 0.");
                }
            });
        }

        var warrantyInp = form.querySelector("input[name='warrantyMonths']");
        if (warrantyInp) {
            warrantyInp.addEventListener("blur", function () {
                Validator.showFeedback(warrantyInp, validateWarranty(warrantyInp.value), "Thời gian bảo hành phải là số nguyên dương lớn hơn 0.");
            });
            warrantyInp.addEventListener("input", function () {
                if (warrantyInp.classList.contains("is-invalid")) {
                    Validator.showFeedback(warrantyInp, validateWarranty(warrantyInp.value), "Thời gian bảo hành phải là số nguyên dương lớn hơn 0.");
                }
            });
        }

        if (fileInp) {
            fileInp.addEventListener("change", function () {
                validateImageFile(fileInp, false);
            });
        }
    }

    // ══════════════════════════════════════════════════════════
    //  DYNAMIC SPECIFICATIONS (AJAX)
    // ══════════════════════════════════════════════════════════

    /**
     * Renders spec template fields into a target container.
     * @param {Array} templates - Array of CategorySpecTemplate JSON objects
     * @param {HTMLElement} fieldsDiv - The container to render into
     * @param {Object} existingSpecs - Map of specName -> specValue for pre-filling (optional)
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
            label.innerHTML = template.specName + (template.isRequired ? " <span>*</span>" : "");
            formGroup.appendChild(label);

            // Hidden field for spec name
            var hiddenName = document.createElement("input");
            hiddenName.type = "hidden";
            hiddenName.name = "spec_names[]";
            hiddenName.value = template.specName;
            formGroup.appendChild(hiddenName);

            // Determine pre-fill value
            var preValue = specMap[template.specName] || "";

            // Spec value input based on type
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
    function fetchCategoryTemplates(categoryId) {
        return fetch(contextPath + "/GetCategoryTemplates?categoryId=" + categoryId)
            .then(function (response) {
                return response.json();
            });
    }

    /**
     * Fetches existing product specifications via AJAX.
     * @returns Promise<Array>
     */
    function fetchProductSpecs(productId) {
        return fetch(contextPath + "/GetProductSpecs?productId=" + productId)
            .then(function (response) {
                return response.json();
            });
    }

    /**
     * Converts an array of {specificationName, specificationValue} into a map.
     */
    function specsToMap(specsArray) {
        var map = {};
        if (specsArray && specsArray.length > 0) {
            specsArray.forEach(function (s) {
                map[s.specificationName] = s.specificationValue;
            });
        }
        return map;
    }

    // ══════════════════════════════════════════════════════════
    //  ADD PRODUCT MODAL – Spec Button Logic
    // ══════════════════════════════════════════════════════════

    var addCategorySelect = document.getElementById("addCategory");
    var addSpecBtn = document.getElementById("addSpecBtn");
    var addSpecsContainer = document.getElementById("dynamicSpecsContainer");
    var addSpecsFields = document.getElementById("dynamicSpecsFields");

    if (addCategorySelect && addSpecBtn) {
        // Show/hide the button based on category selection
        addCategorySelect.addEventListener("change", function () {
            if (this.value) {
                addSpecBtn.style.display = "inline-flex";
            } else {
                addSpecBtn.style.display = "none";
                if (addSpecsContainer) addSpecsContainer.style.display = "none";
                if (addSpecsFields) addSpecsFields.innerHTML = "";
            }
        });

        // Button click → fetch and render specs
        addSpecBtn.addEventListener("click", function (e) {
            e.preventDefault();
            var categoryId = addCategorySelect.value;
            if (!categoryId) return;

            addSpecBtn.disabled = true;
            addSpecBtn.textContent = "Đang tải...";

            fetchCategoryTemplates(categoryId)
                .then(function (data) {
                    if (data.length === 0) {
                        if (addSpecsContainer) addSpecsContainer.style.display = "none";
                        if (addSpecsFields) addSpecsFields.innerHTML = "";
                        addSpecBtn.textContent = "Không có thông số cho danh mục này";
                        setTimeout(function () {
                            addSpecBtn.textContent = "Lựa chọn thông số kĩ thuật";
                            addSpecBtn.disabled = false;
                        }, 2000);
                        return;
                    }

                    renderSpecFields(data, addSpecsFields, {});
                    if (addSpecsContainer) addSpecsContainer.style.display = "block";
                    addSpecBtn.textContent = "Lựa chọn thông số kĩ thuật";
                    addSpecBtn.disabled = false;
                })
                .catch(function (err) {
                    console.error("Error fetching specifications:", err);
                    addSpecBtn.textContent = "Lựa chọn thông số kĩ thuật";
                    addSpecBtn.disabled = false;
                });
        });
    }

    // ══════════════════════════════════════════════════════════
    //  EDIT PRODUCT MODAL – Spec Button Logic
    // ══════════════════════════════════════════════════════════

    var editSpecBtn = document.getElementById("editSpecBtn");
    var editSpecsContainer = document.getElementById("editDynamicSpecsContainer");
    var editSpecsFields = document.getElementById("editDynamicSpecsFields");
    var editCategorySelect = document.getElementById("editCategory");

    if (editSpecBtn) {
        editSpecBtn.addEventListener("click", function (e) {
            e.preventDefault();
            var categoryId = editCategorySelect ? editCategorySelect.value : "";
            var productId = document.getElementById("editProductId").value;

            if (!categoryId) return;

            editSpecBtn.disabled = true;
            editSpecBtn.textContent = "Đang tải...";

            // Fetch both templates and existing specs in parallel
            Promise.all([
                fetchCategoryTemplates(categoryId),
                productId ? fetchProductSpecs(productId) : Promise.resolve([])
            ])
                .then(function (results) {
                    var templates = results[0];
                    var existingSpecs = results[1];

                    if (templates.length === 0) {
                        if (editSpecsContainer) editSpecsContainer.style.display = "none";
                        if (editSpecsFields) editSpecsFields.innerHTML = "";
                        editSpecBtn.textContent = "Không có thông số cho danh mục này";
                        setTimeout(function () {
                            editSpecBtn.textContent = "Lựa chọn thông số kĩ thuật";
                            editSpecBtn.disabled = false;
                        }, 2000);
                        return;
                    }

                    var specMap = specsToMap(existingSpecs);
                    renderSpecFields(templates, editSpecsFields, specMap);
                    if (editSpecsContainer) editSpecsContainer.style.display = "block";
                    editSpecBtn.textContent = "Lựa chọn thông số kĩ thuật";
                    editSpecBtn.disabled = false;
                })
                .catch(function (err) {
                    console.error("Error fetching specifications:", err);
                    editSpecBtn.textContent = "Lựa chọn thông số kĩ thuật";
                    editSpecBtn.disabled = false;
                });
        });
    }

    // ══════════════════════════════════════════════════════════
    //  MODAL OPEN HELPERS (exposed globally)
    // ══════════════════════════════════════════════════════════

    window.openAddModal = function () {
        var addForm = document.getElementById("addProductForm");
        if (addForm) {
            addForm.reset();
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
        if (addSpecBtn) addSpecBtn.style.display = "none";
        if (addSpecsContainer) addSpecsContainer.style.display = "none";
        if (addSpecsFields) addSpecsFields.innerHTML = "";

        // Re-enable submit
        var submitBtn = addForm ? addForm.querySelector("button[type='submit']") : null;
        if (submitBtn) submitBtn.disabled = false;
    };

    window.openEditModal = function (productId, productName, categoryId, brandId, price, warrantyMonths, description, currentImgUrl) {
        var editForm = document.getElementById("editProductForm");
        if (editForm) {
            // Clear all validation feedback
            editForm.querySelectorAll(".is-invalid").forEach(function (el) {
                Validator.clearFeedback(el);
            });
            editForm.querySelectorAll(".form-error-text").forEach(function (el) {
                el.textContent = "";
                el.style.display = "none";
            });
        }

        document.getElementById("editProductId").value = productId;
        document.getElementById("editProductName").value = productName;
        document.getElementById("editCategory").value = categoryId;
        document.getElementById("editBrand").value = brandId;
        document.getElementById("editPrice").value = price;
        document.getElementById("editWarrantyMonths").value = warrantyMonths;
        document.getElementById("editDescription").value = description;
        document.getElementById("editCurrentImg").value = currentImgUrl;

        // Image preview
        var previewContainer = document.getElementById("editImgPreviewContainer");
        var previewImg = document.getElementById("editImgPreview");
        if (currentImgUrl && currentImgUrl.trim() !== "") {
            previewImg.src = contextPath + "/" + currentImgUrl;
            previewContainer.style.display = "block";
        } else {
            previewContainer.style.display = "none";
        }

        // Reset spec state for edit modal
        if (editSpecsContainer) editSpecsContainer.style.display = "none";
        if (editSpecsFields) editSpecsFields.innerHTML = "";
        if (editSpecBtn) {
            editSpecBtn.style.display = "inline-flex";
            editSpecBtn.disabled = false;
            editSpecBtn.textContent = "Lựa chọn thông số kĩ thuật";
        }

        // Re-enable submit
        var submitBtn = editForm ? editForm.querySelector("button[type='submit']") : null;
        if (submitBtn) submitBtn.disabled = false;
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
            if (!validateProductForm(addForm, true)) {
                e.preventDefault();
            }
        });
    }

    // Edit Product Form
    var editForm = document.getElementById("editProductForm");
    if (editForm) {
        setupFieldValidation(editForm);
        editForm.addEventListener("submit", function (e) {
            if (!validateProductForm(editForm, false)) {
                e.preventDefault();
            }
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
});
