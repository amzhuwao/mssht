<?php
/**
 * Reporting & analytics helpers
 */

function reportScalar(string $sql, array $params = [], $default = 0)
{
    $db = getDB();
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $value = $stmt->fetchColumn();
    return $value === false || $value === null ? $default : $value;
}

function reportRows(string $sql, array $params = []): array
{
    $db = getDB();
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll();
}

function reportCurrentAcademicPeriod(): array
{
    $db = getDB();
    $current = $db->query(
        'SELECT id, name, academic_year, start_date, end_date
         FROM intakes
         WHERE start_date <= CURDATE() AND end_date >= CURDATE()
         ORDER BY start_date DESC LIMIT 1'
    )->fetch();

    if (!$current) {
        $current = $db->query(
            'SELECT id, name, academic_year, start_date, end_date
             FROM intakes ORDER BY start_date DESC LIMIT 1'
        )->fetch();
    }

    return $current ?: [
        'id' => null,
        'name' => 'N/A',
        'academic_year' => (string) date('Y'),
        'start_date' => null,
        'end_date' => null,
    ];
}

function reportEnrollmentSummary(): array
{
    $programRows = reportRows(
        "SELECT p.id, p.name, COUNT(s.id) AS students,
                SUM(CASE WHEN s.gender = 'male' THEN 1 ELSE 0 END) AS male,
                SUM(CASE WHEN s.gender = 'female' THEN 1 ELSE 0 END) AS female
         FROM programs p
         LEFT JOIN students s ON s.program_id = p.id AND s.enrollment_status = 'active'
         GROUP BY p.id, p.name
         ORDER BY students DESC, p.name"
    );

    $genderRows = reportRows(
        "SELECT COALESCE(gender, 'unknown') AS gender, COUNT(*) AS total
         FROM students
         GROUP BY COALESCE(gender, 'unknown')
         ORDER BY total DESC"
    );

    $ageRows = reportRows(
        "SELECT bucket, COUNT(*) AS total
         FROM (
            SELECT CASE
                WHEN date_of_birth IS NULL THEN 'Unknown'
                WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) < 18 THEN 'Under 18'
                WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 18 AND 20 THEN '18-20'
                WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 21 AND 24 THEN '21-24'
                ELSE '25+'
            END AS bucket
            FROM students
         ) age_buckets
         GROUP BY bucket
         ORDER BY total DESC"
    );

    $intakeRows = reportRows(
        "SELECT i.name AS intake, i.academic_year, COUNT(s.id) AS students,
                SUM(CASE WHEN s.enrollment_status = 'withdrawn' THEN 1 ELSE 0 END) AS withdrawals,
                SUM(CASE WHEN s.enrollment_status = 'graduated' THEN 1 ELSE 0 END) AS graduates
         FROM intakes i
         LEFT JOIN students s ON s.intake_id = i.id
         GROUP BY i.id, i.name, i.academic_year
         ORDER BY i.start_date DESC"
    );

    return [
        'programs' => $programRows,
        'gender'   => $genderRows,
        'age'      => $ageRows,
        'intakes'  => $intakeRows,
    ];
}

function reportAcademicSummary(): array
{
    $subjectRows = reportRows(
        "SELECT m.id, m.code, m.name AS subject,
                ROUND(AVG(ms.score), 2) AS average_mark,
                ROUND(100 * SUM(CASE WHEN ms.score >= (a.max_score * 0.5) THEN 1 ELSE 0 END) / NULLIF(COUNT(ms.id), 0), 2) AS pass_rate,
                MAX(ms.score) AS highest_mark,
                MIN(ms.score) AS lowest_mark,
                COUNT(ms.id) AS submissions
         FROM assessments a
         JOIN modules m ON m.id = a.module_id
         LEFT JOIN marks ms ON ms.assessment_id = a.id
         GROUP BY m.id, m.code, m.name
         HAVING submissions > 0
         ORDER BY average_mark DESC, m.name"
    );

    $assessmentTypeRows = reportRows(
        "SELECT a.assessment_type,
                COUNT(*) AS assessments,
                ROUND(AVG(a.weight_percent), 2) AS avg_weight,
                ROUND(AVG(ms.score), 2) AS average_mark,
                ROUND(100 * SUM(CASE WHEN ms.score >= (a.max_score * 0.5) THEN 1 ELSE 0 END) / NULLIF(COUNT(ms.id), 0), 2) AS pass_rate
         FROM assessments a
         LEFT JOIN marks ms ON ms.assessment_id = a.id
         GROUP BY a.assessment_type
         ORDER BY assessments DESC"
    );

    $classRows = reportRows(
        "SELECT c.id, c.name AS class_name,
                ROUND(AVG(ms.score), 2) AS average_mark,
                MAX(ms.score) AS highest_mark,
                MIN(ms.score) AS lowest_mark,
                ROUND(STDDEV_POP(ms.score), 2) AS std_deviation,
                COUNT(ms.id) AS marks_count
         FROM classes c
         LEFT JOIN class_members cm ON cm.class_id = c.id AND cm.member_role = 'student'
         LEFT JOIN class_assignments ca ON ca.class_id = c.id
         LEFT JOIN class_submissions cs ON cs.class_assignment_id = ca.id AND cs.student_id IS NOT NULL
         LEFT JOIN marks ms ON ms.student_id IN (SELECT s.id FROM students s JOIN class_members cm2 ON cm2.user_id = s.user_id WHERE cm2.class_id = c.id)
         GROUP BY c.id, c.name
         HAVING marks_count > 0
         ORDER BY average_mark DESC, c.name"
    );

    return [
        'subjects'    => $subjectRows,
        'assessment_types' => $assessmentTypeRows,
        'classes'     => $classRows,
    ];
}

function reportAdmissionsSummary(): array
{
    $statusRows = reportRows(
        "SELECT status, COUNT(*) AS total
         FROM applications
         GROUP BY status
         ORDER BY total DESC, status"
    );

    $trendRows = reportRows(
        "SELECT DATE_FORMAT(created_at, '%Y-%m') AS period, COUNT(*) AS applications,
                SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) AS approved,
                SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) AS rejected,
                SUM(CASE WHEN status = 'waitlisted' THEN 1 ELSE 0 END) AS waitlisted
         FROM applications
         GROUP BY DATE_FORMAT(created_at, '%Y-%m')
         ORDER BY period DESC
         LIMIT 12"
    );

    return [
        'status' => $statusRows,
        'trend'  => $trendRows,
    ];
}

function reportSystemSummary(): array
{
    $db = getDB();
    $loginHistory = reportRows(
        "SELECT al.created_at, al.action, al.ip_address,
                u.email,
                CONCAT(COALESCE(up.first_name, ''), ' ', COALESCE(up.last_name, '')) AS user_name
         FROM audit_logs al
         LEFT JOIN users u ON u.id = al.user_id
         LEFT JOIN user_profiles up ON up.user_id = u.id
         WHERE al.action IN ('login', 'student_portal_login', 'login_failed', 'student_login_failed')
         ORDER BY al.created_at DESC
         LIMIT 100"
    );

    $securityRows = reportRows(
        "SELECT action, COUNT(*) AS total
         FROM audit_logs
         WHERE action IN ('login_failed', 'student_login_failed', 'password_reset', 'student_portal_reset', 'role_changed', 'permission_changed')
         GROUP BY action
         ORDER BY total DESC, action"
    );

    $storage = [
        'disk_total' => 0,
        'disk_used' => 0,
        'disk_free' => 0,
        'backup_files' => 0,
        'uploaded_files' => 0,
    ];
    try {
        $diskTotal = @disk_total_space(APP_ROOT);
        $diskFree = @disk_free_space(APP_ROOT);
        if ($diskTotal !== false && $diskFree !== false) {
            $storage['disk_total'] = (float) $diskTotal;
            $storage['disk_free'] = (float) $diskFree;
            $storage['disk_used'] = max(0, (float) $diskTotal - (float) $diskFree);
        }
        $storage['backup_files'] = is_dir(BACKUP_PATH) ? count(glob(BACKUP_PATH . '/*') ?: []) : 0;
        $storage['uploaded_files'] = is_dir(UPLOAD_PATH) ? count(glob(UPLOAD_PATH . '/*', GLOB_ONLYDIR) ?: []) : 0;
    } catch (Exception $e) {
        // File system stats are best effort.
    }

    return [
        'login_history' => $loginHistory,
        'security'      => $securityRows,
        'storage'       => $storage,
    ];
}

function reportAuditTrail(array $filters = []): array
{
    $where = [];
    $params = [];

    if (!empty($filters['action'])) {
        $where[] = 'al.action LIKE ?';
        $params[] = '%' . $filters['action'] . '%';
    }
    if (!empty($filters['entity_type'])) {
        $where[] = 'al.entity_type = ?';
        $params[] = $filters['entity_type'];
    }
    if (!empty($filters['user_id'])) {
        $where[] = 'al.user_id = ?';
        $params[] = (int) $filters['user_id'];
    }
    if (!empty($filters['date_from'])) {
        $where[] = 'DATE(al.created_at) >= ?';
        $params[] = $filters['date_from'];
    }
    if (!empty($filters['date_to'])) {
        $where[] = 'DATE(al.created_at) <= ?';
        $params[] = $filters['date_to'];
    }

    $sql = "SELECT al.*, u.email,
                   CONCAT(COALESCE(up.first_name, ''), ' ', COALESCE(up.last_name, '')) AS user_name
            FROM audit_logs al
            LEFT JOIN users u ON u.id = al.user_id
            LEFT JOIN user_profiles up ON up.user_id = u.id";
    if ($where) {
        $sql .= ' WHERE ' . implode(' AND ', $where);
    }
    $sql .= ' ORDER BY al.created_at DESC LIMIT 250';

    return reportRows($sql, $params);
}

function reportExecutiveStats(): array
{
    $current = reportCurrentAcademicPeriod();
    $currentIntakeId = $current['id'] ? (int) $current['id'] : null;
    $currentStart = $current['start_date'] ?? null;
    $currentEnd = $current['end_date'] ?? null;

    $stats = [
        'total_students' => 0,
        'total_teachers' => 0,
        'total_admin_staff' => 0,
        'active_courses' => 0,
        'active_classes' => 0,
        'current_academic_year' => $current['academic_year'] ?? date('Y'),
        'current_term' => $current['name'] ?? 'N/A',
        'total_parents_registered' => 0,
        'new_admissions_this_term' => 0,
        'student_withdrawals' => 0,
        'overall_school_average' => 0,
        'overall_pass_rate' => 0,
        'course_completion_rate' => 0,
        'average_attendance' => 0,
        'assignment_submission_rate' => 0,
        'examination_completion_rate' => 0,
        'total_logins_today' => 0,
        'active_users' => 0,
        'pending_approvals' => 0,
        'pending_admissions' => 0,
        'pending_leave_requests' => 0,
        'pending_fee_clearances' => 0,
        'pending_teacher_evaluations' => 0,
    ];

    try {
        $stats['total_students'] = (int) reportScalar("SELECT COUNT(*) FROM students WHERE enrollment_status = 'active'");
        $stats['total_teachers'] = (int) reportScalar("SELECT COUNT(*) FROM users WHERE role = 'lecturer' AND status = 'active'");
        $stats['total_admin_staff'] = (int) reportScalar('SELECT COUNT(*) FROM staff');
        $stats['active_courses'] = (int) reportScalar("SELECT COUNT(*) FROM programs WHERE status = 'active'");
        $stats['active_classes'] = (int) reportScalar("SELECT COUNT(*) FROM classes WHERE status = 'active'");
        $stats['total_parents_registered'] = (int) reportScalar('SELECT COUNT(DISTINCT guardian_id) FROM student_guardians');

        if ($currentIntakeId) {
            $stats['new_admissions_this_term'] = (int) reportScalar('SELECT COUNT(*) FROM students WHERE intake_id = ?', [$currentIntakeId]);
        } elseif ($currentStart && $currentEnd) {
            $stats['new_admissions_this_term'] = (int) reportScalar(
                'SELECT COUNT(*) FROM students WHERE enrollment_date BETWEEN ? AND ?',
                [$currentStart, $currentEnd]
            );
        }

        $stats['student_withdrawals'] = (int) reportScalar("SELECT COUNT(*) FROM students WHERE enrollment_status = 'withdrawn'");

        $stats['overall_school_average'] = (float) reportScalar(
            'SELECT COALESCE(ROUND(AVG((m.score / NULLIF(a.max_score, 0)) * 100), 2), 0) FROM marks m JOIN assessments a ON a.id = m.assessment_id'
        );
        $stats['overall_pass_rate'] = (float) reportScalar(
            'SELECT COALESCE(ROUND(100 * SUM(CASE WHEN m.score >= (a.max_score * 0.5) THEN 1 ELSE 0 END) / NULLIF(COUNT(m.id), 0), 2), 0) FROM marks m JOIN assessments a ON a.id = m.assessment_id'
        );
        $stats['course_completion_rate'] = (float) reportScalar(
            "SELECT COALESCE(ROUND(100 * SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2), 0) FROM module_registrations"
        );
        $stats['average_attendance'] = (float) reportScalar(
            "SELECT COALESCE(ROUND(100 * SUM(CASE WHEN status = 'present' THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2), 0) FROM attendance_records"
        );
        $stats['assignment_submission_rate'] = (float) reportScalar(
            "SELECT COALESCE(ROUND(100 * SUM(CASE WHEN status IN ('submitted','late','graded') THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2), 0) FROM class_submissions"
        );

        $expectedExams = reportScalar(
            "SELECT COALESCE(SUM(module_assessments * module_students), 0)
             FROM (
                SELECT m.id AS module_id,
                       COUNT(DISTINCT a.id) AS module_assessments,
                       COUNT(DISTINCT mr.student_id) AS module_students
                FROM modules m
                LEFT JOIN assessments a ON a.module_id = m.id
                LEFT JOIN module_registrations mr ON mr.module_id = m.id AND mr.status IN ('registered','completed','failed','carried')
                GROUP BY m.id
             ) x"
        );
        $marksRecorded = (int) reportScalar('SELECT COUNT(*) FROM marks');
        $stats['examination_completion_rate'] = $expectedExams > 0 ? round(100 * $marksRecorded / $expectedExams, 2) : 0;

        $stats['total_logins_today'] = (int) reportScalar(
            "SELECT COUNT(*) FROM audit_logs WHERE action IN ('login', 'student_portal_login') AND DATE(created_at) = CURDATE()"
        );
        $stats['active_users'] = (int) reportScalar(
            "SELECT COUNT(*) FROM users WHERE last_login >= DATE_SUB(NOW(), INTERVAL 24 HOUR)"
        );
        $stats['pending_approvals'] = (int) reportScalar(
            "SELECT COUNT(*) FROM applications WHERE status IN ('pending', 'under_review')"
        );
        $stats['pending_admissions'] = $stats['pending_approvals'];
        $stats['pending_fee_clearances'] = (int) reportScalar(
            "SELECT COUNT(*) FROM invoices WHERE status IN ('pending', 'partial', 'overdue')"
        );

    } catch (Exception $e) {
        // Best-effort analytics; missing modules should not break the page.
    }

    return $stats;
}

function reportFinancialSummary(array $filters = []): array
{
    $comparison = strtolower(trim((string) ($filters['comparison'] ?? 'greater')));
    $threshold = (float) ($filters['percentage'] ?? 0);
    $threshold = max(0, min(100, $threshold));
    $feeStatus = strtolower(trim((string) ($filters['fee_status'] ?? '')));

    $where = [];
    $params = [];

    if (!empty($filters['program_id'])) {
        $where[] = 's.program_id = ?';
        $params[] = (int) $filters['program_id'];
    }
    if (!empty($filters['intake_id'])) {
        $where[] = 's.intake_id = ?';
        $params[] = (int) $filters['intake_id'];
    }
    if (!empty($filters['student_id'])) {
        $where[] = 's.id = ?';
        $params[] = (int) $filters['student_id'];
    }

    $sql = "SELECT s.id, s.student_number,
                   COALESCE(s.first_name, up.first_name) AS first_name,
                   COALESCE(s.last_name, up.last_name) AS last_name,
                   p.name AS program_name,
                   i.name AS intake_name,
                   COALESCE(SUM(inv.total_amount), 0) AS billed,
                   COALESCE(SUM(inv.amount_paid), 0) AS paid,
                   COALESCE(SUM(inv.total_amount - inv.amount_paid), 0) AS balance,
                    COALESCE(SUM(CASE WHEN inv.due_date < CURDATE() AND inv.status IN ('pending','partial','overdue') THEN inv.total_amount - inv.amount_paid ELSE 0 END), 0) AS overdue_balance,
                   CASE WHEN COALESCE(SUM(inv.total_amount), 0) > 0
                        THEN ROUND(100 * COALESCE(SUM(inv.amount_paid), 0) / SUM(inv.total_amount), 2)
                        ELSE 0 END AS paid_percent
            FROM students s
            JOIN programs p ON p.id = s.program_id
            JOIN intakes i ON i.id = s.intake_id
            LEFT JOIN users u ON u.id = s.user_id
            LEFT JOIN user_profiles up ON up.user_id = u.id
            LEFT JOIN invoices inv ON inv.student_id = s.id AND inv.status <> 'cancelled'";

    if ($where) {
        $sql .= ' WHERE ' . implode(' AND ', $where);
    }

    $sql .= ' GROUP BY s.id, s.student_number, first_name, last_name, p.name, i.name';

    $feeStatusClause = '';
    if ($feeStatus === 'clear') {
        $feeStatusClause = ' AND balance <= 0.01';
    } elseif ($feeStatus === 'due') {
        $feeStatusClause = ' AND balance > 0.01 AND overdue_balance <= 0.01';
    } elseif ($feeStatus === 'overdue') {
        $feeStatusClause = ' AND overdue_balance > 0.01';
    }

    if ($comparison === 'less') {
        $sql .= ' HAVING paid_percent < ?' . $feeStatusClause;
    } else {
        $sql .= ' HAVING paid_percent >= ?' . $feeStatusClause;
        $comparison = 'greater';
    }
    $params[] = $threshold;
    $sql .= ' ORDER BY paid_percent DESC, s.student_number';

    $rows = reportRows($sql, $params);

    return [
        'title' => 'Financial Payment Percentage Report',
        'comparison' => $comparison,
        'threshold' => $threshold,
        'headers' => ['Student', 'Program', 'Intake', 'Billed', 'Paid', 'Balance', 'Paid %'],
        'rows' => array_map(static function ($row) {
            return [
                trim(($row['student_number'] ?? '') . ' — ' . trim(($row['first_name'] ?? '') . ' ' . ($row['last_name'] ?? ''))),
                $row['program_name'] ?? '',
                $row['intake_name'] ?? '',
                (float) $row['billed'],
                (float) $row['paid'],
                (float) $row['balance'],
                (float) $row['paid_percent'] . '%',
            ];
        }, $rows),
        'records' => $rows,
    ];
}

function reportDataset(string $type, array $filters = []): array
{
    return match ($type) {
        'financial' => [
            'title' => 'Financial Payment Percentage Report',
            'headers' => ['Student', 'Program', 'Intake', 'Billed', 'Paid', 'Balance', 'Paid %'],
            'rows' => array_map(static function ($row) {
                return [
                    trim(($row['student_number'] ?? '') . ' — ' . trim(($row['first_name'] ?? '') . ' ' . ($row['last_name'] ?? ''))),
                    $row['program_name'] ?? '',
                    $row['intake_name'] ?? '',
                    (float) $row['billed'],
                    (float) $row['paid'],
                    (float) $row['balance'],
                    (float) $row['paid_percent'] . '%',
                ];
            }, reportFinancialSummary($filters)['records']),
        ],
        'enrollment' => [
            'title' => 'Enrollment Report',
            'headers' => ['Program', 'Students', 'Male', 'Female'],
            'rows' => array_map(static function ($row) {
                return [$row['name'], (int) $row['students'], (int) $row['male'], (int) $row['female']];
            }, reportEnrollmentSummary()['programs']),
        ],
        'academic' => [
            'title' => 'Academic Performance Report',
            'headers' => ['Subject', 'Average Mark', 'Pass Rate %', 'Highest', 'Lowest', 'Submissions'],
            'rows' => array_map(static function ($row) {
                return [$row['subject'], $row['average_mark'], $row['pass_rate'], $row['highest_mark'], $row['lowest_mark'], (int) $row['submissions']];
            }, reportAcademicSummary()['subjects']),
        ],
        'admissions' => [
            'title' => 'Admissions Report',
            'headers' => ['Status', 'Total'],
            'rows' => array_map(static function ($row) {
                return [$row['status'], (int) $row['total']];
            }, reportAdmissionsSummary()['status']),
        ],
        'system' => [
            'title' => 'ICT / System Report',
            'headers' => ['Action', 'Total'],
            'rows' => array_map(static function ($row) {
                return [$row['action'], (int) $row['total']];
            }, reportSystemSummary()['security']),
        ],
        'audit' => [
            'title' => 'Audit Trail',
            'headers' => ['Date', 'User', 'Action', 'Entity Type', 'Entity ID', 'IP Address'],
            'rows' => array_map(static function ($row) {
                return [
                    $row['created_at'],
                    trim(($row['user_name'] ?? '') . ' ' . ($row['email'] ?? '')),
                    $row['action'],
                    $row['entity_type'] ?? '',
                    $row['entity_id'] ?? '',
                    $row['ip_address'] ?? '',
                ];
            }, reportAuditTrail($filters)),
        ],
        default => [
            'title' => 'Report',
            'headers' => ['Item', 'Value'],
            'rows' => [],
        ],
    };
}

function buildReportHtml(string $title, array $headers, array $rows, array $meta = []): string
{
    $html = '<!DOCTYPE html><html><head><meta charset="UTF-8"><style>';
    $html .= 'body{font-family:Arial,sans-serif;font-size:11px;color:#222;margin:24px;}';
    $html .= 'h1{font-size:18px;margin:0 0 8px;color:#0d4f4c;}';
    $html .= '.meta{color:#666;font-size:10px;margin-bottom:16px;}';
    $html .= 'table{width:100%;border-collapse:collapse;margin-top:12px;}th,td{border:1px solid #ccc;padding:7px;text-align:left;}th{background:#0d4f4c;color:#fff;}';
    $html .= '</style></head><body>';
    $html .= '<h1>' . e($title) . '</h1><div class="meta">' . e(APP_FULL_NAME) . '<br>Generated: ' . date('d M Y H:i') . '</div>';
    if ($meta) {
        $html .= '<div class="meta">';
        foreach ($meta as $label => $value) {
            $html .= '<strong>' . e($label) . ':</strong> ' . e((string) $value) . ' &nbsp; ';
        }
        $html .= '</div>';
    }
    $html .= '<table><thead><tr>';
    foreach ($headers as $header) {
        $html .= '<th>' . e((string) $header) . '</th>';
    }
    $html .= '</tr></thead><tbody>';
    foreach ($rows as $row) {
        $html .= '<tr>';
        foreach ($row as $cell) {
            $html .= '<td>' . e((string) $cell) . '</td>';
        }
        $html .= '</tr>';
    }
    $html .= '</tbody></table></body></html>';
    return $html;
}

function outputReportFile(string $type, string $format, array $filters = []): void
{
    $dataset = reportDataset($type, $filters);
    $title = $dataset['title'];
    $headers = $dataset['headers'];
    $rows = $dataset['rows'];
    $safeName = preg_replace('/[^a-zA-Z0-9._-]/', '_', strtolower($title));

    if ($format === 'pdf') {
        outputPdf(buildReportHtml($title, $headers, $rows), $safeName . '.pdf');
    }

    $filename = $safeName . '.csv';
    header('Content-Type: ' . ($format === 'excel' ? 'application/vnd.ms-excel' : 'text/csv'));
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    $handle = fopen('php://output', 'w');
    fputcsv($handle, $headers);
    foreach ($rows as $row) {
        fputcsv($handle, $row);
    }
    fclose($handle);
    exit;
}