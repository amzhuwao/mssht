<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('programs');

$pageTitle = 'Programs & Courses';
$currentModule = 'programs';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare(
        'INSERT INTO programs (code, name, program_type, duration_months, total_credits, description) VALUES (?, ?, ?, ?, ?, ?)'
    )->execute([
        strtoupper(trim($_POST['code'])),
        trim($_POST['name']),
        $_POST['program_type'],
        (int)$_POST['duration_months'],
        (float)$_POST['total_credits'],
        trim($_POST['description'] ?? ''),
    ]);
    flash('success', 'Program created.');
    redirect(moduleUrl('programs'));
}

$programs = $db->query('SELECT p.*, (SELECT COUNT(*) FROM modules m WHERE m.program_id = p.id) AS module_count FROM programs p ORDER BY p.name')->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <h2 style="margin:0;">Programs</h2>
    <button type="button" class="btn btn-primary btn-sm" id="showAddProgram">+ Add Program</button>
</div>

<div class="card" id="addProgramForm" style="display:none;">
    <div class="card-header"><h2>New Program</h2></div>
    <div class="card-body">
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-row">
                <div class="form-group"><label>Code *</label><input name="code" required placeholder="HND-HOSP-401"></div>
                <div class="form-group"><label>Name *</label><input name="name" required></div>
                <div class="form-group">
                    <label>Type *</label>
                    <select name="program_type" required>
                        <option value="short_course">Short Course</option>
                        <option value="certificate">Professional Certificate</option>
                        <option value="diploma">Diploma</option>
                        <option value="hnd">HND</option>
                    </select>
                </div>
                <div class="form-group"><label>Duration (months)</label><input type="number" name="duration_months" value="12" min="1"></div>
                <div class="form-group"><label>Total Credits</label><input type="number" step="0.01" name="total_credits" value="0"></div>
            </div>
            <div class="form-group"><label>Description</label><textarea name="description" rows="2"></textarea></div>
            <button type="submit" class="btn btn-primary">Save Program</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Code</th><th>Program</th><th>Type</th><th>Modules</th><th>Duration</th><th>Status</th><th></th></tr>
            </thead>
            <tbody>
            <?php foreach ($programs as $p): ?>
            <tr>
                <td><?= e($p['code']) ?></td>
                <td><?= e($p['name']) ?></td>
                <td><?= programTypeLabel($p['program_type']) ?></td>
                <td><?= (int)$p['module_count'] ?></td>
                <td><?= (int)$p['duration_months'] ?> mo</td>
                <td><?= statusBadge($p['status']) ?></td>
                <td><a href="modules.php?program_id=<?= $p['id'] ?>" class="btn btn-sm btn-outline">Modules</a></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
$('#showAddProgram').on('click', function() { $('#addProgramForm').slideToggle(); });
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
