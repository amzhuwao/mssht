<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'General Ledger';
$currentModule = 'finance';
$financeSection = 'ledger';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    if (($_POST['action'] ?? '') === 'journal') {
        $debitAcct = (int)$_POST['debit_account'];
        $creditAcct = (int)$_POST['credit_account'];
        $amount = (float)$_POST['amount'];
        createJournalEntry([
            'description' => trim($_POST['description']),
            'lines' => [
                ['account_id' => $debitAcct, 'debit' => $amount, 'credit' => 0],
                ['account_id' => $creditAcct, 'debit' => 0, 'credit' => $amount],
            ],
        ]);
        flash('success', 'Journal entry posted.');
    }
    if (($_POST['action'] ?? '') === 'close_period' && (int)$_POST['period_id']) {
        $db->prepare('UPDATE financial_periods SET is_closed = 1, closed_at = NOW() WHERE id = ?')->execute([(int)$_POST['period_id']]);
        flash('success', 'Period closed.');
    }
    redirect(moduleUrl('finance', 'ledger'));
}

$accounts = $db->query('SELECT * FROM chart_of_accounts WHERE is_active = 1 ORDER BY code')->fetchAll();
$trialBalance = getTrialBalance();
$journals = $db->query(
    'SELECT je.*, u.email AS created_by_email FROM journal_entries je
     LEFT JOIN users u ON u.id = je.created_by ORDER BY je.created_at DESC LIMIT 30'
)->fetchAll();
$periods = $db->query('SELECT * FROM financial_periods ORDER BY start_date DESC')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="dashboard-grid">
    <div class="card"><div class="card-header"><h2>Manual journal entry</h2></div>
    <div class="card-body"><form method="post">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="journal">
        <div class="form-group"><label>Description</label><input name="description" required></div>
        <div class="form-row">
            <div class="form-group"><label>Search debit account</label><input type="text" id="debitAccountSearch" placeholder="Search debit account"></div>
            <div class="form-group"><label>Search credit account</label><input type="text" id="creditAccountSearch" placeholder="Search credit account"></div>
            <div class="form-group"><label>Debit account</label><select name="debit_account" id="debitAccountSelect" required><option value="">Select account</option><?php foreach ($accounts as $a): ?><option value="<?= (int) $a['id'] ?>"><?= e($a['code'] . ' ' . $a['name']) ?></option><?php endforeach; ?></select></div>
            <div class="form-group"><label>Credit account</label><select name="credit_account" id="creditAccountSelect" required><option value="">Select account</option><?php foreach ($accounts as $a): ?><option value="<?= (int) $a['id'] ?>"><?= e($a['code'] . ' ' . $a['name']) ?></option><?php endforeach; ?></select></div>
            <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" required></div>
        </div>
        <button type="submit" class="btn btn-primary">Post entry</button>
    </form></div></div>
</div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Trial balance</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Code</th><th>Account</th><th>Type</th><th>Debit</th><th>Credit</th><th>Balance</th></tr></thead>
<tbody>
<?php foreach ($trialBalance as $row): $bal = (float)$row['total_debit'] - (float)$row['total_credit']; ?>
<tr>
    <td><?= e($row['code']) ?></td><td><?= e($row['name']) ?></td><td><?= e($row['account_type']) ?></td>
    <td><?= formatMoney((float)$row['total_debit']) ?></td><td><?= formatMoney((float)$row['total_credit']) ?></td>
    <td><?= formatMoney(abs($bal)) ?> <?= $bal >= 0 ? 'Dr' : 'Cr' ?></td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Chart of accounts</h2></div>
<div class="card-body table-wrap"><table class="data-table"><thead><tr><th>Code</th><th>Name</th><th>Type</th></tr></thead><tbody>
<?php foreach ($accounts as $a): ?><tr><td><?= e($a['code']) ?></td><td><?= e($a['name']) ?></td><td><?= e($a['account_type']) ?></td></tr><?php endforeach; ?>
</tbody></table></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Recent journals</h2></div>
<div class="card-body table-wrap"><table class="data-table"><thead><tr><th>#</th><th>Date</th><th>Description</th><th>Source</th></tr></thead><tbody>
<?php foreach ($journals as $j): ?>
<tr><td><?= e($j['entry_number']) ?></td><td><?= formatDate($j['entry_date']) ?></td><td><?= e($j['description']) ?></td><td><?= e($j['source_type'] ?? 'manual') ?></td></tr>
<?php endforeach; ?>
</tbody></table></div></div>

<script>
msshtSearchableSelect('debitAccountSearch', 'debitAccountSelect');
msshtSearchableSelect('creditAccountSearch', 'creditAccountSelect');
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
