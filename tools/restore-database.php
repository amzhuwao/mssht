<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from the command line.\n");
    exit(1);
}

$db = getDB();
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$path = $argv[1] ?? '';
$resetExisting = true;
foreach ($argv as $arg) {
    if ($arg === '--no-reset') {
        $resetExisting = false;
    }
}

if ($path === '') {
    fwrite(STDERR, "Usage: php restore-database.php <backup.sql> [--no-reset]\n");
    exit(1);
}

$result = restoreDatabase($db, $path, $resetExisting);
echo "Backup restored from: {$result['path']}\n";
echo "Statements executed: {$result['executed']}\n";
