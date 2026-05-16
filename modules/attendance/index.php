<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('attendance');

$pageTitle = isStudentPortal() ? 'My Attendance' : 'Attendance Management';
$currentModule = 'attendance';
$db = getDB();
$studentId = getCurrentStudentId();

if (isStudentPortal() && $studentId) {
    $records = $db->prepare(
        'SELECT ar.status, ar.marked_at, s.session_date, m.code, m.name AS module_name
         FROM attendance_records ar
         JOIN attendance_sessions s ON s.id = ar.session_id
         JOIN modules m ON m.id = s.module_id
         WHERE ar.student_id = ? ORDER BY s.session_date DESC LIMIT 50'
    );
    $records->execute([$studentId]);
    $records = $records->fetchAll();
    require_once __DIR__ . '/../../includes/header.php';
    ?>
    <div class="card">
        <div class="card-header"><h2>My Attendance Record</h2></div>
        <div class="card-body table-wrap">
            <?php if (empty($records)): ?>
            <p class="empty-state">No attendance records yet.</p>
            <?php else: ?>
            <table class="data-table">
                <thead><tr><th>Date</th><th>Module</th><th>Status</th></tr></thead>
                <tbody>
                <?php foreach ($records as $r): ?>
                <tr>
                    <td><?= formatDate($r['session_date']) ?></td>
                    <td><?= e($r['code'] . ' - ' . $r['module_name']) ?></td>
                    <td><?= statusBadge($r['status']) ?></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <?php endif; ?>
        </div>
    </div>
    <?php
    require_once __DIR__ . '/../../includes/footer.php';
    return;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $token = bin2hex(random_bytes(16));
    $db->prepare('INSERT INTO attendance_sessions (module_id, session_date, qr_token, created_by) VALUES (?, CURDATE(), ?, ?)')
       ->execute([(int)$_POST['module_id'], $token, $_SESSION['user_id']]);
    flash('success', 'Attendance session created. QR token: ' . $token);
    redirect(moduleUrl('attendance'));
}

$sessions = $db->query(
    'SELECT s.*, m.code, m.name AS module_name,
            (SELECT COUNT(*) FROM attendance_records ar WHERE ar.session_id = s.id) AS present_count
     FROM attendance_sessions s
     JOIN modules m ON m.id = s.module_id ORDER BY s.session_date DESC LIMIT 30'
)->fetchAll();
$modules = $db->query('SELECT id, code, name FROM modules')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Start QR Attendance Session</h2></div>
    <div class="card-body">
        <form method="post" class="form-row" style="align-items:flex-end;">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group">
                <label>Module</label>
                <select name="module_id" required>
                    <?php foreach ($modules as $m): ?>
                    <option value="<?= $m['id'] ?>"><?= e($m['code'] . ' - ' . $m['name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Generate Session</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Recent Sessions</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Date</th><th>Module</th><th>Present</th><th>QR Token</th></tr></thead>
            <tbody>
            <?php foreach ($sessions as $s): ?>
            <tr>
                <td><?= formatDate($s['session_date']) ?></td>
                <td><?= e($s['code']) ?></td>
                <td><?= (int)$s['present_count'] ?></td>
                <td><code><?= e($s['qr_token']) ?></code></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
