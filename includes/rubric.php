<?php
/**
 * Rubric helpers
 */

function getAssignmentRubric(int $assignmentId): ?array
{
    $db = getDB();
    $stmt = $db->prepare('SELECT * FROM class_rubrics WHERE class_assignment_id = ?');
    $stmt->execute([$assignmentId]);
    $row = $stmt->fetch();
    if (!$row) {
        return null;
    }
    $row['criteria'] = json_decode($row['criteria_json'], true) ?: [];
    return $row;
}

function saveAssignmentRubric(int $assignmentId, string $title, array $criteria): void
{
    $db = getDB();
    $json = json_encode(array_values($criteria), JSON_UNESCAPED_UNICODE);
    $exists = $db->prepare('SELECT id FROM class_rubrics WHERE class_assignment_id = ?');
    $exists->execute([$assignmentId]);
    if ($exists->fetch()) {
        $db->prepare('UPDATE class_rubrics SET title = ?, criteria_json = ? WHERE class_assignment_id = ?')
           ->execute([$title, $json, $assignmentId]);
    } else {
        $db->prepare('INSERT INTO class_rubrics (class_assignment_id, title, criteria_json) VALUES (?, ?, ?)')
           ->execute([$assignmentId, $title, $json]);
    }
}

function calculateRubricScore(array $criteria, array $scores): float
{
    $total = 0.0;
    foreach ($criteria as $i => $c) {
        $max = (float) ($c['max_points'] ?? 0);
        $earned = isset($scores[$i]) ? (float) $scores[$i] : 0;
        $total += min(max($earned, 0), $max);
    }
    return round($total, 2);
}

function parseRubricScores(?string $json): array
{
    if (!$json) return [];
    $data = json_decode($json, true);
    return is_array($data) ? $data : [];
}

function rubricScoresToMax(array $criteria): float
{
    $max = 0;
    foreach ($criteria as $c) {
        $max += (float) ($c['max_points'] ?? 0);
    }
    return $max;
}
