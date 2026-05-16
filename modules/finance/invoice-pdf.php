<?php
require_once __DIR__ . '/../../includes/bootstrap.php';

$id = (int)($_GET['id'] ?? 0);
$db = getDB();
$stmt = $db->prepare('SELECT i.*, s.student_number FROM invoices i JOIN students s ON s.id = i.student_id WHERE i.id = ?');
$stmt->execute([$id]);
$invoice = $stmt->fetch();
if (!$invoice) {
    exit('Invoice not found.');
}
if (isStudentPortal()) {
    if ((int)$invoice['student_id'] !== getCurrentStudentId()) {
        exit('Access denied.');
    }
} else {
    requireModule('finance');
}
$lines = $db->prepare('SELECT * FROM invoice_lines WHERE invoice_id = ?');
$lines->execute([$id]);
$lines = $lines->fetchAll();
if (!$lines) {
    $lines = [['description' => 'Fees', 'quantity' => 1, 'unit_amount' => $invoice['total_amount'], 'line_total' => $invoice['total_amount']]];
}
$html = buildInvoicePdfHtml($invoice, $lines);
outputPdf($html, 'invoice_' . $invoice['invoice_number']);
