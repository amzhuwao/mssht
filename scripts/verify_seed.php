<?php
require_once __DIR__ . '/../includes/bootstrap.php';
$db = getDB();
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

$out = [];
function tableExists(PDO $db, string $table): bool
{
    try {
        $quoted = $db->quote($table);
        $row = $db->query('SHOW TABLES LIKE ' . $quoted)->fetchColumn();
        return (bool) $row;
    } catch (Throwable $e) {
        return false;
    }
}

$out['db'] = $db->query('SELECT DATABASE()')->fetchColumn();
$out['students'] = (int) $db->query("SELECT COUNT(*) AS c FROM students WHERE student_number LIKE 'SEED-STU-%'")->fetchColumn();
$out['classes'] = (int) $db->query("SELECT COUNT(*) AS c FROM classes WHERE join_code LIKE 'SEED%'")->fetchColumn();
$out['invoices'] = tableExists($db, 'invoices') ? (int) $db->query("SELECT COUNT(*) AS c FROM invoices WHERE invoice_number LIKE 'SEED-INV-%'")->fetchColumn() : 0;
$out['payments'] = tableExists($db, 'payments') ? (int) $db->query("SELECT COUNT(*) AS c FROM payments WHERE receipt_number LIKE 'SEED-RCT-%'")->fetchColumn() : 0;

// sample rows
$out['sample_students'] = $db->query("SELECT id, student_number, user_id, program_id, intake_id, enrollment_status FROM students WHERE student_number LIKE 'SEED-STU-%' ORDER BY id LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);
if (tableExists($db, 'invoices')) {
    $cols = $db->query('SHOW COLUMNS FROM invoices')->fetchAll(PDO::FETCH_ASSOC);
    $colNames = array_column($cols, 'Field');
    $amountCol = null;
    foreach ($cols as $c) {
        $t = strtolower($c['Type']);
        if (strpos($t, 'int') !== false || strpos($t, 'decimal') !== false || strpos($t, 'float') !== false) {
            if ($c['Field'] !== 'id') {
                $amountCol = $c['Field'];
                break;
            }
        }
    }
    $selectCols = ['id','invoice_number','student_id'];
    if ($amountCol) $selectCols[] = $amountCol;
    if (in_array('status', $colNames, true)) $selectCols[] = 'status';
    $out['sample_invoices'] = $db->query('SELECT ' . implode(', ', $selectCols) . " FROM invoices WHERE invoice_number LIKE 'SEED-INV-%' ORDER BY id LIMIT 5")->fetchAll(PDO::FETCH_ASSOC);
} else {
    $out['sample_invoices'] = [];
}

echo json_encode($out, JSON_PRETTY_PRINT) . PHP_EOL;
