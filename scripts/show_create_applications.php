<?php
require_once __DIR__ . '/../includes/bootstrap.php';
$db = getDB();
$row = $db->query("SHOW CREATE TABLE applications")->fetch(PDO::FETCH_ASSOC);
if ($row) {
    echo $row['Create Table'] . PHP_EOL;
} else {
    echo "No create info\n";
}
