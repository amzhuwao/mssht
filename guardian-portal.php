<?php
require_once __DIR__ . '/includes/bootstrap.php';

$token = $_GET['token'] ?? '';
$guardian = $token ? getGuardianByToken($token) : null;
if (!$guardian) {
    http_response_code(403);
    echo '<h1>Invalid or expired link</h1><p>Please request a new summary email from the school.</p>';
    exit;
}

$students = getGuardianStudents((int)$guardian['id']);
$selectedId = (int)($_GET['student_id'] ?? ($students[0]['id'] ?? 0));
$summary = $selectedId ? buildStudentSummary($selectedId) : null;
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guardian Portal | <?= e(APP_NAME) ?></title>
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <link rel="stylesheet" href="<?= asset('css/auth.css') ?>">
    <style>
        body{background:#f4f6f9;padding:1.5rem;}
        .portal-wrap{max-width:800px;margin:0 auto;}
        .portal-header{background:linear-gradient(135deg,#1a3a5c,#0d4f4c);color:#fff;padding:1.5rem;border-radius:10px;margin-bottom:1.5rem;}
        .student-tabs{display:flex;gap:.5rem;flex-wrap:wrap;margin-bottom:1rem;}
        .student-tabs a{padding:.5rem 1rem;background:#fff;border-radius:8px;text-decoration:none;color:#333;}
        .student-tabs a.active{background:#0d4f4c;color:#fff;}
        .summary-card{background:#fff;border-radius:10px;padding:1.5rem;box-shadow:0 2px 8px rgba(0,0,0,.08);}
        .summary-card h3{margin-top:1.25rem;color:#0d4f4c;}
        .summary-card ul{margin:.5rem 0;padding-left:1.25rem;}
    </style>
</head>
<body>
<div class="portal-wrap">
    <div class="portal-header">
        <h1>Guardian Portal</h1>
        <p>Hello <?= e($guardian['first_name'] . ' ' . $guardian['last_name']) ?></p>
        <p style="opacity:.85;font-size:.9rem;"><?= e(APP_FULL_NAME) ?></p>
    </div>

    <?php if (count($students) > 1): ?>
    <div class="student-tabs">
        <?php foreach ($students as $st): ?>
        <a href="?token=<?= e($token) ?>&student_id=<?= (int)$st['id'] ?>" class="<?= $selectedId === (int)$st['id'] ? 'active' : '' ?>">
            <?= e($st['name'] ?: $st['student_number']) ?>
        </a>
        <?php endforeach; ?>
    </div>
    <?php endif; ?>

    <?php if ($summary): ?>
    <div class="summary-card">
        <?= renderGuardianSummaryHtml($summary) ?>
        <p style="margin-top:1.5rem;">
            <a href="<?= moduleUrl('classes', 'grades-pdf') ?>?student_id=<?= $selectedId ?>&guardian_token=<?= e($token) ?>"
               class="btn btn-primary btn-sm">Download grades PDF</a>
        </p>
    </div>
    <?php else: ?>
    <p>No student data linked to your account.</p>
    <?php endif; ?>
</div>
</body>
</html>
