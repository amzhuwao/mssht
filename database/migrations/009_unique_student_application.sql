USE mssht_db;

ALTER TABLE students
    ADD UNIQUE KEY uq_students_application_id (application_id);