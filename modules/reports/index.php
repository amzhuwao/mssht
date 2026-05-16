<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('reports');

$pageTitle = 'Reports & Analytics';
$currentModule = 'reports';
$db = getDB();
$stats = getDashboardStats();

$enrollmentByProgram = $db->query(
    'SELECT p.name, COUNT(s.id) AS total FROM programs p
     LEFT JOIN students s ON s.program_id = p.id AND s.enrollment_status = "active"
     GROUP BY p.id ORDER BY total DESC'
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="stats-grid">
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format($stats['students']) ?></span><span class="stat-label">Active Students</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format($stats['applications']) ?></span><span class="stat-label">Total Applications</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['revenue']) ?></span><span class="stat-label">Revenue Collected</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format($stats['invoices_due']) ?></span><span class="stat-label">Outstanding Invoices</span></div></div>
</div>

<div class="card">
    <div class="card-header"><h2>Enrollment by Program</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Program</th><th>Active Students</th></tr></thead>
            <tbody>
            <?php foreach ($enrollmentByProgram as $row): ?>
            <tr><td><?= e($row['name']) ?></td><td><?= (int)$row['total'] ?></td></tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <p class="text-muted" style="margin-top:1rem;">Export to PDF/Excel — integration ready for future release.</p>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
