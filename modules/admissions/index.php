<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('admissions');

$pageTitle = 'Admissions';
$currentModule = 'admissions';
$db = getDB();

$status = $_GET['status'] ?? '';
$sql = 'SELECT a.*, p.name AS program_name, i.name AS intake_name,
    JSON_UNQUOTE(JSON_EXTRACT(a.notes, "$.national_id")) AS national_id,
    JSON_UNQUOTE(JSON_EXTRACT(a.notes, "$.attendance_type")) AS attendance_type,
    JSON_UNQUOTE(JSON_EXTRACT(a.notes, "$.first_choice")) AS first_choice
    FROM applications a
    JOIN programs p ON p.id = a.program_id
    JOIN intakes i ON i.id = a.intake_id WHERE 1=1';
$params = [];
if ($status) {
    $sql .= ' AND a.status = ?';
    $params[] = $status;
}
$sql .= ' ORDER BY a.created_at DESC LIMIT 100';
$stmt = $db->prepare($sql);
$stmt->execute($params);
$applications = $stmt->fetchAll();

// CSV export
if (isset($_GET['export']) && $_GET['export'] === 'csv') {
    header('Content-Type: text/csv');
    header('Content-Disposition: attachment; filename="applications.csv"');
    $out = fopen('php://output', 'w');
    fputcsv($out, ['Ref','First Name','Last Name','Email','Phone','National ID','Attendance','First Choice','Program','Intake','Status','Applied At']);
    foreach ($applications as $r) {
        // resolve first_choice program name when numeric
        $firstChoiceLabel = '';
        if (!empty($r['first_choice'])) {
            if (is_numeric($r['first_choice'])) {
                $q = $db->prepare('SELECT name FROM programs WHERE id = ?');
                $q->execute([(int)$r['first_choice']]);
                $firstChoiceLabel = $q->fetchColumn() ?: $r['first_choice'];
            } else {
                $firstChoiceLabel = $r['first_choice'];
            }
        }
        fputcsv($out, [
            $r['application_ref'],
            $r['first_name'],
            $r['last_name'],
            $r['email'],
            $r['phone'],
            $r['national_id'] ?? '',
            $r['attendance_type'] ?? '',
            $firstChoiceLabel,
            $r['program_name'],
            $r['intake_name'],
            $r['status'],
            $r['created_at'],
        ]);
    }
    fclose($out);
    exit;
}

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <div class="tabs">
        <a href="?" class="tab-link <?= !$status ? 'active' : '' ?>">All</a>
        <a href="?status=pending" class="tab-link <?= $status === 'pending' ? 'active' : '' ?>">Pending</a>
        <a href="?status=under_review" class="tab-link <?= $status === 'under_review' ? 'active' : '' ?>">Under Review</a>
        <a href="?status=approved" class="tab-link <?= $status === 'approved' ? 'active' : '' ?>">Approved</a>
    </div>
    <a href="apply.php" class="btn btn-primary btn-sm" target="_blank">Public Apply Form</a>
    <a href="?export=csv" class="btn btn-outline btn-sm">Export CSV</a>
</div>

<div class="card">
    <div class="card-header">
        <h2>Applications</h2>
        <div class="search-box">
            <input type="text" id="tableSearch" placeholder="Search applications...">
        </div>
    </div>
    <div class="card-body table-wrap">
        <?php if (empty($applications)): ?>
        <p class="empty-state">No applications found.</p>
        <?php else: ?>
        <table class="data-table">
            <thead>
                <tr>
                    <th>Ref</th>
                    <th>Applicant</th>
                    <th>National ID</th>
                    <th>Attendance</th>
                    <th>Program</th>
                    <th>First Choice</th>
                    <th>Intake</th>
                    <th>Status</th>
                    <th>Date</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($applications as $app): ?>
                <tr>
                    <td><?= e($app['application_ref']) ?></td>
                    <td><?= e($app['first_name'] . ' ' . $app['last_name']) ?><br><small class="text-muted"><?= e($app['email']) ?></small></td>
                    <td><?= e($app['national_id'] ?? '') ?></td>
                    <td><?= e($app['attendance_type'] ?? '') ?></td>
                    <td>
                        <?php
                        // display first_choice program name when stored as id
                        if (!empty($app['first_choice']) && is_numeric($app['first_choice'])) {
                            $pname = $db->prepare('SELECT name FROM programs WHERE id = ?');
                            $pname->execute([(int)$app['first_choice']]);
                            echo e($pname->fetchColumn() ?: $app['first_choice']);
                        } else {
                            echo e($app['first_choice'] ?? '');
                        }
                        ?>
                    </td>
                    <td><?= e($app['program_name']) ?></td>
                    <td><?= e($app['intake_name']) ?></td>
                    <td><?= statusBadge($app['status']) ?></td>
                    <td><?= formatDate($app['created_at']) ?></td>
                    <td class="table-actions">
                        <a href="review.php?id=<?= (int)$app['id'] ?>" class="btn btn-sm btn-outline">Review</a>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
