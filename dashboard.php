<?php
require_once __DIR__ . '/includes/bootstrap.php';
requireLogin();

$pageTitle = 'Dashboard';
$currentModule = 'dashboard';
$stats = getDashboardStats();
$user = currentUser();
$role = currentRole();

$moduleLabels = [
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
$modules = getRoleModules($role);
$accessibleModules = array_values(array_filter($modules, static function ($module) use ($moduleLabels) {
    return isset($moduleLabels[$module]);
}));
$totalModules = count($moduleLabels);
$moduleCoverage = $totalModules > 0 ? min(100, (int) round(count($accessibleModules) / $totalModules * 100)) : 0;
$revenuePerStudent = ($stats['students'] ?? 0) > 0 ? (float) $stats['revenue'] / (float) $stats['students'] : 0.0;
$dashboardMix = [
    ['label' => 'Active Students', 'value' => (int) $stats['students'], 'tone' => 'students'],
    ['label' => 'Pending Applications', 'value' => (int) $stats['pending_apps'], 'tone' => 'applications'],
    ['label' => 'Active Programs', 'value' => (int) $stats['programs'], 'tone' => 'programs'],
    ['label' => 'Invoices Due', 'value' => (int) $stats['invoices_due'], 'tone' => 'finance'],
];
$dashboardMixMax = max(array_map(static fn ($item) => $item['value'], $dashboardMix)) ?: 1;

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

<section class="dashboard-hero">
    <div class="hero-panel">
        <div class="hero-copy">
            <p class="eyebrow">Live operational snapshot</p>
            <h2>Welcome back, <?= e($user['first_name'] ?? 'User') ?></h2>
            <p>Watch enrollment, admissions, and finance signals update in a more visual way so the important parts stand out immediately.</p>

            <div class="hero-metrics">
                <div>
                    <span>Role</span>
                    <strong><?= e(roleLabel($role)) ?></strong>
                </div>
                <div>
                    <span>Modules unlocked</span>
                    <strong data-count-up="<?= count($accessibleModules) ?>"><?= count($accessibleModules) ?></strong>
                </div>
                <div>
                    <span>Invoices due</span>
                    <strong data-count-up="<?= (int) $stats['invoices_due'] ?>"><?= number_format((int) $stats['invoices_due']) ?></strong>
                </div>
            </div>
        </div>

        <div class="hero-visual">
            <div class="radial-meter" data-meter data-value="<?= $moduleCoverage ?>">
                <div class="radial-meter-inner">
                    <strong data-count-up="<?= $moduleCoverage ?>"><?= $moduleCoverage ?>%</strong>
                    <span>module coverage</span>
                </div>
            </div>

            <div class="hero-signal-list">
                <div class="signal-item">
                    <span>Revenue per student</span>
                    <strong><?= formatMoney($revenuePerStudent) ?></strong>
                </div>
                <div class="signal-item">
                    <span>Active students</span>
                    <strong><?= number_format((int) $stats['students']) ?></strong>
                </div>
                <div class="signal-item">
                    <span>Pending applications</span>
                    <strong><?= number_format((int) $stats['pending_apps']) ?></strong>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="dashboard-infographics">
    <div class="card infographic-card">
        <div class="card-header">
            <h2>Operational mix</h2>
            <span class="text-muted">Current workload distribution</span>
        </div>
        <div class="card-body infographic-body">
            <?php foreach ($dashboardMix as $item):
                $percent = (int) round(($item['value'] / $dashboardMixMax) * 100);
            ?>
            <div class="mix-row" data-mix-row>
                <div class="mix-row-head">
                    <span><?= e($item['label']) ?></span>
                    <strong data-count-up="<?= $item['value'] ?>"><?= number_format($item['value']) ?></strong>
                </div>
                <div class="mix-track">
                    <span class="mix-fill mix-<?= e($item['tone']) ?>" data-fill style="width:0;" data-target="<?= $percent ?>%"></span>
                </div>
            </div>
            <?php endforeach; ?>
        </div>
    </div>

    <div class="card infographic-card">
        <div class="card-header">
            <h2>Finance pulse</h2>
            <span class="text-muted">Quick read on cash activity</span>
        </div>
        <div class="card-body infographic-body">
            <div class="pulse-grid">
                <div class="pulse-cell">
                    <span>Total revenue</span>
                    <strong data-count-up="<?= (float) $stats['revenue'] ?>" data-prefix="USD "><?= formatMoney((float) $stats['revenue']) ?></strong>
                </div>
                <div class="pulse-cell">
                    <span>Invoices due</span>
                    <strong data-count-up="<?= (int) $stats['invoices_due'] ?>"><?= number_format((int) $stats['invoices_due']) ?></strong>
                </div>
                <div class="pulse-cell">
                    <span>Pending applications</span>
                    <strong><?= number_format((int) $stats['pending_apps']) ?></strong>
                </div>
                <div class="pulse-cell">
                    <span>Active programs</span>
                    <strong><?= number_format((int) $stats['programs']) ?></strong>
                </div>
            </div>
        </div>
    </div>
</section>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header">
            <h2>Welcome, <?= e($user['first_name'] ?? 'User') ?></h2>
        </div>
        <div class="card-body">
            <p>You are logged in as <strong><?= e(roleLabel($role)) ?></strong>.</p>
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
                <?php foreach ($modules as $m):
                    if ($m === 'dashboard') continue;
                ?>
                <li><?= e($moduleLabels[$m] ?? ucfirst($m)) ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    </div>
</div>

<script>
(function () {
    function animateNumber(node, target) {
        var isDecimal = String(target).indexOf('.') !== -1;
        var start = 0;
        var duration = 900;
        var startTime = null;
        var prefix = node.getAttribute('data-prefix') || '';
        var suffix = node.getAttribute('data-suffix') || '';

        function frame(timestamp) {
            if (startTime === null) {
                startTime = timestamp;
            }
            var progress = Math.min((timestamp - startTime) / duration, 1);
            var value = start + (target - start) * progress;
            var formatted = isDecimal
                ? value.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
                : Math.round(value).toLocaleString();
            node.textContent = prefix + formatted + suffix;
            if (progress < 1) {
                requestAnimationFrame(frame);
            }
        }

        requestAnimationFrame(frame);
    }

    document.querySelectorAll('[data-count-up]').forEach(function (node) {
        var rawTarget = node.getAttribute('data-count-up');
        var target = rawTarget.indexOf('.') !== -1 ? parseFloat(rawTarget) : parseInt(rawTarget, 10);

        if (isNaN(target)) {
            return;
        }

        animateNumber(node, target);
    });

    document.querySelectorAll('[data-meter]').forEach(function (node) {
        var value = parseInt(node.getAttribute('data-value') || '0', 10);
        node.style.setProperty('--meter-value', value + '%');
    });

    document.querySelectorAll('[data-fill]').forEach(function (node) {
        var target = node.getAttribute('data-target') || '0%';
        requestAnimationFrame(function () {
            node.style.width = target;
        });
    });
})();
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
