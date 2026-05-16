<?php
require_once __DIR__ . '/includes/bootstrap.php';

if (isLoggedIn()) {
    redirect(url('dashboard.php'));
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!verifyCsrf($_POST['csrf'] ?? '')) {
        $error = 'Invalid request. Please try again.';
    } else {
        $identifier = trim($_POST['identifier'] ?? '');
        $password = $_POST['password'] ?? '';
        if (studentPortalLogin($identifier, $password)) {
            if (mustChangePassword()) {
                flash('info', 'Please set a new password to continue.');
                redirect(url('student-activate.php'));
            }
            flash('success', 'Welcome to your student portal!');
            redirect(url('dashboard.php'));
        }
        $error = studentPortalLoginFailure() ?? 'Invalid student ID/email or password.';
    }
}
$w = 'div';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Portal | <?= e(APP_NAME) ?></title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <link rel="stylesheet" href="<?= asset('css/auth.css') ?>">
</head>
<body class="auth-body auth-body-student">
    <<?= $w ?> class="auth-container">
        <<?= $w ?> class="auth-card auth-card-student">
            <<?= $w ?> class="auth-brand">
                <span class="brand-icon lg">M</span>
                <h1>Student Portal</h1>
                <p><?= e(APP_NAME) ?></p>
            </<?= $w ?>>
            <?php if ($error): ?>
            <<?= $w ?> class="alert alert-danger"><?= e($error) ?></<?= $w ?>>
            <?php endif; ?>
            <?php $flash = getFlash(); if ($flash): ?>
            <<?= $w ?> class="alert alert-<?= e($flash['type']) ?>"><?= e($flash['message']) ?></<?= $w ?>>
            <?php endif; ?>
            <form method="post" class="auth-form">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <<?= $w ?> class="form-group">
                    <label for="identifier">Student ID or Email</label>
                    <input type="text" id="identifier" name="identifier" required autofocus
                           value="<?= e($_POST['identifier'] ?? '') ?>"
                           placeholder="e.g. MSSHT26-00123 or you@email.com">
                </<?= $w ?>>
                <<?= $w ?> class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required placeholder="Enter password">
                </<?= $w ?>>
                <button type="submit" class="btn btn-primary btn-block">Sign In to Portal</button>
            </form>
            <p class="auth-footer">
                <a href="<?= url() ?>">&larr; Back to website</a>
                &nbsp;&middot;&nbsp;
                <a href="<?= url('login.php') ?>">Staff login</a>
            </p>
            <p class="auth-hint">Use your Student ID and password provided when your enrollment was approved.</p>
            <p class="auth-footer" style="margin-top:.5rem;"><a href="<?= url('student-forgot-password.php') ?>">Forgot password?</a></p>
        </<?= $w ?>>
    </<?= $w ?>>
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</body>
</html>
