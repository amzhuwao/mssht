<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('settings');
requireRole(['super_admin']);

$pageTitle = 'Backup & Restore';
$currentModule = 'settings';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';

    try {
        if ($action === 'create_backup') {
            $result = backupDatabase($db, trim($_POST['backup_name'] ?? '') ?: null);
            flash('success', 'Backup created: ' . $result['filename']);
            redirect(moduleUrl('settings', 'backup'));
        }

        if ($action === 'restore_backup') {
            $restorePath = '';
            $resetExisting = !empty($_POST['reset_existing']);

            if (!empty($_FILES['backup_file']['name'])) {
                $upload = $_FILES['backup_file'];
                if (($upload['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
                    throw new RuntimeException('Could not upload backup file.');
                }
                $ext = strtolower(pathinfo($upload['name'], PATHINFO_EXTENSION));
                if (!in_array($ext, ['sql'], true)) {
                    throw new RuntimeException('Backup file must be a .sql file.');
                }
                $restorePath = ensureBackupDirectory() . '/' . uniqid('restore_', true) . '.sql';
                if (!move_uploaded_file($upload['tmp_name'], $restorePath)) {
                    throw new RuntimeException('Could not save uploaded backup file.');
                }
            } else {
                $selectedFile = trim($_POST['existing_backup'] ?? '');
                if ($selectedFile === '') {
                    throw new RuntimeException('Choose a backup file or upload one first.');
                }
                $restorePath = realpath(ensureBackupDirectory() . '/' . basename($selectedFile)) ?: '';
                if ($restorePath === '' || strpos($restorePath, realpath(ensureBackupDirectory()) ?: '') !== 0) {
                    throw new RuntimeException('Invalid backup selection.');
                }
            }

            $result = restoreDatabase($db, $restorePath, $resetExisting);
            flash('success', 'Backup restored successfully. Executed ' . $result['executed'] . ' SQL statements.');
            redirect(moduleUrl('settings', 'backup'));
        }
    } catch (Throwable $e) {
        flash('danger', $e->getMessage());
    }
}

$backups = backupFiles();
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="<?= moduleUrl('settings') ?>" class="btn btn-outline btn-sm">&larr; Back to Settings</a>
</div>

<div class="card">
    <div class="card-header"><h2>Create Backup</h2></div>
    <div class="card-body">
        <p class="text-muted">Generate a SQL backup of the current database and store it in the backups folder.</p>
        <form method="post" class="form-row" style="align-items:flex-end;">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="action" value="create_backup">
            <div class="form-group" style="flex:1;">
                <label>Backup filename (optional)</label>
                <input name="backup_name" placeholder="mssht-backup-20260529.sql">
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-primary">Create Backup</button>
            </div>
        </form>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Restore Backup</h2></div>
    <div class="card-body">
        <p class="text-muted">Restore from an existing backup file or upload a `.sql` backup. Check the reset option to replace current data.</p>
        <form method="post" enctype="multipart/form-data" class="form-stack" onsubmit="return confirm('Restore will overwrite database tables. Continue?');">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="action" value="restore_backup">
            <div class="form-row">
                <div class="form-group" style="flex:1;">
                    <label>Upload backup file</label>
                    <input type="file" name="backup_file" accept=".sql">
                </div>
                <div class="form-group" style="flex:1;">
                    <label>Or choose existing backup</label>
                    <select name="existing_backup">
                        <option value="">-- Select backup --</option>
                        <?php foreach ($backups as $backup): ?>
                        <option value="<?= e($backup['name']) ?>"><?= e($backup['name']) ?> (<?= number_format($backup['size'] / 1024, 1) ?> KB)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
            <div class="form-group">
                <label><input type="checkbox" name="reset_existing" value="1" checked> Reset existing database objects before restore</label>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-danger">Restore Backup</button>
            </div>
        </form>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Available Backups</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>File</th><th>Size</th><th>Modified</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <?php foreach ($backups as $backup): ?>
                <tr>
                    <td><?= e($backup['name']) ?></td>
                    <td><?= number_format($backup['size'] / 1024, 1) ?> KB</td>
                    <td><?= e(date('d M Y H:i', $backup['modified'])) ?></td>
                    <td><a class="btn btn-sm btn-outline" href="<?= e(BACKUP_URL . '/' . rawurlencode($backup['name'])) ?>" target="_blank" rel="noopener">Download</a></td>
                </tr>
                <?php endforeach; ?>
                <?php if (!$backups): ?>
                <tr><td colspan="4" class="text-muted">No backups found yet.</td></tr>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
