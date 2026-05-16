USE mssht_db;

-- Extend fee structures
ALTER TABLE fee_structures
    ADD COLUMN fee_type ENUM('tuition','registration','examination','graduation','practical','accommodation','library','penalty','other') DEFAULT 'tuition' AFTER description,
    ADD COLUMN billing_model ENUM('once_off','per_module','per_semester','corporate_group') DEFAULT 'per_semester' AFTER fee_type,
    ADD COLUMN currency ENUM('USD','ZWL') DEFAULT 'USD' AFTER amount,
    ADD COLUMN semester TINYINT UNSIGNED NULL AFTER currency,
    ADD COLUMN is_active TINYINT(1) DEFAULT 1 AFTER allow_installments;

-- Extend invoices
ALTER TABLE invoices
    ADD COLUMN currency ENUM('USD','ZWL') DEFAULT 'USD' AFTER total_amount,
    ADD COLUMN invoice_type ENUM('invoice','credit_note','debit_note') DEFAULT 'invoice' AFTER currency,
    ADD COLUMN fee_structure_id INT UNSIGNED NULL AFTER student_id,
    ADD COLUMN sponsor_id INT UNSIGNED NULL AFTER fee_structure_id,
    ADD COLUMN notes TEXT NULL AFTER due_date,
    ADD INDEX idx_inv_status_due (status, due_date);

CREATE TABLE IF NOT EXISTS invoice_lines (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT UNSIGNED NOT NULL,
    description VARCHAR(200) NOT NULL,
    quantity DECIMAL(8,2) DEFAULT 1,
    unit_amount DECIMAL(12,2) NOT NULL,
    line_total DECIMAL(12,2) NOT NULL,
    fee_type VARCHAR(40) NULL,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS installment_plans (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    invoice_id INT UNSIGNED NULL,
    title VARCHAR(150) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    down_payment DECIMAL(12,2) DEFAULT 0,
    currency ENUM('USD','ZWL') DEFAULT 'USD',
    status ENUM('pending','approved','active','completed','cancelled') DEFAULT 'pending',
    created_by INT UNSIGNED NULL,
    approved_by INT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS installment_schedule (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    plan_id INT UNSIGNED NOT NULL,
    due_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    amount_paid DECIMAL(12,2) DEFAULT 0,
    status ENUM('pending','partial','paid','overdue') DEFAULT 'pending',
    FOREIGN KEY (plan_id) REFERENCES installment_plans(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS fee_rules (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    rule_type ENUM('international','returning','early_payment','custom') NOT NULL,
    program_id INT UNSIGNED NULL,
    fee_type VARCHAR(40) NULL,
    adjustment_type ENUM('percent','fixed') DEFAULT 'percent',
    adjustment_value DECIMAL(10,2) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Extend payments
ALTER TABLE payments
    ADD COLUMN receipt_number VARCHAR(30) NULL UNIQUE AFTER id,
    ADD COLUMN currency ENUM('USD','ZWL') DEFAULT 'USD' AFTER amount,
    ADD COLUMN exchange_rate DECIMAL(12,4) DEFAULT 1 AFTER currency,
    ADD COLUMN pop_file VARCHAR(255) NULL AFTER reference,
    ADD COLUMN status ENUM('pending','confirmed','rejected') DEFAULT 'confirmed' AFTER pop_file,
    ADD COLUMN sponsor_id INT UNSIGNED NULL AFTER received_by;

ALTER TABLE payments MODIFY payment_method ENUM('cash','bank','mobile','gateway','pos','card') NOT NULL;

CREATE TABLE IF NOT EXISTS finance_holds (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    hold_type ENUM('exams','registration','results','graduation','general') NOT NULL,
    reason VARCHAR(255) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    auto_generated TINYINT(1) DEFAULT 0,
    created_by INT UNSIGNED NULL,
    lifted_by INT UNSIGNED NULL,
    lifted_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS finance_sponsors (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    sponsor_type ENUM('ngo','government','corporate','other') DEFAULT 'corporate',
    email VARCHAR(150) NULL,
    phone VARCHAR(30) NULL,
    billing_terms TEXT NULL,
    credit_limit DECIMAL(14,2) DEFAULT 0,
    currency ENUM('USD','ZWL') DEFAULT 'USD',
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sponsor_students (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sponsor_id INT UNSIGNED NOT NULL,
    student_id INT UNSIGNED NOT NULL,
    coverage_percent DECIMAL(5,2) DEFAULT 100,
    UNIQUE KEY uk_sponsor_student (sponsor_id, student_id),
    FOREIGN KEY (sponsor_id) REFERENCES finance_sponsors(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS suppliers (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(120) NULL,
    email VARCHAR(150) NULL,
    phone VARCHAR(30) NULL,
    tax_number VARCHAR(50) NULL,
    bank_name VARCHAR(100) NULL,
    bank_account VARCHAR(80) NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS expense_categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    parent_id INT UNSIGNED NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payables (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bill_number VARCHAR(30) NOT NULL UNIQUE,
    supplier_id INT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NULL,
    description VARCHAR(255) NOT NULL,
    amount DECIMAL(14,2) NOT NULL,
    amount_paid DECIMAL(14,2) DEFAULT 0,
    currency ENUM('USD','ZWL') DEFAULT 'USD',
    due_date DATE NOT NULL,
    status ENUM('pending','partial','paid','cancelled') DEFAULT 'pending',
    created_by INT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (category_id) REFERENCES expense_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payable_payments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payable_id INT UNSIGNED NOT NULL,
    amount DECIMAL(14,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    reference VARCHAR(100) NULL,
    paid_by INT UNSIGNED NULL,
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payable_id) REFERENCES payables(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS chart_of_accounts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    account_type ENUM('asset','liability','equity','revenue','expense') NOT NULL,
    parent_id INT UNSIGNED NULL,
    is_active TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS financial_periods (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_closed TINYINT(1) DEFAULT 0,
    closed_at DATETIME NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS journal_entries (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    entry_number VARCHAR(30) NOT NULL UNIQUE,
    entry_date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    period_id INT UNSIGNED NULL,
    source_type VARCHAR(40) NULL,
    source_id INT UNSIGNED NULL,
    created_by INT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (period_id) REFERENCES financial_periods(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS journal_lines (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    journal_id INT UNSIGNED NOT NULL,
    account_id INT UNSIGNED NOT NULL,
    debit DECIMAL(14,2) DEFAULT 0,
    credit DECIMAL(14,2) DEFAULT 0,
    memo VARCHAR(200) NULL,
    FOREIGN KEY (journal_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS budgets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    department VARCHAR(100) NOT NULL,
    fiscal_year VARCHAR(20) NOT NULL,
    budget_type ENUM('operational','capital') DEFAULT 'operational',
    total_amount DECIMAL(14,2) NOT NULL,
    spent_amount DECIMAL(14,2) DEFAULT 0,
    status ENUM('draft','approved','closed') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_requisitions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    req_number VARCHAR(30) NOT NULL UNIQUE,
    department VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    estimated_total DECIMAL(14,2) NOT NULL,
    status ENUM('draft','hod_approved','finance_approved','procurement_approved','rejected','ordered') DEFAULT 'draft',
    requested_by INT UNSIGNED NULL,
    hod_approved_by INT UNSIGNED NULL,
    finance_approved_by INT UNSIGNED NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_orders (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    po_number VARCHAR(30) NOT NULL UNIQUE,
    requisition_id INT UNSIGNED NULL,
    supplier_id INT UNSIGNED NOT NULL,
    total_amount DECIMAL(14,2) NOT NULL,
    status ENUM('draft','sent','partial','received','cancelled') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (requisition_id) REFERENCES purchase_requisitions(id) ON DELETE SET NULL,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS goods_receipts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    po_id INT UNSIGNED NOT NULL,
    received_date DATE NOT NULL,
    notes TEXT NULL,
    received_by INT UNSIGNED NULL,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS assets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    asset_tag VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    category ENUM('computer','vehicle','furniture','lab','other') DEFAULT 'other',
    purchase_date DATE NULL,
    purchase_cost DECIMAL(14,2) DEFAULT 0,
    location VARCHAR(120) NULL,
    status ENUM('active','disposed','maintenance') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS bank_accounts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    account_number VARCHAR(50) NOT NULL,
    currency ENUM('USD','ZWL') DEFAULT 'USD',
    opening_balance DECIMAL(14,2) DEFAULT 0,
    current_balance DECIMAL(14,2) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS bank_transactions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    bank_account_id INT UNSIGNED NOT NULL,
    txn_date DATE NOT NULL,
    description VARCHAR(255) NOT NULL,
    reference VARCHAR(100) NULL,
    amount DECIMAL(14,2) NOT NULL,
    txn_type ENUM('credit','debit') NOT NULL,
    matched_payment_id INT UNSIGNED NULL,
    is_reconciled TINYINT(1) DEFAULT 0,
    FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id) ON DELETE CASCADE,
    FOREIGN KEY (matched_payment_id) REFERENCES payments(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS exchange_rates (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    from_currency ENUM('USD','ZWL') NOT NULL,
    to_currency ENUM('USD','ZWL') NOT NULL,
    rate DECIMAL(12,6) NOT NULL,
    rate_date DATE NOT NULL,
    UNIQUE KEY uk_rate_date (from_currency, to_currency, rate_date)
) ENGINE=InnoDB;

-- Seed chart of accounts
INSERT IGNORE INTO chart_of_accounts (code, name, account_type) VALUES
('1000', 'Cash & Bank', 'asset'),
('1100', 'Accounts Receivable', 'asset'),
('2000', 'Accounts Payable', 'liability'),
('3000', 'Equity', 'equity'),
('4000', 'Tuition Revenue', 'revenue'),
('4100', 'Other Revenue', 'revenue'),
('5000', 'Operating Expenses', 'expense'),
('5100', 'Payroll Expenses', 'expense');

INSERT IGNORE INTO expense_categories (code, name) VALUES
('UTIL', 'Utilities'),
('IT', 'Internet & IT'),
('CAT', 'Catering'),
('MAINT', 'Maintenance');
