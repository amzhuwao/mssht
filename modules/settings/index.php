<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('settings');

$pageTitle = 'System Settings';
$currentModule = 'settings';

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
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
            <li>SMS / Email Notifications</li>
        </ul>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
