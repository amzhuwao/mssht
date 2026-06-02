<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

try {
    $cols = $db->query("SHOW COLUMNS FROM programs")->fetchAll(PDO::FETCH_COLUMN, 0);
    $toAdd = [];
    if (!in_array('duration_value', $cols, true)) {
        $toAdd[] = "ADD COLUMN duration_value SMALLINT UNSIGNED DEFAULT 12";
    }
    if (!in_array('duration_unit', $cols, true)) {
        $toAdd[] = "ADD COLUMN duration_unit VARCHAR(10) DEFAULT 'months'";
    }

    if ($toAdd) {
        $sql = 'ALTER TABLE programs ' . implode(', ', $toAdd);
        $db->exec($sql);
        echo "Migration applied: " . implode(', ', $toAdd) . "\n";
    } else {
        echo "No migration needed; columns already present.\n";
    }
} catch (Throwable $e) {
    fwrite(STDERR, 'Migration failed: ' . $e->getMessage() . "\n");
    exit(1);
}
