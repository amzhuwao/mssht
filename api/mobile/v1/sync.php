<?php
/**
 * GET /api/mobile/v1/sync.php?since=ISO8601
 * Returns dashboard snapshot for offline cache.
 */
require_once __DIR__ . '/_bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    mobileJson(['ok' => false, 'error' => 'Method not allowed'], 405);
}

$db = getDB();
$user = mobileRequireUser($db);
$since = trim((string) ($_GET['since'] ?? ''));
$sinceSql = null;
if ($since !== '') {
    $ts = strtotime($since);
    if ($ts !== false) {
        $sinceSql = date('Y-m-d H:i:s', $ts);
    }
}

$notifications = [];
try {
    $sql = 'SELECT id, title, body, is_read, created_at
            FROM notifications
            WHERE user_id = ?';
    $params = [(int) $user['user_id']];
    if ($sinceSql) {
        $sql .= ' AND created_at >= ?';
        $params[] = $sinceSql;
    }
    $sql .= ' ORDER BY created_at DESC LIMIT 50';
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (Throwable $e) {
    $notifications = [];
}

$invoices = [];
$classes = [];
$stats = [
    'notifications_unread' => 0,
    'open_invoices' => 0,
    'active_classes' => 0,
];

if (!empty($user['student_id'])) {
    $studentId = (int) $user['student_id'];
    try {
        $inv = $db->prepare(
            "SELECT i.id, i.invoice_number, i.status, i.total_amount, i.balance_due, i.due_date, i.updated_at
             FROM invoices i
             WHERE i.student_id = ?
             ORDER BY i.due_date DESC
             LIMIT 30"
        );
        $inv->execute([$studentId]);
        $invoices = $inv->fetchAll(PDO::FETCH_ASSOC);
        $c = $db->prepare("SELECT COUNT(*) FROM invoices WHERE student_id = ? AND status IN ('issued','partial','overdue')");
        $c->execute([$studentId]);
        $stats['open_invoices'] = (int) $c->fetchColumn();
    } catch (Throwable $e) {
        $invoices = [];
    }

    try {
        $cls = $db->prepare(
            "SELECT c.id, c.name, c.join_code, c.status
             FROM class_members cm
             JOIN virtual_classes c ON c.id = cm.class_id
             WHERE cm.user_id = ?
             ORDER BY c.name
             LIMIT 30"
        );
        $cls->execute([(int) $user['user_id']]);
        $classes = $cls->fetchAll(PDO::FETCH_ASSOC);
        $stats['active_classes'] = count($classes);
    } catch (Throwable $e) {
        // Fallback table names if classroom migration naming differs
        try {
            $cls = $db->prepare(
                "SELECT vc.id, vc.title AS name, vc.join_code, vc.status
                 FROM classroom_members cm
                 JOIN classrooms vc ON vc.id = cm.classroom_id
                 WHERE cm.user_id = ?
                 LIMIT 30"
            );
            $cls->execute([(int) $user['user_id']]);
            $classes = $cls->fetchAll(PDO::FETCH_ASSOC);
            $stats['active_classes'] = count($classes);
        } catch (Throwable $e2) {
            $classes = [];
        }
    }
}

foreach ($notifications as $n) {
    if (empty($n['is_read'])) {
        $stats['notifications_unread']++;
    }
}

mobileJson([
    'ok' => true,
    'server_time' => gmdate('c'),
    'user' => mobileUserPayload($user),
    'stats' => $stats,
    'notifications' => array_map(static function ($n) {
        return [
            'id' => (int) $n['id'],
            'title' => $n['title'] ?? '',
            'body' => $n['body'] ?? ($n['message'] ?? ''),
            'is_read' => (int) ($n['is_read'] ?? 0) === 1,
            'created_at' => $n['created_at'] ?? null,
        ];
    }, $notifications),
    'invoices' => array_map(static function ($i) {
        return [
            'id' => (int) $i['id'],
            'invoice_number' => $i['invoice_number'] ?? '',
            'status' => $i['status'] ?? '',
            'total_amount' => (float) ($i['total_amount'] ?? 0),
            'balance_due' => (float) ($i['balance_due'] ?? 0),
            'due_date' => $i['due_date'] ?? null,
            'updated_at' => $i['updated_at'] ?? null,
        ];
    }, $invoices),
    'classes' => array_map(static function ($c) {
        return [
            'id' => (int) $c['id'],
            'name' => $c['name'] ?? '',
            'join_code' => $c['join_code'] ?? null,
            'status' => $c['status'] ?? 'active',
        ];
    }, $classes),
]);
