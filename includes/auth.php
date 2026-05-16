<?php
/**
 * Authentication & authorization
 */

function isLoggedIn(): bool
{
    return !empty($_SESSION['user_id']);
}

function currentUser(): ?array
{
    if (!isLoggedIn()) return null;
    return $_SESSION['user'] ?? null;
}

function currentRole(): ?string
{
    $user = currentUser();
    return $user['role'] ?? null;
}

function requireLogin(): void
{
    if (!isLoggedIn()) {
        flash('warning', 'Please log in to continue.');
        redirect(url('login.php'));
    }
}

function requireRole(array $roles): void
{
    requireLogin();
    if (!in_array(currentRole(), $roles, true)) {
        flash('danger', 'You do not have permission to access this page.');
        redirect(url('dashboard.php'));
    }
}

function canAccessModule(string $module): bool
{
    $role = currentRole();
    if (!$role) return false;
    $modules = ROLE_MODULES[$role] ?? [];
    return in_array($module, $modules, true);
}

function requireModule(string $module): void
{
    requireLogin();
    if (!canAccessModule($module)) {
        flash('danger', 'Access denied.');
        redirect(url('dashboard.php'));
    }
}

function login(string $email, string $password): bool
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT u.*, p.first_name, p.last_name, p.avatar
         FROM users u
         LEFT JOIN user_profiles p ON p.user_id = u.id
         WHERE u.email = ? AND u.status = ?'
    );
    $stmt->execute([$email, 'active']);
    $user = $stmt->fetch();

    if (!$user || !password_verify($password, $user['password_hash'])) {
        return false;
    }

    // Students must use the dedicated student portal login
    if ($user['role'] === 'student') {
        return false;
    }

    $db->prepare('UPDATE users SET last_login = NOW() WHERE id = ?')->execute([$user['id']]);

    unset($user['password_hash']);
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['user'] = $user;
    unset($_SESSION['student_id'], $_SESSION['login_portal']);

    auditLog('login', 'user', (int) $user['id']);
    return true;
}

function logout(): void
{
    $wasStudentPortal = ($_SESSION['login_portal'] ?? '') === 'student';
    if (isLoggedIn()) {
        auditLog('logout', 'user', (int) $_SESSION['user_id']);
    }
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $p = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $p['path'], $p['domain'], $p['secure'], $p['httponly']);
    }
    session_destroy();

    return $wasStudentPortal;
}

function getDashboardStats(): array
{
    $db = getDB();
    $role = currentRole();

    $stats = [
        'students'     => 0,
        'applications' => 0,
        'programs'     => 0,
        'pending_apps' => 0,
        'invoices_due' => 0,
        'revenue'      => 0,
    ];

    try {
        $stats['students']     = (int) $db->query("SELECT COUNT(*) FROM students WHERE enrollment_status = 'active'")->fetchColumn();
        $stats['applications'] = (int) $db->query('SELECT COUNT(*) FROM applications')->fetchColumn();
        $stats['programs']     = (int) $db->query("SELECT COUNT(*) FROM programs WHERE status = 'active'")->fetchColumn();
        $stats['pending_apps'] = (int) $db->query("SELECT COUNT(*) FROM applications WHERE status IN ('pending','under_review')")->fetchColumn();
        $stats['invoices_due'] = (int) $db->query("SELECT COUNT(*) FROM invoices WHERE status IN ('pending','partial','overdue')")->fetchColumn();
        $stats['revenue']      = (float) $db->query('SELECT COALESCE(SUM(amount),0) FROM payments')->fetchColumn();
    } catch (Exception $e) {
        // Tables may not exist yet
    }

    return $stats;
}
