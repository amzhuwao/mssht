<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('hr');

$pageTitle = 'Human Resources';
$currentModule = 'hr';
$db = getDB();

$staff = $db->query(
    'SELECT s.*, u.email, p.first_name, p.last_name
     FROM staff s JOIN users u ON u.id = s.user_id
    LEFT JOIN user_profiles p ON p.user_id = u.id ORDER BY s.hire_date DESC'
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Staff Records</h2></div>
    <div class="card-body table-wrap">
        <?php if (empty($staff)): ?>
        <p class="empty-state">No staff records. Add users with staff roles via User Management.</p>
        <?php else: ?>
        <table class="data-table">
            <thead><tr><th>Staff #</th><th>Name</th><th>Email</th><th>Department</th><th>Position</th><th>Hired</th></tr></thead>
            <tbody>
            <?php foreach ($staff as $s): ?>
            <tr>
                <td><?= e($s['staff_number']) ?></td>
                <td><?= e(trim(($s['first_name'] ?? '') . ' ' . ($s['last_name'] ?? '')) ?: '—') ?></td>
                <td><?= e($s['email']) ?></td>
                <td><?= e($s['department'] ?? '—') ?></td>
                <td><?= e($s['position'] ?? '—') ?></td>
                <td><?= formatDate($s['hire_date']) ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
