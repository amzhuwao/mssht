<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();
requireModule('notifications');

$userId = (int) $_SESSION['user_id'];
$db = getDB();

if (isset($_GET['read']) && $_GET['read'] === 'all') {
    $db->prepare('UPDATE user_notifications SET is_read = 1 WHERE user_id = ?')->execute([$userId]);
    flash('success', 'All notifications marked as read.');
    redirect(moduleUrl('notifications'));
}

if ($markId = (int) ($_GET['mark'] ?? 0)) {
    $db->prepare('UPDATE user_notifications SET is_read = 1 WHERE id = ? AND user_id = ?')->execute([$markId, $userId]);
    redirect(moduleUrl('notifications'));
}

$items = [];
try {
    $stmt = $db->prepare('SELECT * FROM user_notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 50');
    $stmt->execute([$userId]);
    $items = $stmt->fetchAll();
} catch (Exception $e) {
    // table missing
}

$pageTitle = 'Notifications';
$currentModule = 'notifications';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <h2 style="margin:0;">Notifications</h2>
    <?php if ($items): ?>
    <a href="?read=all" class="btn btn-outline btn-sm">Mark all read</a>
    <?php endif; ?>
</div>

<div class="card">
    <div class="card-body">
        <?php if (empty($items)): ?>
        <p class="empty-state">No notifications yet. Assignment due dates and class updates will appear here.</p>
        <?php else: ?>
        <ul class="notification-list">
            <?php foreach ($items as $n): ?>
            <li class="notification-item <?= $n['is_read'] ? '' : 'unread' ?>">
                <div class="notification-meta">
                    <strong><?= e($n['title']) ?></strong>
                    <span class="text-muted"><?= formatDate($n['created_at'], 'd M Y H:i') ?></span>
                </div>
                <p><?= e($n['message']) ?></p>
                <?php if ($n['link_url']): ?>
                <a href="<?= e($n['link_url']) ?>" class="btn btn-sm btn-outline">Open</a>
                <?php endif; ?>
                <?php if (!$n['is_read']): ?>
                <a href="?mark=<?= (int)$n['id'] ?>" class="btn btn-sm btn-link">Mark read</a>
                <?php endif; ?>
            </li>
            <?php endforeach; ?>
        </ul>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
