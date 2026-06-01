<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

$tables = [
    'users',
    'students',
    'applications',
    'programs',
    'modules',
    'classes',
    'intakes',
    'fee_structures',
    'invoices',
    'payments',
    'attendance_records',
];

function tableExists(PDO $db, string $table): bool
{
    try {
        $stmt = $db->query("SHOW TABLES LIKE " . $db->quote($table));
        return (bool) $stmt->fetchColumn();
    } catch (Throwable $e) {
        return false;
    }
}

foreach ($tables as $table) {
    echo "-- " . $table . " --\n";
    if (!tableExists($db, $table)) {
        echo "(table missing)\n\n";
        continue;
    }

    $count = (int) $db->query("SELECT COUNT(*) FROM `{$table}`")->fetchColumn();
    echo "count: " . $count . "\n";

    if ($count > 0) {
        $stmt = $db->query("SELECT * FROM `{$table}` ORDER BY id DESC LIMIT 5");
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($rows as $r) {
            echo json_encode($r, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) . "\n";
        }
    }

    echo "\n";
}

echo "Inspection complete.\n";
