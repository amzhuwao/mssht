<?php
/**
 * Install mobile_tokens table for native app API auth.
 * Usage: php tools/install-migration-011.php
 */
require_once dirname(__DIR__) . '/config/database.php';

$sqlFile = dirname(__DIR__) . '/database/migrations/011_mobile_tokens.sql';
if (!is_file($sqlFile)) {
    fwrite(STDERR, "Missing $sqlFile\n");
    exit(1);
}

$db = getDB();
$sql = file_get_contents($sqlFile);
$db->exec($sql);
echo "Migration 011_mobile_tokens applied.\n";
