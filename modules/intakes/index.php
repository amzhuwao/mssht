<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('intakes');

$pageTitle = 'Intakes';
$currentModule = 'intakes';
$db = getDB();

$errors = [];
$editIntake = null;

// AJAX: fetch single intake
if (isset($_GET['ajax']) && $_GET['ajax'] === 'get' && !empty($_GET['id'])) {
    $stmt = $db->prepare('SELECT id, name, academic_year, start_date, end_date, status FROM intakes WHERE id = ?');
    $stmt->execute([(int)$_GET['id']]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    jsonResponse(['success' => (bool)$row, 'intake' => $row ?: null]);
}

// AJAX: delete intake
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['ajax_action']) && $_POST['ajax_action'] === 'delete') {
    if (!verifyCsrf($_POST['csrf'] ?? '')) {
        jsonResponse(['success' => false, 'message' => 'Invalid CSRF token'], 400);
    }
    $id = (int)($_POST['id'] ?? 0);
    if ($id <= 0) jsonResponse(['success' => false, 'message' => 'Invalid id'], 400);
    try {
        $stmt = $db->prepare('DELETE FROM intakes WHERE id = ?');
        $stmt->execute([$id]);
        jsonResponse(['success' => true]);
    } catch (Throwable $e) {
        jsonResponse(['success' => false, 'message' => $e->getMessage()]);
    }
}

// Edit mode: load intake if edit_id given
if (!empty($_GET['edit_id'])) {
    $stmt = $db->prepare('SELECT * FROM intakes WHERE id = ?');
    $stmt->execute([(int)$_GET['edit_id']]);
    $editIntake = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $name = trim($_POST['name'] ?? '');
    $academic_year = trim($_POST['academic_year'] ?? '');
    $start_date = trim($_POST['start_date'] ?? '');
    $end_date = trim($_POST['end_date'] ?? '');
    $status = in_array($_POST['status'] ?? 'open', ['open','closed'], true) ? $_POST['status'] : 'open';

    if ($name === '') $errors[] = 'Intake name is required.';
    if ($start_date !== '' && !strtotime($start_date)) $errors[] = 'Start date is invalid.';
    if ($end_date === '') $errors[] = 'End date is required.';
    if ($end_date !== '' && !strtotime($end_date)) $errors[] = 'End date is invalid.';
    if ($start_date !== '' && $end_date !== '' && strtotime($end_date) < strtotime($start_date)) $errors[] = 'End date must be after start date.';

    if (!$errors) {
        if (!empty($_POST['id'])) {
            $id = (int)$_POST['id'];
            $stmt = $db->prepare('UPDATE intakes SET name = ?, academic_year = ?, start_date = ?, end_date = ?, status = ? WHERE id = ?');
            $stmt->execute([$name, $academic_year, $start_date ?: null, $end_date, $status, $id]);
            if (!empty($_POST['ajax'])) {
                jsonResponse(['success' => true, 'message' => 'Intake updated.', 'intake' => ['id' => $id, 'name' => $name, 'academic_year' => $academic_year, 'start_date' => $start_date, 'end_date' => $end_date, 'status' => $status]]);
            }
            flash('success', 'Intake updated.');
            redirect(moduleUrl('intakes'));
        }

        $stmt = $db->prepare('INSERT INTO intakes (name, academic_year, start_date, end_date, status) VALUES (?, ?, ?, ?, ?)');
        $stmt->execute([$name, $academic_year, $start_date ?: null, $end_date, $status]);
        $newId = (int)$db->lastInsertId();
        if (!empty($_POST['ajax'])) {
            jsonResponse(['success' => true, 'message' => 'Intake created.', 'intake' => ['id' => $newId, 'name' => $name, 'academic_year' => $academic_year, 'start_date' => $start_date, 'end_date' => $end_date, 'status' => $status]]);
        }
        flash('success', 'Intake created.');
        redirect(moduleUrl('intakes'));
    }
    // on validation errors with AJAX, return JSON
    if (!empty($_POST['ajax'])) {
        jsonResponse(['success' => false, 'errors' => $errors]);
    }
}

$intakes = $db->query('SELECT id, name, academic_year, start_date, end_date, status FROM intakes ORDER BY start_date DESC')->fetchAll(PDO::FETCH_ASSOC);

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <h2 style="margin:0;">Intakes</h2>
    <button type="button" class="btn btn-primary btn-sm" id="showNewIntake">+ New Intake</button>
    <a href="<?= moduleUrl('intakes') ?>" class="btn btn-outline btn-sm">Refresh</a>
</div>

<div class="card" style="margin-bottom:16px;">
    <div class="card-header"><h2><?= $editIntake ? 'Edit Intake' : 'New Intake' ?></h2></div>
    <div class="card-body">
        <?php if ($errors): ?>
        <div class="alert alert-danger"><?= e(implode(' ', $errors)) ?></div>
        <?php endif; ?>
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="id" value="<?= $editIntake ? (int)$editIntake['id'] : '' ?>">
            <div class="form-row">
                <div class="form-group"><label>Name</label><input name="name" required value="<?= $editIntake ? e($editIntake['name']) : '' ?>"></div>
                <div class="form-group"><label>Academic Year</label><input name="academic_year" placeholder="2026/2027" value="<?= $editIntake ? e($editIntake['academic_year']) : '' ?>"></div>
                <div class="form-group"><label>Start Date</label><input type="date" name="start_date" value="<?= $editIntake && !empty($editIntake['start_date']) ? e(date('Y-m-d', strtotime($editIntake['start_date']))) : '' ?>"></div>
                <div class="form-group"><label>End Date</label><input type="date" name="end_date" required value="<?= $editIntake && !empty($editIntake['end_date']) ? e(date('Y-m-d', strtotime($editIntake['end_date']))) : '' ?>"></div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status">
                        <option value="open" <?= $editIntake && $editIntake['status'] === 'open' ? 'selected' : '' ?>>Open</option>
                        <option value="closed" <?= $editIntake && $editIntake['status'] === 'closed' ? 'selected' : '' ?>>Closed</option>
                    </select>
                </div>
            </div>
            <div class="form-actions">
                <button class="btn btn-primary" type="submit"><?= $editIntake ? 'Update Intake' : 'Create Intake' ?></button>
                <?php if ($editIntake): ?> <a href="<?= moduleUrl('intakes') ?>" class="btn btn-outline">Cancel</a> <?php endif; ?>
            </div>
        </form>
    </div>
</div>

    <!-- Modal for create/edit intake -->
    <div class="modal" id="intakeModal" style="display:none;position:fixed;left:0;top:0;width:100%;height:100%;background:rgba(0,0,0,0.3);align-items:center;justify-content:center;">
        <div class="modal-dialog" style="background:#fff;padding:18px;max-width:680px;width:100%;border-radius:6px;">
            <h3 id="intakeModalTitle">New Intake</h3>
            <form id="intakeModalForm">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <input type="hidden" name="id" value="">
                <div class="form-row">
                    <div class="form-group"><label>Name</label><input name="name" required></div>
                    <div class="form-group"><label>Academic Year</label><input name="academic_year" placeholder="2026/2027"></div>
                    <div class="form-group"><label>Start Date</label><input type="date" name="start_date"></div>
                    <div class="form-group"><label>End Date</label><input type="date" name="end_date" required></div>
                    <div class="form-group">
                        <label>Status</label>
                        <select name="status">
                            <option value="open">Open</option>
                            <option value="closed">Closed</option>
                        </select>
                    </div>
                </div>
                <div class="form-actions">
                    <button class="btn btn-primary" type="submit">Save</button>
                    <button type="button" class="btn btn-outline" id="intakeModalCancel">Cancel</button>
                </div>
                <div class="form-error" id="intakeModalErrors" style="margin-top:8px;color:#b00;"></div>
            </form>
        </div>
    </div>

<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Name</th><th>Academic Year</th><th>Start Date</th><th>End Date</th><th>Status</th><th></th></tr></thead>
            <tbody>
                <?php foreach ($intakes as $it): ?>
                <tr data-intake-id="<?= (int)$it['id'] ?>">
                    <td><?= e($it['name']) ?></td>
                    <td><?= e($it['academic_year']) ?></td>
                    <td><?= e(!empty($it['start_date']) ? date('d M Y', strtotime($it['start_date'])) : '—') ?></td>
                    <td><?= e(!empty($it['end_date']) ? date('d M Y', strtotime($it['end_date'])) : '—') ?></td>
                    <td><?= statusBadge($it['status']) ?></td>
                    <td>
                        <a href="<?= moduleUrl('intakes') ?>?edit_id=<?= (int)$it['id'] ?>" class="btn btn-sm btn-outline intake-edit">Edit</a>
                        <button type="button" class="btn btn-sm btn-danger intake-delete" data-id="<?= (int)$it['id'] ?>">Delete</button>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
(function () {
    function byId(id) { return document.getElementById(id); }
    var modal = byId('intakeModal');
    var form = byId('intakeModalForm');
    var title = byId('intakeModalTitle');
    var cancel = byId('intakeModalCancel');
    var errorsDiv = byId('intakeModalErrors');
    var csrf = (document.querySelector('input[name="csrf"]') || {}).value || '';

    function openModal() { modal.style.display = 'flex'; }
    function closeModal() { modal.style.display = 'none'; errorsDiv.innerHTML = ''; }

    function statusBadgeHtml(status) {
        var map = { open: 'badge-success', closed: 'badge-secondary' };
        var cls = map[status] || 'badge-secondary';
        var label = status.replace('_', ' ');
        return '<span class="badge ' + cls + '">' + label.charAt(0).toUpperCase() + label.slice(1) + '</span>';
    }

    function formatDateDisplay(iso) {
        if (!iso) return '—';
        var d = new Date(iso);
        if (isNaN(d.getTime())) return iso.split(' ')[0];
        var opts = { day: '2-digit', month: 'short', year: 'numeric' };
        return d.toLocaleDateString(undefined, opts);
    }

    function attachRowHandlers(root) {
        root = root || document;
        Array.prototype.slice.call(root.querySelectorAll('a.intake-edit')).forEach(function (el) {
            el.onclick = function (e) {
                var href = el.getAttribute('href') || '';
                var m = href.match(/edit_id=(\d+)/);
                if (!m) return;
                e.preventDefault();
                var id = m[1];
                fetch(window.location.pathname + '?ajax=get&id=' + encodeURIComponent(id), { credentials: 'same-origin' })
                    .then(function (r) { return r.json(); })
                    .then(function (data) {
                        if (!data || !data.success) { alert('Could not load intake'); return; }
                        var it = data.intake;
                        form.reset();
                        form.elements['id'].value = it.id;
                        form.elements['name'].value = it.name || '';
                        form.elements['academic_year'].value = it.academic_year || '';
                        form.elements['start_date'].value = it.start_date ? it.start_date.split(' ')[0] : '';
                        form.elements['end_date'].value = it.end_date ? it.end_date.split(' ')[0] : '';
                        form.elements['status'].value = it.status || 'open';
                        title.textContent = 'Edit Intake';
                        openModal();
                    }).catch(function () { alert('Error loading intake'); });
            };
        });

        Array.prototype.slice.call(root.querySelectorAll('button.intake-delete')).forEach(function (btn) {
            btn.onclick = function (e) {
                var id = btn.getAttribute('data-id');
                if (!id) return;
                if (!confirm('Delete this intake? This action cannot be easily undone.')) return;
                var fd = new FormData();
                fd.append('csrf', csrf);
                fd.append('id', id);
                fd.append('ajax_action', 'delete');
                fetch(window.location.pathname, { method: 'POST', credentials: 'same-origin', body: fd })
                    .then(function (r) { return r.json(); })
                    .then(function (data) {
                        if (data && data.success) {
                            var tr = document.querySelector('tr[data-intake-id="' + id + '"]');
                            if (tr) tr.parentNode.removeChild(tr);
                        } else {
                            alert(data && data.message ? data.message : 'Delete failed');
                        }
                    }).catch(function () { alert('Delete failed'); });
            };
        });
    }

    document.getElementById('showNewIntake').addEventListener('click', function () {
        form.reset(); form.id.value = '';
        title.textContent = 'New Intake';
        openModal();
    });

    cancel.addEventListener('click', function () { closeModal(); });

    form.addEventListener('submit', function (ev) {
        ev.preventDefault();
        errorsDiv.innerHTML = '';
        var fd = new FormData(form);
        fd.append('ajax', '1');
        fetch(window.location.pathname, { method: 'POST', credentials: 'same-origin', body: fd })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data) { errorsDiv.textContent = 'No response'; return; }
                if (data.success && data.intake) {
                    var it = data.intake;
                    // update or insert row
                    var tbody = document.querySelector('table.data-table tbody');
                    var existing = document.querySelector('tr[data-intake-id="' + it.id + '"]');
                    var html = '';
                    html += '<td>' + (it.name ? it.name : '') + '</td>';
                    html += '<td>' + (it.academic_year ? it.academic_year : '') + '</td>';
                    html += '<td>' + formatDateDisplay(it.start_date) + '</td>';
                    html += '<td>' + formatDateDisplay(it.end_date) + '</td>';
                    html += '<td>' + statusBadgeHtml(it.status) + '</td>';
                    html += '<td><a href="' + window.location.pathname + '?edit_id=' + it.id + '" class="btn btn-sm btn-outline intake-edit">Edit</a> ';
                    html += '<button type="button" class="btn btn-sm btn-danger intake-delete" data-id="' + it.id + '">Delete</button></td>';

                    if (existing) {
                        existing.innerHTML = html;
                    } else {
                        var tr = document.createElement('tr');
                        tr.setAttribute('data-intake-id', it.id);
                        tr.innerHTML = html;
                        if (tbody.firstChild) tbody.insertBefore(tr, tbody.firstChild);
                        else tbody.appendChild(tr);
                    }
                    attachRowHandlers(document);
                    closeModal();
                } else {
                    if (Array.isArray(data.errors)) {
                        errorsDiv.innerHTML = data.errors.map(function (s) { return '<div>' + s + '</div>'; }).join('');
                    } else if (data.message) {
                        errorsDiv.textContent = data.message;
                    } else {
                        errorsDiv.textContent = 'Validation failed';
                    }
                }
            }).catch(function (err) { errorsDiv.textContent = 'Save failed'; });
    });

    // initial binding
    attachRowHandlers(document);
})();
</script>
<?php require_once __DIR__ . '/../../includes/footer.php';
