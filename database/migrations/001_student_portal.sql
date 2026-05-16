-- Run this if you already installed the database before student portal was added
USE mssht_db;

-- If column already exists, ignore the error and continue.
ALTER TABLE users
    ADD COLUMN must_change_password TINYINT(1) NOT NULL DEFAULT 0 AFTER status;
