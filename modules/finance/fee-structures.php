<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Fee Structures';
$currentModule = 'finance';
$financeSection = 'fees';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $program = $db->prepare('SELECT program_type FROM programs WHERE id = ?');
    $program->execute([(int)$_POST['program_id']]);
    $ptype = $program->fetchColumn() ?: 'diploma';
    $db->prepare(
        'INSERT INTO fee_structures (program_id, intake_id, description, fee_type, billing_model, amount, currency, semester, allow_installments, is_active)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)'
    )->execute([
        (int)$_POST['program_id'],
        $_POST['intake_id'] ? (int)$_POST['intake_id'] : null,
        trim($_POST['description']),
        $_POST['fee_type'],
        $_POST['billing_model'] ?: billingModelForProgram($ptype),
        (float)$_POST['amount'],
        $_POST['currency'] ?? 'USD',
        $_POST['semester'] ? (int)$_POST['semester'] : null,
        isset($_POST['allow_installments']) ? 1 : 0,
    ]);
    flash('success', 'Fee structure added.');
    redirect(moduleUrl('finance', 'fee-structures'));
}

$fees = $db->query(
    'SELECT fs.*, p.name AS program_name, p.program_type, i.name AS intake_name
     FROM fee_structures fs
     JOIN programs p ON p.id = fs.program_id
     LEFT JOIN intakes i ON i.id = fs.intake_id
     ORDER BY p.name, fs.fee_type'
)->fetchAll();
$programs = $db->query("SELECT id, name, program_type FROM programs WHERE status = 'active'")->fetchAll();
$intakes = $db->query('SELECT id, name FROM intakes ORDER BY start_date DESC')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Add fee structure</h2></div>
        <div class="card-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <div class="form-group"><label>Program</label><select name="program_id" required>
                    <?php foreach ($programs as $p): ?><option value="<?= $p['id'] ?>"><?= e($p['name']) ?> (<?= programTypeLabel($p['program_type']) ?>)</option><?php endforeach; ?>
                </select></div>
                <div class="form-group"><label>Intake (optional)</label><select name="intake_id"><option value="">All intakes</option>
                    <?php foreach ($intakes as $i): ?><option value="<?= $i['id'] ?>"><?= e($i['name']) ?></option><?php endforeach; ?>
                </select></div>
                <div class="form-group"><label>Description</label><input name="description" required></div>
                <div class="form-row">
                    <div class="form-group"><label>Fee type</label>
                        <select name="fee_type">
                            <?php foreach (['tuition','registration','examination','graduation','practical','accommodation','library','penalty','other'] as $t): ?>
                            <option value="<?= $t ?>"><?= ucfirst($t) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="form-group"><label>Billing model</label>
                        <select name="billing_model">
                            <option value="once_off">Once-off</option>
                            <option value="per_module">Per module</option>
                            <option value="per_semester">Per semester</option>
                            <option value="corporate_group">Corporate group</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group"><label>Amount</label><input type="number" step="0.01" name="amount" required></div>
                    <div class="form-group"><label>Currency</label><select name="currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
                    <div class="form-group"><label>Semester</label><input type="number" name="semester" min="1" max="8" placeholder="Optional"></div>
                </div>
                <label><input type="checkbox" name="allow_installments" value="1"> Allow installments</label>
                <div style="margin-top:1rem;"><button type="submit" class="btn btn-primary">Save</button></div>
            </form>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Fee structures</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Program</th><th>Intake</th><th>Type</th><th>Model</th><th>Description</th><th>Amount</th><th>Installments</th></tr></thead>
            <tbody>
            <?php foreach ($fees as $f): ?>
            <tr>
                <td><?= e($f['program_name']) ?></td>
                <td><?= e($f['intake_name'] ?? 'All') ?></td>
                <td><?= e($f['fee_type'] ?? 'tuition') ?></td>
                <td><?= e(str_replace('_', ' ', $f['billing_model'] ?? '')) ?></td>
                <td><?= e($f['description']) ?></td>
                <td><?= formatMoney((float)$f['amount'], $f['currency'] ?? 'USD') ?></td>
                <td><?= $f['allow_installments'] ? 'Yes' : 'No' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
