<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('settings');
requireRole(['super_admin']);

$pageTitle = 'System Settings';
$currentModule = 'settings';
$mail = getMailConfig();
$testResult = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'save_mail') {
        saveMailSettings($_POST);
        $mail = getMailConfig();
        flash('success', 'Mail settings saved.');
        redirect(moduleUrl('settings'));
    }
    if ($action === 'test_mail') {
        $to = trim($_POST['test_email'] ?? '');
        if (!filter_var($to, FILTER_VALIDATE_EMAIL)) {
            flash('danger', 'Enter a valid test email address.');
        } else {
            $testResult = sendTestEmail($to) ? 'success' : 'failed';
            $mail = getMailConfig();
        }
    }
}

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Email / SMTP</h2></div>
    <div class="card-body">
        <?php if ($testResult === 'success'): ?>
        <div class="alert alert-success">Test email sent to <?= e($_POST['test_email'] ?? '') ?>.</div>
        <?php elseif ($testResult === 'failed'): ?>
        <div class="alert alert-danger">Test email could not be sent. Check driver, SMTP credentials, and that mail is enabled.</div>
        <?php endif; ?>

        <form method="post" class="form-stack" style="max-width:640px;">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="action" value="save_mail">

            <div class="form-group">
                <label><input type="checkbox" name="enabled" value="1" <?= $mail['enabled'] ? 'checked' : '' ?>> Enable outbound email</label>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>From name</label>
                    <input name="from_name" value="<?= e($mail['from_name']) ?>" required>
                </div>
                <div class="form-group">
                    <label>From email</label>
                    <input type="email" name="from_email" value="<?= e($mail['from_email']) ?>" required>
                </div>
            </div>
            <div class="form-group">
                <label>Driver</label>
                <select name="driver" id="mailDriver">
                    <option value="mail" <?= $mail['driver'] === 'mail' ? 'selected' : '' ?>>PHP mail()</option>
                    <option value="smtp" <?= $mail['driver'] === 'smtp' ? 'selected' : '' ?>>SMTP</option>
                </select>
            </div>

            <div id="smtpFields" style="<?= $mail['driver'] === 'smtp' ? '' : 'display:none;' ?>">
                <h3 style="font-size:1rem;margin:1rem 0 .5rem;">SMTP</h3>
                <div class="form-row">
                    <div class="form-group">
                        <label>Host</label>
                        <input name="smtp_host" value="<?= e($mail['smtp_host']) ?>" placeholder="smtp.gmail.com">
                    </div>
                    <div class="form-group">
                        <label>Port</label>
                        <input type="number" name="smtp_port" value="<?= (int)$mail['smtp_port'] ?>">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Username</label>
                        <input name="smtp_user" value="<?= e($mail['smtp_user']) ?>" autocomplete="off">
                    </div>
                    <div class="form-group">
                        <label>Password</label>
                        <input type="password" name="smtp_pass" placeholder="<?= $mail['smtp_pass'] ? '•••••••• (unchanged if blank)' : '' ?>" autocomplete="new-password">
                    </div>
                </div>
                <div class="form-group">
                    <label>Encryption</label>
                    <select name="smtp_secure">
                        <option value="tls" <?= $mail['smtp_secure'] === 'tls' ? 'selected' : '' ?>>TLS (STARTTLS)</option>
                        <option value="ssl" <?= $mail['smtp_secure'] === 'ssl' ? 'selected' : '' ?>>SSL</option>
                    </select>
                </div>
            </div>

            <div class="form-group">
                <label><input type="checkbox" name="fallback_show_link" value="1" <?= $mail['fallback_show_link'] ? 'checked' : '' ?>>
                    Show password-reset link on screen when email fails</label>
            </div>

            <button type="submit" class="btn btn-primary">Save mail settings</button>
        </form>

        <hr style="margin:2rem 0;">

        <h3 style="font-size:1rem;margin-bottom:.75rem;">Send test email</h3>
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="action" value="test_mail">
            <div class="form-group" style="flex:1;">
                <label>Recipient</label>
                <input type="email" name="test_email" placeholder="you@example.com" required value="<?= e(currentUser()['email'] ?? '') ?>">
            </div>
            <div class="form-group" style="align-self:flex-end;">
                <button type="submit" class="btn btn-outline">Send test</button>
            </div>
        </form>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>System Configuration</h2></div>
    <div class="card-body">
        <table class="data-table">
            <tbody>
                <tr><td><strong>Application</strong></td><td><?= e(APP_FULL_NAME) ?></td></tr>
                <tr><td><strong>Version</strong></td><td><?= e(APP_VERSION) ?></td></tr>
                <tr><td><strong>Base URL</strong></td><td><?= e(APP_URL) ?></td></tr>
                <tr><td><strong>Timezone</strong></td><td>Africa/Harare</td></tr>
                <tr><td><strong>Database</strong></td><td><?= e(DB_NAME) ?> @ <?= e(DB_HOST) ?></td></tr>
            </tbody>
        </table>
        <h3 style="margin:1.5rem 0 .75rem;">Integrations (Planned)</h3>
        <ul class="module-list">
            <li>Moodle LMS</li>
            <li>Zoom / Microsoft Teams</li>
            <li>Payment Gateways</li>
            <li>Biometric Attendance</li>
            <li>SMS Notifications</li>
        </ul>
    </div>
</div>

<script>
document.getElementById('mailDriver')?.addEventListener('change', function () {
    document.getElementById('smtpFields').style.display = this.value === 'smtp' ? '' : 'none';
});
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
