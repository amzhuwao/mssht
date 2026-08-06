-- Mobile API tokens for native apps (Android / future iOS)
CREATE TABLE IF NOT EXISTS mobile_tokens (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    token_hash CHAR(64) NOT NULL UNIQUE,
    device_name VARCHAR(120) NULL,
    platform VARCHAR(40) NOT NULL DEFAULT 'android',
    push_token VARCHAR(255) NULL,
    last_seen_at DATETIME NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_mobile_tokens_user (user_id),
    CONSTRAINT fk_mobile_tokens_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
