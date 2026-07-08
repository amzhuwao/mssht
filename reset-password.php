<?php
require_once __DIR__ . '/includes/bootstrap.php';

$token = $_GET['token'] ?? $_POST['token'] ?? '';
$error = '';
$valid = false;
$userId = null;
$userRole = null;

if ($token) {
    try {
        $row = getPasswordResetUserId($token);
        if ($row) {
            $valid = true;
            $userId = (int) $row['user_id'];
            $userRole = $row['role'];
        }
    } catch (Exception $e) {
        $error = 'Password reset is not configured.';
    }
}

$isStudent = $userRole === 'student';
$loginUrl = $isStudent ? url('student-login.php') : url('login.php');

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '') && $valid) {
    $pass = $_POST['password'] ?? '';
    if (strlen($pass) < 8) {
        $error = 'Password must be at least 8 characters.';
    } elseif ($pass !== ($_POST['password_confirm'] ?? '')) {
        $error = 'Passwords do not match.';
    } else {
        $db = getDB();
        $hash = password_hash($pass, PASSWORD_DEFAULT);
        $db->prepare('UPDATE users SET password_hash = ?, must_change_password = 0 WHERE id = ?')->execute([$hash, $userId]);
        $db->prepare('UPDATE password_resets SET used_at = NOW() WHERE token = ?')->execute([$token]);
        auditLog('password_reset', $isStudent ? 'student' : 'user', $userId);
        flash('success', 'Password updated. You can now sign in.');
        redirect($loginUrl);
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set New Password | <?= e(APP_NAME) ?></title>
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <link rel="stylesheet" href="<?= asset('css/auth.css') ?>">
</head>
<body class="auth-body <?= $isStudent ? 'auth-body-student' : '' ?>">
    <div class="auth-container">
        <div class="auth-card <?= $isStudent ? 'auth-card-student' : '' ?>">
            <h1>New password</h1>
            <?php if (!$valid && !$error): ?>
            <p class="alert alert-danger">Invalid or expired reset link.</p>
            <p class="auth-footer"><a href="<?= e($loginUrl) ?>">&larr; Back to login</a></p>
            <?php else: ?>
            <?php if ($error): ?><p class="alert alert-danger"><?= e($error) ?></p><?php endif; ?>
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <input type="hidden" name="token" value="<?= e($token) ?>">
                <div class="form-group"><label>New password</label><input type="password" name="password" minlength="8" required></div>
                <div class="form-group"><label>Confirm</label><input type="password" name="password_confirm" minlength="8" required></div>
                <button type="submit" class="btn btn-primary btn-block">Update password</button>
            </form>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>
