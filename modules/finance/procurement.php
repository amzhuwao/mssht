<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Procurement';
$currentModule = 'finance';
$financeSection = 'procurement';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'requisition') {
        $db->prepare('INSERT INTO purchase_requisitions (req_number, department, description, estimated_total, requested_by) VALUES (?, ?, ?, ?, ?)')
           ->execute([generateRef('REQ'), trim($_POST['department']), trim($_POST['description']), (float)$_POST['estimated_total'], $_SESSION['user_id']]);
        flash('success', 'Requisition submitted.');
    }
    if ($action === 'approve_hod' && (int)$_POST['req_id']) {
        $db->prepare("UPDATE purchase_requisitions SET status = 'hod_approved', hod_approved_by = ? WHERE id = ?")->execute([$_SESSION['user_id'], (int)$_POST['req_id']]);
        flash('success', 'HOD approved.');
    }
    if ($action === 'approve_finance' && (int)$_POST['req_id']) {
        $db->prepare("UPDATE purchase_requisitions SET status = 'finance_approved', finance_approved_by = ? WHERE id = ?")->execute([$_SESSION['user_id'], (int)$_POST['req_id']]);
        flash('success', 'Finance approved.');
    }
    if ($action === 'create_po' && (int)$_POST['req_id'] && (int)$_POST['supplier_id']) {
        $req = $db->prepare('SELECT estimated_total FROM purchase_requisitions WHERE id = ?');
        $req->execute([(int)$_POST['req_id']]);
        $total = (float)$req->fetchColumn();
        $db->prepare('INSERT INTO purchase_orders (po_number, requisition_id, supplier_id, total_amount, status) VALUES (?, ?, ?, ?, ?)')
           ->execute([generateRef('PO'), (int)$_POST['req_id'], (int)$_POST['supplier_id'], $total, 'sent']);
        $db->prepare("UPDATE purchase_requisitions SET status = 'ordered' WHERE id = ?")->execute([(int)$_POST['req_id']]);
        flash('success', 'Purchase order created.');
    }
    if ($action === 'receive' && (int)$_POST['po_id']) {
        $db->prepare('INSERT INTO goods_receipts (po_id, received_date, notes, received_by) VALUES (?, CURDATE(), ?, ?)')
           ->execute([(int)$_POST['po_id'], trim($_POST['notes'] ?? ''), $_SESSION['user_id']]);
        $db->prepare("UPDATE purchase_orders SET status = 'received' WHERE id = ?")->execute([(int)$_POST['po_id']]);
        flash('success', 'Goods received.');
    }
    redirect(moduleUrl('finance', 'procurement'));
}

$requisitions = $db->query('SELECT * FROM purchase_requisitions ORDER BY created_at DESC LIMIT 30')->fetchAll();
$orders = $db->query(
    'SELECT po.*, s.name AS supplier_name FROM purchase_orders po JOIN suppliers s ON s.id = po.supplier_id ORDER BY po.created_at DESC LIMIT 20'
)->fetchAll();
$suppliers = $db->query('SELECT id, name FROM suppliers WHERE is_active = 1')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="card"><div class="card-header"><h2>New purchase requisition</h2></div>
<div class="card-body" style="max-width:560px;"><form method="post">
    <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="requisition">
    <div class="form-group"><label>Department</label><input name="department" required></div>
    <div class="form-group"><label>Description</label><textarea name="description" rows="3" required></textarea></div>
    <div class="form-group"><label>Estimated total</label><input type="number" step="0.01" name="estimated_total" required></div>
    <button type="submit" class="btn btn-primary">Submit</button>
</form></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Requisitions</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>#</th><th>Department</th><th>Description</th><th>Amount</th><th>Status</th><th></th></tr></thead>
<tbody>
<?php foreach ($requisitions as $r): ?>
<tr>
    <td><?= e($r['req_number']) ?></td><td><?= e($r['department']) ?></td>
    <td><?= e(substr($r['description'], 0, 60)) ?></td><td><?= formatMoney((float)$r['estimated_total']) ?></td>
    <td><?= statusBadge($r['status']) ?></td>
    <td style="white-space:nowrap;">
        <?php if ($r['status'] === 'draft'): ?>
        <form method="post" style="display:inline;"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="approve_hod"><input type="hidden" name="req_id" value="<?= (int)$r['id'] ?>"><button class="btn btn-sm btn-outline">HOD</button></form>
        <?php endif; ?>
        <?php if ($r['status'] === 'hod_approved'): ?>
        <form method="post" style="display:inline;"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="approve_finance"><input type="hidden" name="req_id" value="<?= (int)$r['id'] ?>"><button class="btn btn-sm btn-outline">Finance</button></form>
        <?php endif; ?>
        <?php if (in_array($r['status'], ['finance_approved', 'procurement_approved'], true)): ?>
        <form method="post" style="display:inline-flex;gap:.25rem;"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="create_po"><input type="hidden" name="req_id" value="<?= (int)$r['id'] ?>">
        <select name="supplier_id" required style="max-width:120px;"><?php foreach ($suppliers as $s): ?><option value="<?= $s['id'] ?>"><?= e($s['name']) ?></option><?php endforeach; ?></select>
        <button class="btn btn-sm btn-primary">PO</button></form>
        <?php endif; ?>
    </td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Purchase orders</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>PO #</th><th>Supplier</th><th>Amount</th><th>Status</th><th></th></tr></thead>
<tbody>
<?php foreach ($orders as $po): ?>
<tr>
    <td><?= e($po['po_number']) ?></td><td><?= e($po['supplier_name']) ?></td>
    <td><?= formatMoney((float)$po['total_amount']) ?></td><td><?= statusBadge($po['status']) ?></td>
    <td><?php if ($po['status'] !== 'received'): ?><form method="post"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="receive"><input type="hidden" name="po_id" value="<?= (int)$po['id'] ?>"><button class="btn btn-sm btn-outline">Receive goods</button></form><?php endif; ?></td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
