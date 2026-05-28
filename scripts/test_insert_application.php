<?php
require_once __DIR__ . '/../includes/bootstrap.php';
$db = getDB();
try {
    $sql = "INSERT INTO applications (application_ref, program_id, intake_id, first_name, last_name, email, phone, gender, date_of_birth, address, previous_qualification, status, notes, reviewed_by, reviewed_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    $params = ['TEST-APP-DBG', 1, 1, 'Dbg', 'User', 'dbg@example.com', '555', 'male', '2000-01-01', 'addr', 'None', 'pending', 'note', null, null];
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    echo "Inserted id: " . $db->lastInsertId() . PHP_EOL;
} catch (Throwable $e) {
    echo "Error: " . $e->getMessage() . PHP_EOL;
    echo $e->getTraceAsString() . PHP_EOL;
}
