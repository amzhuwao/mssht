<?php
require_once __DIR__ . '/includes/bootstrap.php';
requireLogin();

if (!isStudentPortal()) {
    flash('warning', 'This page is for students only.');
    redirect(url('dashboard.php'));
}

if (!mustChangePassword()) {
    redirect(url('dashboard.php'));
}

$error = '';
$student = getCurrentStudent();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!verifyCsrf($_POST['csrf'] ?? '')) {
        $error = 'Invalid request.';
    } else {
        $password = $_POST['password'] ?? '';
        $confirm = $_POST['password_confirm'] ?? '';
        if (strlen($password) < 8) {
            $error = 'Password must be at least 8 characters.';
        } elseif ($password !== $confirm) {
            $error = 'Passwords do not match.';
        } else {
            $hash = password_hash($password, PASSWORD_DEFAULT);
            $db = getDB();
            $db->prepare('UPDATE users SET password_hash = ?, must_change_password = 0 WHERE id = ?')
               ->execute([$hash, $_SESSION['user_id']]);
            loadSessionUser((int) $_SESSION['user_id']);
            flash('success', 'Your password has been updated.');
            redirect(url('dashboard.php'));
        }
    }
}
$w = 'div';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Set Your Password | <?= e(APP_NAME) ?></title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <link rel="stylesheet" href="<?= asset('css/auth.css') ?>">
</head>
<body class="auth-body auth-body-student">
    <<?= $w ?> class="auth-container">
        <<?= $w ?> class="auth-card auth-card-student">
            <<?= $w ?> class="auth-brand">
                <span class="brand-icon lg">M</span>
                <h1>Set Your Password</h1>
                <p>Student ID: <strong><?= e($student['student_number'] ?? '') ?></strong></p>
            </<?= $w ?>>
            <?php if ($error): ?>
            <<?= $w ?> class="alert alert-danger"><?= e($error) ?></<?= $w ?>>
            <?php endif; ?>
            <p class="text-muted" style="margin-bottom:1rem;font-size:.9rem;">For security, choose a new password before using the portal.</p>
            <form method="post" class="auth-form">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <<?= $w ?> class="form-group">
                    <label for="password">New Password</label>
                    <input type="password" id="password" name="password" required minlength="8" autofocus>
                </<?= $w ?>>
                <<?= $w ?> class="form-group">
                    <label for="password_confirm">Confirm Password</label>
                    <input type="password" id="password_confirm" name="password_confirm" required minlength="8">
                </<?= $w ?>>
                <button type="submit" class="btn btn-primary btn-block">Save &amp; Continue</button>
            </form>
        </<?= $w ?>>
    </<?= $w ?>>
</body>
</html>
