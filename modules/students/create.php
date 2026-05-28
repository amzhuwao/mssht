<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('students');

$pageTitle = 'Register Student';
$currentModule = 'students';
$db = getDB();
$programs = $db->query("SELECT id, code, name, program_type FROM programs WHERE status = 'active' ORDER BY name")->fetchAll();
$intakes = $db->query("SELECT id, name FROM intakes WHERE status IN ('open','closed') ORDER BY start_date DESC")->fetchAll();
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

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
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
                'INSERT INTO students (student_number, program_id, intake_id, enrollment_status, enrollment_date) VALUES (?, ?, ?, ?, CURDATE())'
            );
            $stmt->execute([
                $studentNumber,
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

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="<?= moduleUrl('students') ?>" class="btn btn-outline btn-sm">&larr; Back to Students</a>
</div>

<div class="card">
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
                    <select name="intake_id" id="studentCreateIntakeSelect" required>
                        <option value="">Select intake</option>
                        <?php foreach ($intakes as $intake): ?>
                        <option value="<?= (int) $intake['id'] ?>" <?= (int) $submitted['intake_id'] === (int) $intake['id'] ? 'selected' : '' ?>><?= e($intake['name']) ?></option>
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
msshtSearchableSelect('studentCreateProgramSearch', 'studentCreateProgramSelect');
msshtSearchableSelect('studentCreateIntakeSearch', 'studentCreateIntakeSelect');
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
