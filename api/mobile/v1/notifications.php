<?php
/**
 * GET /api/mobile/v1/notifications.php
 */
require_once __DIR__ . '/_bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    mobileJson(['ok' => false, 'error' => 'Method not allowed'], 405);
}

$db = getDB();
$user = mobileRequireUser($db);

try {
    $stmt = $db->prepare(
        'SELECT id, title, body, is_read, created_at
         FROM notifications
         WHERE user_id = ?
         ORDER BY created_at DESC
         LIMIT 100'
    );
    $stmt->execute([(int) $user['user_id']]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    $rows = [];
}

mobileJson([
    'ok' => true,
    'notifications' => array_map(static function ($n) {
        return [
            'id' => (int) $n['id'],
            'title' => $n['title'] ?? '',
            'body' => $n['body'] ?? '',
            'is_read' => (int) ($n['is_read'] ?? 0) === 1,
            'created_at' => $n['created_at'] ?? null,
        ];
    }, $rows),
    'server_time' => gmdate('c'),
]);
