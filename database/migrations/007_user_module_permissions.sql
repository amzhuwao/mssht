USE mssht_db;

CREATE TABLE IF NOT EXISTS user_module_permissions (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    module_name VARCHAR(80) NOT NULL,
    access ENUM('allow', 'deny') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_module (user_id, module_name),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;
