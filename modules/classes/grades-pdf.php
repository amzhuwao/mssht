<?php
require_once __DIR__ . '/../../includes/bootstrap.php';

$studentId = getCurrentStudentId();
$classId = (int) ($_GET['class_id'] ?? 0);
$guardianToken = $_GET['guardian_token'] ?? '';

if ($guardianToken) {
    $guardian = getGuardianByToken($guardianToken);
    if (!$guardian) {
        http_response_code(403);
        exit('Invalid guardian link.');
    }
    $studentId = (int) ($_GET['student_id'] ?? 0);
    $allowed = array_column(getGuardianStudents((int)$guardian['id']), 'id');
    if (!in_array($studentId, $allowed, true)) {
        http_response_code(403);
        exit('Access denied.');
    }
} else {
    requireLogin();
    if (!$studentId && canAccessModule('students')) {
        $studentId = (int) ($_GET['student_id'] ?? 0);
    }
    if (!$studentId) {
        flash('danger', 'Student record required.');
        redirect(moduleUrl('classes'));
    }
    if ($classId && !isClassMember($classId) && !canAccessModule('students')) {
        flash('danger', 'Access denied.');
        redirect(moduleUrl('classes'));
    }
}

$data = getStudentClassGradesForPdf($studentId, $classId ?: null);
if (empty($data['rows'])) {
    flash('warning', 'No grades to export.');
    redirect($classId ? moduleUrl('classes', 'view') . '?id=' . $classId . '&tab=grades' : moduleUrl('exams', 'my-results'));
}

$meta = [
    'Student' => $data['student']['name'] ?? $data['student']['student_number'],
    'ID'      => $data['student']['student_number'],
    'Program' => $data['student']['program'] ?? '',
];
$title = $classId ? 'Class Grade Report' : 'Complete Grade Report';
$html = buildGradesReportHtml($meta, $data['rows'], $title);
$filename = 'grades_' . $data['student']['student_number'] . ($classId ? '_class' . $classId : '') . '_' . date('Ymd');
outputPdf($html, $filename);
