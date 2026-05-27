<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();

$programId = $db->query('SELECT id FROM programs LIMIT 1')->fetchColumn();
$intakeId = $db->query('SELECT id FROM intakes LIMIT 1')->fetchColumn();
if (!$programId || !$intakeId) {
    echo "Could not find a program or intake. Please create one first.\n";
    exit(1);
}

$ref = generateRef('APP');
$notes = [
    'attendance_type' => 'full_time',
    'national_id' => 'SEED-TEST-1234',
    'first_choice' => $programId,
    'reviewer_notes' => 'Seeded test application',
];

$notesJson = json_encode($notes, JSON_UNESCAPED_UNICODE);

$stmt = $db->prepare('INSERT INTO applications (application_ref, program_id, intake_id, first_name, last_name, email, phone, previous_qualification, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)');
$stmt->execute([
    $ref,
    $programId,
    $intakeId,
    'Test',
    'Applicant',
    'test.applicant@example.com',
    '0777000000',
    'O-Level',
    $notesJson,
]);

$id = (int)$db->lastInsertId();

echo "Inserted test application with ID: $id and reference: $ref\n";
exit(0);
