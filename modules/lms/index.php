<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('lms');

$pageTitle = 'Learning Management';
$currentModule = 'lms';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $path = !empty($_FILES['file']['name']) ? uploadFile($_FILES['file'], 'lms') : null;
    $db->prepare(
        'INSERT INTO lms_materials (module_id, title, description, file_path, external_url, uploaded_by) VALUES (?, ?, ?, ?, ?, ?)'
    )->execute([
        (int)$_POST['module_id'], trim($_POST['title']), trim($_POST['description'] ?? ''),
        $path, trim($_POST['external_url'] ?? '') ?: null, $_SESSION['user_id'],
    ]);
    flash('success', 'Material uploaded.');
    redirect(moduleUrl('lms'));
}

$materials = $db->query(
    'SELECT lm.*, m.code, m.name AS module_name FROM lms_materials lm
     JOIN modules m ON m.id = lm.module_id ORDER BY lm.created_at DESC LIMIT 30'
)->fetchAll();
$modules = $db->query('SELECT id, code, name FROM modules ORDER BY code')->fetchAll();
$assignments = $db->query(
    'SELECT a.*, m.code FROM assignments a JOIN modules m ON m.id = a.module_id ORDER BY a.due_date DESC LIMIT 20'
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Upload Learning Material</h2></div>
        <div class="card-body">
            <form method="post" enctype="multipart/form-data">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <div class="form-group">
                    <label>Module</label>
                    <select name="module_id" required>
                        <?php foreach ($modules as $m): ?>
                        <option value="<?= $m['id'] ?>"><?= e($m['code'] . ' - ' . $m['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group"><label>Title</label><input name="title" required></div>
                <div class="form-group"><label>Description</label><textarea name="description" rows="2"></textarea></div>
                <div class="form-group"><label>File</label><input type="file" name="file"></div>
                <div class="form-group"><label>Or External URL (Zoom/Teams)</label><input type="url" name="external_url" placeholder="https://"></div>
                <button type="submit" class="btn btn-primary">Upload</button>
            </form>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Learning Materials</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Title</th><th>Module</th><th>Date</th><th>Access</th></tr></thead>
            <tbody>
            <?php foreach ($materials as $mat): ?>
            <tr>
                <td><?= e($mat['title']) ?></td>
                <td><?= e($mat['code']) ?></td>
                <td><?= formatDate($mat['created_at']) ?></td>
                <td>
                    <?php if ($mat['file_path']): ?>
                    <a href="<?= UPLOAD_URL . '/' . e($mat['file_path']) ?>" target="_blank">Download</a>
                    <?php elseif ($mat['external_url']): ?>
                    <a href="<?= e($mat['external_url']) ?>" target="_blank">Open Link</a>
                    <?php endif; ?>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Assignments</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Title</th><th>Module</th><th>Due</th><th>Max Score</th></tr></thead>
            <tbody>
            <?php foreach ($assignments as $a): ?>
            <tr>
                <td><?= e($a['title']) ?></td>
                <td><?= e($a['code']) ?></td>
                <td><?= formatDate($a['due_date'], 'd M Y H:i') ?></td>
                <td><?= e($a['max_score']) ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
