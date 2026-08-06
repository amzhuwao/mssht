<?php
/**
 * POST /api/mobile/v1/logout.php
 * Authorization: Bearer <token>
 */
require_once __DIR__ . '/_bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    mobileJson(['ok' => false, 'error' => 'Method not allowed'], 405);
}

$db = getDB();
$token = mobileBearerToken();
if ($token) {
    mobileEnsureSchema($db);
    $db->prepare('DELETE FROM mobile_tokens WHERE token_hash = ?')->execute([hash('sha256', $token)]);
}
mobileJson(['ok' => true]);
