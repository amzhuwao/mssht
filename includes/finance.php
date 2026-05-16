<?php
/**
 * Finance ERP helpers - MSSHT
 */

function getFinanceDashboardStats(): array
{
    $db = getDB();
    $stats = [
        'revenue_mtd'      => 0.0,
        'outstanding'      => 0.0,
        'overdue_count'    => 0,
        'debtors'          => 0,
        'payables_due'     => 0.0,
        'active_holds'     => 0,
        'pending_payments' => 0,
    ];
    try {
        $stats['revenue_mtd'] = (float) $db->query(
            "SELECT COALESCE(SUM(amount),0) FROM payments WHERE status = 'confirmed' AND MONTH(paid_at) = MONTH(CURDATE()) AND YEAR(paid_at) = YEAR(CURDATE())"
        )->fetchColumn();
        $stats['outstanding'] = (float) $db->query(
            "SELECT COALESCE(SUM(total_amount - amount_paid),0) FROM invoices WHERE status IN ('pending','partial','overdue')"
        )->fetchColumn();
        $stats['overdue_count'] = (int) $db->query(
            "SELECT COUNT(*) FROM invoices WHERE status IN ('pending','partial','overdue') AND due_date < CURDATE()"
        )->fetchColumn();
        $stats['debtors'] = (int) $db->query(
            "SELECT COUNT(DISTINCT student_id) FROM invoices WHERE status IN ('pending','partial','overdue') AND (total_amount - amount_paid) > 0"
        )->fetchColumn();
        $stats['payables_due'] = (float) $db->query(
            "SELECT COALESCE(SUM(amount - amount_paid),0) FROM payables WHERE status IN ('pending','partial')"
        )->fetchColumn();
        $stats['active_holds'] = (int) $db->query('SELECT COUNT(*) FROM finance_holds WHERE is_active = 1')->fetchColumn();
        $stats['pending_payments'] = (int) $db->query("SELECT COUNT(*) FROM payments WHERE status = 'pending'")->fetchColumn();
    } catch (Exception $e) {
        // Tables may not exist yet
    }
    return $stats;
}

function getStudentFinanceSummary(int $studentId): array
{
    $db = getDB();
    $stmt = $db->prepare(
        "SELECT COALESCE(SUM(total_amount),0) AS billed,
                COALESCE(SUM(amount_paid),0) AS paid,
                COALESCE(SUM(total_amount - amount_paid),0) AS balance
         FROM invoices WHERE student_id = ? AND status NOT IN ('cancelled')"
    );
    $stmt->execute([$studentId]);
    return $stmt->fetch() ?: ['billed' => 0, 'paid' => 0, 'balance' => 0];
}

function studentHasFinanceHold(int $studentId, ?string $holdType = null): bool
{
    $db = getDB();
    $sql = 'SELECT 1 FROM finance_holds WHERE student_id = ? AND is_active = 1';
    $params = [$studentId];
    if ($holdType) {
        $sql .= ' AND hold_type = ?';
        $params[] = $holdType;
    }
    $sql .= ' LIMIT 1';
    $stmt = $db->prepare($sql);
    $stmt->execute($params);
    return (bool) $stmt->fetchColumn();
}

function applyAutoFinanceHolds(): int
{
    $db = getDB();
    $stmt = $db->query(
        "SELECT s.id AS student_id, SUM(i.total_amount - i.amount_paid) AS balance
         FROM students s
         JOIN invoices i ON i.student_id = s.id
         WHERE s.enrollment_status = 'active'
           AND i.status IN ('pending','partial','overdue')
           AND i.due_date < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
         GROUP BY s.id
         HAVING balance > 0"
    );
    $count = 0;
    while ($row = $stmt->fetch()) {
        if (!studentHasFinanceHold((int) $row['student_id'], 'exams')) {
            $db->prepare(
                'INSERT INTO finance_holds (student_id, hold_type, reason, auto_generated, created_by)
                 VALUES (?, ?, ?, 1, NULL)'
            )->execute([
                (int) $row['student_id'],
                'exams',
                'Outstanding balance overdue 30+ days (auto)',
            ]);
            $count++;
        }
    }
    return $count;
}

function billingModelForProgram(string $programType): string
{
    return match ($programType) {
        'short_course' => 'once_off',
        'certificate'  => 'per_module',
        default        => 'per_semester',
    };
}

function getExchangeRate(string $from, string $to, ?string $date = null): float
{
    if ($from === $to) {
        return 1.0;
    }
    $db = getDB();
    $date = $date ?? date('Y-m-d');
    $stmt = $db->prepare(
        'SELECT rate FROM exchange_rates WHERE from_currency = ? AND to_currency = ? AND rate_date <= ? ORDER BY rate_date DESC LIMIT 1'
    );
    $stmt->execute([$from, $to, $date]);
    $rate = $stmt->fetchColumn();
    return $rate ? (float) $rate : 1.0;
}

function createInvoice(array $data, array $lines = []): int
{
    $db = getDB();
    $invNum = generateRef('INV');
    $total = (float) ($data['total_amount'] ?? 0);
    if ($lines) {
        $total = 0;
        foreach ($lines as $line) {
            $total += (float) $line['line_total'];
        }
    }
    $db->prepare(
        'INSERT INTO invoices (invoice_number, student_id, fee_structure_id, sponsor_id, total_amount, currency, invoice_type, due_date, notes, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    )->execute([
        $invNum,
        (int) $data['student_id'],
        $data['fee_structure_id'] ?? null,
        $data['sponsor_id'] ?? null,
        $total,
        $data['currency'] ?? 'USD',
        $data['invoice_type'] ?? 'invoice',
        $data['due_date'],
        $data['notes'] ?? null,
        'pending',
    ]);
    $invoiceId = (int) $db->lastInsertId();
    foreach ($lines as $line) {
        $db->prepare(
            'INSERT INTO invoice_lines (invoice_id, description, quantity, unit_amount, line_total, fee_type)
             VALUES (?, ?, ?, ?, ?, ?)'
        )->execute([
            $invoiceId,
            $line['description'],
            $line['quantity'] ?? 1,
            $line['unit_amount'],
            $line['line_total'],
            $line['fee_type'] ?? null,
        ]);
    }
    postInvoiceToLedger($invoiceId);
    auditLog('invoice_created', 'invoice', $invoiceId);
    return $invoiceId;
}

function bulkInvoiceIntake(int $intakeId, int $feeStructureId, string $dueDate): array
{
    $db = getDB();
    $fee = $db->prepare('SELECT * FROM fee_structures WHERE id = ? AND is_active = 1');
    $fee->execute([$feeStructureId]);
    $fee = $fee->fetch();
    if (!$fee) {
        return ['created' => 0, 'error' => 'Fee structure not found'];
    }
    $students = $db->prepare(
        "SELECT id FROM students WHERE intake_id = ? AND enrollment_status = 'active' AND program_id = ?"
    );
    $students->execute([$intakeId, $fee['program_id']]);
    $created = 0;
    while ($s = $students->fetch()) {
        createInvoice([
            'student_id'       => (int) $s['id'],
            'fee_structure_id' => $feeStructureId,
            'total_amount'     => (float) $fee['amount'],
            'currency'         => $fee['currency'] ?? 'USD',
            'due_date'         => $dueDate,
            'notes'            => $fee['description'],
        ], [[
            'description' => $fee['description'],
            'quantity'    => 1,
            'unit_amount' => (float) $fee['amount'],
            'line_total'  => (float) $fee['amount'],
            'fee_type'    => $fee['fee_type'] ?? 'tuition',
        ]]);
        $created++;
    }
    return ['created' => $created];
}

function recordPayment(int $invoiceId, array $data): int
{
    $db = getDB();
    $inv = $db->prepare('SELECT * FROM invoices WHERE id = ?');
    $inv->execute([$invoiceId]);
    $inv = $inv->fetch();
    if (!$inv) {
        throw new InvalidArgumentException('Invoice not found');
    }

    $amount = (float) $data['amount'];
    $receipt = generateRef('RCP');
    $status = $data['status'] ?? (($data['pop_file'] ?? '') ? 'pending' : 'confirmed');

    $db->prepare(
        'INSERT INTO payments (receipt_number, invoice_id, amount, currency, exchange_rate, payment_method, reference, pop_file, status, received_by, sponsor_id)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    )->execute([
        $receipt,
        $invoiceId,
        $amount,
        $data['currency'] ?? $inv['currency'] ?? 'USD',
        $data['exchange_rate'] ?? 1,
        $data['payment_method'],
        $data['reference'] ?? null,
        $data['pop_file'] ?? null,
        $status,
        $_SESSION['user_id'] ?? null,
        $data['sponsor_id'] ?? null,
    ]);
    $paymentId = (int) $db->lastInsertId();

    if ($status === 'confirmed') {
        finalizePayment($invoiceId, $amount);
        postPaymentToLedger($paymentId, $invoiceId, $amount);
    }
    auditLog('payment_recorded', 'payment', $paymentId);
    return $paymentId;
}

function confirmPayment(int $paymentId): void
{
    $db = getDB();
    $p = $db->prepare('SELECT * FROM payments WHERE id = ?');
    $p->execute([$paymentId]);
    $p = $p->fetch();
    if (!$p || $p['status'] !== 'pending') {
        return;
    }
    $db->prepare("UPDATE payments SET status = 'confirmed' WHERE id = ?")->execute([$paymentId]);
    finalizePayment((int) $p['invoice_id'], (float) $p['amount']);
    postPaymentToLedger($paymentId, (int) $p['invoice_id'], (float) $p['amount']);
}

function finalizePayment(int $invoiceId, float $amount): void
{
    $db = getDB();
    $inv = $db->prepare('SELECT * FROM invoices WHERE id = ?');
    $inv->execute([$invoiceId]);
    $inv = $inv->fetch();
    if (!$inv) {
        return;
    }
    $newPaid = (float) $inv['amount_paid'] + $amount;
    $balance = (float) $inv['total_amount'] - $newPaid;
    $status = $balance <= 0.01 ? 'paid' : 'partial';
    if ($balance > 0.01 && $inv['due_date'] < date('Y-m-d')) {
        $status = 'overdue';
    }
    $db->prepare('UPDATE invoices SET amount_paid = ?, status = ? WHERE id = ?')->execute([$newPaid, $status, $invoiceId]);
    if ($status === 'paid') {
        liftAutoHoldsForStudent((int) $inv['student_id']);
    }
}

function liftAutoHoldsForStudent(int $studentId): void
{
    $db = getDB();
    $summary = getStudentFinanceSummary($studentId);
    if ((float) $summary['balance'] <= 0.01) {
        $db->prepare(
            'UPDATE finance_holds SET is_active = 0, lifted_at = NOW(), lifted_by = ? WHERE student_id = ? AND auto_generated = 1 AND is_active = 1'
        )->execute([$_SESSION['user_id'] ?? null, $studentId]);
    }
}

function postInvoiceToLedger(int $invoiceId): void
{
    $db = getDB();
    $inv = $db->prepare('SELECT total_amount, invoice_number FROM invoices WHERE id = ?');
    $inv->execute([$invoiceId]);
    $inv = $inv->fetch();
    if (!$inv) {
        return;
    }
    $ar = getAccountIdByCode('1100');
    $rev = getAccountIdByCode('4000');
    if (!$ar || !$rev) {
        return;
    }
    createJournalEntry([
        'description' => 'Invoice ' . $inv['invoice_number'],
        'source_type' => 'invoice',
        'source_id'   => $invoiceId,
        'lines'       => [
            ['account_id' => $ar, 'debit' => (float) $inv['total_amount'], 'credit' => 0],
            ['account_id' => $rev, 'debit' => 0, 'credit' => (float) $inv['total_amount']],
        ],
    ]);
}

function postPaymentToLedger(int $paymentId, int $invoiceId, float $amount): void
{
    $cash = getAccountIdByCode('1000');
    $ar = getAccountIdByCode('1100');
    if (!$cash || !$ar) {
        return;
    }
    createJournalEntry([
        'description' => 'Payment receipt #' . $paymentId,
        'source_type' => 'payment',
        'source_id'   => $paymentId,
        'lines'       => [
            ['account_id' => $cash, 'debit' => $amount, 'credit' => 0],
            ['account_id' => $ar, 'debit' => 0, 'credit' => $amount],
        ],
    ]);
}

function getAccountIdByCode(string $code): ?int
{
    $db = getDB();
    $stmt = $db->prepare('SELECT id FROM chart_of_accounts WHERE code = ?');
    $stmt->execute([$code]);
    $id = $stmt->fetchColumn();
    return $id ? (int) $id : null;
}

function createJournalEntry(array $data): int
{
    $db = getDB();
    $entryNum = generateRef('JE');
    $db->prepare(
        'INSERT INTO journal_entries (entry_number, entry_date, description, source_type, source_id, created_by)
         VALUES (?, CURDATE(), ?, ?, ?, ?)'
    )->execute([
        $entryNum,
        $data['description'],
        $data['source_type'] ?? null,
        $data['source_id'] ?? null,
        $_SESSION['user_id'] ?? null,
    ]);
    $jid = (int) $db->lastInsertId();
    foreach ($data['lines'] as $line) {
        $db->prepare(
            'INSERT INTO journal_lines (journal_id, account_id, debit, credit, memo) VALUES (?, ?, ?, ?, ?)'
        )->execute([
            $jid,
            (int) $line['account_id'],
            (float) ($line['debit'] ?? 0),
            (float) ($line['credit'] ?? 0),
            $line['memo'] ?? null,
        ]);
    }
    return $jid;
}

function getAgingReport(): array
{
    $db = getDB();
    return $db->query(
        "SELECT s.id AS student_id, s.student_number,
                CONCAT(COALESCE(a.first_name,up.first_name),' ',COALESCE(a.last_name,up.last_name)) AS name,
                SUM(CASE WHEN DATEDIFF(CURDATE(), i.due_date) BETWEEN 0 AND 30 THEN i.total_amount - i.amount_paid ELSE 0 END) AS bucket_30,
                SUM(CASE WHEN DATEDIFF(CURDATE(), i.due_date) BETWEEN 31 AND 60 THEN i.total_amount - i.amount_paid ELSE 0 END) AS bucket_60,
                SUM(CASE WHEN DATEDIFF(CURDATE(), i.due_date) BETWEEN 61 AND 90 THEN i.total_amount - i.amount_paid ELSE 0 END) AS bucket_90,
                SUM(CASE WHEN DATEDIFF(CURDATE(), i.due_date) > 90 THEN i.total_amount - i.amount_paid ELSE 0 END) AS bucket_120,
                SUM(i.total_amount - i.amount_paid) AS total_due
         FROM invoices i
         JOIN students s ON s.id = i.student_id
         LEFT JOIN applications a ON a.id = s.application_id
         LEFT JOIN users u ON u.id = s.user_id
         LEFT JOIN user_profiles up ON up.user_id = u.id
         WHERE i.status IN ('pending','partial','overdue') AND (i.total_amount - i.amount_paid) > 0
         GROUP BY s.id, s.student_number, name
         ORDER BY total_due DESC"
    )->fetchAll();
}

function sendPaymentReminder(int $studentId): bool
{
    $db = getDB();
    $stmt = $db->prepare(
        'SELECT u.email, up.first_name, up.last_name, s.student_number
         FROM students s
         LEFT JOIN users u ON u.id = s.user_id
         LEFT JOIN user_profiles up ON up.user_id = u.id
         LEFT JOIN applications a ON a.id = s.application_id
         WHERE s.id = ?'
    );
    $stmt->execute([$studentId]);
    $student = $stmt->fetch();
    $email = $student['email'] ?? null;
    if (!$email) {
        $a = $db->prepare('SELECT email, first_name, last_name FROM applications WHERE id = (SELECT application_id FROM students WHERE id = ?)');
        $a->execute([$studentId]);
        $app = $a->fetch();
        $email = $app['email'] ?? null;
    }
    if (!$email) {
        return false;
    }
    $summary = getStudentFinanceSummary($studentId);
    $name = trim(($student['first_name'] ?? '') . ' ' . ($student['last_name'] ?? '')) ?: $student['student_number'];
    $html = '<h2>Payment Reminder</h2><p>Hello ' . e($name) . ',</p>'
        . '<p>Your outstanding balance is <strong>' . formatMoney((float) $summary['balance']) . '</strong>.</p>'
        . '<p>Please log in to the student portal to view invoices and make payment.</p>'
        . '<p><a href="' . e(url('student-login.php')) . '">Student Portal</a></p>';
    return sendEmail($email, APP_NAME . ' - Payment Reminder', $html);
}

function getTrialBalance(): array
{
    $db = getDB();
    return $db->query(
        'SELECT c.code, c.name, c.account_type,
                COALESCE(SUM(jl.debit),0) AS total_debit,
                COALESCE(SUM(jl.credit),0) AS total_credit
         FROM chart_of_accounts c
         LEFT JOIN journal_lines jl ON jl.account_id = c.id
         LEFT JOIN journal_entries je ON je.id = jl.journal_id
         GROUP BY c.id, c.code, c.name, c.account_type
         ORDER BY c.code'
    )->fetchAll();
}

function handlePopUpload(string $field): ?string
{
    if (empty($_FILES[$field]['name']) || $_FILES[$field]['error'] !== UPLOAD_ERR_OK) {
        return null;
    }
    $ext = strtolower(pathinfo($_FILES[$field]['name'], PATHINFO_EXTENSION));
    if (!in_array($ext, ['pdf', 'jpg', 'jpeg', 'png'], true)) {
        return null;
    }
    $dir = UPLOAD_PATH . '/payments';
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
    $name = 'pop_' . date('Ymd') . '_' . bin2hex(random_bytes(6)) . '.' . $ext;
    $path = $dir . '/' . $name;
    if (move_uploaded_file($_FILES[$field]['tmp_name'], $path)) {
        return 'payments/' . $name;
    }
    return null;
}

function buildInvoicePdfHtml(array $invoice, array $lines): string
{
    $currency = $invoice['currency'] ?? 'USD';
    $rows = [];
    foreach ($lines as $line) {
        $rows[] = [
            'Description' => $line['description'],
            'Qty'         => $line['quantity'],
            'Unit'        => formatMoney((float) $line['unit_amount'], $currency),
            'Total'       => formatMoney((float) $line['line_total'], $currency),
        ];
    }
    $balance = (float) $invoice['total_amount'] - (float) $invoice['amount_paid'];
    $rows[] = ['Description' => 'BALANCE DUE', 'Qty' => '', 'Unit' => '', 'Total' => formatMoney($balance, $currency)];
    return buildGradesReportHtml(
        ['Invoice' => $invoice['invoice_number'], 'Student' => $invoice['student_number'], 'Due' => formatDate($invoice['due_date'])],
        $rows,
        'Student Invoice'
    );
}
