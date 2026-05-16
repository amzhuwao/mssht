<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('students');

$id = (int)($_GET['id'] ?? 0);
$db = getDB();
$stmt = $db->prepare(
    'SELECT s.*, p.name AS program_name, p.program_type, i.name AS intake_name,
            a.first_name, a.last_name, a.email, a.phone
     FROM students s
     JOIN programs p ON p.id = s.program_id
     JOIN intakes i ON i.id = s.intake_id
     LEFT JOIN applications a ON a.id = s.application_id
     WHERE s.id = ?'
);
$stmt->execute([$id]);
$student = $stmt->fetch();
if (!$student) {
    flash('danger', 'Student not found.');
    redirect(moduleUrl('students'));
}

$registrations = $db->prepare(
    'SELECT mr.*, m.code, m.name AS module_name FROM module_registrations mr
     JOIN modules m ON m.id = mr.module_id WHERE mr.student_id = ?'
);
$registrations->execute([$id]);
$registrations = $registrations->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    if (($_POST['action'] ?? '') === 'add_guardian') {
        saveGuardianForStudent($id, [
            'first_name' => $_POST['first_name'],
            'last_name'  => $_POST['last_name'],
            'email'      => $_POST['email'],
            'phone'      => $_POST['phone'] ?? '',
            'relationship' => $_POST['relationship'] ?? 'parent',
            'is_primary' => isset($_POST['is_primary']),
            'receive_summaries' => isset($_POST['receive_summaries']),
        ]);
        flash('success', 'Guardian added.');
        redirect(moduleUrl('students', 'view') . '?id=' . $id);
    }
}

$guardians = getStudentGuardians($id);

$pageTitle = 'Student: ' . $student['student_number'];
$currentModule = 'students';

$hasPortal = !empty($student['user_id']);
$portalUser = null;
if ($hasPortal) {
    $pu = $db->prepare('SELECT email, must_change_password, last_login FROM users WHERE id = ?');
    $pu->execute([$student['user_id']]);
    $portalUser = $pu->fetch();
}

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="index.php" class="btn btn-outline btn-sm">&larr; All Students</a>
    <?php if ($hasPortal): ?>
    <a href="create-portal.php?id=<?= $id ?>&reset=1" class="btn btn-outline btn-sm"
       data-confirm="Reset this student's portal password?">Reset Portal Password</a>
    <?php else: ?>
    <a href="create-portal.php?id=<?= $id ?>" class="btn btn-primary btn-sm">Create Portal Login</a>
    <?php endif; ?>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2><?= e($student['student_number']) ?></h2><?= statusBadge($student['enrollment_status']) ?></div>
        <div class="card-body">
            <?php if ($student['first_name']): ?>
            <p><strong>Name:</strong> <?= e($student['first_name'] . ' ' . $student['last_name']) ?></p>
            <p><strong>Email:</strong> <?= e($student['email']) ?></p>
            <p><strong>Phone:</strong> <?= e($student['phone']) ?></p>
            <?php endif; ?>
            <p><strong>Program:</strong> <?= e($student['program_name']) ?> (<?= programTypeLabel($student['program_type']) ?>)</p>
            <p><strong>Intake:</strong> <?= e($student['intake_name']) ?></p>
            <p><strong>Enrolled:</strong> <?= formatDate($student['enrollment_date']) ?></p>
            <hr style="margin:1rem 0;border-color:var(--color-border);">
            <p><strong>Portal access:</strong>
                <?php if ($hasPortal && $portalUser): ?>
                Active — <?= e($portalUser['email']) ?>
                <?php if ($portalUser['must_change_password']): ?>
                <span class="badge badge-warning">Must change password</span>
                <?php endif; ?>
                <?php else: ?>
                <span class="text-muted">Not set up</span>
                <?php endif; ?>
            </p>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>Module Registrations</h2></div>
        <div class="card-body">
            <?php if (empty($registrations)): ?>
            <p class="text-muted">No module registrations yet.</p>
            <?php else: ?>
            <table class="data-table">
                <thead><tr><th>Module</th><th>Year</th><th>Status</th><th>Grade</th></tr></thead>
                <tbody>
                <?php foreach ($registrations as $r): ?>
                <tr>
                    <td><?= e($r['code'] . ' - ' . $r['module_name']) ?></td>
                    <td><?= e($r['academic_year']) ?></td>
                    <td><?= statusBadge($r['status']) ?></td>
                    <td><?= e($r['grade'] ?? '—') ?></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <?php endif; ?>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h2>Guardians / Parents</h2>
    </div>
    <div class="card-body">
        <?php if ($guardians): ?>
        <table class="data-table" style="margin-bottom:1.5rem;">
            <thead><tr><th>Name</th><th>Email</th><th>Relationship</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($guardians as $g): ?>
            <tr>
                <td><?= e($g['first_name'] . ' ' . $g['last_name']) ?></td>
                <td><?= e($g['email']) ?></td>
                <td><?= e($g['relationship']) ?></td>
                <td>
                    <a href="<?= moduleUrl('guardians', 'send-summary') ?>?student_id=<?= $id ?>&guardian_id=<?= (int)$g['id'] ?>" class="btn btn-sm btn-outline">Send summary</a>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <p><a href="<?= moduleUrl('guardians', 'send-summary') ?>?student_id=<?= $id ?>" class="btn btn-outline btn-sm">Email all guardians</a></p>
        <?php else: ?>
        <p class="text-muted">No guardians registered.</p>
        <?php endif; ?>
        <h3 style="font-size:1rem;margin:1rem 0;">Add guardian</h3>
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="action" value="add_guardian">
            <div class="form-group"><label>First name</label><input name="first_name" required></div>
            <div class="form-group"><label>Last name</label><input name="last_name" required></div>
            <div class="form-group"><label>Email</label><input type="email" name="email" required></div>
            <div class="form-group"><label>Phone</label><input name="phone"></div>
            <div class="form-group"><label>Relationship</label>
                <select name="relationship"><option value="parent">Parent</option><option value="guardian">Guardian</option><option value="sponsor">Sponsor</option></select>
            </div>
            <div class="form-group"><label><input type="checkbox" name="receive_summaries" value="1" checked> Receive progress summaries</label></div>
            <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Add guardian</button></div>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
