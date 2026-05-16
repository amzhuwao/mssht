<?php
require_once dirname(__DIR__) . '/config/app.php';
require_once dirname(__DIR__) . '/config/database.php';
$sql = file_get_contents(dirname(__DIR__) . '/database/migrations/005_finance_erp.sql');
$db = getDB();
foreach (preg_split('/;\s*\n/', $sql) as $stmt) {
    $stmt = trim($stmt);
    if ($stmt === '' || stripos($stmt, 'USE ') === 0) {
        continue;
    }
    try {
        $db->exec($stmt);
        echo "OK\n";
    } catch (PDOException $e) {
        echo 'SKIP/ERR: ' . substr($e->getMessage(), 0, 120) . "\n";
    }
}
echo "Done.\n";
