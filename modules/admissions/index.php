<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('admissions');

$pageTitle = 'Admissions';
$currentModule = 'admissions';
$db = getDB();

$status = $_GET['status'] ?? '';
$sql = 'SELECT a.*, p.name AS program_name, i.name AS intake_name
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
                    <th>Program</th>
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
