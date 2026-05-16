<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();

$classId = (int) ($_GET['id'] ?? 0);
requireClassAccess($classId);
$class = getClassById($classId);
if (!$class) {
    flash('danger', 'Class not found.');
    redirect(moduleUrl('classes'));
}

$tab = $_GET['tab'] ?? 'stream';
$studentId = getCurrentStudentId();
$isTeacher = isClassTeacher($classId);
$userId = (int) $_SESSION['user_id'];
$db = getDB();

// Post comment
if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'comment' && !empty($_POST['post_id'])) {
        if ($class['comments_enabled'] || $isTeacher) {
            $db->prepare('INSERT INTO stream_comments (post_id, user_id, body) VALUES (?, ?, ?)')
               ->execute([(int)$_POST['post_id'], $userId, trim($_POST['comment_body'])]);
            flash('success', 'Comment posted.');
        }
    }
    redirect(moduleUrl('classes', 'view') . '?id=' . $classId . '&tab=' . urlencode($tab));
}

$stream = getClassStream($classId);
$assignments = getClassAssignments($classId, $studentId);
$grades = $studentId ? getStudentClassGrades($classId, $studentId) : [];
$members = $db->prepare(
    'SELECT cm.member_role, CONCAT(p.first_name," ",p.last_name) AS name, u.email
     FROM class_members cm JOIN users u ON u.id = cm.user_id
     JOIN user_profiles p ON p.user_id = u.id WHERE cm.class_id = ? ORDER BY cm.member_role, name'
);
$members->execute([$classId]);
$members = $members->fetchAll();

$pageTitle = $class['name'];
$currentModule = 'classes';
$extraCss = ['classroom.css'];
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="class-header" style="--class-color:<?= e($class['theme_color']) ?>">
    <div class="class-header-inner">
        <div>
            <h1><?= e($class['name']) ?></h1>
            <p><?= e($class['section'] ?? '') ?> <?= $class['module_code'] ? ' &middot; ' . e($class['module_code']) : '' ?></p>
            <?php if ($isTeacher): ?>
            <p class="class-code-display">Join code: <strong><?= e($class['join_code']) ?></strong></p>
            <?php endif; ?>
        </div>
        <?php if ($isTeacher): ?>
        <div class="class-header-actions">
            <a href="post.php?id=<?= $classId ?>" class="btn btn-outline btn-sm" style="color:#fff;border-color:#fff;">Post announcement</a>
            <a href="assignment-create.php?id=<?= $classId ?>" class="btn btn-primary btn-sm">Create assignment</a>
        </div>
        <?php endif; ?>
    </div>
</div>

<nav class="class-tabs">
    <a href="?id=<?= $classId ?>&tab=stream" class="<?= $tab === 'stream' ? 'active' : '' ?>">Stream</a>
    <a href="?id=<?= $classId ?>&tab=classwork" class="<?= $tab === 'classwork' ? 'active' : '' ?>">Classwork</a>
    <?php if ($studentId): ?>
    <a href="?id=<?= $classId ?>&tab=grades" class="<?= $tab === 'grades' ? 'active' : '' ?>">Grades</a>
    <?php endif; ?>
    <a href="?id=<?= $classId ?>&tab=people" class="<?= $tab === 'people' ? 'active' : '' ?>">People</a>
</nav>

<?php if ($tab === 'stream'): ?>
<div class="stream-list">
    <?php foreach ($stream as $post):
        $comments = getStreamComments((int)$post['id']);
    ?>
    <article class="stream-post card">
        <div class="stream-post-header">
            <strong><?= e($post['author_name']) ?></strong>
            <span class="text-muted"><?= formatDate($post['published_at'] ?? $post['created_at'], 'd M Y H:i') ?></span>
            <span class="badge badge-secondary"><?= e(ucfirst($post['post_type'])) ?></span>
        </div>
        <div class="stream-post-body">
            <?php if ($post['title']): ?><h3><?= e($post['title']) ?></h3><?php endif; ?>
            <p><?= nl2br(e($post['body'])) ?></p>
            <?php if ($post['attachment_path']): ?>
            <p><a href="<?= UPLOAD_URL . '/' . e($post['attachment_path']) ?>" target="_blank">Download attachment</a></p>
            <?php endif; ?>
            <?php if ($post['external_url']): ?>
            <p><a href="<?= e($post['external_url']) ?>" target="_blank">Open link</a></p>
            <?php endif; ?>
            <?php if ($post['class_assignment_id']): ?>
            <p><a href="submit.php?assignment_id=<?= (int)$post['class_assignment_id'] ?>" class="btn btn-sm btn-primary">View assignment</a></p>
            <?php endif; ?>
        </div>
        <?php if ($post['comments_enabled'] || $isTeacher): ?>
        <div class="stream-comments">
            <?php foreach ($comments as $cm): ?>
            <div class="stream-comment"><strong><?= e($cm['author_name']) ?>:</strong> <?= e($cm['body']) ?></div>
            <?php endforeach; ?>
            <form method="post" class="stream-comment-form">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <input type="hidden" name="action" value="comment">
                <input type="hidden" name="post_id" value="<?= (int)$post['id'] ?>">
                <input type="text" name="comment_body" placeholder="Add class comment..." required>
                <button type="submit" class="btn btn-sm btn-outline">Reply</button>
            </form>
        </div>
        <?php endif; ?>
    </article>
    <?php endforeach; ?>
    <?php if (empty($stream)): ?>
    <p class="empty-state">No posts yet.</p>
    <?php endif; ?>
</div>

<?php elseif ($tab === 'classwork'): ?>
<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Assignment</th><th>Due</th><th>Status</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($assignments as $a):
                $ws = $a['work_status'] ?? 'assigned';
                $badge = match($ws) {
                    'submitted' => 'badge-success',
                    'late' => 'badge-warning',
                    'graded' => 'badge-info',
                    'missing' => 'badge-danger',
                    default => 'badge-secondary',
                };
            ?>
            <tr>
                <td><strong><?= e($a['title']) ?></strong><?php if ($a['topic_title']): ?><br><small class="text-muted"><?= e($a['topic_title']) ?></small><?php endif; ?></td>
                <td><?= formatDate($a['due_date'], 'd M Y H:i') ?></td>
                <td><span class="badge <?= $badge ?>"><?= e(ucfirst($ws)) ?></span></td>
                <td>
                    <?php if ($studentId): ?>
                    <a href="submit.php?assignment_id=<?= (int)$a['id'] ?>" class="btn btn-sm btn-outline">
                        <?= in_array($ws, ['submitted','late','graded']) ? 'View' : 'Submit' ?>
                    </a>
                    <?php elseif ($isTeacher): ?>
                    <a href="grade.php?assignment_id=<?= (int)$a['id'] ?>" class="btn btn-sm btn-outline">Grade</a>
                    <?php endif; ?>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <?php if (empty($assignments)): ?><p class="empty-state">No assignments yet.</p><?php endif; ?>
    </div>
</div>

<?php elseif ($tab === 'grades' && $studentId): ?>
<div class="page-actions" style="margin-bottom:1rem;">
    <a href="grades-pdf.php?class_id=<?= $classId ?>" class="btn btn-outline btn-sm">Download class PDF</a>
    <a href="grades-pdf.php" class="btn btn-outline btn-sm">All classes PDF</a>
</div>
<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Assignment</th><th>Due</th><th>Score</th><th>Feedback</th></tr></thead>
            <tbody>
            <?php
            $totalEarned = 0; $totalMax = 0;
            foreach ($grades as $g):
                if ($g['score'] !== null) $totalEarned += (float)$g['score'];
                $totalMax += (float)$g['max_score'];
            ?>
            <tr>
                <td><?= e($g['title']) ?></td>
                <td><?= formatDate($g['due_date'], 'd M Y') ?></td>
                <td><?= $g['score'] !== null ? e($g['score']) . ' / ' . e($g['max_score']) : '—' ?></td>
                <td><?= e($g['feedback'] ?? '—') ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
            <?php if ($totalMax > 0): ?>
            <tfoot><tr><td colspan="2"><strong>Overall</strong></td><td colspan="2"><strong><?= round($totalEarned / $totalMax * 100, 1) ?>%</strong> (<?= $totalEarned ?>/<?= $totalMax ?>)</td></tr></tfoot>
            <?php endif; ?>
        </table>
    </div>
</div>

<?php elseif ($tab === 'people'): ?>
<div class="card">
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Name</th><th>Email</th><th>Role</th></tr></thead>
            <tbody>
            <?php foreach ($members as $m): ?>
            <tr>
                <td><?= e($m['name']) ?></td>
                <td><?= e($m['email']) ?></td>
                <td><?= e(ucfirst(str_replace('_', ' ', $m['member_role']))) ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>

<p style="margin-top:1rem;"><a href="index.php">&larr; All classes</a></p>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
