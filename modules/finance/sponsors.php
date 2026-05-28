<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');

$pageTitle = 'Sponsorship & Corporate Billing';
$currentModule = 'finance';
$financeSection = 'sponsors';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'add_sponsor') {
        $db->prepare('INSERT INTO finance_sponsors (code, name, sponsor_type, email, phone, billing_terms, credit_limit, currency) VALUES (?, ?, ?, ?, ?, ?, ?, ?)')
           ->execute([generateRef('SPN'), trim($_POST['name']), $_POST['sponsor_type'], trim($_POST['email'] ?? ''), trim($_POST['phone'] ?? ''), trim($_POST['billing_terms'] ?? ''), (float)($_POST['credit_limit'] ?? 0), $_POST['currency'] ?? 'USD']);
        flash('success', 'Sponsor profile created.');
    }
    if ($action === 'link_student') {
        $db->prepare('INSERT IGNORE INTO sponsor_students (sponsor_id, student_id, coverage_percent) VALUES (?, ?, ?)')
           ->execute([(int)$_POST['sponsor_id'], (int)$_POST['student_id'], (float)$_POST['coverage_percent']]);
        flash('success', 'Student linked to sponsor.');
    }
    if ($action === 'bulk_invoice' && (int)$_POST['sponsor_id']) {
        $sid = (int)$_POST['sponsor_id'];
        $links = $db->prepare('SELECT student_id, coverage_percent FROM sponsor_students WHERE sponsor_id = ?');
        $links->execute([$sid]);
        $created = 0;
        while ($link = $links->fetch()) {
            $fee = $db->prepare('SELECT amount, currency, description FROM fee_structures WHERE program_id = (SELECT program_id FROM students WHERE id = ?) AND is_active = 1 LIMIT 1');
            $fee->execute([(int)$link['student_id']]);
            $fee = $fee->fetch();
            if (!$fee) continue;
            $amt = (float)$fee['amount'] * ((float)$link['coverage_percent'] / 100);
            createInvoice([
                'student_id' => (int)$link['student_id'],
                'sponsor_id' => $sid,
                'total_amount' => $amt,
                'currency' => $fee['currency'] ?? 'USD',
                'due_date' => $_POST['due_date'],
                'notes' => 'Corporate/sponsor billing',
            ], [['description' => $fee['description'], 'quantity' => 1, 'unit_amount' => $amt, 'line_total' => $amt]]);
            $created++;
        }
        flash('success', "{$created} sponsor invoice(s) created.");
    }
    redirect(moduleUrl('finance', 'sponsors'));
}

$sponsors = $db->query('SELECT * FROM finance_sponsors ORDER BY name')->fetchAll();
$students = $db->query(
    "SELECT s.id, s.student_number, COALESCE(a.first_name, up.first_name) AS first_name, COALESCE(a.last_name, up.last_name) AS last_name
     FROM students s
     LEFT JOIN applications a ON a.id = s.application_id
     LEFT JOIN users u ON u.id = s.user_id
     LEFT JOIN user_profiles up ON up.user_id = u.id
     WHERE s.enrollment_status = 'active'
     ORDER BY s.student_number"
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="dashboard-grid">
    <div class="card"><div class="card-header"><h2>Add sponsor</h2></div>
    <div class="card-body"><form method="post">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="add_sponsor">
        <div class="form-group"><label>Name</label><input name="name" required></div>
        <div class="form-group"><label>Type</label><select name="sponsor_type"><option value="corporate">Corporate</option><option value="government">Government</option><option value="ngo">NGO</option><option value="other">Other</option></select></div>
        <div class="form-row">
            <div class="form-group"><label>Email</label><input type="email" name="email"></div>
            <div class="form-group"><label>Credit limit</label><input type="number" step="0.01" name="credit_limit" value="0"></div>
        </div>
        <div class="form-group"><label>Billing terms</label><textarea name="billing_terms" rows="2"></textarea></div>
        <button type="submit" class="btn btn-primary">Save</button>
    </form></div></div>
    <div class="card"><div class="card-header"><h2>Link student to sponsor</h2></div>
    <div class="card-body"><form method="post">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="link_student">
        <div class="form-group"><label>Search sponsor</label><input type="text" id="sponsorSearch" placeholder="Search sponsors"></div>
        <div class="form-group"><label>Sponsor</label><select name="sponsor_id" id="sponsorSelect" required><option value="">Select sponsor</option><?php foreach ($sponsors as $sp): ?><option value="<?= (int) $sp['id'] ?>"><?= e($sp['name']) ?></option><?php endforeach; ?></select></div>
        <div class="form-group"><label>Search student</label><input type="text" id="sponsorStudentSearch" placeholder="Search by student number, name, or surname"></div>
        <div class="form-group"><label>Student</label><select name="student_id" id="sponsorStudentSelect" required><option value="">Select student</option><?php foreach ($students as $s): ?><option value="<?= (int) $s['id'] ?>"><?= e(trim($s['student_number'] . ' — ' . trim(($s['first_name'] ?? '') . ' ' . ($s['last_name'] ?? '')))) ?></option><?php endforeach; ?></select></div>
        <div class="form-group"><label>Coverage %</label><input type="number" name="coverage_percent" value="100" min="1" max="100"></div>
        <button type="submit" class="btn btn-outline">Link</button>
    </form></div></div>
</div>

<div class="card" style="margin-top:1.5rem;"><div class="card-header"><h2>Sponsors</h2></div>
<div class="card-body table-wrap"><table class="data-table">
<thead><tr><th>Code</th><th>Name</th><th>Type</th><th>Email</th><th>Credit limit</th><th>Students</th><th></th></tr></thead>
<tbody>
<?php foreach ($sponsors as $sp):
    $cnt = $db->prepare('SELECT COUNT(*) FROM sponsor_students WHERE sponsor_id = ?');
    $cnt->execute([$sp['id']]);
    $cnt = (int)$cnt->fetchColumn();
?>
<tr>
    <td><?= e($sp['code']) ?></td><td><?= e($sp['name']) ?></td><td><?= e($sp['sponsor_type']) ?></td>
    <td><?= e($sp['email'] ?? '—') ?></td><td><?= formatMoney((float)$sp['credit_limit'], $sp['currency'] ?? 'USD') ?></td>
    <td><?= $cnt ?></td>
    <td><form method="post" class="form-row" style="gap:.25rem;"><input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="bulk_invoice"><input type="hidden" name="sponsor_id" value="<?= (int)$sp['id'] ?>"><input type="date" name="due_date" required value="<?= date('Y-m-d', strtotime('+30 days')) ?>"><button class="btn btn-sm btn-primary">Bulk invoice</button></form></td>
</tr>
<?php endforeach; ?>
</tbody></table></div></div>

<script>
msshtSearchableSelect('sponsorSearch', 'sponsorSelect');
msshtSearchableSelect('sponsorStudentSearch', 'sponsorStudentSelect');
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
