<?php
/**
 * PDF export helpers
 */

function buildGradesReportHtml(array $meta, array $rows, string $title): string
{
    $html = '<!DOCTYPE html><html><head><meta charset="UTF-8"><style>
        body{font-family:DejaVu Sans,Arial,sans-serif;font-size:11px;color:#222;margin:24px;}
        h1{font-size:18px;color:#0d4f4c;margin:0 0 4px;}
        .meta{color:#666;font-size:10px;margin-bottom:20px;}
        table{width:100%;border-collapse:collapse;margin-top:12px;}
        th,td{border:1px solid #ccc;padding:8px;text-align:left;}
        th{background:#0d4f4c;color:#fff;font-size:10px;}
        tr:nth-child(even){background:#f8f9fa;}
        .footer{margin-top:24px;font-size:9px;color:#888;text-align:center;}
        .overall{font-weight:bold;margin-top:16px;font-size:12px;}
    </style></head><body>';
    $html .= '<h1>' . e($title) . '</h1>';
    $html .= '<div class="meta">' . e(APP_FULL_NAME) . '<br>';
    foreach ($meta as $k => $v) {
        $html .= '<strong>' . e($k) . ':</strong> ' . e($v) . ' &nbsp; ';
    }
    $html .= '<br>Generated: ' . date('d M Y H:i') . '</div>';
    $html .= '<table><thead><tr>';
    foreach (array_keys($rows[0] ?? ['Item' => '', 'Score' => '']) as $header) {
        $html .= '<th>' . e($header) . '</th>';
    }
    $html .= '</tr></thead><tbody>';
    foreach ($rows as $row) {
        $html .= '<tr>';
        foreach ($row as $cell) {
            $html .= '<td>' . e((string) $cell) . '</td>';
        }
        $html .= '</tr>';
    }
    $html .= '</tbody></table>';
    $html .= '<div class="footer">Confidential academic record — ' . e(APP_FULL_NAME) . '</div>';
    $html .= '</body></html>';
    return $html;
}

function outputPdf(string $html, string $filename): void
{
    $filename = preg_replace('/[^a-zA-Z0-9._-]/', '_', $filename);
    if (!str_ends_with(strtolower($filename), '.pdf')) {
        $filename .= '.pdf';
    }

    $autoload = APP_ROOT . '/vendor/autoload.php';
    if (file_exists($autoload)) {
        require_once $autoload;
        if (class_exists(\Dompdf\Dompdf::class)) {
            $dompdf = new \Dompdf\Dompdf(['isRemoteEnabled' => false]);
            $dompdf->loadHtml($html);
            $dompdf->setPaper('A4', 'portrait');
            $dompdf->render();
            $dompdf->stream($filename, ['Attachment' => true]);
            exit;
        }
    }

    // Fallback: HTML download for print-to-PDF
    header('Content-Type: text/html; charset=UTF-8');
    echo $html;
    echo '<p style="margin-top:24px;padding:12px;background:#fff3cd;">PDF library not installed. '
        . 'Run <code>composer install</code> in the project root, or use your browser Print → Save as PDF.</p>';
    echo '<script>window.onload=function(){window.print();}</script>';
    exit;
}

function getStudentClassGradesForPdf(int $studentId, ?int $classId = null): array
{
    $db = getDB();
    $student = $db->prepare(
        'SELECT s.student_number, CONCAT(COALESCE(s.first_name,up.first_name)," ",COALESCE(s.last_name,up.last_name)) AS name, p.name AS program
         FROM students s JOIN programs p ON p.id = s.program_id
         LEFT JOIN users u ON u.id = s.user_id LEFT JOIN user_profiles up ON up.user_id = u.id
         WHERE s.id = ?'
    );
    $student->execute([$studentId]);
    $student = $student->fetch();

    $sql = 'SELECT c.name AS class_name, ca.title, ca.due_date, ca.max_score, cs.score, cs.status, cs.feedback
            FROM class_assignments ca
            JOIN classes c ON c.id = ca.class_id
            JOIN class_members cm ON cm.class_id = c.id
            JOIN students s ON s.user_id = cm.user_id AND s.id = ?
            LEFT JOIN class_submissions cs ON cs.class_assignment_id = ca.id AND cs.student_id = s.id
            WHERE ca.status = ?';
    $params = [$studentId, 'published'];
    if ($classId) {
        $sql .= ' AND c.id = ?';
        $params[] = $classId;
    }
    $sql .= ' ORDER BY c.name, ca.due_date';
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    $grades = $stmt->fetchAll();

    $rows = [];
    $totalEarned = 0;
    $totalMax = 0;
    foreach ($grades as $g) {
        $scoreStr = $g['score'] !== null ? $g['score'] . ' / ' . $g['max_score'] : '—';
        if ($g['score'] !== null) {
            $totalEarned += (float) $g['score'];
            $totalMax += (float) $g['max_score'];
        }
        $rows[] = [
            'Class'    => $g['class_name'],
            'Assignment' => $g['title'],
            'Due'      => formatDate($g['due_date']),
            'Score'    => $scoreStr,
            'Status'   => ucfirst($g['status'] ?? 'missing'),
        ];
    }
    if ($totalMax > 0) {
        $rows[] = [
            'Class' => 'OVERALL', 'Assignment' => '', 'Due' => '',
            'Score' => round($totalEarned / $totalMax * 100, 1) . '%',
            'Status' => $totalEarned . ' / ' . $totalMax . ' pts',
        ];
    }

    return ['student' => $student, 'rows' => $rows];
}
