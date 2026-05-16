<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();
requireModule('classes');

$userId = (int) $_SESSION['user_id'];
$deadlines = getStudentUpcomingDeadlines($userId, 30);

$pageTitle = 'Calendar & Deadlines';
$currentModule = 'classes';
$extraCss = ['classroom.css'];
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="index.php" class="btn btn-outline btn-sm">&larr; My Classes</a>
</div>

<div class="card">
    <div class="card-header"><h2>Upcoming deadlines (30 days)</h2></div>
    <div class="card-body">
        <?php if (empty($deadlines)): ?>
        <p class="empty-state">No upcoming deadlines.</p>
        <?php else: ?>
        <ul class="calendar-list">
            <?php foreach ($deadlines as $d): ?>
            <li class="calendar-item" style="border-left-color:<?= e($d['theme_color']) ?>">
                <div class="calendar-date"><?= formatDate($d['due_date'], 'd M Y H:i') ?></div>
                <div class="calendar-title"><a href="view.php?id=<?= (int)$d['class_id'] ?>&tab=classwork"><?= e($d['title']) ?></a></div>
                <div class="calendar-class text-muted"><?= e($d['class_name']) ?></div>
            </li>
            <?php endforeach; ?>
        </ul>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
