<?php
require_once __DIR__ . '/includes/bootstrap.php';

if (isLoggedIn()) {
    redirect(url('dashboard.php'));
}

$message = '';
$success = false;
$showLink = false;
$resetLink = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $identifier = trim($_POST['identifier'] ?? '');
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT u.id, u.email, p.first_name, p.last_name
         FROM users u
         LEFT JOIN students s ON s.user_id = u.id
         LEFT JOIN user_profiles p ON p.user_id = u.id
         WHERE u.role = ? AND (LOWER(u.email) = LOWER(?) OR UPPER(s.student_number) = UPPER(?))'
    );
    $stmt->execute(['student', $identifier, $identifier]);
    $user = $stmt->fetch();

    $genericMsg = 'If an account exists for that Student ID or email, we have sent password reset instructions.';

    if ($user) {
        try {
            $token = createPasswordResetToken((int) $user['id']);
            $resetLink = url('reset-password.php') . '?token=' . $token;
            $name = trim(($user['first_name'] ?? '') . ' ' . ($user['last_name'] ?? '')) ?: 'Student';
            $result = sendPasswordResetEmail($user['email'], $name, $resetLink, 'student');

            $message = $genericMsg;
            $success = true;
            if (!$result['sent'] && mailShowFallbackLink()) {
                $showLink = true;
            }
        } catch (Exception $e) {
            $message = 'Password reset is not available. Please contact the registrar.';
        }
    } else {
        $message = $genericMsg;
        $success = true;
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password | <?= e(APP_NAME) ?></title>
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <link rel="stylesheet" href="<?= asset('css/auth.css') ?>">
</head>
<body class="auth-body auth-body-student">
    <div class="auth-container">
        <div class="auth-card auth-card-student">
            <h1>Reset password</h1>
            <p class="text-muted">Enter your Student ID or portal email.</p>
            <?php if ($message): ?>
            <div class="alert alert-<?= $success ? 'success' : 'danger' ?>"><?= e($message) ?></div>
            <?php if ($showLink && $resetLink): ?>
            <div class="alert alert-info">
                <strong>Email could not be sent.</strong> Use this link to reset your password:<br>
                <a href="<?= e($resetLink) ?>"><?= e($resetLink) ?></a>
            </div>
            <?php endif; ?>
            <?php endif; ?>
            <?php if (!$success): ?>
            <form method="post" class="auth-form">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <div class="form-group">
                    <label>Student ID or email</label>
                    <input type="text" name="identifier" required>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Send reset link</button>
            </form>
            <?php endif; ?>
            <p class="auth-footer"><a href="<?= url('student-login.php') ?>">&larr; Back to login</a></p>
        </div>
    </div>
</body>
</html>
