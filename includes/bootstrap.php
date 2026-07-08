<?php
/**
 * Application bootstrap
 */

require_once __DIR__ . '/../config/app.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/helpers.php';
require_once __DIR__ . '/app-settings.php';
require_once __DIR__ . '/auth.php';
require_once __DIR__ . '/student-auth.php';
require_once __DIR__ . '/classroom.php';
require_once __DIR__ . '/mailer.php';
require_once __DIR__ . '/rubric.php';
require_once __DIR__ . '/guardian.php';
require_once __DIR__ . '/pdf.php';
require_once __DIR__ . '/finance.php';
require_once __DIR__ . '/reports.php';
require_once __DIR__ . '/backup.php';

// Redirect students who must change their temporary password
if (isLoggedIn()) {
    $skip = ['student-activate.php', 'logout.php'];
    if (!in_array(basename($_SERVER['PHP_SELF'] ?? ''), $skip, true)) {
        requirePasswordChanged();
    }
}

if (session_status() === PHP_SESSION_NONE) {
    session_set_cookie_params([
        'lifetime' => SESSION_LIFETIME,
        'path'     => '/',
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}

// Ensure upload directories exist
$uploadDirs = ['applications', 'students', 'lms', 'assignments', 'avatars', 'classroom'];
foreach ($uploadDirs as $dir) {
    $path = UPLOAD_PATH . '/' . $dir;
    if (!is_dir($path)) {
        mkdir($path, 0755, true);
    }
}

if (!is_dir(BACKUP_PATH)) {
    mkdir(BACKUP_PATH, 0755, true);
}
