<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('exams');

$pageTitle = 'Examinations & Assessment';
$currentModule = 'exams';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare(
        'INSERT INTO assessments (module_id, title, assessment_type, weight_percent, max_score, scheduled_date) VALUES (?, ?, ?, ?, ?, ?)'
    )->execute([
        (int)$_POST['module_id'], trim($_POST['title']), $_POST['assessment_type'],
        (float)$_POST['weight_percent'], (float)$_POST['max_score'], $_POST['scheduled_date'] ?: null,
    ]);
    flash('success', 'Assessment created.');
    redirect(moduleUrl('exams'));
}

$assessments = $db->query(
    'SELECT a.*, m.code FROM assessments a JOIN modules m ON m.id = a.module_id ORDER BY a.scheduled_date DESC'
)->fetchAll();
$modules = $db->query('SELECT id, code, name FROM modules')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Add Assessment</h2></div>
    <div class="card-body">
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group">
                <label>Module</label>
                <select name="module_id" required><?php foreach ($modules as $m): ?>
                <option value="<?= $m['id'] ?>"><?= e($m['code']) ?></option><?php endforeach; ?></select>
            </div>
            <div class="form-group"><label>Title</label><input name="title" required></div>
            <div class="form-group">
                <label>Type</label>
                <select name="assessment_type"><option value="ca">Continuous Assessment</option><option value="exam">Exam</option><option value="project">Project</option><option value="practical">Practical</option></select>
            </div>
            <div class="form-group"><label>Weight %</label><input type="number" step="0.01" name="weight_percent" value="30"></div>
            <div class="form-group"><label>Max Score</label><input type="number" name="max_score" value="100"></div>
            <div class="form-group"><label>Date</label><input type="datetime-local" name="scheduled_date"></div>
            <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Add</button></div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Assessments</h2><a href="marks.php" class="btn btn-sm btn-outline">Enter Marks</a></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Title</th><th>Module</th><th>Type</th><th>Weight</th><th>Date</th></tr></thead>
            <tbody>
            <?php foreach ($assessments as $a): ?>
            <tr>
                <td><?= e($a['title']) ?></td>
                <td><?= e($a['code']) ?></td>
                <td><?= e(strtoupper($a['assessment_type'])) ?></td>
                <td><?= e($a['weight_percent']) ?>%</td>
                <td><?= $a['scheduled_date'] ? formatDate($a['scheduled_date'], 'd M Y H:i') : '—' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
