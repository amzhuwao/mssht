<?php
$financeSection = $financeSection ?? '';
$sections = [
    'dashboard'    => ['label' => 'Overview', 'url' => moduleUrl('finance')],
    'fees'         => ['label' => 'Fee Structures', 'url' => moduleUrl('finance', 'fee-structures')],
    'invoices'     => ['label' => 'Invoicing', 'url' => moduleUrl('finance', 'invoices')],
    'receipts'     => ['label' => 'Receipts', 'url' => moduleUrl('finance', 'receipts')],
    'receivables'  => ['label' => 'Receivables', 'url' => moduleUrl('finance', 'receivables')],
    'payables'     => ['label' => 'Payables', 'url' => moduleUrl('finance', 'payables')],
    'ledger'       => ['label' => 'General Ledger', 'url' => moduleUrl('finance', 'ledger')],
    'budgets'      => ['label' => 'Budgets', 'url' => moduleUrl('finance', 'budgets')],
    'procurement'  => ['label' => 'Procurement', 'url' => moduleUrl('finance', 'procurement')],
    'assets'       => ['label' => 'Assets', 'url' => moduleUrl('finance', 'assets')],
    'sponsors'     => ['label' => 'Sponsors', 'url' => moduleUrl('finance', 'sponsors')],
    'banking'      => ['label' => 'Banking', 'url' => moduleUrl('finance', 'banking')],
    'reports'      => ['label' => 'Reports', 'url' => moduleUrl('finance', 'reports')],
];
?>
<nav class="finance-subnav" style="display:flex;flex-wrap:wrap;gap:.35rem;margin-bottom:1.25rem;">
<?php foreach ($sections as $key => $item): ?>
    <a href="<?= $item['url'] ?>" class="btn btn-sm <?= $financeSection === $key ? 'btn-primary' : 'btn-outline' ?>"><?= e($item['label']) ?></a>
<?php endforeach; ?>
</nav>
