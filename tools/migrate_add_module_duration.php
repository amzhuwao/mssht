<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();

echo "Adding duration columns to modules table if missing...\n";

try {
    $db->exec("ALTER TABLE modules ADD COLUMN IF NOT EXISTS duration_value SMALLINT UNSIGNED DEFAULT 0");
    echo "Added duration_value column.\n";
} catch (Exception $e) {
    echo "duration_value column may already exist: " . $e->getMessage() . "\n";
}

try {
    $db->exec("ALTER TABLE modules ADD COLUMN IF NOT EXISTS duration_unit VARCHAR(10) DEFAULT 'hours'");
    echo "Added duration_unit column.\n";
} catch (Exception $e) {
    echo "duration_unit column may already exist: " . $e->getMessage() . "\n";
}

echo "Migration complete.\n";
return 0;
