<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$invoiceId = (int)($_GET['invoice_id'] ?? 0);
$db = getDB();
$inv = $db->prepare('SELECT i.*, s.student_number FROM invoices i JOIN students s ON s.id = i.student_id WHERE i.id = ?');
$inv->execute([$invoiceId]);
$inv = $inv->fetch();
if (!$inv) {
    flash('danger', 'Invoice not found.');
    redirect(moduleUrl('finance', 'invoices'));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $pop = handlePopUpload('pop_file');
    recordPayment($invoiceId, [
        'amount'         => (float)$_POST['amount'],
        'payment_method' => $_POST['payment_method'],
        'reference'      => trim($_POST['reference'] ?? ''),
        'currency'       => $_POST['currency'] ?? $inv['currency'] ?? 'USD',
        'exchange_rate'  => (float)($_POST['exchange_rate'] ?? 1),
        'sponsor_id'     => $_POST['sponsor_id'] ? (int)$_POST['sponsor_id'] : null,
        'pop_file'       => $pop,
        'status'         => $pop ? 'pending' : 'confirmed',
    ]);
    flash('success', $pop ? 'Payment submitted for POP verification.' : 'Payment recorded and receipt generated.');
    redirect(moduleUrl('finance', 'invoice') . '?id=' . $invoiceId);
}

$sponsors = $db->query('SELECT id, name FROM finance_sponsors WHERE is_active = 1')->fetchAll();
$pageTitle = 'Record Payment';
$currentModule = 'finance';
$financeSection = 'invoices';
require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
$balance = (float)$inv['total_amount'] - (float)$inv['amount_paid'];
?>

<div class="card" style="max-width:560px;">
    <div class="card-header"><h2>Invoice <?= e($inv['invoice_number']) ?></h2></div>
    <div class="card-body">
        <p>Student: <strong><?= e($inv['student_number']) ?></strong></p>
        <p>Balance: <strong><?= formatMoney($balance, $inv['currency'] ?? 'USD') ?></strong></p>
        <form method="post" enctype="multipart/form-data">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" value="<?= $balance ?>" required></div>
            <div class="form-row">
                <div class="form-group"><label>Currency</label><select name="currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
                <div class="form-group"><label>Exchange rate</label><input type="number" step="0.0001" name="exchange_rate" value="1"></div>
            </div>
            <div class="form-group"><label>Method</label>
                <select name="payment_method" required>
                    <option value="cash">Cash</option><option value="bank">Bank Transfer</option>
                    <option value="mobile">EcoCash / Mobile Money</option><option value="pos">POS / Card</option>
                    <option value="card">Card</option><option value="gateway">Payment Gateway</option>
                </select>
            </div>
            <div class="form-group"><label>Reference</label><input name="reference"></div>
            <div class="form-group"><label>Sponsor (split payment)</label>
                <select name="sponsor_id"><option value="">None</option>
                <?php foreach ($sponsors as $sp): ?><option value="<?= $sp['id'] ?>"><?= e($sp['name']) ?></option><?php endforeach; ?>
                </select>
            </div>
            <div class="form-group"><label>Proof of payment (optional)</label><input type="file" name="pop_file" accept=".pdf,.jpg,.jpeg,.png"></div>
            <button type="submit" class="btn btn-primary">Record payment</button>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
