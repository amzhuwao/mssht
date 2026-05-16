<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();

$classId = (int) ($_GET['id'] ?? $_POST['class_id'] ?? 0);
if (!isClassTeacher($classId)) {
    flash('danger', 'Access denied.');
    redirect(moduleUrl('classes'));
}

$db = getDB();
$topics = $db->prepare('SELECT id, title FROM class_topics WHERE class_id = ? ORDER BY sort_order');
$topics->execute([$classId]);
$topics = $topics->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $path = !empty($_FILES['file']['name']) ? uploadFile($_FILES['file'], 'assignments') : null;
    publishClassAssignment($classId, [
        'topic_id'     => (int) ($_POST['topic_id'] ?? 0) ?: null,
        'title'        => trim($_POST['title']),
        'instructions' => trim($_POST['instructions'] ?? ''),
        'due_date'     => $_POST['due_date'],
        'max_score'    => (float) ($_POST['max_score'] ?? 100),
        'allow_late'   => isset($_POST['allow_late']),
        'attachment_path' => $path,
    ], (int) $_SESSION['user_id']);
    flash('success', 'Assignment published to class.');
    redirect(moduleUrl('classes', 'view') . '?id=' . $classId . '&tab=classwork');
}

$pageTitle = 'Create Assignment';
$currentModule = 'classes';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card" style="max-width:640px;">
    <div class="card-header"><h2>Create assignment</h2></div>
    <div class="card-body">
        <form method="post" enctype="multipart/form-data">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="class_id" value="<?= $classId ?>">
            <div class="form-group"><label>Title *</label><input name="title" required></div>
            <div class="form-group"><label>Instructions</label><textarea name="instructions" rows="4"></textarea></div>
            <div class="form-row">
                <div class="form-group"><label>Due date *</label><input type="datetime-local" name="due_date" required></div>
                <div class="form-group"><label>Max points</label><input type="number" name="max_score" value="100" step="0.01"></div>
            </div>
            <div class="form-group"><label><input type="checkbox" name="allow_late" checked> Allow late submission</label></div>
            <div class="form-group"><label>Attachment</label><input type="file" name="file"></div>
            <button type="submit" class="btn btn-primary">Assign</button>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
