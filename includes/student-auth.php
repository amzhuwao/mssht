<?php
/**
 * Student portal authentication helpers
 */

function getCurrentStudentId(): ?int
{
    return isset($_SESSION['student_id']) ? (int) $_SESSION['student_id'] : null;
}

function getCurrentStudent(): ?array
{
    static $student = null;
    if ($student !== null) {
        return $student;
    }
    $id = getCurrentStudentId();
    if (!$id) {
        return null;
    }
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT s.*, p.name AS program_name, p.program_type, i.name AS intake_name,
                u.email AS portal_email
         FROM students s
         JOIN programs p ON p.id = s.program_id
         JOIN intakes i ON i.id = s.intake_id
         LEFT JOIN users u ON u.id = s.user_id
         WHERE s.id = ?'
    );
    $stmt->execute([$id]);
    $student = $stmt->fetch() ?: null;
    return $student;
}

function isStudentPortal(): bool
{
    return currentRole() === 'student';
}

function requireStudentPortal(): void
{
    requireLogin();
    if (!isStudentPortal()) {
        flash('danger', 'Student portal access only.');
        redirect(url('dashboard.php'));
    }
}

function generateStudentTempPassword(string $studentNumber): string
{
    $suffix = preg_replace('/\D/', '', $studentNumber);
    $suffix = substr($suffix, -4) ?: '0000';
    return 'Mssht' . $suffix;
}

/**
 * Create or reset portal login for a student record.
 * @return array{email:string,temp_password:string,student_number:string,is_new:bool}|null
 */
function createStudentPortalAccount(int $studentId, bool $resetPassword = false): ?array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT s.*, a.first_name, a.last_name, a.email, a.phone
         FROM students s
         LEFT JOIN applications a ON a.id = s.application_id
         WHERE s.id = ?'
    );
    $stmt->execute([$studentId]);
    $student = $stmt->fetch();
    if (!$student) {
        return null;
    }

    $email = trim($student['email'] ?? '');
    if ($email === '') {
        $email = strtolower($student['student_number']) . '@students.mssht.ac.zw';
    }

    $firstName = $student['first_name'] ?? 'Student';
    $lastName = $student['last_name'] ?? $student['student_number'];
    $phone = $student['phone'] ?? null;
    $tempPassword = generateStudentTempPassword($student['student_number']);
    $hash = password_hash($tempPassword, PASSWORD_DEFAULT);
    $isNew = empty($student['user_id']);

    if ($student['user_id']) {
        $userId = (int) $student['user_id'];
        if ($resetPassword) {
            $db->prepare('UPDATE users SET password_hash = ?, must_change_password = 1, status = ? WHERE id = ?')
               ->execute([$hash, 'active', $userId]);
        }
        $db->prepare('UPDATE user_profiles SET first_name = ?, last_name = ?, phone = ? WHERE user_id = ?')
           ->execute([$firstName, $lastName, $phone, $userId]);
    } else {
        $check = $db->prepare('SELECT id FROM users WHERE email = ?');
        $check->execute([$email]);
        if ($check->fetch()) {
            $email = strtolower($student['student_number']) . '+' . $studentId . '@students.mssht.ac.zw';
        }

        try {
            $db->prepare(
                'INSERT INTO users (email, password_hash, role, status, must_change_password) VALUES (?, ?, ?, ?, 1)'
            )->execute([$email, $hash, 'student', 'active']);
        } catch (PDOException $e) {
            $db->prepare(
                'INSERT INTO users (email, password_hash, role, status) VALUES (?, ?, ?, ?)'
            )->execute([$email, $hash, 'student', 'active']);
        }
        $userId = (int) $db->lastInsertId();

        $db->prepare(
            'INSERT INTO user_profiles (user_id, first_name, last_name, phone) VALUES (?, ?, ?, ?)'
        )->execute([$userId, $firstName, $lastName, $phone]);

        $db->prepare('UPDATE students SET user_id = ? WHERE id = ?')->execute([$userId, $studentId]);
    }

    auditLog($resetPassword ? 'student_portal_reset' : 'student_portal_created', 'student', $studentId);

    return [
        'email'          => $email,
        'temp_password'  => $tempPassword,
        'student_number' => $student['student_number'],
        'is_new'         => $isNew,
    ];
}

function studentPortalLoginFailure(): ?string
{
    return $_SESSION['login_error_detail'] ?? null;
}

function studentPortalLogin(string $identifier, string $password): bool
{
    unset($_SESSION['login_error_detail']);
    $identifier = trim($identifier);
    if ($identifier === '' || $password === '') {
        $_SESSION['login_error_detail'] = 'Please enter your Student ID (or email) and password.';
        return false;
    }

    $db = getDB();
    $studentNumberKey = strtoupper(str_replace([' ', '-'], '', $identifier));

    // Lookup by student number (normalized, case-insensitive)
    $stmt = $db->prepare(
        'SELECT u.*, p.first_name, p.last_name, p.avatar, s.id AS student_id, s.student_number, s.enrollment_status, s.user_id
         FROM students s
         LEFT JOIN users u ON u.id = s.user_id
         LEFT JOIN user_profiles p ON p.user_id = u.id
         WHERE UPPER(REPLACE(REPLACE(s.student_number, \' \', \'\'), \'-\', \'\')) = ?'
    );
    $stmt->execute([$studentNumberKey]);
    $row = $stmt->fetch();

    if ($row && empty($row['user_id'])) {
        $_SESSION['login_error_detail'] = 'Your student record exists but no portal login has been set up yet. Please contact the registrar to activate your portal account.';
        return false;
    }

    $user = null;
    if ($row && !empty($row['id']) && $row['role'] === 'student') {
        $user = $row;
    }

    if (!$user) {
        $stmt = $db->prepare(
            'SELECT u.*, p.first_name, p.last_name, p.avatar, s.id AS student_id, s.student_number, s.enrollment_status
             FROM users u
             JOIN students s ON s.user_id = u.id
             JOIN user_profiles p ON p.user_id = u.id
             WHERE u.role = ? AND u.status = ? AND LOWER(u.email) = LOWER(?)'
        );
        $stmt->execute(['student', 'active', $identifier]);
        $user = $stmt->fetch();
    }

    if (!$user) {
        $_SESSION['login_error_detail'] = 'No portal account found for that Student ID or email.';
        return false;
    }

    if (!password_verify($password, $user['password_hash'])) {
        $_SESSION['login_error_detail'] = 'Incorrect password. If this is your first login, use the temporary password from enrollment (format: Mssht + last 4 digits of your Student ID, e.g. Mssht1699 for MSSHT2691699).';
        return false;
    }

    if (!in_array($user['enrollment_status'], ['active', 'deferred'], true)) {
        $_SESSION['login_error_detail'] = 'Your enrollment is not active. Please contact the registrar.';
        return false;
    }

    $db->prepare('UPDATE users SET last_login = NOW() WHERE id = ?')->execute([$user['id']]);

    unset($user['password_hash']);
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['user'] = $user;
    $_SESSION['student_id'] = (int) $user['student_id'];
    $_SESSION['login_portal'] = 'student';

    auditLog('student_portal_login', 'student', (int) $user['student_id']);
    return true;
}

function loadSessionUser(int $userId): void
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT u.*, p.first_name, p.last_name, p.avatar
         FROM users u
         LEFT JOIN user_profiles p ON p.user_id = u.id
         WHERE u.id = ? AND u.status = ?'
    );
    $stmt->execute([$userId, 'active']);
    $user = $stmt->fetch();
    if ($user) {
        unset($user['password_hash']);
        $_SESSION['user'] = $user;
        if ($user['role'] === 'student') {
            $s = $db->prepare('SELECT id FROM students WHERE user_id = ?');
            $s->execute([$userId]);
            $sid = $s->fetchColumn();
            if ($sid) {
                $_SESSION['student_id'] = (int) $sid;
            }
        }
    }
}

function mustChangePassword(): bool
{
    $user = currentUser();
    return !empty($user['must_change_password']);
}

function requirePasswordChanged(): void
{
    if (isLoggedIn() && mustChangePassword() && isStudentPortal()) {
        redirect(url('student-activate.php'));
    }
}

function getStudentDashboardData(): array
{
    $studentId = getCurrentStudentId();
    if (!$studentId) {
        return [];
    }
    $db = getDB();
    $data = [
        'invoices_due'    => 0,
        'balance'         => 0,
        'assignments_due' => 0,
        'modules_count'   => 0,
    ];

    $stmt = $db->prepare(
        "SELECT COUNT(*) FROM invoices WHERE student_id = ? AND status IN ('pending','partial','overdue')"
    );
    $stmt->execute([$studentId]);
    $data['invoices_due'] = (int) $stmt->fetchColumn();

    $stmt = $db->prepare(
        "SELECT COALESCE(SUM(total_amount - amount_paid), 0) FROM invoices
         WHERE student_id = ? AND status IN ('pending','partial','overdue')"
    );
    $stmt->execute([$studentId]);
    $data['balance'] = (float) $stmt->fetchColumn();

    $stmt = $db->prepare('SELECT COUNT(*) FROM module_registrations WHERE student_id = ?');
    $stmt->execute([$studentId]);
    $data['modules_count'] = (int) $stmt->fetchColumn();

    return $data;
}
