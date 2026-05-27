<?php
/** Student portal dashboard partial */
$student = getCurrentStudent();
$applicant = $student ? null : getCurrentApplicant();
$user = currentUser();

if ($student) {
    $stats = getStudentDashboardData();
    $classStats = getStudentClassStats();
    $deadlines = getStudentUpcomingDeadlines(null, 7);
    ?>

    <div class="student-welcome-banner">
        <div>
            <p class="hero-eyebrow" style="margin:0;">Student Portal</p>
            <h2 style="margin:.25rem 0 .5rem;">Welcome, <?= e($user['first_name'] ?? 'Student') ?></h2>
            <p class="text-muted" style="margin:0;">
                <strong><?= e($student['student_number'] ?? '') ?></strong>
                &mdash; <?= e($student['program_name'] ?? '') ?>
            </p>
        </div>
        <?= statusBadge($student['enrollment_status'] ?? 'active') ?>
    </div>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-body">
                <span class="stat-value"><?= (int) $classStats['classes'] ?></span>
                <span class="stat-label">My Classes</span>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-body">
                <span class="stat-value"><?= (int) $classStats['missing'] ?></span>
                <span class="stat-label">Missing Work</span>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-body">
                <span class="stat-value"><?= (int) $classStats['due_soon'] ?></span>
                <span class="stat-label">Due This Week</span>
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
                    <a href="<?= moduleUrl('classes') ?>" class="quick-link">My Classes</a>
                    <a href="<?= moduleUrl('classes', 'calendar') ?>" class="quick-link">Calendar &amp; Deadlines</a>
                    <a href="<?= moduleUrl('exams', 'my-results') ?>" class="quick-link">My Results</a>
                    <a href="<?= moduleUrl('finance') ?>" class="quick-link">My Fees</a>
                    <a href="<?= moduleUrl('attendance') ?>" class="quick-link">Attendance</a>
                    <a href="<?= moduleUrl('library') ?>" class="quick-link">Library</a>
                    <a href="<?= moduleUrl('notifications') ?>" class="quick-link">Notifications<?php if ($classStats['unread_notifications']): ?> (<?= (int)$classStats['unread_notifications'] ?>)<?php endif; ?></a>
                    <a href="<?= url('profile.php') ?>" class="quick-link">My Profile</a>
                </div>
            </div>
        </div>
        <div class="card">
            <div class="card-header"><h2>Upcoming deadlines</h2></div>
            <div class="card-body">
                <?php if (empty($deadlines)): ?>
                <p class="text-muted">No deadlines in the next 7 days.</p>
                <?php else: ?>
                <ul class="calendar-list" style="margin:0;">
                    <?php foreach (array_slice($deadlines, 0, 5) as $d): ?>
                    <li class="calendar-item" style="border-left-color:<?= e($d['theme_color']) ?>">
                        <div class="calendar-date"><?= formatDate($d['due_date'], 'd M H:i') ?></div>
                        <div class="calendar-title"><a href="<?= moduleUrl('classes', 'submit') ?>?assignment_id=<?= (int)($d['assignment_id'] ?? 0) ?>"><?= e($d['title']) ?></a></div>
                        <div class="calendar-class text-muted"><?= e($d['class_name']) ?></div>
                    </li>
                    <?php endforeach; ?>
                </ul>
                <a href="<?= moduleUrl('classes', 'calendar') ?>" style="font-size:.9rem;">View all &rarr;</a>
                <?php endif; ?>
            </div>
        </div>
    </div>
    <?php return; ?>
<?php } ?>

<div class="student-welcome-banner">
    <div>
        <p class="hero-eyebrow" style="margin:0;">Applicant Portal</p>
        <h2 style="margin:.25rem 0 .5rem;">Welcome, <?= e($user['first_name'] ?? 'Applicant') ?></h2>
        <p class="text-muted" style="margin:0;">
            <strong><?= e($applicant['application_ref'] ?? '') ?></strong>
            &mdash; <?= e($applicant['program_name'] ?? '') ?>
        </p>
    </div>
    <?= statusBadge($applicant['status'] ?? 'pending') ?>
</div>

<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-body">
            <span class="stat-value"><?= e(ucfirst(str_replace('_', ' ', $applicant['status'] ?? 'pending'))) ?></span>
            <span class="stat-label">Application Status</span>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-body">
            <span class="stat-value"><?= (int) ($applicant['documents_count'] ?? 0) ?></span>
            <span class="stat-label">Documents Uploaded</span>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-body">
            <span class="stat-value"><?= e($applicant['intake_name'] ?? '—') ?></span>
            <span class="stat-label">Intake</span>
        </div>
    </div>
    <div class="stat-card">
        <div class="stat-body">
            <span class="stat-value"><?= e($applicant['portal_email'] ?? $user['email'] ?? '—') ?></span>
            <span class="stat-label">Portal Email</span>
        </div>
    </div>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Application Tracking</h2></div>
        <div class="card-body">
            <p><strong>Reference:</strong> <?= e($applicant['application_ref'] ?? '') ?></p>
            <p><strong>Program:</strong> <?= e($applicant['program_name'] ?? '') ?></p>
            <p><strong>Submitted:</strong> <?= formatDate($applicant['created_at'] ?? null) ?></p>
            <p class="text-muted" style="margin-bottom:0;">You can use this portal to monitor your application while it is pending. Once approved, learning materials and class tools will appear automatically.</p>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>What happens next</h2></div>
        <div class="card-body">
            <ul class="module-list">
                <li>Your application is stored and visible here.</li>
                <li>Admissions can review documents and update your status.</li>
                <li>After approval, your account is linked to a student record.</li>
                <li>Learning materials and student tools unlock after approval.</li>
            </ul>
        </div>
    </div>
</div>
