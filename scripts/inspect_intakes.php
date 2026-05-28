<?php
require_once __DIR__ . '/../includes/bootstrap.php';
$db = getDB();
$rows = $db->query('SELECT id,name,academic_year,start_date FROM intakes ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);
echo json_encode($rows, JSON_PRETTY_PRINT) . PHP_EOL;
