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

const SEED_STUDENT_EMAIL_DOMAIN = 'seed.mssht.test';
const SEED_STAFF_EMAIL_DOMAIN = 'seed-staff.mssht.test';
const SEED_STUDENT_NUMBER_PREFIX = 'SEED-STU-';
const SEED_APPLICATION_PREFIX = 'SEED-APP-';
const SEED_CLASS_PREFIX = 'Seed ';
const SEED_CODE_PREFIX = 'SEED-';
const SEED_FINANCE_PREFIX = 'Seed ';
const SEED_PASSWORD = 'Seed@1234';

function tableExists(PDO $db, string $table): bool
{
    try {
        $quoted = $db->quote($table);
        $row = $db->query('SHOW TABLES LIKE ' . $quoted)->fetchColumn();
        return (bool) $row;
    } catch (Throwable $e) {
        return false;
    }
}

function fetchOne(PDO $db, string $sql, array $params = []): ?array
{
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch();
    return $row ?: null;
}

function fetchAllRows(PDO $db, string $sql, array $params = []): array
{
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

function execute(PDO $db, string $sql, array $params = []): void
{
    if (stripos($sql, 'INSERT INTO applications') !== false) {
        fwrite(STDOUT, "EXECUTE DEBUG SQL: " . $sql . "\nPARAMS: " . var_export($params, true) . "\n");
    }
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
}

function insertId(PDO $db, string $sql, array $params = []): int
{
    execute($db, $sql, $params);
    return (int) $db->lastInsertId();
}

function likeValue(string $value): string
{
    return $value;
}

function safeIndex(array $arr, int $i, $fallback = null)
{
    $n = count($arr);
    if ($n === 0) {
        return $fallback;
    }
    return $arr[$i % $n];
}

function ensureUser(PDO $db, string $email, string $role, string $firstName, string $lastName, ?string $phone = null, bool $mustChange = true): int
{
    $existing = fetchOne($db, 'SELECT id FROM users WHERE email = ?', [$email]);
    if ($existing) {
        $userId = (int) $existing['id'];
        execute($db, 'UPDATE users SET role = ?, status = ?, must_change_password = ? WHERE id = ?', [$role, 'active', $mustChange ? 1 : 0, $userId]);
        $profile = fetchOne($db, 'SELECT id FROM user_profiles WHERE user_id = ?', [$userId]);
        if ($profile) {
            execute($db, 'UPDATE user_profiles SET first_name = ?, last_name = ?, phone = ? WHERE user_id = ?', [$firstName, $lastName, $phone, $userId]);
        } else {
            execute($db, 'INSERT INTO user_profiles (user_id, first_name, last_name, phone) VALUES (?, ?, ?, ?)', [$userId, $firstName, $lastName, $phone]);
        }
        return $userId;
    }

    $hash = password_hash(SEED_PASSWORD, PASSWORD_DEFAULT);
    execute($db, 'INSERT INTO users (email, password_hash, role, status, must_change_password) VALUES (?, ?, ?, ?, ?)', [$email, $hash, $role, 'active', $mustChange ? 1 : 0]);
    $userId = (int) $db->lastInsertId();
    execute($db, 'INSERT INTO user_profiles (user_id, first_name, last_name, phone) VALUES (?, ?, ?, ?)', [$userId, $firstName, $lastName, $phone]);
    return $userId;
}

function ensureStaffRoleUser(PDO $db, string $role, string $slug, string $firstName, string $lastName, string $staffNumber, string $department, string $position): int
{
    $email = $slug . '@' . SEED_STAFF_EMAIL_DOMAIN;
    $userId = ensureUser($db, $email, $role, $firstName, $lastName, '+263770000000', true);

    if (tableExists($db, 'staff')) {
        $existing = fetchOne($db, 'SELECT id FROM staff WHERE user_id = ?', [$userId]);
        if (!$existing) {
            execute($db, 'INSERT INTO staff (user_id, staff_number, department, position, hire_date) VALUES (?, ?, ?, ?, ?)', [$userId, $staffNumber, $department, $position, '2025-01-15']);
        }
    }

    return $userId;
}

function ensureIntake(PDO $db, string $name, string $academicYear, string $startDate, string $endDate, string $status = 'open'): int
{
    $existing = fetchOne($db, 'SELECT id FROM intakes WHERE name = ? OR (academic_year = ? AND start_date = ?)', [$name, $academicYear, $startDate]);
    if ($existing) {
        return (int) $existing['id'];
    }

    return insertId($db, 'INSERT INTO intakes (name, academic_year, start_date, end_date, status) VALUES (?, ?, ?, ?, ?)', [$name, $academicYear, $startDate, $endDate, $status]);
}

function ensureProgramModules(PDO $db, int $programId, string $programCode, string $programName): array
{
    $modules = fetchAllRows($db, 'SELECT id, code, name FROM modules WHERE program_id = ? ORDER BY id', [$programId]);
    if (count($modules) >= 4) {
        return array_slice($modules, 0, 4);
    }

    $programShort = preg_replace('/^(Certificate in |Professional Certificate in |Diploma in |Higher National Diploma in )/i', '', $programName) ?: $programName;
    $templates = [
        ['Introduction to ' . $programShort, 1],
        ['Core Skills for ' . $programShort, 1],
        ['Applied Practice in ' . $programShort, 2],
        ['Industry Placement and Review', 2],
    ];

    $existingCodes = array_column($modules, 'code');
    foreach ($templates as $index => $template) {
        $code = $programCode . '-M' . ($index + 1);
        if (in_array($code, $existingCodes, true)) {
            continue;
        }
        execute($db, 'INSERT INTO modules (program_id, code, name, credits, semester, is_core) VALUES (?, ?, ?, ?, ?, ?)', [$programId, $code, $template[0], 6, $template[1], 1]);
    }

    return fetchAllRows($db, 'SELECT id, code, name FROM modules WHERE program_id = ? ORDER BY id', [$programId]);
}

function ensureFeeStructure(PDO $db, int $programId, ?int $intakeId, string $description, float $amount): int
{
    $existing = fetchOne($db, 'SELECT id FROM fee_structures WHERE program_id = ? AND intake_id <=> ? AND description = ?', [$programId, $intakeId, $description]);
    if ($existing) {
        return (int) $existing['id'];
    }

    return insertId($db, 'INSERT INTO fee_structures (program_id, intake_id, description, amount, allow_installments, fee_type, billing_model, currency, semester, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
        $programId,
        $intakeId,
        $description,
        $amount,
        1,
        'tuition',
        'per_semester',
        'USD',
        null,
        1,
    ]);
}

function ensureSponsor(PDO $db, string $code, string $name, string $type = 'corporate'): int
{
    $existing = fetchOne($db, 'SELECT id FROM finance_sponsors WHERE code = ?', [$code]);
    if ($existing) {
        return (int) $existing['id'];
    }

    return insertId($db, 'INSERT INTO finance_sponsors (code, name, sponsor_type, email, phone, billing_terms, credit_limit, currency, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', [
        $code,
        $name,
        $type,
        strtolower($code) . '@example.com',
        '+263778000000',
        'Seed test sponsor',
        50000,
        'USD',
        1,
    ]);
}

function ensureSupplier(PDO $db, string $code, string $name): int
{
    $existing = fetchOne($db, 'SELECT id FROM suppliers WHERE code = ?', [$code]);
    if ($existing) {
        return (int) $existing['id'];
    }

    return insertId($db, 'INSERT INTO suppliers (code, name, contact_person, email, phone, tax_number, bank_name, bank_account, is_active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', [
        $code,
        $name,
        'Seed Contact',
        strtolower($code) . '@example.com',
        '+263780000000',
        'TAX-' . substr($code, -4),
        'Seed Bank',
        '000' . random_int(100000, 999999),
        1,
    ]);
}

function ensureBankAccount(PDO $db, string $name, string $bankName, string $accountNumber, string $currency): int
{
    $existing = fetchOne($db, 'SELECT id FROM bank_accounts WHERE name = ? AND bank_name = ? AND account_number = ?', [$name, $bankName, $accountNumber]);
    if ($existing) {
        return (int) $existing['id'];
    }

    return insertId($db, 'INSERT INTO bank_accounts (name, bank_name, account_number, currency, opening_balance, current_balance, is_active) VALUES (?, ?, ?, ?, ?, ?, ?)', [$name, $bankName, $accountNumber, $currency, 25000, 25000, 1]);
}

function ensureFinancialPeriod(PDO $db, string $name, string $startDate, string $endDate): int
{
    $existing = fetchOne($db, 'SELECT id FROM financial_periods WHERE name = ?', [$name]);
    if ($existing) {
        return (int) $existing['id'];
    }

    return insertId($db, 'INSERT INTO financial_periods (name, start_date, end_date, is_closed, closed_at) VALUES (?, ?, ?, ?, ?)', [$name, $startDate, $endDate, 0, null]);
}

function ensureJournalEntry(PDO $db, string $entryNumber, string $entryDate, string $description, ?int $periodId, string $sourceType, ?int $sourceId, ?int $createdBy): int
{
    $existing = fetchOne($db, 'SELECT id FROM journal_entries WHERE entry_number = ?', [$entryNumber]);
    if ($existing) {
        return (int) $existing['id'];
    }

    return insertId($db, 'INSERT INTO journal_entries (entry_number, entry_date, description, period_id, source_type, source_id, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)', [$entryNumber, $entryDate, $description, $periodId, $sourceType, $sourceId, $createdBy]);
}

function ensureBankTransaction(PDO $db, int $bankAccountId, string $txnDate, string $description, ?string $reference, float $amount, string $txnType, ?int $matchedPaymentId): int
{
    $existing = fetchOne($db, 'SELECT id FROM bank_transactions WHERE bank_account_id = ? AND txn_date = ? AND description = ? AND amount = ?', [$bankAccountId, $txnDate, $description, $amount]);
    if ($existing) {
        return (int) $existing['id'];
    }

    return insertId($db, 'INSERT INTO bank_transactions (bank_account_id, txn_date, description, reference, amount, txn_type, matched_payment_id, is_reconciled) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [$bankAccountId, $txnDate, $description, $reference, $amount, $txnType, $matchedPaymentId, $matchedPaymentId ? 1 : 0]);
}

function cleanupSeedData(PDO $db): void
{
    $seedStudentUserIds = [];
    if (tableExists($db, 'users')) {
        $seedStudentUserIds = array_column(fetchAllRows($db, 'SELECT id FROM users WHERE email LIKE ?', ['%@' . SEED_STUDENT_EMAIL_DOMAIN]), 'id');
    }

    if (tableExists($db, 'classes')) {
        execute($db, 'DELETE FROM classes WHERE name LIKE ? OR join_code LIKE ?', [SEED_CLASS_PREFIX . '%', SEED_CODE_PREFIX . '%']);
    }

    if ($seedStudentUserIds && tableExists($db, 'class_members')) {
        $placeholders = implode(',', array_fill(0, count($seedStudentUserIds), '?'));
        execute($db, "DELETE FROM class_members WHERE user_id IN ($placeholders)", $seedStudentUserIds);
    }

    if (tableExists($db, 'users')) {
        execute($db, 'DELETE FROM users WHERE email LIKE ?', ['%@' . SEED_STUDENT_EMAIL_DOMAIN]);
    }

    if (tableExists($db, 'students')) {
        execute($db, 'DELETE FROM students WHERE student_number LIKE ?', [SEED_STUDENT_NUMBER_PREFIX . '%']);
    }

    if (tableExists($db, 'applications')) {
        execute($db, 'DELETE FROM applications WHERE application_ref LIKE ?', [SEED_APPLICATION_PREFIX . '%']);
    }

    foreach ([
        'module_registrations' => 'DELETE FROM module_registrations WHERE academic_year IN (?, ?)'
        ,
        'attendance_records' => 'DELETE FROM attendance_records WHERE student_id IN (SELECT id FROM students WHERE student_number LIKE ?)',
        'attendance_sessions' => 'DELETE FROM attendance_sessions WHERE created_by IN (SELECT id FROM users WHERE email LIKE ?)',
        'assessments' => 'DELETE FROM assessments WHERE module_id IN (SELECT id FROM modules WHERE code LIKE ?)',
        'marks' => 'DELETE FROM marks WHERE student_id IN (SELECT id FROM students WHERE student_number LIKE ?)',
        'class_submissions' => 'DELETE FROM class_submissions WHERE student_id IN (SELECT id FROM students WHERE student_number LIKE ?)',
        'placements' => 'DELETE FROM placements WHERE student_id IN (SELECT id FROM students WHERE student_number LIKE ?)',
        'graduations' => 'DELETE FROM graduations WHERE student_id IN (SELECT id FROM students WHERE student_number LIKE ?)',
        'finance_holds' => 'DELETE FROM finance_holds WHERE student_id IN (SELECT id FROM students WHERE student_number LIKE ?)',
        'sponsor_students' => 'DELETE FROM sponsor_students WHERE student_id IN (SELECT id FROM students WHERE student_number LIKE ?)',
        'invoice_lines' => 'DELETE FROM invoice_lines WHERE invoice_id IN (SELECT id FROM invoices WHERE invoice_number LIKE ?)',
        'invoices' => 'DELETE FROM invoices WHERE invoice_number LIKE ?',
        'payments' => 'DELETE FROM payments WHERE receipt_number LIKE ?',
        'installment_schedule' => 'DELETE FROM installment_schedule WHERE plan_id IN (SELECT id FROM installment_plans WHERE title LIKE ?)',
        'installment_plans' => 'DELETE FROM installment_plans WHERE title LIKE ?',
        'fee_structures' => 'DELETE FROM fee_structures WHERE description LIKE ?',
        'finance_sponsors' => 'DELETE FROM finance_sponsors WHERE code LIKE ?',
        'suppliers' => 'DELETE FROM suppliers WHERE code LIKE ?',
        'payable_payments' => 'DELETE FROM payable_payments WHERE payable_id IN (SELECT id FROM payables WHERE bill_number LIKE ?)',
        'payables' => 'DELETE FROM payables WHERE bill_number LIKE ?',
        'purchase_orders' => 'DELETE FROM purchase_orders WHERE po_number LIKE ?',
        'purchase_requisitions' => 'DELETE FROM purchase_requisitions WHERE req_number LIKE ?',
        'bank_transactions' => 'DELETE FROM bank_transactions WHERE description LIKE ?',
        'bank_accounts' => 'DELETE FROM bank_accounts WHERE name LIKE ?',
        'journal_lines' => 'DELETE FROM journal_lines WHERE journal_id IN (SELECT id FROM journal_entries WHERE entry_number LIKE ?)',
        'journal_entries' => 'DELETE FROM journal_entries WHERE entry_number LIKE ?',
        'financial_periods' => 'DELETE FROM financial_periods WHERE name LIKE ?',
        'fee_rules' => 'DELETE FROM fee_rules WHERE name LIKE ?',
        'modules' => 'DELETE FROM modules WHERE code LIKE ?',
        'intakes' => 'DELETE FROM intakes WHERE name LIKE ?',
        'rooms' => 'DELETE FROM rooms WHERE name LIKE ?',
    ] as $table => $sql) {
        if (!tableExists($db, $table)) {
            continue;
        }
        if ($table === 'module_registrations') {
            execute($db, $sql, ['2026', '2027']);
            continue;
        }
        if (in_array($table, ['invoice_lines', 'invoices', 'payments', 'installment_schedule', 'installment_plans', 'payable_payments', 'payables', 'purchase_orders', 'purchase_requisitions', 'bank_transactions', 'journal_lines', 'journal_entries', 'modules'], true)) {
            execute($db, $sql, [SEED_CODE_PREFIX . '%']);
            continue;
        }
        if (in_array($table, ['fee_structures', 'finance_sponsors', 'suppliers', 'bank_accounts', 'financial_periods', 'fee_rules', 'intakes', 'rooms'], true)) {
            execute($db, $sql, [SEED_FINANCE_PREFIX . '%']);
            continue;
        }
        execute($db, $sql, [SEED_STUDENT_NUMBER_PREFIX . '%']);
    }
}

$dryRun = in_array('--dry-run', $argv ?? [], true);

$programRows = fetchAllRows($db, 'SELECT id, code, name, program_type FROM programs ORDER BY id');
$programs = [];
foreach ($programRows as $row) {
    $programs[$row['code']] = $row;
}

$requiredProgramCodes = ['SC-HOSP-101', 'PC-CUL-201', 'DIP-TOUR-301', 'HND-HOSP-401'];
foreach ($requiredProgramCodes as $code) {
    if (!isset($programs[$code])) {
        throw new RuntimeException('Required program missing: ' . $code);
    }
}

$year2026Jan = ensureIntake($db, 'Seed January 2026 Intake', '2026', '2026-01-15', '2026-12-15');
$year2026May = ensureIntake($db, 'Seed May 2026 Intake', '2026', '2026-05-01', '2027-04-30');
$year2027Jan = ensureIntake($db, 'Seed January 2027 Intake', '2027', '2027-01-15', '2027-12-15');
$year2027May = ensureIntake($db, 'Seed May 2027 Intake', '2027', '2027-05-01', '2028-04-30');

$registrarId = ensureStaffRoleUser($db, 'registrar', 'seed.registrar', 'Seed', 'Registrar', 'SR-0001', 'Academic Registry', 'Registrar');
$financeId = ensureStaffRoleUser($db, 'finance', 'seed.finance', 'Seed', 'Finance', 'SF-0001', 'Finance', 'Finance Officer');
$lecturerIds = [
    ensureStaffRoleUser($db, 'lecturer', 'seed.lecturer1', 'Seed', 'Lecturer', 'SL-0001', 'Hospitality', 'Lecturer'),
    ensureStaffRoleUser($db, 'lecturer', 'seed.lecturer2', 'Seed', 'Trainer', 'SL-0002', 'Culinary', 'Lecturer'),
    ensureStaffRoleUser($db, 'lecturer', 'seed.lecturer3', 'Seed', 'Facilitator', 'SL-0003', 'Tourism', 'Lecturer'),
    ensureStaffRoleUser($db, 'lecturer', 'seed.lecturer4', 'Seed', 'Advisor', 'SL-0004', 'Management', 'Lecturer'),
];

$programModules = [];
foreach ($programs as $program) {
    $programModules[$program['code']] = ensureProgramModules($db, (int) $program['id'], $program['code'], $program['name']);
}

$classes = [];
$classLookup = [];
$classYearMap = [
    2026 => $year2026Jan,
    2027 => $year2027Jan,
];

$yearLabels = [2026 => '2026', 2027 => '2027'];
$programCodes = array_keys($programs);
foreach ([2026, 2027] as $year) {
    $programIndex = 0;
    foreach ($programCodes as $programCode) {
        $program = $programs[$programCode];
        $module = $programModules[$programCode][0];
        $className = sprintf('%s %s Cohort %s', SEED_CLASS_PREFIX, $program['name'], $year);
        $section = chr(65 + $programIndex);
        $joinCode = sprintf('SEED%02d%02d%s', $year % 100, $programIndex + 1, $section);
        $existing = fetchOne($db, 'SELECT id FROM classes WHERE join_code = ?', [$joinCode]);
        if ($existing) {
            $classId = (int) $existing['id'];
        } else {
            $classId = insertId($db, 'INSERT INTO classes (module_id, name, section, subject, room_number, join_code, theme_color, description, status, comments_enabled, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                (int) $module['id'],
                $className,
                $section,
                $program['name'],
                'Room ' . ($programIndex + 1),
                $joinCode,
                sprintf('#%02x%02x%02x', 13 + ($programIndex * 20), 79 + ($year === 2027 ? 20 : 0), 76 + ($programIndex * 10)),
                'Seed classroom for testing',
                'active',
                1,
                safeIndex($lecturerIds, $programIndex, $registrarId),
            ]);
        }

        $classes[$year][$programCode] = $classId;
        $classLookup[$classId] = ['year' => $year, 'program' => $program];

        if (tableExists($db, 'class_topics')) {
            $topics = [
                'Welcome and expectations',
                'Core theory',
                'Practical assessment',
            ];
            foreach ($topics as $topicIndex => $topicTitle) {
                $topicExists = fetchOne($db, 'SELECT id FROM class_topics WHERE class_id = ? AND title = ?', [$classId, $topicTitle]);
                if (!$topicExists) {
                    execute($db, 'INSERT INTO class_topics (class_id, title, sort_order) VALUES (?, ?, ?)', [$classId, $topicTitle, $topicIndex + 1]);
                }
            }
        }
        $programIndex++;
    }
}

$firstNames = ['Amina', 'Blessing', 'Chenai', 'Derrick', 'Elina', 'Farai', 'Godfrey', 'Hilda', 'Ivy', 'Jared', 'Kudzai', 'Lerato', 'Moses', 'Nadia', 'Obert', 'Precious', 'Tariro', 'Unity', 'Vimbai', 'Wellington'];
$lastNames = ['Banda', 'Chirwa', 'Dube', 'Furusa', 'Gumbo', 'Hove', 'Jele', 'Kachidza', 'Moyo', 'Ncube', 'Nyasha', 'Phiri', 'Sibanda', 'Tafara', 'Vengesai', 'Zhou'];

$seedStudents = [];
$moduleRegistrations = [];
$studentCounter = 0;

$db->beginTransaction();
try {
    cleanupSeedData($db);

    $studentIndexByClass = [];
    $allStudentIdsByProgramYear = [];

    foreach ([2026, 2027] as $year) {
        $yearIntakes = $year === 2026 ? [$year2026Jan, $year2026May] : [$year2027Jan, $year2027May];
        foreach ($programCodes as $programIndex => $programCode) {
            $program = $programs[$programCode];
            $classId = $classes[$year][$programCode];
            $moduleRows = $programModules[$programCode];
            $programMembers = [];

            for ($i = 0; $i < 15; $i++) {
                $studentCounter++;
                $firstName = safeIndex($firstNames, $studentCounter, $firstNames[0]);
                $lastName = safeIndex($lastNames, $studentCounter, $lastNames[0]);
                $suffix = str_pad((string) $studentCounter, 3, '0', STR_PAD_LEFT);
                $studentNumber = SEED_STUDENT_NUMBER_PREFIX . $year . '-' . $suffix;
                $applicationRef = SEED_APPLICATION_PREFIX . $year . '-' . $suffix;
                $email = sprintf('student.%s.%s@%s', strtolower($firstName), strtolower($lastName) . '.' . $suffix, SEED_STUDENT_EMAIL_DOMAIN);
                $phone = '077' . str_pad((string) (7000000 + $studentCounter), 7, '0', STR_PAD_LEFT);
                $gender = ($studentCounter % 3 === 0) ? 'male' : (($studentCounter % 2 === 0) ? 'female' : 'other');
                $dob = (new DateTimeImmutable(sprintf('%04d-09-01', $year - 18)))->modify('+' . ($studentCounter % 180) . ' days')->format('Y-m-d');
                $intakeId = $yearIntakes[$i < 8 ? 0 : 1];
                $enrollmentDate = $year === 2026
                    ? (new DateTimeImmutable('2026-01-15'))->modify('+' . ($studentCounter % 80) . ' days')->format('Y-m-d')
                    : (new DateTimeImmutable('2027-01-15'))->modify('+' . ($studentCounter % 80) . ' days')->format('Y-m-d');
                $address = 'Seed House ' . $suffix . ', Test Avenue, Harare';
                $qualification = $year === 2026 ? 'O-Level' : 'A-Level';

                if ($studentCounter === 1) {
                    fwrite(STDOUT, "DEBUG: will insert application " . $applicationRef . " with intakeId=" . var_export($intakeId, true) . " programId=" . (int) $program['id'] . "\n");
                }

                // Defensive: ensure the intake exists before attempting to insert application
                $intakeCheck = fetchOne($db, 'SELECT id FROM intakes WHERE id = ?', [$intakeId]);
                if (!$intakeCheck) {
                    // Recreate a missing intake deterministically based on year and position
                    $isFirstHalf = $i < 8;
                    if ($year === 2026) {
                        $intakeName = $isFirstHalf ? 'Seed January 2026 Intake' : 'Seed May 2026 Intake';
                        $intakeStart = $isFirstHalf ? '2026-01-15' : '2026-05-01';
                        $intakeEnd = $isFirstHalf ? '2026-12-15' : '2027-04-30';
                    } else {
                        $intakeName = $isFirstHalf ? 'Seed January 2027 Intake' : 'Seed May 2027 Intake';
                        $intakeStart = $isFirstHalf ? '2027-01-15' : '2027-05-01';
                        $intakeEnd = $isFirstHalf ? '2027-12-15' : '2028-04-30';
                    }
                    fwrite(STDOUT, sprintf("Intake id %s missing; creating %s\n", var_export($intakeId, true), $intakeName));
                    $intakeId = ensureIntake($db, $intakeName, (string) $year, $intakeStart, $intakeEnd);
                }
                execute($db, 'INSERT INTO applications (application_ref, program_id, intake_id, first_name, last_name, email, phone, gender, date_of_birth, address, previous_qualification, status, notes, reviewed_by, reviewed_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $applicationRef,
                    (int) $program['id'],
                    $intakeId,
                    $firstName,
                    $lastName,
                    $email,
                    $phone,
                    $gender,
                    $dob,
                    $address,
                    $qualification,
                    'approved',
                    json_encode([
                        'seed' => true,
                        'academic_year' => (string) $year,
                        'cohort' => $programCode,
                        'intake_id' => $intakeId,
                    ], JSON_UNESCAPED_UNICODE),
                    $registrarId,
                    (new DateTimeImmutable($enrollmentDate . ' 09:00:00'))->format('Y-m-d H:i:s'),
                ]);
                $applicationId = (int) $db->lastInsertId();

                execute($db, 'INSERT INTO students (student_number, application_id, program_id, intake_id, enrollment_status, enrollment_date) VALUES (?, ?, ?, ?, ?, ?)', [
                    $studentNumber,
                    $applicationId,
                    (int) $program['id'],
                    $intakeId,
                    ($studentCounter % 11 === 0) ? 'deferred' : (($studentCounter % 9 === 0) ? 'suspended' : 'active'),
                    $enrollmentDate,
                ]);
                $studentId = (int) $db->lastInsertId();

                $portal = createDirectStudentPortalAccount($studentId, $firstName, $lastName, $email, $phone, true);
                $studentRow = fetchOne($db, 'SELECT user_id FROM students WHERE id = ?', [$studentId]);
                $userId = (int) ($studentRow['user_id'] ?? 0);
                if ($userId) {
                    execute($db, 'UPDATE applications SET user_id = ? WHERE id = ?', [$userId, $applicationId]);
                    execute($db, 'UPDATE students SET user_id = ? WHERE id = ?', [$userId, $studentId]);
                    execute($db, 'INSERT IGNORE INTO class_members (class_id, user_id, member_role) VALUES (?, ?, ?)', [$classId, $userId, 'student']);
                }

                $allStudentIdsByProgramYear[$year][$programCode][] = $studentId;
                $programMembers[] = ['student_id' => $studentId, 'user_id' => $userId, 'first_name' => $firstName, 'last_name' => $lastName, 'email' => $email, 'portal' => $portal];
                $seedStudents[] = $studentId;

                foreach ($moduleRows as $moduleIndex => $moduleRow) {
                    execute($db, 'INSERT INTO module_registrations (student_id, module_id, academic_year, status, grade) VALUES (?, ?, ?, ?, ?)', [
                        $studentId,
                        (int) $moduleRow['id'],
                        (string) $year,
                        'registered',
                        null,
                    ]);
                }
            }

            $studentIndexByClass[$classId] = $programMembers;
        }
    }

    foreach ($programModules as $programCode => $modules) {
        foreach ($modules as $moduleIndex => $moduleRow) {
            foreach ([2026, 2027] as $year) {
                $assessmentBase = sprintf('Seed %s %s %s', $programCode, $year, $moduleRow['code']);
                $caTitle = $assessmentBase . ' CA';
                $examTitle = $assessmentBase . ' Exam';

                $caExists = fetchOne($db, 'SELECT id FROM assessments WHERE module_id = ? AND title = ?', [(int) $moduleRow['id'], $caTitle]);
                if (!$caExists) {
                    $caId = insertId($db, 'INSERT INTO assessments (module_id, title, assessment_type, weight_percent, max_score, scheduled_date) VALUES (?, ?, ?, ?, ?, ?)', [(int) $moduleRow['id'], $caTitle, 'ca', 40, 100, sprintf('%04d-04-15 09:00:00', $year)]);
                } else {
                    $caId = (int) $caExists['id'];
                }

                $examExists = fetchOne($db, 'SELECT id FROM assessments WHERE module_id = ? AND title = ?', [(int) $moduleRow['id'], $examTitle]);
                if (!$examExists) {
                    $examId = insertId($db, 'INSERT INTO assessments (module_id, title, assessment_type, weight_percent, max_score, scheduled_date) VALUES (?, ?, ?, ?, ?, ?)', [(int) $moduleRow['id'], $examTitle, 'exam', 60, 100, sprintf('%04d-11-15 09:00:00', $year)]);
                } else {
                    $examId = (int) $examExists['id'];
                }

                $studentRegs = fetchAllRows($db, 'SELECT student_id FROM module_registrations WHERE module_id = ? AND academic_year = ?', [(int) $moduleRow['id'], (string) $year]);
                foreach ($studentRegs as $regIndex => $regRow) {
                    $studentId = (int) $regRow['student_id'];
                    $baseScore = 55 + (($studentId + $moduleIndex + $year) % 35);
                    $caScore = min(100, $baseScore);
                    $examScore = min(100, $baseScore + 5);

                    $enteredBy = safeIndex($lecturerIds, ($moduleIndex + $year), $registrarId);
                    $caMark = fetchOne($db, 'SELECT id FROM marks WHERE assessment_id = ? AND student_id = ?', [$caId, $studentId]);
                    if (!$caMark) {
                        execute($db, 'INSERT INTO marks (assessment_id, student_id, score, grade, moderated, entered_by) VALUES (?, ?, ?, ?, ?, ?)', [$caId, $studentId, $caScore, $caScore >= 75 ? 'A' : ($caScore >= 65 ? 'B' : ($caScore >= 55 ? 'C' : 'D')), 0, $enteredBy]);
                    }
                    $examMark = fetchOne($db, 'SELECT id FROM marks WHERE assessment_id = ? AND student_id = ?', [$examId, $studentId]);
                    if (!$examMark) {
                        execute($db, 'INSERT INTO marks (assessment_id, student_id, score, grade, moderated, entered_by) VALUES (?, ?, ?, ?, ?, ?)', [$examId, $studentId, $examScore, $examScore >= 75 ? 'A' : ($examScore >= 65 ? 'B' : ($examScore >= 55 ? 'C' : 'D')), 0, $enteredBy]);
                    }
                }
            }
        }
    }

    foreach ($studentIndexByClass as $classId => $students) {
        $year = $classLookup[$classId]['year'];
        $programCode = $classLookup[$classId]['program']['code'];
        $moduleId = (int) $classes[$year][$programCode];
        $classDateBase = $year === 2026 ? '2026-03-01' : '2027-03-01';

        for ($sessionIndex = 0; $sessionIndex < 2; $sessionIndex++) {
            $sessionDate = (new DateTimeImmutable($classDateBase))->modify('+' . ($sessionIndex * 21) . ' days');
            $sessionToken = substr(hash('sha256', 'class-' . $classId . '-' . $sessionIndex), 0, 32);
            $sessionExists = fetchOne($db, 'SELECT id FROM attendance_sessions WHERE module_id = ? AND session_date = ?', [$moduleId, $sessionDate->format('Y-m-d')]);
            if ($sessionExists) {
                $sessionId = (int) $sessionExists['id'];
            } else {
                $sessionId = insertId($db, 'INSERT INTO attendance_sessions (module_id, session_date, qr_token, created_by) VALUES (?, ?, ?, ?)', [$moduleId, $sessionDate->format('Y-m-d'), $sessionToken, safeIndex($lecturerIds, $sessionIndex, $registrarId)]);
            }

            foreach ($students as $memberIndex => $student) {
                $statusCycle = ['present', 'late', 'absent', 'excused'];
                $status = safeIndex($statusCycle, ($memberIndex + $sessionIndex), $statusCycle[0]);
                $recordExists = fetchOne($db, 'SELECT id FROM attendance_records WHERE session_id = ? AND student_id = ?', [$sessionId, $student['student_id']]);
                if (!$recordExists) {
                    execute($db, 'INSERT INTO attendance_records (session_id, student_id, status) VALUES (?, ?, ?)', [$sessionId, $student['student_id'], $status]);
                }
            }
        }

        $topicRows = fetchAllRows($db, 'SELECT id FROM class_topics WHERE class_id = ? ORDER BY sort_order', [$classId]);
        $classAssignments = [];
        foreach ($topicRows as $topicIndex => $topicRow) {
            $assignmentTitle = sprintf('Seed Assignment %d for %s', $topicIndex + 1, $classLookup[$classId]['program']['code']);
            $dueDate = (new DateTimeImmutable($classDateBase))->modify('+' . (14 + ($topicIndex * 10)) . ' days');
            $assignmentExists = fetchOne($db, 'SELECT id FROM class_assignments WHERE class_id = ? AND title = ?', [$classId, $assignmentTitle]);
            if ($assignmentExists) {
                $assignmentId = (int) $assignmentExists['id'];
            } else {
                $assignmentId = insertId($db, 'INSERT INTO class_assignments (class_id, topic_id, title, instructions, due_date, max_score, allow_late, late_penalty_percent, status, created_by, published_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    $classId,
                    (int) $topicRow['id'],
                    $assignmentTitle,
                    'Seed classwork for testing submissions and grading.',
                    $dueDate->format('Y-m-d H:i:s'),
                    100,
                    1,
                    5,
                    'published',
                    safeIndex($lecturerIds, $topicIndex, $registrarId),
                    $dueDate->modify('-3 days')->format('Y-m-d H:i:s'),
                ]);
            }
            $classAssignments[] = $assignmentId;

            if (tableExists($db, 'class_rubrics')) {
                $rubricTitle = 'Seed Rubric ' . ($topicIndex + 1) . ' for class ' . $classId;
                $rubricExists = fetchOne($db, 'SELECT id FROM class_rubrics WHERE class_assignment_id = ?', [$assignmentId]);
                if (!$rubricExists) {
                    execute($db, 'INSERT INTO class_rubrics (class_assignment_id, title, criteria_json) VALUES (?, ?, ?)', [$assignmentId, $rubricTitle, json_encode([
                        ['criterion' => 'Content', 'max_points' => 40],
                        ['criterion' => 'Structure', 'max_points' => 30],
                        ['criterion' => 'Presentation', 'max_points' => 30],
                    ], JSON_UNESCAPED_UNICODE)]);
                }
            }
        }

        if (tableExists($db, 'stream_posts')) {
            // Ensure the class row exists; if not, recreate deterministically using classLookup
            $classRow = fetchOne($db, 'SELECT id FROM classes WHERE id = ?', [$classId]);
                if (!$classRow) {
                $lookup = $classLookup[$classId] ?? null;
                if ($lookup && isset($lookup['program'])) {
                    $prog = $lookup['program'];
                    $moduleId = fetchOne($db, 'SELECT id FROM modules WHERE program_id = ? LIMIT 1', [(int) $prog['id']]);
                    // determine program index to create a matching join code
                    $programIndexForJoin = 0;
                    if (isset($programCodes) && is_array($programCodes)) {
                        $found = array_search($prog['code'], $programCodes, true);
                        if ($found !== false) {
                            $programIndexForJoin = (int) $found;
                        }
                    }
                    $sectionChar = chr(65 + $programIndexForJoin);
                    $joinCode = sprintf('SEED%02d%02d%s', ($lookup['year'] % 100), $programIndexForJoin + 1, $sectionChar);
                    $classId = insertId($db, 'INSERT INTO classes (module_id, name, section, subject, room_number, join_code, theme_color, description, status, comments_enabled, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                        (int) ($moduleId['id'] ?? 0),
                        SEED_CLASS_PREFIX . ' ' . $prog['name'] . ' Cohort ' . $lookup['year'],
                        $sectionChar,
                        $prog['name'],
                        'Room 1',
                        $joinCode,
                        '#999999',
                        'Recreated seed class',
                        'active',
                        1,
                        safeIndex($lecturerIds, 0, $registrarId),
                    ]);
                    $classes[$lookup['year']][$prog['code']] = $classId;
                    $classLookup[$classId] = $lookup;
                }
            }

            $postExists = fetchOne($db, 'SELECT id FROM stream_posts WHERE class_id = ? AND post_type = ?', [$classId, 'announcement']);
            if (!$postExists) {
                execute($db, 'INSERT INTO stream_posts (class_id, user_id, post_type, title, body, comments_enabled, published_at) VALUES (?, ?, ?, ?, ?, ?, ?)', [$classId, $lecturerIds[0], 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', 1, (new DateTimeImmutable($classDateBase))->format('Y-m-d H:i:s')]);
            }
        }

        if (tableExists($db, 'class_calendar_events')) {
            for ($eventIndex = 0; $eventIndex < 2; $eventIndex++) {
                $eventTitle = 'Seed event ' . ($eventIndex + 1) . ' for class ' . $classId;
                $eventDate = (new DateTimeImmutable($classDateBase))->modify('+' . ($eventIndex * 14) . ' days');
                $eventExists = fetchOne($db, 'SELECT id FROM class_calendar_events WHERE class_id = ? AND title = ?', [$classId, $eventTitle]);
                if (!$eventExists) {
                    execute($db, 'INSERT INTO class_calendar_events (class_id, title, event_type, start_at, end_at, class_assignment_id, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)', [$classId, $eventTitle, 'class', $eventDate->format('Y-m-d H:i:s'), $eventDate->modify('+2 hours')->format('Y-m-d H:i:s'), safeIndex($classAssignments, $eventIndex, $classAssignments[0] ?? null), safeIndex($lecturerIds, $eventIndex, $registrarId)]);
                }
            }
        }

        if (tableExists($db, 'class_submissions')) {
            foreach (array_slice($students, 0, 5) as $student) {
                foreach ($classAssignments as $assignmentIndex => $assignmentId) {
                    $submissionExists = fetchOne($db, 'SELECT id FROM class_submissions WHERE class_assignment_id = ? AND student_id = ?', [$assignmentId, $student['student_id']]);
                    if (!$submissionExists) {
                        $submittedAt = (new DateTimeImmutable($classDateBase))->modify('+' . (10 + $assignmentIndex) . ' days');
                        execute($db, 'INSERT INTO class_submissions (class_assignment_id, student_id, notes, status, score, feedback, private_comment, graded_by, submitted_at, graded_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                            $assignmentId,
                            $student['student_id'],
                            'Seed submission for testing',
                            'graded',
                            70 + (($student['student_id'] + $assignmentIndex) % 25),
                            'Seed feedback',
                            'Internal note',
                            safeIndex($lecturerIds, $assignmentIndex, $registrarId),
                            $submittedAt->format('Y-m-d H:i:s'),
                            $submittedAt->modify('+1 day')->format('Y-m-d H:i:s'),
                        ]);
                    }
                }
            }
        }
    }

    $feeStructures = [];
    foreach ([2026, 2027] as $year) {
        foreach ($programCodes as $programCode) {
            $program = $programs[$programCode];
            $description = sprintf('Seed tuition %s %s', $year, $program['code']);
            $feeStructures[$year][$programCode] = ensureFeeStructure($db, (int) $program['id'], null, $description, 450 + (($program['id'] % 4) * 120) + (($year - 2026) * 40));
        }
    }

    $sponsorOne = ensureSponsor($db, 'SEED-SP-001', 'Seed Hospitality Trust');
    $sponsorTwo = ensureSponsor($db, 'SEED-SP-002', 'Seed Tourism Partners', 'corporate');

    $bankMain = ensureBankAccount($db, 'Seed Tuition Main Account', 'Seed Bank', '111100001111', 'USD');
    $bankOps = ensureBankAccount($db, 'Seed Operations Account', 'Seed Bank', '222200002222', 'USD');
    $period2026 = ensureFinancialPeriod($db, 'Seed FY 2026', '2026-01-01', '2026-12-31');
    $period2027 = ensureFinancialPeriod($db, 'Seed FY 2027', '2027-01-01', '2027-12-31');

    $allStudents = fetchAllRows($db, 'SELECT s.id, s.student_number, s.program_id, s.intake_id, s.enrollment_date, s.enrollment_status, s.user_id, p.code AS program_code, p.name AS program_name, i.academic_year AS intake_year FROM students s JOIN programs p ON p.id = s.program_id JOIN intakes i ON i.id = s.intake_id WHERE s.student_number LIKE ? ORDER BY s.id', [SEED_STUDENT_NUMBER_PREFIX . '%']);

    foreach ($allStudents as $studentIndex => $student) {
        $year = (int) substr((string) $student['intake_year'], 0, 4);
        $programCode = $student['program_code'];
        $feeStructureId = $feeStructures[$year][$programCode] ?? null;
        $invoiceNumber = sprintf('SEED-INV-%04d', $studentIndex + 1);
        $dueDate = (new DateTimeImmutable((string) $student['enrollment_date']))->modify('+60 days')->format('Y-m-d');
        $invoiceExists = fetchOne($db, 'SELECT id FROM invoices WHERE invoice_number = ?', [$invoiceNumber]);
        if (!$invoiceExists) {
            $invoiceId = insertId($db, 'INSERT INTO invoices (invoice_number, student_id, total_amount, amount_paid, status, due_date, currency, invoice_type, fee_structure_id, sponsor_id, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                $invoiceNumber,
                (int) $student['id'],
                500 + (($studentIndex % 4) * 75),
                0,
                'pending',
                $dueDate,
                'USD',
                'invoice',
                $feeStructureId,
                ($studentIndex % 7 === 0) ? $sponsorOne : (($studentIndex % 9 === 0) ? $sponsorTwo : null),
                'Seed invoice for testing',
            ]);
            if (tableExists($db, 'invoice_lines')) {
                execute($db, 'INSERT INTO invoice_lines (invoice_id, description, quantity, unit_amount, line_total, fee_type) VALUES (?, ?, ?, ?, ?, ?)', [$invoiceId, 'Tuition', 1, 350, 350, 'tuition']);
                execute($db, 'INSERT INTO invoice_lines (invoice_id, description, quantity, unit_amount, line_total, fee_type) VALUES (?, ?, ?, ?, ?, ?)', [$invoiceId, 'Registration', 1, 150, 150, 'registration']);
            }

            if ($studentIndex % 2 === 0) {
                $paidAmount = 250 + (($studentIndex % 3) * 50);
                $paymentId = insertId($db, 'INSERT INTO payments (receipt_number, invoice_id, amount, payment_method, reference, received_by, currency, exchange_rate, pop_file, status, sponsor_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
                    sprintf('SEED-RCT-%04d', $studentIndex + 1),
                    $invoiceId,
                    $paidAmount,
                    ['cash', 'bank', 'mobile', 'gateway', 'pos', 'card'][$studentIndex % 6],
                    'SEEDPAY' . sprintf('%04d', $studentIndex + 1),
                    $financeId,
                    'USD',
                    1,
                    null,
                    'confirmed',
                    ($studentIndex % 7 === 0) ? $sponsorOne : null,
                ]);
                execute($db, 'UPDATE invoices SET amount_paid = ?, status = ? WHERE id = ?', [$paidAmount, $paidAmount >= 500 ? 'paid' : 'partial', $invoiceId]);
                ensureBankTransaction($db, $bankMain, $student['year'] ?? $student['intake_year'] ?? date('Y-m-d'), 'Seed tuition receipt ' . ($studentIndex + 1), 'SEEDPAY' . sprintf('%04d', $studentIndex + 1), $paidAmount, 'credit', $paymentId);
            }
        }

        if ($studentIndex % 12 === 0 && tableExists($db, 'finance_holds')) {
            execute($db, 'INSERT INTO finance_holds (student_id, hold_type, reason, is_active, auto_generated, created_by) VALUES (?, ?, ?, ?, ?, ?)', [(int) $student['id'], 'results', 'Seed results hold for testing', 1, 1, $financeId]);
        }

        if ($studentIndex % 10 === 0 && tableExists($db, 'sponsor_students')) {
            $sponsorId = ($studentIndex % 20 === 0) ? $sponsorOne : $sponsorTwo;
            execute($db, 'INSERT IGNORE INTO sponsor_students (sponsor_id, student_id, coverage_percent) VALUES (?, ?, ?)', [$sponsorId, (int) $student['id'], 100]);
        }

        if ($studentIndex % 8 === 0 && tableExists($db, 'placements')) {
            $placementId = insertId($db, 'INSERT INTO placements (student_id, employer_name, supervisor_name, supervisor_contact, start_date, end_date, status) VALUES (?, ?, ?, ?, ?, ?, ?)', [(int) $student['id'], 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', $year . '-06-01', $year . '-08-31', 'active']);
            if (tableExists($db, 'placement_logbooks')) {
                execute($db, 'INSERT INTO placement_logbooks (placement_id, log_date, activities) VALUES (?, ?, ?)', [$placementId, $year . '-06-10', 'Seed logbook entry for testing']);
            }
        }

        if ($studentIndex % 14 === 0 && tableExists($db, 'graduations')) {
            execute($db, 'INSERT INTO graduations (student_id, program_id, graduation_date, certificate_number, qr_verification_code, gpa) VALUES (?, ?, ?, ?, ?, ?)', [(int) $student['id'], (int) $student['program_id'], $year . '-12-10', 'SEED-CERT-' . str_pad((string) ($studentIndex + 1), 4, '0', STR_PAD_LEFT), hash('sha256', 'SEED-CERT-' . ($studentIndex + 1)), 3.10 + (($studentIndex % 4) * 0.2)]);
        }
    }

    if (tableExists($db, 'payables')) {
        $supplierIds = [
            ensureSupplier($db, 'SEED-SUP-001', 'Seed Office Supplies'),
            ensureSupplier($db, 'SEED-SUP-002', 'Seed Food Services'),
            ensureSupplier($db, 'SEED-SUP-003', 'Seed ICT Solutions'),
        ];
        $purchaseReqNumbers = [];
        foreach ($supplierIds as $idx => $supplierId) {
            $reqNumber = sprintf('SEED-REQ-%03d', $idx + 1);
            $purchaseReqNumbers[] = $reqNumber;
            $reqId = fetchOne($db, 'SELECT id FROM purchase_requisitions WHERE req_number = ?', [$reqNumber]);
            if (!$reqId) {
                $reqId = insertId($db, 'INSERT INTO purchase_requisitions (req_number, department, description, estimated_total, status, requested_by, hod_approved_by, finance_approved_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', [$reqNumber, 'Operations', 'Seed procurement request ' . ($idx + 1), 1200 + ($idx * 400), 'finance_approved', $registrarId, $registrarId, $financeId]);
            } else {
                $reqId = (int) $reqId['id'];
            }

            $poNumber = sprintf('SEED-PO-%03d', $idx + 1);
            $poExists = fetchOne($db, 'SELECT id FROM purchase_orders WHERE po_number = ?', [$poNumber]);
            if (!$poExists) {
                $poId = insertId($db, 'INSERT INTO purchase_orders (po_number, requisition_id, supplier_id, total_amount, status) VALUES (?, ?, ?, ?, ?)', [$poNumber, $reqId, $supplierId, 1200 + ($idx * 400), 'received']);
            } else {
                $poId = (int) $poExists['id'];
            }

            if (tableExists($db, 'goods_receipts')) {
                $receiptExists = fetchOne($db, 'SELECT id FROM goods_receipts WHERE po_id = ?', [$poId]);
                if (!$receiptExists) {
                    execute($db, 'INSERT INTO goods_receipts (po_id, received_date, notes, received_by) VALUES (?, ?, ?, ?)', [$poId, '2027-09-15', 'Seed goods receipt', $financeId]);
                }
            }

            $billNumber = sprintf('SEED-BILL-%03d', $idx + 1);
            $billExists = fetchOne($db, 'SELECT id FROM payables WHERE bill_number = ?', [$billNumber]);
            if (!$billExists) {
                $billId = insertId($db, 'INSERT INTO payables (bill_number, supplier_id, category_id, description, amount, amount_paid, currency, due_date, status, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [$billNumber, $supplierId, null, 'Seed supplier bill ' . ($idx + 1), 1200 + ($idx * 400), 0, 'USD', '2027-10-15', 'pending', $financeId]);
                if (tableExists($db, 'payable_payments')) {
                    execute($db, 'INSERT INTO payable_payments (payable_id, amount, payment_method, reference, paid_by) VALUES (?, ?, ?, ?, ?)', [$billId, 400, 'bank', 'SEED-PAYABLE-' . ($idx + 1), $financeId]);
                }
            }
        }
    }

    if (tableExists($db, 'journal_entries') && tableExists($db, 'journal_lines')) {
        foreach ([
            ['SEED-JE-001', '2026-06-30', 'Seed tuition receipt', $period2026, 1200, 1200],
            ['SEED-JE-002', '2027-06-30', 'Seed tuition receipt', $period2027, 1400, 1400],
            ['SEED-JE-003', '2026-12-31', 'Seed office expense', $period2026, 300, 300],
            ['SEED-JE-004', '2027-12-31', 'Seed office expense', $period2027, 450, 450],
        ] as [$entryNumber, $entryDate, $description, $periodId, $debit, $credit]) {
            $entryId = ensureJournalEntry($db, $entryNumber, $entryDate, $description, $periodId, 'seed', null, $financeId);
            $cashAccount = (int) fetchOne($db, 'SELECT id FROM chart_of_accounts WHERE code = ?', ['1000'])['id'];
            $revenueAccount = (int) fetchOne($db, 'SELECT id FROM chart_of_accounts WHERE code = ?', ['4000'])['id'];
            if (!fetchOne($db, 'SELECT id FROM journal_lines WHERE journal_id = ?', [$entryId])) {
                execute($db, 'INSERT INTO journal_lines (journal_id, account_id, debit, credit, memo) VALUES (?, ?, ?, ?, ?)', [$entryId, $cashAccount, $debit, 0, 'Seed cash line']);
                execute($db, 'INSERT INTO journal_lines (journal_id, account_id, debit, credit, memo) VALUES (?, ?, ?, ?, ?)', [$entryId, $revenueAccount, 0, $credit, 'Seed offset line']);
            }
        }
    }

    if ($dryRun) {
        $db->rollBack();
        echo "Dry run complete. No changes were committed.\n";
        exit(0);
    }

    $db->commit();
} catch (Throwable $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    fwrite(STDERR, 'Seed failed: ' . $e->getMessage() . PHP_EOL);
    fwrite(STDERR, $e->getTraceAsString() . PHP_EOL);
    exit(1);
}

$studentCount = (int) fetchOne($db, 'SELECT COUNT(*) AS c FROM students WHERE student_number LIKE ?', [SEED_STUDENT_NUMBER_PREFIX . '%'])['c'];
$classCount = (int) fetchOne($db, 'SELECT COUNT(*) AS c FROM classes WHERE name LIKE ?', [SEED_CLASS_PREFIX . '%'])['c'];
$invoiceCount = tableExists($db, 'invoices') ? (int) fetchOne($db, 'SELECT COUNT(*) AS c FROM invoices WHERE invoice_number LIKE ?', ['SEED-INV-%'])['c'] : 0;
$paymentCount = tableExists($db, 'payments') ? (int) fetchOne($db, 'SELECT COUNT(*) AS c FROM payments WHERE receipt_number LIKE ?', ['SEED-RCT-%'])['c'] : 0;

echo sprintf("Seeded %d students, %d classes, %d invoices, and %d payments.\n", $studentCount, $classCount, $invoiceCount, $paymentCount);
