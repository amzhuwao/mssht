<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Invoicing';
$currentModule = 'finance';
$financeSection = 'invoices';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'create') {
        createInvoice([
            'student_id' => (int)$_POST['student_id'],
            'total_amount' => (float)$_POST['amount'],
            'currency' => $_POST['currency'] ?? 'USD',
            'due_date' => $_POST['due_date'],
            'notes' => trim($_POST['notes'] ?? ''),
        ], [[
            'description' => trim($_POST['description'] ?? 'Fees'),
            'quantity' => 1,
            'unit_amount' => (float)$_POST['amount'],
            'line_total' => (float)$_POST['amount'],
        ]]);
        flash('success', 'Invoice created.');
    }
    if ($action === 'bulk' && (int)$_POST['intake_id'] && (int)$_POST['fee_structure_id']) {
        $r = bulkInvoiceIntake((int)$_POST['intake_id'], (int)$_POST['fee_structure_id'], $_POST['due_date']);
        flash('success', "Bulk billing: {$r['created']} invoice(s) created.");
    }
    redirect(moduleUrl('finance', 'invoices'));
}

$invoices = $db->query(
    'SELECT i.*, s.student_number FROM invoices i JOIN students s ON s.id = i.student_id ORDER BY i.created_at DESC LIMIT 100'
)->fetchAll();
$students = $db->query("SELECT id, student_number FROM students WHERE enrollment_status = 'active'")->fetchAll();
$intakes = $db->query('SELECT id, name FROM intakes ORDER BY start_date DESC')->fetchAll();
$feeStructures = $db->query('SELECT fs.id, fs.description, p.name AS program_name, fs.amount FROM fee_structures fs JOIN programs p ON p.id = fs.program_id WHERE fs.is_active = 1')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Create invoice</h2></div>
        <div class="card-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="create">
                <div class="form-group"><label>Student</label><select name="student_id" required>
                    <option value="">Select</option><?php foreach ($students as $s): ?><option value="<?= $s['id'] ?>"><?= e($s['student_number']) ?></option><?php endforeach; ?>
                </select></div>
                <div class="form-row">
                    <div class="form-group"><label>Description</label><input name="description" value="Tuition fees"></div>
                    <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" required></div>
                    <div class="form-group"><label>Currency</label><select name="currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
                    <div class="form-group"><label>Due date</label><input type="date" name="due_date" required value="<?= date('Y-m-d', strtotime('+30 days')) ?>"></div>
                </div>
                <button type="submit" class="btn btn-primary">Create invoice</button>
            </form>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>Bulk billing (intake)</h2></div>
        <div class="card-body">
            <form method="post" onsubmit="return confirm('Generate invoices for all active students in this intake?');">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="bulk">
                <div class="form-group"><label>Intake</label><select name="intake_id" required>
                    <?php foreach ($intakes as $i): ?><option value="<?= $i['id'] ?>"><?= e($i['name']) ?></option><?php endforeach; ?>
                </select></div>
                <div class="form-group"><label>Fee structure</label><select name="fee_structure_id" required>
                    <?php foreach ($feeStructures as $f): ?><option value="<?= $f['id'] ?>"><?= e($f['program_name']) ?> — <?= e($f['description']) ?> (<?= formatMoney((float)$f['amount']) ?>)</option><?php endforeach; ?>
                </select></div>
                <div class="form-group"><label>Due date</label><input type="date" name="due_date" required value="<?= date('Y-m-d', strtotime('+30 days')) ?>"></div>
                <button type="submit" class="btn btn-outline">Bulk invoice intake</button>
            </form>
        </div>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Invoices</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>#</th><th>Student</th><th>Total</th><th>Paid</th><th>Status</th><th>Due</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($invoices as $inv): ?>
            <tr>
                <td><?= e($inv['invoice_number']) ?></td>
                <td><?= e($inv['student_number']) ?></td>
                <td><?= formatMoney((float)$inv['total_amount'], $inv['currency'] ?? 'USD') ?></td>
                <td><?= formatMoney((float)$inv['amount_paid'], $inv['currency'] ?? 'USD') ?></td>
                <td><?= statusBadge($inv['status']) ?></td>
                <td><?= formatDate($inv['due_date']) ?></td>
                <td>
                    <a href="invoice.php?id=<?= (int)$inv['id'] ?>" class="btn btn-sm btn-outline">View</a>
                    <a href="payment.php?invoice_id=<?= (int)$inv['id'] ?>" class="btn btn-sm btn-primary">Pay</a>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
