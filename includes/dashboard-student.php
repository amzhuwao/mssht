<?php
/** Student portal dashboard partial */
$student = getCurrentStudent();
$stats = getStudentDashboardData();
$user = currentUser();
$w = 'div';
?>

<div class="student-welcome-banner">
    <div>
        <p class="hero-eyebrow" style="margin:0;">Student Portal</p>
        <h2 style="margin:.25rem 0 .5rem;">Welcome, <?= e($user['first_name'] ?? 'Student') ?></h2>
        <p class="text-muted" style="margin:0;">
            <strong><?= e($student['student_number'] ?? '') ?></strong>
            &mdash; <?= e($student['program_name'] ?? '') ?>
            (<?= e($student['intake_name'] ?? '') ?>)
        </p>
    </div>
    <?= statusBadge($student['enrollment_status'] ?? 'active') ?>
</div>

<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-body">
            <span class="stat-value"><?= (int) $stats['modules_count'] ?></span>
            <span class="stat-label">Registered Modules</span>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-body">
            <span class="stat-value"><?= (int) $stats['invoices_due'] ?></span>
            <span class="stat-label">Outstanding Invoices</span>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-body">
            <span class="stat-value"><?= formatMoney((float) $stats['balance']) ?></span>
            <span class="stat-label">Fees Balance</span>
        </div>
    </div>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Quick Access</h2></div>
        <div class="card-body">
            <div class="quick-links">
                <a href="<?= moduleUrl('lms') ?>" class="quick-link">My Courses &amp; Materials</a>
                <a href="<?= moduleUrl('finance') ?>" class="quick-link">My Fees &amp; Invoices</a>
                <a href="<?= moduleUrl('exams', 'my-results') ?>" class="quick-link">My Results</a>
                <a href="<?= moduleUrl('attendance') ?>" class="quick-link">My Attendance</a>
                <a href="<?= moduleUrl('library') ?>" class="quick-link">Library</a>
                <a href="<?= moduleUrl('placements') ?>" class="quick-link">Industrial Attachment</a>
                <a href="<?= moduleUrl('messages') ?>" class="quick-link">Messages</a>
                <a href="<?= url('profile.php') ?>" class="quick-link">My Profile</a>
            </div>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>My Enrollment</h2></div>
        <div class="card-body">
            <p><strong>Program:</strong> <?= e($student['program_name'] ?? '') ?></p>
            <p><strong>Type:</strong> <?= programTypeLabel($student['program_type'] ?? '') ?></p>
            <p><strong>Intake:</strong> <?= e($student['intake_name'] ?? '') ?></p>
            <p><strong>Enrolled:</strong> <?= formatDate($student['enrollment_date'] ?? null) ?></p>
            <p><strong>Portal email:</strong> <?= e($student['portal_email'] ?? currentUser()['email'] ?? '') ?></p>
        </div>
    </div>
</div>
