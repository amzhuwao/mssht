USE mssht_db;

CREATE TABLE IF NOT EXISTS roles (
    role_key VARCHAR(80) NOT NULL PRIMARY KEY,
    label VARCHAR(150) NOT NULL,
    module_permissions LONGTEXT NULL,
    is_system TINYINT(1) NOT NULL DEFAULT 0,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

ALTER TABLE users MODIFY role VARCHAR(80) NOT NULL;

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
