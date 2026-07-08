USE mssht_db;

ALTER TABLE students
    ADD COLUMN application_ref VARCHAR(30) NULL UNIQUE AFTER student_number,
    ADD COLUMN first_name VARCHAR(80) NULL AFTER application_ref,
    ADD COLUMN last_name VARCHAR(80) NULL AFTER first_name,
    ADD COLUMN email VARCHAR(150) NULL AFTER last_name,
    ADD COLUMN phone VARCHAR(30) NULL AFTER email,
    ADD COLUMN gender ENUM('male', 'female', 'other') NULL AFTER phone,
    ADD COLUMN date_of_birth DATE NULL AFTER gender,
    ADD COLUMN address TEXT NULL AFTER date_of_birth,
    ADD COLUMN previous_qualification VARCHAR(200) NULL AFTER address,
    ADD COLUMN notes TEXT NULL AFTER previous_qualification;

UPDATE students s
LEFT JOIN applications a ON a.id = s.application_id
LEFT JOIN users u ON u.id = s.user_id
LEFT JOIN user_profiles up ON up.user_id = u.id
SET s.application_ref = COALESCE(s.application_ref, a.application_ref),
    s.first_name = COALESCE(s.first_name, a.first_name, up.first_name),
    s.last_name = COALESCE(s.last_name, a.last_name, up.last_name),
    s.email = COALESCE(s.email, a.email, u.email),
    s.phone = COALESCE(s.phone, a.phone, up.phone),
    s.gender = COALESCE(s.gender, a.gender, up.gender),
    s.date_of_birth = COALESCE(s.date_of_birth, a.date_of_birth, up.date_of_birth),
    s.address = COALESCE(s.address, a.address, up.address),
    s.previous_qualification = COALESCE(s.previous_qualification, a.previous_qualification),
    s.notes = COALESCE(s.notes, a.notes);