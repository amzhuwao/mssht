<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = isStudentPortal() ? 'My Fees' : 'Finance & Billing';
$currentModule = 'finance';
$db = getDB();
$studentId = getCurrentStudentId();

if (isStudentPortal()) {
    $invoices = [];
    if ($studentId) {
        $stmt = $db->prepare(
            'SELECT i.*, s.student_number FROM invoices i
             JOIN students s ON s.id = i.student_id
             WHERE i.student_id = ? ORDER BY i.created_at DESC'
        );
        $stmt->execute([$studentId]);
        $invoices = $stmt->fetchAll();
    }
    require_once __DIR__ . '/../../includes/header.php';
    ?>
    <div class="card">
        <div class="card-header"><h2>My Invoices</h2></div>
        <div class="card-body table-wrap">
            <?php if (empty($invoices)): ?>
            <p class="empty-state">No invoices on your account.</p>
            <?php else: ?>
            <table class="data-table">
                <thead><tr><th>Invoice #</th><th>Total</th><th>Paid</th><th>Balance</th><th>Status</th><th>Due</th></tr></thead>
                <tbody>
                <?php foreach ($invoices as $inv): ?>
                <tr>
                    <td><?= e($inv['invoice_number']) ?></td>
                    <td><?= formatMoney((float)$inv['total_amount']) ?></td>
                    <td><?= formatMoney((float)$inv['amount_paid']) ?></td>
                    <td><?= formatMoney((float)$inv['total_amount'] - (float)$inv['amount_paid']) ?></td>
                    <td><?= statusBadge($inv['status']) ?></td>
                    <td><?= formatDate($inv['due_date']) ?></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <?php endif; ?>
        </div>
    </div>
    <?php
    require_once __DIR__ . '/../../includes/footer.php';
    return;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $invNum = generateRef('INV');
    $db->prepare(
        'INSERT INTO invoices (invoice_number, student_id, total_amount, due_date) VALUES (?, ?, ?, ?)'
    )->execute([$invNum, (int)$_POST['student_id'], (float)$_POST['amount'], $_POST['due_date']]);
    flash('success', "Invoice $invNum created.");
    redirect(moduleUrl('finance'));
}

$invoices = $db->query(
    'SELECT i.*, s.student_number FROM invoices i
     JOIN students s ON s.id = i.student_id ORDER BY i.created_at DESC LIMIT 50'
)->fetchAll();
$students = $db->query("SELECT id, student_number FROM students WHERE enrollment_status = 'active'")->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Create Invoice</h2></div>
        <div class="card-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <div class="form-group">
                    <label>Student</label>
                    <select name="student_id" required>
                        <option value="">Select student</option>
                        <?php foreach ($students as $s): ?>
                        <option value="<?= $s['id'] ?>"><?= e($s['student_number']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Amount (USD)</label><input type="number" step="0.01" name="amount" required></div>
                    <div class="form-group"><label>Due Date</label><input type="date" name="due_date" required></div>
                </div>
                <button type="submit" class="btn btn-primary">Create Invoice</button>
            </form>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Invoices</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Invoice #</th><th>Student</th><th>Total</th><th>Paid</th><th>Status</th><th>Due</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($invoices as $inv): ?>
            <tr>
                <td><?= e($inv['invoice_number']) ?></td>
                <td><?= e($inv['student_number']) ?></td>
                <td><?= formatMoney((float)$inv['total_amount']) ?></td>
                <td><?= formatMoney((float)$inv['amount_paid']) ?></td>
                <td><?= statusBadge($inv['status']) ?></td>
                <td><?= formatDate($inv['due_date']) ?></td>
                <td><a href="payment.php?invoice_id=<?= $inv['id'] ?>" class="btn btn-sm btn-outline">Record Payment</a></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
