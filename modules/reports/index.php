<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('reports');

$pageTitle = 'Reports & Analytics';
$currentModule = 'reports';

$executive = reportExecutiveStats();
$enrollment = reportEnrollmentSummary();
$academic = reportAcademicSummary();
$admissions = reportAdmissionsSummary();
$system = reportSystemSummary();

$auditFilters = [
    'action' => trim($_GET['action'] ?? ''),
    'entity_type' => trim($_GET['entity_type'] ?? ''),
    'user_id' => trim($_GET['user_id'] ?? ''),
    'date_from' => trim($_GET['date_from'] ?? ''),
    'date_to' => trim($_GET['date_to'] ?? ''),
];
$auditTrail = reportAuditTrail($auditFilters);

$db = getDB();
$programs = $db->query('SELECT id, name FROM programs WHERE status = "active" ORDER BY name')->fetchAll();
$intakes = $db->query('SELECT id, name FROM intakes ORDER BY start_date DESC')->fetchAll();
$classes = $db->query('SELECT id, name FROM classes WHERE status = "active" ORDER BY name')->fetchAll();
$modules = $db->query('SELECT id, name, code FROM modules ORDER BY name')->fetchAll();
$students = $db->query(
    "SELECT s.id, s.student_number, COALESCE(s.first_name, up.first_name) AS first_name, COALESCE(s.last_name, up.last_name) AS last_name
     FROM students s
     LEFT JOIN users u ON u.id = s.user_id
     LEFT JOIN user_profiles up ON up.user_id = u.id
     ORDER BY s.student_number"
)->fetchAll();
$staffUsers = $db->query(
    "SELECT u.id, u.email, CONCAT(COALESCE(p.first_name, ''), ' ', COALESCE(p.last_name, '')) AS name
     FROM users u
     LEFT JOIN user_profiles p ON p.user_id = u.id
     WHERE u.role IN ('super_admin','registrar','finance','hod','lecturer')
     ORDER BY u.email"
)->fetchAll();

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="card" style="margin-bottom:1.5rem;">
    <div class="card-header"><h2>Executive Dashboard</h2></div>
    <div class="card-body">
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['total_students']) ?></span><span class="stat-label">Total Students</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['total_teachers']) ?></span><span class="stat-label">Total Teachers</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['total_admin_staff']) ?></span><span class="stat-label">Administrative Staff</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['active_courses']) ?></span><span class="stat-label">Active Courses</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['active_classes']) ?></span><span class="stat-label">Active Classes</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= e((string) $executive['current_academic_year']) ?></span><span class="stat-label">Academic Year</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= e((string) $executive['current_term']) ?></span><span class="stat-label">Current Term</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['total_parents_registered']) ?></span><span class="stat-label">Parents Registered</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['new_admissions_this_term']) ?></span><span class="stat-label">New Admissions This Term</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['student_withdrawals']) ?></span><span class="stat-label">Student Withdrawals</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney((float) $executive['overall_school_average']) ?></span><span class="stat-label">Overall School Average</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((float) $executive['overall_pass_rate'], 1) ?>%</span><span class="stat-label">Overall Pass Rate</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((float) $executive['course_completion_rate'], 1) ?>%</span><span class="stat-label">Course Completion Rate</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((float) $executive['average_attendance'], 1) ?>%</span><span class="stat-label">Average Attendance</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((float) $executive['assignment_submission_rate'], 1) ?>%</span><span class="stat-label">Assignment Submission Rate</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((float) $executive['examination_completion_rate'], 1) ?>%</span><span class="stat-label">Examination Completion Rate</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['total_logins_today']) ?></span><span class="stat-label">Total Logins Today</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['active_users']) ?></span><span class="stat-label">Active Users</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['pending_approvals']) ?></span><span class="stat-label">Pending Approvals</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['pending_admissions']) ?></span><span class="stat-label">Pending Admissions</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['pending_leave_requests']) ?></span><span class="stat-label">Pending Leave Requests</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['pending_fee_clearances']) ?></span><span class="stat-label">Pending Fee Clearances</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $executive['pending_teacher_evaluations']) ?></span><span class="stat-label">Pending Teacher Evaluations</span></div></div>
        </div>
    </div>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Enrollment Reports</h2></div>
        <div class="card-body table-wrap">
            <table class="data-table">
                <thead><tr><th>Program</th><th>Students</th><th>Male</th><th>Female</th></tr></thead>
                <tbody>
                <?php foreach ($enrollment['programs'] as $row): ?>
                <tr><td><?= e($row['name']) ?></td><td><?= (int) $row['students'] ?></td><td><?= (int) $row['male'] ?></td><td><?= (int) $row['female'] ?></td></tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h2>Demographics</h2></div>
        <div class="card-body table-wrap">
            <table class="data-table" style="margin-bottom:1rem;">
                <thead><tr><th>Gender</th><th>Total</th></tr></thead>
                <tbody><?php foreach ($enrollment['gender'] as $row): ?><tr><td><?= e($row['gender']) ?></td><td><?= (int) $row['total'] ?></td></tr><?php endforeach; ?></tbody>
            </table>
            <table class="data-table">
                <thead><tr><th>Age Band</th><th>Total</th></tr></thead>
                <tbody><?php foreach ($enrollment['age'] as $row): ?><tr><td><?= e($row['bucket']) ?></td><td><?= (int) $row['total'] ?></td></tr><?php endforeach; ?></tbody>
            </table>
        </div>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Academic Reports</h2></div>
    <div class="card-body">
        <div class="stats-grid" style="margin-bottom:1rem;">
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= formatMoney((float) $executive['overall_school_average']) ?></span><span class="stat-label">School Average</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((float) $executive['overall_pass_rate'], 1) ?>%</span><span class="stat-label">Pass Rate</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((float) $executive['course_completion_rate'], 1) ?>%</span><span class="stat-label">Course Completion</span></div></div>
            <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((float) $executive['average_attendance'], 1) ?>%</span><span class="stat-label">Attendance</span></div></div>
        </div>
        <table class="data-table">
            <thead><tr><th>Subject</th><th>Average</th><th>Pass Rate</th><th>Highest</th><th>Lowest</th><th>Marks</th></tr></thead>
            <tbody>
            <?php foreach ($academic['subjects'] as $row): ?>
            <tr>
                <td><?= e($row['subject']) ?></td>
                <td><?= e((string) $row['average_mark']) ?></td>
                <td><?= e((string) $row['pass_rate']) ?>%</td>
                <td><?= e((string) $row['highest_mark']) ?></td>
                <td><?= e((string) $row['lowest_mark']) ?></td>
                <td><?= (int) $row['submissions'] ?></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <table class="data-table" style="margin-top:1rem;">
            <thead><tr><th>Assessment Type</th><th>Assessments</th><th>Avg Weight</th><th>Average Mark</th><th>Pass Rate</th></tr></thead>
            <tbody>
            <?php foreach ($academic['assessment_types'] as $row): ?>
            <tr><td><?= e($row['assessment_type']) ?></td><td><?= (int) $row['assessments'] ?></td><td><?= e((string) $row['avg_weight']) ?>%</td><td><?= e((string) $row['average_mark']) ?></td><td><?= e((string) $row['pass_rate']) ?>%</td></tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Admissions Reports</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Status</th><th>Total</th></tr></thead>
            <tbody><?php foreach ($admissions['status'] as $row): ?><tr><td><?= e($row['status']) ?></td><td><?= (int) $row['total'] ?></td></tr><?php endforeach; ?></tbody>
        </table>
        <table class="data-table" style="margin-top:1rem;">
            <thead><tr><th>Period</th><th>Applications</th><th>Approved</th><th>Rejected</th><th>Waitlisted</th></tr></thead>
            <tbody><?php foreach ($admissions['trend'] as $row): ?><tr><td><?= e($row['period']) ?></td><td><?= (int) $row['applications'] ?></td><td><?= (int) $row['approved'] ?></td><td><?= (int) $row['rejected'] ?></td><td><?= (int) $row['waitlisted'] ?></td></tr><?php endforeach; ?></tbody>
        </table>
    </div>
</div>

<div class="dashboard-grid" style="margin-top:1.5rem;">
    <div class="card">
        <div class="card-header"><h2>ICT / System Reports</h2></div>
        <div class="card-body" style="max-height:520px; overflow-y:auto;">
            <div class="stats-grid" style="margin-bottom:1rem;">
                <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format($system['storage']['disk_total'] > 0 ? round(($system['storage']['disk_used'] / $system['storage']['disk_total']) * 100, 1) : 0, 1) ?>%</span><span class="stat-label">Disk Usage</span></div></div>
                <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $system['storage']['backup_files']) ?></span><span class="stat-label">Backup Files</span></div></div>
                <div class="stat-card"><div class="stat-body"><span class="stat-value"><?= number_format((int) $system['storage']['uploaded_files']) ?></span><span class="stat-label">Upload Folders</span></div></div>
            </div>
            <table class="data-table">
                <thead><tr><th>User</th><th>Action</th><th>IP</th><th>Date</th></tr></thead>
                <tbody>
                <?php foreach ($system['login_history'] as $row): ?>
                <tr><td><?= e(trim(($row['user_name'] ?? '') . ' ' . ($row['email'] ?? ''))) ?></td><td><?= e($row['action']) ?></td><td><?= e($row['ip_address'] ?? '—') ?></td><td><?= e($row['created_at']) ?></td></tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h2>Security Summary</h2></div>
        <div class="card-body table-wrap">
            <table class="data-table">
                <thead><tr><th>Action</th><th>Total</th></tr></thead>
                <tbody><?php foreach ($system['security'] as $row): ?><tr><td><?= e($row['action']) ?></td><td><?= (int) $row['total'] ?></td></tr><?php endforeach; ?></tbody>
            </table>
            <p class="text-muted" style="margin-top:1rem;">Failed logins, password resets, and role or permission changes are surfaced from the immutable audit trail.</p>
        </div>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Audit Reports</h2></div>
    <div class="card-body" style="max-height:520px; overflow-y:auto;">
        <form method="get" class="form-row" style="align-items:flex-end;">
            <div class="form-group"><label>Action</label><input name="action" value="<?= e($auditFilters['action']) ?>" placeholder="e.g. invoice_updated"></div>
            <div class="form-group"><label>Entity Type</label><input name="entity_type" value="<?= e($auditFilters['entity_type']) ?>" placeholder="user, invoice, student"></div>
            <div class="form-group"><label>User ID</label><input name="user_id" value="<?= e($auditFilters['user_id']) ?>"></div>
            <div class="form-group"><label>From</label><input type="date" name="date_from" value="<?= e($auditFilters['date_from']) ?>"></div>
            <div class="form-group"><label>To</label><input type="date" name="date_to" value="<?= e($auditFilters['date_to']) ?>"></div>
            <div class="form-group"><button type="submit" class="btn btn-outline">Filter</button></div>
        </form>

        <div class="table-wrap" style="margin-top:1rem;">
            <table class="data-table">
                <thead><tr><th>Date</th><th>User</th><th>Action</th><th>Entity</th><th>ID</th><th>IP</th></tr></thead>
                <tbody>
                <?php foreach ($auditTrail as $row): ?>
                <tr>
                    <td><?= e($row['created_at']) ?></td>
                    <td><?= e(trim(($row['user_name'] ?? '') . ' ' . ($row['email'] ?? ''))) ?></td>
                    <td><?= e($row['action']) ?></td>
                    <td><?= e($row['entity_type'] ?? '—') ?></td>
                    <td><?= e((string) ($row['entity_id'] ?? '—')) ?></td>
                    <td><?= e($row['ip_address'] ?? '—') ?></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Custom Report Builder</h2></div>
    <div class="card-body">
        <form method="get" action="<?= moduleUrl('reports', 'export') ?>" class="dashboard-grid" style="grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:1rem;align-items:end;">
            <div class="form-group">
                <label>Report</label>
                <select name="report_type">
                    <option value="enrollment">Enrollment</option>
                    <option value="academic">Academic</option>
                    <option value="admissions">Admissions</option>
                    <option value="financial">Financial</option>
                    <option value="system">ICT / System</option>
                    <option value="audit">Audit Trail</option>
                </select>
            </div>
            <div class="form-group">
                <label>Program</label>
                <select name="program_id"><option value="">Any</option><?php foreach ($programs as $program): ?><option value="<?= (int) $program['id'] ?>"><?= e($program['name']) ?></option><?php endforeach; ?></select>
            </div>
            <div class="form-group">
                <label>Paid Amount Is</label>
                <select name="comparison">
                    <option value="greater">Greater than or equal to</option>
                    <option value="less">Less than</option>
                </select>
            </div>
            <div class="form-group"><label>Percentage Threshold</label><input type="number" name="percentage" step="0.01" min="0" max="100" value="50"></div>
            <div class="form-group"><label>Academic Year</label><input name="academic_year" placeholder="2026"></div>
            <div class="form-group"><label>Term</label><input name="term" placeholder="Term 1"></div>
            <div class="form-group"><label>Department</label><input name="department" placeholder="Academic / Finance"></div>
            <div class="form-group">
                <label>Intake</label>
                <select name="intake_id"><option value="">Any</option><?php foreach ($intakes as $intake): ?><option value="<?= (int) $intake['id'] ?>"><?= e($intake['name']) ?></option><?php endforeach; ?></select>
            </div>
            <div class="form-group">
                <label>Class</label>
                <select name="class_id"><option value="">Any</option><?php foreach ($classes as $class): ?><option value="<?= (int) $class['id'] ?>"><?= e($class['name']) ?></option><?php endforeach; ?></select>
            </div>
            <div class="form-group"><label>Grade / Form</label><input name="grade_form" placeholder="Form 1, Grade 12"></div>
            <div class="form-group">
                <label>Subject</label>
                <select name="module_id"><option value="">Any</option><?php foreach ($modules as $module): ?><option value="<?= (int) $module['id'] ?>"><?= e(trim(($module['code'] ?? '') . ' ' . ($module['name'] ?? ''))) ?></option><?php endforeach; ?></select>
            </div>
            <div class="form-group"><label>Teacher</label><input name="teacher" placeholder="Lecturer name"></div>
            <div class="form-group">
                <label>Student</label>
                <select name="student_id"><option value="">Any</option><?php foreach ($students as $student): ?><option value="<?= (int) $student['id'] ?>"><?= e(trim($student['student_number'] . ' — ' . trim(($student['first_name'] ?? '') . ' ' . ($student['last_name'] ?? '')))) ?></option><?php endforeach; ?></select>
            </div>
            <div class="form-group">
                <label>Staff / User</label>
                <select name="user_id"><option value="">Any</option><?php foreach ($staffUsers as $staff): ?><option value="<?= (int) $staff['id'] ?>"><?= e(trim($staff['email'] . ' — ' . trim($staff['name']))) ?></option><?php endforeach; ?></select>
            </div>
            <div class="form-group">
                <label>Gender</label>
                <select name="gender">
                    <option value="">Any</option>
                    <option value="male">Male</option>
                    <option value="female">Female</option>
                    <option value="other">Other</option>
                </select>
            </div>
            <div class="form-group"><label>Boarding / Day Scholar</label><input name="boarding_day" placeholder="Boarding or Day"></div>
            <div class="form-group">
                <label>Admission Status</label>
                <select name="admission_status">
                    <option value="">Any</option>
                    <option value="pending">Pending</option>
                    <option value="under_review">Under Review</option>
                    <option value="approved">Approved</option>
                    <option value="rejected">Rejected</option>
                    <option value="waitlisted">Waitlisted</option>
                </select>
            </div>
            <div class="form-group"><label>Attendance %</label><input type="number" name="attendance_percentage" step="0.01" placeholder=">= 75"></div>
            <div class="form-group">
                <label>Fee Status</label>
                <select name="fee_status">
                    <option value="">Any</option>
                    <option value="clear">Clear</option>
                    <option value="due">Due</option>
                    <option value="overdue">Overdue</option>
                </select>
            </div>
            <div class="form-group"><label>Action</label><input name="action_filter" placeholder="For audit reports"></div>
            <div class="form-group"><label>From</label><input type="date" name="date_from"></div>
            <div class="form-group"><label>To</label><input type="date" name="date_to"></div>
            <div class="form-group"><button name="format" value="csv" type="submit" class="btn btn-outline">CSV</button></div>
            <div class="form-group"><button name="format" value="excel" type="submit" class="btn btn-outline">Excel</button></div>
            <div class="form-group"><button name="format" value="pdf" type="submit" class="btn btn-primary">PDF</button></div>
        </form>
        <p class="text-muted" style="margin-top:1rem;">The builder exports the selected report using the same data source as the dashboard and audit views.</p>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
