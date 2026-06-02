-- Manica Skyview School of Hospitality and Tourism (MSSHT)
-- School Management System - Database Schema

CREATE DATABASE IF NOT EXISTS mssht_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mssht_db;

-- Users & authentication
CREATE TABLE roles (
    role_key VARCHAR(80) NOT NULL PRIMARY KEY,
    label VARCHAR(150) NOT NULL,
    module_permissions LONGTEXT NULL,
    is_system TINYINT(1) NOT NULL DEFAULT 0,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(80) NOT NULL,
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    must_change_password TINYINT(1) NOT NULL DEFAULT 0,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_role (role),
    INDEX idx_status (status)
) ENGINE=InnoDB;

ALTER TABLE users ADD CONSTRAINT fk_users_role FOREIGN KEY (role) REFERENCES roles(role_key) ON UPDATE CASCADE ON DELETE RESTRICT;

CREATE TABLE user_module_permissions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    module_name VARCHAR(80) NOT NULL,
    access ENUM('allow', 'deny') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_module (user_id, module_name),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE user_profiles (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL UNIQUE,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    phone VARCHAR(30) NULL,
    gender ENUM('male', 'female', 'other') NULL,
    date_of_birth DATE NULL,
    national_id VARCHAR(50) NULL,
    address TEXT NULL,
    avatar VARCHAR(255) NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Academic structure
CREATE TABLE programs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(200) NOT NULL,
    program_type ENUM('short_course', 'certificate', 'diploma', 'hnd') NOT NULL,
    duration_months SMALLINT UNSIGNED DEFAULT 12,
    duration_value SMALLINT UNSIGNED DEFAULT 12,
    duration_unit VARCHAR(10) DEFAULT 'months',
    total_credits DECIMAL(6,2) DEFAULT 0,
    description TEXT NULL,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE intakes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('open', 'closed', 'archived') DEFAULT 'open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE modules (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_id INT UNSIGNED NOT NULL,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(200) NOT NULL,
    credits DECIMAL(4,2) DEFAULT 0,
    semester TINYINT UNSIGNED DEFAULT 1,
    is_core TINYINT(1) DEFAULT 1,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    UNIQUE KEY uk_program_module (program_id, code)
) ENGINE=InnoDB;

-- Admissions
CREATE TABLE applications (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    application_ref VARCHAR(30) NOT NULL UNIQUE,
    user_id INT UNSIGNED NULL UNIQUE,
    program_id INT UNSIGNED NOT NULL,
    intake_id INT UNSIGNED NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    gender ENUM('male', 'female', 'other') NULL,
    date_of_birth DATE NULL,
    address TEXT NULL,
    previous_qualification VARCHAR(200) NULL,
    status ENUM('pending', 'under_review', 'approved', 'rejected', 'waitlisted') DEFAULT 'pending',
    notes TEXT NULL,
    reviewed_by INT UNSIGNED NULL,
    reviewed_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (program_id) REFERENCES programs(id),
    FOREIGN KEY (intake_id) REFERENCES intakes(id),
    FOREIGN KEY (reviewed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE application_documents (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    application_id INT UNSIGNED NOT NULL,
    document_type VARCHAR(80) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Students (SIS)
CREATE TABLE students (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NULL UNIQUE,
    student_number VARCHAR(30) NOT NULL UNIQUE,
    application_id INT UNSIGNED NULL,
    program_id INT UNSIGNED NOT NULL,
    intake_id INT UNSIGNED NOT NULL,
    enrollment_status ENUM('active', 'graduated', 'withdrawn', 'suspended', 'deferred') DEFAULT 'active',
    enrollment_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (application_id) REFERENCES applications(id) ON DELETE SET NULL,
    FOREIGN KEY (program_id) REFERENCES programs(id),
    FOREIGN KEY (intake_id) REFERENCES intakes(id)
) ENGINE=InnoDB;

CREATE TABLE student_documents (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    title VARCHAR(150) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    uploaded_by INT UNSIGNED NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE module_registrations (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    module_id INT UNSIGNED NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    status ENUM('registered', 'completed', 'failed', 'carried') DEFAULT 'registered',
    grade VARCHAR(5) NULL,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    UNIQUE KEY uk_student_module_year (student_id, module_id, academic_year)
) ENGINE=InnoDB;

-- Timetabling
CREATE TABLE rooms (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL,
    capacity SMALLINT UNSIGNED DEFAULT 30,
    room_type ENUM('classroom', 'lab', 'hall', 'online') DEFAULT 'classroom'
) ENGINE=InnoDB;

CREATE TABLE timetable_slots (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_id INT UNSIGNED NOT NULL,
    lecturer_id INT UNSIGNED NOT NULL,
    room_id INT UNSIGNED NULL,
    day_of_week TINYINT UNSIGNED NOT NULL COMMENT '1=Mon .. 7=Sun',
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    delivery_mode ENUM('face_to_face', 'online', 'hybrid') DEFAULT 'face_to_face',
    academic_year VARCHAR(20) NOT NULL,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (lecturer_id) REFERENCES users(id),
    FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE academic_calendar (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    event_type ENUM('semester_start', 'semester_end', 'exam', 'holiday', 'graduation', 'other') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    description TEXT NULL
) ENGINE=InnoDB;

-- LMS
CREATE TABLE lms_materials (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_id INT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    file_path VARCHAR(255) NULL,
    external_url VARCHAR(500) NULL,
    uploaded_by INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE assignments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_id INT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT NULL,
    due_date DATETIME NOT NULL,
    max_score DECIMAL(6,2) DEFAULT 100,
    created_by INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE assignment_submissions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT UNSIGNED NOT NULL,
    student_id INT UNSIGNED NOT NULL,
    file_path VARCHAR(255) NULL,
    notes TEXT NULL,
    score DECIMAL(6,2) NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE KEY uk_assignment_student (assignment_id, student_id)
) ENGINE=InnoDB;

CREATE TABLE forum_topics (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- Attendance
CREATE TABLE attendance_sessions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_id INT UNSIGNED NOT NULL,
    session_date DATE NOT NULL,
    qr_token VARCHAR(64) NOT NULL UNIQUE,
    created_by INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE attendance_records (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    session_id INT UNSIGNED NOT NULL,
    student_id INT UNSIGNED NOT NULL,
    status ENUM('present', 'absent', 'late', 'excused') DEFAULT 'present',
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (session_id) REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    UNIQUE KEY uk_session_student (session_id, student_id)
) ENGINE=InnoDB;

-- Examinations & assessment
CREATE TABLE assessments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_id INT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    assessment_type ENUM('ca', 'exam', 'project', 'practical') NOT NULL,
    weight_percent DECIMAL(5,2) DEFAULT 0,
    max_score DECIMAL(6,2) DEFAULT 100,
    scheduled_date DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE marks (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    assessment_id INT UNSIGNED NOT NULL,
    student_id INT UNSIGNED NOT NULL,
    score DECIMAL(6,2) NOT NULL,
    grade VARCHAR(5) NULL,
    moderated TINYINT(1) DEFAULT 0,
    entered_by INT UNSIGNED NOT NULL,
    entered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (entered_by) REFERENCES users(id),
    UNIQUE KEY uk_assessment_student (assessment_id, student_id)
) ENGINE=InnoDB;

-- Finance
CREATE TABLE fee_structures (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    program_id INT UNSIGNED NOT NULL,
    intake_id INT UNSIGNED NULL,
    description VARCHAR(200) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    allow_installments TINYINT(1) DEFAULT 0,
    FOREIGN KEY (program_id) REFERENCES programs(id) ON DELETE CASCADE,
    FOREIGN KEY (intake_id) REFERENCES intakes(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE invoices (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(30) NOT NULL UNIQUE,
    student_id INT UNSIGNED NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    amount_paid DECIMAL(12,2) DEFAULT 0,
    status ENUM('pending', 'partial', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    due_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE payments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT UNSIGNED NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('cash', 'bank', 'mobile', 'gateway') NOT NULL,
    reference VARCHAR(100) NULL,
    received_by INT UNSIGNED NULL,
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Human resources
CREATE TABLE staff (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL UNIQUE,
    staff_number VARCHAR(30) NOT NULL UNIQUE,
    department VARCHAR(100) NULL,
    position VARCHAR(100) NULL,
    hire_date DATE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE lecturer_workload (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    lecturer_id INT UNSIGNED NOT NULL,
    module_id INT UNSIGNED NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    contact_hours SMALLINT UNSIGNED DEFAULT 0,
    FOREIGN KEY (lecturer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Library
CREATE TABLE library_books (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NULL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(150) NULL,
    category VARCHAR(80) NULL,
    copies_total SMALLINT UNSIGNED DEFAULT 1,
    copies_available SMALLINT UNSIGNED DEFAULT 1,
    is_digital TINYINT(1) DEFAULT 0,
    digital_url VARCHAR(500) NULL
) ENGINE=InnoDB;

CREATE TABLE library_borrowings (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    book_id INT UNSIGNED NOT NULL,
    student_id INT UNSIGNED NOT NULL,
    borrowed_at DATE NOT NULL,
    due_date DATE NOT NULL,
    returned_at DATE NULL,
    status ENUM('borrowed', 'returned', 'overdue') DEFAULT 'borrowed',
    FOREIGN KEY (book_id) REFERENCES library_books(id),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Industrial attachment
CREATE TABLE placements (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    employer_name VARCHAR(200) NOT NULL,
    supervisor_name VARCHAR(150) NULL,
    supervisor_contact VARCHAR(80) NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    status ENUM('pending', 'active', 'completed', 'terminated') DEFAULT 'pending',
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE placement_logbooks (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    placement_id INT UNSIGNED NOT NULL,
    log_date DATE NOT NULL,
    activities TEXT NOT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (placement_id) REFERENCES placements(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Communication
CREATE TABLE messages (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sender_id INT UNSIGNED NOT NULL,
    recipient_id INT UNSIGNED NOT NULL,
    subject VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notifications (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    channel ENUM('system', 'email', 'sms', 'push') DEFAULT 'system',
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Certification & graduation
CREATE TABLE graduations (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    program_id INT UNSIGNED NOT NULL,
    graduation_date DATE NOT NULL,
    certificate_number VARCHAR(50) NOT NULL UNIQUE,
    qr_verification_code VARCHAR(64) NOT NULL UNIQUE,
    gpa DECIMAL(4,2) NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(id)
) ENGINE=InnoDB;

-- Audit log
CREATE TABLE audit_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NULL,
    entity_id INT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Seed default super admin (password: Admin@123)
INSERT INTO roles (role_key, label, module_permissions, is_system, status, sort_order) VALUES
('super_admin', 'Super Administrator', '["dashboard","admissions","programs","students","classes","timetable","lms","attendance","exams","finance","hr","library","placements","messages","reports","graduation","settings","users","notifications"]', 1, 'active', 1),
('registrar', 'Registrar / Academic Admin', '["dashboard","admissions","programs","students","classes","timetable","exams","reports","graduation","messages"]', 1, 'active', 2),
('finance', 'Finance Officer', '["dashboard","finance","students","reports","messages"]', 1, 'active', 3),
('lecturer', 'Lecturer / Trainer', '["dashboard","classes","lms","attendance","exams","timetable","messages"]', 1, 'active', 4),
('student', 'Student', '["dashboard","classes","lms","attendance","exams","finance","library","placements","messages","notifications"]', 1, 'active', 5),
('hod', 'HOD / Dean', '["dashboard","programs","students","classes","timetable","exams","reports","messages"]', 1, 'active', 6),
('librarian', 'Librarian', '["dashboard","library","messages"]', 1, 'active', 7),
('external_examiner', 'External Examiner', '["dashboard","exams","messages"]', 1, 'active', 8)
ON DUPLICATE KEY UPDATE
    label = VALUES(label),
    module_permissions = VALUES(module_permissions),
    is_system = VALUES(is_system),
    status = VALUES(status),
    sort_order = VALUES(sort_order);

INSERT INTO users (email, password_hash, role, status) VALUES
('admin@mssht.ac.zw', '$2y$10$evJtjIdvtv9sBnWqcfx9xuTunp38PE3AwNDyNiVHY/LcsbBpd9kdK', 'super_admin', 'active');

INSERT INTO user_profiles (user_id, first_name, last_name, phone) VALUES
(1, 'System', 'Administrator', '+263000000000');

INSERT INTO programs (code, name, program_type, duration_months, total_credits, description) VALUES
('SC-HOSP-101', 'Certificate in Hospitality Operations', 'short_course', 3, 12, 'Short course in hospitality operations'),
('PC-CUL-201', 'Professional Certificate in Culinary Arts', 'certificate', 6, 24, 'Professional culinary certificate'),
('DIP-TOUR-301', 'Diploma in Tourism Management', 'diploma', 24, 120, 'Tourism management diploma'),
('HND-HOSP-401', 'Higher National Diploma in Hospitality Management', 'hnd', 36, 240, 'HND in hospitality management');

INSERT INTO intakes (name, academic_year, start_date, end_date, status) VALUES
('January 2026 Intake', '2026', '2026-01-15', '2026-12-15', 'open'),
('May 2026 Intake', '2026', '2026-05-01', '2027-04-30', 'open');

INSERT INTO rooms (name, capacity, room_type) VALUES
('Lecture Hall A', 80, 'hall'),
('Computer Lab 1', 30, 'lab'),
('Training Kitchen', 25, 'lab'),
('Online Platform', 500, 'online');
