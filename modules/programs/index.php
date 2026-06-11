<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('programs');

$pageTitle = 'Programs & Courses';
$currentModule = 'programs';
$db = getDB();
$intakes = $db->query('SELECT id, name, academic_year, status, start_date FROM intakes ORDER BY start_date DESC')->fetchAll(PDO::FETCH_ASSOC);
$selectedProgramIntakes = [];

// AJAX: fetch program details
if (isset($_GET['ajax']) && $_GET['ajax'] === '1' && isset($_GET['action']) && $_GET['action'] === 'get' && !empty($_GET['id'])) {
    $stmt = $db->prepare('SELECT p.*, (SELECT COUNT(*) FROM program_modules pm WHERE pm.program_id = p.id) AS module_count FROM programs p WHERE p.id = ?');
    $stmt->execute([(int)$_GET['id']]);
    $prog = $stmt->fetch(PDO::FETCH_ASSOC);
    if ($prog) {
        $pi = $db->prepare('SELECT intake_id FROM program_intakes WHERE program_id = ? ORDER BY intake_id');
        $pi->execute([(int)$_GET['id']]);
        $prog['intake_ids'] = array_map('intval', $pi->fetchAll(PDO::FETCH_COLUMN));
        $intakeNames = $db->prepare('SELECT GROUP_CONCAT(i.name ORDER BY i.start_date DESC SEPARATOR ", ") AS intake_names FROM program_intakes pi JOIN intakes i ON i.id = pi.intake_id WHERE pi.program_id = ?');
        $intakeNames->execute([(int)$_GET['id']]);
        $prog['intakes_text'] = (string)($intakeNames->fetchColumn() ?: '');
    }
    header('Content-Type: application/json');
    echo json_encode(['success' => (bool)$prog, 'program' => $prog]);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $durationValue = (int)($_POST['duration_value'] ?? $_POST['duration_months'] ?? 12);
    $durationUnit = in_array($_POST['duration_unit'] ?? 'months', ['months','hours'], true) ? $_POST['duration_unit'] : 'months';

    // basic server-side validation
    $errors = [];
    $code = trim($_POST['code'] ?? '');
    $name = trim($_POST['name'] ?? '');
    $program_type = $_POST['program_type'] ?? '';
    $total_credits = $_POST['total_credits'] ?? '';
    $intakeIds = $_POST['intake_ids'] ?? [];
    if (is_string($intakeIds)) {
        $intakeIds = json_decode($intakeIds, true) ?: [];
    }
    $intakeIds = array_values(array_unique(array_filter(array_map('intval', (array)$intakeIds))));

    if ($code === '') {
        $errors['code'] = 'Code is required.';
    }
    if ($name === '') {
        $errors['name'] = 'Name is required.';
    }
    if (!in_array($program_type, ['short_course','certificate','diploma','hnd'], true)) {
        $errors['program_type'] = 'Invalid program type.';
    }
    if (!is_numeric($durationValue) || $durationValue < 1) {
        $errors['duration_value'] = 'Duration must be at least 1.';
    }
    if ($total_credits !== '' && !is_numeric($total_credits)) {
        $errors['total_credits'] = 'Total credits must be a number.';
    }
    if (!$intakeIds) {
        $errors['intake_ids'] = 'Please select at least one intake.';
    }

    if ($errors) {
        if (!empty($_POST['ajax'])) {
            header('Content-Type: application/json');
            echo json_encode(['success' => false, 'errors' => $errors]);
            exit;
        }
        foreach ($errors as $msg) { flash('error', $msg); }
        redirect(moduleUrl('programs'));
    }

    if (!empty($_POST['id'])) {
        // Update existing program
        $programId = (int)$_POST['id'];
        $db->beginTransaction();
        $stmt = $db->prepare(
            'UPDATE programs SET code = ?, name = ?, program_type = ?, duration_months = ?, duration_value = ?, duration_unit = ?, total_credits = ?, description = ? WHERE id = ?'
        );
        $stmt->execute([
            strtoupper(trim($_POST['code'])),
            trim($_POST['name']),
            $_POST['program_type'],
            $durationUnit === 'months' ? $durationValue : 0,
            $durationValue,
            $durationUnit,
            (float)$_POST['total_credits'],
            trim($_POST['description'] ?? ''),
            $programId,
        ]);
        $db->prepare('DELETE FROM program_intakes WHERE program_id = ?')->execute([$programId]);
        $stmtIntake = $db->prepare('INSERT IGNORE INTO program_intakes (program_id, intake_id) VALUES (?, ?)');
        foreach ($intakeIds as $intakeId) {
            $stmtIntake->execute([$programId, $intakeId]);
        }
        $db->commit();

        $updatedId = $programId;
        if (!empty($_POST['ajax'])) {
            $stmt2 = $db->prepare('SELECT p.*, (SELECT COUNT(*) FROM program_modules pm WHERE pm.program_id = p.id) AS module_count FROM programs p WHERE p.id = ?');
            $stmt2->execute([$updatedId]);
            $stmt3 = $db->prepare('SELECT GROUP_CONCAT(i.name ORDER BY i.start_date DESC SEPARATOR ", ") FROM program_intakes pi JOIN intakes i ON i.id = pi.intake_id WHERE pi.program_id = ?');
            $stmt3->execute([$updatedId]);
            $program = $stmt2->fetch(PDO::FETCH_ASSOC);
            $program['intakes_text'] = (string)($stmt3->fetchColumn() ?: '');
            header('Content-Type: application/json');
            echo json_encode(['success' => true, 'program' => $program]);
            exit;
        }

        flash('success', 'Program updated.');
        redirect(moduleUrl('programs'));
    }

    // Insert new program
    $stmtIns = $db->prepare(
        'INSERT INTO programs (code, name, program_type, duration_months, duration_value, duration_unit, total_credits, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
    );
    $stmtIns->execute([
        strtoupper(trim($_POST['code'])),
        trim($_POST['name']),
        $_POST['program_type'],
        // keep duration_months for compatibility
        $durationUnit === 'months' ? $durationValue : 0,
        $durationValue,
        $durationUnit,
        (float)$_POST['total_credits'],
        trim($_POST['description'] ?? ''),
    ]);

    $newId = (int)$db->lastInsertId();
    $stmtIntake = $db->prepare('INSERT IGNORE INTO program_intakes (program_id, intake_id) VALUES (?, ?)');
    foreach ($intakeIds as $intakeId) {
        $stmtIntake->execute([$newId, $intakeId]);
    }
    if (!empty($_POST['ajax'])) {
        $stmt2 = $db->prepare('SELECT p.*, (SELECT COUNT(*) FROM program_modules pm WHERE pm.program_id = p.id) AS module_count FROM programs p WHERE p.id = ?');
        $stmt2->execute([$newId]);
        $stmt3 = $db->prepare('SELECT GROUP_CONCAT(i.name ORDER BY i.start_date DESC SEPARATOR ", ") FROM program_intakes pi JOIN intakes i ON i.id = pi.intake_id WHERE pi.program_id = ?');
        $stmt3->execute([$newId]);
        $program = $stmt2->fetch(PDO::FETCH_ASSOC);
        $program['intakes_text'] = (string)($stmt3->fetchColumn() ?: '');
        header('Content-Type: application/json');
        echo json_encode(['success' => true, 'program' => $program]);
        exit;
    }

    flash('success', 'Program created.');
    redirect(moduleUrl('programs'));
}

// Edit mode: load program if edit_id given
$editProgram = null;
if (!empty($_GET['edit_id'])) {
    $editProgram = $db->prepare('SELECT * FROM programs WHERE id = ?');
    $editProgram->execute([(int)$_GET['edit_id']]);
    $editProgram = $editProgram->fetch(PDO::FETCH_ASSOC) ?: null;
    if ($editProgram) {
        $pi = $db->prepare('SELECT intake_id FROM program_intakes WHERE program_id = ? ORDER BY intake_id');
        $pi->execute([(int)$_GET['edit_id']]);
        $selectedProgramIntakes = array_map('intval', $pi->fetchAll(PDO::FETCH_COLUMN));
    }
}

$programs = $db->query('SELECT p.*, (SELECT COUNT(*) FROM program_modules pm WHERE pm.program_id = p.id) AS module_count, (SELECT GROUP_CONCAT(i.name ORDER BY i.start_date DESC SEPARATOR ", ") FROM program_intakes pi JOIN intakes i ON i.id = pi.intake_id WHERE pi.program_id = p.id) AS intakes_text FROM programs p ORDER BY p.name')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <h2 style="margin:0;">Programs</h2>
    <button type="button" class="btn btn-primary btn-sm" id="showAddProgram">+ Add Program</button>
</div>

    <?php $isEdit = (bool)$editProgram; ?>
    <div class="card" id="addProgramForm" style="display:<?= $isEdit ? 'block' : 'none' ?>;">
    <div class="card-header"><h2><?= $isEdit ? 'Edit Program' : 'New Program' ?></h2></div>
    <div class="card-body">
        <form method="post" novalidate>
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="id" value="<?= $isEdit ? (int)$editProgram['id'] : '' ?>">
            <div class="form-row">
                <div class="form-group"><label>Code *</label><input name="code" required placeholder="HND-HOSP-401"><div class="form-error" data-for="code"></div></div>
                <div class="form-group"><label>Name *</label><input name="name" required><div class="form-error" data-for="name"></div></div>
                <div class="form-group">
                    <label>Type *</label>
                    <select name="program_type" required>
                        <option value="short_course">Short Course</option>
                        <option value="certificate">Professional Certificate</option>
                        <option value="diploma">Diploma</option>
                        <option value="hnd">HND</option>
                    </select>
                    <div class="form-error" data-for="program_type"></div>
                </div>
                <div class="form-group"><label>Duration</label>
                    <div style="display:flex;gap:8px;align-items:center;">
                        <input type="number" name="duration_value" value="<?= $isEdit ? (int)($editProgram['duration_value'] ?? $editProgram['duration_months']) : 12 ?>" min="1" style="width:120px;">
                        <select name="duration_unit">
                            <option value="months" <?= $isEdit && ($editProgram['duration_unit'] ?? 'months') === 'months' ? 'selected' : '' ?>>months</option>
                            <option value="hours" <?= $isEdit && ($editProgram['duration_unit'] ?? '') === 'hours' ? 'selected' : '' ?>>hours</option>
                        </select>
                    </div>
                    <div class="form-error" data-for="duration_value"></div>
                </div>
                <div class="form-group"><label>Total Credits</label><input type="number" step="0.01" name="total_credits" value="0"></div>
                <div class="form-group">
                    <label>Intakes *</label>
                    <select name="intake_ids[]" multiple size="6" required>
                        <?php foreach ($intakes as $intake): ?>
                            <option value="<?= (int)$intake['id'] ?>" <?= in_array((int)$intake['id'], $selectedProgramIntakes, true) ? 'selected' : '' ?>>
                                <?= e($intake['name']) ?> (<?= e($intake['academic_year']) ?><?= $intake['status'] ? ' • ' . e($intake['status']) : '' ?>)
                            </option>
                        <?php endforeach; ?>
                    </select>
                    <div class="form-error" data-for="intake_ids"></div>
                    <div class="muted" style="font-size:12px;">Hold Ctrl/Command to select multiple intakes.</div>
                </div>
            </div>
            <div class="form-group"><label>Description</label><textarea name="description" rows="2"><?= $isEdit ? e($editProgram['description'] ?? '') : '' ?></textarea></div>
            <button type="submit" class="btn btn-primary"><?= $isEdit ? 'Update Program' : 'Save Program' ?></button>
            <?php if ($isEdit): ?>
                <a href="<?= moduleUrl('programs') ?>" class="btn btn-outline">Cancel</a>
            <?php endif; ?>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Code</th><th>Program</th><th>Type</th><th>Modules</th><th>Duration</th><th>Intakes</th><th>Status</th><th></th></tr>
            </thead>
            <tbody>
            <?php foreach ($programs as $p): ?>
            <tr data-program-id="<?= $p['id'] ?>">
                <td class="prog-code"><?= e($p['code']) ?></td>
                <td class="prog-name"><?= e($p['name']) ?></td>
                <td class="prog-type"><?= programTypeLabel($p['program_type']) ?></td>
                <td class="prog-modules"><?= (int)$p['module_count'] ?></td>
                <?php
                    $durVal = $p['duration_value'] ?? $p['duration_months'] ?? 0;
                    $durUnit = $p['duration_unit'] ?? 'months';
                ?>
                <td><?= (int)$durVal ?> <?= $durUnit === 'months' ? 'mo' : 'hrs' ?></td>
                <td class="prog-intakes"><?= e($p['intakes_text'] ?: '—') ?></td>
                <td><?= statusBadge($p['status']) ?></td>
                <td>
                    <a href="modules.php?program_id=<?= $p['id'] ?>" class="btn btn-sm btn-outline">Modules</a>
                    <a href="#" data-id="<?= $p['id'] ?>" class="btn btn-sm btn-outline js-edit-program">Edit</a>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
var showAddProgram = document.getElementById('showAddProgram');
var addProgramForm = document.getElementById('addProgramForm');
var programForm = document.querySelector('#addProgramForm form');

function resetProgramFormForCreate() {
    if (!programForm) return;
    programForm.reset();
    var idInput = programForm.querySelector('input[name="id"]');
    if (idInput) idInput.value = '';
    document.querySelectorAll('.form-error').forEach(function (el) { el.textContent = ''; });
    var title = addProgramForm ? addProgramForm.querySelector('.card-header h2') : null;
    if (title) title.textContent = 'New Program';
}

if (showAddProgram && addProgramForm) {
    showAddProgram.addEventListener('click', function () {
        var isHidden = addProgramForm.style.display === 'none' || !addProgramForm.style.display;
        if (isHidden) {
            resetProgramFormForCreate();
            addProgramForm.style.display = 'block';
        } else {
            addProgramForm.style.display = 'none';
        }
    });
}

// AJAX edit handlers
document.addEventListener('click', function (e) {
    var target = e.target.closest && e.target.closest('.js-edit-program');
    if (!target) return;
    e.preventDefault();
    var id = target.getAttribute('data-id');
    fetch(window.location.pathname + '?ajax=1&action=get&id=' + encodeURIComponent(id))
        .then(function (r) { return r.json(); })
        .then(function (data) {
            if (!data.success) return alert('Program not found');
            var p = data.program || {};
            // ensure hidden id exists
            var idInput = document.querySelector('input[name="id"]');
            if (!idInput) {
                idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                var f = document.querySelector('#addProgramForm form');
                if (f) f.appendChild(idInput);
            }
            idInput.value = p.id || '';
            // helper to set value if field exists
            function setVal(sel, val) { var el = document.querySelector(sel); if (el) el.value = val; }
            setVal('input[name="code"]', p.code || '');
            setVal('input[name="name"]', p.name || '');
            setVal('select[name="program_type"]', p.program_type || 'short_course');
            setVal('input[name="duration_value"]', (p.duration_value !== undefined ? p.duration_value : (p.duration_months || 0)) );
            setVal('select[name="duration_unit"]', p.duration_unit || 'months');
            setVal('input[name="total_credits"]', p.total_credits || 0);
            if (p.intake_ids && Array.isArray(p.intake_ids)) {
                var intakeSelect = document.querySelector('select[name="intake_ids[]"]');
                if (intakeSelect) {
                    Array.prototype.forEach.call(intakeSelect.options, function (opt) {
                        opt.selected = p.intake_ids.indexOf(parseInt(opt.value, 10)) !== -1;
                    });
                }
            }
            var ta = document.querySelector('textarea[name="description"]'); if (ta) ta.value = p.description || '';
            if (addProgramForm) addProgramForm.style.display = 'block';
            if (addProgramForm) window.scrollTo(0, addProgramForm.offsetTop - 20);
        });
});

if (programForm) {
    programForm.addEventListener('submit', function (e) {
        e.preventDefault();
        var formData = new FormData(programForm);
        formData.append('ajax', '1');
        fetch(window.location.pathname, { method: 'POST', body: formData })
            .then(function (r) { return r.json(); })
                .then(function (data) {
                    // clear previous errors
                    document.querySelectorAll('.form-error').forEach(function(el){ el.textContent = ''; });
                    if (!data.success) {
                        if (data.errors) {
                            // show inline errors
                            Object.keys(data.errors).forEach(function (key) {
                                var el = document.querySelector('.form-error[data-for="' + key + '"]');
                                if (el) el.textContent = data.errors[key];
                            });
                            // focus first error field
                            var firstKey = Object.keys(data.errors)[0];
                            var field = document.querySelector('[name="' + firstKey + '"]');
                            if (field) field.focus();
                            return;
                        }
                        alert('Save failed');
                        return;
                    }
                var p = data.program;
                // update or insert row
                var tr = document.querySelector('tr[data-program-id="' + p.id + '"]');
                var durUnit = (p.duration_unit || 'months') === 'months' ? 'mo' : 'hrs';
                if (tr) {
                    tr.querySelector('.prog-code').textContent = p.code || '';
                    tr.querySelector('.prog-name').textContent = p.name || '';
                    tr.querySelector('.prog-type').textContent = p.program_type || '';
                    tr.querySelector('.prog-modules').textContent = p.module_count || 0;
                    tr.querySelector('td:nth-child(5)').textContent = (p.duration_value || 0) + ' ' + durUnit;
                    tr.querySelector('.prog-intakes').textContent = p.intakes_text || '—';
                } else {
                    // simple: reload to show new row if not present
                    window.location.reload();
                }
                alert('Program saved');
                addProgramForm.style.display = 'none';
            }).catch(function () { alert('Save failed'); });
    });
}
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
