<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('settings');
requireRole(['super_admin']);

$pageTitle = 'User Roles';
$currentModule = 'settings';
$db = getDB();
$moduleCatalog = MODULE_CATALOG;
$roleKeyOptions = array_keys(DEFAULT_ROLES);
$editingRoleKey = $editingRole['role_key'] ?? '';
$isSystemRole = !empty($editingRole['is_system']);

$roleKey = trim($_GET['role'] ?? $_POST['role_key'] ?? '');
$editingRole = null;
if ($roleKey !== '') {
    $stmt = $db->prepare('SELECT * FROM roles WHERE role_key = ? LIMIT 1');
    $stmt->execute([$roleKey]);
    $editingRole = $stmt->fetch() ?: null;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? 'save';
    $incomingKey = trim($_POST['role_key'] ?? '');
    $roleKeyMode = $_POST['role_key_mode'] ?? 'preset';
    if ($roleKeyMode === 'custom') {
        $incomingKey = trim($_POST['role_key_custom'] ?? '');
    }
    $label = trim($_POST['label'] ?? '');
    $status = ($_POST['status'] ?? 'active') === 'inactive' ? 'inactive' : 'active';
    $sortOrder = (int) ($_POST['sort_order'] ?? 0);
    $moduleAccess = (array) ($_POST['module_access'] ?? []);
    $allowedModules = [];
    foreach ($moduleAccess as $moduleName => $access) {
        if ($access === 'allow') {
            $allowedModules[] = $moduleName;
        }
    }

    try {
        if ($action === 'delete') {
            if ($incomingKey === '' || $incomingKey === 'super_admin') {
                throw new RuntimeException('This role cannot be deleted.');
            }
            $deleteStmt = $db->prepare('DELETE FROM roles WHERE role_key = ? AND is_system = 0');
            $deleteStmt->execute([$incomingKey]);
            if ($deleteStmt->rowCount() === 0) {
                throw new RuntimeException('Role not found or protected.');
            }
            flash('success', 'Role deleted.');
            redirect(moduleUrl('settings', 'roles'));
        }

        if ($label === '') {
            throw new RuntimeException('Role label is required.');
        }

        if ($incomingKey === '') {
            $incomingKey = strtolower(trim(preg_replace('/[^a-z0-9]+/i', '_', $label), '_'));
        }
        $incomingKey = preg_replace('/[^a-z0-9_]+/i', '', strtolower($incomingKey));
        if ($incomingKey === '') {
            throw new RuntimeException('Role key is required.');
        }

        if ($editingRole && !empty($editingRole['is_system']) && $incomingKey !== $editingRole['role_key']) {
            throw new RuntimeException('System role keys cannot be changed.');
        }

        $payload = json_encode(array_values(array_unique($allowedModules)));
        $upsert = $db->prepare(
            'INSERT INTO roles (role_key, label, module_permissions, is_system, status, sort_order)
             VALUES (?, ?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE label = VALUES(label), module_permissions = VALUES(module_permissions), status = VALUES(status), sort_order = VALUES(sort_order)'
        );
        $upsert->execute([
            $incomingKey,
            $label,
            $payload,
            $editingRole ? (int) $editingRole['is_system'] : 0,
            $status,
            $sortOrder,
        ]);

        flash('success', 'Role saved.');
        redirect(moduleUrl('settings', 'roles') . '?role=' . urlencode($incomingKey));
    } catch (Throwable $e) {
        flash('danger', $e->getMessage() ?: 'Could not save role.');
    }
}

$roles = [];
try {
    $roles = $db->query('SELECT * FROM roles ORDER BY sort_order, label')->fetchAll();
} catch (Throwable $e) {
    $roles = [];
}

$selectedModules = [];
if ($editingRole && !empty($editingRole['module_permissions'])) {
    $decoded = json_decode((string) $editingRole['module_permissions'], true);
    if (is_array($decoded)) {
        $selectedModules = $decoded;
    }
}

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="<?= moduleUrl('settings') ?>" class="btn btn-outline btn-sm">&larr; Back to Settings</a>
</div>

<div class="card">
    <div class="card-header"><h2><?= $editingRole ? 'Edit Role' : 'Create Role' ?></h2></div>
    <div class="card-body">
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="action" value="save">
            <div class="form-row">
                <div class="form-group">
                    <label>Role Key</label>
                    <select name="role_key_mode" id="roleKeyMode" <?= $isSystemRole ? 'disabled' : '' ?>>
                        <?php foreach ($roleKeyOptions as $optionKey): ?>
                        <option value="<?= e($optionKey) ?>" <?= ($editingRoleKey === $optionKey) ? 'selected' : '' ?>><?= e($optionKey) ?></option>
                        <?php endforeach; ?>
                        <option value="custom" <?= (!empty($editingRole) && !in_array($editingRoleKey, $roleKeyOptions, true)) ? 'selected' : '' ?>>Custom key...</option>
                    </select>
                    <input id="customRoleKey" name="role_key_custom" value="<?= e(!empty($editingRole) && !in_array($editingRoleKey, $roleKeyOptions, true) ? $editingRoleKey : '') ?>" placeholder="custom_role" style="margin-top:.5rem;display=<?= (!empty($editingRole) && !in_array($editingRoleKey, $roleKeyOptions, true)) ? 'block' : 'none' ?>;">
                    <input type="hidden" name="role_key" value="<?= e($editingRoleKey) ?>">
                </div>
                <div class="form-group">
                    <label>Role Label</label>
                    <input name="label" required value="<?= e($editingRole['label'] ?? '') ?>" placeholder="Custom Role Name">
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status">
                        <option value="active" <?= (($editingRole['status'] ?? 'active') === 'active') ? 'selected' : '' ?>>Active</option>
                        <option value="inactive" <?= (($editingRole['status'] ?? 'active') === 'inactive') ? 'selected' : '' ?>>Inactive</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Sort Order</label>
                    <input type="number" name="sort_order" value="<?= e((string) ($editingRole['sort_order'] ?? 0)) ?>">
                </div>
            </div>

            <h3 style="margin:1.25rem 0 .75rem;">Module Access</h3>
            <p class="text-muted">Choose which modules this role can access. Roles marked as system roles are protected from deletion.</p>
            <div class="card" style="padding:0.75rem 1rem;max-height:420px;overflow:auto;">
                <?php foreach ($moduleCatalog as $moduleName):
                    $isAllowed = in_array($moduleName, $selectedModules, true);
                ?>
                <div style="display:flex;align-items:center;justify-content:space-between;gap:1rem;margin:.35rem 0;">
                    <div style="flex:1;"><?= e(ucfirst(str_replace('_', ' ', $moduleName))) ?></div>
                    <div style="width:220px;">
                        <select name="module_access[<?= e($moduleName) ?>]" style="width:100%;">
                            <option value="deny" <?= $isAllowed ? '' : 'selected' ?>>Deny</option>
                            <option value="allow" <?= $isAllowed ? 'selected' : '' ?>>Allow</option>
                        </select>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-primary"><?= $editingRole ? 'Update Role' : 'Create Role' ?></button>
                <?php if ($editingRole && empty($editingRole['is_system'])): ?>
                <button type="submit" name="action" value="delete" class="btn btn-danger" onclick="return confirm('Delete this role?');">Delete Role</button>
                <?php endif; ?>
            </div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Existing Roles</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Key</th><th>Label</th><th>Status</th><th>Type</th><th>Modules</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <?php foreach ($roles as $role): ?>
                <tr>
                    <td><?= e($role['role_key']) ?></td>
                    <td><?= e($role['label']) ?></td>
                    <td><?= statusBadge($role['status']) ?></td>
                    <td><?= !empty($role['is_system']) ? 'System' : 'Custom' ?></td>
                    <td><?= (int) count(json_decode((string) ($role['module_permissions'] ?? '[]'), true) ?: []) ?></td>
                    <td>
                        <a class="btn btn-sm btn-outline" href="<?= moduleUrl('settings', 'roles') ?>?role=<?= urlencode($role['role_key']) ?>">Edit</a>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
(function () {
    const mode = document.getElementById('roleKeyMode');
    const custom = document.getElementById('customRoleKey');
    if (!mode || !custom) return;
    function syncRoleKeyVisibility() {
        custom.style.display = mode.value === 'custom' ? 'block' : 'none';
    }
    mode.addEventListener('change', syncRoleKeyVisibility);
    syncRoleKeyVisibility();
})();
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
