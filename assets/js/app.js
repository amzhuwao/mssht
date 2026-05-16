/**
 * MSSHT Application JavaScript (jQuery)
 */
(function ($) {
    'use strict';

    // Sidebar toggle (mobile)
    $('#sidebarToggle').on('click', function () {
        $('#sidebar').toggleClass('open');
    });

    // User dropdown
    $('#userMenuBtn').on('click', function (e) {
        e.stopPropagation();
        $(this).closest('.dropdown').toggleClass('open');
    });
    $(document).on('click', function () {
        $('.dropdown').removeClass('open');
    });

    // Alert dismiss
    $(document).on('click', '.alert-close', function () {
        $(this).closest('.alert').fadeOut(200, function () { $(this).remove(); });
    });

    // Auto-dismiss flash after 5s
    setTimeout(function () {
        $('.alert-dismissible').fadeOut(400, function () { $(this).remove(); });
    }, 5000);

    // Confirm delete
    $(document).on('click', '[data-confirm]', function (e) {
        if (!confirm($(this).data('confirm') || 'Are you sure?')) {
            e.preventDefault();
        }
    });

    // AJAX form helper
    window.msshtAjax = function (url, data, callback) {
        $.ajax({
            url: url,
            method: 'POST',
            data: data,
            dataType: 'json'
        }).done(callback).fail(function (xhr) {
            var msg = 'Request failed.';
            try { msg = xhr.responseJSON.message || msg; } catch (e) {}
            alert(msg);
        });
    };

    // Table search filter
    $('#tableSearch').on('keyup', function () {
        var q = $(this).val().toLowerCase();
        $('.data-table tbody tr').each(function () {
            var text = $(this).text().toLowerCase();
            $(this).toggle(text.indexOf(q) > -1);
        });
    });

    // Application status update
    $('.status-form').on('submit', function (e) {
        e.preventDefault();
        var $form = $(this);
        msshtAjax($form.attr('action'), $form.serialize(), function (res) {
            if (res.success) location.reload();
        });
    });

})(jQuery);
