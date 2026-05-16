<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();

$assignmentId = (int) ($_GET['assignment_id'] ?? 0);
$db = getDB();
$stmt = $db->prepare('SELECT ca.*, c.id AS class_id, c.name AS class_name FROM class_assignments ca JOIN classes c ON c.id = ca.class_id WHERE ca.id = ?');
$stmt->execute([$assignmentId]);
$assignment = $stmt->fetch();
if (!$assignment || !isClassTeacher((int)$assignment['class_id'])) {
    flash('danger', 'Access denied.');
    redirect(moduleUrl('classes'));
}

$rubric = getAssignmentRubric($assignmentId);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    foreach ($_POST['grades'] ?? [] as $studentId => $data) {
        $studentId = (int) $studentId;
        $feedback = trim($data['feedback'] ?? '');
        $rubricScores = [];
        if ($rubric && !empty($data['rubric'])) {
            foreach ($data['rubric'] as $idx => $pts) {
                $rubricScores[$idx] = $pts !== '' ? (float) $pts : 0;
            }
            $score = calculateRubricScore($rubric['criteria'], $rubricScores);
        } else {
            $score = $data['score'] !== '' ? (float) $data['score'] : null;
        }
        if ($score === null && $feedback === '' && empty($rubricScores)) continue;

        $rubricJson = !empty($rubricScores) ? json_encode($rubricScores) : null;
        $exists = $db->prepare('SELECT id FROM class_submissions WHERE class_assignment_id = ? AND student_id = ?');
        $exists->execute([$assignmentId, $studentId]);
        if ($exists->fetch()) {
            $db->prepare(
                'UPDATE class_submissions SET score = ?, feedback = ?, rubric_scores_json = ?, status = ?, graded_by = ?, graded_at = NOW()
                 WHERE class_assignment_id = ? AND student_id = ?'
            )->execute([$score, $feedback, $rubricJson, 'graded', $_SESSION['user_id'], $assignmentId, $studentId]);
        } else {
            $db->prepare(
                'INSERT INTO class_submissions (class_assignment_id, student_id, score, feedback, rubric_scores_json, status, graded_by, graded_at, submitted_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())'
            )->execute([$assignmentId, $studentId, $score, $feedback, $rubricJson, 'graded', $_SESSION['user_id']]);
        }
    }
    flash('success', 'Grades saved.');
    redirect(moduleUrl('classes', 'grade') . '?assignment_id=' . $assignmentId);
}

$subs = $db->prepare(
    'SELECT s.id AS student_id, s.student_number, CONCAT(p.first_name," ",p.last_name) AS name,
            cs.score, cs.feedback, cs.rubric_scores_json, cs.status, cs.submitted_at
     FROM class_members cm
     JOIN students s ON s.user_id = cm.user_id
     JOIN user_profiles p ON p.user_id = s.user_id
     LEFT JOIN class_submissions cs ON cs.student_id = s.id AND cs.class_assignment_id = ?
     WHERE cm.class_id = ? AND cm.member_role = ?
     ORDER BY s.student_number'
);
$subs->execute([$assignmentId, $assignment['class_id'], 'student']);
$submissions = $subs->fetchAll();

$pageTitle = 'Grade: ' . $assignment['title'];
$currentModule = 'classes';
require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="view.php?id=<?= (int)$assignment['class_id'] ?>&tab=classwork" class="btn btn-outline btn-sm">&larr; Classwork</a>
    <a href="rubric.php?assignment_id=<?= $assignmentId ?>" class="btn btn-outline btn-sm"><?= $rubric ? 'Edit rubric' : 'Create rubric' ?></a>
</div>

<form method="post">
    <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
    <?php foreach ($submissions as $s):
        $rubricScores = parseRubricScores($s['rubric_scores_json'] ?? null);
    ?>
    <div class="card" style="margin-bottom:1rem;">
        <div class="card-header">
            <h2 style="font-size:1rem;"><?= e($s['student_number']) ?> — <?= e($s['name']) ?></h2>
            <?= statusBadge($s['status'] ?? 'missing') ?>
        </div>
        <div class="card-body">
            <?php if ($rubric && !empty($rubric['criteria'])): ?>
            <table class="data-table rubric-grade-table">
                <thead><tr><th>Criterion</th><th>Max</th><th>Points</th></tr></thead>
                <tbody>
                <?php foreach ($rubric['criteria'] as $i => $c): ?>
                <tr>
                    <td><?= e($c['criterion']) ?></td>
                    <td><?= e($c['max_points']) ?></td>
                    <td><input type="number" step="0.01" name="grades[<?= $s['student_id'] ?>][rubric][<?= $i ?>]"
                               value="<?= e($rubricScores[$i] ?? '') ?>" min="0" max="<?= e($c['max_points']) ?>" style="width:80px;"></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <?php else: ?>
            <div class="form-group">
                <label>Score / <?= e($assignment['max_score']) ?></label>
                <input type="number" step="0.01" name="grades[<?= $s['student_id'] ?>][score]" value="<?= e($s['score'] ?? '') ?>" style="width:100px;">
            </div>
            <?php endif; ?>
            <div class="form-group">
                <label>Feedback</label>
                <textarea name="grades[<?= $s['student_id'] ?>][feedback]" rows="2" style="width:100%;"><?= e($s['feedback'] ?? '') ?></textarea>
            </div>
        </div>
    </div>
    <?php endforeach; ?>
    <button type="submit" class="btn btn-primary">Save all grades</button>
</form>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
