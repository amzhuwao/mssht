<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();
requireModule('classes');

$pageTitle = isStudentPortal() ? 'My Classes' : 'Class Management';
$currentModule = 'classes';
$extraCss = ['classroom.css'];
$userId = (int) $_SESSION['user_id'];
$classes = getUserClasses($userId);
$classStats = isStudentPortal() ? getStudentClassStats($userId) : [];

require_once __DIR__ . '/../../includes/header.php';
?>

<?php if (isStudentPortal()): ?>
<div class="stats-grid">
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= (int)$classStats['classes'] ?></span><span class="stat-label">My Classes</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= (int)$classStats['due_soon'] ?></span><span class="stat-label">Due This Week</span></div></div>
    <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= (int)$classStats['missing'] ?></span><span class="stat-label">Missing Work</span></div></div>
</div>
<?php endif; ?>

<div class="page-actions">
    <h2 style="margin:0;"><?= isStudentPortal() ? 'My Classes' : 'Classes' ?></h2>
    <div style="display:flex;gap:.5rem;flex-wrap:wrap;">
        <?php if (!isStudentPortal()): ?>
        <a href="create.php" class="btn btn-primary btn-sm">+ Create Class</a>
        <?php endif; ?>
        <a href="calendar.php" class="btn btn-outline btn-sm">Calendar</a>
    </div>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2><?= isStudentPortal() ? 'Join a Class' : 'Join with Code' ?></h2></div>
        <div class="card-body">
            <form method="post" action="join.php" class="join-class-form">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <div class="form-group">
                    <label>Class code</label>
                    <input type="text" name="join_code" required placeholder="e.g. ABC123" maxlength="12" style="text-transform:uppercase;">
                </div>
                <button type="submit" class="btn btn-primary">Join</button>
            </form>
        </div>
    </div>
    <?php if (!isStudentPortal()): ?>
    <div class="card">
        <div class="card-header"><h2>Quick links</h2></div>
        <div class="card-body quick-links">
            <a href="create.php" class="quick-link">Create new class</a>
        </div>
    </div>
    <?php endif; ?>
</div>

<div class="class-grid">
    <?php if (empty($classes)): ?>
    <p class="empty-state card" style="padding:2rem;grid-column:1/-1;">
        <?= isStudentPortal() ? 'You are not enrolled in any classes yet. Enter a join code from your lecturer.' : 'No classes yet. Create your first class.' ?>
    </p>
    <?php else: ?>
    <?php foreach ($classes as $c): ?>
    <a href="view.php?id=<?= (int)$c['id'] ?>" class="class-card" style="--class-color:<?= e($c['theme_color']) ?>">
        <div class="class-card-banner"></div>
        <div class="class-card-body">
            <h3><?= e($c['name']) ?></h3>
            <?php if ($c['section']): ?><p class="class-meta"><?= e($c['section']) ?></p><?php endif; ?>
            <?php if ($c['module_code']): ?><p class="class-meta"><?= e($c['module_code']) ?></p><?php endif; ?>
            <p class="class-code">Code: <strong><?= e($c['join_code']) ?></strong></p>
            <?php if (!isStudentPortal()): ?>
            <p class="class-meta"><?= (int)$c['student_count'] ?> students</p>
            <?php endif; ?>
        </div>
    </a>
    <?php endforeach; ?>
    <?php endif; ?>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
