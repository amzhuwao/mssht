<?php
/**
 * Application configuration - MSSHT
 */

define('APP_NAME', 'Manica Skyview SHT');
define('APP_FULL_NAME', 'Manica Skyview School of Hospitality and Tourism');
define('APP_VERSION', '1.0.0');
define('APP_ROOT', dirname(__DIR__));

if (!defined('APP_URL')) {
    $configuredUrl = getenv('APP_URL') ?: '';
    if ($configuredUrl !== '') {
        define('APP_URL', rtrim($configuredUrl, '/'));
    } elseif (PHP_SAPI !== 'cli' && !empty($_SERVER['HTTP_HOST'])) {
        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
            || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https')
            || (int) ($_SERVER['SERVER_PORT'] ?? 80) === 443
            ? 'https'
            : 'http';

        // Compute application base path relative to the web server document root so
        // asset URLs remain correct regardless of the executing script's subdirectory.
        $docRoot = rtrim(str_replace('\\', '/', realpath($_SERVER['DOCUMENT_ROOT'] ?? '') ?: ''), '/');
        $appRoot = rtrim(str_replace('\\', '/', realpath(APP_ROOT) ?: ''), '/');
        $basePath = '';
        if ($docRoot !== '' && strpos($appRoot, $docRoot) === 0) {
            $basePath = substr($appRoot, strlen($docRoot));
            $basePath = $basePath !== '' ? '/' . ltrim($basePath, '/') : '';
        } else {
            // Fallback: use the parent directory of the current script
            $basePath = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? '')), '/');
        }

        define('APP_URL', $scheme . '://' . $_SERVER['HTTP_HOST'] . ($basePath !== '' ? $basePath : ''));
    } else {
        // CLI / unknown host fallback — keep generic host only.
        // Override with the APP_URL environment variable in real deployments.
        define('APP_URL', 'http://localhost');
    }
}

define('UPLOAD_PATH', APP_ROOT . '/uploads');
define('UPLOAD_URL', APP_URL . '/uploads');

define('SESSION_LIFETIME', 3600 * 8); // 8 hours

// Set to false on production servers
define('APP_DEBUG', true);

date_default_timezone_set('Africa/Harare');

// Default role labels for display and bootstrap seeding
define('DEFAULT_ROLES', [
    'super_admin'       => 'Super Administrator',
    'registrar'         => 'Registrar / Academic Admin',
    'finance'           => 'Finance Officer',
    'lecturer'          => 'Lecturer / Trainer',
    'student'           => 'Student',
    'hod'               => 'HOD / Dean',
    'librarian'         => 'Librarian',
    'external_examiner' => 'External Examiner',
]);

// Default module access by role for bootstrap seeding
define('DEFAULT_ROLE_MODULES', [
    'super_admin' => ['dashboard', 'admissions', 'programs', 'students', 'classes', 'timetable', 'lms', 'attendance', 'exams', 'finance', 'hr', 'library', 'placements', 'messages', 'reports', 'graduation', 'settings', 'users', 'notifications'],
    'registrar'   => ['dashboard', 'admissions', 'programs', 'students', 'classes', 'timetable', 'exams', 'reports', 'graduation', 'messages'],
    'finance'     => ['dashboard', 'finance', 'students', 'reports', 'messages'],
    'lecturer'    => ['dashboard', 'classes', 'lms', 'attendance', 'exams', 'timetable', 'messages'],
    'student'     => ['dashboard', 'classes', 'lms', 'attendance', 'exams', 'finance', 'library', 'placements', 'messages', 'notifications'],
    'hod'         => ['dashboard', 'programs', 'students', 'classes', 'timetable', 'exams', 'reports', 'messages'],
    'librarian'   => ['dashboard', 'library', 'messages'],
    'external_examiner' => ['dashboard', 'exams', 'messages'],
]);

define('ROLES', DEFAULT_ROLES);
define('ROLE_MODULES', DEFAULT_ROLE_MODULES);

define('MODULE_CATALOG', array_values(array_unique(array_merge(...array_values(ROLE_MODULES)))));

require_once __DIR__ . '/../includes/debug.php';
