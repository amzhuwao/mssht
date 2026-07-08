<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('reports');

$reportType = $_GET['report_type'] ?? 'enrollment';
$format = $_GET['format'] ?? 'csv';
$filters = [
    'action' => trim($_GET['action_filter'] ?? $_GET['action'] ?? ''),
    'entity_type' => trim($_GET['entity_type'] ?? ''),
    'user_id' => trim($_GET['user_id'] ?? ''),
    'date_from' => trim($_GET['date_from'] ?? ''),
    'date_to' => trim($_GET['date_to'] ?? ''),
    'academic_year' => trim($_GET['academic_year'] ?? ''),
    'term' => trim($_GET['term'] ?? ''),
    'department' => trim($_GET['department'] ?? ''),
    'grade_form' => trim($_GET['grade_form'] ?? ''),
    'teacher' => trim($_GET['teacher'] ?? ''),
    'student_id' => trim($_GET['student_id'] ?? ''),
    'gender' => trim($_GET['gender'] ?? ''),
    'boarding_day' => trim($_GET['boarding_day'] ?? ''),
    'admission_status' => trim($_GET['admission_status'] ?? ''),
    'attendance_percentage' => trim($_GET['attendance_percentage'] ?? ''),
    'fee_status' => trim($_GET['fee_status'] ?? ''),
    'comparison' => trim($_GET['comparison'] ?? ''),
    'percentage' => trim($_GET['percentage'] ?? ''),
    'program_id' => trim($_GET['program_id'] ?? ''),
    'intake_id' => trim($_GET['intake_id'] ?? ''),
    'class_id' => trim($_GET['class_id'] ?? ''),
    'module_id' => trim($_GET['module_id'] ?? ''),
];

if ($format === 'pdf' || $format === 'csv' || $format === 'excel') {
    outputReportFile($reportType, $format, $filters);
}

flash('danger', 'Unsupported export format.');
redirect(moduleUrl('reports'));