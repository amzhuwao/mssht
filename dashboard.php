<?php
require_once __DIR__ . '/includes/bootstrap.php';
requireLogin();

$pageTitle = 'Dashboard';
$currentModule = 'dashboard';
$stats = getDashboardStats();
$user = currentUser();
$role = currentRole();

require_once __DIR__ . '/includes/header.php';

if (isStudentPortal()) {
    require __DIR__ . '/includes/dashboard-student.php';
    require_once __DIR__ . '/includes/footer.php';
    return;
}
?>

<div class="stats-grid">
    <?php if (canAccessModule('students')): ?>
    <div class="stat-card">
        <div class="stat-icon students"></div>
        <div class="stat-body">
            <span class="stat-value"><?= number_format($stats['students']) ?></span>
            <span class="stat-label">Active Students</span>
        </div>
    </div>
    <?php endif; ?>
    <?php if (canAccessModule('admissions')): ?>
    <div class="stat-card">
        <div class="stat-icon applications"></div>
        <div class="stat-body">
            <span class="stat-value"><?= number_format($stats['pending_apps']) ?></span>
            <span class="stat-label">Pending Applications</span>
        </div>
    </div>
    <?php endif; ?>
    <?php if (canAccessModule('programs')): ?>
    <div class="stat-card">
        <div class="stat-icon programs"></div>
        <div class="stat-body">
            <span class="stat-value"><?= number_format($stats['programs']) ?></span>
            <span class="stat-label">Active Programs</span>
        </div>
    </div>
    <?php endif; ?>
    <?php if (canAccessModule('finance')): ?>
    <div class="stat-card">
        <div class="stat-icon finance"></div>
        <div class="stat-body">
            <span class="stat-value"><?= formatMoney($stats['revenue']) ?></span>
            <span class="stat-label">Total Revenue</span>
        </div>
    </div>
    <?php endif; ?>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header">
            <h2>Welcome, <?= e($user['first_name'] ?? 'User') ?></h2>
        </div>
        <div class="card-body">
            <p>You are logged in as <strong><?= e(ROLES[$role] ?? $role) ?></strong>.</p>
            <p class="text-muted">Use the sidebar to access modules available for your role.</p>
            <div class="quick-links">
                <?php if (canAccessModule('admissions')): ?>
                <a href="<?= moduleUrl('admissions') ?>" class="quick-link">Review Applications</a>
                <?php endif; ?>
                <?php if (canAccessModule('students')): ?>
                <a href="<?= moduleUrl('students') ?>" class="quick-link">Student Records</a>
                <?php endif; ?>
                <?php if (canAccessModule('lms')): ?>
                <a href="<?= moduleUrl('lms') ?>" class="quick-link">Learning Portal</a>
                <?php endif; ?>
                <?php if (canAccessModule('finance')): ?>
                <a href="<?= moduleUrl('finance') ?>" class="quick-link">Finance & Billing</a>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h2>System Modules</h2></div>
        <div class="card-body">
            <ul class="module-list">
                <?php
                $modules = ROLE_MODULES[$role] ?? [];
                $labels = [
                    'admissions' => 'Student Admissions',
                    'programs'   => 'Course & Program Management',
                    'students'   => 'Student Information System',
                    'timetable'  => 'Timetabling',
                    'lms'        => 'Learning Management',
                    'attendance' => 'Attendance Management',
                    'exams'      => 'Examinations & Assessment',
                    'finance'    => 'Finance & Accounting',
                    'hr'         => 'Human Resources',
                    'library'    => 'Library Management',
                    'placements' => 'Industrial Attachment',
                    'messages'   => 'Communication',
                    'reports'    => 'Reporting & Analytics',
                    'graduation' => 'Certification & Graduation',
                ];
                foreach ($modules as $m):
                    if ($m === 'dashboard') continue;
                ?>
                <li><?= e($labels[$m] ?? ucfirst($m)) ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
