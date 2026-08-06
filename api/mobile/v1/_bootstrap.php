<?php
/**
 * Mobile API bootstrap — JSON only, token auth.
 */
require_once dirname(__DIR__, 2) . '/includes/bootstrap.php';

header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');

function mobileJson(array $payload, int $status = 200): void
{
    http_response_code($status);
    echo json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function mobileReadJsonBody(): array
{
    $raw = file_get_contents('php://input') ?: '';
    if ($raw === '') {
        return [];
    }
    $data = json_decode($raw, true);
    return is_array($data) ? $data : [];
}

function mobileEnsureSchema(PDO $db): void
{
    static $ready = false;
    if ($ready) {
        return;
    }
    $db->exec(
        "CREATE TABLE IF NOT EXISTS mobile_tokens (
            id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            user_id INT UNSIGNED NOT NULL,
            token_hash CHAR(64) NOT NULL UNIQUE,
            device_name VARCHAR(120) NULL,
            platform VARCHAR(40) NOT NULL DEFAULT 'android',
            push_token VARCHAR(255) NULL,
            last_seen_at DATETIME NULL,
            expires_at DATETIME NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_mobile_tokens_user (user_id),
            CONSTRAINT fk_mobile_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
         ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
    );
    $ready = true;
}

function mobileIssueToken(PDO $db, int $userId, string $deviceName = ''): array
{
    mobileEnsureSchema($db);
    $plain = bin2hex(random_bytes(32));
    $hash = hash('sha256', $plain);
    $expires = (new DateTimeImmutable('+60 days'))->format('Y-m-d H:i:s');
    $stmt = $db->prepare(
        'INSERT INTO mobile_tokens (user_id, token_hash, device_name, platform, expires_at, last_seen_at)
         VALUES (?, ?, ?, ?, ?, NOW())'
    );
    $stmt->execute([$userId, $hash, $deviceName !== '' ? $deviceName : null, 'android', $expires]);
    return ['token' => $plain, 'expires_at' => $expires];
}

function mobileBearerToken(): ?string
{
    $header = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
    if (preg_match('/Bearer\s+(\S+)/i', $header, $m)) {
        return $m[1];
    }
    return null;
}

function mobileRequireUser(PDO $db): array
{
    mobileEnsureSchema($db);
    $token = mobileBearerToken();
    if (!$token) {
        mobileJson(['ok' => false, 'error' => 'Missing bearer token'], 401);
    }
    $hash = hash('sha256', $token);
    $stmt = $db->prepare(
        'SELECT t.id AS token_id, t.user_id, t.expires_at, u.email, u.role, u.status, u.must_change_password,
                p.first_name, p.last_name, s.id AS student_id, s.student_number
         FROM mobile_tokens t
         JOIN users u ON u.id = t.user_id
         LEFT JOIN user_profiles p ON p.user_id = u.id
         LEFT JOIN students s ON s.user_id = u.id
         WHERE t.token_hash = ?
         LIMIT 1'
    );
    $stmt->execute([$hash]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!$row) {
        mobileJson(['ok' => false, 'error' => 'Invalid token'], 401);
    }
    if (strtotime($row['expires_at']) < time()) {
        mobileJson(['ok' => false, 'error' => 'Token expired'], 401);
    }
    if (($row['status'] ?? '') !== 'active') {
        mobileJson(['ok' => false, 'error' => 'Account inactive'], 403);
    }
    $db->prepare('UPDATE mobile_tokens SET last_seen_at = NOW() WHERE id = ?')->execute([(int) $row['token_id']]);
    return $row;
}

function mobileUserPayload(array $row): array
{
    return [
        'id' => (int) $row['user_id'],
        'email' => $row['email'],
        'role' => $row['role'],
        'first_name' => $row['first_name'] ?? '',
        'last_name' => $row['last_name'] ?? '',
        'display_name' => trim(($row['first_name'] ?? '') . ' ' . ($row['last_name'] ?? '')) ?: ($row['email'] ?? ''),
        'student_id' => $row['student_id'] ? (int) $row['student_id'] : null,
        'student_number' => $row['student_number'] ?? null,
        'must_change_password' => (int) ($row['must_change_password'] ?? 0) === 1,
        'portal' => ($row['role'] ?? '') === 'student' ? 'student' : 'staff',
    ];
}
