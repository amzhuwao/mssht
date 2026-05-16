<?php
require_once __DIR__ . '/includes/bootstrap.php';
$studentPortal = logout();
redirect($studentPortal ? url('student-login.php') : url('login.php'));
