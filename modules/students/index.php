<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('students');

$pageTitle = 'Student Information System';
$currentModule = 'students';
$db = getDB();

$students = $db->query(
    'SELECT s.*, p.name AS program_name, i.name AS intake_name
     FROM students s
     JOIN programs p ON p.id = s.program_id
     JOIN intakes i ON i.id = s.intake_id
     ORDER BY s.enrollment_date DESC LIMIT 100'
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <h2 style="margin:0;">Students</h2>
    <div class="search-box"><input type="text" id="tableSearch" placeholder="Search students..."></div>
</div>

<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Student ID</th><th>Program</th><th>Intake</th><th>Status</th><th>Enrolled</th><th></th></tr>
            </thead>
            <tbody>
            <?php foreach ($students as $s): ?>
            <tr>
                <td><strong><?= e($s['student_number']) ?></strong></td>
                <td><?= e($s['program_name']) ?></td>
                <td><?= e($s['intake_name']) ?></td>
                <td><?= statusBadge($s['enrollment_status']) ?></td>
                <td><?= formatDate($s['enrollment_date']) ?></td>
                <td><a href="view.php?id=<?= $s['id'] ?>" class="btn btn-sm btn-outline">View Profile</a></td>
            </tr>
            <?php endforeach; ?>
            <?php if (empty($students)): ?>
            <tr><td colspan="6" class="empty-state">No students enrolled yet. Approve applications to create student records.</td></tr>
            <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
