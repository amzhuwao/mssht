<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('admissions');

$id = (int)($_GET['id'] ?? 0);
$db = getDB();
$stmt = $db->prepare(
    'SELECT a.*, p.name AS program_name, i.name AS intake_name
     FROM applications a
     JOIN programs p ON p.id = a.program_id
     JOIN intakes i ON i.id = a.intake_id
     WHERE a.id = ?'
);
$stmt->execute([$id]);
$app = $stmt->fetch();
if (!$app) {
    flash('danger', 'Application not found.');
    redirect(moduleUrl('admissions'));
}

// Decode notes JSON (if present) into a meta array for display and editing
$meta = [];
if (!empty($app['notes'])) {
    $decoded = json_decode($app['notes'], true);
    if (is_array($decoded)) {
        $meta = $decoded;
    } else {
        $meta = ['reviewer_notes' => $app['notes']];
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $newStatus = $_POST['status'];
    // Collect reviewer freeform notes
    $reviewer_notes = trim($_POST['reviewer_notes'] ?? '');

    // Merge posted meta fields into the existing meta array
    $metaUpdate = $meta;
    $metaUpdate['attendance_type'] = $_POST['attendance_type'] ?? ($metaUpdate['attendance_type'] ?? '');
    $metaUpdate['title'] = $_POST['title'] ?? ($metaUpdate['title'] ?? '');
    $metaUpdate['national_id'] = trim($_POST['national_id'] ?? ($metaUpdate['national_id'] ?? ''));
    $metaUpdate['marital_status'] = $_POST['marital_status'] ?? ($metaUpdate['marital_status'] ?? '');
    $metaUpdate['nationality'] = trim($_POST['nationality'] ?? ($metaUpdate['nationality'] ?? ''));
    $metaUpdate['citizenship'] = trim($_POST['citizenship'] ?? ($metaUpdate['citizenship'] ?? ''));
    $metaUpdate['country_permanent_residence'] = trim($_POST['country_permanent_residence'] ?? ($metaUpdate['country_permanent_residence'] ?? ''));
    $metaUpdate['disability'] = trim($_POST['disability'] ?? ($metaUpdate['disability'] ?? ''));
    $metaUpdate['medical_conditions'] = trim($_POST['medical_conditions'] ?? ($metaUpdate['medical_conditions'] ?? ''));
    $metaUpdate['tel'] = trim($_POST['tel'] ?? ($metaUpdate['tel'] ?? ''));
    $metaUpdate['cell'] = trim($_POST['cell'] ?? ($metaUpdate['cell'] ?? ''));
    $metaUpdate['next_of_kin'] = [
        'name' => trim($_POST['nok_name'] ?? ($metaUpdate['next_of_kin']['name'] ?? '')),
        'relationship' => trim($_POST['nok_relationship'] ?? ($metaUpdate['next_of_kin']['relationship'] ?? '')),
        'tel' => trim($_POST['nok_tel'] ?? ($metaUpdate['next_of_kin']['tel'] ?? '')),
        'email' => trim($_POST['nok_email'] ?? ($metaUpdate['next_of_kin']['email'] ?? '')),
        'cell' => trim($_POST['nok_cell'] ?? ($metaUpdate['next_of_kin']['cell'] ?? '')),
    ];
    $metaUpdate['first_choice'] = $_POST['first_choice'] ?? ($metaUpdate['first_choice'] ?? '');
    $metaUpdate['second_choice'] = $_POST['second_choice'] ?? ($metaUpdate['second_choice'] ?? '');
    $metaUpdate['exam_board'] = trim($_POST['exam_board'] ?? ($metaUpdate['exam_board'] ?? ''));
    $metaUpdate['o_level_results'] = trim($_POST['o_level_results'] ?? ($metaUpdate['o_level_results'] ?? ''));
    $metaUpdate['a_level_results'] = trim($_POST['a_level_results'] ?? ($metaUpdate['a_level_results'] ?? ''));
    $metaUpdate['tertiary_education'] = trim($_POST['tertiary_education'] ?? ($metaUpdate['tertiary_education'] ?? ''));
    $metaUpdate['work_experience'] = trim($_POST['work_experience'] ?? ($metaUpdate['work_experience'] ?? ''));
    $metaUpdate['sponsor'] = [
        'type' => trim($_POST['sponsor_type'] ?? ($metaUpdate['sponsor']['type'] ?? '')),
        'name' => trim($_POST['sponsor_name'] ?? ($metaUpdate['sponsor']['name'] ?? '')),
        'contact' => trim($_POST['sponsor_contact'] ?? ($metaUpdate['sponsor']['contact'] ?? '')),
    ];
    $metaUpdate['declarations'] = [
        'completed_sections' => isset($_POST['completed_sections']) ? 1 : ($metaUpdate['declarations']['completed_sections'] ?? 0),
        'enclosed_documents' => isset($_POST['enclosed_documents']) ? 1 : ($metaUpdate['declarations']['enclosed_documents'] ?? 0),
        'signed' => isset($_POST['signed']) ? 1 : ($metaUpdate['declarations']['signed'] ?? 0),
    ];
    $metaUpdate['reviewer_notes'] = $reviewer_notes;

    $notesJson = json_encode($metaUpdate, JSON_UNESCAPED_UNICODE);

    try {
        $db->beginTransaction();

        if ($newStatus === 'approved') {
            $current = $db->prepare('SELECT * FROM applications WHERE id = ? FOR UPDATE');
            $current->execute([$id]);
            $application = $current->fetch(PDO::FETCH_ASSOC);
            if (!$application) {
                throw new RuntimeException('This application has already been processed.');
            }

            $existingStudent = $db->prepare('SELECT id, student_number FROM students WHERE application_ref = ? OR application_id = ? LIMIT 1');
            $existingStudent->execute([$application['application_ref'], $id]);
            $duplicateStudent = $existingStudent->fetch(PDO::FETCH_ASSOC);
            if ($duplicateStudent) {
                throw new RuntimeException('This application has already been converted to student record ' . $duplicateStudent['student_number'] . '.');
            }

            $studentNum = generateStudentNumber($db);
            $db->prepare(
                'INSERT INTO students (
                    student_number, application_ref, first_name, last_name, email, phone, gender,
                    date_of_birth, address, previous_qualification, notes, user_id, application_id,
                    program_id, intake_id, enrollment_status, enrollment_date
                 ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE())'
            )->execute([
                $studentNum,
                $application['application_ref'],
                $application['first_name'],
                $application['last_name'],
                $application['email'],
                $application['phone'],
                $application['gender'],
                $application['date_of_birth'],
                $application['address'],
                $application['previous_qualification'],
                $application['notes'],
                !empty($application['user_id']) ? (int) $application['user_id'] : null,
                $id,
                $application['program_id'],
                $application['intake_id'],
                'active',
            ]);
            $studentId = (int) $db->lastInsertId();
            if (empty($application['user_id'])) {
                $portal = createStudentPortalAccount($studentId);
                $portalMsg = $portal
                    ? " Portal login — ID: {$portal['student_number']}, temp password: {$portal['temp_password']}"
                    : '';
                flash('success', "Application approved. Student ID: $studentNum.$portalMsg");
            } else {
                flash('success', "Application approved. Student ID: $studentNum. Existing portal account is now linked to the student record.");
            }

            $db->prepare('DELETE FROM applications WHERE id = ?')->execute([$id]);
        } else {
            $db->prepare('UPDATE applications SET status = ?, notes = ?, reviewed_by = ?, reviewed_at = NOW() WHERE id = ?')
               ->execute([$newStatus, $notesJson, $_SESSION['user_id'], $id]);
            flash('success', 'Application updated.');
        }

        $db->commit();
        auditLog('application_' . $newStatus, 'application', $id);
        redirect($newStatus === 'approved' ? moduleUrl('students', 'view') . '?id=' . $studentId : moduleUrl('admissions', 'review') . '?id=' . $id);
    } catch (Throwable $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        flash('danger', $e->getMessage() ?: 'Application update failed.');
        redirect(moduleUrl('admissions', 'review') . '?id=' . $id);
    }
}

$docs = $db->prepare('SELECT * FROM application_documents WHERE application_id = ?');
$docs->execute([$id]);
$documents = $docs->fetchAll();
$reviewerNotes = trim($meta['reviewer_notes'] ?? '');

$pageTitle = 'Review Application';
$currentModule = 'admissions';
require_once __DIR__ . '/../../includes/header.php';
?>

<style>
    .notes-box {
        background: #f8fafc;
        border: 1px solid #dbe4ee;
        border-radius: 12px;
        padding: 1rem;
        margin-top: 1rem;
        white-space: pre-wrap;
        line-height: 1.6;
    }
    .notes-help {
        color: #64748b;
        font-size: 0.92rem;
        margin-top: 0.35rem;
    }
</style>

<div class="page-actions">
    <a href="index.php" class="btn btn-outline btn-sm">&larr; Back to Applications</a>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2><?= e($app['application_ref']) ?> — <?= statusBadge($app['status']) ?></h2></div>
        <div class="card-body">
            <div class="form-row">
                <div><strong>Name:</strong> <?= e($app['first_name'] . ' ' . $app['last_name']) ?></div>
                <div><strong>Email:</strong> <?= e($app['email']) ?></div>
                <div><strong>Phone:</strong> <?= e($app['phone']) ?></div>
                <div><strong>Program:</strong> <?= e($app['program_name']) ?></div>
                <div><strong>Intake:</strong> <?= e($app['intake_name']) ?></div>
                <div><strong>Applied:</strong> <?= formatDate($app['created_at']) ?></div>
            </div>
            <?php if (!empty($meta)): ?>
            <hr>
            <h3>Applicant Details</h3>
            <div class="form-row">
                <div><strong>Title:</strong> <?= e($meta['title'] ?? '') ?></div>
                <div><strong>Attendance:</strong> <?= e($meta['attendance_type'] ?? '') ?></div>
                <div><strong>National ID:</strong> <?= e($meta['national_id'] ?? '') ?></div>
                <div><strong>Nationality:</strong> <?= e($meta['nationality'] ?? '') ?></div>
                <div><strong>Citizenship:</strong> <?= e($meta['citizenship'] ?? '') ?></div>
                <div><strong>Country (permanent):</strong> <?= e($meta['country_permanent_residence'] ?? '') ?></div>
            </div>
            <div class="form-row" style="margin-top:0.5rem;">
                <div><strong>Disability:</strong> <?= e($meta['disability'] ?? '') ?></div>
                <div><strong>Medical:</strong> <?= e($meta['medical_conditions'] ?? '') ?></div>
            </div>
            <div class="form-row" style="margin-top:0.5rem;">
                <div><strong>Telephone:</strong> <?= e($meta['tel'] ?? '') ?></div>
                <div><strong>Cell:</strong> <?= e($meta['cell'] ?? '') ?></div>
            </div>
            <h4 style="margin-top:0.5rem;">Next of Kin</h4>
            <div class="form-row">
                <div><strong>Name:</strong> <?= e($meta['next_of_kin']['name'] ?? '') ?></div>
                <div><strong>Relationship:</strong> <?= e($meta['next_of_kin']['relationship'] ?? '') ?></div>
                <div><strong>Tel:</strong> <?= e($meta['next_of_kin']['tel'] ?? '') ?></div>
                <div><strong>Email:</strong> <?= e($meta['next_of_kin']['email'] ?? '') ?></div>
                <div><strong>Cell:</strong> <?= e($meta['next_of_kin']['cell'] ?? '') ?></div>
            </div>
            <h4 style="margin-top:0.5rem;">Education & Preferences</h4>
            <div class="form-row">
                <div><strong>First Choice:</strong>
                    <?php
                    if (!empty($meta['first_choice']) && is_numeric($meta['first_choice'])) {
                        $pname = $db->prepare('SELECT name FROM programs WHERE id = ?');
                        $pname->execute([(int)$meta['first_choice']]);
                        echo e($pname->fetchColumn() ?: $meta['first_choice']);
                    } else {
                        echo e($meta['first_choice'] ?? '');
                    }
                    ?>
                </div>
                <div><strong>Second Choice:</strong>
                    <?php
                    if (!empty($meta['second_choice']) && is_numeric($meta['second_choice'])) {
                        $pname2 = $db->prepare('SELECT name FROM programs WHERE id = ?');
                        $pname2->execute([(int)$meta['second_choice']]);
                        echo e($pname2->fetchColumn() ?: $meta['second_choice']);
                    } else {
                        echo e($meta['second_choice'] ?? '');
                    }
                    ?>
                </div>
                <div><strong>Exam Board:</strong> <?= e($meta['exam_board'] ?? '') ?></div>
            </div>
            <div style="margin-top:0.5rem;"><strong>O'Level:</strong> <?= nl2br(e($meta['o_level_results'] ?? '')) ?></div>
            <div style="margin-top:0.5rem;"><strong>A'Level:</strong> <?= nl2br(e($meta['a_level_results'] ?? '')) ?></div>
            <div style="margin-top:0.5rem;"><strong>Tertiary:</strong> <?= nl2br(e($meta['tertiary_education'] ?? '')) ?></div>
            <div style="margin-top:0.5rem;"><strong>Work Experience:</strong> <?= nl2br(e($meta['work_experience'] ?? '')) ?></div>
            <div style="margin-top:0.5rem;"><strong>Sponsor:</strong> <?= e(($meta['sponsor']['type'] ?? '') . ' ' . ($meta['sponsor']['name'] ?? '')) ?> <?= e($meta['sponsor']['contact'] ?? '') ?></div>
            <div style="margin-top:0.5rem;"><strong>Declarations:</strong>
                Completed: <?= ($meta['declarations']['completed_sections'] ?? 0) ? 'Yes' : 'No' ?>,
                Documents: <?= ($meta['declarations']['enclosed_documents'] ?? 0) ? 'Yes' : 'No' ?>,
                Signed: <?= ($meta['declarations']['signed'] ?? 0) ? 'Yes' : 'No' ?>
            </div>
            <?php endif; ?>
            <?php if ($app['previous_qualification']): ?>
            <p style="margin-top:1rem;"><strong>Qualification:</strong> <?= e($app['previous_qualification']) ?></p>
            <?php endif; ?>
            <?php if ($app['address']): ?>
            <p><strong>Address:</strong> <?= e($app['address']) ?></p>
            <?php endif; ?>
            <?php if ($reviewerNotes !== ''): ?>
            <div style="margin-top:1rem;">
                <strong>Reviewer Notes</strong>
                <div class="notes-box"><?= nl2br(e($reviewerNotes)) ?></div>
            </div>
            <?php endif; ?>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h2>Update Status</h2></div>
        <div class="card-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" required>
                        <?php foreach (['pending','under_review','approved','rejected','waitlisted'] as $s): ?>
                        <option value="<?= $s ?>" <?= $app['status'] === $s ? 'selected' : '' ?>><?= ucfirst(str_replace('_',' ',$s)) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Reviewer Notes</label>
                    <textarea name="reviewer_notes" rows="7" placeholder="Use short paragraphs or one note per line for easier review."><?= e($reviewerNotes) ?></textarea>
                    <div class="notes-help">Tip: use line breaks to separate observations, concerns, or approval comments.</div>
                </div>
                <button type="submit" class="btn btn-primary">Save Decision</button>
            </form>
        </div>
    </div>
</div>

<?php if ($documents): ?>
<div class="card">
    <div class="card-header"><h2>Supporting Documents</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Type</th><th>Uploaded</th><th>Download</th></tr></thead>
            <tbody>
            <?php foreach ($documents as $doc): ?>
            <tr>
                <td>
                    <?php
                    $docLabels = [
                        'o_level_certificate' => 'O-Level Certificate / Results Slip',
                        'a_level_certificate' => 'A-Level Certificate / Results Slip',
                        'diploma' => 'Diploma Certificate',
                        'degree' => 'Degree Certificate',
                        'professional_qualification' => 'Professional Qualification',
                        'other_supporting_document' => 'Other Supporting Document',
                        'supporting_document' => 'Supporting Document',
                        'certificate' => 'Academic Certificate',
                        'id' => 'National ID',
                        'photo' => 'Passport Photo',
                        'other' => 'Other',
                    ];
                    echo e($docLabels[$doc['document_type']] ?? $doc['document_type']);
                    ?>
                </td>
                <td><?= formatDate($doc['uploaded_at']) ?></td>
                <td><a href="<?= UPLOAD_URL . '/' . e($doc['file_path']) ?>" target="_blank">View</a></td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
