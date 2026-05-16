<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();
if (isStudentPortal()) {
    flash('danger', 'Students cannot create classes.');
    redirect(moduleUrl('classes'));
}

$db = getDB();
$modules = $db->query('SELECT id, code, name FROM modules ORDER BY code')->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $classId = createClass([
        'module_id'    => (int) ($_POST['module_id'] ?? 0) ?: null,
        'name'         => trim($_POST['name']),
        'section'      => trim($_POST['section'] ?? ''),
        'subject'      => trim($_POST['subject'] ?? ''),
        'room_number'  => trim($_POST['room_number'] ?? ''),
        'theme_color'  => $_POST['theme_color'] ?? '#0d4f4c',
        'description'  => trim($_POST['description'] ?? ''),
    ], (int) $_SESSION['user_id']);
    if ($classId) {
        flash('success', 'Class created. Share the join code with students.');
        redirect(moduleUrl('classes', 'view') . '?id=' . $classId);
    }
    flash('danger', 'Could not create class.');
}

$pageTitle = 'Create Class';
$currentModule = 'classes';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card" style="max-width:640px;">
    <div class="card-header"><h2>Create Class</h2></div>
    <div class="card-body">
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Class name *</label><input name="name" required placeholder="e.g. Hospitality Operations 2026"></div>
            <div class="form-row">
                <div class="form-group"><label>Section</label><input name="section" placeholder="Section A"></div>
                <div class="form-group"><label>Subject</label><input name="subject"></div>
            </div>
            <div class="form-row">
                <div class="form-group"><label>Room</label><input name="room_number"></div>
                <div class="form-group"><label>Theme colour</label><input type="color" name="theme_color" value="#0d4f4c"></div>
            </div>
            <div class="form-group">
                <label>Link to module (optional)</label>
                <select name="module_id">
                    <option value="">— None —</option>
                    <?php foreach ($modules as $m): ?>
                    <option value="<?= $m['id'] ?>"><?= e($m['code'] . ' - ' . $m['name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group"><label>Description</label><textarea name="description" rows="3"></textarea></div>
            <button type="submit" class="btn btn-primary">Create class</button>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
