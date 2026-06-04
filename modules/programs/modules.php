<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('programs');

$programId = (int)($_GET['program_id'] ?? 0);
$db = getDB();
$program = $db->prepare('SELECT * FROM programs WHERE id = ?');
$program->execute([$programId]);
$program = $program->fetch();
if (!$program) {
    flash('danger', 'Program not found.');
    redirect(moduleUrl('programs'));
}

// AJAX handlers: search existing modules and attach existing module to program
// The same module can be attached multiple times to the same program if the semester differs.
if (isset($_GET['ajax']) && $_GET['ajax'] === '1' && isset($_GET['action']) && $_GET['action'] === 'search') {
    $q = trim($_GET['q'] ?? '');
    $attachSemester = max(1, (int)($_GET['semester'] ?? 1));
    header('Content-Type: application/json');
    if ($q === '') { echo json_encode(['success' => true, 'results' => []]); exit; }
    $like = '%' . str_replace('%','\\%',$q) . '%';
    $stmt = $db->prepare(
        'SELECT m.id, m.code, m.name, m.duration_value, m.duration_unit,
                (SELECT GROUP_CONCAT(pm.semester ORDER BY pm.semester SEPARATOR ", ")
                   FROM program_modules pm
                  WHERE pm.program_id = ? AND pm.module_id = m.id) AS attached_semesters,
                CASE WHEN EXISTS(
                    SELECT 1 FROM program_modules pm2
                     WHERE pm2.program_id = ? AND pm2.module_id = m.id AND pm2.semester = ?
                ) THEN 1 ELSE 0 END AS is_attached
           FROM modules m
          WHERE (m.code LIKE ? OR m.name LIKE ?)
          ORDER BY is_attached ASC, m.code LIMIT 20'
    );
    $stmt->execute([$programId, $programId, $attachSemester, $like, $like]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode(['success' => true, 'results' => $rows]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['ajax']) && ($_POST['action'] ?? '') === 'add_existing') {
    header('Content-Type: application/json');
    if (!verifyCsrf($_POST['csrf'] ?? '')) {
        echo json_encode(['success' => false, 'error' => 'Invalid CSRF']); exit;
    }
    $moduleId = (int)($_POST['module_id'] ?? 0);
    $attachSemester = max(1, (int)($_POST['semester'] ?? 1));
    if (!$moduleId) { echo json_encode(['success' => false, 'error' => 'Invalid module id']); exit; }
    try {
        $stmt = $db->prepare('INSERT IGNORE INTO program_modules (program_id, module_id, semester) VALUES (?, ?, ?)');
        $stmt->execute([$programId, $moduleId, $attachSemester]);
        $m = $db->prepare('SELECT id, code, name, duration_value, duration_unit, semester, is_core FROM modules WHERE id = ?');
        $m->execute([$moduleId]);
        $mod = $m->fetch(PDO::FETCH_ASSOC);
        $mod['program_semester'] = $attachSemester;
        echo json_encode(['success' => true, 'module' => $mod]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}

// bulk add existing modules to program (ajax)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['ajax']) && ($_POST['action'] ?? '') === 'add_multiple') {
    header('Content-Type: application/json');
    if (!verifyCsrf($_POST['csrf'] ?? '')) { echo json_encode(['success' => false, 'error' => 'Invalid CSRF']); exit; }
    $attachSemester = max(1, (int)($_POST['semester'] ?? 1));
    $ids = $_POST['module_ids'] ?? [];
    if (is_string($ids)) {
        $ids = json_decode($ids, true) ?: [];
    }
    if (!is_array($ids) || empty($ids)) { echo json_encode(['success' => false, 'error' => 'No module ids provided']); exit; }
    $inserted = [];
    foreach ($ids as $mid) {
        $mid = (int)$mid;
        if (!$mid) continue;
        try {
            $db->prepare('INSERT IGNORE INTO program_modules (program_id, module_id, semester) VALUES (?, ?, ?)')->execute([$programId, $mid, $attachSemester]);
            $inserted[] = $mid;
        } catch (Exception $e) { }
    }
    if (empty($inserted)) { echo json_encode(['success' => false, 'error' => 'No modules attached']); exit; }
    // fetch attached module rows
    $placeholders = implode(',', array_fill(0, count($inserted), '?'));
    $stmt = $db->prepare('SELECT id, code, name, duration_value, duration_unit, semester, is_core FROM modules WHERE id IN (' . $placeholders . ')');
    $stmt->execute($inserted);
    $mods = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($mods as &$mod) { $mod['program_semester'] = $attachSemester; }
    echo json_encode(['success' => true, 'modules' => $mods]);
    exit;
}

// AJAX: get attachment details
if (isset($_GET['ajax']) && $_GET['ajax'] === '1' && isset($_GET['action']) && $_GET['action'] === 'get_attachment') {
    header('Content-Type: application/json');
    $moduleId = (int)($_GET['module_id'] ?? 0);
    $sem = max(1, (int)($_GET['semester'] ?? 1));
    if (!$moduleId) { echo json_encode(['success' => false, 'error' => 'Invalid module id']); exit; }
    $stmt = $db->prepare('SELECT pm.*, m.code, m.name, m.duration_value, m.duration_unit FROM program_modules pm JOIN modules m ON m.id = pm.module_id WHERE pm.program_id = ? AND pm.module_id = ? AND pm.semester = ? LIMIT 1');
    $stmt->execute([$programId, $moduleId, $sem]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) { echo json_encode(['success' => false, 'error' => 'Attachment not found']); exit; }
    echo json_encode(['success' => true, 'attachment' => $row]); exit;
}

// AJAX: update attachment details
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['ajax']) && ($_POST['action'] ?? '') === 'update_attachment') {
    header('Content-Type: application/json');
    if (!verifyCsrf($_POST['csrf'] ?? '')) { echo json_encode(['success' => false, 'error' => 'Invalid CSRF']); exit; }
    $moduleId = (int)($_POST['module_id'] ?? 0);
    $sem = max(1, (int)($_POST['semester'] ?? 1));
    $isCore = isset($_POST['is_core']) ? 1 : 0;
    $notes = trim($_POST['notes'] ?? '');
    $order = (int)($_POST['display_order'] ?? 0);
    if (!$moduleId) { echo json_encode(['success' => false, 'error' => 'Invalid module id']); exit; }
    try {
        $stmt = $db->prepare('UPDATE program_modules SET is_core = ?, notes = ?, display_order = ? WHERE program_id = ? AND module_id = ? AND semester = ?');
        $stmt->execute([$isCore, $notes !== '' ? $notes : null, $order, $programId, $moduleId, $sem]);
        echo json_encode(['success' => true]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}

// AJAX: remove (detach) attachment
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['ajax']) && ($_POST['action'] ?? '') === 'remove_attachment') {
    header('Content-Type: application/json');
    if (!verifyCsrf($_POST['csrf'] ?? '')) { echo json_encode(['success' => false, 'error' => 'Invalid CSRF']); exit; }
    $moduleId = (int)($_POST['module_id'] ?? 0);
    $sem = max(1, (int)($_POST['semester'] ?? 1));
    if (!$moduleId) { echo json_encode(['success' => false, 'error' => 'Invalid module id']); exit; }
    try {
        $stmt = $db->prepare('DELETE FROM program_modules WHERE program_id = ? AND module_id = ? AND semester = ?');
        $stmt->execute([$programId, $moduleId, $sem]);
        echo json_encode(['success' => true]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'error' => $e->getMessage()]);
    }
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
     $durationValue = (int)($_POST['duration_value'] ?? 0);
     $durationUnit = in_array($_POST['duration_unit'] ?? 'hours', ['hours', 'weeks', 'days'], true) ? $_POST['duration_unit'] : 'hours';
    $programSemester = max(1, (int)($_POST['semester'] ?? 1));

     // server-side validation
     $errors = [];
     if ($durationValue <= 0) {
         $errors[] = 'Duration must be at least 1.';
     }

     if ($errors) {
         foreach ($errors as $msg) { flash('danger', $msg); }
         redirect(moduleUrl('programs', 'modules') . '?program_id=' . $programId);
     }

     $db->prepare('INSERT INTO modules (program_id, code, name, credits, semester, is_core, duration_value, duration_unit) VALUES (?, ?, ?, ?, ?, ?, ?, ?)')
         ->execute([$programId, strtoupper(trim($_POST['code'])), trim($_POST['name']), 0, $programSemester, isset($_POST['is_core']) ? 1 : 0, $durationValue, $durationUnit]);
     $mid = (int)$db->lastInsertId();
     // insert pivot link for many-to-many support
     $db->prepare('INSERT IGNORE INTO program_modules (program_id, module_id, semester) VALUES (?, ?, ?)')->execute([$programId, $mid, $programSemester]);
    flash('success', 'Module added.');
    redirect(moduleUrl('programs', 'modules') . '?program_id=' . $programId);
}

$modules = $db->prepare('SELECT m.*, pm.semester AS program_semester, pm.is_core, pm.notes, pm.display_order FROM modules m JOIN program_modules pm ON pm.module_id = m.id WHERE pm.program_id = ? ORDER BY pm.semester, pm.display_order, m.code');
$modules->execute([$programId]);
$modules = $modules->fetchAll();

$pageTitle = 'Curriculum: ' . $program['name'];
$currentModule = 'programs';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="index.php" class="btn btn-outline btn-sm">&larr; Programs</a>
</div>

<div class="card">
    <div class="card-header"><h2><?= e($program['name']) ?> — Modules</h2></div>
    <div class="card-body">
        <form method="post" class="form-row" style="align-items:flex-end;" id="newModuleForm">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div style="flex:1">
                <label>Search Existing Modules</label>
                <label style="margin-top:8px;display:block;">Attach semester</label>
                <select id="attachSemester" style="width:100%;margin-bottom:8px;">
                    <?php for ($sem = 1; $sem <= 12; $sem++): ?>
                        <option value="<?= $sem ?>" <?= $sem === 1 ? 'selected' : '' ?>>Semester <?= $sem ?></option>
                    <?php endfor; ?>
                </select>
                <input type="search" id="moduleSearch" placeholder="Search by code or name">
                <div id="moduleSearchResults" style="max-height:200px;overflow:auto;margin-top:6px;"></div>
                <label style="margin-top:8px;display:block;">Selection</label>
                <select id="moduleMultiSelect" multiple size="6" style="width:100%;margin-top:6px;"></select>
                <button type="button" id="attachSelectedBtn" class="btn btn-sm btn-primary" style="margin-top:6px;">Attach Selected</button>
            </div>
            <div style="width:1px;">&nbsp;</div>
            <div class="form-group"><label>Code</label><input name="code" required></div>
            <div class="form-group"><label>Name</label><input name="name" required></div>
            <div class="form-group"><label>Duration</label>
                <div style="display:flex;gap:8px;align-items:center;">
                    <input type="number" name="duration_value" value="0" min="0" style="width:120px;">
                    <select name="duration_unit">
                        <option value="hours">hours</option>
                        <option value="weeks">weeks</option>
                        <option value="days">days</option>
                    </select>
                </div>
            </div>
            <div class="form-group"><label>Semester</label><input type="number" name="semester" value="1" min="1"></div>
            <div class="form-group"><label><input type="checkbox" name="is_core" checked> Core</label></div>
            <button type="submit" class="btn btn-primary">Add Module</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Code</th><th>Module</th><th>Duration</th><th>Semester</th><th>Core</th><th>Actions</th></tr></thead>
            <tbody>
            <?php foreach ($modules as $m): ?>
            <tr data-module-id="<?= (int)$m['id'] ?>" data-semester="<?= (int)($m['program_semester'] ?? $m['semester']) ?>">
                <td><?= e($m['code']) ?></td>
                <td><?= e($m['name']) ?><?= $m['notes'] ? '<div class="muted" style="font-size:12px;margin-top:4px;">' . e(substr($m['notes'],0,160)) . (strlen($m['notes'])>160?'...':'') . '</div>' : '' ?></td>
                <td><?= (int)($m['duration_value'] ?? 0) ?> <?= $m['duration_unit'] ?? 'hours' ?></td>
                <td><?= (int)($m['program_semester'] ?? $m['semester']) ?></td>
                <td class="col-core"><?= $m['is_core'] ? 'Yes' : 'No' ?></td>
                <td>
                    <button class="btn btn-sm btn-outline js-edit-attachment">Edit</button>
                    <button class="btn btn-sm btn-danger js-remove-attachment">Remove</button>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
// debounce helper
function debounce(fn, delay){ var t; return function(){ var args=arguments, ctx=this; clearTimeout(t); t=setTimeout(function(){ fn.apply(ctx,args); }, delay); }; }

var currentProgramId = '<?= (int) $programId ?>';
var ajaxBaseUrl = window.location.pathname + '?program_id=' + encodeURIComponent(currentProgramId);
var attachSemesterSelect = document.getElementById('attachSemester');

var searchInput = document.getElementById('moduleSearch');
var resultsBox = document.getElementById('moduleSearchResults');
if (searchInput) {
    var doSearch = debounce(function () {
        var q = searchInput.value.trim();
        if (q.length < 2) { resultsBox.innerHTML = ''; return; }
        var semesterValue = attachSemesterSelect ? attachSemesterSelect.value : '1';
        fetch(ajaxBaseUrl + '&ajax=1&action=search&q=' + encodeURIComponent(q) + '&semester=' + encodeURIComponent(semesterValue))
            .then(function(r){ return r.json(); })
            .then(function(data){
                if (!data.success) return;
                var out = '';
                data.results.forEach(function(m){
                    var attached = String(m.is_attached) === '1' || m.is_attached === 1;
                    var durVal = (m.duration_value || 0) + ' ' + (m.duration_unit || 'hours');
                    var attachedLabel = m.attached_semesters ? 'Attached in semester(s): ' + m.attached_semesters : '';
                    out += '<div style="padding:6px;border-bottom:1px solid #eee;display:flex;justify-content:space-between;align-items:center;gap:10px;">'
                        + '<div><strong>' + (m.code||'') + '</strong> — ' + (m.name||'') + ' <small>(' + durVal + ')</small>'
                        + (attachedLabel ? ' <span style="display:inline-block;padding:2px 6px;border-radius:999px;background:#eef2ff;color:#3b82f6;font-size:12px;">' + attachedLabel + '</span>' : '')
                        + (attached ? ' <span style="display:inline-block;padding:2px 6px;border-radius:999px;background:#e8f5e9;color:#2e7d32;font-size:12px;">Already attached</span>' : '')
                        + '</div>'
                        + '<div style="display:flex;gap:6px;flex-wrap:wrap;justify-content:flex-end;">'
                        + '<button class="btn btn-sm btn-outline js-queue-module" data-id="' + m.id + '" data-code="' + (m.code || '') + '" data-name="' + (m.name || '') + '"' + (attached ? ' disabled' : '') + '>Queue</button>'
                        + '<button class="btn btn-sm btn-outline js-add-existing" data-id="' + m.id + '"' + (attached ? ' disabled' : '') + '>' + (attached ? 'Added' : 'Add') + '</button>'
                        + '</div>'
                        + '</div>';
                });
                resultsBox.innerHTML = out || '<div class="muted">No results</div>';
            });
    }, 300);
    searchInput.addEventListener('input', doSearch);

    // delegate add clicks
    resultsBox.addEventListener('click', function (e) {
        var btn = e.target.closest && e.target.closest('.js-add-existing');
        if (!btn) return;
        var id = btn.getAttribute('data-id');
        btn.disabled = true;
        var semesterValue = attachSemesterSelect ? attachSemesterSelect.value : '1';
        var fd = new FormData(); fd.append('ajax','1'); fd.append('action','add_existing'); fd.append('module_id', id); fd.append('semester', semesterValue); fd.append('csrf', '<?= csrfToken() ?>');
        fetch(ajaxBaseUrl, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(data){
                if (!data.success) { showToast(data.error || 'Failed to attach module', 'danger'); btn.disabled = false; return; }
                // append row to modules table
                var tb = document.querySelector('.data-table tbody');
                if (tb) {
                    var tr = document.createElement('tr');
                    var durVal = (data.module.duration_value || 0) + ' ' + (data.module.duration_unit || 'hours');
                    tr.innerHTML = '<td>' + (data.module.code||'') + '</td>'
                                 + '<td>' + (data.module.name||'') + '</td>'
                                 + '<td>' + durVal + '</td>'
                                 + '<td>' + (data.module.program_semester || semesterValue) + '</td>'
                                 + '<td>' + (data.module.is_core ? 'Yes' : 'No') + '</td>';
                    tb.appendChild(tr);
                }
                btn.textContent = 'Added';
                btn.disabled = true;
                showToast('Module attached', 'success');
            }).catch(function(){ showToast('Request failed', 'danger'); btn.disabled = false; });
    });
}

// queue and bulk attach handlers
var multiSelect = document.getElementById('moduleMultiSelect');
var attachBtn = document.getElementById('attachSelectedBtn');
if (resultsBox) {
    resultsBox.addEventListener('click', function (e) {
        var qbtn = e.target.closest && e.target.closest('.js-queue-module');
        if (!qbtn) return;
        var id = qbtn.getAttribute('data-id');
        var code = qbtn.getAttribute('data-code') || '';
        var name = qbtn.getAttribute('data-name') || '';
        if (!multiSelect) return;
        // avoid duplicates
        if ([].slice.call(multiSelect.options).some(function(o){ return o.value === id; })) return;
        var opt = document.createElement('option'); opt.value = id; opt.text = (code ? code + ' — ' : '') + name;
        multiSelect.appendChild(opt);
    });
}

if (attachBtn) {
    attachBtn.addEventListener('click', function () {
        if (!multiSelect) return alert('No modules selected');
        var sel = [].slice.call(multiSelect.options).filter(function(o){ return o.selected; });
        if (!sel.length) return showToast('Please select modules in the list', 'warning');
        var semesterValue = attachSemesterSelect ? attachSemesterSelect.value : '1';
        var fd = new FormData(); fd.append('ajax','1'); fd.append('action','add_multiple'); fd.append('semester', semesterValue); fd.append('csrf','<?= csrfToken() ?>');
        sel.forEach(function(o){ fd.append('module_ids[]', o.value); });
        attachBtn.disabled = true;
        fetch(ajaxBaseUrl, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(data){
                attachBtn.disabled = false;
                if (!data.success) { showToast(data.error || 'Attach failed', 'danger'); return; }
                var tb = document.querySelector('.data-table tbody');
                data.modules.forEach(function(m){
                    if (tb) {
                        var tr = document.createElement('tr');
                        var durVal = (m.duration_value || 0) + ' ' + (m.duration_unit || 'hours');
                        tr.innerHTML = '<td>' + (m.code||'') + '</td>'
                                     + '<td>' + (m.name||'') + '</td>'
                                     + '<td>' + durVal + '</td>'
                                     + '<td>' + (m.program_semester || semesterValue) + '</td>'
                                     + '<td>' + (m.is_core ? 'Yes' : 'No') + '</td>';
                        tb.appendChild(tr);
                    }
                    // remove option from multi-select
                    var opt = multiSelect.querySelector('option[value="' + m.id + '"]'); if (opt) opt.remove();
                });
                showToast('Modules attached', 'success');
            }).catch(function(){ attachBtn.disabled = false; alert('Request failed'); });
    });
}

if (attachSemesterSelect && searchInput) {
    attachSemesterSelect.addEventListener('change', function () {
        if (searchInput.value.trim().length >= 2) {
            searchInput.dispatchEvent(new Event('input'));
        }
    });
}

// Edit / Remove attachment handlers
document.querySelector('.data-table tbody').addEventListener('click', function (e) {
    var editBtn = e.target.closest && e.target.closest('.js-edit-attachment');
    var remBtn = e.target.closest && e.target.closest('.js-remove-attachment');
    if (editBtn) {
        var tr = editBtn.closest('tr');
        var moduleId = tr.getAttribute('data-module-id');
        var sem = tr.getAttribute('data-semester') || '1';
        openEditAttachmentModal(moduleId, sem, tr);
    }
    if (remBtn) {
        var tr2 = remBtn.closest('tr');
        var moduleId2 = tr2.getAttribute('data-module-id');
        var sem2 = tr2.getAttribute('data-semester') || '1';
        if (!confirm('Remove this module from the program (this will not delete the module)?')) return;
        var fd = new FormData(); fd.append('ajax','1'); fd.append('action','remove_attachment'); fd.append('module_id', moduleId2); fd.append('semester', sem2); fd.append('csrf','<?= csrfToken() ?>');
        fetch(ajaxBaseUrl, { method: 'POST', body: fd }).then(function(r){ return r.json(); }).then(function(data){
            if (!data.success) { showToast(data.error || 'Failed to remove', 'danger'); return; }
            tr2.remove(); showToast('Attachment removed', 'success');
        }).catch(function(){ showToast('Request failed', 'danger'); });
    }
});

// modal DOM
var modalHtml = '<div id="attachmentModal" style="position:fixed;left:0;top:0;right:0;bottom:0;background:rgba(0,0,0,0.4);display:none;align-items:center;justify-content:center;z-index:10000;">'
    + '<div style="background:#fff;padding:18px;border-radius:8px;max-width:560px;width:100%;">'
    + '<h3 id="attachmentModalTitle">Edit Attachment</h3>'
    + '<input type="hidden" id="att_module_id"><input type="hidden" id="att_semester">'
    + '<div style="margin-top:8px;"><label><input type="checkbox" id="att_is_core"> Core</label></div>'
    + '<div style="margin-top:8px;"><label>Display order</label><input type="number" id="att_display_order" value="0" style="width:120px;"></div>'
    + '<div style="margin-top:8px;"><label>Notes</label><textarea id="att_notes" style="width:100%;height:100px;"></textarea></div>'
    + '<div style="margin-top:12px;text-align:right;display:flex;gap:8px;justify-content:flex-end;">'
    + '<button id="att_cancel" class="btn btn-sm">Cancel</button>'
    + '<button id="att_save" class="btn btn-sm btn-primary">Save</button>'
    + '</div></div></div>';
document.body.insertAdjacentHTML('beforeend', modalHtml);
var attachmentModal = document.getElementById('attachmentModal');
var att_module_id = document.getElementById('att_module_id');
var att_semester = document.getElementById('att_semester');
var att_is_core = document.getElementById('att_is_core');
var att_display_order = document.getElementById('att_display_order');
var att_notes = document.getElementById('att_notes');
var att_cancel = document.getElementById('att_cancel');
var att_save = document.getElementById('att_save');

function openEditAttachmentModal(moduleId, sem, tr) {
    att_module_id.value = moduleId; att_semester.value = sem;
    // load data
    fetch(ajaxBaseUrl + '&ajax=1&action=get_attachment&module_id=' + encodeURIComponent(moduleId) + '&semester=' + encodeURIComponent(sem))
        .then(function(r){ return r.json(); }).then(function(data){
            if (!data.success) { showToast(data.error || 'Failed to load', 'danger'); return; }
            var a = data.attachment;
            att_is_core.checked = a.is_core == 1 || a.is_core === '1';
            att_display_order.value = a.display_order || 0;
            att_notes.value = a.notes || '';
            attachmentModal.style.display = 'flex';
        }).catch(function(){ showToast('Request failed', 'danger'); });
}

att_cancel.addEventListener('click', function(){ attachmentModal.style.display = 'none'; });
att_save.addEventListener('click', function(){
    var fd = new FormData(); fd.append('ajax','1'); fd.append('action','update_attachment'); fd.append('module_id', att_module_id.value); fd.append('semester', att_semester.value);
    if (att_is_core.checked) fd.append('is_core','1'); fd.append('display_order', att_display_order.value); fd.append('notes', att_notes.value); fd.append('csrf','<?= csrfToken() ?>');
    att_save.disabled = true;
    fetch(ajaxBaseUrl, { method: 'POST', body: fd }).then(function(r){ return r.json(); }).then(function(data){ att_save.disabled = false; if (!data.success) { showToast(data.error || 'Failed to save', 'danger'); return; } attachmentModal.style.display = 'none';
        // update row display
        var tr = document.querySelector('tr[data-module-id="' + att_module_id.value + '"][data-semester="' + att_semester.value + '"]');
        if (tr) { tr.querySelector('.col-core').textContent = att_is_core.checked ? 'Yes' : 'No'; }
        showToast('Attachment updated', 'success');
    }).catch(function(){ att_save.disabled = false; showToast('Request failed', 'danger'); });
});
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>

<style>
/* simple toast styles */
#toastContainer { position: fixed; top: 20px; right: 20px; z-index: 9999; display:flex; flex-direction:column; gap:8px; }
.toast { background:#222; color:#fff; padding:8px 12px; border-radius:6px; box-shadow:0 4px 12px rgba(0,0,0,0.15); min-width:180px; }
.toast.success { background:#2e7d32; }
.toast.danger { background:#c62828; }
.toast.warning { background:#f9a825; color:#111; }
</style>
<div id="toastContainer" aria-live="polite" aria-atomic="true"></div>
<script>
function showToast(msg, type) {
    type = type || 'success';
    var c = document.getElementById('toastContainer');
    if (!c) return alert(msg);
    var d = document.createElement('div'); d.className = 'toast ' + (type || ''); d.textContent = msg;
    c.appendChild(d);
    setTimeout(function(){ d.style.opacity = '1'; }, 10);
    setTimeout(function(){ d.style.transition = 'opacity 400ms'; d.style.opacity = '0'; setTimeout(function(){ d.remove(); }, 400); }, 4000);
}
</script>
