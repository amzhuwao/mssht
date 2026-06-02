<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();

echo "Creating program_modules pivot table if missing...\n";
$db->exec("CREATE TABLE IF NOT EXISTS program_modules (
    program_id INT UNSIGNED NOT NULL,
    module_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (program_id, module_id),
    INDEX (module_id),
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

echo "Migrating existing module links from modules.program_id into program_modules...\n";
$rows = $db->query('SELECT id, program_id FROM modules WHERE program_id IS NOT NULL AND program_id != 0')->fetchAll(PDO::FETCH_ASSOC);
$count = 0;
foreach ($rows as $r) {
    try {
        $stmt = $db->prepare('INSERT IGNORE INTO program_modules (program_id, module_id) VALUES (?, ?)');
        $stmt->execute([(int)$r['program_id'], (int)$r['id']]);
        $count += $stmt->rowCount();
    } catch (Exception $e) {
        // ignore
    }
}

echo "Inserted pivot rows: $count\n";
echo "Migration complete. Note: modules.program_id left unchanged for backward compatibility.\n";

return 0;

