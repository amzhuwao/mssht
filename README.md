# MSSHT — School Management System

**Manica Skyview School of Hospitality and Tourism (MSSHT)** — a web-based school management platform for admissions, student records, virtual classrooms, finance, and guardian communication.

Built for **XAMPP** (Apache + MySQL + PHP) with a classic PHP architecture (no full-stack framework).

---

## Tech stack

| Layer | Technology |
|--------|------------|
| Backend | PHP 8.0+ |
| Database | MySQL / MariaDB |
| Frontend | HTML5, CSS3, jQuery |
| PDF export | [Dompdf](https://github.com/dompdf/dompdf) (Composer) |
| Server | Apache (XAMPP) |

---

## Requirements

- PHP 8.0 or higher (extensions: `pdo_mysql`, `mbstring`, `openssl`, `gd` recommended)
- MySQL 5.7+ or MariaDB 10.3+
- Apache with `mod_rewrite` optional
- [Composer](https://getcomposer.org/) (for PDF generation)
- XAMPP or equivalent LAMP/WAMP stack

---

## Quick start (local / XAMPP)

### 1. Clone or copy the project

Place the project under your web root, for example:

```
C:\xampp\htdocs\mssht
```

### 2. Configure the database

Edit `config/database.php` if needed (defaults match XAMPP):

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'mssht_db');
define('DB_USER', 'root');
define('DB_PASS', '');
```

### 3. Set the application URL

Edit `config/app.php` or set the `APP_URL` environment variable. Example:

```
define('APP_URL', 'http(s)://your-host/mssht');
```

Use your actual host/path if different.

### 4. Install PHP dependencies

From the project root:

```bash
composer install
```

This installs Dompdf for invoice and grade PDF exports.

### 5. Create the database

**Option A — Web installer (recommended for first install)**

1. Start Apache and MySQL in XAMPP.
2. Open [install.php](install.php)
3. Click **Install Database** (runs `database/schema.sql` and resets the admin password).

**Option B — Command line**

```bash
php tools/install-cli.php
```

### 6. Run migrations

After the base schema is installed, apply incremental migrations in order:

```bash
php tools/run-migration-002.php
php tools/install-migration-003.php
php tools/install-migration-004.php
php tools/install-migration-005.php
```

| Migration | Purpose |
|-----------|---------|
| `001_student_portal.sql` | Included in base schema / student portal fields |
| `002_classroom_lms.sql` | Virtual classes, assignments, stream, calendar |
| `003_guardians_rubrics_mail.sql` | Guardians, rubrics, mail-related columns |
| `004_app_settings.sql` | Database-backed mail/SMTP settings |
| `005_finance_erp.sql` | Full finance ERP tables and extensions |

### 7. Log in

| Portal | URL | Default credentials |
|--------|-----|---------------------|
| **Staff** | [login.php](login.php) | `admin@mssht.ac.zw` / `Admin@123` |
| **Students** | [student-login.php](student-login.php) | Created on admission approval (see below) |
| **Public site** | [index.php](index.php) | — |

**Change the admin password immediately** after first login.

---

## Student portal accounts

When an application is **approved**, a student record and portal user are created. The temporary password format is:

```
Mssht + last 4 digits of student number
```

Example: student number `MSSHT25001234` → temporary password `Mssht1234`

Students must change this password on first login (`student-activate.php`).

**Manual portal creation** (if a student has no login):

```bash
php tools/create-portal-for-student.php
```

**Diagnose login issues:**

```bash
php tools/check-student-login.php
```

---

## Configuration

### Mail (password reset, guardian summaries, reminders)

Configure via **System Settings → Email / SMTP** (super admin), or defaults in `config/mail.defaults.php`.

Settings are stored in the `app_settings` table after migration 004.

For local development without SMTP, enable **fallback reset link on screen** in settings (or set `APP_DEBUG` to `true` in `config/app.php`).

### Uploads

Uploaded files are stored under `uploads/` (applications, assignments, proof-of-payment, etc.). The app creates subfolders on bootstrap. Ensure the web server can write to `uploads/`.

### Database backup and restore

Super admins can manage backups from **System Settings → Backup & Restore**. Backups are written as `.sql` files in `backups/`.

CLI helpers are also available:

```bash
php tools/backup-database.php --name=manual-backup.sql
php tools/restore-database.php backups/manual-backup.sql
php tools/clear-seed-data.php
```

The restore command replaces the current application tables with the backup contents.
The seed cleanup command removes the demo records so you can start capturing real data without reinstalling the schema.

### Production checklist

- Set `APP_DEBUG` to `false` in `config/app.php`
- Use strong passwords; remove or protect `install.php`
- Configure HTTPS and update `APP_URL`
- Set up real SMTP in System Settings
- Restrict access to `tools/` scripts

---

## User roles

| Role | Typical access |
|------|----------------|
| Super Admin | Full system + settings + mail |
| Registrar | Admissions, programs, students, classes, exams |
| Finance | Finance ERP, students (billing), reports |
| Lecturer | Classes, LMS, attendance, exams |
| Student | Portal: classes, fees, results, notifications |
| HOD | Programs, students, classes, reports |
| Librarian | Library module |
| External Examiner | Exams module |

Module visibility is defined in `config/app.php` → `ROLE_MODULES`.

---

## Main features

### Core SMS

- Admissions (online apply, review, approve → student record)
- Programs, modules, intakes
- Student Information System (SIS)
- User management and audit logging
- Timetable, HR, library, placements, messages, graduation (foundation UI)

### Classroom / LMS

- Virtual classes (join codes, members)
- Stream (announcements, materials, comments)
- Assignments and submissions
- Rubric-based grading
- Class calendar and in-app notifications
- Grade PDF export

### Guardian & communication

- Guardian profiles linked to students
- Email progress summaries with token-based [guardian portal](guardian-portal.php)
- Bulk summaries by intake

### Finance ERP

Submodules under **Finance** (see `mssht-desc3.txt`):

- Fee structures (tuition, registration, per-semester / per-module / once-off)
- Invoicing and bulk intake billing
- Payments (cash, bank, EcoCash/mobile, POS) + proof-of-payment upload
- Accounts receivable (aging, reminders, financial holds)
- Accounts payable (suppliers, bills)
- General ledger (chart of accounts, journals, trial balance)
- Budgets, procurement, assets
- Corporate/sponsor billing
- Banking & reconciliation, USD/ZWL exchange rates
- Financial reports and CSV export

### Student finance portal

- View invoices and balance
- Download invoice PDF
- Upload proof of payment
- Request installment plans
- Results may be blocked when a **results** financial hold is active

---

## Project structure

```
mssht/
├── assets/              # CSS, JS, images
├── config/              # app.php, database.php, mail defaults
├── database/
│   ├── schema.sql       # Base install
│   └── migrations/      # 002–005 incremental SQL
├── includes/            # bootstrap, auth, finance, classroom, mail, PDF
├── modules/             # Feature modules (admissions, finance, classes, …)
├── tools/               # CLI installers, migrations, utilities
├── uploads/             # User uploads (not in git by default)
├── vendor/              # Composer (Dompdf)
├── index.php            # Public landing page
├── login.php            # Staff login
├── student-login.php    # Student portal login
├── install.php          # Web database installer
└── guardian-portal.php  # Token-based guardian view
```

---

## Useful URLs

| Path | Description |
|------|-------------|
| `/` | Public website |
| `/login.php` | Staff login |
| `/forgot-password.php` | Staff password reset |
| `/student-login.php` | Student portal |
| `/student-forgot-password.php` | Student password reset |
| `/dashboard.php` | Role-based dashboard |
| `/modules/finance/` | Finance ERP hub |
| `/modules/classes/` | Virtual classes |
| `/modules/guardians/bulk-send.php` | Bulk guardian emails by intake |

---

## CLI tools

| Script | Purpose |
|--------|---------|
| `tools/install-cli.php` | Install base schema from command line |
| `tools/install-migration-003.php` | Guardians & rubrics migration |
| `tools/install-migration-004.php` | App settings (mail UI) |
| `tools/install-migration-005.php` | Finance ERP migration |
| `tools/install-migration-009.php` | Unique student/application enrollment constraint |
| `tools/run-migration-002.php` | Classroom/LMS migration |
| `tools/create-portal-for-student.php` | Create student portal account |
| `tools/check-student-login.php` | Debug student login |
| `tools/fix-html.php` | Fix accidental invalid HTML tag typos in templates |

---

## Troubleshooting

**Blank page or 500 error**  
Enable errors temporarily via `APP_DEBUG` in `config/app.php`. Check Apache `error.log` and PHP version ≥ 8.0.

**Database connection failed**  
Confirm MySQL is running and credentials in `config/database.php` match your environment.

**PDF download shows HTML instead of PDF**  
Run `composer install` in the project root so Dompdf is available under `vendor/`.

**Emails not sending**  
Configure SMTP under **System Settings**, or use the on-screen fallback link for password reset in development.

**Student cannot log in**  
Ensure the student has a `user_id` (approve application or run `tools/create-portal-for-student.php`).

---

## License

Proprietary — Manica Skyview School of Hospitality and Tourism. All rights reserved unless otherwise agreed.

---

## Version

Application version: **1.0.0** (`config/app.php`)

For detailed finance specifications, see `mssht-desc3.txt` in the repository root.
