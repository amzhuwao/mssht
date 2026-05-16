<?php
require_once dirname(__DIR__) . '/config/app.php';
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/includes/helpers.php';
require_once dirname(__DIR__) . '/includes/student-auth.php';

$db = getDB();

echo "=== MSSHT Student Portal Diagnostics ===\n\n";

// Check column
$cols = $db->query("SHOW COLUMNS FROM users LIKE 'must_change_password'")->fetch();
echo 'must_change_password column: ' . ($cols ? "YES\n" : "MISSING - run database/migrations/001_student_portal.sql\n");

$students = $db->query(
    'SELECT s.id, s.student_number, s.user_id, s.enrollment_status,
            u.email, u.status AS user_status, u.role
     FROM students s
     LEFT JOIN users u ON u.id = s.user_id
     ORDER BY s.id DESC LIMIT 10'
)->fetchAll();

echo "\nRecent students:\n";
if (empty($students)) {
    echo "  (none - approve an application first)\n";
} else {
    foreach ($students as $s) {
        $portal = $s['user_id'] ? 'YES' : 'NO';
        $temp = $s['user_id'] ? generateStudentTempPassword($s['student_number']) : 'n/a';
        echo "  {$s['student_number']} | portal: {$portal} | enroll: {$s['enrollment_status']} | email: " . ($s['email'] ?? '-') . " | temp pass: {$temp}\n";
    }
}

echo "\nDone.\n";
