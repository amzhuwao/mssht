<?php
require_once dirname(__DIR__) . '/config/app.php';
require_once dirname(__DIR__) . '/config/database.php';

try {
    $pdo = new PDO('mysql:host=' . DB_HOST . ';charset=' . DB_CHARSET, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
    $sql = file_get_contents(dirname(__DIR__) . '/database/schema.sql');
    $pdo->exec($sql);
    $hash = password_hash('Admin@123', PASSWORD_DEFAULT);
    $pdo->exec('USE ' . DB_NAME);
    $pdo->prepare('UPDATE users SET password_hash = ? WHERE email = ?')->execute([$hash, 'admin@mssht.ac.zw']);
    echo "Database installed successfully.\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
