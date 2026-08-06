<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('students');

$pageTitle = 'Student Information System';
$currentModule = 'students';
$db = getDB();

$q = trim((string) ($_GET['q'] ?? ''));
$programId = (int) ($_GET['program_id'] ?? 0);
$intakeId = (int) ($_GET['intake_id'] ?? 0);
$status = trim((string) ($_GET['status'] ?? ''));
$portal = trim((string) ($_GET['portal'] ?? '')); // '', 'yes', 'no'
$export = ($_GET['export'] ?? '') === 'csv';

$allowedStatuses = ['active', 'graduated', 'withdrawn', 'suspended', 'deferred'];
if ($status !== '' && !in_array($status, $allowedStatuses, true)) {
    $status = '';
}
if (!in_array($portal, ['', 'yes', 'no'], true)) {
    $portal = '';
}

$programs = $db->query("SELECT id, code, name FROM programs WHERE status = 'active' ORDER BY name")->fetchAll(PDO::FETCH_ASSOC);
$intakes = $db->query('SELECT id, name, academic_year FROM intakes ORDER BY start_date DESC, name ASC')->fetchAll(PDO::FETCH_ASSOC);

$where = ' WHERE 1=1';
$params = [];

if ($q !== '') {
    $where .= ' AND (
        s.student_number LIKE ?
        OR COALESCE(s.first_name, up.first_name) LIKE ?
        OR COALESCE(s.last_name, up.last_name) LIKE ?
        OR CONCAT(COALESCE(s.first_name, up.first_name), \' \', COALESCE(s.last_name, up.last_name)) LIKE ?
        OR COALESCE(s.email, u.email) LIKE ?
        OR s.phone LIKE ?
    )';
    $like = '%' . $q . '%';
    array_push($params, $like, $like, $like, $like, $like, $like);
}
if ($programId > 0) {
    $where .= ' AND s.program_id = ?';
    $params[] = $programId;
}
if ($intakeId > 0) {
    $where .= ' AND s.intake_id = ?';
    $params[] = $intakeId;
}
if ($status !== '') {
    $where .= ' AND s.enrollment_status = ?';
    $params[] = $status;
}
if ($portal === 'yes') {
    $where .= ' AND s.user_id IS NOT NULL';
} elseif ($portal === 'no') {
    $where .= ' AND s.user_id IS NULL';
}

$from = ' FROM students s
     JOIN programs p ON p.id = s.program_id
     JOIN intakes i ON i.id = s.intake_id
     LEFT JOIN users u ON u.id = s.user_id
     LEFT JOIN user_profiles up ON up.user_id = u.id';

$countStmt = $db->prepare('SELECT COUNT(*)' . $from . $where);
$countStmt->execute($params);
$totalCount = (int) $countStmt->fetchColumn();

$sql = 'SELECT s.*, p.name AS program_name, p.code AS program_code, i.name AS intake_name,
            COALESCE(s.first_name, up.first_name) AS first_name,
            COALESCE(s.last_name, up.last_name) AS last_name,
            COALESCE(s.email, u.email) AS email,
            s.phone'
    . $from . $where
    . ' ORDER BY s.enrollment_date DESC, s.student_number ASC';

$stmt = $db->prepare($sql);
$stmt->execute($params);
$students = $stmt->fetchAll(PDO::FETCH_ASSOC);

$queryParams = array_filter([
    'q' => $q !== '' ? $q : null,
    'program_id' => $programId > 0 ? (string) $programId : null,
    'intake_id' => $intakeId > 0 ? (string) $intakeId : null,
    'status' => $status !== '' ? $status : null,
    'portal' => $portal !== '' ? $portal : null,
], static fn($v) => $v !== null && $v !== '');

if ($export) {
    header('Content-Type: text/csv; charset=utf-8');
    header('Content-Disposition: attachment; filename="students-' . date('Ymd-His') . '.csv"');
    echo "\xEF\xBB\xBF";
    $out = fopen('php://output', 'w');
    fputcsv($out, [
        'Student Number',
        'First Name',
        'Last Name',
        'Email',
        'Phone',
        'Program Code',
        'Program',
        'Intake',
        'Status',
        'Enrollment Date',
        'Portal Account',
    ]);
    foreach ($students as $s) {
        fputcsv($out, [
            $s['student_number'],
            $s['first_name'] ?? '',
            $s['last_name'] ?? '',
            $s['email'] ?? '',
            $s['phone'] ?? '',
            $s['program_code'] ?? '',
            $s['program_name'] ?? '',
            $s['intake_name'] ?? '',
            $s['enrollment_status'] ?? '',
            $s['enrollment_date'] ?? '',
            !empty($s['user_id']) ? 'yes' : 'no',
        ]);
    }
    fclose($out);
    exit;
}

$exportUrl = '?' . http_build_query(array_merge($queryParams, ['export' => 'csv']));
$hasFilters = $queryParams !== [];

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <h2 style="margin:0;">Students</h2>
    <div style="display:flex;gap:.5rem;align-items:center;flex-wrap:wrap;">
        <a href="<?= moduleUrl('students', 'create') ?>" class="btn btn-primary btn-sm">Register Student</a>
        <a href="<?= moduleUrl('guardians', 'bulk-send') ?>" class="btn btn-outline btn-sm">Bulk guardian summaries</a>
        <a href="<?= e($exportUrl) ?>" class="btn btn-outline btn-sm">Download CSV</a>
    </div>
</div>

<div class="card" style="margin-bottom:1.25rem;">
    <div class="card-header">
        <h2 style="margin:0;font-size:1rem;">Filters</h2>
        <?php if ($hasFilters): ?>
            <a href="?" class="btn btn-outline btn-sm">Clear filters</a>
        <?php endif; ?>
    </div>
    <div class="card-body">
        <form method="get" class="form-row" style="align-items:end;">
            <div class="form-group">
                <label for="filter-q">Search</label>
                <input type="text" id="filter-q" name="q" value="<?= e($q) ?>" placeholder="Name, ID, email, phone">
            </div>
            <div class="form-group">
                <label for="filter-program">Program</label>
                <select id="filter-program" name="program_id">
                    <option value="">All programs</option>
                    <?php foreach ($programs as $p): ?>
                        <option value="<?= (int) $p['id'] ?>" <?= $programId === (int) $p['id'] ? 'selected' : '' ?>>
                            <?= e($p['name']) ?> (<?= e($p['code']) ?>)
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label for="filter-intake">Intake</label>
                <select id="filter-intake" name="intake_id">
                    <option value="">All intakes</option>
                    <?php foreach ($intakes as $i): ?>
                        <option value="<?= (int) $i['id'] ?>" <?= $intakeId === (int) $i['id'] ? 'selected' : '' ?>>
                            <?= e($i['name']) ?><?= $i['academic_year'] ? ' — ' . e($i['academic_year']) : '' ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label for="filter-status">Status</label>
                <select id="filter-status" name="status">
                    <option value="">All statuses</option>
                    <?php foreach ($allowedStatuses as $st): ?>
                        <option value="<?= e($st) ?>" <?= $status === $st ? 'selected' : '' ?>><?= e(ucfirst($st)) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label for="filter-portal">Portal account</label>
                <select id="filter-portal" name="portal">
                    <option value="" <?= $portal === '' ? 'selected' : '' ?>>All</option>
                    <option value="yes" <?= $portal === 'yes' ? 'selected' : '' ?>>Has portal</option>
                    <option value="no" <?= $portal === 'no' ? 'selected' : '' ?>>No portal</option>
                </select>
            </div>
            <div class="form-group" style="display:flex;gap:.5rem;flex-wrap:wrap;">
                <button type="submit" class="btn btn-primary">Apply filters</button>
                <a href="<?= e($exportUrl) ?>" class="btn btn-outline">Download CSV</a>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h2 style="margin:0;font-size:1rem;">
            <?= $totalCount ?> student<?= $totalCount === 1 ? '' : 's' ?>
            <?= $hasFilters ? ' (filtered)' : '' ?>
        </h2>
    </div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Student ID</th>
                    <th>Name</th>
                    <th>Program</th>
                    <th>Intake</th>
                    <th>Status</th>
                    <th>Portal</th>
                    <th>Enrolled</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($students as $s): ?>
            <tr>
                <td><strong><?= e($s['student_number']) ?></strong></td>
                <td><?= e(trim(($s['first_name'] ?? '') . ' ' . ($s['last_name'] ?? '')) ?: '—') ?></td>
                <td><?= e($s['program_name']) ?></td>
                <td><?= e($s['intake_name']) ?></td>
                <td><?= statusBadge($s['enrollment_status']) ?></td>
                <td><?= !empty($s['user_id']) ? 'Yes' : 'No' ?></td>
                <td><?= formatDate($s['enrollment_date']) ?></td>
                <td><a href="view.php?id=<?= (int) $s['id'] ?>" class="btn btn-sm btn-outline">View Profile</a></td>
            </tr>
            <?php endforeach; ?>
            <?php if (empty($students)): ?>
            <tr><td colspan="8" class="empty-state">No students match the selected filters.</td></tr>
            <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
