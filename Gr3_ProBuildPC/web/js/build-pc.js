// Tương tác mở và đóng modal chọn linh kiện trên trang Build PC.
(function () {
    var activeModalTrigger = null;

    function closeBuildModal(modal) {
        if (!modal) return;
        modal.classList.remove('is-open');
        modal.setAttribute('aria-hidden', 'true');
        document.body.classList.remove('build-modal-open');
        if (activeModalTrigger) {
            activeModalTrigger.focus();
            activeModalTrigger = null;
        }
    }

    // Mở modal chọn linh kiện cho một slot Build PC.
    document.querySelectorAll('.build-open-quick-view').forEach(function (button) {
        button.addEventListener('click', function () {
            var modal = document.getElementById(button.getAttribute('data-build-modal'));
            if (modal) {
                activeModalTrigger = button;
                modal.classList.add('is-open');
                modal.setAttribute('aria-hidden', 'false');
                document.body.classList.add('build-modal-open');
                var closeButton = modal.querySelector('[data-build-close]:not(.build-quick-backdrop)');
                if (closeButton) closeButton.focus();
            }
        });
    });

    // Đóng modal chọn linh kiện.
    document.querySelectorAll('[data-build-close]').forEach(function (button) {
        button.addEventListener('click', function () {
            var modal = button.closest('.build-quick-view');
            closeBuildModal(modal);
        });
    });

    // Cho phép đóng modal bằng phím Escape.
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            closeBuildModal(document.querySelector('.build-quick-view.is-open'));
        }
    });

})();
