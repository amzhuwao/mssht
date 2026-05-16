<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();
requireModule('students');

$studentId = (int)($_GET['student_id'] ?? $_POST['student_id'] ?? 0);
$guardianId = (int)($_GET['guardian_id'] ?? $_POST['guardian_id'] ?? 0);

if (!$studentId) {
    flash('danger', 'Student required.');
    redirect(moduleUrl('students'));
}

$db = getDB();
$stmt = $db->prepare('SELECT s.student_number, a.first_name, a.last_name FROM students s LEFT JOIN applications a ON a.id = s.application_id WHERE s.id = ?');
$stmt->execute([$studentId]);
$student = $stmt->fetch();
if (!$student) {
    flash('danger', 'Student not found.');
    redirect(moduleUrl('students'));
}

$guardians = getStudentGuardians($studentId);
$target = null;
if ($guardianId) {
    foreach ($guardians as $g) {
        if ((int)$g['id'] === $guardianId) {
            $target = $g;
            break;
        }
    }
    if (!$target) {
        flash('danger', 'Guardian not linked to this student.');
        redirect(moduleUrl('students', 'view') . '?id=' . $studentId);
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    if ($guardianId && $studentId) {
        $ok = sendGuardianSummary($guardianId, $studentId);
        flash($ok ? 'success' : 'warning', $ok ? 'Summary email sent.' : 'Email could not be sent. Check mail configuration or enable receive summaries for this guardian.');
    } elseif ($studentId) {
        $sent = 0;
        foreach ($guardians as $g) {
            if (sendGuardianSummary((int)$g['id'], $studentId)) {
                $sent++;
            }
        }
        flash('success', "Sent {$sent} guardian summary email(s).");
    }
    redirect(moduleUrl('students', 'view') . '?id=' . $studentId);
}

$pageTitle = 'Send guardian summary';
$currentModule = 'students';
require_once __DIR__ . '/../../includes/header.php';

$studentLabel = trim(($student['first_name'] ?? '') . ' ' . ($student['last_name'] ?? '')) ?: $student['student_number'];
?>

<div class="card">
    <div class="card-header"><h2>Send progress summary</h2></div>
    <div class="card-body">
        <p>Student: <strong><?= e($studentLabel) ?></strong> (<?= e($student['student_number']) ?>)</p>
        <?php if ($target): ?>
        <p>Recipient: <strong><?= e($target['first_name'] . ' ' . $target['last_name']) ?></strong> — <?= e($target['email']) ?></p>
        <?php else: ?>
        <p>Recipients: <strong><?= count($guardians) ?></strong> guardian(s) with summaries enabled.</p>
        <?php endif; ?>
        <p class="text-muted">The email includes missing work, upcoming deadlines, recent grades, and a link to the guardian portal.</p>
        <form method="post" style="margin-top:1rem;">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="student_id" value="<?= $studentId ?>">
            <?php if ($guardianId): ?><input type="hidden" name="guardian_id" value="<?= $guardianId ?>"><?php endif; ?>
            <button type="submit" class="btn btn-primary">Send email now</button>
            <a href="<?= moduleUrl('students', 'view') ?>?id=<?= $studentId ?>" class="btn btn-outline">Cancel</a>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
