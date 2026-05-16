<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Banking & Reconciliation';
$currentModule = 'finance';
$financeSection = 'banking';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'add_account') {
        $bal = (float)$_POST['opening_balance'];
        $db->prepare('INSERT INTO bank_accounts (name, bank_name, account_number, currency, opening_balance, current_balance) VALUES (?, ?, ?, ?, ?, ?)')
           ->execute([trim($_POST['name']), trim($_POST['bank_name']), trim($_POST['account_number']), $_POST['currency'] ?? 'USD', $bal, $bal]);
        flash('success', 'Bank account added.');
    }
    if ($action === 'add_rate') {
        $db->prepare('INSERT INTO exchange_rates (from_currency, to_currency, rate, rate_date) VALUES (?, ?, ?, ?)')
           ->execute([$_POST['from_currency'], $_POST['to_currency'], (float)$_POST['rate'], $_POST['rate_date']]);
        flash('success', 'Exchange rate saved.');
    }
    if ($action === 'import_txn') {
        $amt = (float)$_POST['amount'];
        $type = $_POST['txn_type'];
        $db->prepare('INSERT INTO bank_transactions (bank_account_id, txn_date, description, reference, amount, txn_type) VALUES (?, ?, ?, ?, ?, ?)')
           ->execute([(int)$_POST['bank_account_id'], $_POST['txn_date'], trim($_POST['description']), trim($_POST['reference'] ?? ''), $amt, $type]);
        $sign = $type === 'credit' ? 1 : -1;
        $db->prepare('UPDATE bank_accounts SET current_balance = current_balance + ? WHERE id = ?')->execute([$sign * $amt, (int)$_POST['bank_account_id']]);
        flash('success', 'Transaction recorded.');
    }
    if ($action === 'match' && (int)$_POST['txn_id'] && (int)$_POST['payment_id']) {
        $db->prepare('UPDATE bank_transactions SET matched_payment_id = ?, is_reconciled = 1 WHERE id = ?')
           ->execute([(int)$_POST['payment_id'], (int)$_POST['txn_id']]);
        flash('success', 'Transaction matched to payment.');
    }
    redirect(moduleUrl('finance', 'banking'));
}

$accounts = $db->query('SELECT * FROM bank_accounts WHERE is_active = 1')->fetchAll();
$txns = $db->query(
    'SELECT bt.*, ba.name AS account_name FROM bank_transactions bt
     JOIN bank_accounts ba ON ba.id = bt.bank_account_id ORDER BY bt.txn_date DESC LIMIT 50'
)->fetchAll();
$unmatchedPayments = $db->query(
    "SELECT p.id, p.receipt_number, p.amount, p.reference, i.invoice_number FROM payments p
     JOIN invoices i ON i.id = p.invoice_id WHERE p.status = 'confirmed'
     AND p.id NOT IN (SELECT matched_payment_id FROM bank_transactions WHERE matched_payment_id IS NOT NULL)
     ORDER BY p.paid_at DESC LIMIT 30"
)->fetchAll();
$rates = $db->query('SELECT * FROM exchange_rates ORDER BY rate_date DESC LIMIT 10')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="dashboard-grid">
    <div class="card"><div class="card-header"><h2>Bank account</h2></div>
    <div class="card-body"><form method="post">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="add_account">
        <div class="form-group"><label>Account name</label><input name="name" required></div>
        <div class="form-row">
            <div class="form-group"><label>Bank</label><input name="bank_name" required></div>
            <div class="form-group"><label>Account #</label><input name="account_number" required></div>
        </div>
        <div class="form-row">
            <div class="form-group"><label>Currency</label><select name="currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
            <div class="form-group"><label>Opening balance</label><input type="number" step="0.01" name="opening_balance" value="0"></div>
        </div>
        <button type="submit" class="btn btn-primary">Add account</button>
    </form></div></div>
    <div class="card"><div class="card-header"><h2>Exchange rate</h2></div>
    <div class="card-body"><form method="post">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="add_rate">
        <div class="form-row">
            <div class="form-group"><label>From</label><select name="from_currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
            <div class="form-group"><label>To</label><select name="to_currency"><option value="ZWL">ZWL</option><option value="USD">USD</option></select></div>
            <div class="form-group"><label>Rate</label><input type="number" step="0.000001" name="rate" required></div>
            <div class="form-group"><label>Date</label><input type="date" name="rate_date" value="<?= date('Y-m-d') ?>" required></div>
        </div>
        <button type="submit" class="btn btn-outline">Save rate</button>
    </form></div></div>
</div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Bank accounts</h2></div>
<div class="card-body table-wrap"><table class="data-table"><thead><tr><th>Name</th><th>Bank</th><th>Account</th><th>Currency</th><th>Balance</th></tr></thead><tbody>
<?php foreach ($accounts as $a): ?>
<tr><td><?= e($a['name']) ?></td><td><?= e($a['bank_name']) ?></td><td><?= e($a['account_number']) ?></td><td><?= e($a['currency']) ?></td><td><?= formatMoney((float)$a['current_balance'], $a['currency']) ?></td></tr>
<?php endforeach; ?>
</tbody></table></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Record bank transaction</h2></div>
<div class="card-body"><form method="post" class="form-row">
    <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="import_txn">
    <div class="form-group"><label>Account</label><select name="bank_account_id" required><?php foreach ($accounts as $a): ?><option value="<?= $a['id'] ?>"><?= e($a['name']) ?></option><?php endforeach; ?></select></div>
    <div class="form-group"><label>Date</label><input type="date" name="txn_date" value="<?= date('Y-m-d') ?>" required></div>
    <div class="form-group"><label>Description</label><input name="description" required></div>
    <div class="form-group"><label>Reference</label><input name="reference"></div>
    <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" required></div>
    <div class="form-group"><label>Type</label><select name="txn_type"><option value="credit">Credit</option><option value="debit">Debit</option></select></div>
    <div class="form-group" style="align-self:flex-end;"><button class="btn btn-primary">Add</button></div>
</form></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Reconciliation</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Date</th><th>Account</th><th>Description</th><th>Ref</th><th>Amount</th><th>Matched</th><th>Match payment</th></tr></thead>
<tbody>
<?php foreach ($txns as $t): ?>
<tr>
    <td><?= formatDate($t['txn_date']) ?></td><td><?= e($t['account_name']) ?></td><td><?= e($t['description']) ?></td>
    <td><?= e($t['reference'] ?? '—') ?></td><td><?= formatMoney((float)$t['amount']) ?> <?= e($t['txn_type']) ?></td>
    <td><?= $t['is_reconciled'] ? 'Yes' : 'No' ?></td>
    <td><?php if (!$t['is_reconciled'] && $t['txn_type'] === 'credit'): ?>
    <form method="post" style="display:inline-flex;gap:.25rem;"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="match"><input type="hidden" name="txn_id" value="<?= (int)$t['id'] ?>">
    <select name="payment_id"><option value="">—</option><?php foreach ($unmatchedPayments as $p): ?><option value="<?= $p['id'] ?>"><?= e($p['receipt_number'] ?? $p['id']) ?> <?= formatMoney((float)$p['amount']) ?></option><?php endforeach; ?></select>
    <button class="btn btn-sm btn-outline">Match</button></form>
    <?php endif; ?></td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<?php if ($rates): ?>
<div class="card" style="margin-top:1rem;"><div class="card-header"><h2>Recent exchange rates</h2></div>
<div class="card-body"><table class="data-table"><thead><tr><th>From</th><th>To</th><th>Rate</th><th>Date</th></tr></thead><tbody>
<?php foreach ($rates as $r): ?><tr><td><?= e($r['from_currency']) ?></td><td><?= e($r['to_currency']) ?></td><td><?= e($r['rate']) ?></td><td><?= formatDate($r['rate_date']) ?></td></tr><?php endforeach; ?>
</tbody></table></div></div>
<?php endif; ?>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
