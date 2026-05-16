<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('programs');

$programId = (int)($_GET['program_id'] ?? 0);
$db = getDB();
$program = $db->prepare('SELECT * FROM programs WHERE id = ?');
$program->execute([$programId]);
$program = $program->fetch();
if (!$program) {
    flash('danger', 'Program not found.');
    redirect(moduleUrl('programs'));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare('INSERT INTO modules (program_id, code, name, credits, semester, is_core) VALUES (?, ?, ?, ?, ?, ?)')
       ->execute([$programId, strtoupper(trim($_POST['code'])), trim($_POST['name']), (float)$_POST['credits'], (int)$_POST['semester'], isset($_POST['is_core']) ? 1 : 0]);
    flash('success', 'Module added.');
    redirect(moduleUrl('programs', 'modules') . '?program_id=' . $programId);
}

$modules = $db->prepare('SELECT * FROM modules WHERE program_id = ? ORDER BY semester, code');
$modules->execute([$programId]);
$modules = $modules->fetchAll();

$pageTitle = 'Curriculum: ' . $program['name'];
$currentModule = 'programs';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="index.php" class="btn btn-outline btn-sm">&larr; Programs</a>
</div>

<div class="card">
    <div class="card-header"><h2><?= e($program['name']) ?> — Modules</h2></div>
    <div class="card-body">
        <form method="post" class="form-row" style="align-items:flex-end;">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Code</label><input name="code" required></div>
            <div class="form-group"><label>Name</label><input name="name" required></div>
            <div class="form-group"><label>Credits</label><input type="number" step="0.01" name="credits" value="0"></div>
            <div class="form-group"><label>Semester</label><input type="number" name="semester" value="1" min="1"></div>
            <div class="form-group"><label><input type="checkbox" name="is_core" checked> Core</label></div>
            <button type="submit" class="btn btn-primary">Add Module</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Code</th><th>Module</th><th>Credits</th><th>Semester</th><th>Core</th></tr></thead>
            <tbody>
            <?php foreach ($modules as $m): ?>
            <tr>
                <td><?= e($m['code']) ?></td>
                <td><?= e($m['name']) ?></td>
                <td><?= e($m['credits']) ?></td>
                <td><?= (int)$m['semester'] ?></td>
                <td><?= $m['is_core'] ? 'Yes' : 'No' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
