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

function getUserModulePermissions(?int $userId = null): array
{
    static $cache = [];
    $userId = $userId ?? (int) ($_SESSION['user_id'] ?? 0);
    if (!$userId) {
        return [];
    }
    if (array_key_exists($userId, $cache)) {
        return $cache[$userId];
    }

    try {
        $db = getDB();
        $stmt = $db->prepare('SELECT module_name, access FROM user_module_permissions WHERE user_id = ?');
        $stmt->execute([$userId]);
        $permissions = [];
        foreach ($stmt->fetchAll() as $row) {
            $permissions[$row['module_name']] = $row['access'];
        }
        $cache[$userId] = $permissions;
        return $permissions;
    } catch (Exception $e) {
        return $cache[$userId] = [];
    }
}

function getAccessibleModules(?int $userId = null): array
{
    $role = currentRole();
    $modules = getRoleModules($role);
    $permissions = getUserModulePermissions($userId);

    foreach ($permissions as $moduleName => $access) {
        if ($access === 'deny') {
            $modules = array_values(array_diff($modules, [$moduleName]));
        }
    }

    foreach ($permissions as $moduleName => $access) {
        if ($access === 'allow' && !in_array($moduleName, $modules, true)) {
            $modules[] = $moduleName;
        }
    }

    return array_values(array_unique($modules));
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
    $permissions = getUserModulePermissions();
    if (($permissions[$module] ?? null) === 'deny') {
        return false;
    }
    if (($permissions[$module] ?? null) === 'allow') {
        return true;
    }
    $modules = getRoleModules($role);
    return in_array($module, $modules, true);
}

function requireModule(string $module): void
{
    requireLogin();
    if (currentRole() === 'student' && function_exists('studentPortalHasApprovedAccess') && !studentPortalHasApprovedAccess()) {
        flash('warning', 'Please complete your application approval process before accessing this module.');
        redirect(url('dashboard.php'));
    }
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
        auditLog('login_failed', 'user', $user['id'] ?? null);
        return false;
    }

    // Students must use the dedicated student portal login
    if ($user['role'] === 'student') {
        auditLog('login_failed', 'user', (int) $user['id']);
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

function logout(): bool
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
