<?php
require_once __DIR__ . '/../includes/bootstrap.php';
$db = getDB();
echo "DB: " . $db->query('SELECT DATABASE()')->fetchColumn() . PHP_EOL;
