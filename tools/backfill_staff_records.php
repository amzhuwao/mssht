<?php
require_once __DIR__ . '/../includes/bootstrap.php';

$db = getDB();
$roleMap = [
    'super_admin' => ['prefix' => 'SA', 'department' => 'Administration', 'position' => 'System Administrator'],
    'registrar' => ['prefix' => 'SR', 'department' => 'Academic Registry', 'position' => 'Registrar'],
    'finance' => ['prefix' => 'SF', 'department' => 'Finance', 'position' => 'Finance Officer'],
    'lecturer' => ['prefix' => 'SL', 'department' => 'Academics', 'position' => 'Lecturer'],
    'hod' => ['prefix' => 'SH', 'department' => 'Academics', 'position' => 'HOD / Dean'],
    'librarian' => ['prefix' => 'LB', 'department' => 'Library', 'position' => 'Librarian'],
    'external_examiner' => ['prefix' => 'EX', 'department' => 'Academic Affairs', 'position' => 'External Examiner'],
];

$dryRun = in_array('--dry-run', $argv, true);
$apply = in_array('--apply', $argv, true) || !$dryRun;

$selectedRoles = array_keys($roleMap);
$placeholders = implode(',', array_fill(0, count($selectedRoles), '?'));
$users = $db->prepare("SELECT u.id, u.email, u.role, p.first_name, p.last_name
    FROM users u
    LEFT JOIN user_profiles p ON p.user_id = u.id
    WHERE u.role IN ($placeholders)
    ORDER BY u.id");
$users->execute($selectedRoles);
$rows = $users->fetchAll();

$existingStmt = $db->prepare('SELECT id FROM staff WHERE user_id = ?');
$insertStmt = $db->prepare('INSERT INTO staff (user_id, staff_number, department, position, hire_date) VALUES (?, ?, ?, ?, CURDATE())');
$created = [];

foreach ($rows as $row) {
    $existingStmt->execute([$row['id']]);
    if ($existingStmt->fetchColumn()) {
        continue;
    }

    $roleMeta = $roleMap[$row['role']] ?? null;
    if ($roleMeta === null) {
        continue;
    }

    $staffNumber = generateRef($roleMeta['prefix']);
    $created[] = [
        'user_id' => $row['id'],
        'email' => $row['email'],
        'role' => $row['role'],
        'staff_number' => $staffNumber,
        'department' => $roleMeta['department'],
        'position' => $roleMeta['position'],
    ];

    if ($apply) {
        $insertStmt->execute([$row['id'], $staffNumber, $roleMeta['department'], $roleMeta['position']]);
    }
}

echo $apply ? 'Applied' : 'Dry run';
echo ' staff backfill.\n';
echo 'Matched users: ' . count($rows) . "\n";
echo 'Created staff rows: ' . count($created) . "\n";

foreach ($created as $item) {
    echo sprintf(
        "%s | %s | %s | %s\n",
        $item['email'],
        $item['role'],
        $item['staff_number'],
        $item['position']
    );
}
