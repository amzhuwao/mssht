<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

try {
    // Force all programs to use duration_months as duration_value and set unit to months
    $affected = $db->exec("UPDATE programs SET duration_value = COALESCE(duration_months, duration_value, 0), duration_unit = 'months'");
    echo "Forced update rows: " . ($affected === false ? 0 : $affected) . "\n\n";

    $stmt = $db->query("SELECT id, code, duration_months, duration_value, duration_unit FROM programs ORDER BY id");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($rows as $r) {
        echo json_encode($r, JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE) . "\n";
    }
} catch (Throwable $e) {
    fwrite(STDERR, 'Forced conversion failed: ' . $e->getMessage() . "\n");
    exit(1);
}
