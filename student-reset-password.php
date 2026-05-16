<?php
$token = $_GET['token'] ?? '';
require_once __DIR__ . '/includes/bootstrap.php';
redirect(url('reset-password.php') . ($token ? '?token=' . urlencode($token) : ''));
