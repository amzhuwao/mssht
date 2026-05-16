<?php
session_start();
require_once dirname(__DIR__) . '/config/app.php';
require_once dirname(__DIR__) . '/config/database.php';
require_once dirname(__DIR__) . '/includes/helpers.php';
require_once dirname(__DIR__) . '/includes/student-auth.php';

$ok = studentPortalLogin('MSSHT2691699', 'Mssht1699');
echo $ok ? "LOGIN OK\n" : "LOGIN FAILED: " . (studentPortalLoginFailure() ?? 'unknown') . "\n";
