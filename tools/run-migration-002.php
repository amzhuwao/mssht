<?php
/**
 * Run classroom LMS migration: php tools/run-migration-002.php
 */
require_once dirname(__DIR__) . '/config/app.php';
require_once dirname(__DIR__) . '/config/database.php';

$sql = file_get_contents(dirname(__DIR__) . '/database/migrations/002_classroom_lms.sql');
// Split on semicolons for statements (skip USE)
$parts = preg_split('/;\s*\n/', $sql);
$db = getDB();
foreach ($parts as $stmt) {
    $stmt = trim($stmt);
    if ($stmt === '' || stripos($stmt, 'USE ') === 0) {
        continue;
    }
    try {
        $db->exec($stmt);
        echo "OK: " . substr(str_replace(["\n", "\r"], ' ', $stmt), 0, 60) . "...\n";
    } catch (PDOException $e) {
        if (str_contains($e->getMessage(), 'already exists') || str_contains($e->getMessage(), 'Duplicate')) {
            echo "SKIP (exists): " . substr($stmt, 0, 40) . "...\n";
        } else {
            echo "ERR: " . $e->getMessage() . "\n";
        }
    }
}
echo "Migration complete.\n";
