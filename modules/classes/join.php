<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireLogin();

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !verifyCsrf($_POST['csrf'] ?? '')) {
    flash('danger', 'Invalid request.');
    redirect(moduleUrl('classes'));
}

$result = joinClassByCode((int) $_SESSION['user_id'], $_POST['join_code'] ?? '');
flash($result['ok'] ? 'success' : 'danger', $result['message']);
redirect($result['class_id'] ?? null ? moduleUrl('classes', 'view') . '?id=' . $result['class_id'] : moduleUrl('classes'));
