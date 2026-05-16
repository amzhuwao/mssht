<?php
/**
 * Guardian summaries & access
 */

function getStudentGuardians(int $studentId): array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT g.*, sg.relationship, sg.is_primary
         FROM student_guardians sg
         JOIN guardians g ON g.id = sg.guardian_id
         WHERE sg.student_id = ?
         ORDER BY sg.is_primary DESC, g.last_name'
    );
    $stmt->execute([$studentId]);
    return $stmt->fetchAll();
}

function saveGuardianForStudent(int $studentId, array $data): int
{
    $db = getDB();
    $email = strtolower(trim($data['email']));
    $stmt = $db->prepare('SELECT id FROM guardians WHERE email = ?');
    $stmt->execute([$email]);
    $guardianId = (int) $stmt->fetchColumn();

    if (!$guardianId) {
        $db->prepare(
            'INSERT INTO guardians (first_name, last_name, email, phone, receive_summaries) VALUES (?, ?, ?, ?, ?)'
        )->execute([
            trim($data['first_name']),
            trim($data['last_name']),
            $email,
            trim($data['phone'] ?? '') ?: null,
            isset($data['receive_summaries']) ? 1 : (!array_key_exists('receive_summaries', $data) ? 1 : 0),
        ]);
        $guardianId = (int) $db->lastInsertId();
    }

    $db->prepare(
        'INSERT IGNORE INTO student_guardians (student_id, guardian_id, relationship, is_primary) VALUES (?, ?, ?, ?)'
    )->execute([
        $studentId, $guardianId,
        $data['relationship'] ?? 'parent',
        !empty($data['is_primary']) ? 1 : 0,
    ]);

    return $guardianId;
}

function buildStudentSummary(int $studentId): array
{
    $db = getDB();
    $student = $db->prepare(
        'SELECT s.*, p.name AS program_name,
                CONCAT(COALESCE(a.first_name, up.first_name), " ", COALESCE(a.last_name, up.last_name)) AS student_name
         FROM students s
         JOIN programs p ON p.id = s.program_id
         LEFT JOIN applications a ON a.id = s.application_id
         LEFT JOIN users u ON u.id = s.user_id
         LEFT JOIN user_profiles up ON up.user_id = u.id
         WHERE s.id = ?'
    );
    $student->execute([$studentId]);
    $student = $student->fetch();
    if (!$student) {
        return [];
    }

    $missing = [];
    $upcoming = [];
    $recentGrades = [];

    if ($student['user_id']) {
        $stmt = $db->prepare(
            'SELECT ca.title, ca.due_date, c.name AS class_name, cs.status
             FROM class_assignments ca
             JOIN classes c ON c.id = ca.class_id
             JOIN class_members cm ON cm.class_id = c.id AND cm.user_id = ?
             LEFT JOIN class_submissions cs ON cs.class_assignment_id = ca.id AND cs.student_id = ?
             WHERE ca.status = ? AND ca.due_date < NOW()
               AND (cs.id IS NULL OR cs.status NOT IN ("submitted","late","graded"))'
        );
        $stmt->execute([$student['user_id'], $studentId, 'published']);
        $missing = $stmt->fetchAll();

        $stmt = $db->prepare(
            'SELECT ca.title, ca.due_date, c.name AS class_name
             FROM class_assignments ca
             JOIN classes c ON c.id = ca.class_id
             JOIN class_members cm ON cm.class_id = c.id AND cm.user_id = ?
             LEFT JOIN class_submissions cs ON cs.class_assignment_id = ca.id AND cs.student_id = ?
             WHERE ca.status = ? AND ca.due_date >= NOW() AND ca.due_date <= DATE_ADD(NOW(), INTERVAL 14 DAY)
               AND (cs.id IS NULL OR cs.status = "missing")
             ORDER BY ca.due_date ASC LIMIT 10'
        );
        $stmt->execute([$student['user_id'], $studentId, 'published']);
        $upcoming = $stmt->fetchAll();

        $stmt = $db->prepare(
            'SELECT ca.title, cs.score, ca.max_score, c.name AS class_name, cs.graded_at
             FROM class_submissions cs
             JOIN class_assignments ca ON ca.id = cs.class_assignment_id
             JOIN classes c ON c.id = ca.class_id
             WHERE cs.student_id = ? AND cs.status = ?
             ORDER BY cs.graded_at DESC LIMIT 5'
        );
        $stmt->execute([$studentId, 'graded']);
        $recentGrades = $stmt->fetchAll();
    }

    $stmt = $db->prepare(
        'SELECT a.title, m.score, a.max_score, modu.code
         FROM marks m
         JOIN assessments a ON a.id = m.assessment_id
         JOIN modules modu ON modu.id = a.module_id
         WHERE m.student_id = ?
         ORDER BY m.entered_at DESC LIMIT 5'
    );
    $stmt->execute([$studentId]);
    $examMarks = $stmt->fetchAll();

    return [
        'student'       => $student,
        'missing'       => $missing,
        'upcoming'      => $upcoming,
        'recent_grades' => $recentGrades,
        'exam_marks'    => $examMarks,
    ];
}

function createGuardianAccessToken(int $guardianId, int $hoursValid = 168): string
{
    $db = getDB();
    $token = bin2hex(random_bytes(32));
    $db->prepare('INSERT INTO guardian_access_tokens (guardian_id, token, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? HOUR))')
       ->execute([$guardianId, $token, $hoursValid]);
    return $token;
}

function getGuardianByToken(string $token): ?array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT g.* FROM guardians g
         JOIN guardian_access_tokens t ON t.guardian_id = g.id
         WHERE t.token = ? AND t.expires_at > NOW()'
    );
    $stmt->execute([$token]);
    return $stmt->fetch() ?: null;
}

function getGuardianStudents(int $guardianId): array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT s.id, s.student_number, sg.relationship,
                CONCAT(COALESCE(a.first_name, up.first_name), " ", COALESCE(a.last_name, up.last_name)) AS name,
                p.name AS program_name
         FROM student_guardians sg
         JOIN students s ON s.id = sg.student_id
         JOIN programs p ON p.id = s.program_id
         LEFT JOIN applications a ON a.id = s.application_id
         LEFT JOIN users u ON u.id = s.user_id
         LEFT JOIN user_profiles up ON up.user_id = u.id
         WHERE sg.guardian_id = ?'
    );
    $stmt->execute([$guardianId]);
    return $stmt->fetchAll();
}

function renderGuardianSummaryHtml(array $summary): string
{
    $s = $summary['student'];
    $html = '<h2>Student Progress Summary</h2>';
    $html .= '<p><strong>' . e($s['student_name'] ?? $s['student_number']) . '</strong> (' . e($s['student_number']) . ')<br>';
    $html .= e($s['program_name']) . ' &middot; ' . formatDate(date('Y-m-d')) . '</p>';

    $html .= '<h3 style="color:#dc3545;">Missing work (' . count($summary['missing']) . ')</h3>';
    if (empty($summary['missing'])) {
        $html .= '<p>No missing assignments at this time.</p>';
    } else {
        $html .= '<ul>';
        foreach ($summary['missing'] as $m) {
            $html .= '<li><strong>' . e($m['title']) . '</strong> — ' . e($m['class_name']) . ' (was due ' . formatDate($m['due_date']) . ')</li>';
        }
        $html .= '</ul>';
    }

    $html .= '<h3 style="color:#0d4f4c;">Upcoming assignments (' . count($summary['upcoming']) . ')</h3>';
    if (empty($summary['upcoming'])) {
        $html .= '<p>Nothing due in the next 14 days.</p>';
    } else {
        $html .= '<ul>';
        foreach ($summary['upcoming'] as $u) {
            $html .= '<li><strong>' . e($u['title']) . '</strong> — ' . e($u['class_name']) . ' (due ' . formatDate($u['due_date'], 'd M Y H:i') . ')</li>';
        }
        $html .= '</ul>';
    }

    if (!empty($summary['recent_grades'])) {
        $html .= '<h3>Recent class grades</h3><ul>';
        foreach ($summary['recent_grades'] as $g) {
            $html .= '<li>' . e($g['title']) . ' — ' . e($g['score']) . '/' . e($g['max_score']) . ' (' . e($g['class_name']) . ')</li>';
        }
        $html .= '</ul>';
    }

    if (!empty($summary['exam_marks'])) {
        $html .= '<h3>Recent assessment marks</h3><ul>';
        foreach ($summary['exam_marks'] as $m) {
            $html .= '<li>' . e($m['code']) . ': ' . e($m['title']) . ' — ' . e($m['score']) . '/' . e($m['max_score']) . '</li>';
        }
        $html .= '</ul>';
    }

    return $html;
}

function sendGuardianSummary(int $guardianId, int $studentId): bool
{
    $db = getDB();
    $g = $db->prepare('SELECT * FROM guardians WHERE id = ? AND receive_summaries = 1');
    $g->execute([$guardianId]);
    $guardian = $g->fetch();
    if (!$guardian) {
        return false;
    }

    $summary = buildStudentSummary($studentId);
    if (empty($summary)) {
        return false;
    }

    $token = createGuardianAccessToken($guardianId);
    $portalLink = url('guardian-portal.php') . '?token=' . $token;
    $body = renderGuardianSummaryHtml($summary);
    $body .= '<p><a href="' . e($portalLink) . '">View full guardian portal</a> (link valid 7 days)</p>';

    $studentName = $summary['student']['student_name'] ?? $summary['student']['student_number'];
    $subject = APP_NAME . ' - Progress summary for ' . $studentName;
    $sent = sendEmail($guardian['email'], $subject, $body);

    $db->prepare(
        'INSERT INTO guardian_summary_logs (guardian_id, student_id, delivery_status) VALUES (?, ?, ?)'
    )->execute([$guardianId, $studentId, $sent ? 'sent' : 'failed']);

    return $sent;
}

function sendIntakeGuardianSummaries(int $intakeId, ?int $programId = null): array
{
    $db = getDB();
    $sql = 'SELECT DISTINCT s.id AS student_id, sg.guardian_id
            FROM students s
            JOIN student_guardians sg ON sg.student_id = s.id
            JOIN guardians g ON g.id = sg.guardian_id AND g.receive_summaries = 1
            WHERE s.intake_id = ? AND s.enrollment_status = ?';
    $params = [$intakeId, 'active'];
    if ($programId) {
        $sql .= ' AND s.program_id = ?';
        $params[] = $programId;
    }
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $pairs = $stmt->fetchAll();

    $sent = 0;
    $failed = 0;
    $students = [];
    foreach ($pairs as $row) {
        $students[(int) $row['student_id']] = true;
        if (sendGuardianSummary((int) $row['guardian_id'], (int) $row['student_id'])) {
            $sent++;
        } else {
            $failed++;
        }
    }

    return [
        'sent'     => $sent,
        'failed'   => $failed,
        'total'    => count($pairs),
        'students' => count($students),
    ];
}
