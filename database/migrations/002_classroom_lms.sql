-- Classroom / LMS extension (mssht-desc2)
USE mssht_db;

-- Virtual classrooms
CREATE TABLE IF NOT EXISTS classes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    module_id INT UNSIGNED NULL,
    name VARCHAR(200) NOT NULL,
    section VARCHAR(80) NULL,
    subject VARCHAR(150) NULL,
    room_number VARCHAR(50) NULL,
    join_code VARCHAR(12) NOT NULL UNIQUE,
    theme_color VARCHAR(20) DEFAULT '#0d4f4c',
    banner_path VARCHAR(255) NULL,
    description TEXT NULL,
    status ENUM('active', 'archived') DEFAULT 'active',
    comments_enabled TINYINT(1) DEFAULT 1,
    created_by INT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_status (status),
    INDEX idx_join_code (join_code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS class_members (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    member_role ENUM('owner', 'co_teacher', 'ta', 'student') NOT NULL DEFAULT 'student',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY uk_class_user (class_id, user_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS class_topics (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id INT UNSIGNED NOT NULL,
    title VARCHAR(150) NOT NULL,
    sort_order SMALLINT UNSIGNED DEFAULT 0,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Stream (announcements & materials)
CREATE TABLE IF NOT EXISTS stream_posts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    post_type ENUM('announcement', 'material', 'assignment') DEFAULT 'announcement',
    title VARCHAR(255) NULL,
    body TEXT NOT NULL,
    attachment_path VARCHAR(255) NULL,
    external_url VARCHAR(500) NULL,
    class_assignment_id INT UNSIGNED NULL,
    scheduled_at DATETIME NULL,
    published_at DATETIME NULL,
    comments_enabled TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_class_published (class_id, published_at),
    INDEX idx_assignment (class_assignment_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS stream_comments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    post_id INT UNSIGNED NOT NULL,
    user_id INT UNSIGNED NOT NULL,
    parent_id INT UNSIGNED NULL,
    body TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES stream_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES stream_comments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Classwork / assignments
CREATE TABLE IF NOT EXISTS class_assignments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id INT UNSIGNED NOT NULL,
    topic_id INT UNSIGNED NULL,
    title VARCHAR(200) NOT NULL,
    instructions TEXT NULL,
    due_date DATETIME NOT NULL,
    max_score DECIMAL(6,2) DEFAULT 100,
    allow_late TINYINT(1) DEFAULT 1,
    late_penalty_percent DECIMAL(5,2) DEFAULT 0,
    status ENUM('draft', 'scheduled', 'published') DEFAULT 'published',
    attachment_path VARCHAR(255) NULL,
    created_by INT UNSIGNED NOT NULL,
    published_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES class_topics(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_class_due (class_id, due_date)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS class_submissions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_assignment_id INT UNSIGNED NOT NULL,
    student_id INT UNSIGNED NOT NULL,
    file_path VARCHAR(255) NULL,
    external_url VARCHAR(500) NULL,
    notes TEXT NULL,
    status ENUM('missing', 'submitted', 'late', 'graded') DEFAULT 'missing',
    score DECIMAL(6,2) NULL,
    feedback TEXT NULL,
    private_comment TEXT NULL,
    graded_by INT UNSIGNED NULL,
    submitted_at DATETIME NULL,
    graded_at DATETIME NULL,
    FOREIGN KEY (class_assignment_id) REFERENCES class_assignments(id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (graded_by) REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE KEY uk_class_assignment_student (class_assignment_id, student_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS class_rubrics (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_assignment_id INT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    criteria_json TEXT NOT NULL COMMENT 'JSON array of {criterion, max_points}',
    FOREIGN KEY (class_assignment_id) REFERENCES class_assignments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Calendar & reminders
CREATE TABLE IF NOT EXISTS class_calendar_events (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    class_id INT UNSIGNED NOT NULL,
    title VARCHAR(200) NOT NULL,
    event_type ENUM('assignment', 'class', 'exam', 'reminder', 'other') DEFAULT 'other',
    start_at DATETIME NOT NULL,
    end_at DATETIME NULL,
    class_assignment_id INT UNSIGNED NULL,
    created_by INT UNSIGNED NOT NULL,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (class_assignment_id) REFERENCES class_assignments(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

-- In-app notifications (due dates, announcements)
CREATE TABLE IF NOT EXISTS user_notifications (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    link_url VARCHAR(500) NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_unread (user_id, is_read)
) ENGINE=InnoDB;

-- Password reset tokens
CREATE TABLE IF NOT EXISTS password_resets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    token VARCHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    used_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;
