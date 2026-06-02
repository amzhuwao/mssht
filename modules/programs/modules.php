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
if (isset($_GET['ajax']) && $_GET['ajax'] === '1' && isset($_GET['action']) && $_GET['action'] === 'search') {
    $q = trim($_GET['q'] ?? '');
    header('Content-Type: application/json');
    if ($q === '') { echo json_encode(['success' => true, 'results' => []]); exit; }
    $like = '%' . str_replace('%','\\%',$q) . '%';
    $stmt = $db->prepare('SELECT m.id, m.code, m.name, m.credits, m.semester, CASE WHEN pm.module_id IS NULL THEN 0 ELSE 1 END AS is_attached FROM modules m LEFT JOIN program_modules pm ON pm.module_id = m.id AND pm.program_id = ? WHERE (m.code LIKE ? OR m.name LIKE ?) ORDER BY is_attached ASC, m.code LIMIT 20');
    $stmt->execute([$programId, $like, $like]);
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
    if (!$moduleId) { echo json_encode(['success' => false, 'error' => 'Invalid module id']); exit; }
    try {
        $stmt = $db->prepare('INSERT IGNORE INTO program_modules (program_id, module_id) VALUES (?, ?)');
        $stmt->execute([$programId, $moduleId]);
        $m = $db->prepare('SELECT id, code, name, credits, semester, is_core FROM modules WHERE id = ?');
        $m->execute([$moduleId]);
        $mod = $m->fetch(PDO::FETCH_ASSOC);
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
            $db->prepare('INSERT IGNORE INTO program_modules (program_id, module_id) VALUES (?, ?)')->execute([$programId, $mid]);
            $inserted[] = $mid;
        } catch (Exception $e) { }
    }
    if (empty($inserted)) { echo json_encode(['success' => false, 'error' => 'No modules attached']); exit; }
    // fetch attached module rows
    $placeholders = implode(',', array_fill(0, count($inserted), '?'));
    $stmt = $db->prepare('SELECT id, code, name, credits, semester, is_core FROM modules WHERE id IN (' . $placeholders . ')');
    $stmt->execute($inserted);
    $mods = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode(['success' => true, 'modules' => $mods]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
     $db->prepare('INSERT INTO modules (program_id, code, name, credits, semester, is_core) VALUES (?, ?, ?, ?, ?, ?)')
         ->execute([$programId, strtoupper(trim($_POST['code'])), trim($_POST['name']), (float)$_POST['credits'], (int)$_POST['semester'], isset($_POST['is_core']) ? 1 : 0]);
     $mid = (int)$db->lastInsertId();
     // insert pivot link for many-to-many support
     $db->prepare('INSERT IGNORE INTO program_modules (program_id, module_id) VALUES (?, ?)')->execute([$programId, $mid]);
    flash('success', 'Module added.');
    redirect(moduleUrl('programs', 'modules') . '?program_id=' . $programId);
}

$modules = $db->prepare('SELECT m.* FROM modules m JOIN program_modules pm ON pm.module_id = m.id WHERE pm.program_id = ? ORDER BY m.semester, m.code');
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
                <input type="search" id="moduleSearch" placeholder="Search by code or name">
                <div id="moduleSearchResults" style="max-height:200px;overflow:auto;margin-top:6px;"></div>
                <label style="margin-top:8px;display:block;">Selection</label>
                <select id="moduleMultiSelect" multiple size="6" style="width:100%;margin-top:6px;"></select>
                <button type="button" id="attachSelectedBtn" class="btn btn-sm btn-primary" style="margin-top:6px;">Attach Selected</button>
            </div>
            <div style="width:1px;">&nbsp;</div>
            <div class="form-group"><label>Code</label><input name="code" required></div>
            <div class="form-group"><label>Name</label><input name="name" required></div>
            <div class="form-group"><label>Credits</label><input type="number" step="0.01" name="credits" value="0"></div>
            <div class="form-group"><label>Semester</label><input type="number" name="semester" value="1" min="1"></div>
            <div class="form-group"><label><input type="checkbox" name="is_core" checked> Core</label></div>
            <button type="submit" class="btn btn-primary">Add Module</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Code</th><th>Module</th><th>Credits</th><th>Semester</th><th>Core</th></tr></thead>
            <tbody>
            <?php foreach ($modules as $m): ?>
            <tr>
                <td><?= e($m['code']) ?></td>
                <td><?= e($m['name']) ?></td>
                <td><?= e($m['credits']) ?></td>
                <td><?= (int)$m['semester'] ?></td>
                <td><?= $m['is_core'] ? 'Yes' : 'No' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
// debounce helper
function debounce(fn, delay){ var t; return function(){ var args=arguments, ctx=this; clearTimeout(t); t=setTimeout(function(){ fn.apply(ctx,args); }, delay); }; }

var searchInput = document.getElementById('moduleSearch');
var resultsBox = document.getElementById('moduleSearchResults');
if (searchInput) {
    var doSearch = debounce(function () {
        var q = searchInput.value.trim();
        if (q.length < 2) { resultsBox.innerHTML = ''; return; }
        fetch(window.location.pathname + '?ajax=1&action=search&q=' + encodeURIComponent(q))
            .then(function(r){ return r.json(); })
            .then(function(data){
                if (!data.success) return;
                var out = '';
                data.results.forEach(function(m){
                    var attached = String(m.is_attached) === '1' || m.is_attached === 1;
                    out += '<div style="padding:6px;border-bottom:1px solid #eee;display:flex;justify-content:space-between;align-items:center;gap:10px;">'
                        + '<div><strong>' + (m.code||'') + '</strong> — ' + (m.name||'') + ' <small>(' + (m.credits||0) + ' cr)</small>'
                        + (attached ? ' <span style="display:inline-block;padding:2px 6px;border-radius:999px;background:#e8f5e9;color:#2e7d32;font-size:12px;">Already attached</span>' : '')
                        + '</div>'
                        + '<div><button class="btn btn-sm btn-outline js-add-existing" data-id="' + m.id + '"' + (attached ? ' disabled' : '') + '>' + (attached ? 'Added' : 'Add') + '</button></div>'
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
        var fd = new FormData(); fd.append('ajax','1'); fd.append('action','add_existing'); fd.append('module_id', id); fd.append('csrf', '<?= csrfToken() ?>');
        fetch(window.location.pathname, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(data){
                if (!data.success) { alert(data.error || 'Failed to attach module'); btn.disabled = false; return; }
                // append row to modules table
                var tb = document.querySelector('.data-table tbody');
                if (tb) {
                    var tr = document.createElement('tr');
                    tr.innerHTML = '<td>' + (data.module.code||'') + '</td>'
                                 + '<td>' + (data.module.name||'') + '</td>'
                                 + '<td>' + (data.module.credits||'') + '</td>'
                                 + '<td>' + (data.module.semester||'') + '</td>'
                                 + '<td>' + (data.module.is_core ? 'Yes' : 'No') + '</td>';
                    tb.appendChild(tr);
                }
                btn.textContent = 'Added';
                btn.disabled = true;
            }).catch(function(){ alert('Request failed'); btn.disabled = false; });
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
        if (!sel.length) return alert('Please select modules in the list');
        var fd = new FormData(); fd.append('ajax','1'); fd.append('action','add_multiple'); fd.append('csrf','<?= csrfToken() ?>');
        sel.forEach(function(o){ fd.append('module_ids[]', o.value); });
        attachBtn.disabled = true;
        fetch(window.location.pathname, { method: 'POST', body: fd })
            .then(function(r){ return r.json(); })
            .then(function(data){
                attachBtn.disabled = false;
                if (!data.success) { alert(data.error || 'Attach failed'); return; }
                var tb = document.querySelector('.data-table tbody');
                data.modules.forEach(function(m){
                    if (tb) {
                        var tr = document.createElement('tr');
                        tr.innerHTML = '<td>' + (m.code||'') + '</td>'
                                     + '<td>' + (m.name||'') + '</td>'
                                     + '<td>' + (m.credits||'') + '</td>'
                                     + '<td>' + (m.semester||'') + '</td>'
                                     + '<td>' + (m.is_core ? 'Yes' : 'No') + '</td>';
                        tb.appendChild(tr);
                    }
                    // remove option from multi-select
                    var opt = multiSelect.querySelector('option[value="' + m.id + '"]'); if (opt) opt.remove();
                });
            }).catch(function(){ attachBtn.disabled = false; alert('Request failed'); });
    });
}
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
