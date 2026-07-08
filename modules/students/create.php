<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('students');

$pageTitle = 'Register Student';
$currentModule = 'students';
$db = getDB();
$programs = $db->query("SELECT id, code, name, program_type FROM programs WHERE status = 'active' ORDER BY name")->fetchAll();
$intakes = $db->query("SELECT id, name FROM intakes WHERE status IN ('open','closed') ORDER BY start_date DESC")->fetchAll();
$programIntakeOptions = [];
$selectedProgramIdForIntakes = 0;

if (isset($_GET['ajax']) && $_GET['ajax'] === 'program_intakes' && !empty($_GET['program_id'])) {
    $stmt = $db->prepare("SELECT i.id, i.name, i.academic_year, i.status, i.start_date
        FROM program_intakes pi
        JOIN intakes i ON i.id = pi.intake_id
        WHERE pi.program_id = ?
        ORDER BY i.start_date DESC, i.name ASC");
    $stmt->execute([(int) $_GET['program_id']]);
    jsonResponse(['success' => true, 'intakes' => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
}

$defaults = [
    'first_name' => '',
    'last_name' => '',
    'email' => '',
    'phone' => '',
    'student_number' => '',
    'program_id' => '',
    'intake_id' => '',
    'enrollment_status' => 'active',
    'create_portal' => 1,
];

$errors = [];
$submitted = $defaults;
$portal = null;

// import preview storage key
if (!isset($_SESSION)) session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && (($_POST['ajax'] ?? '') === 'clear_import_preview')) {
    if (verifyCsrf($_POST['csrf'] ?? '')) {
        unset($_SESSION['student_import_preview']);
    }
    header('Content-Type: application/json');
    echo json_encode(['success' => true]);
    exit;
}

// Helper: parse uploaded file (CSV or XLSX if PhpSpreadsheet available)
function parseStudentImportFile($tmpPath, $originalName)
{
    $ext = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
    $rows = [];
    if ($ext === 'csv' || $ext === 'txt') {
        if (($h = fopen($tmpPath, 'r')) !== false) {
            $header = fgetcsv($h);
            if (!$header) return ['error' => 'Empty or invalid CSV file'];
            $cols = array_map('trim', $header);
            while (($data = fgetcsv($h)) !== false) {
                $r = [];
                foreach ($cols as $i => $c) { $r[$c] = isset($data[$i]) ? trim($data[$i]) : ''; }
                $rows[] = $r;
            }
            fclose($h);
        } else {
            return ['error' => 'Could not open uploaded CSV file'];
        }
    } elseif ($ext === 'xlsx' || $ext === 'xls') {
        if (class_exists('\PhpOffice\PhpSpreadsheet\IOFactory')) {
            try {
                $reader = \PhpOffice\PhpSpreadsheet\IOFactory::createReaderForFile($tmpPath);
                $spreadsheet = $reader->load($tmpPath);
                $sheet = $spreadsheet->getActiveSheet();
                $iter = $sheet->getRowIterator();
                $header = [];
                foreach ($iter as $rowIndex => $row) {
                    $cellIterator = $row->getCellIterator(); $cellIterator->setIterateOnlyExistingCells(false);
                    $cells = [];
                    foreach ($cellIterator as $cell) { $cells[] = (string)$cell->getValue(); }
                    if (empty($header)) { $header = array_map('trim', $cells); continue; }
                    $r = [];
                    foreach ($header as $i => $c) { $r[$c] = $cells[$i] ?? ''; }
                    $rows[] = $r;
                }
            } catch (Throwable $e) { return ['error' => 'Failed to read Excel file: ' . $e->getMessage()]; }
        } else {
            return ['error' => 'PhpSpreadsheet not installed. Please upload CSV or install phpoffice/phpspreadsheet.'];
        }
    } else {
        return ['error' => 'Unsupported file type. Use CSV or XLSX'];
    }
    return ['rows' => $rows];
}

function generateUniqueStudentNumberForRegistration(PDO $db): string
{
    for ($i = 0; $i < 10; $i++) {
        $candidate = generateStudentNumber();
        $check = $db->prepare('SELECT id FROM students WHERE student_number = ?');
        $check->execute([$candidate]);
        if (!$check->fetch()) {
            return $candidate;
        }
    }
    return generateStudentNumber();
}

function getIntakesForProgram(PDO $db, int $programId): array
{
    if ($programId <= 0) {
        return [];
    }

    $stmt = $db->prepare("SELECT i.id, i.name, i.academic_year, i.status, i.start_date
        FROM program_intakes pi
        JOIN intakes i ON i.id = pi.intake_id
        WHERE pi.program_id = ?
        ORDER BY i.start_date DESC, i.name ASC");
    $stmt->execute([$programId]);

    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $importAction = trim($_POST['import_action'] ?? '');

    // handle import preview request
    if ($importAction === 'preview' && !empty($_FILES['import_file']) && $_FILES['import_file']['error'] === UPLOAD_ERR_OK) {
        $res = parseStudentImportFile($_FILES['import_file']['tmp_name'], $_FILES['import_file']['name']);
        if (!empty($res['error'])) { $errors[] = $res['error']; }
        else {
            $raw = $res['rows'];
            $preview = [];
            foreach ($raw as $r) {
                // normalize keys (lowercase)
                $row = array_change_key_case($r, CASE_LOWER);
                $preview[] = [
                    'first_name' => trim($row['first_name'] ?? $row['firstname'] ?? ''),
                    'last_name' => trim($row['last_name'] ?? $row['lastname'] ?? ''),
                    'email' => trim($row['email'] ?? ''),
                    'phone' => trim($row['phone'] ?? ''),
                    'student_number' => trim($row['student_number'] ?? $row['studentno'] ?? ''),
                    'program_code' => trim($row['program_code'] ?? $row['program'] ?? ''),
                    'intake_name' => trim($row['intake_name'] ?? $row['intake'] ?? ''),
                    'enrollment_status' => trim(strtolower($row['enrollment_status'] ?? 'active')) ?: 'active',
                    'create_portal' => in_array(trim($row['create_portal'] ?? ''), ['1','yes','true'], true) ? 1 : 0,
                ];
            }
            // map program codes/names to ids
            $programMap = [];
            foreach ($programs as $p) { $programMap[strtoupper($p['code'])] = $p['id']; $programMap[strtoupper($p['name'])] = $p['id']; }
            $intakeMap = [];
            foreach ($intakes as $it) { $intakeMap[strtoupper($it['name'])] = $it['id']; }
            foreach ($preview as &$pr) {
                $pc = strtoupper($pr['program_code']);
                $pr['program_id'] = $programMap[$pc] ?? 0;
                $pr['intake_id'] = $intakeMap[strtoupper($pr['intake_name'])] ?? 0;
                $pr['valid'] = true;
                $pr['errors'] = [];
                if ($pr['first_name'] === '') { $pr['valid'] = false; $pr['errors'][] = 'Missing first name'; }
                if ($pr['last_name'] === '') { $pr['valid'] = false; $pr['errors'][] = 'Missing last name'; }
                if ($pr['program_id'] <= 0) { $pr['valid'] = false; $pr['errors'][] = 'Unknown program'; }
                if ($pr['intake_id'] <= 0) { $pr['valid'] = false; $pr['errors'][] = 'Unknown intake'; }
                if ($pr['create_portal'] && !filter_var($pr['email'], FILTER_VALIDATE_EMAIL)) { $pr['valid'] = false; $pr['errors'][] = 'Invalid email for portal'; }
            }
            $_SESSION['student_import_preview'] = $preview;
            flash('info', 'Import preview loaded. Review rows and click Import to commit.');
            // fall through to show preview below
        }
        $submitted = $defaults;
    }

    // handle import commit
    if ($importAction === 'import_confirm') {
        $preview = $_SESSION['student_import_preview'] ?? [];
        $selected = $_POST['import_selected'] ?? [];
        if (is_string($selected)) $selected = json_decode($selected, true) ?: [];
        $results = [];
        foreach ($selected as $idx) {
            if (!isset($preview[$idx])) { $results[] = ['row'=>$idx,'success'=>false,'error'=>'Row missing in preview']; continue; }
            $pr = $preview[$idx];
            if (!$pr['valid']) { $results[] = ['row'=>$idx,'success'=>false,'error'=>implode('; ',$pr['errors'])]; continue; }
            try {
                $db->beginTransaction();
                $studentNumber = $pr['student_number'] !== '' ? preg_replace('/[^A-Za-z0-9\-]/','',$pr['student_number']) : generateUniqueStudentNumberForRegistration($db);
                $check = $db->prepare('SELECT id FROM students WHERE student_number = ?'); $check->execute([$studentNumber]); if ($check->fetch()) { throw new RuntimeException('Student number exists'); }
                $stmt = $db->prepare('INSERT INTO students (student_number, first_name, last_name, email, phone, program_id, intake_id, enrollment_status, enrollment_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURDATE())');
                $stmt->execute([$studentNumber, $pr['first_name'], $pr['last_name'], $pr['email'], $pr['phone'], $pr['program_id'], $pr['intake_id'], $pr['enrollment_status']]);
                $studentId = (int)$db->lastInsertId();
                if ($pr['create_portal']) {
                    $portal = createDirectStudentPortalAccount($studentId, $pr['first_name'], $pr['last_name'], $pr['email'], $pr['phone'], true);
                    if (!$portal) { throw new RuntimeException('Created student but portal creation failed'); }
                    sendStudentPortalCredentialsEmail($portal['email'], trim($pr['first_name'] . ' ' . $pr['last_name']), $studentNumber, $portal['email'], $portal['temp_password'], url('student-login.php'));
                }
                $db->commit();
                $results[] = ['row'=>$idx,'success'=>true,'student_id'=>$studentId];
            } catch (Throwable $e) {
                if ($db->inTransaction()) $db->rollBack();
                $results[] = ['row'=>$idx,'success'=>false,'error'=>$e->getMessage()];
            }
        }
        unset($_SESSION['student_import_preview']);
        // show summary as flash and fall through
        $ok = count(array_filter($results, function($r){ return $r['success']; }));
        $failed = count($results) - $ok;
        flash('success', "Imported $ok rows. $failed failed.");
        $submitted = $defaults;
    }

    if ($importAction !== '') {
        // Do not run manual single-student validation when an import action was submitted.
        goto render_form;
    }

    $submitted = [
        'first_name' => trim($_POST['first_name'] ?? ''),
        'last_name' => trim($_POST['last_name'] ?? ''),
        'email' => trim($_POST['email'] ?? ''),
        'phone' => trim($_POST['phone'] ?? ''),
        'student_number' => trim($_POST['student_number'] ?? ''),
        'program_id' => (int) ($_POST['program_id'] ?? 0),
        'intake_id' => (int) ($_POST['intake_id'] ?? 0),
        'enrollment_status' => in_array(($_POST['enrollment_status'] ?? 'active'), ['active', 'graduated', 'withdrawn', 'suspended', 'deferred'], true) ? $_POST['enrollment_status'] : 'active',
        'create_portal' => !empty($_POST['create_portal']) ? 1 : 0,
    ];

    if ($submitted['first_name'] === '') $errors[] = 'First name is required.';
    if ($submitted['last_name'] === '') $errors[] = 'Last name is required.';
    if ($submitted['program_id'] <= 0) $errors[] = 'Please select a program.';
    if ($submitted['intake_id'] <= 0) $errors[] = 'Please select an intake.';

    if ($submitted['program_id'] > 0 && $submitted['intake_id'] > 0) {
        $linkedIntake = $db->prepare('SELECT 1 FROM program_intakes WHERE program_id = ? AND intake_id = ? LIMIT 1');
        $linkedIntake->execute([$submitted['program_id'], $submitted['intake_id']]);
        if (!$linkedIntake->fetchColumn()) {
            $errors[] = 'Please select an intake linked to the chosen program.';
        }
    }

    if ($submitted['create_portal'] && !filter_var($submitted['email'], FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Enter a valid email address to create the portal account.';
    }

    if (!$errors) {
        try {
            $db->beginTransaction();

            $studentNumber = $submitted['student_number'] !== '' ? preg_replace('/[^A-Za-z0-9\-]/', '', $submitted['student_number']) : generateUniqueStudentNumberForRegistration($db);
            if ($studentNumber === '') {
                $studentNumber = generateUniqueStudentNumberForRegistration($db);
            }

            $check = $db->prepare('SELECT id FROM students WHERE student_number = ?');
            $check->execute([$studentNumber]);
            if ($check->fetch()) {
                throw new RuntimeException('That student number already exists.');
            }

            $stmt = $db->prepare(
                'INSERT INTO students (student_number, first_name, last_name, email, phone, program_id, intake_id, enrollment_status, enrollment_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, CURDATE())'
            );
            $stmt->execute([
                $studentNumber,
                $submitted['first_name'],
                $submitted['last_name'],
                $submitted['email'],
                $submitted['phone'],
                $submitted['program_id'],
                $submitted['intake_id'],
                $submitted['enrollment_status'],
            ]);
            $studentId = (int) $db->lastInsertId();

            $portal = null;
            if ($submitted['create_portal']) {
                $portal = createDirectStudentPortalAccount(
                    $studentId,
                    $submitted['first_name'],
                    $submitted['last_name'],
                    $submitted['email'],
                    $submitted['phone'],
                    true
                );
                if (!$portal) {
                    throw new RuntimeException('Student was created, but the portal account could not be set up.');
                }
                sendStudentPortalCredentialsEmail(
                    $portal['email'],
                    trim($submitted['first_name'] . ' ' . $submitted['last_name']),
                    $studentNumber,
                    $portal['email'],
                    $portal['temp_password'],
                    url('student-login.php')
                );
            }

            $db->commit();
            flash('success', 'Student registered successfully.' . ($portal ? ' Portal access was created too.' : ''));
            redirect(moduleUrl('students', 'view') . '?id=' . $studentId);
        } catch (Throwable $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            $errors[] = $e->getMessage() ?: 'Could not register student.';
        }
    }
}

if ($submitted['program_id'] > 0) {
    $selectedProgramIdForIntakes = (int) $submitted['program_id'];
    $programIntakeOptions = getIntakesForProgram($db, $selectedProgramIdForIntakes);
}

require_once __DIR__ . '/../../includes/header.php';
?>

<?php render_form: ?>

<div class="page-actions">
    <a href="<?= moduleUrl('students') ?>" class="btn btn-outline btn-sm" id="backToStudentsLink">&larr; Back to Students</a>
</div>

<div class="card">
    <div class="card-header"><h2>Batch Student Import</h2></div>
    <div class="card-body">
        <p class="muted" style="margin-top:0;">
            Upload a CSV or XLSX file with a header row to register many students at once.
            Use the template if you need the expected column names.
        </p>
        <form method="post" enctype="multipart/form-data">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group">
                <label>Upload file</label>
                <div style="display:flex;gap:8px;align-items:center;">
                    <input type="file" name="import_file" accept=".csv,.xlsx,.xls">
                    <a href="<?= url('assets/templates/student_import_template.csv') ?>" class="btn btn-sm btn-outline" download>Download template</a>
                </div>
                <div class="muted" style="margin-top:6px;">Template header: first_name,last_name,email,phone,student_number,program_code,intake_name,enrollment_status,create_portal</div>
            </div>
            <div style="display:flex;gap:8px;margin-bottom:12px;flex-wrap:wrap;">
                <button type="submit" name="import_action" value="preview" class="btn btn-outline" formnovalidate>Preview Import</button>
                <?php if (!empty($_SESSION['student_import_preview'])): ?>
                    <button type="submit" name="import_action" value="import_confirm" class="btn btn-primary" formnovalidate>Import Selected</button>
                <?php endif; ?>
            </div>
            <div class="card" style="margin-bottom:12px;background:#fafafa;">
                <div class="card-body" style="padding:12px 14px;">
                    <strong>Import format</strong>
                    <div class="muted" style="margin-top:6px;">
                        Required columns: <code>first_name</code>, <code>last_name</code>, <code>program_code</code>, <code>intake_name</code>.<br>
                        Optional columns: <code>email</code>, <code>phone</code>, <code>student_number</code>, <code>enrollment_status</code>, <code>create_portal</code>.<br>
                        Sample row: <code>Jane,Doe,jane.doe@example.com,0712345678,S-1001,CS101,Intake 2026,active,1</code>
                    </div>
                </div>
            </div>

            <?php if (!empty($_SESSION['student_import_preview'])): $preview = $_SESSION['student_import_preview']; ?>
                <div class="card" style="margin-bottom:12px;">
                    <div class="card-header"><strong>Import Preview (<?= count($preview) ?> rows)</strong></div>
                    <div class="card-body" style="overflow:auto;max-height:360px;">
                        <table class="data-table">
                            <thead><tr><th></th><th>First name</th><th>Last name</th><th>Email</th><th>Phone</th><th>Program</th><th>Intake</th><th>Portal</th><th>Valid</th><th>Errors</th></tr></thead>
                            <tbody>
                            <?php foreach ($preview as $i => $r): ?>
                            <tr>
                                <td><input type="checkbox" name="import_selected[]" value="<?= $i ?>" <?= $r['valid'] ? 'checked' : '' ?>></td>
                                <td><?= e($r['first_name']) ?></td>
                                <td><?= e($r['last_name']) ?></td>
                                <td><?= e($r['email']) ?></td>
                                <td><?= e($r['phone']) ?></td>
                                <td><?= e($r['program_id'] ? 'OK' : ($r['program_code'] ?? '')) ?></td>
                                <td><?= e($r['intake_id'] ? 'OK' : ($r['intake_name'] ?? '')) ?></td>
                                <td><?= $r['create_portal'] ? 'Yes' : 'No' ?></td>
                                <td><?= $r['valid'] ? 'Yes' : 'No' ?></td>
                                <td><?= e(implode('; ', $r['errors'] ?? [])) ?></td>
                            </tr>
                            <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            <?php endif; ?>
        </form>
    </div>
</div>

<div class="card" style="margin-top:16px;">
    <div class="card-header"><h2>Direct Student Registration</h2></div>
    <div class="card-body">
        <?php if ($errors): ?>
        <div class="alert alert-danger">
            <?= e(implode(' ', $errors)) ?>
        </div>
        <?php endif; ?>

        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-row">
                <div class="form-group"><label>First Name</label><input name="first_name" required value="<?= e($submitted['first_name']) ?>"></div>
                <div class="form-group"><label>Last Name</label><input name="last_name" required value="<?= e($submitted['last_name']) ?>"></div>
                <div class="form-group"><label>Email for Portal</label><input type="email" name="email" value="<?= e($submitted['email']) ?>"></div>
                <div class="form-group"><label>Phone</label><input name="phone" value="<?= e($submitted['phone']) ?>"></div>
                <div class="form-group"><label>Student Number</label><input name="student_number" value="<?= e($submitted['student_number']) ?>" placeholder="Leave blank to auto-generate"></div>
                <div class="form-group">
                    <label>Program</label>
                    <input type="text" id="studentCreateProgramSearch" placeholder="Search programs">
                    <select name="program_id" id="studentCreateProgramSelect" required>
                        <option value="">Select program</option>
                        <?php foreach ($programs as $program): ?>
                        <option value="<?= (int) $program['id'] ?>" <?= (int) $submitted['program_id'] === (int) $program['id'] ? 'selected' : '' ?>><?= e($program['name']) ?> (<?= e(programTypeLabel($program['program_type'])) ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Intake</label>
                    <input type="text" id="studentCreateIntakeSearch" placeholder="Search intakes">
                    <select name="intake_id" id="studentCreateIntakeSelect" required <?= $selectedProgramIdForIntakes <= 0 ? 'disabled' : '' ?> data-selected="<?= (int) $submitted['intake_id'] ?>">
                        <option value=""><?= $selectedProgramIdForIntakes > 0 ? 'Select intake' : 'Select a program first' ?></option>
                        <?php foreach ($programIntakeOptions as $intake): ?>
                        <option value="<?= (int) $intake['id'] ?>" <?= (int) $submitted['intake_id'] === (int) $intake['id'] ? 'selected' : '' ?>><?= e($intake['name']) ?><?= !empty($intake['academic_year']) ? ' (' . e($intake['academic_year']) . ')' : '' ?><?= !empty($intake['status']) ? ' • ' . e($intake['status']) : '' ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Enrollment Status</label>
                    <select name="enrollment_status">
                        <?php foreach (['active' => 'Active', 'deferred' => 'Deferred', 'suspended' => 'Suspended', 'withdrawn' => 'Withdrawn', 'graduated' => 'Graduated'] as $key => $label): ?>
                        <option value="<?= e($key) ?>" <?= $submitted['enrollment_status'] === $key ? 'selected' : '' ?>><?= e($label) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label><input type="checkbox" name="create_portal" value="1" <?= !empty($submitted['create_portal']) ? 'checked' : '' ?>> Create student portal account</label>
                </div>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Register Student</button>
            </div>
        </form>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    msshtSearchableSelect('studentCreateProgramSearch', 'studentCreateProgramSelect');

    (function () {
        var backLink = document.getElementById('backToStudentsLink');
        var clearUrl = window.location.pathname + window.location.search;
        var csrf = '<?= csrfToken() ?>';
        var programSelect = document.getElementById('studentCreateProgramSelect');
        var intakeSearch = document.getElementById('studentCreateIntakeSearch');
        var intakeSelect = document.getElementById('studentCreateIntakeSelect');
        var intakeState = [];
        var intakeSelected = intakeSelect ? intakeSelect.getAttribute('data-selected') || '' : '';

        function getIntakeLabel(intake) {
            var label = intake.name || '';
            if (intake.academic_year) {
                label += ' (' + intake.academic_year + ')';
            }
            if (intake.status) {
                label += ' • ' + intake.status;
            }
            return label;
        }

        function renderIntakes(query) {
            if (!intakeSelect) return;
            var term = (query || '').toLowerCase().trim();
            var currentValue = intakeSelected || intakeSelect.value || '';
            intakeSelect.innerHTML = '';

            var placeholder = document.createElement('option');
            placeholder.value = '';
            placeholder.textContent = intakeState.length ? 'Select intake' : 'Select a program first';
            intakeSelect.appendChild(placeholder);

            intakeState.forEach(function (intake) {
                var label = getIntakeLabel(intake);
                if (term && label.toLowerCase().indexOf(term) === -1) return;

                var option = document.createElement('option');
                option.value = String(intake.id);
                option.textContent = label;
                if (String(intake.id) === String(currentValue)) {
                    option.selected = true;
                }
                intakeSelect.appendChild(option);
            });

            intakeSelect.disabled = intakeState.length === 0;
            if (!intakeState.length) {
                intakeSelected = '';
                intakeSelect.value = '';
            }
        }

        function loadProgramIntakes(programId, selectedIntakeId) {
            intakeSelected = selectedIntakeId ? String(selectedIntakeId) : '';

            if (!programId) {
                intakeState = [];
                renderIntakes('');
                if (intakeSearch) intakeSearch.value = '';
                return;
            }

            var url = window.location.pathname + '?ajax=program_intakes&program_id=' + encodeURIComponent(programId);
            fetch(url, { credentials: 'same-origin' })
                .then(function (response) { return response.json(); })
                .then(function (data) {
                    intakeState = data && data.success && Array.isArray(data.intakes) ? data.intakes : [];
                    renderIntakes(intakeSearch ? intakeSearch.value : '');
                })
                .catch(function () {
                    intakeState = [];
                    renderIntakes('');
                });
        }

        if (programSelect) {
            programSelect.addEventListener('change', function () {
                intakeSelected = '';
                if (intakeSearch) intakeSearch.value = '';
                loadProgramIntakes(this.value, '');
            });
        }

        if (intakeSearch) {
            intakeSearch.addEventListener('input', function () {
                renderIntakes(this.value);
            });
        }

        loadProgramIntakes(programSelect ? programSelect.value : '', intakeSelected);

        var previewExists = <?= !empty($_SESSION['student_import_preview']) ? 'true' : 'false' ?>;

        // Clear import preview on navigation/close using sendBeacon (only if preview exists)
        if (previewExists) {
            var cleared = false;
            function clearPreviewOnce() {
                if (cleared) return;
                cleared = true;
                if (!navigator.sendBeacon) return true;
                var fd = new FormData();
                fd.append('ajax', 'clear_import_preview');
                fd.append('csrf', csrf);
                navigator.sendBeacon(clearUrl, fd);
                return true;
            }

            if (backLink) {
                backLink.addEventListener('click', function () { clearPreviewOnce(); });
            }
            window.addEventListener('pagehide', clearPreviewOnce);
            window.addEventListener('beforeunload', clearPreviewOnce);
        }
    })();
});
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
