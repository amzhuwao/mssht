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

    // Searchable select helper
    window.msshtSearchableSelect = function (searchId, selectId) {
        var $search = $('#' + searchId);
        var $select = $('#' + selectId);
        if (!$search.length || !$select.length) return;

        var options = $select.find('option').map(function () {
            return {
                value: this.value,
                text: $(this).text()
            };
        }).get();

        $search.on('input', function () {
            var q = $(this).val().toLowerCase().trim();
            var currentValue = $select.val();

            $select.empty();
            options.forEach(function (option, index) {
                if (index === 0) {
                    $('<option>')
                        .attr('value', option.value)
                        .text(option.text)
                        .appendTo($select);
                    return;
                }
                if (!q || option.text.toLowerCase().indexOf(q) > -1) {
                    $('<option>')
                        .attr('value', option.value)
                        .text(option.text)
                        .appendTo($select);
                }
            });

            if (currentValue) {
                $select.val(currentValue);
            }
        });

        // Keep the search input in sync when the select value changes (user picks an option)
        $select.on('change', function () {
            var selText = $select.find('option:selected').text() || '';
            $search.val($.trim(selText));
            $search.trigger('input');
        });

        // Initialize search box with currently selected option (if any)
        var initial = $select.find('option:selected').text() || '';
        if (initial) {
            $search.val($.trim(initial));
        }
    };

    // Application status update
    $('.status-form').on('submit', function (e) {
        e.preventDefault();
        var $form = $(this);
        msshtAjax($form.attr('action'), $form.serialize(), function (res) {
            if (res.success) location.reload();
        });
    });

})(jQuery);
