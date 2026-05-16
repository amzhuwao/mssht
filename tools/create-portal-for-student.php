<?php
/**
 * CLI: Create portal login for a student by student number
 * Usage: php tools/create-portal-for-student.php MSSHT2691699
 */
require_once dirname(__DIR__) . '/config/app.php';
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/includes/helpers.php';
require_once dirname(__DIR__) . '/includes/student-auth.php';

$number = $argv[1] ?? '';
if ($number === '') {
    echo "Usage: php tools/create-portal-for-student.php STUDENT_NUMBER\n";
    exit(1);
}

$db = getDB();
$stmt = $db->prepare('SELECT id FROM students WHERE student_number = ? OR UPPER(student_number) = UPPER(?)');
$stmt->execute([$number, $number]);
$id = (int) $stmt->fetchColumn();

if (!$id) {
    echo "Student not found: {$number}\n";
    exit(1);
}

$result = createStudentPortalAccount($id, true);
if (!$result) {
    echo "Failed to create portal account.\n";
    exit(1);
}

echo "Portal created for {$result['student_number']}\n";
echo "Email:    {$result['email']}\n";
echo "Password: {$result['temp_password']}\n";
