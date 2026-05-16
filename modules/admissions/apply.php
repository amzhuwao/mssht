<?php
require_once __DIR__ . '/../../includes/bootstrap.php';

$pageTitle = 'Online Application';
$db = getDB();
$programs = $db->query("SELECT id, name, program_type FROM programs WHERE status = 'active' ORDER BY name")->fetchAll();
$intakes = $db->query("SELECT id, name FROM intakes WHERE status = 'open' ORDER BY start_date")->fetchAll();
$success = false;
$ref = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!verifyCsrf($_POST['csrf'] ?? '')) {
        flash('danger', 'Invalid request.');
    } else {
        $ref = generateRef('APP');
        $stmt = $db->prepare(
            'INSERT INTO applications (application_ref, program_id, intake_id, first_name, last_name, email, phone, gender, date_of_birth, address, previous_qualification)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
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
        ]);
        $appId = (int)$db->lastInsertId();

        if (!empty($_FILES['document']['name'])) {
            $path = uploadFile($_FILES['document'], 'applications');
            if ($path) {
                $db->prepare('INSERT INTO application_documents (application_id, document_type, file_path) VALUES (?, ?, ?)')
                   ->execute([$appId, $_POST['document_type'] ?? 'certificate', $path]);
            }
        }
        $success = true;
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
        .apply-wrap { max-width: 720px; margin: 0 auto; }
        .apply-header { text-align: center; margin-bottom: 2rem; }
        .apply-header h1 { color: var(--color-primary-dark); font-family: var(--font-display); }
    </style>
</head>
<body>
<div class="apply-wrap">
    <div class="apply-header">
        <h1>Online Application</h1>
        <p class="text-muted"><?= e(APP_FULL_NAME) ?></p>
    </div>
    <?php if ($success): ?>
    <div class="card">
        <div class="card-body" style="text-align:center;padding:2rem;">
            <h2 style="color:var(--color-success);">Application Submitted!</h2>
            <p>Your reference number is: <strong><?= e($ref) ?></strong></p>
            <p class="text-muted">Keep this reference to track your application status.</p>
            <a href="<?= url() ?>" class="btn btn-primary" style="margin-top:1rem;">Return Home</a>
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
                    <select name="program_id" required>
                        <option value="">Select program</option>
                        <?php foreach ($programs as $p): ?>
                        <option value="<?= $p['id'] ?>"><?= e($p['name']) ?> (<?= programTypeLabel($p['program_type']) ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group">
                    <label>Intake *</label>
                    <select name="intake_id" required>
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
                    <input type="email" name="email" required>
                </div>
                <div class="form-group">
                    <label>Phone *</label>
                    <input type="tel" name="phone" required>
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
            <div class="form-group">
                <label>Address</label>
                <textarea name="address" rows="2"></textarea>
            </div>
            <div class="form-group">
                <label>Previous Qualification</label>
                <input type="text" name="previous_qualification" placeholder="e.g. O-Level, A-Level, Diploma">
            </div>
            <h3 style="margin:1.5rem 0 1rem;">Documents</h3>
            <div class="form-row">
                <div class="form-group">
                    <label>Document Type</label>
                    <select name="document_type">
                        <option value="certificate">Academic Certificate</option>
                        <option value="id">National ID</option>
                        <option value="photo">Passport Photo</option>
                        <option value="other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Upload Document (PDF, JPG, PNG)</label>
                    <input type="file" name="document" accept=".pdf,.jpg,.jpeg,.png">
                </div>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn btn-primary btn-lg">Submit Application</button>
            </div>
        </div>
    </form>
    <?php endif; ?>
</div>
</body>
</html>
