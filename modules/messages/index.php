<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('messages');

$pageTitle = 'Communication';
$currentModule = 'messages';
$db = getDB();
$userId = (int)$_SESSION['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare('INSERT INTO messages (sender_id, recipient_id, subject, body) VALUES (?, ?, ?, ?)')
       ->execute([$userId, (int)$_POST['recipient_id'], trim($_POST['subject']), trim($_POST['body'])]);
    flash('success', 'Message sent.');
    redirect(moduleUrl('messages'));
}

$messages = $db->prepare(
    'SELECT m.*, CONCAT(p.first_name," ",p.last_name) AS sender_name
     FROM messages m JOIN users u ON u.id = m.sender_id
     JOIN user_profiles p ON p.user_id = u.id
     WHERE m.recipient_id = ? ORDER BY m.created_at DESC LIMIT 30'
);
$messages->execute([$userId]);
$messages = $messages->fetchAll();

$users = $db->query(
    'SELECT u.id, p.first_name, p.last_name, u.role FROM users u
     JOIN user_profiles p ON p.user_id = u.id WHERE u.id != ' . $userId . " AND u.status = 'active'"
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Compose Message</h2></div>
        <div class="card-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <div class="form-group">
                    <label>To</label>
                    <select name="recipient_id" required>
                        <?php foreach ($users as $u): ?>
                        <option value="<?= $u['id'] ?>"><?= e($u['first_name'].' '.$u['last_name']) ?> (<?= e(ROLES[$u['role']] ?? $u['role']) ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group"><label>Subject</label><input name="subject" required></div>
                <div class="form-group"><label>Message</label><textarea name="body" rows="4" required></textarea></div>
                <button type="submit" class="btn btn-primary">Send</button>
            </form>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>Inbox</h2></div>
        <div class="card-body">
            <?php foreach ($messages as $m): ?>
            <div style="padding:.75rem 0;border-bottom:1px solid var(--color-border);<?= !$m['is_read']?'font-weight:600;':'' ?>">
                <strong><?= e($m['subject']) ?></strong>
                <small class="text-muted"> — from <?= e($m['sender_name']) ?>, <?= formatDate($m['created_at']) ?></small>
                <p style="margin-top:.25rem;font-size:.9rem;"><?= e(substr($m['body'],0,120)) ?>...</p>
            </div>
            <?php endforeach; ?>
            <?php if (empty($messages)): ?><p class="text-muted">No messages.</p><?php endif; ?>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
