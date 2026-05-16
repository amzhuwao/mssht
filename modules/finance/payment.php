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
    redirect(moduleUrl('finance'));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $amount = (float)$_POST['amount'];
    $db->prepare('INSERT INTO payments (invoice_id, amount, payment_method, reference, received_by) VALUES (?, ?, ?, ?, ?)')
       ->execute([$invoiceId, $amount, $_POST['payment_method'], trim($_POST['reference'] ?? ''), $_SESSION['user_id']]);
    $newPaid = (float)$inv['amount_paid'] + $amount;
    $status = $newPaid >= (float)$inv['total_amount'] ? 'paid' : 'partial';
    $db->prepare('UPDATE invoices SET amount_paid = ?, status = ? WHERE id = ?')->execute([$newPaid, $status, $invoiceId]);
    flash('success', 'Payment recorded.');
    redirect(moduleUrl('finance'));
}

$pageTitle = 'Record Payment';
$currentModule = 'finance';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card" style="max-width:480px;">
    <div class="card-header"><h2>Invoice <?= e($inv['invoice_number']) ?></h2></div>
    <div class="card-body">
        <p>Student: <strong><?= e($inv['student_number']) ?></strong></p>
        <p>Balance: <strong><?= formatMoney((float)$inv['total_amount'] - (float)$inv['amount_paid']) ?></strong></p>
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" required></div>
            <div class="form-group">
                <label>Method</label>
                <select name="payment_method" required>
                    <option value="cash">Cash</option>
                    <option value="bank">Bank Transfer</option>
                    <option value="mobile">Mobile Money</option>
                    <option value="gateway">Payment Gateway</option>
                </select>
            </div>
            <div class="form-group"><label>Reference</label><input name="reference"></div>
            <button type="submit" class="btn btn-primary">Record Payment</button>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
