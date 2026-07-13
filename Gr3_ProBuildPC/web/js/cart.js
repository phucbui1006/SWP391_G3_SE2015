(function () {
    const addToCartForms = document.querySelectorAll('.cart-form');
    const headerCartCountElement = document.querySelector('.cart-box .cart-icon span');
    const cartIconElement = document.querySelector('.cart-box .cart-icon');
    let toastElement = document.querySelector('[data-home-toast]');
    let toastMessageElement = document.querySelector('[data-home-toast-message]');
    let toastIconElement = document.querySelector('[data-home-toast-icon]');
    let toastTimerId = null;

    const addToCartButtons = document.querySelectorAll('[data-add-to-cart-btn]');

    if (!addToCartButtons.length && !addToCartForms.length) {
        return;
    }

    // Helper to get Context Path
    const getContextPath = function () {
        return document.body.dataset.contextPath || '';
    };

    const showToast = function (message, isSuccess) {
        if (!toastElement) toastElement = document.querySelector('[data-home-toast]');
        if (!toastMessageElement) toastMessageElement = document.querySelector('[data-home-toast-message]');
        if (!toastIconElement) toastIconElement = document.querySelector('[data-home-toast-icon]');

        if (!toastElement || !toastMessageElement || !toastIconElement) {
            return;
        }

        if (toastTimerId) {
            window.clearTimeout(toastTimerId);
        }

        toastMessageElement.textContent = message;
        toastIconElement.textContent = isSuccess ? '+' : '!';
        toastElement.hidden = false;
        toastElement.classList.remove('is-success', 'is-error');
        toastElement.classList.add(isSuccess ? 'is-success' : 'is-error');

        window.requestAnimationFrame(function () {
            toastElement.classList.add('is-visible');
        });

        toastTimerId = window.setTimeout(function () {
            toastElement.classList.remove('is-visible');
            window.setTimeout(function () {
                if (!toastElement.classList.contains('is-visible')) {
                    toastElement.hidden = true;
                }
            }, 220);
        }, 2600);
    };

    const animateProductFlyToCart = function (form) {
        if (!cartIconElement || !form) {
            return;
        }

        const productCard = form.closest('.product-card, .category-product-card, .detail-card, .build-pc-shell');
        let productImage = productCard ? productCard.querySelector('figure img, .main-image img, .build-part-product img') : null;
        if (!productImage && productCard) {
            productImage = productCard.querySelector('.build-slot-placeholder');
        }

        if (!productImage) {
            cartIconElement.classList.add('is-bumping');
            window.setTimeout(function () {
                cartIconElement.classList.remove('is-bumping');
            }, 520);
            return;
        }

        const imageRect = productImage.getBoundingClientRect();
        const cartRect = cartIconElement.getBoundingClientRect();
        const flyingImage = productImage.cloneNode(true);

        flyingImage.className = 'home-cart-flight';
        flyingImage.alt = '';
        flyingImage.setAttribute('aria-hidden', 'true');
        flyingImage.style.left = imageRect.left + 'px';
        flyingImage.style.top = imageRect.top + 'px';
        flyingImage.style.width = imageRect.width + 'px';
        flyingImage.style.height = imageRect.height + 'px';
        flyingImage.style.setProperty('--cart-flight-x', (cartRect.left - imageRect.left) + 'px');
        flyingImage.style.setProperty('--cart-flight-y', (cartRect.top - imageRect.top) + 'px');

        document.body.appendChild(flyingImage);

        window.requestAnimationFrame(function () {
            flyingImage.classList.add('is-flying');
        });

        window.setTimeout(function () {
            cartIconElement.classList.add('is-bumping');
        }, 520);

        window.setTimeout(function () {
            cartIconElement.classList.remove('is-bumping');
            flyingImage.remove();
        }, 980);
    };

    const handleAddToCart = function (form) {
        const submitButton = form.querySelector('[data-add-to-cart-btn]');
        if (!submitButton || submitButton.disabled || submitButton.classList.contains('is-adding')) {
            return;
        }

        const requestUrl = form.getAttribute('action') || (getContextPath() + '/cart');
        submitButton.classList.add('is-adding');

        fetch(requestUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                'X-Requested-With': 'XMLHttpRequest'
            },
            body: new URLSearchParams(new FormData(form)).toString()
        })
            .then(function (response) {
                return response.json().catch(function () {
                    return {};
                }).then(function (data) {
                    return { response: response, data: data };
                });
            })
            .then(function (result) {
                const response = result.response;
                const data = result.data || {};

                if (response.status === 401) {
                    showToast('Vui lòng đăng nhập để thêm sản phẩm vào giỏ hàng.', false);
                    window.setTimeout(function () {
                        window.location.href = getContextPath() + '/Login';
                    }, 900);
                    return;
                }

                if (!response.ok || !data.success) {
                    showToast(data.message || 'Không thể thêm sản phẩm vào giỏ hàng lúc này.', false);
                    return;
                }

                if (headerCartCountElement && typeof data.cartItemCount === 'number') {
                    headerCartCountElement.textContent = data.cartItemCount;
                }

                animateProductFlyToCart(form);
                submitButton.classList.add('is-added');
                showToast(data.message || 'Đã thêm sản phẩm vào giỏ hàng.', true);

                window.setTimeout(function () {
                    submitButton.classList.remove('is-added');
                }, 1400);
            })
            .catch(function () {
                showToast('Không thể kết nối đến giỏ hàng lúc này.', false);
            })
            .finally(function () {
                submitButton.classList.remove('is-adding');
            });
    };

    window.ProBuildCart = {
        showToast: showToast,
        animateProductFlyToCart: animateProductFlyToCart,
        handleAddToCart: handleAddToCart
    };

    addToCartButtons.forEach(function (btn) {
        btn.addEventListener('click', function (event) {
            if (btn.type === 'submit') {
                event.preventDefault();
            }
            const form = btn.closest('form');
            if (form) {
                if (typeof validateQuantity === 'function' && !validateQuantity(form, true)) {
                    return;
                }
                handleAddToCart(form);
            }
        });
    });
})();
