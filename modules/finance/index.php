<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = isStudentPortal() ? 'My Fees' : 'Finance';
$currentModule = 'finance';
$financeSection = 'dashboard';
$db = getDB();
$studentId = getCurrentStudentId();

if (isStudentPortal()) {
    $summary = $studentId ? getStudentFinanceSummary($studentId) : ['billed' => 0, 'paid' => 0, 'balance' => 0];
    $holds = $studentId ? $db->prepare('SELECT * FROM finance_holds WHERE student_id = ? AND is_active = 1') : null;
    if ($holds) {
        $holds->execute([$studentId]);
        $holds = $holds->fetchAll();
    } else {
        $holds = [];
    }
    $invoices = [];
    $payments = [];
    if ($studentId) {
        $stmt = $db->prepare('SELECT * FROM invoices WHERE student_id = ? ORDER BY created_at DESC');
        $stmt->execute([$studentId]);
        $invoices = $stmt->fetchAll();
        $stmt = $db->prepare(
            'SELECT p.*, i.invoice_number FROM payments p JOIN invoices i ON i.id = p.invoice_id WHERE i.student_id = ? ORDER BY p.paid_at DESC'
        );
        $stmt->execute([$studentId]);
        $payments = $stmt->fetchAll();
    }

    if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
        if (($_POST['action'] ?? '') === 'request_plan' && $studentId) {
            $db->prepare(
                'INSERT INTO installment_plans (student_id, title, total_amount, currency, status, created_by)
                 VALUES (?, ?, ?, ?, ?, NULL)'
            )->execute([
                $studentId,
                'Payment plan request',
                (float) ($_POST['requested_amount'] ?? $summary['balance']),
                $_POST['currency'] ?? 'USD',
                'pending',
            ]);
            flash('success', 'Payment plan request submitted for finance approval.');
            redirect(moduleUrl('finance'));
        }
        if (($_POST['action'] ?? '') === 'submit_pop' && $studentId) {
            $invId = (int) ($_POST['invoice_id'] ?? 0);
            $pop = handlePopUpload('pop_file');
            if ($pop && $invId) {
                recordPayment($invId, [
                    'amount'          => (float) $_POST['amount'],
                    'payment_method'  => $_POST['payment_method'] ?? 'bank',
                    'reference'       => trim($_POST['reference'] ?? ''),
                    'pop_file'        => $pop,
                    'status'          => 'pending',
                ]);
                flash('success', 'Proof of payment uploaded. Finance will verify and confirm.');
            } else {
                flash('danger', 'Upload a PDF or image and select an invoice.');
            }
            redirect(moduleUrl('finance'));
        }
    }

    require_once __DIR__ . '/../../includes/header.php';
    ?>
    <div class="stats-grid" style="margin-bottom:1.5rem;">
        <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney((float)$summary['balance']) ?></span><span class="stat-label">Outstanding</span></div></div>
        <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney((float)$summary['paid']) ?></span><span class="stat-label">Total Paid</span></div></div>
    </div>
    <?php if ($holds): ?>
    <div class="alert alert-danger">Financial hold active: <?= e(implode(', ', array_column($holds, 'hold_type'))) ?>. Contact finance office.</div>
    <?php endif; ?>
    <div class="card"><div class="card-header"><h2>My Invoices</h2></div>
    <div class="card-body table-wrap">
        <?php if (empty($invoices)): ?><p class="empty-state">No invoices.</p>
        <?php else: ?>
        <table class="data-table"><thead><tr><th>#</th><th>Total</th><th>Paid</th><th>Balance</th><th>Status</th><th>Due</th><th></th></tr></thead><tbody>
        <?php foreach ($invoices as $inv): $bal = (float)$inv['total_amount'] - (float)$inv['amount_paid']; ?>
        <tr>
            <td><?= e($inv['invoice_number']) ?></td>
            <td><?= formatMoney((float)$inv['total_amount'], $inv['currency'] ?? 'USD') ?></td>
            <td><?= formatMoney((float)$inv['amount_paid'], $inv['currency'] ?? 'USD') ?></td>
            <td><?= formatMoney($bal, $inv['currency'] ?? 'USD') ?></td>
            <td><?= statusBadge($inv['status']) ?></td>
            <td><?= formatDate($inv['due_date']) ?></td>
            <td><a href="invoice-pdf.php?id=<?= (int)$inv['id'] ?>" class="btn btn-sm btn-outline">PDF</a></td>
        </tr>
        <?php endforeach; ?></tbody></table>
        <?php endif; ?>
    </div></div>

    <div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Upload proof of payment</h2></div>
    <div class="card-body" style="max-width:520px;">
        <form method="post" enctype="multipart/form-data">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="submit_pop">
            <div class="form-group"><label>Invoice</label><select name="invoice_id" required>
                <option value="">Select</option>
                <?php foreach ($invoices as $inv): if ((float)$inv['total_amount'] - (float)$inv['amount_paid'] <= 0) continue; ?>
                <option value="<?= (int)$inv['id'] ?>"><?= e($inv['invoice_number']) ?> — <?= formatMoney((float)$inv['total_amount'] - (float)$inv['amount_paid'], $inv['currency'] ?? 'USD') ?></option>
                <?php endforeach; ?>
            </select></div>
            <div class="form-row">
                <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" required></div>
                <div class="form-group"><label>Method</label><select name="payment_method"><option value="bank">Bank</option><option value="mobile">EcoCash / Mobile</option><option value="cash">Cash</option></select></div>
            </div>
            <div class="form-group"><label>Reference</label><input name="reference"></div>
            <div class="form-group"><label>Proof (PDF/JPG/PNG)</label><input type="file" name="pop_file" accept=".pdf,.jpg,.jpeg,.png" required></div>
            <button type="submit" class="btn btn-primary">Submit for verification</button>
        </form>
    </div></div>

    <div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Request payment plan</h2></div>
    <div class="card-body" style="max-width:400px;">
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="request_plan">
            <div class="form-group"><label>Amount to plan</label><input type="number" step="0.01" name="requested_amount" value="<?= (float)$summary['balance'] ?>"></div>
            <div class="form-group"><label>Currency</label><select name="currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
            <button type="submit" class="btn btn-outline">Submit request</button>
        </form>
    </div></div>

    <?php if ($payments): ?>
    <div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Payment History</h2></div>
    <div class="card-body table-wrap"><table class="data-table"><thead><tr><th>Receipt</th><th>Invoice</th><th>Amount</th><th>Method</th><th>Status</th><th>Date</th></tr></thead><tbody>
    <?php foreach ($payments as $p): ?>
    <tr><td><?= e($p['receipt_number'] ?? '—') ?></td><td><?= e($p['invoice_number']) ?></td><td><?= formatMoney((float)$p['amount'], $p['currency'] ?? 'USD') ?></td><td><?= e($p['payment_method']) ?></td><td><?= statusBadge($p['status'] ?? 'confirmed') ?></td><td><?= formatDate($p['paid_at'], 'd M Y H:i') ?></td></tr>
    <?php endforeach; ?></tbody></table></div></div>
    <?php endif;
    require_once __DIR__ . '/../../includes/footer.php';
    return;
}

$stats = getFinanceDashboardStats();
require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="stats-grid">
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['revenue_mtd']) ?></span><span class="stat-label">Revenue (MTD)</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['outstanding']) ?></span><span class="stat-label">Outstanding AR</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= $stats['debtors'] ?></span><span class="stat-label">Debtors</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= $stats['overdue_count'] ?></span><span class="stat-label">Overdue Invoices</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney($stats['payables_due']) ?></span><span class="stat-label">Payables Due</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= $stats['active_holds'] ?></span><span class="stat-label">Financial Holds</span></div></div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Quick actions</h2></div>
    <div class="card-body">
        <p><a href="<?= moduleUrl('finance', 'invoices') ?>" class="btn btn-primary btn-sm">Create invoice</a>
        <a href="<?= moduleUrl('finance', 'payment') ?>" class="btn btn-outline btn-sm">Record payment</a>
        <a href="<?= moduleUrl('finance', 'receivables') ?>" class="btn btn-outline btn-sm">Debtors &amp; aging</a>
        <a href="<?= moduleUrl('finance', 'reports') ?>" class="btn btn-outline btn-sm">Financial reports</a></p>
        <p class="text-muted" style="margin-top:1rem;font-size:.9rem;">Use the tabs above for fee structures, payables, ledger, procurement, sponsors, banking, and assets.</p>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
