<?php
/**
 * POST /api/mobile/v1/device.php
 * Register / update FCM push token
 * Body: { "push_token": "...", "device_name": "..." }
 */
require_once __DIR__ . '/_bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    mobileJson(['ok' => false, 'error' => 'Method not allowed'], 405);
}

$db = getDB();
$user = mobileRequireUser($db);
$body = mobileReadJsonBody();
$push = trim((string) ($body['push_token'] ?? ''));
$deviceName = trim((string) ($body['device_name'] ?? ''));

if ($push === '') {
    mobileJson(['ok' => false, 'error' => 'push_token is required'], 422);
}

$token = mobileBearerToken();
$hash = hash('sha256', (string) $token);
$stmt = $db->prepare(
    'UPDATE mobile_tokens
     SET push_token = ?, device_name = COALESCE(NULLIF(?, ""), device_name), last_seen_at = NOW()
     WHERE token_hash = ?'
);
$stmt->execute([$push, $deviceName, $hash]);

mobileJson(['ok' => true]);
