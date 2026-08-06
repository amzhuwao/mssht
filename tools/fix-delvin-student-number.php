<?php
/**
 * Remap Delvin Mafura (and optionally other legacy MSSHT* IDs) to official MYYYYNNNN format.
 *
 * Usage:
 *   php tools/fix-delvin-student-number.php
 *   php tools/fix-delvin-student-number.php --apply
 *   php tools/fix-delvin-student-number.php --all-mssht --apply
 */

require_once dirname(__DIR__) . '/config/app.php';
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/includes/helpers.php';
require_once dirname(__DIR__) . '/includes/app-settings.php';
require_once dirname(__DIR__) . '/includes/student-auth.php';

$options = getopt('', ['apply', 'all-mssht', 'number::']);
$apply = array_key_exists('apply', $options);
$allMssht = array_key_exists('all-mssht', $options);
$forcedNumber = isset($options['number']) ? strtoupper(trim((string) $options['number'])) : '';

$db = getDB();

$targets = [];
if ($allMssht) {
    $targets = $db->query(
        "SELECT id, student_number, first_name, last_name, user_id
         FROM students
         WHERE student_number LIKE 'MSSHT%'
         ORDER BY id"
    )->fetchAll(PDO::FETCH_ASSOC);
} else {
    $stmt = $db->prepare(
        "SELECT id, student_number, first_name, last_name, user_id
         FROM students
         WHERE student_number LIKE 'MSSHT%'
            OR (LOWER(last_name) IN ('mafura', 'mafara') AND LOWER(first_name) LIKE 'delvin%')
         ORDER BY
            CASE WHEN LOWER(last_name) IN ('mafura', 'mafara') THEN 0 ELSE 1 END,
            id
         LIMIT 5"
    );
    $stmt->execute();
    $targets = $stmt->fetchAll(PDO::FETCH_ASSOC);
}

if (!$targets) {
    echo "No matching student found (Delvin Mafura / MSSHT* legacy IDs).\n";
    exit(0);
}

echo ($apply ? "APPLY MODE\n" : "DRY RUN\n");
echo 'Targets: ' . count($targets) . PHP_EOL . PHP_EOL;

$plan = [];
$reservedNumbers = [];
foreach ($targets as $student) {
    $old = (string) $student['student_number'];
    if (preg_match('/^M\d{8}$/', $old)) {
        echo "SKIP already official  {$old}  {$student['first_name']} {$student['last_name']}\n";
        continue;
    }

    if ($forcedNumber !== '' && count($targets) === 1) {
        if (!preg_match('/^M\d{8}$/', $forcedNumber)) {
            fwrite(STDERR, "Invalid --number value. Expected MYYYYNNNN (e.g. M20260105).\n");
            exit(1);
        }
        $check = $db->prepare('SELECT id FROM students WHERE student_number = ? AND id <> ?');
        $check->execute([$forcedNumber, (int) $student['id']]);
        if ($check->fetch()) {
            fwrite(STDERR, "{$forcedNumber} is already in use.\n");
            exit(1);
        }
        $new = $forcedNumber;
    } else {
        // Dry-run peeks without consuming the sequence; apply allocates and persists.
        do {
            $new = $apply ? generateStudentNumber($db) : peekNextOfficialStudentNumber($db);
            if (!$apply && isset($reservedNumbers[$new])) {
                // Simulate advance for multi-row dry-run previews.
                if (preg_match('/^M(\d{4})(\d{4})$/', $new, $m)) {
                    $probe = 'M' . $m[1] . str_pad((string) (((int) $m[2]) + 1), 4, '0', STR_PAD_LEFT);
                    $reservedNumbers[$new] = true;
                    $new = $probe;
                }
            }
        } while (isset($reservedNumbers[$new]));
    }
    $reservedNumbers[$new] = true;

    $plan[] = [
        'id' => (int) $student['id'],
        'old' => $old,
        'new' => $new,
        'name' => trim(($student['first_name'] ?? '') . ' ' . ($student['last_name'] ?? '')),
        'user_id' => $student['user_id'] ? (int) $student['user_id'] : null,
    ];

    echo sprintf("  %-14s -> %-12s  %s\n", $old, $new, trim(($student['first_name'] ?? '') . ' ' . ($student['last_name'] ?? '')));
}

if (!$plan) {
    echo PHP_EOL . "Nothing to change.\n";
    exit(0);
}

if (!$apply) {
    echo PHP_EOL . "No changes written. Re-run with --apply to update.\n";
    exit(0);
}

foreach ($plan as $row) {
    $db->beginTransaction();
    try {
        $upd = $db->prepare('UPDATE students SET student_number = ? WHERE id = ?');
        $upd->execute([$row['new'], $row['id']]);

        // If portal still uses the derived temp password, refresh hash for the new ID.
        if ($row['user_id']) {
            $user = $db->prepare('SELECT id, must_change_password FROM users WHERE id = ?');
            $user->execute([$row['user_id']]);
            $u = $user->fetch(PDO::FETCH_ASSOC);
            if ($u && (int) ($u['must_change_password'] ?? 0) === 1) {
                $temp = generateStudentTempPassword($row['new']);
                $db->prepare('UPDATE users SET password_hash = ? WHERE id = ?')->execute([
                    password_hash($temp, PASSWORD_DEFAULT),
                    $row['user_id'],
                ]);
                echo "  portal temp password refreshed for {$row['new']}: {$temp}\n";
            }
        }

        $db->commit();
        echo "UPDATED  id={$row['id']}  {$row['old']} -> {$row['new']}  {$row['name']}\n";
    } catch (Throwable $e) {
        $db->rollBack();
        fwrite(STDERR, 'ERROR  ' . $row['old'] . ': ' . $e->getMessage() . PHP_EOL);
        exit(1);
    }
}

echo PHP_EOL . 'Done. Remapped ' . count($plan) . " student number(s).\n";
