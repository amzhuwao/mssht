USE mssht_db;

ALTER TABLE applications
    ADD COLUMN user_id INT UNSIGNED NULL UNIQUE AFTER application_ref,
    ADD CONSTRAINT fk_applications_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;
