<?php
require_once __DIR__ . '/includes/bootstrap.php';
requireLogin();

$db = getDB();
$userId = (int)$_SESSION['user_id'];

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare('UPDATE user_profiles SET first_name = ?, last_name = ?, phone = ? WHERE user_id = ?')
       ->execute([trim($_POST['first_name']), trim($_POST['last_name']), trim($_POST['phone'] ?? ''), $userId]);
    if (!empty($_POST['new_password'])) {
        $hash = password_hash($_POST['new_password'], PASSWORD_DEFAULT);
        $db->prepare('UPDATE users SET password_hash = ? WHERE id = ?')->execute([$hash, $userId]);
    }
    $stmt = $db->prepare('SELECT u.*, p.first_name, p.last_name, p.phone FROM users u JOIN user_profiles p ON p.user_id = u.id WHERE u.id = ?');
    $stmt->execute([$userId]);
    $_SESSION['user'] = $stmt->fetch();
    flash('success', 'Profile updated.');
    redirect(url('profile.php'));
}

$user = currentUser();
$pageTitle = 'My Profile';
$currentModule = '';
require_once __DIR__ . '/includes/header.php';
?>

<div class="card" style="max-width:560px;">
    <div class="card-header"><h2>Profile</h2></div>
    <div class="card-body">
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-row">
                <div class="form-group"><label>First Name</label><input name="first_name" value="<?= e($user['first_name'] ?? '') ?>" required></div>
                <div class="form-group"><label>Last Name</label><input name="last_name" value="<?= e($user['last_name'] ?? '') ?>" required></div>
            </div>
            <div class="form-group"><label>Email</label><input value="<?= e($user['email']) ?>" disabled></div>
            <div class="form-group"><label>Phone</label><input name="phone" value="<?= e($user['phone'] ?? '') ?>"></div>
            <div class="form-group"><label>Role</label><input value="<?= e(ROLES[$user['role']] ?? '') ?>" disabled></div>
            <hr style="margin:1.5rem 0;border-color:var(--color-border);">
            <div class="form-group"><label>New Password (leave blank to keep)</label><input type="password" name="new_password" minlength="8"></div>
            <button type="submit" class="btn btn-primary">Save Changes</button>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
