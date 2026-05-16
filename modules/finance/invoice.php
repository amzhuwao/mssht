<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$id = (int)($_GET['id'] ?? 0);
$db = getDB();
$stmt = $db->prepare(
    'SELECT i.*, s.student_number FROM invoices i JOIN students s ON s.id = i.student_id WHERE i.id = ?'
);
$stmt->execute([$id]);
$invoice = $stmt->fetch();
if (!$invoice) {
    flash('danger', 'Invoice not found.');
    redirect(moduleUrl('finance', 'invoices'));
}
$lines = $db->prepare('SELECT * FROM invoice_lines WHERE invoice_id = ?');
$lines->execute([$id]);
$lines = $lines->fetchAll();
$payments = $db->prepare('SELECT * FROM payments WHERE invoice_id = ? ORDER BY paid_at DESC');
$payments->execute([$id]);
$payments = $payments->fetchAll();

$pageTitle = 'Invoice ' . $invoice['invoice_number'];
$currentModule = 'finance';
$financeSection = 'invoices';
require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
$balance = (float)$invoice['total_amount'] - (float)$invoice['amount_paid'];
?>

<div class="card">
    <div class="card-header">
        <h2><?= e($invoice['invoice_number']) ?></h2>
        <?= statusBadge($invoice['status']) ?>
    </div>
    <div class="card-body">
        <p>Student: <strong><?= e($invoice['student_number']) ?></strong> | Due: <?= formatDate($invoice['due_date']) ?> | Balance: <strong><?= formatMoney($balance, $invoice['currency'] ?? 'USD') ?></strong></p>
        <p><a href="invoice-pdf.php?id=<?= $id ?>" class="btn btn-outline btn-sm">Download PDF</a>
        <a href="payment.php?invoice_id=<?= $id ?>" class="btn btn-primary btn-sm">Record payment</a></p>
        <?php if ($lines): ?>
        <table class="data-table" style="margin-top:1rem;"><thead><tr><th>Description</th><th>Qty</th><th>Unit</th><th>Total</th></tr></thead><tbody>
        <?php foreach ($lines as $l): ?>
        <tr><td><?= e($l['description']) ?></td><td><?= e($l['quantity']) ?></td><td><?= formatMoney((float)$l['unit_amount'], $invoice['currency'] ?? 'USD') ?></td><td><?= formatMoney((float)$l['line_total'], $invoice['currency'] ?? 'USD') ?></td></tr>
        <?php endforeach; ?></tbody></table>
        <?php endif; ?>
        <?php if ($payments): ?>
        <h3 style="margin-top:1.5rem;font-size:1rem;">Payments</h3>
        <table class="data-table"><thead><tr><th>Receipt</th><th>Amount</th><th>Method</th><th>Status</th><th>Date</th></tr></thead><tbody>
        <?php foreach ($payments as $p): ?>
        <tr><td><?= e($p['receipt_number'] ?? '—') ?></td><td><?= formatMoney((float)$p['amount'], $p['currency'] ?? 'USD') ?></td><td><?= e($p['payment_method']) ?></td><td><?= statusBadge($p['status'] ?? 'confirmed') ?></td><td><?= formatDate($p['paid_at'], 'd M Y H:i') ?></td></tr>
        <?php endforeach; ?></tbody></table>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
