<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('library');

$pageTitle = 'Library Management';
$currentModule = 'library';
$db = getDB();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $db->prepare(
        'INSERT INTO library_books (isbn, title, author, category, copies_total, copies_available, is_digital, digital_url) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
    )->execute([
        trim($_POST['isbn'] ?? ''), trim($_POST['title']), trim($_POST['author'] ?? ''),
        trim($_POST['category'] ?? ''), (int)$_POST['copies'], (int)$_POST['copies'],
        isset($_POST['is_digital']) ? 1 : 0, trim($_POST['digital_url'] ?? '') ?: null,
    ]);
    flash('success', 'Book added to catalog.');
    redirect(moduleUrl('library'));
}

$books = $db->query('SELECT * FROM library_books ORDER BY title')->fetchAll();
$borrowings = $db->query(
    'SELECT b.title, s.student_number, lb.borrowed_at, lb.due_date, lb.status
     FROM library_borrowings lb
     JOIN library_books b ON b.id = lb.book_id
     JOIN students s ON s.id = lb.student_id
     WHERE lb.status != "returned" ORDER BY lb.due_date'
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card">
    <div class="card-header"><h2>Add Book</h2></div>
    <div class="card-body">
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group"><label>Title *</label><input name="title" required></div>
            <div class="form-group"><label>Author</label><input name="author"></div>
            <div class="form-group"><label>ISBN</label><input name="isbn"></div>
            <div class="form-group"><label>Category</label><input name="category"></div>
            <div class="form-group"><label>Copies</label><input type="number" name="copies" value="1" min="1"></div>
            <div class="form-group"><label><input type="checkbox" name="is_digital"> Digital</label></div>
            <div class="form-group"><label>Digital URL</label><input name="digital_url"></div>
            <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Add</button></div>
        </form>
    </div>
</div>

<div class="card">
    <div class="card-header"><h2>Catalog (<?= count($books) ?> books)</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Title</th><th>Author</th><th>Available</th><th>Type</th></tr></thead>
            <tbody>
            <?php foreach ($books as $b): ?>
            <tr>
                <td><?= e($b['title']) ?></td>
                <td><?= e($b['author'] ?? '—') ?></td>
                <td><?= (int)$b['copies_available'] ?> / <?= (int)$b['copies_total'] ?></td>
                <td><?= $b['is_digital'] ? 'Digital' : 'Physical' ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
