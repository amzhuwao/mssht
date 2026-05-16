<?php
/**
 * Virtual classroom / class management helpers
 */

function generateJoinCode(): string
{
    $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    $code = '';
    for ($i = 0; $i < 6; $i++) {
        $code .= $chars[random_int(0, strlen($chars) - 1)];
    }
    return $code;
}

function isClassTeacher(int $classId, ?int $userId = null): bool
{
    $userId = $userId ?? (int) ($_SESSION['user_id'] ?? 0);
    if (!$userId) return false;
    $db = getDB();
    $stmt = $db->prepare(
        "SELECT 1 FROM class_members WHERE class_id = ? AND user_id = ? AND member_role IN ('owner','co_teacher','ta')"
    );
    $stmt->execute([$classId, $userId]);
    return (bool) $stmt->fetchColumn();
}

function isClassMember(int $classId, ?int $userId = null): bool
{
    $userId = $userId ?? (int) ($_SESSION['user_id'] ?? 0);
    if (!$userId) return false;
    $db = getDB();
    $stmt = $db->prepare('SELECT 1 FROM class_members WHERE class_id = ? AND user_id = ?');
    $stmt->execute([$classId, $userId]);
    return (bool) $stmt->fetchColumn();
}

function requireClassAccess(int $classId): void
{
    requireLogin();
    if (!isClassMember($classId)) {
        flash('danger', 'You are not enrolled in this class.');
        redirect(moduleUrl('classes'));
    }
}

function getClassById(int $classId): ?array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT c.*, m.code AS module_code, m.name AS module_name,
                CONCAT(p.first_name, " ", p.last_name) AS teacher_name
         FROM classes c
         LEFT JOIN modules m ON m.id = c.module_id
         LEFT JOIN users u ON u.id = c.created_by
         LEFT JOIN user_profiles p ON p.user_id = u.id
         WHERE c.id = ?'
    );
    $stmt->execute([$classId]);
    return $stmt->fetch() ?: null;
}

function getUserClasses(?int $userId = null): array
{
    $userId = $userId ?? (int) ($_SESSION['user_id'] ?? 0);
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT c.*, cm.member_role, m.code AS module_code,
                (SELECT COUNT(*) FROM class_members WHERE class_id = c.id AND member_role = "student") AS student_count
         FROM class_members cm
         JOIN classes c ON c.id = cm.class_id
         LEFT JOIN modules m ON m.id = c.module_id
         WHERE cm.user_id = ? AND c.status = "active"
         ORDER BY c.name'
    );
    $stmt->execute([$userId]);
    return $stmt->fetchAll();
}

function joinClassByCode(int $userId, string $code): array
{
    $code = strtoupper(trim($code));
    $db = getDB();
    $stmt = $db->prepare('SELECT * FROM classes WHERE join_code = ? AND status = ?');
    $stmt->execute([$code, 'active']);
    $class = $stmt->fetch();
    if (!$class) {
        return ['ok' => false, 'message' => 'Invalid or expired class code.'];
    }

    $check = $db->prepare('SELECT id FROM class_members WHERE class_id = ? AND user_id = ?');
    $check->execute([$class['id'], $userId]);
    if ($check->fetch()) {
        return ['ok' => true, 'message' => 'You are already in this class.', 'class_id' => (int) $class['id']];
    }

    $role = 'student';
    $user = $db->prepare('SELECT role FROM users WHERE id = ?');
    $user->execute([$userId]);
    $userRole = $user->fetchColumn();
    if (in_array($userRole, ['lecturer', 'hod', 'super_admin', 'registrar'], true)) {
        $role = 'co_teacher';
    }

    $db->prepare('INSERT INTO class_members (class_id, user_id, member_role) VALUES (?, ?, ?)')
       ->execute([$class['id'], $userId, $role]);

    auditLog('class_join', 'class', (int) $class['id']);
    return ['ok' => true, 'message' => 'Joined class: ' . $class['name'], 'class_id' => (int) $class['id']];
}

function getClassStream(int $classId, int $limit = 50): array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT sp.*, CONCAT(p.first_name, " ", p.last_name) AS author_name, u.role AS author_role
         FROM stream_posts sp
         JOIN users u ON u.id = sp.user_id
         JOIN user_profiles p ON p.user_id = u.id
         WHERE sp.class_id = ? AND (sp.published_at IS NULL OR sp.published_at <= NOW())
         ORDER BY COALESCE(sp.published_at, sp.created_at) DESC
         LIMIT ?'
    );
    $stmt->execute([$classId, $limit]);
    return $stmt->fetchAll();
}

function getStreamComments(int $postId): array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT sc.*, CONCAT(p.first_name, " ", p.last_name) AS author_name
         FROM stream_comments sc
         JOIN user_profiles p ON p.user_id = sc.user_id
         WHERE sc.post_id = ? ORDER BY sc.created_at ASC'
    );
    $stmt->execute([$postId]);
    return $stmt->fetchAll();
}

function getClassAssignments(int $classId, ?int $studentId = null): array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT ca.*, ct.title AS topic_title,
                CONCAT(p.first_name, " ", p.last_name) AS author_name
         FROM class_assignments ca
         LEFT JOIN class_topics ct ON ct.id = ca.topic_id
         JOIN user_profiles p ON p.user_id = ca.created_by
         WHERE ca.class_id = ? AND ca.status = ?
         ORDER BY ca.due_date ASC'
    );
    $stmt->execute([$classId, 'published']);
    $assignments = $stmt->fetchAll();

    if ($studentId) {
        foreach ($assignments as &$a) {
            $sub = $db->prepare(
                'SELECT * FROM class_submissions WHERE class_assignment_id = ? AND student_id = ?'
            );
            $sub->execute([$a['id'], $studentId]);
            $a['submission'] = $sub->fetch() ?: null;
            $a['work_status'] = computeSubmissionStatus($a, $a['submission']);
        }
    }
    return $assignments;
}

function computeSubmissionStatus(array $assignment, ?array $submission): string
{
    if ($submission && in_array($submission['status'], ['submitted', 'late', 'graded'], true)) {
        return $submission['status'] === 'graded' ? 'graded' : ($submission['status'] === 'late' ? 'late' : 'submitted');
    }
    if (strtotime($assignment['due_date']) < time()) {
        return 'missing';
    }
    return 'assigned';
}

function submitClassAssignment(int $assignmentId, int $studentId, array $data): bool
{
    $db = getDB();
    $stmt = $db->prepare('SELECT * FROM class_assignments WHERE id = ? AND status = ?');
    $stmt->execute([$assignmentId, 'published']);
    $assignment = $stmt->fetch();
    if (!$assignment) return false;

    $isLate = strtotime($assignment['due_date']) < time();
    if ($isLate && !$assignment['allow_late']) {
        return false;
    }

    $status = $isLate ? 'late' : 'submitted';
    $filePath = $data['file_path'] ?? null;
    $externalUrl = $data['external_url'] ?? null;
    $notes = $data['notes'] ?? null;

    $existing = $db->prepare(
        'SELECT id FROM class_submissions WHERE class_assignment_id = ? AND student_id = ?'
    );
    $existing->execute([$assignmentId, $studentId]);
    $existingId = $existing->fetchColumn();

    if ($existingId) {
        $db->prepare(
            'UPDATE class_submissions SET file_path = ?, external_url = ?, notes = ?, status = ?, submitted_at = NOW() WHERE id = ?'
        )->execute([$filePath, $externalUrl, $notes, $status, $existingId]);
    } else {
        $db->prepare(
            'INSERT INTO class_submissions (class_assignment_id, student_id, file_path, external_url, notes, status, submitted_at)
             VALUES (?, ?, ?, ?, ?, ?, NOW())'
        )->execute([$assignmentId, $studentId, $filePath, $externalUrl, $notes, $status]);
    }
    return true;
}

function getStudentClassGrades(int $classId, int $studentId): array
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT ca.title, ca.max_score, ca.due_date, cs.score, cs.status, cs.feedback, cs.graded_at
         FROM class_assignments ca
         LEFT JOIN class_submissions cs ON cs.class_assignment_id = ca.id AND cs.student_id = ?
         WHERE ca.class_id = ? AND ca.status = ?
         ORDER BY ca.due_date'
    );
    $stmt->execute([$studentId, $classId, 'published']);
    return $stmt->fetchAll();
}

function getStudentUpcomingDeadlines(?int $userId = null, int $days = 14): array
{
    $userId = $userId ?? (int) ($_SESSION['user_id'] ?? 0);
    $studentId = getCurrentStudentId();
    if (!$studentId) return [];

    $db = getDB();
    $stmt = $db->prepare(
        'SELECT ca.id AS assignment_id, ca.title, ca.due_date, c.name AS class_name, c.id AS class_id, c.theme_color
         FROM class_assignments ca
         JOIN classes c ON c.id = ca.class_id
         JOIN class_members cm ON cm.class_id = c.id AND cm.user_id = ?
         WHERE ca.status = ? AND ca.due_date >= NOW() AND ca.due_date <= DATE_ADD(NOW(), INTERVAL ? DAY)
         ORDER BY ca.due_date ASC'
    );
    $stmt->execute([$userId, 'published', $days]);
    return $stmt->fetchAll();
}

function getStudentClassStats(?int $userId = null): array
{
    $userId = $userId ?? (int) ($_SESSION['user_id'] ?? 0);
    $studentId = getCurrentStudentId();
    $stats = ['classes' => 0, 'due_soon' => 0, 'missing' => 0, 'unread_notifications' => 0];
    if (!$userId) {
        return $stats;
    }

    $db = getDB();
    $s = $db->prepare(
        'SELECT COUNT(*) FROM class_members cm JOIN classes c ON c.id = cm.class_id
         WHERE cm.user_id = ? AND c.status = ?'
    );
    $s->execute([$userId, 'active']);
    $stats['classes'] = (int) $s->fetchColumn();

    if ($studentId) {
        $s = $db->prepare(
            'SELECT COUNT(*) FROM class_assignments ca
             JOIN class_members cm ON cm.class_id = ca.class_id AND cm.user_id = ?
             LEFT JOIN class_submissions cs ON cs.class_assignment_id = ca.id AND cs.student_id = ?
             WHERE ca.status = ? AND ca.due_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)
               AND (cs.id IS NULL OR cs.status = ?)'
        );
        $s->execute([$userId, $studentId, 'published', 'missing']);
        $stats['due_soon'] = (int) $s->fetchColumn();

        $s = $db->prepare(
            'SELECT COUNT(*) FROM class_assignments ca
             JOIN class_members cm ON cm.class_id = ca.class_id AND cm.user_id = ?
             LEFT JOIN class_submissions cs ON cs.class_assignment_id = ca.id AND cs.student_id = ?
             WHERE ca.status = ? AND ca.due_date < NOW()
               AND (cs.id IS NULL OR cs.status NOT IN ("submitted","late","graded"))'
        );
        $s->execute([$userId, $studentId, 'published']);
        $stats['missing'] = (int) $s->fetchColumn();
    }

    try {
        $s = $db->prepare('SELECT COUNT(*) FROM user_notifications WHERE user_id = ? AND is_read = 0');
        $s->execute([$userId]);
        $stats['unread_notifications'] = (int) $s->fetchColumn();
    } catch (Exception $e) {
        // notifications table may not exist
    }

    return $stats;
}

function notifyUser(int $userId, string $type, string $title, string $message, ?string $link = null): void
{
    try {
        $db = getDB();
        $db->prepare(
            'INSERT INTO user_notifications (user_id, type, title, message, link_url) VALUES (?, ?, ?, ?, ?)'
        )->execute([$userId, $type, $title, $message, $link]);
    } catch (Exception $e) {
        // Table may not exist yet
    }
}

function createClass(array $data, int $creatorId): ?int
{
    $db = getDB();
    $code = generateJoinCode();
    for ($i = 0; $i < 5; $i++) {
        try {
            $db->prepare(
                'INSERT INTO classes (module_id, name, section, subject, room_number, join_code, theme_color, description, created_by)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
            )->execute([
                $data['module_id'] ?: null,
                $data['name'],
                $data['section'] ?? null,
                $data['subject'] ?? null,
                $data['room_number'] ?? null,
                $code,
                $data['theme_color'] ?? '#0d4f4c',
                $data['description'] ?? null,
                $creatorId,
            ]);
            break;
        } catch (PDOException $e) {
            $code = generateJoinCode();
        }
    }
    $classId = (int) $db->lastInsertId();
    if (!$classId) return null;

    $db->prepare('INSERT INTO class_members (class_id, user_id, member_role) VALUES (?, ?, ?)')
       ->execute([$classId, $creatorId, 'owner']);

    return $classId;
}

function publishClassAssignment(int $classId, array $data, int $creatorId): int
{
    $db = getDB();
    $db->prepare(
        'INSERT INTO class_assignments (class_id, topic_id, title, instructions, due_date, max_score, allow_late, status, attachment_path, created_by, published_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())'
    )->execute([
        $classId,
        $data['topic_id'] ?: null,
        $data['title'],
        $data['instructions'] ?? null,
        $data['due_date'],
        $data['max_score'] ?? 100,
        !empty($data['allow_late']) ? 1 : 0,
        'published',
        $data['attachment_path'] ?? null,
        $creatorId,
    ]);
    $assignmentId = (int) $db->lastInsertId();

    $db->prepare(
        'INSERT INTO stream_posts (class_id, user_id, post_type, title, body, class_assignment_id, published_at, comments_enabled)
         VALUES (?, ?, ?, ?, ?, ?, NOW(), 1)'
    )->execute([
        $classId, $creatorId, 'assignment', $data['title'],
        'New assignment posted. Due: ' . date('d M Y H:i', strtotime($data['due_date'])),
        $assignmentId,
    ]);

    $class = getClassById($classId);
    $members = $db->prepare(
        'SELECT user_id FROM class_members WHERE class_id = ? AND member_role = ?'
    );
    $members->execute([$classId, 'student']);
    $link = moduleUrl('classes', 'view') . '?id=' . $classId . '&tab=classwork';
    foreach ($members->fetchAll() as $m) {
        notifyUser((int) $m['user_id'], 'assignment', 'New assignment: ' . $data['title'], $class['name'] ?? 'Class', $link);
    }

    return $assignmentId;
}

function postStreamAnnouncement(int $classId, int $userId, array $data): int
{
    $db = getDB();
    $db->prepare(
        'INSERT INTO stream_posts (class_id, user_id, post_type, title, body, attachment_path, external_url, published_at, comments_enabled)
         VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), ?)'
    )->execute([
        $classId, $userId, $data['post_type'] ?? 'announcement',
        $data['title'] ?? null, $data['body'],
        $data['attachment_path'] ?? null, $data['external_url'] ?? null,
        isset($data['comments_enabled']) ? (int) $data['comments_enabled'] : 1,
    ]);
    return (int) $db->lastInsertId();
}
