<?php
/**
 * Helper functions
 */

function e(?string $value): string
{
    return htmlspecialchars($value ?? '', ENT_QUOTES, 'UTF-8');
}

function redirect(string $url): void
{
    header('Location: ' . $url);
    exit;
}

function url(string $path = ''): string
{
    return rtrim(APP_URL, '/') . '/' . ltrim($path, '/');
}

function asset(string $path): string
{
    return url('assets/' . ltrim($path, '/'));
}

function moduleUrl(string $module, string $action = 'index'): string
{
    return url('modules/' . $module . '/' . $action . '.php');
}

function flash(string $type, string $message): void
{
    $_SESSION['flash'] = ['type' => $type, 'message' => $message];
}

function getFlash(): ?array
{
    if (!empty($_SESSION['flash'])) {
        $flash = $_SESSION['flash'];
        unset($_SESSION['flash']);
        return $flash;
    }
    return null;
}

function csrfToken(): string
{
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function verifyCsrf(?string $token): bool
{
    return $token && isset($_SESSION['csrf_token']) && hash_equals($_SESSION['csrf_token'], $token);
}

function generateRef(string $prefix = 'APP'): string
{
    return $prefix . '-' . date('Y') . '-' . strtoupper(substr(uniqid(), -6));
}

function generateStudentNumber(): string
{
    return 'MSSHT' . date('y') . str_pad((string) random_int(1, 99999), 5, '0', STR_PAD_LEFT);
}

function formatDate(?string $date, string $format = 'd M Y'): string
{
    if (!$date) return '—';
    return date($format, strtotime($date));
}

function formatMoney(float $amount): string
{
    return 'USD ' . number_format($amount, 2);
}

function programTypeLabel(string $type): string
{
    $labels = [
        'short_course' => 'Short Course',
        'certificate'    => 'Professional Certificate',
        'diploma'        => 'Diploma',
        'hnd'            => 'Higher National Diploma',
    ];
    return $labels[$type] ?? $type;
}

function statusBadge(string $status): string
{
    $map = [
        'pending'      => 'badge-warning',
        'under_review' => 'badge-info',
        'approved'     => 'badge-success',
        'rejected'     => 'badge-danger',
        'active'       => 'badge-success',
        'inactive'     => 'badge-secondary',
        'paid'         => 'badge-success',
        'partial'      => 'badge-warning',
        'overdue'      => 'badge-danger',
        'open'         => 'badge-success',
        'closed'       => 'badge-secondary',
    ];
    $class = $map[$status] ?? 'badge-secondary';
    return '<span class="badge ' . $class . '">' . e(ucfirst(str_replace('_', ' ', $status))) . '</span>';
}

function auditLog(string $action, ?string $entityType = null, ?int $entityId = null): void
{
    try {
        $db = getDB();
        $stmt = $db->prepare(
            'INSERT INTO audit_logs (user_id, action, entity_type, entity_id, ip_address) VALUES (?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            $_SESSION['user_id'] ?? null,
            $action,
            $entityType,
            $entityId,
            $_SERVER['REMOTE_ADDR'] ?? null,
        ]);
    } catch (Exception $e) {
        // Silent fail for audit
    }
}

function paginate(int $total, int $page, int $perPage = 20): array
{
    $totalPages = max(1, (int) ceil($total / $perPage));
    $page = max(1, min($page, $totalPages));
    $offset = ($page - 1) * $perPage;
    return [
        'total'       => $total,
        'per_page'    => $perPage,
        'current'     => $page,
        'total_pages' => $totalPages,
        'offset'      => $offset,
    ];
}

function jsonResponse(array $data, int $code = 200): void
{
    http_response_code($code);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit;
}

function uploadFile(array $file, string $subdir, array $allowed = ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx']): ?string
{
    if ($file['error'] !== UPLOAD_ERR_OK) return null;

    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($ext, $allowed, true)) return null;

    $filename = uniqid('f_', true) . '.' . $ext;
    $destDir = UPLOAD_PATH . '/' . $subdir;
    if (!is_dir($destDir)) mkdir($destDir, 0755, true);

    $dest = $destDir . '/' . $filename;
    if (move_uploaded_file($file['tmp_name'], $dest)) {
        return $subdir . '/' . $filename;
    }
    return null;
}
