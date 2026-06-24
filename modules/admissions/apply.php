<?php
require_once __DIR__ . '/../../includes/bootstrap.php';

$pageTitle = 'Online Application';
$db = getDB();
$programs = $db->query("SELECT id, name, program_type FROM programs WHERE status = 'active' ORDER BY name")->fetchAll();
$intakes = $db->query("SELECT id, name FROM intakes WHERE status = 'open' ORDER BY start_date")->fetchAll();
$success = false;
$ref = '';
$portalAccount = null;
$portalEmailResult = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!verifyCsrf($_POST['csrf'] ?? '')) {
        flash('danger', 'Invalid request.');
    } else {
        $ref = generateRef('APP');
        // Collect additional application details into a notes JSON blob
        $extra = [
            'attendance_type' => $_POST['attendance_type'] ?? '',
            'title' => $_POST['title'] ?? '',
            'national_id' => trim($_POST['national_id'] ?? ''),
            'marital_status' => $_POST['marital_status'] ?? '',
            'nationality' => trim($_POST['nationality'] ?? ''),
            'citizenship' => trim($_POST['citizenship'] ?? ''),
            'country_permanent_residence' => trim($_POST['country_permanent_residence'] ?? ''),
            'disability' => trim($_POST['disability'] ?? ''),
            'medical_conditions' => trim($_POST['medical_conditions'] ?? ''),
            'tel' => trim($_POST['tel'] ?? ''),
            'cell' => trim($_POST['cell'] ?? ''),
            'next_of_kin' => [
                'name' => trim($_POST['nok_name'] ?? ''),
                'relationship' => trim($_POST['nok_relationship'] ?? ''),
                'tel' => trim($_POST['nok_tel'] ?? ''),
                'email' => trim($_POST['nok_email'] ?? ''),
                'cell' => trim($_POST['nok_cell'] ?? ''),
            ],
            'first_choice' => trim($_POST['first_choice'] ?? ''),
            'second_choice' => trim($_POST['second_choice'] ?? ''),
            'exam_board' => trim($_POST['exam_board'] ?? ''),
            'o_level_results' => trim($_POST['o_level_results'] ?? ''),
            'a_level_results' => trim($_POST['a_level_results'] ?? ''),
            'tertiary_education' => trim($_POST['tertiary_education'] ?? ''),
            'work_experience' => trim($_POST['work_experience'] ?? ''),
            'sponsor' => [
                'type' => trim($_POST['sponsor_type'] ?? ''),
                'name' => trim($_POST['sponsor_name'] ?? ''),
                'contact' => trim($_POST['sponsor_contact'] ?? ''),
            ],
            'declarations' => [
                'completed_sections' => isset($_POST['completed_sections']) ? 1 : 0,
                'enclosed_documents' => isset($_POST['enclosed_documents']) ? 1 : 0,
                'signed' => isset($_POST['signed']) ? 1 : 0,
            ],
        ];
        $notes = json_encode($extra, JSON_UNESCAPED_UNICODE);

        if (empty($_FILES['document']['name'])) {
            flash('danger', 'Please upload a supporting document for your qualification.');
        } else {
            try {
                $db->beginTransaction();

                $stmt = $db->prepare(
                    'INSERT INTO applications (application_ref, program_id, intake_id, first_name, last_name, email, phone, gender, date_of_birth, address, previous_qualification, notes)
                     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
                );
                $stmt->execute([
                    $ref,
                    (int)$_POST['program_id'],
                    (int)$_POST['intake_id'],
                    trim($_POST['first_name']),
                    trim($_POST['last_name']),
                    trim($_POST['email']),
                    trim($_POST['phone']),
                    $_POST['gender'] ?: null,
                    $_POST['date_of_birth'] ?: null,
                    trim($_POST['address'] ?? ''),
                    trim($_POST['previous_qualification'] ?? ''),
                    $notes,
                ]);
                $appId = (int) $db->lastInsertId();

                $path = uploadFile($_FILES['document'], 'applications');
                if ($path) {
                    $db->prepare('INSERT INTO application_documents (application_id, document_type, file_path) VALUES (?, ?, ?)')
                       ->execute([$appId, $_POST['document_type'] ?? 'supporting_document', $path]);
                }

                $portalAccount = createApplicantPortalAccount($appId);
                if (!$portalAccount) {
                    throw new RuntimeException('Could not create the portal account.');
                }

                $applicantName = trim($_POST['first_name']) . ' ' . trim($_POST['last_name']);
                $portalEmailResult = sendApplicantPortalCredentialsEmail(
                    $portalAccount['email'],
                    $applicantName,
                    $ref,
                    $portalAccount['email'],
                    $portalAccount['temp_password'],
                    url('student-login.php')
                );

                $db->commit();
                $success = true;
            } catch (Throwable $e) {
                if ($db->inTransaction()) {
                    $db->rollBack();
                }
                flash('danger', 'Application submission failed. Please try again.');
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply Online | <?= e(APP_NAME) ?></title>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<?= asset('css/main.css') ?>">
    <style>
        body { background: var(--color-bg); padding: 2rem 1rem; }
        .apply-wrap { max-width: 760px; margin: 0 auto; }
        .apply-header { text-align: center; margin-bottom: 2rem; }
        .apply-header h1 { color: var(--color-primary-dark); font-family: var(--font-display); }
        .success-panel {
            overflow: hidden;
            border-radius: 18px;
            box-shadow: 0 18px 45px rgba(15, 23, 42, 0.12);
        }
        .success-hero {
            background: linear-gradient(135deg, #0d4f4c 0%, #146b68 100%);
            color: #fff;
            text-align: center;
            padding: 2.25rem 1.5rem 1.75rem;
        }
        .success-hero .brand-mark {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 64px;
            height: 64px;
            border-radius: 18px;
            background: rgba(255, 255, 255, 0.14);
            font-size: 28px;
            font-weight: 700;
            letter-spacing: 0.08em;
            margin-bottom: 12px;
        }
        .success-hero .eyebrow {
            font-size: 12px;
            letter-spacing: 0.22em;
            text-transform: uppercase;
            opacity: 0.85;
            margin: 0;
        }
        .success-hero h2 {
            margin: 10px 0 0;
            font-size: 28px;
            line-height: 1.1;
        }
        .success-body {
            background: #fff;
            border: 1px solid #dbe4ee;
            border-top: none;
            padding: 1.5rem;
        }
        .credential-box {
            background: #f8fafc;
            border: 1px solid #dbe4ee;
            border-radius: 14px;
            padding: 1.1rem 1.1rem 0.9rem;
            margin: 1.25rem 0 1rem;
        }
        .credential-box .label {
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            color: var(--color-primary-dark);
            margin-bottom: 0.85rem;
        }
        .credential-box table {
            width: 100%;
            border-collapse: collapse;
        }
        .credential-box td {
            padding: 0.45rem 0;
            vertical-align: top;
        }
        .credential-box td:first-child {
            color: #64748b;
            width: 42%;
        }
        .credential-box td:last-child {
            font-weight: 700;
            color: #0f172a;
        }
        .success-actions {
            text-align: center;
            margin-top: 1.1rem;
        }
    </style>
</head>
<body>
<div class="apply-wrap">
    <div class="apply-header">
        <h1>Online Application</h1>
        <p class="text-muted"><?= e(APP_FULL_NAME) ?></p>
    </div>
    <?php if ($success): ?>
    <div class="card success-panel">
        <div class="success-hero">
            <div class="brand-mark">M</div>
            <p class="eyebrow">Manica Skyview School of Hospitality and Tourism</p>
            <h2>Application Submitted</h2>
        </div>
        <div class="success-body">
            <p style="margin-top:0;">Hello, <?= e(trim(($_POST['first_name'] ?? '') . ' ' . ($_POST['last_name'] ?? ''))) ?: 'Applicant' ?>. Your application has been received and your portal is ready.</p>
            <div class="credential-box">
                <div class="label">Portal Credentials</div>
                <table role="presentation">
                    <tr>
                        <td>Application Ref</td>
                        <td><?= e($ref) ?></td>
                    </tr>
                    <?php if ($portalAccount): ?>
                    <tr>
                        <td>Portal Email</td>
                        <td><?= e($portalAccount['email']) ?></td>
                    </tr>
                    <tr>
                        <td>Temporary Password</td>
                        <td><?= e($portalAccount['temp_password']) ?></td>
                    </tr>
                    <?php endif; ?>
                </table>
            </div>
            <?php if ($portalEmailResult && !empty($portalEmailResult['sent'])): ?>
            <p class="text-success" style="margin-top:0;">A copy of your portal login details has been emailed to you.</p>
            <?php endif; ?>
            <p class="text-muted">Use the email and temporary password above to sign in to the applicant portal. Once your application is approved, the same account will unlock learning materials and student tools automatically.</p>
            <div class="success-actions">
                <a href="<?= url('student-login.php') ?>" class="btn btn-primary">Sign in to Portal</a>
                <a href="<?= url() ?>" class="btn btn-outline" style="margin-left:.5rem;">Return Home</a>
            </div>
        </div>
    </div>
    <?php else: ?>
    <form method="post" enctype="multipart/form-data" class="card">
        <div class="card-body">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <h3 style="margin-bottom:1rem;">Program Selection</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>Program *</label>
                    <input type="text" id="applyProgramSearch" placeholder="Search programs">
                    <select name="program_id" id="applyProgramSelect" required>
                        <option value="">Select program</option>
                        <?php foreach ($programs as $p): ?>
                        <option value="<?= $p['id'] ?>"><?= e($p['name']) ?> (<?= programTypeLabel($p['program_type']) ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Intake *</label>
                    <input type="text" id="applyIntakeSearch" placeholder="Search intakes">
                    <select name="intake_id" id="applyIntakeSelect" required>
                        <option value="">Select intake</option>
                        <?php foreach ($intakes as $i): ?>
                        <option value="<?= $i['id'] ?>"><?= e($i['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
            <h3 style="margin:1.5rem 0 1rem;">Personal Information</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>Title</label>
                    <select name="title">
                        <option value="">Select</option>
                        <option>Mr</option>
                        <option>Mrs</option>
                        <option>Miss</option>
                        <option>Ms</option>
                        <option>Dr</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Attendance Type</label>
                    <select name="attendance_type">
                        <option value="">Select</option>
                        <option value="full_time">Full time</option>
                        <option value="part_time">Part-time</option>
                        <option value="block">Block</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>First Name *</label>
                    <input type="text" name="first_name" required>
                </div>
                <div class="form-group">
                    <label>Last Name *</label>
                    <input type="text" name="last_name" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Email *</label>
                    <input type="email" name="email">
                </div>
                <div class="form-group">
                    <label>Telephone</label>
                    <input type="tel" name="tel">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Phone / Cell *</label>
                    <input type="tel" name="phone" required>
                </div>
                <div class="form-group">
                    <label>Alternate Cell</label>
                    <input type="tel" name="cell">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Gender</label>
                    <select name="gender">
                        <option value="">Select</option>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Date of Birth</label>
                    <input type="date" name="date_of_birth">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>National ID</label>
                    <input type="text" name="national_id">
                </div>
                <div class="form-group">
                    <label>Marital Status</label>
                    <select name="marital_status">
                        <option value="">Select</option>
                        <option value="single">Single</option>
                        <option value="married">Married</option>
                        <option value="divorced">Divorced</option>
                        <option value="widowed">Widowed</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Nationality</label>
                    <input type="text" name="nationality">
                </div>
                <div class="form-group">
                    <label>Citizenship</label>
                    <input type="text" name="citizenship">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Country of Permanent Residence</label>
                    <input type="text" name="country_permanent_residence">
                </div>
                <div class="form-group">
                    <label>Disability (if any)</label>
                    <input type="text" name="disability">
                </div>
            </div>
            <div class="form-group">
                <label>Medical condition / allergies (if any)</label>
                <textarea name="medical_conditions" rows="2"></textarea>
            </div>
            <div class="form-group">
                <label>Address</label>
                <textarea name="address" rows="2"></textarea>
            </div>
            <div class="form-group">
                <label>Previous Qualification</label>
                <input type="text" name="previous_qualification" placeholder="e.g. O-Level, A-Level, Diploma">
            </div>
            <h3 style="margin:1.5rem 0 1rem;">Next of Kin</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>Name</label>
                    <input type="text" name="nok_name">
                </div>
                <div class="form-group">
                    <label>Relationship</label>
                    <input type="text" name="nok_relationship">
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label>Telephone</label>
                    <input type="tel" name="nok_tel">
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="nok_email">
                </div>
            </div>
            <div class="form-group">
                <label>Cell</label>
                <input type="tel" name="nok_cell">
            </div>

            <h3 style="margin:1.5rem 0 1rem;">ACADEMIN HISTORY</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>Examination Board (e.g. ZIMSEC)</label>
                    <input type="text" name="exam_board">
                </div>
                <div class="form-group">
                    <label>Month/Year</label>
                    <input type="text" name="exam_month_year" placeholder="MM/YYYY">
                </div>
            </div>
            <div class="form-group">
                <label>O'Level Results / Grades</label>
                <textarea name="o_level_results" rows="2"></textarea>
            </div>
            <div class="form-group">
                <label>A'Level Results / Grades</label>
                <textarea name="a_level_results" rows="2"></textarea>
            </div>
            <div class="form-group">
                <label>Tertiary Education (Year / Qualification / Institution)</label>
                <textarea name="tertiary_education" rows="2"></textarea>
            </div>

            <h3 style="margin:1.5rem 0 1rem;">Work Experience</h3>
            <div class="form-group">
                <label>Work Experience (Period, Occupation, Employer)</label>
                <textarea name="work_experience" rows="3"></textarea>
            </div>

            <h3 style="margin:1.5rem 0 1rem;">Sponsorship</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>Sponsor Type</label>
                    <select name="sponsor_type">
                        <option value="self">Self</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Sponsor Name / Organisation</label>
                    <input type="text" name="sponsor_name">
                </div>
            </div>
            <div class="form-group">
                <label>Sponsor Contact</label>
                <input type="text" name="sponsor_contact">
            </div>

            <h3 style="margin:1.5rem 0 1rem;">Declarations</h3>
            <div class="form-row">
                <div class="form-group">
                    <label><input type="checkbox" name="completed_sections"> I have completed all sections of the form</label>
                </div>
                <div class="form-group">
                    <label><input type="checkbox" name="enclosed_documents"> I have enclosed certified copies of all documents</label>
                </div>
            </div>
            <div class="form-group">
                <label><input type="checkbox" name="signed"> I have signed this form</label>
            </div>
            <h3 style="margin:1.5rem 0 1rem;">Supporting Documents</h3>
            <p class="text-muted">Upload a document that supports the qualification you listed above.</p>
            <div class="form-row">
                <div class="form-group">
                    <label>Qualification Document Type</label>
                    <select name="document_type">
                        <option value="o_level_certificate">O-Level Certificate / Results Slip</option>
                        <option value="a_level_certificate">A-Level Certificate / Results Slip</option>
                        <option value="diploma">Diploma Certificate</option>
                        <option value="degree">Degree Certificate</option>
                        <option value="professional_qualification">Professional Qualification</option>
                        <option value="other_supporting_document">Other Supporting Document</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Upload Document (PDF, JPG, PNG)</label>
                    <input type="file" name="document" accept=".pdf,.jpg,.jpeg,.png" required>
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn btn-primary btn-lg">Submit Application</button>
            </div>
        </div>
    </form>
    <?php endif; ?>
</div>

<script src="<?= asset('js/app.js') ?>"></script>
<script>
msshtSearchableSelect('applyProgramSearch', 'applyProgramSelect');
msshtSearchableSelect('applyIntakeSearch', 'applyIntakeSelect');
</script>

</body>
</html>
