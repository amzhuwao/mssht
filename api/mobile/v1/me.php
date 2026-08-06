<?php
/**
 * GET /api/mobile/v1/me.php
 * Authorization: Bearer <token>
 */
require_once __DIR__ . '/_bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    mobileJson(['ok' => false, 'error' => 'Method not allowed'], 405);
}

$db = getDB();
$user = mobileRequireUser($db);
mobileJson([
    'ok' => true,
    'user' => mobileUserPayload($user),
    'server_time' => gmdate('c'),
]);
