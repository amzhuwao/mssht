<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('placements');

$pageTitle = 'Industrial Attachment';
$currentModule = 'placements';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare(
        'INSERT INTO placements (student_id, employer_name, supervisor_name, supervisor_contact, start_date, status) VALUES (?, ?, ?, ?, ?, ?)'
    )->execute([
        (int)$_POST['student_id'], trim($_POST['employer_name']),
        trim($_POST['supervisor_name'] ?? ''), trim($_POST['supervisor_contact'] ?? ''),
        $_POST['start_date'], 'active',
    ]);
    flash('success', 'Placement recorded.');
    redirect(moduleUrl('placements'));
}

$placements = $db->query(
    'SELECT pl.*, s.student_number FROM placements pl
     JOIN students s ON s.id = pl.student_id ORDER BY pl.start_date DESC'
)->fetchAll();
$students = $db->query(
    "SELECT s.id, s.student_number, COALESCE(s.first_name, up.first_name) AS first_name, COALESCE(s.last_name, up.last_name) AS last_name
     FROM students s
     LEFT JOIN users u ON u.id = s.user_id
     LEFT JOIN user_profiles up ON up.user_id = u.id
     WHERE s.enrollment_status = 'active'
     ORDER BY s.student_number"
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Record Placement</h2></div>
    <div class="card-body">
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Search student</label><input type="text" id="placementStudentSearch" placeholder="Search by student number, name, or surname"></div>
            <div class="form-group"><label>Student</label><select name="student_id" id="placementStudentSelect" required><option value="">Select student</option><?php foreach ($students as $s): ?><option value="<?= (int) $s['id'] ?>"><?= e(trim($s['student_number'] . ' — ' . trim(($s['first_name'] ?? '') . ' ' . ($s['last_name'] ?? '')))) ?></option><?php endforeach; ?></select></div>
            <div class="form-group"><label>Employer *</label><input name="employer_name" required></div>
            <div class="form-group"><label>Supervisor</label><input name="supervisor_name"></div>
            <div class="form-group"><label>Contact</label><input name="supervisor_contact"></div>
            <div class="form-group"><label>Start Date</label><input type="date" name="start_date" required></div>
            <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Save</button></div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Placements</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Student</th><th>Employer</th><th>Supervisor</th><th>Start</th><th>Status</th></tr></thead>
            <tbody>
            <?php foreach ($placements as $p): ?>
            <tr>
                <td><?= e($p['student_number']) ?></td>
                <td><?= e($p['employer_name']) ?></td>
                <td><?= e($p['supervisor_name'] ?? '—') ?></td>
                <td><?= formatDate($p['start_date']) ?></td>
                <td><?= statusBadge($p['status']) ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
msshtSearchableSelect('placementStudentSearch', 'placementStudentSelect');
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
