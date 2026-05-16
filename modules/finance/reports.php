<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Financial Reports';
$currentModule = 'finance';
$financeSection = 'reports';
$db = getDB();

$export = $_GET['export'] ?? '';
$report = $_GET['report'] ?? 'dashboard';

$stats = getFinanceDashboardStats();
$trialBalance = getTrialBalance();
$aging = getAgingReport();

$revenueByMonth = $db->query(
    "SELECT DATE_FORMAT(paid_at, '%Y-%m') AS period, SUM(amount) AS total
     FROM payments WHERE status = 'confirmed' GROUP BY period ORDER BY period DESC LIMIT 12"
)->fetchAll();

if ($export === 'csv' && $report === 'aging') {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="aging_report.csv"');
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Student', 'Name', '0-30', '31-60', '61-90', '120+', 'Total']);
    foreach ($aging as $row) {
        fputcsv($out, [$row['student_number'], $row['name'], $row['bucket_30'], $row['bucket_60'], $row['bucket_90'], $row['bucket_120'], $row['total_due']]);
    }
    exit;
}

if ($export === 'csv' && $report === 'trial') {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="trial_balance.csv"');
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Code', 'Account', 'Type', 'Debit', 'Credit']);
    foreach ($trialBalance as $row) {
        fputcsv($out, [$row['code'], $row['name'], $row['account_type'], $row['total_debit'], $row['total_credit']]);
    }
    exit;
}

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="stats-grid">
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['revenue_mtd']) ?></span><span class="stat-label">Revenue MTD</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['outstanding']) ?></span><span class="stat-label">Outstanding AR</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= $stats['debtors'] ?></span><span class="stat-label">Debtors</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['payables_due']) ?></span><span class="stat-label">Payables</span></div></div>
</div>

<p style="margin:1rem 0;">
    <a href="?export=csv&amp;report=aging" class="btn btn-outline btn-sm">Export aging (CSV)</a>
    <a href="?export=csv&amp;report=trial" class="btn btn-outline btn-sm">Export trial balance (CSV)</a>
</p>

<div class="card"><div class="card-header"><h2>Income summary (collections by month)</h2></div>
<div class="card-body table-wrap"><table class="data-table"><thead><tr><th>Period</th><th>Collected</th></tr></thead><tbody>
<?php foreach ($revenueByMonth as $r): ?>
<tr><td><?= e($r['period']) ?></td><td><?= formatMoney((float)$r['total']) ?></td></tr>
<?php endforeach; ?>
</tbody></table></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Trial balance (simplified)</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Code</th><th>Account</th><th>Debit</th><th>Credit</th></tr></thead>
<tbody>
<?php
$totalDr = 0; $totalCr = 0;
foreach ($trialBalance as $row):
    $totalDr += (float)$row['total_debit'];
    $totalCr += (float)$row['total_credit'];
?>
<tr><td><?= e($row['code']) ?></td><td><?= e($row['name']) ?></td><td><?= formatMoney((float)$row['total_debit']) ?></td><td><?= formatMoney((float)$row['total_credit']) ?></td></tr>
<?php endforeach; ?>
<tr><td colspan="2"><strong>Totals</strong></td><td><strong><?= formatMoney($totalDr) ?></strong></td><td><strong><?= formatMoney($totalCr) ?></strong></td></tr>
</tbody></table></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Top debtors (aging)</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Student</th><th>Total due</th></tr></thead>
<tbody>
<?php foreach (array_slice($aging, 0, 15) as $row): ?>
<tr><td><?= e($row['student_number']) ?> — <?= e($row['name']) ?></td><td><?= formatMoney((float)$row['total_due']) ?></td></tr>
<?php endforeach; ?>
</tbody></table></div></div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
