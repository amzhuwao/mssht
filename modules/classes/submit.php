<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();
requireStudentPortal();

$assignmentId = (int) ($_GET['assignment_id'] ?? $_POST['assignment_id'] ?? 0);
$studentId = getCurrentStudentId();
if (!$studentId) {
    flash('danger', 'Student record required.');
    redirect(moduleUrl('classes'));
}

$db = getDB();
$stmt = $db->prepare(
    'SELECT ca.*, c.name AS class_name, c.id AS class_id
     FROM class_assignments ca JOIN classes c ON c.id = ca.class_id
     WHERE ca.id = ? AND ca.status = ?'
);
$stmt->execute([$assignmentId, 'published']);
$assignment = $stmt->fetch();
if (!$assignment || !isClassMember((int)$assignment['class_id'])) {
    flash('danger', 'Assignment not found.');
    redirect(moduleUrl('classes'));
}

$sub = $db->prepare('SELECT * FROM class_submissions WHERE class_assignment_id = ? AND student_id = ?');
$sub->execute([$assignmentId, $studentId]);
$submission = $sub->fetch();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $filePath = !empty($_FILES['file']['name']) ? uploadFile($_FILES['file'], 'assignments') : ($submission['file_path'] ?? null);
    $ok = submitClassAssignment($assignmentId, $studentId, [
        'file_path'    => $filePath,
        'external_url' => trim($_POST['external_url'] ?? '') ?: null,
        'notes'        => trim($_POST['notes'] ?? ''),
    ]);
    if ($ok) {
        flash('success', 'Work submitted successfully.');
        redirect(moduleUrl('classes', 'view') . '?id=' . $assignment['class_id'] . '&tab=classwork');
    }
    flash('danger', 'Submission failed. Late submissions may not be allowed.');
}

$pageTitle = 'Submit: ' . $assignment['title'];
$currentModule = 'classes';
$extraCss = ['classroom.css'];
require_once __DIR__ . '/../../includes/header.php';

$isLate = strtotime($assignment['due_date']) < time();
$status = $submission ? computeSubmissionStatus($assignment, $submission) : ($isLate ? 'missing' : 'assigned');
?>

<div class="page-actions">
    <a href="view.php?id=<?= (int)$assignment['class_id'] ?>&tab=classwork" class="btn btn-outline btn-sm">&larr; Classwork</a>
</div>

<div class="card">
    <div class="card-header">
        <h2><?= e($assignment['title']) ?></h2>
        <?= statusBadge($status === 'missing' ? 'overdue' : ($status === 'late' ? 'partial' : ($status === 'graded' ? 'paid' : 'open'))) ?>
    </div>
    <div class="card-body">
        <p><strong>Class:</strong> <?= e($assignment['class_name']) ?></p>
        <p><strong>Due:</strong> <?= formatDate($assignment['due_date'], 'd M Y H:i') ?>
            <?php if ($isLate && !$assignment['allow_late']): ?>
            <span class="badge badge-danger">Late submissions closed</span>
            <?php elseif ($isLate): ?>
            <span class="badge badge-warning">Late</span>
            <?php endif; ?>
        </p>
        <p><strong>Points:</strong> <?= e($assignment['max_score']) ?></p>
        <?php if ($assignment['instructions']): ?>
        <div class="assignment-instructions"><?= nl2br(e($assignment['instructions'])) ?></div>
        <?php endif; ?>

        <?php if ($submission && $submission['feedback']): ?>
        <div class="alert alert-info" style="margin-top:1rem;">
            <strong>Teacher feedback:</strong><br><?= nl2br(e($submission['feedback'])) ?>
            <?php if ($submission['score'] !== null): ?>
            <br><strong>Score:</strong> <?= e($submission['score']) ?> / <?= e($assignment['max_score']) ?>
            <?php endif; ?>
        </div>
        <?php endif; ?>

        <?php if (!$isLate || $assignment['allow_late']): ?>
        <form method="post" enctype="multipart/form-data" style="margin-top:1.5rem;">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="assignment_id" value="<?= $assignmentId ?>">
            <div class="form-group">
                <label>Upload file (PDF, DOC, images)</label>
                <input type="file" name="file" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png">
                <?php if (!empty($submission['file_path'])): ?>
                <small class="text-muted">Current: <a href="<?= UPLOAD_URL . '/' . e($submission['file_path']) ?>" target="_blank">View file</a></small>
                <?php endif; ?>
            </div>
            <div class="form-group">
                <label>Or external link (Google Doc, video, etc.)</label>
                <input type="url" name="external_url" value="<?= e($submission['external_url'] ?? '') ?>" placeholder="https://">
            </div>
            <div class="form-group">
                <label>Private comment to teacher</label>
                <textarea name="notes" rows="3"><?= e($submission['notes'] ?? '') ?></textarea>
            </div>
            <button type="submit" class="btn btn-primary"><?= $submission ? 'Resubmit' : 'Turn in' ?></button>
        </form>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
