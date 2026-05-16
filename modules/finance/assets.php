<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Asset Management';
$currentModule = 'finance';
$financeSection = 'assets';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare('INSERT INTO assets (asset_tag, name, category, purchase_date, purchase_cost, location) VALUES (?, ?, ?, ?, ?, ?)')
       ->execute([
           generateRef('AST'),
           trim($_POST['name']),
           $_POST['category'],
           $_POST['purchase_date'] ?: null,
           (float)($_POST['purchase_cost'] ?? 0),
           trim($_POST['location'] ?? ''),
       ]);
    flash('success', 'Asset registered.');
    redirect(moduleUrl('finance', 'assets'));
}

$assets = $db->query('SELECT * FROM assets ORDER BY created_at DESC')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="card"><div class="card-header"><h2>Register asset</h2></div>
<div class="card-body" style="max-width:520px;"><form method="post">
    <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
    <div class="form-group"><label>Name</label><input name="name" required></div>
    <div class="form-row">
        <div class="form-group"><label>Category</label>
            <select name="category"><option value="computer">Computer</option><option value="vehicle">Vehicle</option><option value="furniture">Furniture</option><option value="lab">Lab equipment</option><option value="other">Other</option></select>
        </div>
        <div class="form-group"><label>Location</label><input name="location"></div>
    </div>
    <div class="form-row">
        <div class="form-group"><label>Purchase date</label><input type="date" name="purchase_date"></div>
        <div class="form-group"><label>Cost</label><input type="number" step="0.01" name="purchase_cost"></div>
    </div>
    <button type="submit" class="btn btn-primary">Register</button>
</form></div></div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Asset register</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Tag</th><th>Name</th><th>Category</th><th>Location</th><th>Cost</th><th>Status</th></tr></thead>
<tbody>
<?php foreach ($assets as $a): ?>
<tr>
    <td><?= e($a['asset_tag']) ?></td><td><?= e($a['name']) ?></td><td><?= e($a['category']) ?></td>
    <td><?= e($a['location'] ?? '—') ?></td><td><?= formatMoney((float)$a['purchase_cost']) ?></td>
    <td><?= statusBadge($a['status']) ?></td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
