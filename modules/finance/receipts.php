<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');
requireFinanceManagement();

$pageTitle = 'Receipts';
$currentModule = 'finance';
$financeSection = 'receipts';
$db = getDB();
$editReceiptId = (int) ($_GET['edit'] ?? 0);
$editReceipt = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'update' && (int) ($_POST['payment_id'] ?? 0)) {
        updatePayment((int) $_POST['payment_id'], [
            'amount' => (float) ($_POST['amount'] ?? 0),
            'currency' => $_POST['currency'] ?? 'USD',
            'exchange_rate' => (float) ($_POST['exchange_rate'] ?? 1),
            'payment_method' => $_POST['payment_method'] ?? 'cash',
            'reference' => trim($_POST['reference'] ?? ''),
            'status' => $_POST['status'] ?? 'confirmed',
            'sponsor_id' => ($_POST['sponsor_id'] ?? '') !== '' ? (int) $_POST['sponsor_id'] : null,
        ]);
        flash('success', 'Receipt updated.');
    }
    if ($action === 'delete' && (int) ($_POST['payment_id'] ?? 0)) {
        deletePayment((int) $_POST['payment_id']);
        flash('success', 'Receipt deleted.');
    }
    if ($action === 'confirm' && (int) ($_POST['payment_id'] ?? 0)) {
        confirmPayment((int) $_POST['payment_id']);
        flash('success', 'Receipt confirmed.');
    }
    redirect(moduleUrl('finance', 'receipts'));
}

$receipts = $db->query(
    'SELECT p.*, i.invoice_number, i.total_amount, i.amount_paid, i.currency AS invoice_currency,
            s.student_number, COALESCE(s.first_name, up.first_name) AS first_name, COALESCE(s.last_name, up.last_name) AS last_name
     FROM payments p
     JOIN invoices i ON i.id = p.invoice_id
     JOIN students s ON s.id = i.student_id
     LEFT JOIN users u ON u.id = s.user_id
     LEFT JOIN user_profiles up ON up.user_id = u.id
     ORDER BY p.paid_at DESC
     LIMIT 200'
)->fetchAll();
$sponsors = $db->query('SELECT id, name FROM finance_sponsors WHERE is_active = 1 ORDER BY name')->fetchAll();

if ($editReceiptId) {
    $stmt = $db->prepare(
        'SELECT p.*, i.invoice_number, i.student_id, s.student_number
         FROM payments p
         JOIN invoices i ON i.id = p.invoice_id
         JOIN students s ON s.id = i.student_id
         WHERE p.id = ?'
    );
    $stmt->execute([$editReceiptId]);
    $editReceipt = $stmt->fetch();
}

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="card" style="margin-bottom:1.5rem;">
    <div class="card-header"><h2>Receipts</h2></div>
    <div class="card-body">
        <p class="text-muted">View and manage payment receipts recorded in finance. Create new receipts from <a href="<?= moduleUrl('finance', 'payment') ?>">Record payment</a>.</p>
    </div>
</div>

<?php if ($editReceipt): ?>
<div class="card" style="margin-bottom:1.5rem;">
    <div class="card-header"><h2>Edit receipt <?= e($editReceipt['receipt_number'] ?? '—') ?></h2></div>
    <div class="card-body" style="max-width:640px;">
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="payment_id" value="<?= (int) $editReceipt['id'] ?>">
            <div class="form-row">
                <div class="form-group"><label>Receipt number</label><input value="<?= e($editReceipt['receipt_number'] ?? '') ?>" disabled></div>
                <div class="form-group"><label>Invoice</label><input value="<?= e($editReceipt['invoice_number']) ?>" disabled></div>
            </div>
            <div class="form-row">
                <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" value="<?= (float) $editReceipt['amount'] ?>" required></div>
                <div class="form-group"><label>Status</label><select name="status">
                    <option value="pending" <?= ($editReceipt['status'] ?? 'confirmed') === 'pending' ? 'selected' : '' ?>>Pending</option>
                    <option value="confirmed" <?= ($editReceipt['status'] ?? 'confirmed') === 'confirmed' ? 'selected' : '' ?>>Confirmed</option>
                    <option value="rejected" <?= ($editReceipt['status'] ?? '') === 'rejected' ? 'selected' : '' ?>>Rejected</option>
                </select></div>
            </div>
            <div class="form-row">
                <div class="form-group"><label>Currency</label><select name="currency"><option value="USD" <?= ($editReceipt['currency'] ?? 'USD') === 'USD' ? 'selected' : '' ?>>USD</option><option value="ZWL" <?= ($editReceipt['currency'] ?? 'USD') === 'ZWL' ? 'selected' : '' ?>>ZWL</option></select></div>
                <div class="form-group"><label>Exchange rate</label><input type="number" step="0.0001" name="exchange_rate" value="<?= e((string) ($editReceipt['exchange_rate'] ?? 1)) ?>"></div>
            </div>
            <div class="form-row">
                <div class="form-group"><label>Method</label><select name="payment_method">
                    <option value="cash" <?= ($editReceipt['payment_method'] ?? '') === 'cash' ? 'selected' : '' ?>>Cash</option>
                    <option value="bank" <?= ($editReceipt['payment_method'] ?? '') === 'bank' ? 'selected' : '' ?>>Bank Transfer</option>
                    <option value="mobile" <?= ($editReceipt['payment_method'] ?? '') === 'mobile' ? 'selected' : '' ?>>Mobile Money</option>
                    <option value="pos" <?= ($editReceipt['payment_method'] ?? '') === 'pos' ? 'selected' : '' ?>>POS / Card</option>
                    <option value="card" <?= ($editReceipt['payment_method'] ?? '') === 'card' ? 'selected' : '' ?>>Card</option>
                    <option value="gateway" <?= ($editReceipt['payment_method'] ?? '') === 'gateway' ? 'selected' : '' ?>>Gateway</option>
                </select></div>
                <div class="form-group"><label>Sponsor</label><select name="sponsor_id"><option value="">None</option><?php foreach ($sponsors as $sp): ?><option value="<?= (int) $sp['id'] ?>" <?= (int) ($editReceipt['sponsor_id'] ?? 0) === (int) $sp['id'] ? 'selected' : '' ?>><?= e($sp['name']) ?></option><?php endforeach; ?></select></div>
            </div>
            <div class="form-group"><label>Reference</label><input name="reference" value="<?= e($editReceipt['reference'] ?? '') ?>"></div>
            <button type="submit" class="btn btn-primary">Save changes</button>
        </form>
    </div>
</div>
<?php endif; ?>

<div class="card">
    <div class="card-header"><h2>Receipt register</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Receipt</th><th>Student</th><th>Invoice</th><th>Amount</th><th>Method</th><th>Status</th><th>Date</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($receipts as $receipt): ?>
            <tr>
                <td><?= e($receipt['receipt_number'] ?? '—') ?></td>
                <td><?= e(trim($receipt['student_number'] . ' — ' . trim(($receipt['first_name'] ?? '') . ' ' . ($receipt['last_name'] ?? '')))) ?></td>
                <td><?= e($receipt['invoice_number']) ?></td>
                <td><?= formatMoney((float) $receipt['amount'], $receipt['currency'] ?? 'USD') ?></td>
                <td><?= e($receipt['payment_method']) ?></td>
                <td><?= statusBadge($receipt['status'] ?? 'confirmed') ?></td>
                <td><?= formatDate($receipt['paid_at'], 'd M Y H:i') ?></td>
                <td>
                    <a href="invoice.php?id=<?= (int) $receipt['invoice_id'] ?>" class="btn btn-sm btn-outline">View</a>
                    <a href="<?= moduleUrl('finance', 'receipts') ?>?edit=<?= (int) $receipt['id'] ?>" class="btn btn-sm btn-outline">Edit</a>
                    <?php if (($receipt['status'] ?? 'confirmed') === 'pending'): ?>
                    <form method="post" style="display:inline;">
                        <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                        <input type="hidden" name="action" value="confirm">
                        <input type="hidden" name="payment_id" value="<?= (int) $receipt['id'] ?>">
                        <button type="submit" class="btn btn-sm btn-primary">Confirm</button>
                    </form>
                    <?php endif; ?>
                    <form method="post" style="display:inline;">
                        <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="payment_id" value="<?= (int) $receipt['id'] ?>">
                        <button type="submit" class="btn btn-sm btn-danger" data-confirm="Delete this receipt?">Delete</button>
                    </form>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>