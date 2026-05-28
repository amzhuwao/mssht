<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Accounts Payable';
$currentModule = 'finance';
$financeSection = 'payables';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'add_supplier') {
        $db->prepare('INSERT INTO suppliers (code, name, contact_person, email, phone, tax_number) VALUES (?, ?, ?, ?, ?, ?)')
           ->execute([generateRef('SUP'), trim($_POST['name']), trim($_POST['contact_person'] ?? ''), trim($_POST['email'] ?? ''), trim($_POST['phone'] ?? ''), trim($_POST['tax_number'] ?? '')]);
        flash('success', 'Supplier added.');
    }
    if ($action === 'add_bill') {
        $db->prepare('INSERT INTO payables (bill_number, supplier_id, category_id, description, amount, due_date, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)')
           ->execute([generateRef('BILL'), (int)$_POST['supplier_id'], $_POST['category_id'] ?: null, trim($_POST['description']), (float)$_POST['amount'], $_POST['due_date'], $_SESSION['user_id']]);
        flash('success', 'Bill recorded.');
    }
    if ($action === 'pay_bill' && (int)$_POST['payable_id']) {
        $amt = (float)$_POST['amount'];
        $pid = (int)$_POST['payable_id'];
        $db->prepare('INSERT INTO payable_payments (payable_id, amount, payment_method, reference, paid_by) VALUES (?, ?, ?, ?, ?)')
           ->execute([$pid, $amt, $_POST['payment_method'], trim($_POST['reference'] ?? ''), $_SESSION['user_id']]);
        $p = $db->prepare('SELECT amount, amount_paid FROM payables WHERE id = ?');
        $p->execute([$pid]);
        $p = $p->fetch();
        $newPaid = (float)$p['amount_paid'] + $amt;
        $status = $newPaid >= (float)$p['amount'] ? 'paid' : 'partial';
        $db->prepare('UPDATE payables SET amount_paid = ?, status = ? WHERE id = ?')->execute([$newPaid, $status, $pid]);
        flash('success', 'Payment recorded.');
    }
    redirect(moduleUrl('finance', 'payables'));
}

$suppliers = $db->query('SELECT * FROM suppliers WHERE is_active = 1 ORDER BY name')->fetchAll();
$categories = $db->query('SELECT * FROM expense_categories ORDER BY name')->fetchAll();
$bills = $db->query(
    'SELECT pb.*, s.name AS supplier_name, ec.name AS category_name FROM payables pb
     JOIN suppliers s ON s.id = pb.supplier_id
     LEFT JOIN expense_categories ec ON ec.id = pb.category_id
     ORDER BY pb.due_date'
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="dashboard-grid">
    <div class="card"><div class="card-header"><h2>Add supplier</h2></div>
    <div class="card-body"><form method="post">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="add_supplier">
        <div class="form-group"><label>Name</label><input name="name" required></div>
        <div class="form-row">
            <div class="form-group"><label>Contact</label><input name="contact_person"></div>
            <div class="form-group"><label>Email</label><input type="email" name="email"></div>
        </div>
        <div class="form-group"><label>Tax number</label><input name="tax_number"></div>
        <button type="submit" class="btn btn-primary">Save supplier</button>
    </form></div></div>
    <div class="card"><div class="card-header"><h2>Record bill</h2></div>
    <div class="card-body"><form method="post">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="add_bill">
        <div class="form-group"><label>Search supplier</label><input type="text" id="supplierSearch" placeholder="Search suppliers..."></div>
        <div class="form-group"><label>Supplier</label><select name="supplier_id" id="supplierSelect" required><option value="">Select supplier</option><?php foreach ($suppliers as $s): ?><option value="<?= (int) $s['id'] ?>"><?= e($s['name']) ?></option><?php endforeach; ?></select></div>
        <div class="form-group"><label>Search category</label><input type="text" id="categorySearch" placeholder="Search categories..."></div>
        <div class="form-group"><label>Category</label><select name="category_id" id="categorySelect"><option value="">—</option><?php foreach ($categories as $c): ?><option value="<?= (int) $c['id'] ?>"><?= e($c['name']) ?></option><?php endforeach; ?></select></div>
        <div class="form-group"><label>Description</label><input name="description" required></div>
        <div class="form-row">
            <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" required></div>
            <div class="form-group"><label>Due date</label><input type="date" name="due_date" required></div>
        </div>
        <button type="submit" class="btn btn-primary">Save bill</button>
    </form></div></div>
</div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Bills &amp; expenses</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Bill #</th><th>Supplier</th><th>Category</th><th>Description</th><th>Amount</th><th>Paid</th><th>Status</th><th>Due</th><th></th></tr></thead>
<tbody>
<?php foreach ($bills as $b): ?>
<tr>
    <td><?= e($b['bill_number']) ?></td><td><?= e($b['supplier_name']) ?></td><td><?= e($b['category_name'] ?? '—') ?></td>
    <td><?= e($b['description']) ?></td><td><?= formatMoney((float)$b['amount'], $b['currency'] ?? 'USD') ?></td>
    <td><?= formatMoney((float)$b['amount_paid'], $b['currency'] ?? 'USD') ?></td>
    <td><?= statusBadge($b['status']) ?></td><td><?= formatDate($b['due_date']) ?></td>
    <td><?php if ($b['status'] !== 'paid'): ?><form method="post" class="form-row" style="gap:.25rem;">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="pay_bill"><input type="hidden" name="payable_id" value="<?= (int)$b['id'] ?>">
        <input type="number" step="0.01" name="amount" style="width:80px;" placeholder="Amt" required>
        <select name="payment_method" style="width:90px;"><option value="bank">Bank</option><option value="cash">Cash</option></select>
        <button class="btn btn-sm btn-outline">Pay</button>
    </form><?php endif; ?></td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<script>
msshtSearchableSelect('supplierSearch', 'supplierSelect');
msshtSearchableSelect('categorySearch', 'categorySelect');
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
