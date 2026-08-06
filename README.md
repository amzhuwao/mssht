# MSSHT — School Management System

**Manica Skyview School of Hospitality and Tourism (MSSHT)** is a web-based school management platform for admissions, student records, virtual classrooms, finance, reporting, and guardian communication.

Built for **XAMPP** (Apache + MySQL + PHP) with classic PHP (no full-stack framework).

---

## Architecture overview

```
Browser
  ├── Public site          (index.php, admissions apply)
  ├── Staff portal         (login.php → dashboard + modules/*)
  ├── Student / applicant  (student-login.php → student dashboard)
  └── Guardian portal      (guardian-portal.php, token link)

Apache
  └── PHP 8 + includes/bootstrap.php
        ├── Auth & roles (staff / student / applicant)
        ├── Feature modules (modules/*)
        ├── Domain services (includes/finance, classroom, mailer, pdf, reports…)
        └── MySQL (mssht_db) + uploads/ + backups/
```

**Request flow:** each staff page loads `includes/bootstrap.php`, checks session + module permission (`requireModule()`), then renders via shared header/footer. Student and applicant sessions use the same user table with `login_portal=student`. Guardians do not create accounts — they open a signed token URL.

**Permissions:** seeded defaults live in `config/app.php` (`DEFAULT_ROLE_MODULES`). After migration 008 / current schema, live permissions are stored in the `roles` table and can be edited under **Settings → Roles**. Per-user allow/deny overrides use `user_module_permissions`.

---

## Tech stack

| Layer | Technology |
|--------|------------|
| Backend | PHP 8.0+ (classic PHP, PDO) |
| Database | MySQL 5.7+ / MariaDB 10.3+ (`utf8mb4`) |
| Frontend | HTML5, CSS3, jQuery 3.7 (CDN) |
| PDF | [Dompdf](https://github.com/dompdf/dompdf) via Composer |
| Mail | Custom mailer (`mail()` or SMTP sockets) — settings in DB |
| Server | Apache (XAMPP); `.htaccess` protects `config/`, `includes/`, `database/` |

Optional: PhpSpreadsheet for XLSX student import (not required; CSV import works out of the box).

---

## Requirements

- PHP 8.0+ with `pdo_mysql`, `mbstring`, `openssl` (`gd` recommended)
- MySQL 5.7+ or MariaDB 10.3+
- Apache (XAMPP or equivalent LAMP/WAMP)
- [Composer](https://getcomposer.org/) for Dompdf

---

## Quick start (XAMPP)

### 1. Place the project

```
C:\xampp\htdocs\mssht
```

If you deploy under a different path, update `.htaccess` `RewriteBase` if you rely on rewrite rules.

### 2. Database config

`config/database.php` (XAMPP defaults):

```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'mssht_db');
define('DB_USER', 'root');
define('DB_PASS', '');
```

### 3. Application URL

`APP_URL` is auto-detected from the request host and document root. Override with an environment variable or edit `config/app.php` when needed:

```
APP_URL=http://localhost/mssht
```

### 4. Composer

```bash
composer install
```

### 5. Install the database

**Web (recommended for first install)**

1. Start Apache and MySQL in XAMPP.
2. Open `install.php`.
3. Click **Install Database** (runs `database/schema.sql` and resets the admin password).

**CLI**

```bash
php tools/install-cli.php
```

### 6. Apply feature migrations

The base schema already includes student portal fields, applicant portal link, roles, user module permissions, unique application→student link, and denormalized student profile fields (migrations 001, 006–010 content).

For a **fresh install**, still run classroom, guardians/rubrics, app settings, and finance:

```bash
php tools/run-migration-002.php
php tools/install-migration-003.php
php tools/install-migration-004.php
php tools/install-migration-005.php
```

When **upgrading an older database**, also run any missing later installers:

```bash
php tools/install-migration-009.php
php tools/install-migration-010.php
```

| Migration | Purpose |
|-----------|---------|
| `001_student_portal.sql` | Student portal / must-change-password (in base schema) |
| `002_classroom_lms.sql` | Virtual classes, assignments, stream, calendar |
| `003_guardians_rubrics_mail.sql` | Guardians, rubrics, mail-related columns |
| `004_app_settings.sql` | Database-backed mail/SMTP settings |
| `005_finance_erp.sql` | Finance ERP tables |
| `006_applicant_portal.sql` | Applicant ↔ user link (in base schema) |
| `007_user_module_permissions.sql` | Per-user module allow/deny (in base schema) |
| `008_roles.sql` | Roles table + seed (in base schema) |
| `009_unique_student_application.sql` | Unique student↔application (in base schema) |
| `010_student_profile_fields.sql` | Student profile fields on SIS records (in base schema) |

### 7. Log in

| Portal | URL | Default credentials |
|--------|-----|---------------------|
| **Staff** | `login.php` | `admin@mssht.ac.zw` / `Admin@123` |
| **Students / applicants** | `student-login.php` | Created on apply / approval (see below) |
| **Guardians** | `guardian-portal.php?token=…` | Token link from emailed summary (no password) |
| **Public site** | `index.php` | — |

**Change the admin password immediately** after first login. Set `APP_DEBUG` to `false` in production (`config/app.php`).

---

## Portals and accounts

### Staff

Email + password. Students cannot use the staff login.

### Student portal

Created when an application is approved, or manually:

```bash
php tools/create-portal-for-student.php STUDENT_NUMBER
```

Login with **student number** or email. Temporary password:

```
Mssht + last 4 digits of the student number
```

Example: `M20260065` → `Mssht0065`. Students must change this on first login (`student-activate.php`).

### Applicant portal

Submitting the public apply form creates a limited portal user (role `student`) linked to the application. Temporary password uses an `Appl…` prefix. After approval, the same person continues as a full student portal user.

### Guardian portal

No login account. Staff send progress summaries; guardians open a token URL to view a read-only summary (and downloadable grade PDF where enabled).

---

## Student numbers

Official format:

```
M + YYYY + 4-digit sequence
```

Example: `M20260065`.

Numbers are allocated sequentially per year (`generateStudentNumber()` in `includes/helpers.php`). Legacy `MSSHT…` IDs may still exist in older data; remap with:

```bash
php tools/fix-delvin-student-number.php          # dry run
php tools/fix-delvin-student-number.php --apply
```

---

## User roles

| Role | Typical access |
|------|----------------|
| Super Admin | Full system, settings, mail, backup, users |
| Registrar | Admissions, programs, intakes, students, classes, exams, reports |
| Finance | Finance ERP, students (billing), reports |
| Lecturer | Classes, LMS materials, attendance, exams, timetable |
| Student | Portal: classes, fees, results, notifications |
| HOD | Programs, students, classes, timetable, exams, reports |
| Librarian | Library |
| External Examiner | Exams |

Defaults are seeded from `config/app.php`. Runtime source of truth is the `roles` table (**Settings → Roles**), with optional per-user overrides.

---

## Main features

### Academic & SIS

- **Admissions** — public apply, document upload, review/approve → student record + portal
- **Programs / modules / intakes** — academic structure and intake linking
- **Students (SIS)** — register (with or without portal), edit/view, **filters** (search, program, intake, status, portal), **CSV download**, CSV import with preview
- **Timetable**, **attendance**, **exams** (marks + student results)
- **Reports** — enrollment / academic / admissions analytics and CSV/PDF export
- **Graduation** — certificate records with QR verification codes
- **Placements** — industrial attachment tracking

### Classroom / LMS

- **Virtual classes** (`modules/classes`) — join codes, members, stream, assignments, rubric grading, calendar, grade PDF
- **LMS materials** (`modules/lms`) — curriculum learning materials attached to program modules

### Finance ERP (`modules/finance`)

- Fee structures, invoicing, bulk intake billing
- Payments (cash, bank, mobile money, POS) + proof-of-payment upload
- Accounts receivable (aging, reminders, financial holds)
- Accounts payable, general ledger, budgets, procurement, assets
- Sponsor/corporate billing, banking & reconciliation, multi-currency rates
- Financial reports and CSV export

Student finance portal: invoices, PDF download, proof upload, installment requests; results can be blocked by a **results** hold.

### Communication

- Internal **messages** and **notifications**
- **Guardian** email summaries (single + bulk by intake) via `modules/guardians/` (requires students module access)
- Password reset mail for staff and students

### Administration

- **Users** and role/module permissions
- **HR** staff records
- **Library** catalog and borrowings
- **Settings** — SMTP/mail, roles, backup & restore
- Audit logging foundation

---

## Project structure

```
mssht/
├── assets/                 # CSS, JS, import templates
├── backups/                # SQL backups
├── config/                 # app, database, mail defaults
├── database/
│   ├── schema.sql          # Base install
│   └── migrations/         # 001–010 incremental SQL
├── includes/               # bootstrap, auth, finance, classroom, mail, PDF, reports
├── modules/                # Feature modules (see below)
├── tools/                  # CLI installers, migrations, utilities
├── uploads/                # User uploads (gitignored content)
├── vendor/                 # Composer (Dompdf)
├── index.php               # Public landing
├── login.php               # Staff login
├── student-login.php       # Student / applicant portal
├── guardian-portal.php     # Token guardian view
├── dashboard.php           # Role-based dashboard
└── install.php             # Web database installer
```

### Modules

| Folder | Purpose |
|--------|---------|
| `admissions` | Applications and approval workflow |
| `programs` / `intakes` | Academic programmes and intake periods |
| `students` | SIS, filters, CSV export/import, portal create |
| `classes` | Virtual classroom / LMS |
| `lms` | Program-module learning materials |
| `attendance` | Class attendance |
| `exams` | Assessments, marks, student results |
| `finance` | Finance ERP hub and submodules |
| `reports` | Analytics and exports |
| `guardians` | Progress summary emails (bulk + single) |
| `timetable` | Weekly timetable |
| `hr` | Staff records |
| `library` | Books and borrowings |
| `placements` | Industrial placements |
| `graduation` | Certificates |
| `messages` / `notifications` | Inbox and alerts |
| `users` | Staff user management |
| `settings` | Mail, roles, backup |

---

## Useful URLs

| Path | Description |
|------|-------------|
| `/` | Public website |
| `/login.php` | Staff login |
| `/forgot-password.php` | Staff password reset |
| `/student-login.php` | Student / applicant portal |
| `/student-forgot-password.php` | Student password reset |
| `/dashboard.php` | Role-based dashboard |
| `/modules/students/` | SIS (filters + CSV download) |
| `/modules/finance/` | Finance ERP |
| `/modules/classes/` | Virtual classes |
| `/modules/reports/` | Reporting & analytics |
| `/modules/guardians/bulk-send.php` | Bulk guardian emails by intake |
| `/modules/settings/` | System settings |

---

## Configuration notes

**Mail** — configure under **Settings → Email / SMTP**, or defaults in `config/mail.defaults.php`. Stored in `app_settings` after migration 004. For local work without SMTP, enable on-screen reset-link fallback (or `APP_DEBUG`).

**Uploads** — under `uploads/` (applications, assignments, avatars, classroom, etc.). Web server must be able to write here.

**Backups** — **Settings → Backup & Restore**, or:

```bash
php tools/backup-database.php --name=manual-backup.sql
php tools/restore-database.php backups/manual-backup.sql
php tools/clear-seed-data.php
```

### Production checklist

- Set `APP_DEBUG` to `false`
- Change default admin password; protect or remove `install.php`
- HTTPS + correct `APP_URL`
- Real SMTP settings
- Restrict web access to `tools/`

---

## CLI tools

| Script | Purpose |
|--------|---------|
| `tools/install-cli.php` | Install base schema |
| `tools/run-migration-002.php` | Classroom / LMS tables |
| `tools/install-migration-003.php` | Guardians & rubrics |
| `tools/install-migration-004.php` | App settings (mail UI) |
| `tools/install-migration-005.php` | Finance ERP |
| `tools/install-migration-009.php` | Unique application↔student (upgrades) |
| `tools/install-migration-010.php` | Student profile fields (upgrades) |
| `tools/backup-database.php` | Create SQL backup |
| `tools/restore-database.php` | Restore from SQL backup |
| `tools/clear-seed-data.php` | Remove demo/seed records |
| `tools/create-portal-for-student.php` | Create student portal account |
| `tools/check-student-login.php` | Diagnose student login |
| `tools/fix-delvin-student-number.php` | Remap legacy `MSSHT*` IDs to `MYYYYNNNN` |
| `tools/install-migration-011.php` | Mobile API bearer tokens table |
| `tools/migrate_program_intakes.php` | Program↔intake pivot helpers |
| `tools/migrate_programs_modules_pivot.php` | Program↔module pivot helpers |

---

## Troubleshooting

**Blank page or 500** — set `APP_DEBUG` true temporarily; check Apache/PHP logs; confirm PHP ≥ 8.0.

**Database connection failed** — MySQL running? Credentials in `config/database.php` correct?

**PDF is HTML** — run `composer install` so Dompdf exists under `vendor/`.

**Emails not sending** — configure SMTP in Settings, or use fallback reset links in development.

**Student cannot log in** — ensure `user_id` is set (approve application or `create-portal-for-student.php`). Confirm they use the official student number format and temp password `Mssht` + last four digits.

**Wrong student number format** — new numbers are `MYYYYNNNN`. Remap leftovers with `tools/fix-delvin-student-number.php --apply`.

---

## License

Proprietary — Manica Skyview School of Hospitality and Tourism. All rights reserved unless otherwise agreed.

---

## Native Android app

A modular Kotlin / Jetpack Compose client lives in [`android/`](android/):

- Biometric unlock (fingerprint / face / device credential)
- Offline Room cache + WorkManager sync
- FCM push notifications
- UI tokens aligned with web CSS (`#0D4F4C` primary, `#C9A227` accent, DM Sans / Playfair Display)

Mobile JSON API: [`api/mobile/v1/`](api/mobile/v1/). See [`android/README.md`](android/README.md) for Android Studio setup.

---

## Version

Application version: **1.0.0** (`config/app.php`).

Finance ERP detail specs: `mssht-desc3.txt`. Older `mssht-desc*.txt` notes may describe planned integrations that are not implemented — treat this README as the live system reference.
