<?php
require_once __DIR__ . '/../includes/bootstrap.php';

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from the command line.\n");
    exit(1);
}

$db = getDB();
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$filename = null;
foreach ($argv as $arg) {
    if (str_starts_with($arg, '--name=')) {
        $filename = substr($arg, 7);
    }
}

$result = backupDatabase($db, $filename ?: null);
echo "Backup created: {$result['path']}\n";
echo "Size: {$result['size']} bytes\n";
