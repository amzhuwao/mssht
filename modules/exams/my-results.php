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

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>My Assessment Results</h2></div>
    <div class="card-body table-wrap">
        <?php if (empty($results)): ?>
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
