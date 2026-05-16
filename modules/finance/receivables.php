<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Accounts Receivable';
$currentModule = 'finance';
$financeSection = 'receivables';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'auto_holds') {
        $n = applyAutoFinanceHolds();
        flash('success', "Applied {$n} automatic financial hold(s).");
    }
    if ($action === 'add_hold') {
        $db->prepare('INSERT INTO finance_holds (student_id, hold_type, reason, created_by) VALUES (?, ?, ?, ?)')
           ->execute([(int)$_POST['student_id'], $_POST['hold_type'], trim($_POST['reason']), $_SESSION['user_id']]);
        flash('success', 'Financial hold placed.');
    }
    if ($action === 'lift_hold') {
        $db->prepare('UPDATE finance_holds SET is_active = 0, lifted_at = NOW(), lifted_by = ? WHERE id = ?')
           ->execute([$_SESSION['user_id'], (int)$_POST['hold_id']]);
        flash('success', 'Hold lifted.');
    }
    if ($action === 'remind' && (int)$_POST['student_id']) {
        sendPaymentReminder((int)$_POST['student_id']);
        flash('success', 'Reminder email sent (if email on file).');
    }
    if ($action === 'confirm_payment' && (int)$_POST['payment_id']) {
        confirmPayment((int)$_POST['payment_id']);
        flash('success', 'Payment confirmed.');
    }
    redirect(moduleUrl('finance', 'receivables'));
}

$aging = getAgingReport();
$holds = $db->query(
    'SELECT fh.*, s.student_number FROM finance_holds fh JOIN students s ON s.id = fh.student_id WHERE fh.is_active = 1 ORDER BY fh.created_at DESC'
)->fetchAll();
$pendingPops = $db->query(
    "SELECT p.*, i.invoice_number, s.student_number FROM payments p
     JOIN invoices i ON i.id = p.invoice_id JOIN students s ON s.id = i.student_id
     WHERE p.status = 'pending' ORDER BY p.paid_at DESC"
)->fetchAll();
$students = $db->query("SELECT id, student_number FROM students WHERE enrollment_status = 'active'")->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="page-actions">
    <form method="post" style="display:inline;">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="auto_holds">
        <button type="submit" class="btn btn-outline btn-sm">Apply auto-holds (30+ days overdue)</button>
    </form>
</div>

<?php if ($pendingPops): ?>
<div class="card"><div class="card-header"><h2>Pending proof of payment</h2></div>
<div class="card-body table-wrap"><table class="data-table"><thead><tr><th>Student</th><th>Invoice</th><th>Amount</th><th>Reference</th><th>POP</th><th></th></tr></thead><tbody>
<?php foreach ($pendingPops as $p): ?>
<tr>
    <td><?= e($p['student_number']) ?></td><td><?= e($p['invoice_number']) ?></td>
    <td><?= formatMoney((float)$p['amount'], $p['currency'] ?? 'USD') ?></td><td><?= e($p['reference'] ?? '—') ?></td>
    <td><?php if ($p['pop_file']): ?><a href="<?= e(UPLOAD_URL . '/' . $p['pop_file']) ?>" target="_blank">View</a><?php endif; ?></td>
    <td><form method="post" style="display:inline;"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="confirm_payment"><input type="hidden" name="payment_id" value="<?= (int)$p['id'] ?>"><button class="btn btn-sm btn-primary">Confirm</button></form></td>
</tr>
<?php endforeach; ?></tbody></table></div></div>
<?php endif; ?>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Aging analysis</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Student</th><th>0-30 days</th><th>31-60</th><th>61-90</th><th>120+</th><th>Total</th><th></th></tr></thead>
<tbody>
<?php foreach ($aging as $row): ?>
<tr>
    <td><strong><?= e($row['student_number']) ?></strong><br><small><?= e($row['name']) ?></small></td>
    <td><?= formatMoney((float)$row['bucket_30']) ?></td>
    <td><?= formatMoney((float)$row['bucket_60']) ?></td>
    <td><?= formatMoney((float)$row['bucket_90']) ?></td>
    <td><?= formatMoney((float)$row['bucket_120']) ?></td>
    <td><strong><?= formatMoney((float)$row['total_due']) ?></strong></td>
    <td><form method="post" style="display:inline;"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="remind"><input type="hidden" name="student_id" value="<?= (int)($row['student_id'] ?? 0) ?>"><button class="btn btn-sm btn-outline">Email reminder</button></form></td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<div class="dashboard-grid" style="margin-top:1.5rem;">
    <div class="card"><div class="card-header"><h2>Place financial hold</h2></div>
    <div class="card-body"><form method="post">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="add_hold">
        <div class="form-group"><label>Student</label><select name="student_id" required><?php foreach ($students as $s): ?><option value="<?= $s['id'] ?>"><?= e($s['student_number']) ?></option><?php endforeach; ?></select></div>
        <div class="form-group"><label>Hold type</label><select name="hold_type"><option value="exams">Exams</option><option value="registration">Registration</option><option value="results">Results</option><option value="graduation">Graduation</option><option value="general">General</option></select></div>
        <div class="form-group"><label>Reason</label><input name="reason" required></div>
        <button type="submit" class="btn btn-primary">Place hold</button>
    </form></div></div>
</div>

<div class="card"><div class="card-header"><h2>Active holds</h2></div>
<div class="card-body table-wrap"><table class="data-table"><thead><tr><th>Student</th><th>Type</th><th>Reason</th><th>Auto</th><th></th></tr></thead><tbody>
<?php foreach ($holds as $h): ?>
<tr><td><?= e($h['student_number']) ?></td><td><?= e($h['hold_type']) ?></td><td><?= e($h['reason']) ?></td><td><?= $h['auto_generated'] ? 'Yes' : 'No' ?></td>
<td><form method="post"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="lift_hold"><input type="hidden" name="hold_id" value="<?= (int)$h['id'] ?>"><button class="btn btn-sm btn-outline">Lift</button></form></td></tr>
<?php endforeach; ?>
</tbody></table></div></div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
