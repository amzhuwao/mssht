<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('exams');

if (!isStudentPortal()) {
    redirect(moduleUrl('exams'));
}

$pageTitle = 'My Results';
$currentModule = 'exams';
$studentId = getCurrentStudentId();
$db = getDB();

$results = [];
if ($studentId) {
    $stmt = $db->prepare(
        'SELECT a.title, a.assessment_type, a.max_score, m.score, m.grade, m.entered_at, modu.code, modu.name AS module_name
         FROM marks m
         JOIN assessments a ON a.id = m.assessment_id
         JOIN modules modu ON modu.id = a.module_id
         WHERE m.student_id = ?
         ORDER BY m.entered_at DESC'
    );
    $stmt->execute([$studentId]);
    $results = $stmt->fetchAll();
}

$resultsBlocked = $studentId && studentHasFinanceHold($studentId, 'results');

require_once __DIR__ . '/../../includes/header.php';
?>

<?php if ($resultsBlocked): ?>
<div class="alert alert-danger">Your results are withheld due to an outstanding fees hold. Please contact the finance office or settle your balance via <a href="<?= moduleUrl('finance') ?>">My Fees</a>.</div>
<?php endif; ?>

<div class="page-actions">
    <a href="<?= moduleUrl('classes', 'grades-pdf') ?>" class="btn btn-outline btn-sm">Download class grades PDF</a>
</div>
<div class="card">
    <div class="card-header"><h2>My Assessment Results</h2></div>
    <div class="card-body table-wrap">
        <?php if ($resultsBlocked): ?>
        <p class="empty-state">Results unavailable while financial hold is active.</p>
        <?php elseif (empty($results)): ?>
        <p class="empty-state">No results published yet.</p>
        <?php else: ?>
        <table class="data-table">
            <thead>
                <tr><th>Module</th><th>Assessment</th><th>Type</th><th>Score</th><th>Grade</th><th>Date</th></tr>
            </thead>
            <tbody>
            <?php foreach ($results as $r): ?>
            <tr>
                <td><?= e($r['code']) ?></td>
                <td><?= e($r['title']) ?></td>
                <td><?= e(strtoupper($r['assessment_type'])) ?></td>
                <td><?= e($r['score']) ?> / <?= e($r['max_score']) ?></td>
                <td><?= e($r['grade'] ?? '—') ?></td>
                <td><?= formatDate($r['entered_at']) ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
