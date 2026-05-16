<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('timetable');

$pageTitle = 'Timetabling';
$currentModule = 'timetable';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare(
        'INSERT INTO timetable_slots (module_id, lecturer_id, room_id, day_of_week, start_time, end_time, delivery_mode, academic_year)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
    )->execute([
        (int)$_POST['module_id'], (int)$_POST['lecturer_id'], $_POST['room_id'] ?: null,
        (int)$_POST['day_of_week'], $_POST['start_time'], $_POST['end_time'],
        $_POST['delivery_mode'], $_POST['academic_year'],
    ]);
    flash('success', 'Timetable slot added.');
    redirect(moduleUrl('timetable'));
}

$slots = $db->query(
    'SELECT t.*, m.code, m.name AS module_name, r.name AS room_name,
            CONCAT(p.first_name, " ", p.last_name) AS lecturer_name
     FROM timetable_slots t
     JOIN modules m ON m.id = t.module_id
     JOIN users u ON u.id = t.lecturer_id
     JOIN user_profiles p ON p.user_id = u.id
     LEFT JOIN rooms r ON r.id = t.room_id
     ORDER BY t.day_of_week, t.start_time'
)->fetchAll();

$modules = $db->query('SELECT id, code, name FROM modules')->fetchAll();
$lecturers = $db->query("SELECT u.id, p.first_name, p.last_name FROM users u JOIN user_profiles p ON p.user_id = u.id WHERE u.role = 'lecturer'")->fetchAll();
$rooms = $db->query('SELECT id, name FROM rooms')->fetchAll();
$days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Add Timetable Slot</h2></div>
    <div class="card-body">
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Module</label><select name="module_id" required><?php foreach ($modules as $m): ?><option value="<?= $m['id'] ?>"><?= e($m['code']) ?></option><?php endforeach; ?></select></div>
            <div class="form-group"><label>Lecturer</label><select name="lecturer_id" required><?php foreach ($lecturers as $l): ?><option value="<?= $l['id'] ?>"><?= e($l['first_name'] . ' ' . $l['last_name']) ?></option><?php endforeach; ?></select></div>
            <div class="form-group"><label>Room</label><select name="room_id"><option value="">—</option><?php foreach ($rooms as $r): ?><option value="<?= $r['id'] ?>"><?= e($r['name']) ?></option><?php endforeach; ?></select></div>
            <div class="form-group"><label>Day</label><select name="day_of_week"><?php for ($d=1;$d<=5;$d++): ?><option value="<?= $d ?>"><?= $days[$d] ?></option><?php endfor; ?></select></div>
            <div class="form-group"><label>Start</label><input type="time" name="start_time" required></div>
            <div class="form-group"><label>End</label><input type="time" name="end_time" required></div>
            <div class="form-group"><label>Mode</label><select name="delivery_mode"><option value="face_to_face">Face to Face</option><option value="online">Online</option><option value="hybrid">Hybrid</option></select></div>
            <div class="form-group"><label>Academic Year</label><input name="academic_year" value="2026" required></div>
            <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Add</button></div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Weekly Timetable</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Day</th><th>Time</th><th>Module</th><th>Lecturer</th><th>Room</th><th>Mode</th></tr></thead>
            <tbody>
            <?php foreach ($slots as $s): ?>
            <tr>
                <td><?= $days[$s['day_of_week']] ?? '' ?></td>
                <td><?= e(substr($s['start_time'],0,5)) ?> - <?= e(substr($s['end_time'],0,5)) ?></td>
                <td><?= e($s['code']) ?></td>
                <td><?= e($s['lecturer_name']) ?></td>
                <td><?= e($s['room_name'] ?? 'Online') ?></td>
                <td><?= e(ucfirst(str_replace('_',' ',$s['delivery_mode']))) ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
