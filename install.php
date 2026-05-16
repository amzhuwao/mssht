<?php
/**
 * MSSHT Database Installer
 * Run once: http://localhost/mssht/install.php
 */
require_once __DIR__ . '/config/app.php';
require_once __DIR__ . '/config/database.php';

$message = '';
$success = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $pdo = new PDO(
            'mysql:host=' . DB_HOST . ';charset=' . DB_CHARSET,
            DB_USER,
            DB_PASS,
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
        );

        $sql = file_get_contents(__DIR__ . '/database/schema.sql');
        $pdo->exec($sql);

        // Update admin password
        $hash = password_hash('Admin@123', PASSWORD_DEFAULT);
        $pdo->exec("USE " . DB_NAME);
        $stmt = $pdo->prepare('UPDATE users SET password_hash = ? WHERE email = ?');
        $stmt->execute([$hash, 'admin@mssht.ac.zw']);

        $message = 'Database installed successfully! You can now <a href="login.php">log in</a>.';
        $success = true;
    } catch (PDOException $e) {
        $message = 'Installation failed: ' . htmlspecialchars($e->getMessage());
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Install MSSHT</title>
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <link rel="stylesheet" href="<?= asset('css/auth.css') ?>">
</head>
<body class="auth-body">
    <div class="auth-container">
        <div class="auth-card">
            <h1>Install MSSHT</h1>
            <p>This will create the database and seed initial data.</p>
            <?php if ($message): ?>
            <div class="alert alert-<?= $success ? 'success' : 'danger' ?>"><?= $message ?></div>
            <?php endif; ?>
            <?php if (!$success): ?>
            <form method="post">
                <button type="submit" class="btn btn-primary btn-block">Install Database</button>
            </form>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>
