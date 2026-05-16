<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('students');

$id = (int)($_GET['id'] ?? $_POST['id'] ?? 0);
if (!$id) {
    flash('danger', 'Invalid student.');
    redirect(moduleUrl('students'));
}

$reset = !empty($_GET['reset']) || !empty($_POST['reset']);
$portal = createStudentPortalAccount($id, $reset);

if (!$portal) {
    flash('danger', 'Could not create portal account. Ensure the student has an email on file.');
    redirect(moduleUrl('students', 'view') . '?id=' . $id);
}

$action = $reset ? 'reset' : 'created';
flash(
    'success',
    "Portal account $action. Student ID: {$portal['student_number']} | Email: {$portal['email']} | Temp password: {$portal['temp_password']}"
);
redirect(moduleUrl('students', 'view') . '?id=' . $id);
