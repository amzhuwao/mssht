<?php
/**
 * Application configuration - MSSHT
 */

define('APP_NAME', 'Manica Skyview SHT');
define('APP_FULL_NAME', 'Manica Skyview School of Hospitality and Tourism');
define('APP_VERSION', '1.0.0');
define('APP_URL', 'http://localhost/mssht');
define('APP_ROOT', dirname(__DIR__));
define('UPLOAD_PATH', APP_ROOT . '/uploads');
define('UPLOAD_URL', APP_URL . '/uploads');

define('SESSION_LIFETIME', 3600 * 8); // 8 hours

// Set to false on production servers
define('APP_DEBUG', true);

date_default_timezone_set('Africa/Harare');

// Role labels for display
define('ROLES', [
    'super_admin'       => 'Super Administrator',
    'registrar'         => 'Registrar / Academic Admin',
    'finance'           => 'Finance Officer',
    'lecturer'          => 'Lecturer / Trainer',
    'student'           => 'Student',
    'hod'               => 'HOD / Dean',
    'librarian'         => 'Librarian',
    'external_examiner' => 'External Examiner',
]);

// Module access by role
define('ROLE_MODULES', [
    'super_admin' => ['dashboard', 'admissions', 'programs', 'students', 'classes', 'timetable', 'lms', 'attendance', 'exams', 'finance', 'hr', 'library', 'placements', 'messages', 'reports', 'graduation', 'settings', 'users', 'notifications'],
    'registrar'   => ['dashboard', 'admissions', 'programs', 'students', 'classes', 'timetable', 'exams', 'reports', 'graduation', 'messages'],
    'finance'     => ['dashboard', 'finance', 'students', 'reports', 'messages'],
    'lecturer'    => ['dashboard', 'classes', 'lms', 'attendance', 'exams', 'timetable', 'messages'],
    'student'     => ['dashboard', 'classes', 'lms', 'attendance', 'exams', 'finance', 'library', 'placements', 'messages', 'notifications'],
    'hod'         => ['dashboard', 'programs', 'students', 'classes', 'timetable', 'exams', 'reports', 'messages'],
    'librarian'   => ['dashboard', 'library', 'messages'],
    'external_examiner' => ['dashboard', 'exams', 'messages'],
]);

define('MODULE_CATALOG', array_values(array_unique(array_merge(...array_values(ROLE_MODULES)))));

require_once __DIR__ . '/../includes/debug.php';
