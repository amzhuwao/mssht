<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('exams');

$db = getDB();
$assessmentId = (int)($_GET['assessment_id'] ?? 0);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $assessmentId = (int)$_POST['assessment_id'];
    foreach ($_POST['scores'] ?? [] as $studentId => $score) {
        if ($score === '') continue;
        $db->prepare(
            'INSERT INTO marks (assessment_id, student_id, score, entered_by) VALUES (?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE score = VALUES(score), entered_by = VALUES(entered_by)'
        )->execute([$assessmentId, (int)$studentId, (float)$score, $_SESSION['user_id']]);
    }
    flash('success', 'Marks saved.');
}

$assessments = $db->query('SELECT a.id, a.title, m.code FROM assessments a JOIN modules m ON m.id = a.module_id')->fetchAll();
$students = [];
$marks = [];
if ($assessmentId) {
    $students = $db->query("SELECT id, student_number FROM students WHERE enrollment_status = 'active'")->fetchAll();
    $stmt = $db->prepare('SELECT student_id, score FROM marks WHERE assessment_id = ?');
    $stmt->execute([$assessmentId]);
    foreach ($stmt->fetchAll() as $m) $marks[$m['student_id']] = $m['score'];
}

$pageTitle = 'Mark Entry';
$currentModule = 'exams';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Enter Marks</h2></div>
    <div class="card-body">
        <form method="get" class="form-group">
            <label>Select Assessment</label>
            <select name="assessment_id" onchange="this.form.submit()">
                <option value="">Choose...</option>
                <?php foreach ($assessments as $a): ?>
                <option value="<?= $a['id'] ?>" <?= $assessmentId === (int)$a['id'] ? 'selected' : '' ?>><?= e($a['title'] . ' (' . $a['code'] . ')') ?></option>
                <?php endforeach; ?>
            </select>
        </form>
        <?php if ($assessmentId && $students): ?>
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="assessment_id" value="<?= $assessmentId ?>">
            <table class="data-table">
                <thead><tr><th>Student ID</th><th>Score</th></tr></thead>
                <tbody>
                <?php foreach ($students as $s): ?>
                <tr>
                    <td><?= e($s['student_number']) ?></td>
                    <td><input type="number" step="0.01" name="scores[<?= $s['id'] ?>]" value="<?= e($marks[$s['id']] ?? '') ?>" style="width:100px;"></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <button type="submit" class="btn btn-primary" style="margin-top:1rem;">Save Marks</button>
        </form>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
