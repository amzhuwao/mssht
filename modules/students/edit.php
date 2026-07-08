<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('students');

$id = (int)($_GET['id'] ?? 0);
$db = getDB();

$stmt = $db->prepare(
    'SELECT s.*,
            p.name AS program_name,
            i.name AS intake_name,
            COALESCE(s.first_name, up.first_name) AS first_name,
            COALESCE(s.last_name, up.last_name) AS last_name,
            COALESCE(s.email, u.email) AS email,
            COALESCE(s.phone, up.phone) AS phone
     FROM students s
     JOIN programs p ON p.id = s.program_id
     JOIN intakes i ON i.id = s.intake_id
     LEFT JOIN users u ON u.id = s.user_id
     LEFT JOIN user_profiles up ON up.user_id = u.id
     WHERE s.id = ?'
);
$stmt->execute([$id]);
$student = $stmt->fetch();
if (!$student) {
    flash('danger', 'Student not found.');
    redirect(moduleUrl('students'));
}

$programs = $db->query("SELECT id, name, program_type FROM programs WHERE status = 'active' ORDER BY name")->fetchAll();
$intakes = $db->query("SELECT id, name FROM intakes WHERE status IN ('open','closed') ORDER BY start_date DESC")->fetchAll();
$errors = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $submitted = [
        'student_number' => trim($_POST['student_number'] ?? ''),
        'first_name' => trim($_POST['first_name'] ?? ''),
        'last_name' => trim($_POST['last_name'] ?? ''),
        'email' => trim($_POST['email'] ?? ''),
        'phone' => trim($_POST['phone'] ?? ''),
        'gender' => in_array(($_POST['gender'] ?? ''), ['male', 'female', 'other'], true) ? $_POST['gender'] : null,
        'date_of_birth' => $_POST['date_of_birth'] ?: null,
        'address' => trim($_POST['address'] ?? ''),
        'previous_qualification' => trim($_POST['previous_qualification'] ?? ''),
        'program_id' => (int) ($_POST['program_id'] ?? 0),
        'intake_id' => (int) ($_POST['intake_id'] ?? 0),
        'enrollment_status' => in_array(($_POST['enrollment_status'] ?? 'active'), ['active', 'graduated', 'withdrawn', 'suspended', 'deferred'], true) ? $_POST['enrollment_status'] : 'active',
    ];

    if ($submitted['student_number'] === '') $errors[] = 'Student number is required.';
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

    if (!$errors) {
        try {
            $db->beginTransaction();

            $check = $db->prepare('SELECT id FROM students WHERE student_number = ? AND id <> ?');
            $check->execute([$submitted['student_number'], $id]);
            if ($check->fetchColumn()) {
                throw new RuntimeException('That student number already exists.');
            }

            $db->prepare(
                'UPDATE students
                 SET student_number = ?, first_name = ?, last_name = ?, email = ?, phone = ?, gender = ?, date_of_birth = ?, address = ?, previous_qualification = ?, program_id = ?, intake_id = ?, enrollment_status = ?
                 WHERE id = ?'
            )->execute([
                $submitted['student_number'],
                $submitted['first_name'],
                $submitted['last_name'],
                $submitted['email'] !== '' ? $submitted['email'] : null,
                $submitted['phone'] !== '' ? $submitted['phone'] : null,
                $submitted['gender'],
                $submitted['date_of_birth'],
                $submitted['address'] !== '' ? $submitted['address'] : null,
                $submitted['previous_qualification'] !== '' ? $submitted['previous_qualification'] : null,
                $submitted['program_id'],
                $submitted['intake_id'],
                $submitted['enrollment_status'],
                $id,
            ]);

            if (!empty($student['user_id'])) {
                $db->prepare('UPDATE users SET email = ?, status = ? WHERE id = ?')
                   ->execute([$submitted['email'] !== '' ? $submitted['email'] : $student['email'], $submitted['enrollment_status'] === 'suspended' ? 'suspended' : 'active', (int) $student['user_id']]);

                $profileStmt = $db->prepare('SELECT id FROM user_profiles WHERE user_id = ?');
                $profileStmt->execute([(int) $student['user_id']]);
                if ($profileStmt->fetchColumn()) {
                    $db->prepare('UPDATE user_profiles SET first_name = ?, last_name = ?, phone = ?, gender = ?, date_of_birth = ?, address = ? WHERE user_id = ?')
                       ->execute([
                           $submitted['first_name'],
                           $submitted['last_name'],
                           $submitted['phone'] !== '' ? $submitted['phone'] : null,
                           $submitted['gender'],
                           $submitted['date_of_birth'],
                           $submitted['address'] !== '' ? $submitted['address'] : null,
                           (int) $student['user_id'],
                       ]);
                } else {
                    $db->prepare('INSERT INTO user_profiles (user_id, first_name, last_name, phone, gender, date_of_birth, address) VALUES (?, ?, ?, ?, ?, ?, ?)')
                       ->execute([
                           (int) $student['user_id'],
                           $submitted['first_name'],
                           $submitted['last_name'],
                           $submitted['phone'] !== '' ? $submitted['phone'] : null,
                           $submitted['gender'],
                           $submitted['date_of_birth'],
                           $submitted['address'] !== '' ? $submitted['address'] : null,
                       ]);
                }
            }

            $db->commit();
            flash('success', 'Student details updated.');
            redirect(moduleUrl('students', 'view') . '?id=' . $id);
        } catch (Throwable $e) {
            if ($db->inTransaction()) {
                $db->rollBack();
            }
            $errors[] = $e->getMessage() ?: 'Update failed.';
        }
    }

    if ($errors) {
        flash('danger', implode(' ', array_unique($errors)));
    }
}

$pageTitle = 'Edit Student';
$currentModule = 'students';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="<?= moduleUrl('students', 'view') ?>?id=<?= $id ?>" class="btn btn-outline btn-sm">&larr; Back to Profile</a>
</div>

<div class="card">
    <div class="card-header"><h2>Edit Student</h2></div>
    <div class="card-body">
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Student Number</label><input name="student_number" required value="<?= e($_POST['student_number'] ?? $student['student_number']) ?>"></div>
            <div class="form-group"><label>First Name</label><input name="first_name" required value="<?= e($_POST['first_name'] ?? $student['first_name']) ?>"></div>
            <div class="form-group"><label>Last Name</label><input name="last_name" required value="<?= e($_POST['last_name'] ?? $student['last_name']) ?>"></div>
            <div class="form-group"><label>Email</label><input type="email" name="email" value="<?= e($_POST['email'] ?? $student['email']) ?>"></div>
            <div class="form-group"><label>Phone</label><input name="phone" value="<?= e($_POST['phone'] ?? $student['phone']) ?>"></div>
            <div class="form-group"><label>Gender</label>
                <select name="gender">
                    <?php $genderValue = $_POST['gender'] ?? $student['gender'] ?? ''; ?>
                    <option value="">Select</option>
                    <option value="male" <?= $genderValue === 'male' ? 'selected' : '' ?>>Male</option>
                    <option value="female" <?= $genderValue === 'female' ? 'selected' : '' ?>>Female</option>
                    <option value="other" <?= $genderValue === 'other' ? 'selected' : '' ?>>Other</option>
                </select>
            </div>
            <div class="form-group"><label>Date of Birth</label><input type="date" name="date_of_birth" value="<?= e($_POST['date_of_birth'] ?? ($student['date_of_birth'] ?? '')) ?>"></div>
            <div class="form-group"><label>Address</label><textarea name="address" rows="3"><?= e($_POST['address'] ?? $student['address']) ?></textarea></div>
            <div class="form-group"><label>Previous Qualification</label><input name="previous_qualification" value="<?= e($_POST['previous_qualification'] ?? $student['previous_qualification']) ?>"></div>
            <div class="form-group"><label>Program</label>
                <select name="program_id" required>
                    <option value="">Select program</option>
                    <?php $programValue = (int) ($_POST['program_id'] ?? $student['program_id']); ?>
                    <?php foreach ($programs as $program): ?>
                    <option value="<?= (int) $program['id'] ?>" <?= $programValue === (int) $program['id'] ? 'selected' : '' ?>><?= e($program['name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group"><label>Intake</label>
                <select name="intake_id" required>
                    <option value="">Select intake</option>
                    <?php $intakeValue = (int) ($_POST['intake_id'] ?? $student['intake_id']); ?>
                    <?php foreach ($intakes as $intake): ?>
                    <option value="<?= (int) $intake['id'] ?>" <?= $intakeValue === (int) $intake['id'] ? 'selected' : '' ?>><?= e($intake['name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group"><label>Status</label>
                <select name="enrollment_status">
                    <?php $statusValue = $_POST['enrollment_status'] ?? $student['enrollment_status']; ?>
                    <?php foreach (['active' => 'Active', 'deferred' => 'Deferred', 'suspended' => 'Suspended', 'withdrawn' => 'Withdrawn', 'graduated' => 'Graduated'] as $key => $label): ?>
                    <option value="<?= e($key) ?>" <?= $statusValue === $key ? 'selected' : '' ?>><?= e($label) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Save Changes</button></div>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>