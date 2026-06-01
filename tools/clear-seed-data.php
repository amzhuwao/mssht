<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from the command line.\n");
    exit(1);
}

$db = getDB();
$db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

const SEED_APPLICATION_REF_PREFIX = 'SEED-APP-';
const SEED_STUDENT_NUMBER_PREFIX = 'SEED-STU-';
const SEED_STUDENT_EMAIL_DOMAIN = 'seed.mssht.test';
const SEED_STAFF_EMAIL_DOMAIN = 'seed-staff.mssht.test';
const SEED_PROGRAM_CODES = ['SC-HOSP-101', 'PC-CUL-201', 'DIP-TOUR-301', 'HND-HOSP-401'];
const SEED_MODULE_CODES = ['SC-HOSP-101-M1', 'SC-HOSP-101-M2', 'SC-HOSP-101-M3', 'SC-HOSP-101-M4', 'PC-CUL-201-M1', 'PC-CUL-201-M2', 'PC-CUL-201-M3', 'PC-CUL-201-M4', 'DIP-TOUR-301-M1', 'DIP-TOUR-301-M2', 'DIP-TOUR-301-M3', 'DIP-TOUR-301-M4', 'HND-HOSP-401-M1', 'HND-HOSP-401-M2', 'HND-HOSP-401-M3', 'HND-HOSP-401-M4'];
const SEED_INTAKE_NAMES = ['January 2026 Intake', 'May 2026 Intake', 'Seed January 2027 Intake', 'Seed May 2027 Intake'];
const SEED_ROOM_NAMES = ['Lecture Hall A', 'Computer Lab 1', 'Training Kitchen', 'Online Platform'];
const SEED_TEST_EMAIL = 'test.applicant@example.com';

function tableExists(PDO $db, string $table): bool
{
    try {
        $quoted = $db->quote($table);
        return (bool) $db->query('SHOW TABLES LIKE ' . $quoted)->fetchColumn();
    } catch (Throwable $e) {
        return false;
    }
}

function recordDelete(PDO $db, array &$summary, string $table, string $sql, array $params = []): void
{
    if (!tableExists($db, $table)) {
        return;
    }

    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $count = $stmt->rowCount();
    if ($count > 0) {
        $summary[$table] = ($summary[$table] ?? 0) + $count;
    }
}

function deleteIn(PDO $db, array &$summary, string $table, string $column, array $values): void
{
    if ($values === [] || !tableExists($db, $table)) {
        return;
    }

    $placeholders = implode(',', array_fill(0, count($values), '?'));
    recordDelete($db, $summary, $table, 'DELETE FROM `' . $table . '` WHERE `' . $column . '` IN (' . $placeholders . ')', array_values($values));
}

function deleteLike(PDO $db, array &$summary, string $table, string $column, string $pattern): void
{
    if (!tableExists($db, $table)) {
        return;
    }

    recordDelete($db, $summary, $table, 'DELETE FROM `' . $table . '` WHERE `' . $column . '` LIKE ?', [$pattern]);
}

function seedPatterns(PDO $db): array
{
    $seedUsers = [];
    foreach ([SEED_STUDENT_EMAIL_DOMAIN, SEED_STAFF_EMAIL_DOMAIN] as $domain) {
        $stmt = $db->prepare('SELECT id FROM users WHERE email LIKE ?');
        $stmt->execute(['%@' . $domain]);
        $seedUsers = array_merge($seedUsers, $stmt->fetchAll(PDO::FETCH_COLUMN) ?: []);
    }

    $seedUsers[] = $db->query('SELECT id FROM users WHERE email = ' . $db->quote(SEED_TEST_EMAIL))->fetchColumn() ?: null;
    $seedUsers = array_values(array_filter(array_unique(array_map('intval', $seedUsers))));

    $seedApplicationsStmt = $db->prepare('SELECT id FROM applications WHERE application_ref LIKE ? OR email LIKE ? OR notes LIKE ? OR email = ?');
    $seedApplicationsStmt->execute([
        SEED_APPLICATION_REF_PREFIX . '%',
        '%@' . SEED_STUDENT_EMAIL_DOMAIN,
        '%"seed":true%',
        SEED_TEST_EMAIL,
    ]);
    $seedApplications = array_values(array_filter(array_unique(array_map('intval', $seedApplicationsStmt->fetchAll(PDO::FETCH_COLUMN) ?: []))));

    $seedStudentsStmt = $db->prepare('SELECT id FROM students WHERE student_number LIKE ?');
    $seedStudentsStmt->execute([SEED_STUDENT_NUMBER_PREFIX . '%']);
    $seedStudents = array_values(array_filter(array_unique(array_map('intval', $seedStudentsStmt->fetchAll(PDO::FETCH_COLUMN) ?: []))));

    if ($seedApplications !== [] && tableExists($db, 'students')) {
        $placeholders = implode(',', array_fill(0, count($seedApplications), '?'));
        $stmt = $db->prepare('SELECT id FROM students WHERE application_id IN (' . $placeholders . ')');
        $stmt->execute($seedApplications);
        $seedStudents = array_values(array_filter(array_unique(array_merge($seedStudents, array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN) ?: [])))));
    }

    $seedProgramsStmt = $db->prepare('SELECT id FROM programs WHERE code IN (' . implode(',', array_fill(0, count(SEED_PROGRAM_CODES), '?')) . ')');
    $seedProgramsStmt->execute(SEED_PROGRAM_CODES);
    $seedPrograms = array_values(array_filter(array_unique(array_map('intval', $seedProgramsStmt->fetchAll(PDO::FETCH_COLUMN) ?: []))));

    $seedModulesStmt = $db->prepare('SELECT id FROM modules WHERE code IN (' . implode(',', array_fill(0, count(SEED_MODULE_CODES), '?')) . ')');
    $seedModulesStmt->execute(SEED_MODULE_CODES);
    $seedModules = array_values(array_filter(array_unique(array_map('intval', $seedModulesStmt->fetchAll(PDO::FETCH_COLUMN) ?: []))));

    $seedClassesStmt = $db->prepare('SELECT id FROM classes WHERE name LIKE ? OR join_code LIKE ?');
    $seedClassesStmt->execute(['Seed %', 'SEED-%']);
    $seedClasses = array_values(array_filter(array_unique(array_map('intval', $seedClassesStmt->fetchAll(PDO::FETCH_COLUMN) ?: []))));

    return [
        'users' => $seedUsers,
        'applications' => $seedApplications,
        'students' => $seedStudents,
        'programs' => $seedPrograms,
        'modules' => $seedModules,
        'classes' => $seedClasses,
    ];
}

function clearSeedData(PDO $db): array
{
    $summary = [];
    $ids = seedPatterns($db);

    $db->beginTransaction();
    $fkDisabled = false;

    try {
        $db->exec('SET FOREIGN_KEY_CHECKS=0');
        $fkDisabled = true;

        deleteIn($db, $summary, 'application_documents', 'application_id', $ids['applications']);
        deleteIn($db, $summary, 'student_documents', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'module_registrations', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'attendance_records', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'marks', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'class_submissions', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'finance_holds', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'sponsor_students', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'graduations', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'placement_logbooks', 'placement_id', collectParentIds($db, 'placements', 'student_id', $ids['students']));
        deleteIn($db, $summary, 'placements', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'library_borrowings', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'assignments', 'module_id', $ids['modules']);
        deleteIn($db, $summary, 'assessments', 'module_id', $ids['modules']);
        deleteIn($db, $summary, 'attendance_sessions', 'module_id', $ids['modules']);
        deleteIn($db, $summary, 'stream_comments', 'post_id', collectParentIds($db, 'stream_posts', 'class_id', $ids['classes']));
        deleteIn($db, $summary, 'class_submissions', 'class_assignment_id', collectParentIds($db, 'class_assignments', 'class_id', $ids['classes']));
        deleteIn($db, $summary, 'class_rubrics', 'class_assignment_id', collectParentIds($db, 'class_assignments', 'class_id', $ids['classes']));
        deleteIn($db, $summary, 'class_assignments', 'class_id', $ids['classes']);
        deleteIn($db, $summary, 'class_topics', 'class_id', $ids['classes']);
        deleteIn($db, $summary, 'class_calendar_events', 'class_id', $ids['classes']);
        deleteIn($db, $summary, 'class_members', 'class_id', $ids['classes']);
        deleteIn($db, $summary, 'stream_posts', 'class_id', $ids['classes']);
        deleteIn($db, $summary, 'user_notifications', 'user_id', $ids['users']);
        deleteIn($db, $summary, 'notifications', 'user_id', $ids['users']);
        deleteIn($db, $summary, 'password_resets', 'user_id', $ids['users']);
        deleteIn($db, $summary, 'messages', 'sender_id', $ids['users']);
        deleteIn($db, $summary, 'messages', 'recipient_id', $ids['users']);
        deleteIn($db, $summary, 'audit_logs', 'user_id', $ids['users']);
        deleteLike($db, $summary, 'audit_logs', 'action', '%seed%');

        deleteIn($db, $summary, 'invoice_lines', 'invoice_id', collectIdsFromTable($db, 'invoices', 'invoice_number', 'SEED-INV-%'));
        deleteIn($db, $summary, 'payments', 'invoice_id', collectIdsFromTable($db, 'invoices', 'invoice_number', 'SEED-INV-%'));
        deleteIn($db, $summary, 'installment_schedule', 'plan_id', collectIdsFromTable($db, 'installment_plans', 'title', 'Seed %'));
        deleteIn($db, $summary, 'installment_plans', 'student_id', $ids['students']);
        deleteIn($db, $summary, 'payable_payments', 'payable_id', collectIdsFromTable($db, 'payables', 'bill_number', 'SEED-%'));
        deleteIn($db, $summary, 'journal_lines', 'journal_id', collectIdsFromTable($db, 'journal_entries', 'entry_number', 'SEED-%'));
        deleteIn($db, $summary, 'bank_transactions', 'bank_account_id', collectIdsFromTable($db, 'bank_accounts', 'name', 'Seed %'));
        deleteIn($db, $summary, 'goods_receipts', 'po_id', collectIdsFromTable($db, 'purchase_orders', 'po_number', 'SEED-%'));

        deleteLike($db, $summary, 'applications', 'application_ref', SEED_APPLICATION_REF_PREFIX . '%');
        deleteLike($db, $summary, 'applications', 'email', '%@' . SEED_STUDENT_EMAIL_DOMAIN);
        deleteLike($db, $summary, 'applications', 'notes', '%"seed":true%');
        deleteLike($db, $summary, 'students', 'student_number', SEED_STUDENT_NUMBER_PREFIX . '%');
        deleteLike($db, $summary, 'users', 'email', '%@' . SEED_STUDENT_EMAIL_DOMAIN);
        deleteLike($db, $summary, 'users', 'email', '%@' . SEED_STAFF_EMAIL_DOMAIN);
        deleteLike($db, $summary, 'users', 'email', SEED_TEST_EMAIL);
        deleteLike($db, $summary, 'staff', 'staff_number', 'SR-%');
        deleteLike($db, $summary, 'staff', 'staff_number', 'SF-%');
        deleteLike($db, $summary, 'staff', 'staff_number', 'SL-%');
        deleteLike($db, $summary, 'classes', 'name', 'Seed %');
        deleteLike($db, $summary, 'classes', 'join_code', 'SEED-%');
        deleteLike($db, $summary, 'programs', 'code', 'SC-HOSP-101');
        deleteLike($db, $summary, 'programs', 'code', 'PC-CUL-201');
        deleteLike($db, $summary, 'programs', 'code', 'DIP-TOUR-301');
        deleteLike($db, $summary, 'programs', 'code', 'HND-HOSP-401');
        deleteLike($db, $summary, 'modules', 'code', 'SC-HOSP-101-M%');
        deleteLike($db, $summary, 'modules', 'code', 'PC-CUL-201-M%');
        deleteLike($db, $summary, 'modules', 'code', 'DIP-TOUR-301-M%');
        deleteLike($db, $summary, 'modules', 'code', 'HND-HOSP-401-M%');
        deleteIn($db, $summary, 'fee_structures', 'program_id', $ids['programs']);
        deleteLike($db, $summary, 'fee_structures', 'description', 'Seed tuition %');
        deleteLike($db, $summary, 'finance_sponsors', 'code', 'SEED-SP-%');
        deleteLike($db, $summary, 'suppliers', 'code', 'SEED-%');
        deleteLike($db, $summary, 'bank_accounts', 'name', 'Seed %');
        deleteLike($db, $summary, 'financial_periods', 'name', 'Seed %');
        deleteLike($db, $summary, 'invoices', 'invoice_number', 'SEED-INV-%');
        deleteLike($db, $summary, 'payables', 'bill_number', 'SEED-%');
        deleteLike($db, $summary, 'purchase_orders', 'po_number', 'SEED-%');
        deleteLike($db, $summary, 'purchase_requisitions', 'req_number', 'SEED-%');
        deleteLike($db, $summary, 'journal_entries', 'entry_number', 'SEED-%');
        deleteLike($db, $summary, 'rooms', 'name', 'Lecture Hall A');
        deleteLike($db, $summary, 'rooms', 'name', 'Computer Lab 1');
        deleteLike($db, $summary, 'rooms', 'name', 'Training Kitchen');
        deleteLike($db, $summary, 'rooms', 'name', 'Online Platform');
        deleteLike($db, $summary, 'intakes', 'name', 'January 2026 Intake');
        deleteLike($db, $summary, 'intakes', 'name', 'May 2026 Intake');
        deleteLike($db, $summary, 'intakes', 'name', 'Seed January 2027 Intake');
        deleteLike($db, $summary, 'intakes', 'name', 'Seed May 2027 Intake');

        deleteIn($db, $summary, 'modules', 'program_id', $ids['programs']);
        deleteIn($db, $summary, 'programs', 'id', $ids['programs']);
        deleteIn($db, $summary, 'rooms', 'id', collectIdsFromExactNames($db, 'rooms', 'name', SEED_ROOM_NAMES));

        deleteLike($db, $summary, 'classes', 'name', 'Seed %');
        deleteLike($db, $summary, 'classes', 'join_code', 'SEED-%');

        deleteIn($db, $summary, 'users', 'id', $ids['users']);
        deleteIn($db, $summary, 'applications', 'id', $ids['applications']);
        deleteIn($db, $summary, 'students', 'id', $ids['students']);

        $db->commit();
    } catch (Throwable $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        throw $e;
    } finally {
        if ($fkDisabled) {
            $db->exec('SET FOREIGN_KEY_CHECKS=1');
        }
    }

    return $summary;
}

function collectParentIds(PDO $db, string $table, string $column, array $values): array
{
    if ($values === [] || !tableExists($db, $table)) {
        return [];
    }

    $placeholders = implode(',', array_fill(0, count($values), '?'));
    $stmt = $db->prepare('SELECT id FROM ' . $table . ' WHERE ' . $column . ' IN (' . $placeholders . ')');
    $stmt->execute(array_values($values));
    return array_values(array_filter(array_unique(array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN) ?: []))));
}

function collectIdsFromTable(PDO $db, string $table, string $column, string $pattern): array
{
    if (!tableExists($db, $table)) {
        return [];
    }

    $stmt = $db->prepare('SELECT id FROM ' . $table . ' WHERE ' . $column . ' LIKE ?');
    $stmt->execute([$pattern]);
    return array_values(array_filter(array_unique(array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN) ?: []))));
}

function collectIdsFromExactNames(PDO $db, string $table, string $column, array $names): array
{
    if ($names === [] || !tableExists($db, $table)) {
        return [];
    }

    $placeholders = implode(',', array_fill(0, count($names), '?'));
    $stmt = $db->prepare('SELECT id FROM ' . $table . ' WHERE ' . $column . ' IN (' . $placeholders . ')');
    $stmt->execute(array_values($names));
    return array_values(array_filter(array_unique(array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN) ?: []))));
}

try {
    $summary = clearSeedData($db);
    $total = array_sum($summary);

    if ($total === 0) {
        echo "No seed data was found.\n";
        exit(0);
    }

    echo "Seed data cleared successfully.\n";
    foreach ($summary as $table => $count) {
        echo $table . ': ' . $count . "\n";
    }
    echo 'Total rows removed: ' . $total . "\n";
} catch (Throwable $e) {
    fwrite(STDERR, 'Seed data cleanup failed: ' . $e->getMessage() . "\n");
    exit(1);
}
