<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('users');

$pageTitle = 'User Management';
$currentModule = 'users';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $hash = password_hash($_POST['password'], PASSWORD_DEFAULT);
    $db->prepare('INSERT INTO users (email, password_hash, role, status) VALUES (?, ?, ?, ?)')
       ->execute([trim($_POST['email']), $hash, $_POST['role'], 'active']);
    $uid = (int)$db->lastInsertId();
    $db->prepare('INSERT INTO user_profiles (user_id, first_name, last_name, phone) VALUES (?, ?, ?, ?)')
       ->execute([$uid, trim($_POST['first_name']), trim($_POST['last_name']), trim($_POST['phone'] ?? '')]);
    if (in_array($_POST['role'], ['lecturer'], true)) {
        $db->prepare('INSERT INTO staff (user_id, staff_number, department, position, hire_date) VALUES (?, ?, ?, ?, CURDATE())')
           ->execute([$uid, generateRef('STF'), trim($_POST['department'] ?? ''), trim($_POST['position'] ?? 'Lecturer')]);
    }
    flash('success', 'User created.');
    redirect(moduleUrl('users'));
}

$users = $db->query(
    'SELECT u.*, p.first_name, p.last_name FROM users u
     JOIN user_profiles p ON p.user_id = u.id ORDER BY u.created_at DESC'
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Add User</h2></div>
    <div class="card-body">
        <form method="post">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-row">
                <div class="form-group"><label>First Name</label><input name="first_name" required></div>
                <div class="form-group"><label>Last Name</label><input name="last_name" required></div>
                <div class="form-group"><label>Email</label><input type="email" name="email" required></div>
                <div class="form-group"><label>Phone</label><input name="phone"></div>
                <div class="form-group">
                    <label>Role</label>
                    <select name="role" required>
                        <?php foreach (ROLES as $key => $label): ?>
                        <option value="<?= $key ?>"><?= e($label) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group"><label>Password</label><input type="password" name="password" required minlength="8"></div>
            </div>
            <button type="submit" class="btn btn-primary">Create User</button>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>All Users</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th>Last Login</th></tr></thead>
            <tbody>
            <?php foreach ($users as $u): ?>
            <tr>
                <td><?= e($u['first_name'] . ' ' . $u['last_name']) ?></td>
                <td><?= e($u['email']) ?></td>
                <td><?= e(ROLES[$u['role']] ?? $u['role']) ?></td>
                <td><?= statusBadge($u['status']) ?></td>
                <td><?= $u['last_login'] ? formatDate($u['last_login'], 'd M Y H:i') : 'Never' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
