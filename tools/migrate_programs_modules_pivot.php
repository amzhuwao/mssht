<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();

echo "Creating program_modules pivot table if missing...\n";
$db->exec("CREATE TABLE IF NOT EXISTS program_modules (
    program_id INT UNSIGNED NOT NULL,
    module_id INT UNSIGNED NOT NULL,
    semester TINYINT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (program_id, module_id, semester),
    INDEX (module_id),
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

try {
    $db->exec("ALTER TABLE program_modules ADD COLUMN semester TINYINT UNSIGNED NOT NULL DEFAULT 1");
    echo "Added semester column to program_modules.\n";
} catch (Exception $e) {
    echo "semester column may already exist: " . $e->getMessage() . "\n";
}

// add per-attachment columns if missing
try {
    $db->exec("ALTER TABLE program_modules ADD COLUMN is_core TINYINT(1) NOT NULL DEFAULT 0");
    echo "Added is_core column to program_modules.\n";
} catch (Exception $e) {
    echo "is_core column may already exist: " . $e->getMessage() . "\n";
}
try {
    $db->exec("ALTER TABLE program_modules ADD COLUMN notes TEXT NULL");
    echo "Added notes column to program_modules.\n";
} catch (Exception $e) {
    echo "notes column may already exist: " . $e->getMessage() . "\n";
}
try {
    $db->exec("ALTER TABLE program_modules ADD COLUMN display_order SMALLINT NOT NULL DEFAULT 0");
    echo "Added display_order column to program_modules.\n";
} catch (Exception $e) {
    echo "display_order column may already exist: " . $e->getMessage() . "\n";
}

try {
    $db->exec("ALTER TABLE program_modules DROP PRIMARY KEY, ADD PRIMARY KEY (program_id, module_id, semester)");
    echo "Updated program_modules primary key.\n";
} catch (Exception $e) {
    echo "Primary key may already be updated: " . $e->getMessage() . "\n";
}

echo "Migrating existing module links from modules.program_id into program_modules...\n";
$rows = $db->query('SELECT id, program_id FROM modules WHERE program_id IS NOT NULL AND program_id != 0')->fetchAll(PDO::FETCH_ASSOC);
$count = 0;
foreach ($rows as $r) {
    try {
        $stmt = $db->prepare('INSERT IGNORE INTO program_modules (program_id, module_id, semester) VALUES (?, ?, 1)');
        $stmt->execute([(int)$r['program_id'], (int)$r['id']]);
        $count += $stmt->rowCount();
    } catch (Exception $e) {
        // ignore
    }
}

echo "Inserted pivot rows: $count\n";
// propagate is_core from modules table into pivot rows where applicable
try {
    $db->exec("UPDATE program_modules pm JOIN modules m ON m.id = pm.module_id SET pm.is_core = m.is_core WHERE pm.program_id = m.program_id");
    echo "Synchronized is_core from modules into program_modules where applicable.\n";
} catch (Exception $e) {
    echo "Could not synchronize is_core: " . $e->getMessage() . "\n";
}
echo "Migration complete. Note: modules.program_id left unchanged for backward compatibility.\n";

return 0;

