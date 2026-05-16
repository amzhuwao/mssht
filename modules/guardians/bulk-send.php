<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();
requireModule('students');

$db = getDB();
$intakes = $db->query('SELECT id, name, status FROM intakes ORDER BY start_date DESC')->fetchAll();
$programs = $db->query("SELECT id, name FROM programs WHERE status = 'active' ORDER BY name")->fetchAll();

$intakeId = (int) ($_GET['intake_id'] ?? $_POST['intake_id'] ?? 0);
$programId = (int) ($_GET['program_id'] ?? $_POST['program_id'] ?? 0) ?: null;
$preview = $intakeId ? countIntakeGuardianSummaryJobs($intakeId, $programId) : null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $intakeId = (int) ($_POST['intake_id'] ?? 0);
    $programId = (int) ($_POST['program_id'] ?? 0) ?: null;
    if (!$intakeId) {
        flash('danger', 'Select an intake.');
        redirect(moduleUrl('guardians', 'bulk-send'));
    }
    $result = sendIntakeGuardianSummaries($intakeId, $programId);
    flash(
        'success',
        "Bulk send complete: {$result['sent']} sent, {$result['failed']} failed "
        . "({$result['students']} students, {$result['total']} emails)."
    );
    redirect(moduleUrl('guardians', 'bulk-send') . '?intake_id=' . $intakeId . ($programId ? '&program_id=' . $programId : ''));
}

$pageTitle = 'Bulk Guardian Summaries';
$currentModule = 'students';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Send summaries by intake</h2></div>
    <div class="card-body">
        <p class="text-muted">Emails all guardians (with summaries enabled) for active students in the selected intake. Each guardian–student pair receives one email.</p>
        <form method="get" class="form-row" style="margin-bottom:1.5rem;">
            <div class="form-group">
                <label>Intake</label>
                <select name="intake_id" required onchange="this.form.submit()">
                    <option value="">Select intake</option>
                    <?php foreach ($intakes as $i): ?>
                    <option value="<?= (int)$i['id'] ?>" <?= $intakeId === (int)$i['id'] ? 'selected' : '' ?>><?= e($i['name']) ?> (<?= e($i['status']) ?>)</option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Program (optional)</label>
                <select name="program_id" onchange="this.form.submit()">
                    <option value="">All programs</option>
                    <?php foreach ($programs as $p): ?>
                    <option value="<?= (int)$p['id'] ?>" <?= $programId === (int)$p['id'] ? 'selected' : '' ?>><?= e($p['name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
        </form>

        <?php if ($preview && $intakeId): ?>
        <div class="alert alert-info">
            <strong>Preview:</strong>
            <?= (int)$preview['students'] ?> student(s),
            <?= (int)$preview['guardians'] ?> guardian(s),
            <?= (int)$preview['emails'] ?> email(s) to send.
        </div>
        <?php if ($preview['emails'] > 0): ?>
        <form method="post" onsubmit="return confirm('Send <?= (int)$preview['emails'] ?> summary email(s)? This may take a minute.');">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="intake_id" value="<?= $intakeId ?>">
            <?php if ($programId): ?><input type="hidden" name="program_id" value="<?= $programId ?>"><?php endif; ?>
            <button type="submit" class="btn btn-primary">Send all now</button>
            <a href="<?= moduleUrl('students') ?>" class="btn btn-outline">Cancel</a>
        </form>
        <?php else: ?>
        <p class="text-muted">No guardians with summaries enabled for students in this selection.</p>
        <?php endif; ?>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
