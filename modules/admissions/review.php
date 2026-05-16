<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('admissions');

$id = (int)($_GET['id'] ?? 0);
$db = getDB();
$stmt = $db->prepare(
    'SELECT a.*, p.name AS program_name, i.name AS intake_name
     FROM applications a
     JOIN programs p ON p.id = a.program_id
     JOIN intakes i ON i.id = a.intake_id
     WHERE a.id = ?'
);
$stmt->execute([$id]);
$app = $stmt->fetch();
if (!$app) {
    flash('danger', 'Application not found.');
    redirect(moduleUrl('admissions'));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $newStatus = $_POST['status'];
    $notes = trim($_POST['notes'] ?? '');
    $db->prepare('UPDATE applications SET status = ?, notes = ?, reviewed_by = ?, reviewed_at = NOW() WHERE id = ?')
       ->execute([$newStatus, $notes, $_SESSION['user_id'], $id]);

    if ($newStatus === 'approved') {
        $studentNum = generateStudentNumber();
        $db->prepare(
            'INSERT INTO students (student_number, application_id, program_id, intake_id, enrollment_date)
             VALUES (?, ?, ?, ?, CURDATE())'
        )->execute([$studentNum, $id, $app['program_id'], $app['intake_id']]);
        $studentId = (int) $db->lastInsertId();
        $portal = createStudentPortalAccount($studentId);
        $portalMsg = $portal
            ? " Portal login — ID: {$portal['student_number']}, temp password: {$portal['temp_password']}"
            : '';
        flash('success', "Application approved. Student ID: $studentNum.$portalMsg");
    } else {
        flash('success', 'Application updated.');
    }
    auditLog('application_' . $newStatus, 'application', $id);
    redirect(moduleUrl('admissions', 'review') . '?id=' . $id);
}

$docs = $db->prepare('SELECT * FROM application_documents WHERE application_id = ?');
$docs->execute([$id]);
$documents = $docs->fetchAll();

$pageTitle = 'Review Application';
$currentModule = 'admissions';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="index.php" class="btn btn-outline btn-sm">&larr; Back to Applications</a>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2><?= e($app['application_ref']) ?> — <?= statusBadge($app['status']) ?></h2></div>
        <div class="card-body">
            <div class="form-row">
                <div><strong>Name:</strong> <?= e($app['first_name'] . ' ' . $app['last_name']) ?></div>
                <div><strong>Email:</strong> <?= e($app['email']) ?></div>
                <div><strong>Phone:</strong> <?= e($app['phone']) ?></div>
                <div><strong>Program:</strong> <?= e($app['program_name']) ?></div>
                <div><strong>Intake:</strong> <?= e($app['intake_name']) ?></div>
                <div><strong>Applied:</strong> <?= formatDate($app['created_at']) ?></div>
            </div>
            <?php if ($app['previous_qualification']): ?>
            <p style="margin-top:1rem;"><strong>Qualification:</strong> <?= e($app['previous_qualification']) ?></p>
            <?php endif; ?>
            <?php if ($app['address']): ?>
            <p><strong>Address:</strong> <?= e($app['address']) ?></p>
            <?php endif; ?>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h2>Update Status</h2></div>
        <div class="card-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" required>
                        <?php foreach (['pending','under_review','approved','rejected','waitlisted'] as $s): ?>
                        <option value="<?= $s ?>" <?= $app['status'] === $s ? 'selected' : '' ?>><?= ucfirst(str_replace('_',' ',$s)) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Notes</label>
                    <textarea name="notes" rows="3"><?= e($app['notes'] ?? '') ?></textarea>
                </div>
                <button type="submit" class="btn btn-primary">Save Decision</button>
            </form>
        </div>
    </div>
</div>

<?php if ($documents): ?>
<div class="card">
    <div class="card-header"><h2>Uploaded Documents</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Type</th><th>Uploaded</th><th>Download</th></tr></thead>
            <tbody>
            <?php foreach ($documents as $doc): ?>
            <tr>
                <td><?= e($doc['document_type']) ?></td>
                <td><?= formatDate($doc['uploaded_at']) ?></td>
                <td><a href="<?= UPLOAD_URL . '/' . e($doc['file_path']) ?>" target="_blank">View</a></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
