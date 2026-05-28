<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('users');

$pageTitle = 'Edit User';
$currentModule = 'users';
$db = getDB();

$id = (int) ($_GET['id'] ?? 0);
$stmt = $db->prepare(
    'SELECT u.*, p.first_name, p.last_name, p.phone, p.gender, p.date_of_birth, p.national_id, p.address
     FROM users u
     JOIN user_profiles p ON p.user_id = u.id
     WHERE u.id = ?'
);
$stmt->execute([$id]);
$user = $stmt->fetch();
if (!$user) {
    flash('danger', 'User not found.');
    redirect(moduleUrl('users'));
}

$staff = null;
$staffStmt = $db->prepare('SELECT * FROM staff WHERE user_id = ?');
$staffStmt->execute([$id]);
$staff = $staffStmt->fetch() ?: null;

$permissionStmt = $db->prepare('SELECT module_name, access FROM user_module_permissions WHERE user_id = ?');
$permissionStmt->execute([$id]);
$permissionRows = $permissionStmt->fetchAll();
$permissionMap = [];
foreach ($permissionRows as $row) {
    $permissionMap[$row['module_name']] = $row['access'];
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $email = trim($_POST['email'] ?? '');
    $firstName = trim($_POST['first_name'] ?? '');
    $lastName = trim($_POST['last_name'] ?? '');
    $phone = trim($_POST['phone'] ?? '');
    $role = $_POST['role'] ?? $user['role'];
    $status = $_POST['status'] ?? $user['status'];
    $mustChangePassword = isset($_POST['must_change_password']) ? 1 : 0;
    $newPassword = trim($_POST['password'] ?? '');
    $department = trim($_POST['department'] ?? '');
    $position = trim($_POST['position'] ?? 'Lecturer');
    // module_access is an associative array: module_access[module_name] => 'inherit'|'allow'|'deny'
    $moduleAccess = (array) ($_POST['module_access'] ?? []);
    $allowModules = [];
    $denyModules = [];
    foreach ($moduleAccess as $mName => $access) {
        if ($access === 'allow') $allowModules[] = $mName;
        if ($access === 'deny') $denyModules[] = $mName;
    }

    try {
        $db->beginTransaction();

        $updateUserSql = 'UPDATE users SET email = ?, role = ?, status = ?, must_change_password = ?';
        $params = [$email, $role, $status, $mustChangePassword];
        if ($newPassword !== '') {
            $updateUserSql .= ', password_hash = ?';
            $params[] = password_hash($newPassword, PASSWORD_DEFAULT);
        }
        $updateUserSql .= ' WHERE id = ?';
        $params[] = $id;
        $db->prepare($updateUserSql)->execute($params);

        $db->prepare('UPDATE user_profiles SET first_name = ?, last_name = ?, phone = ?, gender = ?, date_of_birth = ?, national_id = ?, address = ? WHERE user_id = ?')
           ->execute([
               $firstName,
               $lastName,
               $phone,
               $_POST['gender'] ?? null,
               $_POST['date_of_birth'] ?: null,
               trim($_POST['national_id'] ?? ''),
               trim($_POST['address'] ?? ''),
               $id,
           ]);

        if ($role === 'lecturer') {
            if ($staff) {
                $db->prepare('UPDATE staff SET department = ?, position = ? WHERE user_id = ?')
                   ->execute([$department, $position, $id]);
            } else {
                $db->prepare('INSERT INTO staff (user_id, staff_number, department, position, hire_date) VALUES (?, ?, ?, ?, CURDATE())')
                   ->execute([$id, generateRef('STF'), $department, $position]);
            }
        } elseif ($staff) {
            $db->prepare('DELETE FROM staff WHERE user_id = ?')->execute([$id]);
        }

        $db->prepare('DELETE FROM user_module_permissions WHERE user_id = ?')->execute([$id]);
        $insertPermission = $db->prepare('INSERT INTO user_module_permissions (user_id, module_name, access) VALUES (?, ?, ?)');
        foreach ($allowModules as $moduleName) {
            if ($moduleName !== '') {
                $insertPermission->execute([$id, $moduleName, 'allow']);
            }
        }
        foreach ($denyModules as $moduleName) {
            if ($moduleName !== '' && !in_array($moduleName, $allowModules, true)) {
                $insertPermission->execute([$id, $moduleName, 'deny']);
            }
        }

        $db->commit();
        flash('success', 'User updated.');
        redirect(moduleUrl('users', 'edit') . '?id=' . $id);
    } catch (Throwable $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        flash('danger', 'Could not update user. Please try again.');
    }
}

$roleList = getRoles();
require_once __DIR__ . '/../../includes/header.php';
?>

<?php
// Fetch a small list of users for the quick selector
$allUsersStmt = $db->query('SELECT u.id, u.email, p.first_name, p.last_name FROM users u LEFT JOIN user_profiles p ON p.user_id = u.id ORDER BY u.email');
$allUsers = $allUsersStmt->fetchAll();
?>

<div style="margin-bottom:1rem;display:flex;gap:1rem;align-items:center;">
    <label style="font-weight:600;">Edit user:</label>
    <input type="text" id="userSelectorSearch" placeholder="Search user by name or email" style="min-width:260px;">
    <select id="userSelector" style="min-width:320px;">
        <?php foreach ($allUsers as $au): ?>
        <option value="<?= (int)$au['id'] ?>" <?= (int)$au['id'] === $id ? 'selected' : '' ?>><?= e(($au['first_name'] || $au['last_name']) ? trim(($au['first_name'] . ' ' . $au['last_name'])) : $au['email']) ?></option>
        <?php endforeach; ?>
    </select>
</div>

<script>
document.getElementById('userSelectorSearch')?.addEventListener('input', function () {
    var q = this.value.toLowerCase().trim();
    var select = document.getElementById('userSelector');
    if (!select) return;
    var currentValue = select.value;
    var options = Array.from(select.options).map(function (option) {
        return { value: option.value, text: option.textContent };
    });
    select.innerHTML = '';
    options.forEach(function (option, index) {
        if (!q || index === 0 || option.text.toLowerCase().indexOf(q) > -1) {
            var opt = document.createElement('option');
            opt.value = option.value;
            opt.textContent = option.text;
            select.appendChild(opt);
        }
    });
    if (currentValue) select.value = currentValue;
});
document.getElementById('userSelector').addEventListener('change', function () {
    var uid = this.value;
    if (uid) {
        window.location = 'edit.php?id=' + encodeURIComponent(uid);
    }
});
</script>

<div class="page-actions">
    <a href="index.php" class="btn btn-outline btn-sm">&larr; Back to Users</a>
</div>

<div class="card">
    <div class="card-header"><h2>Edit User Account</h2></div>
    <div class="card-body">
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-row">
                <div class="form-group"><label>First Name</label><input name="first_name" required value="<?= e($user['first_name']) ?>"></div>
                <div class="form-group"><label>Last Name</label><input name="last_name" required value="<?= e($user['last_name']) ?>"></div>
                <div class="form-group"><label>Email</label><input type="email" name="email" required value="<?= e($user['email']) ?>"></div>
                <div class="form-group"><label>Phone</label><input name="phone" value="<?= e($user['phone'] ?? '') ?>"></div>
                <div class="form-group">
                    <label>Gender</label>
                    <select name="gender">
                        <option value="">Select</option>
                        <option value="male" <?= ($user['gender'] ?? '') === 'male' ? 'selected' : '' ?>>Male</option>
                        <option value="female" <?= ($user['gender'] ?? '') === 'female' ? 'selected' : '' ?>>Female</option>
                        <option value="other" <?= ($user['gender'] ?? '') === 'other' ? 'selected' : '' ?>>Other</option>
                    </select>
                </div>
                <div class="form-group"><label>Date of Birth</label><input type="date" name="date_of_birth" value="<?= e($user['date_of_birth'] ?? '') ?>"></div>
                <div class="form-group"><label>National ID</label><input name="national_id" value="<?= e($user['national_id'] ?? '') ?>"></div>
                <div class="form-group"><label>Address</label><input name="address" value="<?= e($user['address'] ?? '') ?>"></div>
                <div class="form-group">
                    <label>Role</label>
                    <input type="text" id="userEditRoleSearch" placeholder="Search roles">
                    <select name="role" id="userEditRoleSelect" required>
                        <?php foreach ($roleList as $key => $label): ?>
                        <option value="<?= e($key) ?>" <?= $user['role'] === $key ? 'selected' : '' ?>><?= e($label) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" required>
                        <option value="active" <?= $user['status'] === 'active' ? 'selected' : '' ?>>Active</option>
                        <option value="inactive" <?= $user['status'] === 'inactive' ? 'selected' : '' ?>>Inactive</option>
                        <option value="suspended" <?= $user['status'] === 'suspended' ? 'selected' : '' ?>>Suspended</option>
                    </select>
                </div>
                <div class="form-group"><label>New Password</label><input type="password" name="password" minlength="8" placeholder="Leave blank to keep current password"></div>
                <div class="form-group"><label><input type="checkbox" name="must_change_password" value="1" <?= !empty($user['must_change_password']) ? 'checked' : '' ?>> Force password change on next login</label></div>
            </div>

            <h3 style="margin:1.5rem 0 1rem;">Access Rights</h3>
            <p class="text-muted">Access rights are controlled by the selected role. Change the role to update the modules this user can access.</p>

            <div class="form-row">
                <div class="form-group">
                    <label>Department (lecturers only)</label>
                    <input name="department" value="<?= e($staff['department'] ?? '') ?>">
                </div>
                <div class="form-group">
                    <label>Position (lecturers only)</label>
                    <input name="position" value="<?= e($staff['position'] ?? 'Lecturer') ?>">
                </div>
            </div>

            <h3 style="margin:1.5rem 0 1rem;">Module Access Overrides</h3>
            <p class="text-muted">By default, the selected role controls access. Use these overrides only when you need to grant or restrict specific modules for this user.</p>
            <div class="form-row" style="align-items:flex-start;">
                <div class="form-group" style="flex:1;">
                    <label>Per-module access</label>
                    <div class="card" style="padding:0.75rem 1rem;max-height:420px;overflow:auto;">
                        <?php foreach (MODULE_CATALOG as $moduleName):
                            $current = $permissionMap[$moduleName] ?? 'inherit';
                        ?>
                        <div style="display:flex;align-items:center;justify-content:space-between;gap:1rem;margin:.35rem 0;">
                            <div style="flex:1;">
                                <?= e(ucfirst(str_replace('_', ' ', $moduleName))) ?>
                            </div>
                            <div style="width:220px;">
                                <select name="module_access[<?= e($moduleName) ?>]" style="width:100%;">
                                    <option value="inherit" <?= $current === 'inherit' ? 'selected' : '' ?>>Inherit (role)</option>
                                    <option value="allow" <?= $current === 'allow' ? 'selected' : '' ?>>Allow</option>
                                    <option value="deny" <?= $current === 'deny' ? 'selected' : '' ?>>Deny</option>
                                </select>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>

            <button type="submit" class="btn btn-primary">Save Changes</button>
        </form>
    </div>
</div>

<script>
msshtSearchableSelect('userEditRoleSearch', 'userEditRoleSelect');
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
