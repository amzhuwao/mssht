<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();

$assignmentId = (int) ($_GET['assignment_id'] ?? 0);
$db = getDB();
$stmt = $db->prepare('SELECT ca.*, c.id AS class_id FROM class_assignments ca JOIN classes c ON c.id = ca.class_id WHERE ca.id = ?');
$stmt->execute([$assignmentId]);
$assignment = $stmt->fetch();
if (!$assignment || !isClassTeacher((int)$assignment['class_id'])) {
    flash('danger', 'Access denied.');
    redirect(moduleUrl('classes'));
}

$rubric = getAssignmentRubric($assignmentId);

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $criteria = [];
    $names = $_POST['criterion'] ?? [];
    $maxes = $_POST['max_points'] ?? [];
    foreach ($names as $i => $name) {
        $name = trim($name);
        if ($name === '') continue;
        $criteria[] = ['criterion' => $name, 'max_points' => (float) ($maxes[$i] ?? 0)];
    }
    if (empty($criteria)) {
        flash('danger', 'Add at least one criterion.');
    } else {
        saveAssignmentRubric($assignmentId, trim($_POST['rubric_title'] ?? 'Rubric'), $criteria);
        $total = rubricScoresToMax($criteria);
        if ($total > 0) {
            $db->prepare('UPDATE class_assignments SET max_score = ? WHERE id = ?')->execute([$total, $assignmentId]);
        }
        flash('success', 'Rubric saved.');
        redirect(moduleUrl('classes', 'grade') . '?assignment_id=' . $assignmentId);
    }
}

$pageTitle = 'Edit Rubric';
$currentModule = 'classes';
require_once __DIR__ . '/../../includes/header.php';
$criteria = $rubric['criteria'] ?? [['criterion' => '', 'max_points' => 10]];
?>

<div class="page-actions">
    <a href="grade.php?assignment_id=<?= $assignmentId ?>" class="btn btn-outline btn-sm">&larr; Grading</a>
</div>

<div class="card" style="max-width:720px;">
    <div class="card-header"><h2>Rubric: <?= e($assignment['title']) ?></h2></div>
    <div class="card-body">
        <form method="post" id="rubricForm">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <div class="form-group">
                <label>Rubric title</label>
                <input name="rubric_title" value="<?= e($rubric['title'] ?? 'Grading Rubric') ?>" required>
            </div>
            <table class="data-table" id="rubricTable">
                <thead><tr><th>Criterion</th><th>Max points</th><th></th></tr></thead>
                <tbody>
                <?php foreach ($criteria as $i => $c): ?>
                <tr>
                    <td><input type="text" name="criterion[]" value="<?= e($c['criterion'] ?? '') ?>" required style="width:100%;"></td>
                    <td><input type="number" step="0.01" name="max_points[]" value="<?= e($c['max_points'] ?? 0) ?>" min="0" style="width:90px;"></td>
                    <td><button type="button" class="btn btn-sm btn-outline remove-row">Remove</button></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <button type="button" class="btn btn-outline btn-sm" id="addCriterion" style="margin:1rem 0;">+ Add criterion</button>
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">Save rubric</button>
            </div>
        </form>
    </div>
</div>

<script>
var addCriterionButton = document.getElementById('addCriterion');
var rubricTableBody = document.querySelector('#rubricTable tbody');

if (addCriterionButton && rubricTableBody) {
    addCriterionButton.addEventListener('click', function () {
        rubricTableBody.insertAdjacentHTML(
            'beforeend',
            '<tr><td><input type="text" name="criterion[]" required style="width:100%;"></td>' +
            '<td><input type="number" step="0.01" name="max_points[]" value="10" min="0" style="width:90px;"></td>' +
            '<td><button type="button" class="btn btn-sm btn-outline remove-row">Remove</button></td></tr>'
        );
    });

    rubricTableBody.addEventListener('click', function (event) {
        var removeButton = event.target.closest('.remove-row');

        if (!removeButton) {
            return;
        }

        if (rubricTableBody.querySelectorAll('tr').length > 1) {
            removeButton.closest('tr').remove();
        }
    });
}
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
