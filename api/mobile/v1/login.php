<?php
/**
 * POST /api/mobile/v1/login.php
 * Body: { "identifier": "...", "password": "...", "device_name": "Pixel 8", "portal": "student"|"staff"|"auto" }
 */
require_once __DIR__ . '/_bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    mobileJson(['ok' => false, 'error' => 'Method not allowed'], 405);
}

$body = mobileReadJsonBody();
$identifier = trim((string) ($body['identifier'] ?? ''));
$password = (string) ($body['password'] ?? '');
$deviceName = trim((string) ($body['device_name'] ?? 'Android'));
$portal = strtolower(trim((string) ($body['portal'] ?? 'auto')));

if ($identifier === '' || $password === '') {
    mobileJson(['ok' => false, 'error' => 'Identifier and password are required'], 422);
}

$db = getDB();
$ok = false;

if ($portal === 'staff') {
    $ok = login($identifier, $password);
} elseif ($portal === 'student') {
    $ok = studentPortalLogin($identifier, $password);
} else {
    // Prefer student ID / student portal, then staff email.
    $ok = studentPortalLogin($identifier, $password);
    if (!$ok) {
        $ok = login($identifier, $password);
    }
}

if (!$ok) {
    $err = studentPortalLoginFailure() ?? 'Invalid credentials';
    mobileJson(['ok' => false, 'error' => $err], 401);
}

$userId = (int) ($_SESSION['user_id'] ?? 0);
if ($userId <= 0) {
    mobileJson(['ok' => false, 'error' => 'Login succeeded but session user missing'], 500);
}

$issued = mobileIssueToken($db, $userId, $deviceName);
$stmt = $db->prepare(
    'SELECT u.id AS user_id, u.email, u.role, u.status, u.must_change_password,
            p.first_name, p.last_name, s.id AS student_id, s.student_number
     FROM users u
     LEFT JOIN user_profiles p ON p.user_id = u.id
     LEFT JOIN students s ON s.user_id = u.id
     WHERE u.id = ?'
);
$stmt->execute([$userId]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);
if (!$row) {
    mobileJson(['ok' => false, 'error' => 'User not found after login'], 500);
}

// Mobile clients use bearer tokens; clear PHP session cookie side-effects.
$_SESSION = [];

mobileJson([
    'ok' => true,
    'token' => $issued['token'],
    'expires_at' => $issued['expires_at'],
    'user' => mobileUserPayload($row),
    'server_time' => gmdate('c'),
]);
