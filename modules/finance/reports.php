<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Financial Reports';
$currentModule = 'finance';
$financeSection = 'reports';
$db = getDB();

$export = $_GET['export'] ?? '';
$report = $_GET['report'] ?? 'dashboard';
$startDateInput = $_GET['start_date'] ?? date('Y-01-01');
$endDateInput = $_GET['end_date'] ?? date('Y-m-d');

$normalizeDate = static function (string $value, string $fallback): string {
    $date = DateTimeImmutable::createFromFormat('Y-m-d', $value);
    return $date ? $date->format('Y-m-d') : $fallback;
};

$startDate = $normalizeDate($startDateInput, date('Y-01-01'));
$endDate = $normalizeDate($endDateInput, date('Y-m-d'));
if ($startDate > $endDate) {
    [$startDate, $endDate] = [$endDate, $startDate];
}

$stats = getFinanceDashboardStats();
$trialBalance = getTrialBalance();
$aging = getAgingReport();

$monthlySummary = [];
$paymentMethodSummary = [];

try {
    $monthlyStmt = $db->prepare(
        "SELECT period, SUM(income) AS income, SUM(expenditure) AS expenditure
         FROM (
             SELECT DATE_FORMAT(paid_at, '%Y-%m') AS period, amount AS income, 0 AS expenditure
             FROM payments
             WHERE status = 'confirmed' AND DATE(paid_at) BETWEEN ? AND ?
             UNION ALL
             SELECT DATE_FORMAT(paid_at, '%Y-%m') AS period, 0 AS income, amount AS expenditure
             FROM payable_payments
             WHERE DATE(paid_at) BETWEEN ? AND ?
         ) financial_movements
         GROUP BY period
         ORDER BY period ASC"
    );
    $monthlyStmt->execute([$startDate, $endDate, $startDate, $endDate]);
    $monthlyRows = $monthlyStmt->fetchAll();
    $monthlyIndex = [];
    foreach ($monthlyRows as $row) {
        $monthlyIndex[$row['period']] = [
            'income' => (float) $row['income'],
            'expenditure' => (float) $row['expenditure'],
        ];
    }

    $periodStart = new DateTimeImmutable($startDate . ' 00:00:00');
    $periodEnd = new DateTimeImmutable($endDate . ' 23:59:59');
    $cursor = $periodStart->modify('first day of this month');
    $cursorEnd = $periodEnd->modify('first day of this month');
    while ($cursor <= $cursorEnd) {
        $periodKey = $cursor->format('Y-m');
        $monthlySummary[] = [
            'period' => $cursor->format('M Y'),
            'income' => $monthlyIndex[$periodKey]['income'] ?? 0.0,
            'expenditure' => $monthlyIndex[$periodKey]['expenditure'] ?? 0.0,
        ];
        $cursor = $cursor->modify('+1 month');
    }

    $methodStmt = $db->prepare(
        "SELECT payment_method, COUNT(*) AS payment_count, SUM(amount) AS total
         FROM payments
         WHERE status = 'confirmed' AND DATE(paid_at) BETWEEN ? AND ?
         GROUP BY payment_method
         ORDER BY total DESC"
    );
    $methodStmt->execute([$startDate, $endDate]);
    $paymentMethodSummary = $methodStmt->fetchAll();
} catch (Exception $e) {
    $monthlySummary = [];
    $paymentMethodSummary = [];
}

if ($export === 'csv' && $report === 'monthly') {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="monthly_income_vs_expenditure.csv"');
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Period', 'Income', 'Expenditure', 'Net']);
    foreach ($monthlySummary as $row) {
        fputcsv($out, [$row['period'], $row['income'], $row['expenditure'], $row['income'] - $row['expenditure']]);
    }
    exit;
}

if ($export === 'csv' && $report === 'methods') {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="payment_method_report.csv"');
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Payment Method', 'Transactions', 'Total']);
    foreach ($paymentMethodSummary as $row) {
        fputcsv($out, [$row['payment_method'], $row['payment_count'], $row['total']]);
    }
    exit;
}

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

$selectedPeriodIncome = array_sum(array_column($monthlySummary, 'income'));
$selectedPeriodExpenditure = array_sum(array_column($monthlySummary, 'expenditure'));
$selectedPeriodNet = $selectedPeriodIncome - $selectedPeriodExpenditure;
?>

<div class="stats-grid">
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['revenue_mtd']) ?></span><span class="stat-label">Revenue MTD</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['outstanding']) ?></span><span class="stat-label">Outstanding AR</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= $stats['debtors'] ?></span><span class="stat-label">Debtors</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['payables_due']) ?></span><span class="stat-label">Payables</span></div></div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Report filters</h2></div>
    <div class="card-body">
        <form method="get" class="form-row" style="align-items:end; gap:1rem;">
            <div class="form-group">
                <label>Start date</label>
                <input type="date" name="start_date" value="<?= e($startDate) ?>">
            </div>
            <div class="form-group">
                <label>End date</label>
                <input type="date" name="end_date" value="<?= e($endDate) ?>">
            </div>
            <div class="form-group" style="min-width:220px;">
                <label>Report export</label>
                <select name="report">
                    <option value="monthly" <?= $report === 'monthly' ? 'selected' : '' ?>>Monthly income vs expenditure</option>
                    <option value="methods" <?= $report === 'methods' ? 'selected' : '' ?>>Payments by method</option>
                    <option value="dashboard" <?= $report === 'dashboard' ? 'selected' : '' ?>>Dashboard view</option>
                    <option value="aging" <?= $report === 'aging' ? 'selected' : '' ?>>Aging report</option>
                    <option value="trial" <?= $report === 'trial' ? 'selected' : '' ?>>Trial balance</option>
                </select>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-primary">Update report</button>
            </div>
        </form>
    </div>
</div>

<div class="stats-grid" style="margin-top:1.5rem;">
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($selectedPeriodIncome) ?></span><span class="stat-label">Income in period</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($selectedPeriodExpenditure) ?></span><span class="stat-label">Expenditure in period</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($selectedPeriodNet) ?></span><span class="stat-label">Net in period</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= count($paymentMethodSummary) ?></span><span class="stat-label">Payment methods</span></div></div>
</div>

<p style="margin:1rem 0;">
    <a href="?report=monthly&amp;export=csv&amp;start_date=<?= e($startDate) ?>&amp;end_date=<?= e($endDate) ?>" class="btn btn-outline btn-sm">Export monthly CSV</a>
    <a href="?report=methods&amp;export=csv&amp;start_date=<?= e($startDate) ?>&amp;end_date=<?= e($endDate) ?>" class="btn btn-outline btn-sm">Export payment methods CSV</a>
    <a href="?export=csv&amp;report=aging" class="btn btn-outline btn-sm">Export aging (CSV)</a>
    <a href="?export=csv&amp;report=trial" class="btn btn-outline btn-sm">Export trial balance (CSV)</a>
</p>

<div class="card"><div class="card-header"><h2>Monthly income vs expenditure</h2></div>
<div class="card-body table-wrap"><table class="data-table"><thead><tr><th>Period</th><th>Income</th><th>Expenditure</th><th>Net</th></tr></thead><tbody>
<?php if (empty($monthlySummary)): ?>
<tr><td colspan="4" class="empty-state">No transactions found for the selected period.</td></tr>
<?php else: foreach ($monthlySummary as $row): ?>
<tr>
    <td><?= e($row['period']) ?></td>
    <td><?= formatMoney((float)$row['income']) ?></td>
    <td><?= formatMoney((float)$row['expenditure']) ?></td>
    <td><?= formatMoney((float)$row['income'] - (float)$row['expenditure']) ?></td>
</tr>
<?php endforeach; endif; ?>
</tbody></table></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Payments by method</h2></div>
<div class="card-body table-wrap"><table class="data-table"><thead><tr><th>Method</th><th>Transactions</th><th>Total</th></tr></thead><tbody>
<?php if (empty($paymentMethodSummary)): ?>
<tr><td colspan="3" class="empty-state">No confirmed payments found for the selected period.</td></tr>
<?php else: foreach ($paymentMethodSummary as $row): ?>
<tr>
    <td><?= e(ucfirst($row['payment_method'])) ?></td>
    <td><?= (int)$row['payment_count'] ?></td>
    <td><?= formatMoney((float)$row['total']) ?></td>
</tr>
<?php endforeach; endif; ?>
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
