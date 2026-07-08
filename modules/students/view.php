<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('students');

$id = (int)($_GET['id'] ?? 0);
$db = getDB();
$stmt = $db->prepare(
    'SELECT s.*, p.name AS program_name, p.program_type, i.name AS intake_name,
          COALESCE(s.first_name, up.first_name) AS first_name,
          COALESCE(s.last_name, up.last_name) AS last_name,
          COALESCE(s.email, u.email) AS email,
          COALESCE(s.phone, up.phone) AS phone
     FROM students s
     JOIN programs p ON p.id = s.program_id
     JOIN intakes i ON i.id = s.intake_id
    LEFT JOIN users u ON u.id = s.user_id
    LEFT JOIN user_profiles up ON up.user_id = u.id
     WHERE s.id = ?'
);
$stmt->execute([$id]);
$student = $stmt->fetch();
if (!$student) {
    flash('danger', 'Student not found.');
    redirect(moduleUrl('students'));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    try {
        $db->beginTransaction();

        if ($action === 'toggle_suspend') {
            $nextStatus = $student['enrollment_status'] === 'suspended' ? 'active' : 'suspended';
            $db->prepare('UPDATE students SET enrollment_status = ? WHERE id = ?')->execute([$nextStatus, $id]);
            if (!empty($student['user_id'])) {
                $db->prepare('UPDATE users SET status = ? WHERE id = ?')->execute([$nextStatus === 'suspended' ? 'suspended' : 'active', (int) $student['user_id']]);
            }
            $db->commit();
            flash('success', $nextStatus === 'suspended' ? 'Student account suspended.' : 'Student account reactivated.');
            redirect(moduleUrl('students', 'view') . '?id=' . $id);
        } elseif ($action === 'delete_student') {
            if (!empty($student['user_id'])) {
                $archiveEmail = 'archived+' . $student['user_id'] . '@students.mssht.ac.zw';
                $db->prepare('UPDATE users SET status = ?, email = ?, must_change_password = 0 WHERE id = ?')
                   ->execute(['inactive', $archiveEmail, (int) $student['user_id']]);
                $db->prepare('DELETE FROM user_profiles WHERE user_id = ?')->execute([(int) $student['user_id']]);
            }
            $db->prepare('DELETE FROM students WHERE id = ?')->execute([$id]);
            $db->commit();
            flash('success', 'Student account deleted.');
            redirect(moduleUrl('students'));
        } elseif ($action === 'finance_create_invoice') {
            requireFinanceManagement();
            $amount = (float) ($_POST['amount'] ?? 0);
            $description = trim($_POST['description'] ?? '');
            $dueDate = $_POST['due_date'] ?? '';
            $currency = $_POST['currency'] ?? 'USD';
            $notes = trim($_POST['notes'] ?? '');

            if ($amount <= 0) {
                throw new RuntimeException('Invoice amount must be greater than zero.');
            }
            if ($description === '') {
                throw new RuntimeException('Invoice description is required.');
            }
            if ($dueDate === '') {
                throw new RuntimeException('Due date is required.');
            }

            createInvoice([
                'student_id' => $id,
                'currency' => $currency,
                'due_date' => $dueDate,
                'notes' => $notes,
            ], [[
                'description' => $description,
                'quantity' => 1,
                'unit_amount' => $amount,
                'line_total' => $amount,
                'fee_type' => 'manual',
            ]]);
            $db->commit();
            flash('success', 'Invoice created for this student.');
            redirect(moduleUrl('students', 'view') . '?id=' . $id);
        } elseif ($action === 'finance_record_payment') {
            requireFinanceManagement();
            $invoiceId = (int) ($_POST['invoice_id'] ?? 0);
            $invoiceCheck = $db->prepare('SELECT id FROM invoices WHERE id = ? AND student_id = ?');
            $invoiceCheck->execute([$invoiceId, $id]);
            if (!$invoiceCheck->fetchColumn()) {
                throw new RuntimeException('Selected invoice does not belong to this student.');
            }

            $amount = (float) ($_POST['amount'] ?? 0);
            if ($amount <= 0) {
                throw new RuntimeException('Payment amount must be greater than zero.');
            }

            recordPayment($invoiceId, [
                'amount' => $amount,
                'currency' => $_POST['currency'] ?? 'USD',
                'payment_method' => $_POST['payment_method'] ?? 'cash',
                'reference' => trim($_POST['reference'] ?? ''),
                'exchange_rate' => (float) ($_POST['exchange_rate'] ?? 1),
                'status' => 'confirmed',
            ]);
            $db->commit();
            flash('success', 'Payment recorded.');
            redirect(moduleUrl('students', 'view') . '?id=' . $id);
        } elseif ($action === 'finance_confirm_payment') {
            requireFinanceManagement();
            $paymentId = (int) ($_POST['payment_id'] ?? 0);
            $paymentCheck = $db->prepare(
                'SELECT p.id
                 FROM payments p
                 JOIN invoices i ON i.id = p.invoice_id
                 WHERE p.id = ? AND i.student_id = ?'
            );
            $paymentCheck->execute([$paymentId, $id]);
            if (!$paymentCheck->fetchColumn()) {
                throw new RuntimeException('Selected payment does not belong to this student.');
            }
            confirmPayment($paymentId);
            $db->commit();
            flash('success', 'Payment confirmed.');
            redirect(moduleUrl('students', 'view') . '?id=' . $id);
        } elseif ($action === 'finance_place_hold') {
            requireFinanceManagement();
            $holdType = $_POST['hold_type'] ?? 'general';
            $reason = trim($_POST['reason'] ?? '');
            if ($reason === '') {
                throw new RuntimeException('Hold reason is required.');
            }
            addFinanceHold($id, $holdType, $reason, (int) ($_SESSION['user_id'] ?? 0) ?: null);
            $db->commit();
            flash('success', 'Financial hold placed.');
            redirect(moduleUrl('students', 'view') . '?id=' . $id);
        } elseif ($action === 'finance_lift_hold') {
            requireFinanceManagement();
            $holdId = (int) ($_POST['hold_id'] ?? 0);
            $holdCheck = $db->prepare('SELECT id FROM finance_holds WHERE id = ? AND student_id = ?');
            $holdCheck->execute([$holdId, $id]);
            if (!$holdCheck->fetchColumn()) {
                throw new RuntimeException('Selected hold does not belong to this student.');
            }
            liftFinanceHold($holdId, (int) ($_SESSION['user_id'] ?? 0) ?: null);
            $db->commit();
            flash('success', 'Financial hold lifted.');
            redirect(moduleUrl('students', 'view') . '?id=' . $id);
        } else {
            $db->rollBack();
        }
    } catch (Throwable $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        flash('danger', $e->getMessage() ?: 'Action failed.');
        redirect(moduleUrl('students', 'view') . '?id=' . $id);
    }
}

$registrations = $db->prepare(
    'SELECT mr.*, m.code, m.name AS module_name FROM module_registrations mr
     JOIN modules m ON m.id = mr.module_id WHERE mr.student_id = ?'
);
$registrations->execute([$id]);
$registrations = $registrations->fetchAll();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    if (($_POST['action'] ?? '') === 'add_guardian') {
        saveGuardianForStudent($id, [
            'first_name' => $_POST['first_name'],
            'last_name'  => $_POST['last_name'],
            'email'      => $_POST['email'],
            'phone'      => $_POST['phone'] ?? '',
            'relationship' => $_POST['relationship'] ?? 'parent',
            'is_primary' => isset($_POST['is_primary']),
            'receive_summaries' => isset($_POST['receive_summaries']),
        ]);
        flash('success', 'Guardian added.');
        redirect(moduleUrl('students', 'view') . '?id=' . $id);
    }
}

$guardians = getStudentGuardians($id);
$financeSummary = getStudentFinanceSummary($id);
$studentInvoicesStmt = $db->prepare(
    'SELECT i.*, (i.total_amount - i.amount_paid) AS balance
     FROM invoices i
     WHERE i.student_id = ?
     ORDER BY i.created_at DESC'
);
$studentInvoicesStmt->execute([$id]);
$studentInvoices = $studentInvoicesStmt->fetchAll();

$studentPaymentsStmt = $db->prepare(
    'SELECT p.*, i.invoice_number, i.total_amount, i.amount_paid, i.currency
     FROM payments p
     JOIN invoices i ON i.id = p.invoice_id
     WHERE i.student_id = ?
     ORDER BY p.paid_at DESC'
);
$studentPaymentsStmt->execute([$id]);
$studentPayments = $studentPaymentsStmt->fetchAll();

$studentHoldsStmt = $db->prepare(
    'SELECT * FROM finance_holds WHERE student_id = ? ORDER BY is_active DESC, created_at DESC'
);
$studentHoldsStmt->execute([$id]);
$studentHolds = $studentHoldsStmt->fetchAll();

$pageTitle = 'Student: ' . $student['student_number'];
$currentModule = 'students';

$hasPortal = !empty($student['user_id']);
$portalUser = null;
if ($hasPortal) {
    $pu = $db->prepare('SELECT email, must_change_password, last_login FROM users WHERE id = ?');
    $pu->execute([$student['user_id']]);
    $portalUser = $pu->fetch();
}

require_once __DIR__ . '/../../includes/header.php';
?>

<div class="page-actions">
    <a href="index.php" class="btn btn-outline btn-sm">&larr; All Students</a>
    <a href="<?= moduleUrl('students', 'edit') ?>?id=<?= $id ?>" class="btn btn-primary btn-sm">Edit Student</a>
    <?php if ($hasPortal): ?>
    <a href="create-portal.php?id=<?= $id ?>&reset=1" class="btn btn-outline btn-sm"
       data-confirm="Reset this student's portal password?">Reset Portal Password</a>
    <?php else: ?>
    <a href="create-portal.php?id=<?= $id ?>" class="btn btn-primary btn-sm">Create Portal Login</a>
    <?php endif; ?>
    <form method="post" style="display:inline-block;">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
        <input type="hidden" name="action" value="toggle_suspend">
        <button type="submit" class="btn btn-outline btn-sm" data-confirm="<?= $student['enrollment_status'] === 'suspended' ? 'Reactivate this student account?' : 'Suspend this student account?' ?>">
            <?= $student['enrollment_status'] === 'suspended' ? 'Reactivate' : 'Suspend' ?>
        </button>
    </form>
    <form method="post" style="display:inline-block;">
        <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
        <input type="hidden" name="action" value="delete_student">
        <button type="submit" class="btn btn-danger btn-sm" data-confirm="Delete this student account? This will remove the student record and deactivate the portal login.">Delete</button>
    </form>
</div>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2><?= e($student['student_number']) ?></h2><?= statusBadge($student['enrollment_status']) ?></div>
        <div class="card-body">
            <?php if ($student['first_name']): ?>
            <p><strong>Name:</strong> <?= e($student['first_name'] . ' ' . $student['last_name']) ?></p>
            <p><strong>Email:</strong> <?= e($student['email']) ?></p>
            <p><strong>Phone:</strong> <?= e($student['phone']) ?></p>
            <?php endif; ?>
            <p><strong>Program:</strong> <?= e($student['program_name']) ?> (<?= programTypeLabel($student['program_type']) ?>)</p>
            <p><strong>Intake:</strong> <?= e($student['intake_name']) ?></p>
            <p><strong>Enrolled:</strong> <?= formatDate($student['enrollment_date']) ?></p>
            <hr style="margin:1rem 0;border-color:var(--color-border);">
            <p><strong>Portal access:</strong>
                <?php if ($hasPortal && $portalUser): ?>
                Active — <?= e($portalUser['email']) ?>
                <?php if ($portalUser['must_change_password']): ?>
                <span class="badge badge-warning">Must change password</span>
                <?php endif; ?>
                <?php else: ?>
                <span class="text-muted">Not set up</span>
                <?php endif; ?>
            </p>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>Module Registrations</h2></div>
        <div class="card-body">
            <?php if (empty($registrations)): ?>
            <p class="text-muted">No module registrations yet.</p>
            <?php else: ?>
            <table class="data-table">
                <thead><tr><th>Module</th><th>Year</th><th>Status</th><th>Grade</th></tr></thead>
                <tbody>
                <?php foreach ($registrations as $r): ?>
                <tr>
                    <td><?= e($r['code'] . ' - ' . $r['module_name']) ?></td>
                    <td><?= e($r['academic_year']) ?></td>
                    <td><?= statusBadge($r['status']) ?></td>
                    <td><?= e($r['grade'] ?? '—') ?></td>
                </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <?php endif; ?>
        </div>
    </div>
</div>

<div class="dashboard-grid" style="margin-top:1.5rem;">
    <div class="card">
        <div class="card-header"><h2>Financial Overview</h2></div>
        <div class="card-body">
            <p><strong>Billed:</strong> <?= formatMoney((float) $financeSummary['billed']) ?></p>
            <p><strong>Paid:</strong> <?= formatMoney((float) $financeSummary['paid']) ?></p>
            <p><strong>Balance:</strong> <?= formatMoney((float) $financeSummary['balance']) ?></p>
            <p><strong>Active holds:</strong> <?= count(array_filter($studentHolds, static fn ($hold) => !empty($hold['is_active']))) ?></p>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>Create Invoice</h2></div>
        <div class="card-body">
            <form method="post" class="form-row">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <input type="hidden" name="action" value="finance_create_invoice">
                <div class="form-group"><label>Description</label><input name="description" required></div>
                <div class="form-group"><label>Amount</label><input type="number" step="0.01" min="0.01" name="amount" required></div>
                <div class="form-group"><label>Currency</label><select name="currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
                <div class="form-group"><label>Due date</label><input type="date" name="due_date" required value="<?= date('Y-m-d', strtotime('+30 days')) ?>"></div>
                <div class="form-group"><label>Notes</label><textarea name="notes" rows="2"></textarea></div>
                <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Add invoice</button></div>
            </form>
        </div>
    </div>
</div>

<div class="dashboard-grid" style="margin-top:1.5rem;">
    <div class="card">
        <div class="card-header"><h2>Record Payment</h2></div>
        <div class="card-body">
            <form method="post" class="form-row">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <input type="hidden" name="action" value="finance_record_payment">
                <div class="form-group">
                    <label>Invoice</label>
                    <select name="invoice_id" required>
                        <option value="">Select invoice</option>
                        <?php foreach ($studentInvoices as $invoice): ?>
                        <option value="<?= (int) $invoice['id'] ?>"><?= e($invoice['invoice_number'] . ' — ' . formatMoney((float) $invoice['balance'], $invoice['currency'] ?? 'USD')) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="form-group"><label>Amount</label><input type="number" step="0.01" min="0.01" name="amount" required></div>
                <div class="form-group"><label>Currency</label><select name="currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
                <div class="form-group"><label>Method</label>
                    <select name="payment_method" required>
                        <option value="cash">Cash</option>
                        <option value="bank">Bank Transfer</option>
                        <option value="mobile">Mobile Money</option>
                        <option value="card">Card</option>
                        <option value="gateway">Gateway</option>
                    </select>
                </div>
                <div class="form-group"><label>Reference</label><input name="reference"></div>
                <div class="form-group"><label>Exchange rate</label><input type="number" step="0.0001" name="exchange_rate" value="1"></div>
                <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Record payment</button></div>
            </form>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>Place Hold</h2></div>
        <div class="card-body">
            <form method="post" class="form-row">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <input type="hidden" name="action" value="finance_place_hold">
                <div class="form-group"><label>Type</label>
                    <select name="hold_type">
                        <option value="exams">Exams</option>
                        <option value="registration">Registration</option>
                        <option value="results">Results</option>
                        <option value="graduation">Graduation</option>
                        <option value="general">General</option>
                    </select>
                </div>
                <div class="form-group"><label>Reason</label><input name="reason" required></div>
                <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-outline">Place hold</button></div>
            </form>
        </div>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Invoices</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>Invoice</th><th>Total</th><th>Paid</th><th>Balance</th><th>Status</th><th>Due</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($studentInvoices as $invoice): ?>
            <tr>
                <td><?= e($invoice['invoice_number']) ?></td>
                <td><?= formatMoney((float) $invoice['total_amount'], $invoice['currency'] ?? 'USD') ?></td>
                <td><?= formatMoney((float) $invoice['amount_paid'], $invoice['currency'] ?? 'USD') ?></td>
                <td><?= formatMoney((float) $invoice['balance'], $invoice['currency'] ?? 'USD') ?></td>
                <td><?= statusBadge($invoice['status']) ?></td>
                <td><?= formatDate($invoice['due_date']) ?></td>
                <td>
                    <a href="<?= moduleUrl('finance', 'invoice') ?>?id=<?= (int) $invoice['id'] ?>" class="btn btn-sm btn-outline">View</a>
                    <a href="<?= moduleUrl('finance', 'payment') ?>?invoice_id=<?= (int) $invoice['id'] ?>" class="btn btn-sm btn-primary">Pay</a>
                </td>
            </tr>
            <?php endforeach; ?>
            <?php if (empty($studentInvoices)): ?>
            <tr><td colspan="7" class="empty-state">No invoices yet.</td></tr>
            <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<div class="dashboard-grid" style="margin-top:1.5rem;">
    <div class="card">
        <div class="card-header"><h2>Payments</h2></div>
        <div class="card-body table-wrap">
            <table class="data-table">
                <thead><tr><th>Receipt</th><th>Invoice</th><th>Amount</th><th>Method</th><th>Status</th><th></th></tr></thead>
                <tbody>
                <?php foreach ($studentPayments as $payment): ?>
                <tr>
                    <td><?= e($payment['receipt_number'] ?? ('#' . $payment['id'])) ?></td>
                    <td><?= e($payment['invoice_number']) ?></td>
                    <td><?= formatMoney((float) $payment['amount'], $payment['currency'] ?? 'USD') ?></td>
                    <td><?= e($payment['payment_method']) ?></td>
                    <td><?= statusBadge($payment['status']) ?></td>
                    <td>
                        <?php if (($payment['status'] ?? '') === 'pending'): ?>
                        <form method="post" style="display:inline-block;">
                            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                            <input type="hidden" name="action" value="finance_confirm_payment">
                            <input type="hidden" name="payment_id" value="<?= (int) $payment['id'] ?>">
                            <button type="submit" class="btn btn-sm btn-outline">Confirm</button>
                        </form>
                        <?php else: ?>
                        <span class="text-muted">—</span>
                        <?php endif; ?>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php if (empty($studentPayments)): ?>
                <tr><td colspan="6" class="empty-state">No payments recorded.</td></tr>
                <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
    <div class="card">
        <div class="card-header"><h2>Financial Holds</h2></div>
        <div class="card-body table-wrap">
            <table class="data-table">
                <thead><tr><th>Type</th><th>Reason</th><th>Active</th><th></th></tr></thead>
                <tbody>
                <?php foreach ($studentHolds as $hold): ?>
                <tr>
                    <td><?= e($hold['hold_type']) ?></td>
                    <td><?= e($hold['reason']) ?></td>
                    <td><?= !empty($hold['is_active']) ? 'Yes' : 'No' ?></td>
                    <td>
                        <?php if (!empty($hold['is_active'])): ?>
                        <form method="post" style="display:inline-block;">
                            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                            <input type="hidden" name="action" value="finance_lift_hold">
                            <input type="hidden" name="hold_id" value="<?= (int) $hold['id'] ?>">
                            <button type="submit" class="btn btn-sm btn-outline">Lift</button>
                        </form>
                        <?php else: ?>
                        <span class="text-muted">Lifted</span>
                        <?php endif; ?>
                    </td>
                </tr>
                <?php endforeach; ?>
                <?php if (empty($studentHolds)): ?>
                <tr><td colspan="4" class="empty-state">No financial holds.</td></tr>
                <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-header">
        <h2>Guardians / Parents</h2>
    </div>
    <div class="card-body">
        <?php if ($guardians): ?>
        <table class="data-table" style="margin-bottom:1.5rem;">
            <thead><tr><th>Name</th><th>Email</th><th>Relationship</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($guardians as $g): ?>
            <tr>
                <td><?= e($g['first_name'] . ' ' . $g['last_name']) ?></td>
                <td><?= e($g['email']) ?></td>
                <td><?= e($g['relationship']) ?></td>
                <td>
                    <a href="<?= moduleUrl('guardians', 'send-summary') ?>?student_id=<?= $id ?>&guardian_id=<?= (int)$g['id'] ?>" class="btn btn-sm btn-outline">Send summary</a>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
        <p><a href="<?= moduleUrl('guardians', 'send-summary') ?>?student_id=<?= $id ?>" class="btn btn-outline btn-sm">Email all guardians</a></p>
        <?php else: ?>
        <p class="text-muted">No guardians registered.</p>
        <?php endif; ?>
        <h3 style="font-size:1rem;margin:1rem 0;">Add guardian</h3>
        <form method="post" class="form-row">
            <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
            <input type="hidden" name="action" value="add_guardian">
            <div class="form-group"><label>First name</label><input name="first_name" required></div>
            <div class="form-group"><label>Last name</label><input name="last_name" required></div>
            <div class="form-group"><label>Email</label><input type="email" name="email" required></div>
            <div class="form-group"><label>Phone</label><input name="phone"></div>
            <div class="form-group"><label>Relationship</label>
                <select name="relationship"><option value="parent">Parent</option><option value="guardian">Guardian</option><option value="sponsor">Sponsor</option></select>
            </div>
            <div class="form-group"><label><input type="checkbox" name="receive_summaries" value="1" checked> Receive progress summaries</label></div>
            <div class="form-group" style="align-self:flex-end;"><button type="submit" class="btn btn-primary">Add guardian</button></div>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
