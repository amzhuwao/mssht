<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Budgets';
$currentModule = 'finance';
$financeSection = 'budgets';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare('INSERT INTO budgets (name, department, fiscal_year, budget_type, total_amount, status) VALUES (?, ?, ?, ?, ?, ?)')
       ->execute([trim($_POST['name']), trim($_POST['department']), trim($_POST['fiscal_year']), $_POST['budget_type'], (float)$_POST['total_amount'], 'draft']);
    flash('success', 'Budget created.');
    redirect(moduleUrl('finance', 'budgets'));
}

$budgets = $db->query('SELECT * FROM budgets ORDER BY fiscal_year DESC, department')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="card"><div class="card-header"><h2>Create budget</h2></div>
<div class="card-body" style="max-width:560px;"><form method="post">
    <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
    <div class="form-group"><label>Name</label><input name="name" required></div>
    <div class="form-row">
        <div class="form-group"><label>Department</label><input name="department" required></div>
        <div class="form-group"><label>Fiscal year</label><input name="fiscal_year" value="<?= date('Y') ?>" required></div>
    </div>
    <div class="form-row">
        <div class="form-group"><label>Type</label><select name="budget_type"><option value="operational">Operational</option><option value="capital">Capital expenditure</option></select></div>
        <div class="form-group"><label>Total amount</label><input type="number" step="0.01" name="total_amount" required></div>
    </div>
    <button type="submit" class="btn btn-primary">Save budget</button>
</form></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Departmental budgets</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Name</th><th>Department</th><th>Year</th><th>Type</th><th>Budget</th><th>Spent</th><th>Utilization</th><th>Status</th></tr></thead>
<tbody>
<?php foreach ($budgets as $b):
    $util = (float)$b['total_amount'] > 0 ? round((float)$b['spent_amount'] / (float)$b['total_amount'] * 100, 1) : 0;
?>
<tr>
    <td><?= e($b['name']) ?></td><td><?= e($b['department']) ?></td><td><?= e($b['fiscal_year']) ?></td>
    <td><?= e($b['budget_type']) ?></td><td><?= formatMoney((float)$b['total_amount']) ?></td>
    <td><?= formatMoney((float)$b['spent_amount']) ?></td>
    <td><?= $util ?>%</td><td><?= statusBadge($b['status']) ?></td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
