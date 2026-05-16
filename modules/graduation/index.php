<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('graduation');

$pageTitle = 'Certification & Graduation';
$currentModule = 'graduation';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $studentId = (int)$_POST['student_id'];
    $student = $db->prepare('SELECT program_id FROM students WHERE id = ?');
    $student->execute([$studentId]);
    $student = $student->fetch();
    if ($student) {
        $certNum = generateRef('CERT');
        $qr = bin2hex(random_bytes(16));
        $db->prepare(
            'INSERT INTO graduations (student_id, program_id, graduation_date, certificate_number, qr_verification_code, gpa)
             VALUES (?, ?, ?, ?, ?, ?)'
        )->execute([$studentId, $student['program_id'], $_POST['graduation_date'], $certNum, $qr, $_POST['gpa'] ?: null]);
        $db->prepare("UPDATE students SET enrollment_status = 'graduated' WHERE id = ?")->execute([$studentId]);
        flash('success', "Certificate issued: $certNum (QR: $qr)");
    }
    redirect(moduleUrl('graduation'));
}

$graduations = $db->query(
    'SELECT g.*, s.student_number, p.name AS program_name
     FROM graduations g JOIN students s ON s.id = g.student_id
     JOIN programs p ON p.id = g.program_id ORDER BY g.graduation_date DESC'
)->fetchAll();
$eligible = $db->query("SELECT id, student_number FROM students WHERE enrollment_status = 'active'")->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Issue Certificate</h2></div>
    <div class="card-body">
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Student</label><select name="student_id" required><?php foreach ($eligible as $s): ?><option value="<?= $s['id'] ?>"><?= e($s['student_number']) ?></option><?php endforeach; ?></select></div>
            <div class="form-group"><label>Graduation Date</label><input type="date" name="graduation_date" required></div>
            <div class="form-group"><label>GPA</label><input type="number" step="0.01" name="gpa" min="0" max="4"></div>
            <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Issue Certificate</button></div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Graduation Records</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Certificate #</th><th>Student</th><th>Program</th><th>Date</th><th>QR Verify</th><th>GPA</th></tr></thead>
            <tbody>
            <?php foreach ($graduations as $g): ?>
            <tr>
                <td><?= e($g['certificate_number']) ?></td>
                <td><?= e($g['student_number']) ?></td>
                <td><?= e($g['program_name']) ?></td>
                <td><?= formatDate($g['graduation_date']) ?></td>
                <td><code><?= e($g['qr_verification_code']) ?></code></td>
                <td><?= e($g['gpa'] ?? '—') ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
