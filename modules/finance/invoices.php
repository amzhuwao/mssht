<?php
require_once __DIR__ . '/../../includes/bootstrap.php';
requireModule('finance');
requireFinanceManagement();

$pageTitle = 'Invoicing';
$currentModule = 'finance';
$financeSection = 'invoices';
$db = getDB();
$editInvoiceId = (int) ($_GET['edit'] ?? 0);
$editInvoice = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && verifyCsrf($_POST['csrf'] ?? '')) {
    $action = $_POST['action'] ?? '';
    if ($action === 'create') {
        $lineDescriptions = $_POST['line_description'] ?? [];
        $lineQuantities = $_POST['line_quantity'] ?? [];
        $lineUnitAmounts = $_POST['line_unit_amount'] ?? [];
        $lineFeeTypes = $_POST['line_fee_type'] ?? [];
        $lines = [];
        $errors = [];

        $rowCount = max(count((array) $lineDescriptions), count((array) $lineQuantities), count((array) $lineUnitAmounts));
        for ($i = 0; $i < $rowCount; $i++) {
            $description = trim((string) ($lineDescriptions[$i] ?? ''));
            $quantity = (float) ($lineQuantities[$i] ?? 0);
            $unitAmount = (float) ($lineUnitAmounts[$i] ?? 0);
            $feeType = trim((string) ($lineFeeTypes[$i] ?? ''));

            if ($description === '' && $quantity <= 0 && $unitAmount <= 0) {
                continue;
            }

            if ($description === '') {
                $errors[] = 'Each invoice item must have a description.';
            }
            if ($quantity <= 0) {
                $errors[] = 'Each invoice item must have a quantity greater than zero.';
            }
            if ($unitAmount < 0) {
                $errors[] = 'Each invoice item must have a valid unit amount.';
            }

            $lines[] = [
                'description' => $description,
                'quantity' => $quantity,
                'unit_amount' => $unitAmount,
                'line_total' => round($quantity * $unitAmount, 2),
                'fee_type' => $feeType !== '' ? $feeType : null,
            ];
        }

        if (!$lines) {
            $errors[] = 'Add at least one invoice item.';
        }

        if ($errors) {
            flash('danger', implode(' ', array_unique($errors)));
            redirect(moduleUrl('finance', 'invoices'));
        }

        createInvoice([
            'student_id' => (int) $_POST['student_id'],
            'currency' => $_POST['currency'] ?? 'USD',
            'due_date' => $_POST['due_date'],
            'notes' => trim($_POST['notes'] ?? ''),
        ], $lines);
        flash('success', 'Invoice created.');
    }
    if ($action === 'update' && (int) ($_POST['invoice_id'] ?? 0)) {
        updateInvoice((int) $_POST['invoice_id'], [
            'currency' => $_POST['currency'] ?? 'USD',
            'invoice_type' => $_POST['invoice_type'] ?? 'invoice',
            'fee_structure_id' => $_POST['fee_structure_id'] ?? null,
            'sponsor_id' => $_POST['sponsor_id'] ?? null,
            'due_date' => $_POST['due_date'] ?? '',
            'notes' => trim($_POST['notes'] ?? ''),
        ]);
        flash('success', 'Invoice updated.');
    }
    if ($action === 'cancel' && (int) ($_POST['invoice_id'] ?? 0)) {
        cancelInvoice((int) $_POST['invoice_id']);
        flash('success', 'Invoice cancelled.');
    }
    if ($action === 'bulk' && (int) $_POST['intake_id'] && (int) $_POST['fee_structure_id']) {
        $r = bulkInvoiceIntake((int) $_POST['intake_id'], (int) $_POST['fee_structure_id'], $_POST['due_date']);
        flash('success', "Bulk billing: {$r['created']} invoice(s) created.");
    }
    redirect(moduleUrl('finance', 'invoices'));
}

$invoices = $db->query(
    'SELECT i.*, s.student_number FROM invoices i JOIN students s ON s.id = i.student_id ORDER BY i.created_at DESC LIMIT 100'
)->fetchAll();
$students = $db->query(
    "SELECT s.id, s.student_number, COALESCE(s.first_name, up.first_name) AS first_name, COALESCE(s.last_name, up.last_name) AS last_name
     FROM students s
     LEFT JOIN users u ON u.id = s.user_id
     LEFT JOIN user_profiles up ON up.user_id = u.id
     WHERE s.enrollment_status = 'active'
     ORDER BY s.student_number"
)->fetchAll();
$intakes = $db->query('SELECT id, name FROM intakes ORDER BY start_date DESC')->fetchAll();
$feeStructures = $db->query('SELECT fs.id, fs.description, p.name AS program_name, fs.amount FROM fee_structures fs JOIN programs p ON p.id = fs.program_id WHERE fs.is_active = 1')->fetchAll();

if ($editInvoiceId) {
    $stmt = $db->prepare('SELECT * FROM invoices WHERE id = ?');
    $stmt->execute([$editInvoiceId]);
    $editInvoice = $stmt->fetch();
}

require_once __DIR__ . '/../../includes/header.php';
require __DIR__ . '/../../includes/finance-nav.php';
?>

<div class="dashboard-grid">
    <div class="card">
        <div class="card-header"><h2>Create invoice</h2></div>
        <div class="card-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="create">
                <div class="form-group">
                    <label>Search student</label>
                    <input type="text" id="studentSearch" placeholder="Search by student number, name, or surname">
                </div>
                <div class="form-group"><label>Student</label><select name="student_id" id="studentSelect" required>
                    <option value="">Select</option><?php foreach ($students as $s): ?><option value="<?= (int) $s['id'] ?>"><?= e(trim($s['student_number'] . ' — ' . trim(($s['first_name'] ?? '') . ' ' . ($s['last_name'] ?? '')))) ?></option><?php endforeach; ?>
                </select></div>
                <div class="form-group"><label>Currency</label><select name="currency"><option value="USD">USD</option><option value="ZWL">ZWL</option></select></div>
                <div class="form-group"><label>Due date</label><input type="date" name="due_date" required value="<?= date('Y-m-d', strtotime('+30 days')) ?>"></div>
                <div class="form-group" style="margin-top:1rem;">
                    <label>Invoice items</label>
                    <div id="invoiceLines"></div>
                    <button type="button" class="btn btn-sm btn-outline" id="addInvoiceLine" style="margin-top:8px;">+ Add item</button>
                </div>
                <div class="form-group" style="margin-top:1rem;">
                    <label>Total</label>
                    <div id="invoiceTotal" style="font-size:1.1rem;font-weight:700;">USD 0.00</div>
                </div>
                <button type="submit" class="btn btn-primary">Create invoice</button>
            </form>
        </div>
    </div>
    <?php if ($editInvoice): ?>
    <div class="card">
        <div class="card-header"><h2>Edit invoice <?= e($editInvoice['invoice_number']) ?></h2></div>
        <div class="card-body">
            <form method="post">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="invoice_id" value="<?= (int) $editInvoice['id'] ?>">
                <div class="form-group"><label>Currency</label><select name="currency"><option value="USD" <?= ($editInvoice['currency'] ?? 'USD') === 'USD' ? 'selected' : '' ?>>USD</option><option value="ZWL" <?= ($editInvoice['currency'] ?? 'USD') === 'ZWL' ? 'selected' : '' ?>>ZWL</option></select></div>
                <div class="form-group"><label>Invoice type</label><select name="invoice_type"><option value="invoice" <?= ($editInvoice['invoice_type'] ?? 'invoice') === 'invoice' ? 'selected' : '' ?>>Invoice</option><option value="credit_note" <?= ($editInvoice['invoice_type'] ?? '') === 'credit_note' ? 'selected' : '' ?>>Credit note</option><option value="debit_note" <?= ($editInvoice['invoice_type'] ?? '') === 'debit_note' ? 'selected' : '' ?>>Debit note</option></select></div>
                <div class="form-group"><label>Due date</label><input type="date" name="due_date" value="<?= e($editInvoice['due_date']) ?>" required></div>
                <div class="form-group"><label>Fee structure</label><select name="fee_structure_id"><option value="">None</option><?php foreach ($feeStructures as $f): ?><option value="<?= (int) $f['id'] ?>" <?= (int) ($editInvoice['fee_structure_id'] ?? 0) === (int) $f['id'] ? 'selected' : '' ?>><?= e($f['program_name']) ?> — <?= e($f['description']) ?></option><?php endforeach; ?></select></div>
                <div class="form-group"><label>Sponsor</label><select name="sponsor_id"><option value="">None</option><?php foreach ($db->query('SELECT id, name FROM finance_sponsors WHERE is_active = 1')->fetchAll() as $sp): ?><option value="<?= (int) $sp['id'] ?>" <?= (int) ($editInvoice['sponsor_id'] ?? 0) === (int) $sp['id'] ? 'selected' : '' ?>><?= e($sp['name']) ?></option><?php endforeach; ?></select></div>
                <div class="form-group"><label>Notes</label><textarea name="notes" rows="4"><?= e($editInvoice['notes'] ?? '') ?></textarea></div>
                <button type="submit" class="btn btn-primary">Save changes</button>
            </form>
        </div>
    </div>
    <?php endif; ?>
    <div class="card">
        <div class="card-header"><h2>Bulk billing (intake)</h2></div>
        <div class="card-body">
            <form method="post" onsubmit="return confirm('Generate invoices for all active students in this intake?');">
                <input type="hidden" name="csrf" value="<?= csrfToken() ?>"><input type="hidden" name="action" value="bulk">
                <div class="form-group">
                    <label>Search intake</label>
                    <input type="text" id="intakeSearch" placeholder="Search by intake name">
                </div>
                <div class="form-group"><label>Intake</label><select name="intake_id" id="intakeSelect" required>
                    <option value="">Select</option><?php foreach ($intakes as $i): ?><option value="<?= (int) $i['id'] ?>"><?= e($i['name']) ?></option><?php endforeach; ?>
                </select></div>
                <div class="form-group">
                    <label>Search fee structure</label>
                    <input type="text" id="feeStructureSearch" placeholder="Search by program or fee description">
                </div>
                <div class="form-group"><label>Fee structure</label><select name="fee_structure_id" id="feeStructureSelect" required>
                    <option value="">Select</option><?php foreach ($feeStructures as $f): ?><option value="<?= (int) $f['id'] ?>"><?= e($f['program_name']) ?> — <?= e($f['description']) ?> (<?= formatMoney((float) $f['amount']) ?>)</option><?php endforeach; ?>
                </select></div>
                <div class="form-group"><label>Due date</label><input type="date" name="due_date" required value="<?= date('Y-m-d', strtotime('+30 days')) ?>"></div>
                <button type="submit" class="btn btn-outline">Bulk invoice intake</button>
            </form>
        </div>
    </div>
</div>

<div class="card" style="margin-top:1.5rem;">
    <div class="card-header"><h2>Invoices</h2></div>
    <div class="card-body table-wrap">
        <table class="data-table">
            <thead><tr><th>#</th><th>Student</th><th>Total</th><th>Paid</th><th>Status</th><th>Due</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($invoices as $inv): ?>
            <tr>
                <td><?= e($inv['invoice_number']) ?></td>
                <td><?= e($inv['student_number']) ?></td>
                <td><?= formatMoney((float) $inv['total_amount'], $inv['currency'] ?? 'USD') ?></td>
                <td><?= formatMoney((float) $inv['amount_paid'], $inv['currency'] ?? 'USD') ?></td>
                <td><?= statusBadge($inv['status']) ?></td>
                <td><?= formatDate($inv['due_date']) ?></td>
                <td>
                    <a href="invoice.php?id=<?= (int) $inv['id'] ?>" class="btn btn-sm btn-outline">View</a>
                    <a href="payment.php?invoice_id=<?= (int) $inv['id'] ?>" class="btn btn-sm btn-primary">Pay</a>
                    <a href="<?= moduleUrl('finance', 'invoices') ?>?edit=<?= (int) $inv['id'] ?>" class="btn btn-sm btn-outline">Edit</a>
                    <form method="post" style="display:inline;">
                        <input type="hidden" name="csrf" value="<?= csrfToken() ?>">
                        <input type="hidden" name="action" value="cancel">
                        <input type="hidden" name="invoice_id" value="<?= (int) $inv['id'] ?>">
                        <button type="submit" class="btn btn-sm btn-danger" data-confirm="Cancel this invoice?">Cancel</button>
                    </form>
                </td>
            </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<script>
(function () {
    function filterSelect(searchId, selectId) {
        const search = document.getElementById(searchId);
        const select = document.getElementById(selectId);
        if (!search || !select) return;

        const allOptions = Array.from(select.options).map(function (option) {
            return {
                value: option.value,
                text: option.textContent,
                selected: option.selected,
            };
        });

        search.addEventListener('input', function () {
            const q = this.value.toLowerCase().trim();
            const currentValue = select.value;

            select.innerHTML = '';
            allOptions.forEach(function (option, index) {
                if (index === 0) {
                    const placeholder = document.createElement('option');
                    placeholder.value = option.value;
                    placeholder.textContent = option.text;
                    select.appendChild(placeholder);
                    return;
                }
                const text = option.text.toLowerCase();
                if (!q || text.indexOf(q) > -1) {
                    const opt = document.createElement('option');
                    opt.value = option.value;
                    opt.textContent = option.text;
                    select.appendChild(opt);
                }
            });

            if (currentValue) {
                select.value = currentValue;
            }
        });
    }

    filterSelect('studentSearch', 'studentSelect');
    filterSelect('intakeSearch', 'intakeSelect');
    filterSelect('feeStructureSearch', 'feeStructureSelect');

    const linesWrap = document.getElementById('invoiceLines');
    const addLineBtn = document.getElementById('addInvoiceLine');
    const totalEl = document.getElementById('invoiceTotal');
    const currencySelect = document.querySelector('select[name="currency"]');

    function lineTemplate(index) {
        return `
            <div class="invoice-line" data-line="${index}" style="display:grid;grid-template-columns:2fr 1fr 1fr auto;gap:10px;align-items:end;margin-bottom:10px;">
                <div class="form-group" style="margin:0;"><label>Description</label><input name="line_description[]" placeholder="Tuition fees" required></div>
                <div class="form-group" style="margin:0;"><label>Qty</label><input type="number" step="0.01" min="0.01" name="line_quantity[]" value="1" required></div>
                <div class="form-group" style="margin:0;"><label>Unit amount</label><input type="number" step="0.01" min="0" name="line_unit_amount[]" value="0.00" required></div>
                <div><button type="button" class="btn btn-sm btn-outline js-remove-line">Remove</button></div>
            </div>
        `;
    }

    function recalcTotal() {
        let total = 0;
        linesWrap.querySelectorAll('.invoice-line').forEach(function (row) {
            const qty = parseFloat(row.querySelector('input[name="line_quantity[]"]').value || '0');
            const unit = parseFloat(row.querySelector('input[name="line_unit_amount[]"]').value || '0');
            total += (isNaN(qty) ? 0 : qty) * (isNaN(unit) ? 0 : unit);
        });
        const currency = currencySelect ? currencySelect.value : 'USD';
        totalEl.textContent = currency + ' ' + total.toFixed(2);
    }

    function addLine() {
        const index = linesWrap.querySelectorAll('.invoice-line').length;
        const wrapper = document.createElement('div');
        wrapper.innerHTML = lineTemplate(index);
        linesWrap.appendChild(wrapper.firstElementChild);
        recalcTotal();
    }

    if (addLineBtn && linesWrap) {
        addLineBtn.addEventListener('click', addLine);
        linesWrap.addEventListener('input', function (e) {
            if (e.target && (e.target.name === 'line_quantity[]' || e.target.name === 'line_unit_amount[]')) {
                recalcTotal();
            }
        });
        linesWrap.addEventListener('click', function (e) {
            const btn = e.target.closest && e.target.closest('.js-remove-line');
            if (!btn) return;
            const row = btn.closest('.invoice-line');
            if (row) row.remove();
            if (!linesWrap.querySelector('.invoice-line')) {
                addLine();
            }
            recalcTotal();
        });
        if (currencySelect) {
            currencySelect.addEventListener('change', recalcTotal);
        }
        addLine();
    }
})();
</script>

<?php require_once __DIR__ . '/../../includes/footer.php'; ?>
