USE mssht_db;

-- Guardians
CREATE TABLE IF NOT EXISTS guardians (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    email VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NULL,
    receive_summaries TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_guardian_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS student_guardians (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    student_id INT UNSIGNED NOT NULL,
    guardian_id INT UNSIGNED NOT NULL,
    relationship VARCHAR(50) DEFAULT 'parent',
    is_primary TINYINT(1) DEFAULT 0,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE CASCADE,
    UNIQUE KEY uk_student_guardian (student_id, guardian_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS guardian_access_tokens (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    guardian_id INT UNSIGNED NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS guardian_summary_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    guardian_id INT UNSIGNED NOT NULL,
    student_id INT UNSIGNED NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_status ENUM('sent', 'failed') DEFAULT 'sent',
    FOREIGN KEY (guardian_id) REFERENCES guardians(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Rubric scores on submissions
ALTER TABLE class_submissions
    ADD COLUMN rubric_scores_json TEXT NULL COMMENT 'JSON {criterion_id: points}' AFTER feedback;
