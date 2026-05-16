<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();

$classId = (int) ($_GET['id'] ?? $_POST['class_id'] ?? 0);
if (!isClassTeacher($classId)) {
    flash('danger', 'Access denied.');
    redirect(moduleUrl('classes'));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $path = !empty($_FILES['file']['name']) ? uploadFile($_FILES['file'], 'lms') : null;
    postStreamAnnouncement($classId, (int)$_SESSION['user_id'], [
        'post_type'  => $_POST['post_type'] ?? 'announcement',
        'title'      => trim($_POST['title'] ?? ''),
        'body'       => trim($_POST['body']),
        'attachment_path' => $path,
        'external_url' => trim($_POST['external_url'] ?? '') ?: null,
        'comments_enabled' => isset($_POST['comments_enabled']) ? 1 : 0,
    ]);
    flash('success', 'Posted to class stream.');
    redirect(moduleUrl('classes', 'view') . '?id=' . $classId);
}

$pageTitle = 'Post to Stream';
$currentModule = 'classes';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card" style="max-width:640px;">
    <div class="card-header"><h2>Post announcement</h2></div>
    <div class="card-body">
        <form method="post" enctype="multipart/form-data">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="class_id" value="<?= $classId ?>">
            <div class="form-group">
                <label>Type</label>
                <select name="post_type"><option value="announcement">Announcement</option><option value="material">Material</option></select>
            </div>
            <div class="form-group"><label>Title</label><input name="title"></div>
            <div class="form-group"><label>Message *</label><textarea name="body" rows="5" required></textarea></div>
            <div class="form-group"><label>Attachment</label><input type="file" name="file"></div>
            <div class="form-group"><label>External link</label><input type="url" name="external_url"></div>
            <div class="form-group"><label><input type="checkbox" name="comments_enabled" checked> Allow comments</label></div>
            <button type="submit" class="btn btn-primary">Post</button>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
