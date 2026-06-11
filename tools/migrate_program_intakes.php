<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();

echo "Creating program_intakes pivot table if missing...\n";
$db->exec("CREATE TABLE IF NOT EXISTS program_intakes (
    program_id INT UNSIGNED NOT NULL,
    intake_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (program_id, intake_id),
    INDEX (intake_id),
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    FOREIGN KEY (intake_id) REFERENCES intakes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

echo "Migration complete.\n";

return 0;
