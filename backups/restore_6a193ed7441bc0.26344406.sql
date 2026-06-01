-- MSSHT database backup
-- Generated: 2026-05-29 08:44:13
-- Database: mssht_db
SET FOREIGN_KEY_CHECKS=0;

-- Table: academic_calendar
DROP TABLE IF EXISTS `academic_calendar`;
CREATE TABLE `academic_calendar` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(150) NOT NULL,
  `event_type` enum('semester_start','semester_end','exam','holiday','graduation','other') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: app_settings
DROP TABLE IF EXISTS `app_settings`;
CREATE TABLE `app_settings` (
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: application_documents
DROP TABLE IF EXISTS `application_documents`;
CREATE TABLE `application_documents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `application_id` int(10) unsigned NOT NULL,
  `document_type` varchar(80) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `application_id` (`application_id`),
  CONSTRAINT `application_documents_ibfk_1` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `application_documents` (`id`,`application_id`,`document_type`,`file_path`,`uploaded_at`) VALUES (1, 1, 'a_level_certificate', 'applications/f_6a16d0f63d4712.45822250.pdf', '2026-05-27 13:09:42');

-- Table: applications
DROP TABLE IF EXISTS `applications`;
CREATE TABLE `applications` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `application_ref` varchar(30) NOT NULL,
  `user_id` int(10) unsigned DEFAULT NULL,
  `program_id` int(10) unsigned NOT NULL,
  `intake_id` int(10) unsigned NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(30) NOT NULL,
  `gender` enum('male','female','other') DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `address` text DEFAULT NULL,
  `previous_qualification` varchar(200) DEFAULT NULL,
  `status` enum('pending','under_review','approved','rejected','waitlisted') DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `reviewed_by` int(10) unsigned DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `application_ref` (`application_ref`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `program_id` (`program_id`),
  KEY `intake_id` (`intake_id`),
  KEY `reviewed_by` (`reviewed_by`),
  CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`),
  CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`intake_id`) REFERENCES `intakes` (`id`),
  CONSTRAINT `applications_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_applications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1330 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1, 'APP-2026-60D8F8', NULL, 1, 1, 'Aubrey', 'Zhuwao', 'amzhuwao@gmail.com', '0774164508', 'male', '1997-01-18', '4018 Dr Nyamuswa Way Sanganai Park', 'a level', 'approved', '{\"attendance_type\":\"part_time\",\"title\":\"Mr\",\"national_id\":\"63242974e63\",\"marital_status\":\"single\",\"nationality\":\"zimbabwe\",\"citizenship\":\"zimbabwe\",\"country_permanent_residence\":\"Zimbabwe\",\"disability\":\"\",\"medical_conditions\":\"\",\"tel\":\"0774164508\",\"cell\":\"\",\"next_of_kin\":{\"name\":\"sili zhuwao\",\"relationship\":\"mother\",\"tel\":\"0782260382\",\"email\":\"\",\"cell\":\"0782260382\"},\"first_choice\":\"\",\"second_choice\":\"\",\"exam_board\":\"zimsec\",\"o_level_results\":\"\",\"a_level_results\":\"15 points\",\"tertiary_education\":\"\",\"work_experience\":\"non\",\"sponsor\":{\"type\":\"self\",\"name\":\"\",\"contact\":\"\"},\"declarations\":{\"completed_sections\":1,\"enclosed_documents\":1,\"signed\":1},\"reviewer_notes\":\"\"}', 1, '2026-05-27 13:17:21', '2026-05-27 13:09:42');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (2, 'APP-2026-9CC2A8', 3, 3, 1, 'Test', 'Applicant', 'test.applicant@example.com', '0777000000', NULL, NULL, NULL, 'O-Level', 'pending', '{\"attendance_type\":\"full_time\",\"national_id\":\"SEED-TEST-1234\",\"first_choice\":3,\"reviewer_notes\":\"Seeded test application\"}', NULL, NULL, '2026-05-27 13:24:41');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (186, 'TEST-APP-DBG', NULL, 1, 1, 'Dbg', 'User', 'dbg@example.com', '555', 'male', '2000-01-01', 'addr', 'None', 'pending', 'note', NULL, NULL, '2026-05-28 14:09:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1210, 'SEED-APP-2026-001', 1212, 1, 1, 'Blessing', 'Chirwa', 'student.blessing.chirwa.001@seed.mssht.test', '0777000001', 'other', '2008-09-02', 'Seed House 001, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":1}', 6, '2026-01-16 09:00:00', '2026-05-28 15:47:08');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1211, 'SEED-APP-2026-002', 1213, 1, 1, 'Chenai', 'Dube', 'student.chenai.dube.002@seed.mssht.test', '0777000002', 'female', '2008-09-03', 'Seed House 002, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":1}', 6, '2026-01-17 09:00:00', '2026-05-28 15:47:09');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1212, 'SEED-APP-2026-003', 1214, 1, 1, 'Derrick', 'Furusa', 'student.derrick.furusa.003@seed.mssht.test', '0777000003', 'male', '2008-09-04', 'Seed House 003, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":1}', 6, '2026-01-18 09:00:00', '2026-05-28 15:47:09');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1213, 'SEED-APP-2026-004', 1215, 1, 1, 'Elina', 'Gumbo', 'student.elina.gumbo.004@seed.mssht.test', '0777000004', 'female', '2008-09-05', 'Seed House 004, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":1}', 6, '2026-01-19 09:00:00', '2026-05-28 15:47:09');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1214, 'SEED-APP-2026-005', 1216, 1, 1, 'Farai', 'Hove', 'student.farai.hove.005@seed.mssht.test', '0777000005', 'other', '2008-09-06', 'Seed House 005, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":1}', 6, '2026-01-20 09:00:00', '2026-05-28 15:47:09');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1215, 'SEED-APP-2026-006', 1217, 1, 1, 'Godfrey', 'Jele', 'student.godfrey.jele.006@seed.mssht.test', '0777000006', 'male', '2008-09-07', 'Seed House 006, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":1}', 6, '2026-01-21 09:00:00', '2026-05-28 15:47:09');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1216, 'SEED-APP-2026-007', 1218, 1, 1, 'Hilda', 'Kachidza', 'student.hilda.kachidza.007@seed.mssht.test', '0777000007', 'other', '2008-09-08', 'Seed House 007, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":1}', 6, '2026-01-22 09:00:00', '2026-05-28 15:47:09');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1217, 'SEED-APP-2026-008', 1219, 1, 1, 'Ivy', 'Moyo', 'student.ivy.moyo.008@seed.mssht.test', '0777000008', 'female', '2008-09-09', 'Seed House 008, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":1}', 6, '2026-01-23 09:00:00', '2026-05-28 15:47:09');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1218, 'SEED-APP-2026-009', 1220, 1, 2, 'Jared', 'Ncube', 'student.jared.ncube.009@seed.mssht.test', '0777000009', 'male', '2008-09-10', 'Seed House 009, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":2}', 6, '2026-01-24 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1219, 'SEED-APP-2026-010', 1221, 1, 2, 'Kudzai', 'Nyasha', 'student.kudzai.nyasha.010@seed.mssht.test', '0777000010', 'female', '2008-09-11', 'Seed House 010, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":2}', 6, '2026-01-25 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1220, 'SEED-APP-2026-011', 1222, 1, 2, 'Lerato', 'Phiri', 'student.lerato.phiri.011@seed.mssht.test', '0777000011', 'other', '2008-09-12', 'Seed House 011, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":2}', 6, '2026-01-26 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1221, 'SEED-APP-2026-012', 1223, 1, 2, 'Moses', 'Sibanda', 'student.moses.sibanda.012@seed.mssht.test', '0777000012', 'male', '2008-09-13', 'Seed House 012, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":2}', 6, '2026-01-27 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1222, 'SEED-APP-2026-013', 1224, 1, 2, 'Nadia', 'Tafara', 'student.nadia.tafara.013@seed.mssht.test', '0777000013', 'other', '2008-09-14', 'Seed House 013, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":2}', 6, '2026-01-28 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1223, 'SEED-APP-2026-014', 1225, 1, 2, 'Obert', 'Vengesai', 'student.obert.vengesai.014@seed.mssht.test', '0777000014', 'female', '2008-09-15', 'Seed House 014, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":2}', 6, '2026-01-29 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1224, 'SEED-APP-2026-015', 1226, 1, 2, 'Precious', 'Zhou', 'student.precious.zhou.015@seed.mssht.test', '0777000015', 'male', '2008-09-16', 'Seed House 015, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":2}', 6, '2026-01-30 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1225, 'SEED-APP-2026-016', 1227, 2, 1, 'Tariro', 'Banda', 'student.tariro.banda.016@seed.mssht.test', '0777000016', 'female', '2008-09-17', 'Seed House 016, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":1}', 6, '2026-01-31 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1226, 'SEED-APP-2026-017', 1228, 2, 1, 'Unity', 'Chirwa', 'student.unity.chirwa.017@seed.mssht.test', '0777000017', 'other', '2008-09-18', 'Seed House 017, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":1}', 6, '2026-02-01 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1227, 'SEED-APP-2026-018', 1229, 2, 1, 'Vimbai', 'Dube', 'student.vimbai.dube.018@seed.mssht.test', '0777000018', 'male', '2008-09-19', 'Seed House 018, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":1}', 6, '2026-02-02 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1228, 'SEED-APP-2026-019', 1230, 2, 1, 'Wellington', 'Furusa', 'student.wellington.furusa.019@seed.mssht.test', '0777000019', 'other', '2008-09-20', 'Seed House 019, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":1}', 6, '2026-02-03 09:00:00', '2026-05-28 15:47:10');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1229, 'SEED-APP-2026-020', 1231, 2, 1, 'Amina', 'Gumbo', 'student.amina.gumbo.020@seed.mssht.test', '0777000020', 'female', '2008-09-21', 'Seed House 020, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":1}', 6, '2026-02-04 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1230, 'SEED-APP-2026-021', 1232, 2, 1, 'Blessing', 'Hove', 'student.blessing.hove.021@seed.mssht.test', '0777000021', 'male', '2008-09-22', 'Seed House 021, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":1}', 6, '2026-02-05 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1231, 'SEED-APP-2026-022', 1233, 2, 1, 'Chenai', 'Jele', 'student.chenai.jele.022@seed.mssht.test', '0777000022', 'female', '2008-09-23', 'Seed House 022, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":1}', 6, '2026-02-06 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1232, 'SEED-APP-2026-023', 1234, 2, 1, 'Derrick', 'Kachidza', 'student.derrick.kachidza.023@seed.mssht.test', '0777000023', 'other', '2008-09-24', 'Seed House 023, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":1}', 6, '2026-02-07 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1233, 'SEED-APP-2026-024', 1235, 2, 2, 'Elina', 'Moyo', 'student.elina.moyo.024@seed.mssht.test', '0777000024', 'male', '2008-09-25', 'Seed House 024, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":2}', 6, '2026-02-08 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1234, 'SEED-APP-2026-025', 1236, 2, 2, 'Farai', 'Ncube', 'student.farai.ncube.025@seed.mssht.test', '0777000025', 'other', '2008-09-26', 'Seed House 025, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":2}', 6, '2026-02-09 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1235, 'SEED-APP-2026-026', 1237, 2, 2, 'Godfrey', 'Nyasha', 'student.godfrey.nyasha.026@seed.mssht.test', '0777000026', 'female', '2008-09-27', 'Seed House 026, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":2}', 6, '2026-02-10 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1236, 'SEED-APP-2026-027', 1238, 2, 2, 'Hilda', 'Phiri', 'student.hilda.phiri.027@seed.mssht.test', '0777000027', 'male', '2008-09-28', 'Seed House 027, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":2}', 6, '2026-02-11 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1237, 'SEED-APP-2026-028', 1239, 2, 2, 'Ivy', 'Sibanda', 'student.ivy.sibanda.028@seed.mssht.test', '0777000028', 'female', '2008-09-29', 'Seed House 028, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":2}', 6, '2026-02-12 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1238, 'SEED-APP-2026-029', 1240, 2, 2, 'Jared', 'Tafara', 'student.jared.tafara.029@seed.mssht.test', '0777000029', 'other', '2008-09-30', 'Seed House 029, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":2}', 6, '2026-02-13 09:00:00', '2026-05-28 15:47:11');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1239, 'SEED-APP-2026-030', 1241, 2, 2, 'Kudzai', 'Vengesai', 'student.kudzai.vengesai.030@seed.mssht.test', '0777000030', 'male', '2008-10-01', 'Seed House 030, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"PC-CUL-201\",\"intake_id\":2}', 6, '2026-02-14 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1240, 'SEED-APP-2026-031', 1242, 3, 1, 'Lerato', 'Zhou', 'student.lerato.zhou.031@seed.mssht.test', '0777000031', 'other', '2008-10-02', 'Seed House 031, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":1}', 6, '2026-02-15 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1241, 'SEED-APP-2026-032', 1243, 3, 1, 'Moses', 'Banda', 'student.moses.banda.032@seed.mssht.test', '0777000032', 'female', '2008-10-03', 'Seed House 032, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":1}', 6, '2026-02-16 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1242, 'SEED-APP-2026-033', 1244, 3, 1, 'Nadia', 'Chirwa', 'student.nadia.chirwa.033@seed.mssht.test', '0777000033', 'male', '2008-10-04', 'Seed House 033, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":1}', 6, '2026-02-17 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1243, 'SEED-APP-2026-034', 1245, 3, 1, 'Obert', 'Dube', 'student.obert.dube.034@seed.mssht.test', '0777000034', 'female', '2008-10-05', 'Seed House 034, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":1}', 6, '2026-02-18 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1244, 'SEED-APP-2026-035', 1246, 3, 1, 'Precious', 'Furusa', 'student.precious.furusa.035@seed.mssht.test', '0777000035', 'other', '2008-10-06', 'Seed House 035, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":1}', 6, '2026-02-19 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1245, 'SEED-APP-2026-036', 1247, 3, 1, 'Tariro', 'Gumbo', 'student.tariro.gumbo.036@seed.mssht.test', '0777000036', 'male', '2008-10-07', 'Seed House 036, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":1}', 6, '2026-02-20 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1246, 'SEED-APP-2026-037', 1248, 3, 1, 'Unity', 'Hove', 'student.unity.hove.037@seed.mssht.test', '0777000037', 'other', '2008-10-08', 'Seed House 037, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":1}', 6, '2026-02-21 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1247, 'SEED-APP-2026-038', 1249, 3, 1, 'Vimbai', 'Jele', 'student.vimbai.jele.038@seed.mssht.test', '0777000038', 'female', '2008-10-09', 'Seed House 038, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":1}', 6, '2026-02-22 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1248, 'SEED-APP-2026-039', 1250, 3, 2, 'Wellington', 'Kachidza', 'student.wellington.kachidza.039@seed.mssht.test', '0777000039', 'male', '2008-10-10', 'Seed House 039, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":2}', 6, '2026-02-23 09:00:00', '2026-05-28 15:47:12');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1249, 'SEED-APP-2026-040', 1251, 3, 2, 'Amina', 'Moyo', 'student.amina.moyo.040@seed.mssht.test', '0777000040', 'female', '2008-10-11', 'Seed House 040, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":2}', 6, '2026-02-24 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1250, 'SEED-APP-2026-041', 1252, 3, 2, 'Blessing', 'Ncube', 'student.blessing.ncube.041@seed.mssht.test', '0777000041', 'other', '2008-10-12', 'Seed House 041, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":2}', 6, '2026-02-25 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1251, 'SEED-APP-2026-042', 1253, 3, 2, 'Chenai', 'Nyasha', 'student.chenai.nyasha.042@seed.mssht.test', '0777000042', 'male', '2008-10-13', 'Seed House 042, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":2}', 6, '2026-02-26 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1252, 'SEED-APP-2026-043', 1254, 3, 2, 'Derrick', 'Phiri', 'student.derrick.phiri.043@seed.mssht.test', '0777000043', 'other', '2008-10-14', 'Seed House 043, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":2}', 6, '2026-02-27 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1253, 'SEED-APP-2026-044', 1255, 3, 2, 'Elina', 'Sibanda', 'student.elina.sibanda.044@seed.mssht.test', '0777000044', 'female', '2008-10-15', 'Seed House 044, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":2}', 6, '2026-02-28 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1254, 'SEED-APP-2026-045', 1256, 3, 2, 'Farai', 'Tafara', 'student.farai.tafara.045@seed.mssht.test', '0777000045', 'male', '2008-10-16', 'Seed House 045, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":2}', 6, '2026-03-01 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1255, 'SEED-APP-2026-046', 1257, 4, 1, 'Godfrey', 'Vengesai', 'student.godfrey.vengesai.046@seed.mssht.test', '0777000046', 'female', '2008-10-17', 'Seed House 046, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":1}', 6, '2026-03-02 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1256, 'SEED-APP-2026-047', 1258, 4, 1, 'Hilda', 'Zhou', 'student.hilda.zhou.047@seed.mssht.test', '0777000047', 'other', '2008-10-18', 'Seed House 047, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":1}', 6, '2026-03-03 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1257, 'SEED-APP-2026-048', 1259, 4, 1, 'Ivy', 'Banda', 'student.ivy.banda.048@seed.mssht.test', '0777000048', 'male', '2008-10-19', 'Seed House 048, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":1}', 6, '2026-03-04 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1258, 'SEED-APP-2026-049', 1260, 4, 1, 'Jared', 'Chirwa', 'student.jared.chirwa.049@seed.mssht.test', '0777000049', 'other', '2008-10-20', 'Seed House 049, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":1}', 6, '2026-03-05 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1259, 'SEED-APP-2026-050', 1261, 4, 1, 'Kudzai', 'Dube', 'student.kudzai.dube.050@seed.mssht.test', '0777000050', 'female', '2008-10-21', 'Seed House 050, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":1}', 6, '2026-03-06 09:00:00', '2026-05-28 15:47:13');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1260, 'SEED-APP-2026-051', 1262, 4, 1, 'Lerato', 'Furusa', 'student.lerato.furusa.051@seed.mssht.test', '0777000051', 'male', '2008-10-22', 'Seed House 051, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":1}', 6, '2026-03-07 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1261, 'SEED-APP-2026-052', 1263, 4, 1, 'Moses', 'Gumbo', 'student.moses.gumbo.052@seed.mssht.test', '0777000052', 'female', '2008-10-23', 'Seed House 052, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":1}', 6, '2026-03-08 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1262, 'SEED-APP-2026-053', 1264, 4, 1, 'Nadia', 'Hove', 'student.nadia.hove.053@seed.mssht.test', '0777000053', 'other', '2008-10-24', 'Seed House 053, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":1}', 6, '2026-03-09 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1263, 'SEED-APP-2026-054', 1265, 4, 2, 'Obert', 'Jele', 'student.obert.jele.054@seed.mssht.test', '0777000054', 'male', '2008-10-25', 'Seed House 054, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":2}', 6, '2026-03-10 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1264, 'SEED-APP-2026-055', 1266, 4, 2, 'Precious', 'Kachidza', 'student.precious.kachidza.055@seed.mssht.test', '0777000055', 'other', '2008-10-26', 'Seed House 055, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":2}', 6, '2026-03-11 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1265, 'SEED-APP-2026-056', 1267, 4, 2, 'Tariro', 'Moyo', 'student.tariro.moyo.056@seed.mssht.test', '0777000056', 'female', '2008-10-27', 'Seed House 056, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":2}', 6, '2026-03-12 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1266, 'SEED-APP-2026-057', 1268, 4, 2, 'Unity', 'Ncube', 'student.unity.ncube.057@seed.mssht.test', '0777000057', 'male', '2008-10-28', 'Seed House 057, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":2}', 6, '2026-03-13 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1267, 'SEED-APP-2026-058', 1269, 4, 2, 'Vimbai', 'Nyasha', 'student.vimbai.nyasha.058@seed.mssht.test', '0777000058', 'female', '2008-10-29', 'Seed House 058, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":2}', 6, '2026-03-14 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1268, 'SEED-APP-2026-059', 1270, 4, 2, 'Wellington', 'Phiri', 'student.wellington.phiri.059@seed.mssht.test', '0777000059', 'other', '2008-10-30', 'Seed House 059, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":2}', 6, '2026-03-15 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1269, 'SEED-APP-2026-060', 1271, 4, 2, 'Amina', 'Sibanda', 'student.amina.sibanda.060@seed.mssht.test', '0777000060', 'male', '2008-10-31', 'Seed House 060, Test Avenue, Harare', 'O-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2026\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":2}', 6, '2026-03-16 09:00:00', '2026-05-28 15:47:14');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1270, 'SEED-APP-2027-061', 1272, 1, 15, 'Blessing', 'Tafara', 'student.blessing.tafara.061@seed.mssht.test', '0777000061', 'other', '2009-11-01', 'Seed House 061, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":15}', 6, '2027-03-17 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1271, 'SEED-APP-2027-062', 1273, 1, 15, 'Chenai', 'Vengesai', 'student.chenai.vengesai.062@seed.mssht.test', '0777000062', 'female', '2009-11-02', 'Seed House 062, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":15}', 6, '2027-03-18 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1272, 'SEED-APP-2027-063', 1274, 1, 15, 'Derrick', 'Zhou', 'student.derrick.zhou.063@seed.mssht.test', '0777000063', 'male', '2009-11-03', 'Seed House 063, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":15}', 6, '2027-03-19 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1273, 'SEED-APP-2027-064', 1275, 1, 15, 'Elina', 'Banda', 'student.elina.banda.064@seed.mssht.test', '0777000064', 'female', '2009-11-04', 'Seed House 064, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":15}', 6, '2027-03-20 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1274, 'SEED-APP-2027-065', 1276, 1, 15, 'Farai', 'Chirwa', 'student.farai.chirwa.065@seed.mssht.test', '0777000065', 'other', '2009-11-05', 'Seed House 065, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":15}', 6, '2027-03-21 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1275, 'SEED-APP-2027-066', 1277, 1, 15, 'Godfrey', 'Dube', 'student.godfrey.dube.066@seed.mssht.test', '0777000066', 'male', '2009-11-06', 'Seed House 066, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":15}', 6, '2027-03-22 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1276, 'SEED-APP-2027-067', 1278, 1, 15, 'Hilda', 'Furusa', 'student.hilda.furusa.067@seed.mssht.test', '0777000067', 'other', '2009-11-07', 'Seed House 067, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":15}', 6, '2027-03-23 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1277, 'SEED-APP-2027-068', 1279, 1, 15, 'Ivy', 'Gumbo', 'student.ivy.gumbo.068@seed.mssht.test', '0777000068', 'female', '2009-11-08', 'Seed House 068, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":15}', 6, '2027-03-24 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1278, 'SEED-APP-2027-069', 1280, 1, 16, 'Jared', 'Hove', 'student.jared.hove.069@seed.mssht.test', '0777000069', 'male', '2009-11-09', 'Seed House 069, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":16}', 6, '2027-03-25 09:00:00', '2026-05-28 15:47:15');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1279, 'SEED-APP-2027-070', 1281, 1, 16, 'Kudzai', 'Jele', 'student.kudzai.jele.070@seed.mssht.test', '0777000070', 'female', '2009-11-10', 'Seed House 070, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":16}', 6, '2027-03-26 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1280, 'SEED-APP-2027-071', 1282, 1, 16, 'Lerato', 'Kachidza', 'student.lerato.kachidza.071@seed.mssht.test', '0777000071', 'other', '2009-11-11', 'Seed House 071, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":16}', 6, '2027-03-27 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1281, 'SEED-APP-2027-072', 1283, 1, 16, 'Moses', 'Moyo', 'student.moses.moyo.072@seed.mssht.test', '0777000072', 'male', '2009-11-12', 'Seed House 072, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":16}', 6, '2027-03-28 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1282, 'SEED-APP-2027-073', 1284, 1, 16, 'Nadia', 'Ncube', 'student.nadia.ncube.073@seed.mssht.test', '0777000073', 'other', '2009-11-13', 'Seed House 073, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":16}', 6, '2027-03-29 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1283, 'SEED-APP-2027-074', 1285, 1, 16, 'Obert', 'Nyasha', 'student.obert.nyasha.074@seed.mssht.test', '0777000074', 'female', '2009-11-14', 'Seed House 074, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":16}', 6, '2027-03-30 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1284, 'SEED-APP-2027-075', 1286, 1, 16, 'Precious', 'Phiri', 'student.precious.phiri.075@seed.mssht.test', '0777000075', 'male', '2009-11-15', 'Seed House 075, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"SC-HOSP-101\",\"intake_id\":16}', 6, '2027-03-31 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1285, 'SEED-APP-2027-076', 1287, 2, 15, 'Tariro', 'Sibanda', 'student.tariro.sibanda.076@seed.mssht.test', '0777000076', 'female', '2009-11-16', 'Seed House 076, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":15}', 6, '2027-04-01 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1286, 'SEED-APP-2027-077', 1288, 2, 15, 'Unity', 'Tafara', 'student.unity.tafara.077@seed.mssht.test', '0777000077', 'other', '2009-11-17', 'Seed House 077, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":15}', 6, '2027-04-02 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1287, 'SEED-APP-2027-078', 1289, 2, 15, 'Vimbai', 'Vengesai', 'student.vimbai.vengesai.078@seed.mssht.test', '0777000078', 'male', '2009-11-18', 'Seed House 078, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":15}', 6, '2027-04-03 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1288, 'SEED-APP-2027-079', 1290, 2, 15, 'Wellington', 'Zhou', 'student.wellington.zhou.079@seed.mssht.test', '0777000079', 'other', '2009-11-19', 'Seed House 079, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":15}', 6, '2027-04-04 09:00:00', '2026-05-28 15:47:16');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1289, 'SEED-APP-2027-080', 1291, 2, 15, 'Amina', 'Banda', 'student.amina.banda.080@seed.mssht.test', '0777000080', 'female', '2009-11-20', 'Seed House 080, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":15}', 6, '2027-01-15 09:00:00', '2026-05-28 15:47:17');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1290, 'SEED-APP-2027-081', 1292, 2, 15, 'Blessing', 'Chirwa', 'student.blessing.chirwa.081@seed.mssht.test', '0777000081', 'male', '2009-11-21', 'Seed House 081, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":15}', 6, '2027-01-16 09:00:00', '2026-05-28 15:47:17');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1291, 'SEED-APP-2027-082', 1293, 2, 15, 'Chenai', 'Dube', 'student.chenai.dube.082@seed.mssht.test', '0777000082', 'female', '2009-11-22', 'Seed House 082, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":15}', 6, '2027-01-17 09:00:00', '2026-05-28 15:47:17');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1292, 'SEED-APP-2027-083', 1294, 2, 15, 'Derrick', 'Furusa', 'student.derrick.furusa.083@seed.mssht.test', '0777000083', 'other', '2009-11-23', 'Seed House 083, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":15}', 6, '2027-01-18 09:00:00', '2026-05-28 15:47:17');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1293, 'SEED-APP-2027-084', 1295, 2, 16, 'Elina', 'Gumbo', 'student.elina.gumbo.084@seed.mssht.test', '0777000084', 'male', '2009-11-24', 'Seed House 084, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":16}', 6, '2027-01-19 09:00:00', '2026-05-28 15:47:17');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1294, 'SEED-APP-2027-085', 1296, 2, 16, 'Farai', 'Hove', 'student.farai.hove.085@seed.mssht.test', '0777000085', 'other', '2009-11-25', 'Seed House 085, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":16}', 6, '2027-01-20 09:00:00', '2026-05-28 15:47:17');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1295, 'SEED-APP-2027-086', 1297, 2, 16, 'Godfrey', 'Jele', 'student.godfrey.jele.086@seed.mssht.test', '0777000086', 'female', '2009-11-26', 'Seed House 086, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":16}', 6, '2027-01-21 09:00:00', '2026-05-28 15:47:17');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1296, 'SEED-APP-2027-087', 1298, 2, 16, 'Hilda', 'Kachidza', 'student.hilda.kachidza.087@seed.mssht.test', '0777000087', 'male', '2009-11-27', 'Seed House 087, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":16}', 6, '2027-01-22 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1297, 'SEED-APP-2027-088', 1299, 2, 16, 'Ivy', 'Moyo', 'student.ivy.moyo.088@seed.mssht.test', '0777000088', 'female', '2009-11-28', 'Seed House 088, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":16}', 6, '2027-01-23 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1298, 'SEED-APP-2027-089', 1300, 2, 16, 'Jared', 'Ncube', 'student.jared.ncube.089@seed.mssht.test', '0777000089', 'other', '2009-11-29', 'Seed House 089, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":16}', 6, '2027-01-24 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1299, 'SEED-APP-2027-090', 1301, 2, 16, 'Kudzai', 'Nyasha', 'student.kudzai.nyasha.090@seed.mssht.test', '0777000090', 'male', '2009-11-30', 'Seed House 090, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"PC-CUL-201\",\"intake_id\":16}', 6, '2027-01-25 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1300, 'SEED-APP-2027-091', 1302, 3, 15, 'Lerato', 'Phiri', 'student.lerato.phiri.091@seed.mssht.test', '0777000091', 'other', '2009-12-01', 'Seed House 091, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":15}', 6, '2027-01-26 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1301, 'SEED-APP-2027-092', 1303, 3, 15, 'Moses', 'Sibanda', 'student.moses.sibanda.092@seed.mssht.test', '0777000092', 'female', '2009-12-02', 'Seed House 092, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":15}', 6, '2027-01-27 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1302, 'SEED-APP-2027-093', 1304, 3, 15, 'Nadia', 'Tafara', 'student.nadia.tafara.093@seed.mssht.test', '0777000093', 'male', '2009-12-03', 'Seed House 093, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":15}', 6, '2027-01-28 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1303, 'SEED-APP-2027-094', 1305, 3, 15, 'Obert', 'Vengesai', 'student.obert.vengesai.094@seed.mssht.test', '0777000094', 'female', '2009-12-04', 'Seed House 094, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":15}', 6, '2027-01-29 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1304, 'SEED-APP-2027-095', 1306, 3, 15, 'Precious', 'Zhou', 'student.precious.zhou.095@seed.mssht.test', '0777000095', 'other', '2009-12-05', 'Seed House 095, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":15}', 6, '2027-01-30 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1305, 'SEED-APP-2027-096', 1307, 3, 15, 'Tariro', 'Banda', 'student.tariro.banda.096@seed.mssht.test', '0777000096', 'male', '2009-12-06', 'Seed House 096, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":15}', 6, '2027-01-31 09:00:00', '2026-05-28 15:47:18');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1306, 'SEED-APP-2027-097', 1308, 3, 15, 'Unity', 'Chirwa', 'student.unity.chirwa.097@seed.mssht.test', '0777000097', 'other', '2009-12-07', 'Seed House 097, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":15}', 6, '2027-02-01 09:00:00', '2026-05-28 15:47:19');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1307, 'SEED-APP-2027-098', 1309, 3, 15, 'Vimbai', 'Dube', 'student.vimbai.dube.098@seed.mssht.test', '0777000098', 'female', '2009-12-08', 'Seed House 098, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":15}', 6, '2027-02-02 09:00:00', '2026-05-28 15:47:19');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1308, 'SEED-APP-2027-099', 1310, 3, 16, 'Wellington', 'Furusa', 'student.wellington.furusa.099@seed.mssht.test', '0777000099', 'male', '2009-12-09', 'Seed House 099, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":16}', 6, '2027-02-03 09:00:00', '2026-05-28 15:47:19');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1309, 'SEED-APP-2027-100', 1311, 3, 16, 'Amina', 'Gumbo', 'student.amina.gumbo.100@seed.mssht.test', '0777000100', 'female', '2009-12-10', 'Seed House 100, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":16}', 6, '2027-02-04 09:00:00', '2026-05-28 15:47:19');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1310, 'SEED-APP-2027-101', 1312, 3, 16, 'Blessing', 'Hove', 'student.blessing.hove.101@seed.mssht.test', '0777000101', 'other', '2009-12-11', 'Seed House 101, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":16}', 6, '2027-02-05 09:00:00', '2026-05-28 15:47:19');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1311, 'SEED-APP-2027-102', 1313, 3, 16, 'Chenai', 'Jele', 'student.chenai.jele.102@seed.mssht.test', '0777000102', 'male', '2009-12-12', 'Seed House 102, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":16}', 6, '2027-02-06 09:00:00', '2026-05-28 15:47:19');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1312, 'SEED-APP-2027-103', 1314, 3, 16, 'Derrick', 'Kachidza', 'student.derrick.kachidza.103@seed.mssht.test', '0777000103', 'other', '2009-12-13', 'Seed House 103, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":16}', 6, '2027-02-07 09:00:00', '2026-05-28 15:47:19');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1313, 'SEED-APP-2027-104', 1315, 3, 16, 'Elina', 'Moyo', 'student.elina.moyo.104@seed.mssht.test', '0777000104', 'female', '2009-12-14', 'Seed House 104, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":16}', 6, '2027-02-08 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1314, 'SEED-APP-2027-105', 1316, 3, 16, 'Farai', 'Ncube', 'student.farai.ncube.105@seed.mssht.test', '0777000105', 'male', '2009-12-15', 'Seed House 105, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"DIP-TOUR-301\",\"intake_id\":16}', 6, '2027-02-09 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1315, 'SEED-APP-2027-106', 1317, 4, 15, 'Godfrey', 'Nyasha', 'student.godfrey.nyasha.106@seed.mssht.test', '0777000106', 'female', '2009-12-16', 'Seed House 106, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":15}', 6, '2027-02-10 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1316, 'SEED-APP-2027-107', 1318, 4, 15, 'Hilda', 'Phiri', 'student.hilda.phiri.107@seed.mssht.test', '0777000107', 'other', '2009-12-17', 'Seed House 107, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":15}', 6, '2027-02-11 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1317, 'SEED-APP-2027-108', 1319, 4, 15, 'Ivy', 'Sibanda', 'student.ivy.sibanda.108@seed.mssht.test', '0777000108', 'male', '2009-12-18', 'Seed House 108, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":15}', 6, '2027-02-12 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1318, 'SEED-APP-2027-109', 1320, 4, 15, 'Jared', 'Tafara', 'student.jared.tafara.109@seed.mssht.test', '0777000109', 'other', '2009-12-19', 'Seed House 109, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":15}', 6, '2027-02-13 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1319, 'SEED-APP-2027-110', 1321, 4, 15, 'Kudzai', 'Vengesai', 'student.kudzai.vengesai.110@seed.mssht.test', '0777000110', 'female', '2009-12-20', 'Seed House 110, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":15}', 6, '2027-02-14 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1320, 'SEED-APP-2027-111', 1322, 4, 15, 'Lerato', 'Zhou', 'student.lerato.zhou.111@seed.mssht.test', '0777000111', 'male', '2009-12-21', 'Seed House 111, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":15}', 6, '2027-02-15 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1321, 'SEED-APP-2027-112', 1323, 4, 15, 'Moses', 'Banda', 'student.moses.banda.112@seed.mssht.test', '0777000112', 'female', '2009-12-22', 'Seed House 112, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":15}', 6, '2027-02-16 09:00:00', '2026-05-28 15:47:20');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1322, 'SEED-APP-2027-113', 1324, 4, 15, 'Nadia', 'Chirwa', 'student.nadia.chirwa.113@seed.mssht.test', '0777000113', 'other', '2009-12-23', 'Seed House 113, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":15}', 6, '2027-02-17 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1323, 'SEED-APP-2027-114', 1325, 4, 16, 'Obert', 'Dube', 'student.obert.dube.114@seed.mssht.test', '0777000114', 'male', '2009-12-24', 'Seed House 114, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":16}', 6, '2027-02-18 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1324, 'SEED-APP-2027-115', 1326, 4, 16, 'Precious', 'Furusa', 'student.precious.furusa.115@seed.mssht.test', '0777000115', 'other', '2009-12-25', 'Seed House 115, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":16}', 6, '2027-02-19 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1325, 'SEED-APP-2027-116', 1327, 4, 16, 'Tariro', 'Gumbo', 'student.tariro.gumbo.116@seed.mssht.test', '0777000116', 'female', '2009-12-26', 'Seed House 116, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":16}', 6, '2027-02-20 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1326, 'SEED-APP-2027-117', 1328, 4, 16, 'Unity', 'Hove', 'student.unity.hove.117@seed.mssht.test', '0777000117', 'male', '2009-12-27', 'Seed House 117, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":16}', 6, '2027-02-21 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1327, 'SEED-APP-2027-118', 1329, 4, 16, 'Vimbai', 'Jele', 'student.vimbai.jele.118@seed.mssht.test', '0777000118', 'female', '2009-12-28', 'Seed House 118, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":16}', 6, '2027-02-22 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1328, 'SEED-APP-2027-119', 1330, 4, 16, 'Wellington', 'Kachidza', 'student.wellington.kachidza.119@seed.mssht.test', '0777000119', 'other', '2009-12-29', 'Seed House 119, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":16}', 6, '2027-02-23 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `applications` (`id`,`application_ref`,`user_id`,`program_id`,`intake_id`,`first_name`,`last_name`,`email`,`phone`,`gender`,`date_of_birth`,`address`,`previous_qualification`,`status`,`notes`,`reviewed_by`,`reviewed_at`,`created_at`) VALUES (1329, 'SEED-APP-2027-120', 1331, 4, 16, 'Amina', 'Moyo', 'student.amina.moyo.120@seed.mssht.test', '0777000120', 'male', '2009-12-30', 'Seed House 120, Test Avenue, Harare', 'A-Level', 'approved', '{\"seed\":true,\"academic_year\":\"2027\",\"cohort\":\"HND-HOSP-401\",\"intake_id\":16}', 6, '2027-02-24 09:00:00', '2026-05-28 15:47:21');

-- Table: assessments
DROP TABLE IF EXISTS `assessments`;
CREATE TABLE `assessments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int(10) unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `assessment_type` enum('ca','exam','project','practical') NOT NULL,
  `weight_percent` decimal(5,2) DEFAULT 0.00,
  `max_score` decimal(6,2) DEFAULT 100.00,
  `scheduled_date` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `module_id` (`module_id`),
  CONSTRAINT `assessments_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=385 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (321, 1, 'Seed SC-HOSP-101 2026 SC-HOSP-101-M1 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (322, 1, 'Seed SC-HOSP-101 2026 SC-HOSP-101-M1 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (323, 1, 'Seed SC-HOSP-101 2027 SC-HOSP-101-M1 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (324, 1, 'Seed SC-HOSP-101 2027 SC-HOSP-101-M1 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (325, 2, 'Seed SC-HOSP-101 2026 SC-HOSP-101-M2 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (326, 2, 'Seed SC-HOSP-101 2026 SC-HOSP-101-M2 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (327, 2, 'Seed SC-HOSP-101 2027 SC-HOSP-101-M2 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (328, 2, 'Seed SC-HOSP-101 2027 SC-HOSP-101-M2 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (329, 3, 'Seed SC-HOSP-101 2026 SC-HOSP-101-M3 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (330, 3, 'Seed SC-HOSP-101 2026 SC-HOSP-101-M3 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (331, 3, 'Seed SC-HOSP-101 2027 SC-HOSP-101-M3 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (332, 3, 'Seed SC-HOSP-101 2027 SC-HOSP-101-M3 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (333, 4, 'Seed SC-HOSP-101 2026 SC-HOSP-101-M4 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (334, 4, 'Seed SC-HOSP-101 2026 SC-HOSP-101-M4 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:21');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (335, 4, 'Seed SC-HOSP-101 2027 SC-HOSP-101-M4 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (336, 4, 'Seed SC-HOSP-101 2027 SC-HOSP-101-M4 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (337, 5, 'Seed PC-CUL-201 2026 PC-CUL-201-M1 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (338, 5, 'Seed PC-CUL-201 2026 PC-CUL-201-M1 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (339, 5, 'Seed PC-CUL-201 2027 PC-CUL-201-M1 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (340, 5, 'Seed PC-CUL-201 2027 PC-CUL-201-M1 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (341, 6, 'Seed PC-CUL-201 2026 PC-CUL-201-M2 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (342, 6, 'Seed PC-CUL-201 2026 PC-CUL-201-M2 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (343, 6, 'Seed PC-CUL-201 2027 PC-CUL-201-M2 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (344, 6, 'Seed PC-CUL-201 2027 PC-CUL-201-M2 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (345, 7, 'Seed PC-CUL-201 2026 PC-CUL-201-M3 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (346, 7, 'Seed PC-CUL-201 2026 PC-CUL-201-M3 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (347, 7, 'Seed PC-CUL-201 2027 PC-CUL-201-M3 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (348, 7, 'Seed PC-CUL-201 2027 PC-CUL-201-M3 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (349, 8, 'Seed PC-CUL-201 2026 PC-CUL-201-M4 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (350, 8, 'Seed PC-CUL-201 2026 PC-CUL-201-M4 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (351, 8, 'Seed PC-CUL-201 2027 PC-CUL-201-M4 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (352, 8, 'Seed PC-CUL-201 2027 PC-CUL-201-M4 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (353, 9, 'Seed DIP-TOUR-301 2026 DIP-TOUR-301-M1 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (354, 9, 'Seed DIP-TOUR-301 2026 DIP-TOUR-301-M1 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (355, 9, 'Seed DIP-TOUR-301 2027 DIP-TOUR-301-M1 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (356, 9, 'Seed DIP-TOUR-301 2027 DIP-TOUR-301-M1 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (357, 10, 'Seed DIP-TOUR-301 2026 DIP-TOUR-301-M2 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (358, 10, 'Seed DIP-TOUR-301 2026 DIP-TOUR-301-M2 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (359, 10, 'Seed DIP-TOUR-301 2027 DIP-TOUR-301-M2 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (360, 10, 'Seed DIP-TOUR-301 2027 DIP-TOUR-301-M2 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (361, 11, 'Seed DIP-TOUR-301 2026 DIP-TOUR-301-M3 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (362, 11, 'Seed DIP-TOUR-301 2026 DIP-TOUR-301-M3 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (363, 11, 'Seed DIP-TOUR-301 2027 DIP-TOUR-301-M3 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (364, 11, 'Seed DIP-TOUR-301 2027 DIP-TOUR-301-M3 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (365, 12, 'Seed DIP-TOUR-301 2026 DIP-TOUR-301-M4 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (366, 12, 'Seed DIP-TOUR-301 2026 DIP-TOUR-301-M4 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (367, 12, 'Seed DIP-TOUR-301 2027 DIP-TOUR-301-M4 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (368, 12, 'Seed DIP-TOUR-301 2027 DIP-TOUR-301-M4 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (369, 13, 'Seed HND-HOSP-401 2026 HND-HOSP-401-M1 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (370, 13, 'Seed HND-HOSP-401 2026 HND-HOSP-401-M1 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (371, 13, 'Seed HND-HOSP-401 2027 HND-HOSP-401-M1 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (372, 13, 'Seed HND-HOSP-401 2027 HND-HOSP-401-M1 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (373, 14, 'Seed HND-HOSP-401 2026 HND-HOSP-401-M2 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (374, 14, 'Seed HND-HOSP-401 2026 HND-HOSP-401-M2 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (375, 14, 'Seed HND-HOSP-401 2027 HND-HOSP-401-M2 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (376, 14, 'Seed HND-HOSP-401 2027 HND-HOSP-401-M2 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (377, 15, 'Seed HND-HOSP-401 2026 HND-HOSP-401-M3 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (378, 15, 'Seed HND-HOSP-401 2026 HND-HOSP-401-M3 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (379, 15, 'Seed HND-HOSP-401 2027 HND-HOSP-401-M3 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (380, 15, 'Seed HND-HOSP-401 2027 HND-HOSP-401-M3 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (381, 16, 'Seed HND-HOSP-401 2026 HND-HOSP-401-M4 CA', 'ca', '40.00', '100.00', '2026-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (382, 16, 'Seed HND-HOSP-401 2026 HND-HOSP-401-M4 Exam', 'exam', '60.00', '100.00', '2026-11-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (383, 16, 'Seed HND-HOSP-401 2027 HND-HOSP-401-M4 CA', 'ca', '40.00', '100.00', '2027-04-15 09:00:00', '2026-05-28 15:47:22');
INSERT INTO `assessments` (`id`,`module_id`,`title`,`assessment_type`,`weight_percent`,`max_score`,`scheduled_date`,`created_at`) VALUES (384, 16, 'Seed HND-HOSP-401 2027 HND-HOSP-401-M4 Exam', 'exam', '60.00', '100.00', '2027-11-15 09:00:00', '2026-05-28 15:47:22');

-- Table: assets
DROP TABLE IF EXISTS `assets`;
CREATE TABLE `assets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `asset_tag` varchar(40) NOT NULL,
  `name` varchar(200) NOT NULL,
  `category` enum('computer','vehicle','furniture','lab','other') DEFAULT 'other',
  `purchase_date` date DEFAULT NULL,
  `purchase_cost` decimal(14,2) DEFAULT 0.00,
  `location` varchar(120) DEFAULT NULL,
  `status` enum('active','disposed','maintenance') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `asset_tag` (`asset_tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: assignment_submissions
DROP TABLE IF EXISTS `assignment_submissions`;
CREATE TABLE `assignment_submissions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `assignment_id` int(10) unsigned NOT NULL,
  `student_id` int(10) unsigned NOT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `score` decimal(6,2) DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_assignment_student` (`assignment_id`,`student_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `assignment_submissions_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_submissions_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: assignments
DROP TABLE IF EXISTS `assignments`;
CREATE TABLE `assignments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int(10) unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `due_date` datetime NOT NULL,
  `max_score` decimal(6,2) DEFAULT 100.00,
  `created_by` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `module_id` (`module_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE,
  CONSTRAINT `assignments_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: attendance_records
DROP TABLE IF EXISTS `attendance_records`;
CREATE TABLE `attendance_records` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` int(10) unsigned NOT NULL,
  `student_id` int(10) unsigned NOT NULL,
  `status` enum('present','absent','late','excused') DEFAULT 'present',
  `marked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_session_student` (`session_id`,`student_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `attendance_records_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `attendance_sessions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_records_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=631 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (391, 27, 1202, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (392, 27, 1203, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (393, 27, 1204, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (394, 27, 1205, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (395, 27, 1206, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (396, 27, 1207, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (397, 27, 1208, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (398, 27, 1209, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (399, 27, 1210, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (400, 27, 1211, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (401, 27, 1212, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (402, 27, 1213, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (403, 27, 1214, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (404, 27, 1215, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (405, 27, 1216, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (406, 28, 1202, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (407, 28, 1203, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (408, 28, 1204, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (409, 28, 1205, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (410, 28, 1206, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (411, 28, 1207, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (412, 28, 1208, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (413, 28, 1209, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (414, 28, 1210, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (415, 28, 1211, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (416, 28, 1212, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (417, 28, 1213, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (418, 28, 1214, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (419, 28, 1215, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (420, 28, 1216, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (421, 29, 1217, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (422, 29, 1218, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (423, 29, 1219, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (424, 29, 1220, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (425, 29, 1221, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (426, 29, 1222, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (427, 29, 1223, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (428, 29, 1224, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (429, 29, 1225, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (430, 29, 1226, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (431, 29, 1227, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (432, 29, 1228, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (433, 29, 1229, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (434, 29, 1230, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (435, 29, 1231, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (436, 30, 1217, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (437, 30, 1218, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (438, 30, 1219, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (439, 30, 1220, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (440, 30, 1221, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (441, 30, 1222, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (442, 30, 1223, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (443, 30, 1224, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (444, 30, 1225, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (445, 30, 1226, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (446, 30, 1227, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (447, 30, 1228, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (448, 30, 1229, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (449, 30, 1230, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (450, 30, 1231, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (451, 31, 1232, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (452, 31, 1233, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (453, 31, 1234, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (454, 31, 1235, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (455, 31, 1236, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (456, 31, 1237, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (457, 31, 1238, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (458, 31, 1239, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (459, 31, 1240, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (460, 31, 1241, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (461, 31, 1242, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (462, 31, 1243, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (463, 31, 1244, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (464, 31, 1245, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (465, 31, 1246, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (466, 32, 1232, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (467, 32, 1233, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (468, 32, 1234, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (469, 32, 1235, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (470, 32, 1236, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (471, 32, 1237, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (472, 32, 1238, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (473, 32, 1239, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (474, 32, 1240, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (475, 32, 1241, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (476, 32, 1242, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (477, 32, 1243, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (478, 32, 1244, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (479, 32, 1245, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (480, 32, 1246, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (481, 33, 1247, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (482, 33, 1248, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (483, 33, 1249, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (484, 33, 1250, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (485, 33, 1251, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (486, 33, 1252, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (487, 33, 1253, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (488, 33, 1254, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (489, 33, 1255, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (490, 33, 1256, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (491, 33, 1257, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (492, 33, 1258, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (493, 33, 1259, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (494, 33, 1260, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (495, 33, 1261, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (496, 34, 1247, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (497, 34, 1248, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (498, 34, 1249, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (499, 34, 1250, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (500, 34, 1251, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (501, 34, 1252, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (502, 34, 1253, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (503, 34, 1254, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (504, 34, 1255, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (505, 34, 1256, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (506, 34, 1257, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (507, 34, 1258, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (508, 34, 1259, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (509, 34, 1260, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (510, 34, 1261, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (511, 35, 1262, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (512, 35, 1263, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (513, 35, 1264, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (514, 35, 1265, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (515, 35, 1266, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (516, 35, 1267, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (517, 35, 1268, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (518, 35, 1269, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (519, 35, 1270, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (520, 35, 1271, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (521, 35, 1272, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (522, 35, 1273, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (523, 35, 1274, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (524, 35, 1275, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (525, 35, 1276, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (526, 36, 1262, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (527, 36, 1263, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (528, 36, 1264, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (529, 36, 1265, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (530, 36, 1266, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (531, 36, 1267, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (532, 36, 1268, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (533, 36, 1269, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (534, 36, 1270, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (535, 36, 1271, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (536, 36, 1272, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (537, 36, 1273, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (538, 36, 1274, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (539, 36, 1275, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (540, 36, 1276, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (541, 37, 1277, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (542, 37, 1278, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (543, 37, 1279, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (544, 37, 1280, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (545, 37, 1281, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (546, 37, 1282, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (547, 37, 1283, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (548, 37, 1284, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (549, 37, 1285, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (550, 37, 1286, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (551, 37, 1287, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (552, 37, 1288, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (553, 37, 1289, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (554, 37, 1290, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (555, 37, 1291, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (556, 38, 1277, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (557, 38, 1278, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (558, 38, 1279, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (559, 38, 1280, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (560, 38, 1281, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (561, 38, 1282, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (562, 38, 1283, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (563, 38, 1284, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (564, 38, 1285, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (565, 38, 1286, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (566, 38, 1287, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (567, 38, 1288, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (568, 38, 1289, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (569, 38, 1290, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (570, 38, 1291, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (571, 39, 1292, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (572, 39, 1293, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (573, 39, 1294, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (574, 39, 1295, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (575, 39, 1296, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (576, 39, 1297, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (577, 39, 1298, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (578, 39, 1299, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (579, 39, 1300, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (580, 39, 1301, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (581, 39, 1302, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (582, 39, 1303, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (583, 39, 1304, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (584, 39, 1305, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (585, 39, 1306, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (586, 40, 1292, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (587, 40, 1293, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (588, 40, 1294, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (589, 40, 1295, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (590, 40, 1296, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (591, 40, 1297, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (592, 40, 1298, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (593, 40, 1299, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (594, 40, 1300, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (595, 40, 1301, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (596, 40, 1302, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (597, 40, 1303, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (598, 40, 1304, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (599, 40, 1305, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (600, 40, 1306, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (601, 41, 1307, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (602, 41, 1308, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (603, 41, 1309, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (604, 41, 1310, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (605, 41, 1311, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (606, 41, 1312, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (607, 41, 1313, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (608, 41, 1314, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (609, 41, 1315, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (610, 41, 1316, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (611, 41, 1317, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (612, 41, 1318, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (613, 41, 1319, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (614, 41, 1320, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (615, 41, 1321, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (616, 42, 1307, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (617, 42, 1308, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (618, 42, 1309, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (619, 42, 1310, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (620, 42, 1311, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (621, 42, 1312, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (622, 42, 1313, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (623, 42, 1314, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (624, 42, 1315, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (625, 42, 1316, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (626, 42, 1317, 'excused', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (627, 42, 1318, 'present', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (628, 42, 1319, 'late', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (629, 42, 1320, 'absent', '2026-05-28 15:47:22');
INSERT INTO `attendance_records` (`id`,`session_id`,`student_id`,`status`,`marked_at`) VALUES (630, 42, 1321, 'excused', '2026-05-28 15:47:22');

-- Table: attendance_sessions
DROP TABLE IF EXISTS `attendance_sessions`;
CREATE TABLE `attendance_sessions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int(10) unsigned NOT NULL,
  `session_date` date NOT NULL,
  `qr_token` varchar(64) NOT NULL,
  `created_by` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `qr_token` (`qr_token`),
  KEY `module_id` (`module_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `attendance_sessions_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_sessions_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (27, 1, '2026-03-01', '44caae832baf630970d60fbe2cb6844b', 8, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (28, 1, '2026-03-22', 'dd74a0278504248c2f16471d6af5ba3b', 9, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (29, 3, '2026-03-01', 'd7248f215a568d67c221722f91e3a7b7', 8, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (30, 3, '2026-03-22', '4bc06164e54632a1c1f79f4d0c868d5c', 9, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (31, 4, '2026-03-01', '7ddbad754231ed50c15424dd0fb76655', 8, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (32, 4, '2026-03-22', '7f17b92e450249d435f6f09e09bc10ef', 9, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (33, 5, '2026-03-01', 'bea6aa546938ad9fefd950e43b353039', 8, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (34, 5, '2026-03-22', '1585bc57aaa0254931569988f15edab3', 9, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (35, 2, '2027-03-01', 'ec3a9500bc89107307346d47e210b625', 8, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (36, 2, '2027-03-22', '3369bfe91742051a1e3b30831584a6d5', 9, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (37, 6, '2027-03-01', 'b5446a7c00b1e7135f3db80b260ffeab', 8, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (38, 6, '2027-03-22', '6430cf9d632712485f7e30c16a16b98d', 9, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (39, 7, '2027-03-01', 'a5d1eda5f2c6a9f7e327b5cb345bb2d6', 8, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (40, 7, '2027-03-22', '6adb4543ef6dccc695cf4ec737cabec5', 9, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (41, 8, '2027-03-01', '4e7bc9af60635c73594d049e1e1f246f', 8, '2026-05-28 15:47:22');
INSERT INTO `attendance_sessions` (`id`,`module_id`,`session_date`,`qr_token`,`created_by`,`created_at`) VALUES (42, 8, '2027-03-22', 'fd1731496612cdecf5c299d2e79c60fe', 9, '2026-05-28 15:47:22');

-- Table: audit_logs
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` int(10) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1348 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1, 1, 'login', 'user', 1, '::1', '2026-05-21 09:49:53');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (2, 1, 'logout', 'user', 1, '::1', '2026-05-27 10:15:38');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (3, 1, 'login', 'user', 1, '::1', '2026-05-27 13:09:58');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (4, 1, 'student_portal_created', 'student', 1, '::1', '2026-05-27 13:17:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (5, 1, 'application_approved', 'application', 1, '::1', '2026-05-27 13:17:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (6, 1, 'logout', 'user', 1, '::1', '2026-05-27 13:17:29');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (7, NULL, 'applicant_portal_created', 'application', 2, NULL, '2026-05-27 13:27:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (8, 1, 'login', 'user', 1, '::1', '2026-05-27 13:38:54');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (9, 4, 'login', 'user', 4, '::1', '2026-05-27 14:08:22');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (11, 4, 'login', 'user', 4, '::1', '2026-05-27 14:15:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (12, 4, 'login', 'user', 4, '::1', '2026-05-27 15:58:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (13, 1, 'login', 'user', 1, '::1', '2026-05-27 16:20:39');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (14, 1, 'logout', 'user', 1, '::1', '2026-05-27 16:27:50');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (15, 2, 'login', 'user', 2, '::1', '2026-05-27 16:28:05');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (16, 2, 'login', 'user', 2, '::1', '2026-05-28 08:55:35');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (17, 4, 'login', 'user', 4, '::1', '2026-05-28 09:16:33');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (18, 4, 'logout', 'user', 4, '::1', '2026-05-28 09:18:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (19, 2, 'login', 'user', 2, '::1', '2026-05-28 09:18:49');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (20, 4, 'login', 'user', 4, '::1', '2026-05-28 10:10:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (21, 4, 'logout', 'user', 4, '::1', '2026-05-28 10:27:07');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (22, 4, 'login', 'user', 4, '::1', '2026-05-28 10:27:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (23, 4, 'logout', 'user', 4, '::1', '2026-05-28 10:27:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (24, 2, 'login', 'user', 2, '::1', '2026-05-28 10:27:44');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (325, 2, 'logout', 'user', 2, '::1', '2026-05-28 14:24:08');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (326, 2, 'login', 'user', 2, '::1', '2026-05-28 14:24:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1227, NULL, 'student_portal_created', 'student', 1202, NULL, '2026-05-28 15:47:08');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1228, NULL, 'student_portal_created', 'student', 1203, NULL, '2026-05-28 15:47:09');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1229, NULL, 'student_portal_created', 'student', 1204, NULL, '2026-05-28 15:47:09');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1230, NULL, 'student_portal_created', 'student', 1205, NULL, '2026-05-28 15:47:09');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1231, NULL, 'student_portal_created', 'student', 1206, NULL, '2026-05-28 15:47:09');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1232, NULL, 'student_portal_created', 'student', 1207, NULL, '2026-05-28 15:47:09');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1233, NULL, 'student_portal_created', 'student', 1208, NULL, '2026-05-28 15:47:09');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1234, NULL, 'student_portal_created', 'student', 1209, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1235, NULL, 'student_portal_created', 'student', 1210, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1236, NULL, 'student_portal_created', 'student', 1211, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1237, NULL, 'student_portal_created', 'student', 1212, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1238, NULL, 'student_portal_created', 'student', 1213, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1239, NULL, 'student_portal_created', 'student', 1214, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1240, NULL, 'student_portal_created', 'student', 1215, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1241, NULL, 'student_portal_created', 'student', 1216, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1242, NULL, 'student_portal_created', 'student', 1217, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1243, NULL, 'student_portal_created', 'student', 1218, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1244, NULL, 'student_portal_created', 'student', 1219, NULL, '2026-05-28 15:47:10');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1245, NULL, 'student_portal_created', 'student', 1220, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1246, NULL, 'student_portal_created', 'student', 1221, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1247, NULL, 'student_portal_created', 'student', 1222, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1248, NULL, 'student_portal_created', 'student', 1223, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1249, NULL, 'student_portal_created', 'student', 1224, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1250, NULL, 'student_portal_created', 'student', 1225, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1251, NULL, 'student_portal_created', 'student', 1226, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1252, NULL, 'student_portal_created', 'student', 1227, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1253, NULL, 'student_portal_created', 'student', 1228, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1254, NULL, 'student_portal_created', 'student', 1229, NULL, '2026-05-28 15:47:11');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1255, NULL, 'student_portal_created', 'student', 1230, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1256, NULL, 'student_portal_created', 'student', 1231, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1257, NULL, 'student_portal_created', 'student', 1232, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1258, NULL, 'student_portal_created', 'student', 1233, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1259, NULL, 'student_portal_created', 'student', 1234, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1260, NULL, 'student_portal_created', 'student', 1235, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1261, NULL, 'student_portal_created', 'student', 1236, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1262, NULL, 'student_portal_created', 'student', 1237, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1263, NULL, 'student_portal_created', 'student', 1238, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1264, NULL, 'student_portal_created', 'student', 1239, NULL, '2026-05-28 15:47:12');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1265, NULL, 'student_portal_created', 'student', 1240, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1266, NULL, 'student_portal_created', 'student', 1241, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1267, NULL, 'student_portal_created', 'student', 1242, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1268, NULL, 'student_portal_created', 'student', 1243, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1269, NULL, 'student_portal_created', 'student', 1244, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1270, NULL, 'student_portal_created', 'student', 1245, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1271, NULL, 'student_portal_created', 'student', 1246, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1272, NULL, 'student_portal_created', 'student', 1247, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1273, NULL, 'student_portal_created', 'student', 1248, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1274, NULL, 'student_portal_created', 'student', 1249, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1275, NULL, 'student_portal_created', 'student', 1250, NULL, '2026-05-28 15:47:13');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1276, NULL, 'student_portal_created', 'student', 1251, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1277, NULL, 'student_portal_created', 'student', 1252, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1278, NULL, 'student_portal_created', 'student', 1253, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1279, NULL, 'student_portal_created', 'student', 1254, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1280, NULL, 'student_portal_created', 'student', 1255, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1281, NULL, 'student_portal_created', 'student', 1256, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1282, NULL, 'student_portal_created', 'student', 1257, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1283, NULL, 'student_portal_created', 'student', 1258, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1284, NULL, 'student_portal_created', 'student', 1259, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1285, NULL, 'student_portal_created', 'student', 1260, NULL, '2026-05-28 15:47:14');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1286, NULL, 'student_portal_created', 'student', 1261, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1287, NULL, 'student_portal_created', 'student', 1262, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1288, NULL, 'student_portal_created', 'student', 1263, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1289, NULL, 'student_portal_created', 'student', 1264, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1290, NULL, 'student_portal_created', 'student', 1265, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1291, NULL, 'student_portal_created', 'student', 1266, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1292, NULL, 'student_portal_created', 'student', 1267, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1293, NULL, 'student_portal_created', 'student', 1268, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1294, NULL, 'student_portal_created', 'student', 1269, NULL, '2026-05-28 15:47:15');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1295, NULL, 'student_portal_created', 'student', 1270, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1296, NULL, 'student_portal_created', 'student', 1271, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1297, NULL, 'student_portal_created', 'student', 1272, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1298, NULL, 'student_portal_created', 'student', 1273, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1299, NULL, 'student_portal_created', 'student', 1274, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1300, NULL, 'student_portal_created', 'student', 1275, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1301, NULL, 'student_portal_created', 'student', 1276, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1302, NULL, 'student_portal_created', 'student', 1277, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1303, NULL, 'student_portal_created', 'student', 1278, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1304, NULL, 'student_portal_created', 'student', 1279, NULL, '2026-05-28 15:47:16');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1305, NULL, 'student_portal_created', 'student', 1280, NULL, '2026-05-28 15:47:17');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1306, NULL, 'student_portal_created', 'student', 1281, NULL, '2026-05-28 15:47:17');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1307, NULL, 'student_portal_created', 'student', 1282, NULL, '2026-05-28 15:47:17');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1308, NULL, 'student_portal_created', 'student', 1283, NULL, '2026-05-28 15:47:17');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1309, NULL, 'student_portal_created', 'student', 1284, NULL, '2026-05-28 15:47:17');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1310, NULL, 'student_portal_created', 'student', 1285, NULL, '2026-05-28 15:47:17');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1311, NULL, 'student_portal_created', 'student', 1286, NULL, '2026-05-28 15:47:17');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1312, NULL, 'student_portal_created', 'student', 1287, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1313, NULL, 'student_portal_created', 'student', 1288, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1314, NULL, 'student_portal_created', 'student', 1289, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1315, NULL, 'student_portal_created', 'student', 1290, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1316, NULL, 'student_portal_created', 'student', 1291, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1317, NULL, 'student_portal_created', 'student', 1292, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1318, NULL, 'student_portal_created', 'student', 1293, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1319, NULL, 'student_portal_created', 'student', 1294, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1320, NULL, 'student_portal_created', 'student', 1295, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1321, NULL, 'student_portal_created', 'student', 1296, NULL, '2026-05-28 15:47:18');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1322, NULL, 'student_portal_created', 'student', 1297, NULL, '2026-05-28 15:47:19');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1323, NULL, 'student_portal_created', 'student', 1298, NULL, '2026-05-28 15:47:19');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1324, NULL, 'student_portal_created', 'student', 1299, NULL, '2026-05-28 15:47:19');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1325, NULL, 'student_portal_created', 'student', 1300, NULL, '2026-05-28 15:47:19');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1326, NULL, 'student_portal_created', 'student', 1301, NULL, '2026-05-28 15:47:19');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1327, NULL, 'student_portal_created', 'student', 1302, NULL, '2026-05-28 15:47:19');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1328, NULL, 'student_portal_created', 'student', 1303, NULL, '2026-05-28 15:47:19');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1329, NULL, 'student_portal_created', 'student', 1304, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1330, NULL, 'student_portal_created', 'student', 1305, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1331, NULL, 'student_portal_created', 'student', 1306, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1332, NULL, 'student_portal_created', 'student', 1307, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1333, NULL, 'student_portal_created', 'student', 1308, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1334, NULL, 'student_portal_created', 'student', 1309, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1335, NULL, 'student_portal_created', 'student', 1310, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1336, NULL, 'student_portal_created', 'student', 1311, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1337, NULL, 'student_portal_created', 'student', 1312, NULL, '2026-05-28 15:47:20');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1338, NULL, 'student_portal_created', 'student', 1313, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1339, NULL, 'student_portal_created', 'student', 1314, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1340, NULL, 'student_portal_created', 'student', 1315, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1341, NULL, 'student_portal_created', 'student', 1316, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1342, NULL, 'student_portal_created', 'student', 1317, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1343, NULL, 'student_portal_created', 'student', 1318, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1344, NULL, 'student_portal_created', 'student', 1319, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1345, NULL, 'student_portal_created', 'student', 1320, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1346, NULL, 'student_portal_created', 'student', 1321, NULL, '2026-05-28 15:47:21');
INSERT INTO `audit_logs` (`id`,`user_id`,`action`,`entity_type`,`entity_id`,`ip_address`,`created_at`) VALUES (1347, 2, 'login', 'user', 2, '::1', '2026-05-29 08:42:46');

-- Table: bank_accounts
DROP TABLE IF EXISTS `bank_accounts`;
CREATE TABLE `bank_accounts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `bank_name` varchar(100) NOT NULL,
  `account_number` varchar(50) NOT NULL,
  `currency` enum('USD','ZWL') DEFAULT 'USD',
  `opening_balance` decimal(14,2) DEFAULT 0.00,
  `current_balance` decimal(14,2) DEFAULT 0.00,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `bank_accounts` (`id`,`name`,`bank_name`,`account_number`,`currency`,`opening_balance`,`current_balance`,`is_active`) VALUES (3, 'Seed Tuition Main Account', 'Seed Bank', '111100001111', 'USD', '25000.00', '25000.00', 1);
INSERT INTO `bank_accounts` (`id`,`name`,`bank_name`,`account_number`,`currency`,`opening_balance`,`current_balance`,`is_active`) VALUES (4, 'Seed Operations Account', 'Seed Bank', '222200002222', 'USD', '25000.00', '25000.00', 1);

-- Table: bank_transactions
DROP TABLE IF EXISTS `bank_transactions`;
CREATE TABLE `bank_transactions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bank_account_id` int(10) unsigned NOT NULL,
  `txn_date` date NOT NULL,
  `description` varchar(255) NOT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `amount` decimal(14,2) NOT NULL,
  `txn_type` enum('credit','debit') NOT NULL,
  `matched_payment_id` int(10) unsigned DEFAULT NULL,
  `is_reconciled` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `bank_account_id` (`bank_account_id`),
  KEY `matched_payment_id` (`matched_payment_id`),
  CONSTRAINT `bank_transactions_ibfk_1` FOREIGN KEY (`bank_account_id`) REFERENCES `bank_accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bank_transactions_ibfk_2` FOREIGN KEY (`matched_payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (61, 3, '0000-00-00', 'Seed tuition receipt 1', 'SEEDPAY0001', '250.00', 'credit', 61, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (62, 3, '0000-00-00', 'Seed tuition receipt 3', 'SEEDPAY0003', '350.00', 'credit', 62, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (63, 3, '0000-00-00', 'Seed tuition receipt 5', 'SEEDPAY0005', '300.00', 'credit', 63, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (64, 3, '0000-00-00', 'Seed tuition receipt 7', 'SEEDPAY0007', '250.00', 'credit', 64, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (65, 3, '0000-00-00', 'Seed tuition receipt 9', 'SEEDPAY0009', '350.00', 'credit', 65, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (66, 3, '0000-00-00', 'Seed tuition receipt 11', 'SEEDPAY0011', '300.00', 'credit', 66, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (67, 3, '0000-00-00', 'Seed tuition receipt 13', 'SEEDPAY0013', '250.00', 'credit', 67, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (68, 3, '0000-00-00', 'Seed tuition receipt 15', 'SEEDPAY0015', '350.00', 'credit', 68, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (69, 3, '0000-00-00', 'Seed tuition receipt 17', 'SEEDPAY0017', '300.00', 'credit', 69, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (70, 3, '0000-00-00', 'Seed tuition receipt 19', 'SEEDPAY0019', '250.00', 'credit', 70, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (71, 3, '0000-00-00', 'Seed tuition receipt 21', 'SEEDPAY0021', '350.00', 'credit', 71, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (72, 3, '0000-00-00', 'Seed tuition receipt 23', 'SEEDPAY0023', '300.00', 'credit', 72, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (73, 3, '0000-00-00', 'Seed tuition receipt 25', 'SEEDPAY0025', '250.00', 'credit', 73, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (74, 3, '0000-00-00', 'Seed tuition receipt 27', 'SEEDPAY0027', '350.00', 'credit', 74, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (75, 3, '0000-00-00', 'Seed tuition receipt 29', 'SEEDPAY0029', '300.00', 'credit', 75, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (76, 3, '0000-00-00', 'Seed tuition receipt 31', 'SEEDPAY0031', '250.00', 'credit', 76, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (77, 3, '0000-00-00', 'Seed tuition receipt 33', 'SEEDPAY0033', '350.00', 'credit', 77, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (78, 3, '0000-00-00', 'Seed tuition receipt 35', 'SEEDPAY0035', '300.00', 'credit', 78, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (79, 3, '0000-00-00', 'Seed tuition receipt 37', 'SEEDPAY0037', '250.00', 'credit', 79, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (80, 3, '0000-00-00', 'Seed tuition receipt 39', 'SEEDPAY0039', '350.00', 'credit', 80, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (81, 3, '0000-00-00', 'Seed tuition receipt 41', 'SEEDPAY0041', '300.00', 'credit', 81, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (82, 3, '0000-00-00', 'Seed tuition receipt 43', 'SEEDPAY0043', '250.00', 'credit', 82, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (83, 3, '0000-00-00', 'Seed tuition receipt 45', 'SEEDPAY0045', '350.00', 'credit', 83, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (84, 3, '0000-00-00', 'Seed tuition receipt 47', 'SEEDPAY0047', '300.00', 'credit', 84, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (85, 3, '0000-00-00', 'Seed tuition receipt 49', 'SEEDPAY0049', '250.00', 'credit', 85, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (86, 3, '0000-00-00', 'Seed tuition receipt 51', 'SEEDPAY0051', '350.00', 'credit', 86, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (87, 3, '0000-00-00', 'Seed tuition receipt 53', 'SEEDPAY0053', '300.00', 'credit', 87, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (88, 3, '0000-00-00', 'Seed tuition receipt 55', 'SEEDPAY0055', '250.00', 'credit', 88, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (89, 3, '0000-00-00', 'Seed tuition receipt 57', 'SEEDPAY0057', '350.00', 'credit', 89, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (90, 3, '0000-00-00', 'Seed tuition receipt 59', 'SEEDPAY0059', '300.00', 'credit', 90, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (91, 3, '0000-00-00', 'Seed tuition receipt 61', 'SEEDPAY0061', '250.00', 'credit', 91, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (92, 3, '0000-00-00', 'Seed tuition receipt 63', 'SEEDPAY0063', '350.00', 'credit', 92, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (93, 3, '0000-00-00', 'Seed tuition receipt 65', 'SEEDPAY0065', '300.00', 'credit', 93, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (94, 3, '0000-00-00', 'Seed tuition receipt 67', 'SEEDPAY0067', '250.00', 'credit', 94, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (95, 3, '0000-00-00', 'Seed tuition receipt 69', 'SEEDPAY0069', '350.00', 'credit', 95, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (96, 3, '0000-00-00', 'Seed tuition receipt 71', 'SEEDPAY0071', '300.00', 'credit', 96, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (97, 3, '0000-00-00', 'Seed tuition receipt 73', 'SEEDPAY0073', '250.00', 'credit', 97, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (98, 3, '0000-00-00', 'Seed tuition receipt 75', 'SEEDPAY0075', '350.00', 'credit', 98, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (99, 3, '0000-00-00', 'Seed tuition receipt 77', 'SEEDPAY0077', '300.00', 'credit', 99, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (100, 3, '0000-00-00', 'Seed tuition receipt 79', 'SEEDPAY0079', '250.00', 'credit', 100, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (101, 3, '0000-00-00', 'Seed tuition receipt 81', 'SEEDPAY0081', '350.00', 'credit', 101, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (102, 3, '0000-00-00', 'Seed tuition receipt 83', 'SEEDPAY0083', '300.00', 'credit', 102, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (103, 3, '0000-00-00', 'Seed tuition receipt 85', 'SEEDPAY0085', '250.00', 'credit', 103, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (104, 3, '0000-00-00', 'Seed tuition receipt 87', 'SEEDPAY0087', '350.00', 'credit', 104, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (105, 3, '0000-00-00', 'Seed tuition receipt 89', 'SEEDPAY0089', '300.00', 'credit', 105, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (106, 3, '0000-00-00', 'Seed tuition receipt 91', 'SEEDPAY0091', '250.00', 'credit', 106, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (107, 3, '0000-00-00', 'Seed tuition receipt 93', 'SEEDPAY0093', '350.00', 'credit', 107, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (108, 3, '0000-00-00', 'Seed tuition receipt 95', 'SEEDPAY0095', '300.00', 'credit', 108, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (109, 3, '0000-00-00', 'Seed tuition receipt 97', 'SEEDPAY0097', '250.00', 'credit', 109, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (110, 3, '0000-00-00', 'Seed tuition receipt 99', 'SEEDPAY0099', '350.00', 'credit', 110, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (111, 3, '0000-00-00', 'Seed tuition receipt 101', 'SEEDPAY0101', '300.00', 'credit', 111, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (112, 3, '0000-00-00', 'Seed tuition receipt 103', 'SEEDPAY0103', '250.00', 'credit', 112, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (113, 3, '0000-00-00', 'Seed tuition receipt 105', 'SEEDPAY0105', '350.00', 'credit', 113, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (114, 3, '0000-00-00', 'Seed tuition receipt 107', 'SEEDPAY0107', '300.00', 'credit', 114, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (115, 3, '0000-00-00', 'Seed tuition receipt 109', 'SEEDPAY0109', '250.00', 'credit', 115, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (116, 3, '0000-00-00', 'Seed tuition receipt 111', 'SEEDPAY0111', '350.00', 'credit', 116, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (117, 3, '0000-00-00', 'Seed tuition receipt 113', 'SEEDPAY0113', '300.00', 'credit', 117, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (118, 3, '0000-00-00', 'Seed tuition receipt 115', 'SEEDPAY0115', '250.00', 'credit', 118, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (119, 3, '0000-00-00', 'Seed tuition receipt 117', 'SEEDPAY0117', '350.00', 'credit', 119, 1);
INSERT INTO `bank_transactions` (`id`,`bank_account_id`,`txn_date`,`description`,`reference`,`amount`,`txn_type`,`matched_payment_id`,`is_reconciled`) VALUES (120, 3, '0000-00-00', 'Seed tuition receipt 119', 'SEEDPAY0119', '300.00', 'credit', 120, 1);

-- Table: budgets
DROP TABLE IF EXISTS `budgets`;
CREATE TABLE `budgets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `department` varchar(100) NOT NULL,
  `fiscal_year` varchar(20) NOT NULL,
  `budget_type` enum('operational','capital') DEFAULT 'operational',
  `total_amount` decimal(14,2) NOT NULL,
  `spent_amount` decimal(14,2) DEFAULT 0.00,
  `status` enum('draft','approved','closed') DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: chart_of_accounts
DROP TABLE IF EXISTS `chart_of_accounts`;
CREATE TABLE `chart_of_accounts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(150) NOT NULL,
  `account_type` enum('asset','liability','equity','revenue','expense') NOT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `chart_of_accounts` (`id`,`code`,`name`,`account_type`,`parent_id`,`is_active`) VALUES (1, '1000', 'Cash & Bank', 'asset', NULL, 1);
INSERT INTO `chart_of_accounts` (`id`,`code`,`name`,`account_type`,`parent_id`,`is_active`) VALUES (2, '1100', 'Accounts Receivable', 'asset', NULL, 1);
INSERT INTO `chart_of_accounts` (`id`,`code`,`name`,`account_type`,`parent_id`,`is_active`) VALUES (3, '2000', 'Accounts Payable', 'liability', NULL, 1);
INSERT INTO `chart_of_accounts` (`id`,`code`,`name`,`account_type`,`parent_id`,`is_active`) VALUES (4, '3000', 'Equity', 'equity', NULL, 1);
INSERT INTO `chart_of_accounts` (`id`,`code`,`name`,`account_type`,`parent_id`,`is_active`) VALUES (5, '4000', 'Tuition Revenue', 'revenue', NULL, 1);
INSERT INTO `chart_of_accounts` (`id`,`code`,`name`,`account_type`,`parent_id`,`is_active`) VALUES (6, '4100', 'Other Revenue', 'revenue', NULL, 1);
INSERT INTO `chart_of_accounts` (`id`,`code`,`name`,`account_type`,`parent_id`,`is_active`) VALUES (7, '5000', 'Operating Expenses', 'expense', NULL, 1);
INSERT INTO `chart_of_accounts` (`id`,`code`,`name`,`account_type`,`parent_id`,`is_active`) VALUES (8, '5100', 'Payroll Expenses', 'expense', NULL, 1);

-- Table: class_assignments
DROP TABLE IF EXISTS `class_assignments`;
CREATE TABLE `class_assignments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_id` int(10) unsigned NOT NULL,
  `topic_id` int(10) unsigned DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `instructions` text DEFAULT NULL,
  `due_date` datetime NOT NULL,
  `max_score` decimal(6,2) DEFAULT 100.00,
  `allow_late` tinyint(1) DEFAULT 1,
  `late_penalty_percent` decimal(5,2) DEFAULT 0.00,
  `status` enum('draft','scheduled','published') DEFAULT 'published',
  `attachment_path` varchar(255) DEFAULT NULL,
  `created_by` int(10) unsigned NOT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `topic_id` (`topic_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_class_due` (`class_id`,`due_date`),
  CONSTRAINT `class_assignments_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_assignments_ibfk_2` FOREIGN KEY (`topic_id`) REFERENCES `class_topics` (`id`) ON DELETE SET NULL,
  CONSTRAINT `class_assignments_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: class_calendar_events
DROP TABLE IF EXISTS `class_calendar_events`;
CREATE TABLE `class_calendar_events` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_id` int(10) unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `event_type` enum('assignment','class','exam','reminder','other') DEFAULT 'other',
  `start_at` datetime NOT NULL,
  `end_at` datetime DEFAULT NULL,
  `class_assignment_id` int(10) unsigned DEFAULT NULL,
  `created_by` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `class_id` (`class_id`),
  KEY `class_assignment_id` (`class_assignment_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `class_calendar_events_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_calendar_events_ibfk_2` FOREIGN KEY (`class_assignment_id`) REFERENCES `class_assignments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `class_calendar_events_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (19, 20, 'Seed event 1 for class 20', 'class', '2026-03-01 00:00:00', '2026-03-01 02:00:00', NULL, 8);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (20, 20, 'Seed event 2 for class 20', 'class', '2026-03-15 00:00:00', '2026-03-15 02:00:00', NULL, 9);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (21, 21, 'Seed event 1 for class 21', 'class', '2026-03-01 00:00:00', '2026-03-01 02:00:00', NULL, 8);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (22, 21, 'Seed event 2 for class 21', 'class', '2026-03-15 00:00:00', '2026-03-15 02:00:00', NULL, 9);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (23, 22, 'Seed event 1 for class 22', 'class', '2026-03-01 00:00:00', '2026-03-01 02:00:00', NULL, 8);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (24, 22, 'Seed event 2 for class 22', 'class', '2026-03-15 00:00:00', '2026-03-15 02:00:00', NULL, 9);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (25, 23, 'Seed event 1 for class 23', 'class', '2026-03-01 00:00:00', '2026-03-01 02:00:00', NULL, 8);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (26, 23, 'Seed event 2 for class 23', 'class', '2026-03-15 00:00:00', '2026-03-15 02:00:00', NULL, 9);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (27, 24, 'Seed event 1 for class 24', 'class', '2027-03-01 00:00:00', '2027-03-01 02:00:00', NULL, 8);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (28, 24, 'Seed event 2 for class 24', 'class', '2027-03-15 00:00:00', '2027-03-15 02:00:00', NULL, 9);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (29, 25, 'Seed event 1 for class 25', 'class', '2027-03-01 00:00:00', '2027-03-01 02:00:00', NULL, 8);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (30, 25, 'Seed event 2 for class 25', 'class', '2027-03-15 00:00:00', '2027-03-15 02:00:00', NULL, 9);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (31, 26, 'Seed event 1 for class 26', 'class', '2027-03-01 00:00:00', '2027-03-01 02:00:00', NULL, 8);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (32, 26, 'Seed event 2 for class 26', 'class', '2027-03-15 00:00:00', '2027-03-15 02:00:00', NULL, 9);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (33, 27, 'Seed event 1 for class 27', 'class', '2027-03-01 00:00:00', '2027-03-01 02:00:00', NULL, 8);
INSERT INTO `class_calendar_events` (`id`,`class_id`,`title`,`event_type`,`start_at`,`end_at`,`class_assignment_id`,`created_by`) VALUES (34, 27, 'Seed event 2 for class 27', 'class', '2027-03-15 00:00:00', '2027-03-15 02:00:00', NULL, 9);

-- Table: class_members
DROP TABLE IF EXISTS `class_members`;
CREATE TABLE `class_members` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `member_role` enum('owner','co_teacher','ta','student') NOT NULL DEFAULT 'student',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_class_user` (`class_id`,`user_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `class_members_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1321 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: class_rubrics
DROP TABLE IF EXISTS `class_rubrics`;
CREATE TABLE `class_rubrics` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_assignment_id` int(10) unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `criteria_json` text NOT NULL COMMENT 'JSON array of {criterion, max_points}',
  PRIMARY KEY (`id`),
  KEY `class_assignment_id` (`class_assignment_id`),
  CONSTRAINT `class_rubrics_ibfk_1` FOREIGN KEY (`class_assignment_id`) REFERENCES `class_assignments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: class_submissions
DROP TABLE IF EXISTS `class_submissions`;
CREATE TABLE `class_submissions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_assignment_id` int(10) unsigned NOT NULL,
  `student_id` int(10) unsigned NOT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `external_url` varchar(500) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('missing','submitted','late','graded') DEFAULT 'missing',
  `score` decimal(6,2) DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  `rubric_scores_json` text DEFAULT NULL COMMENT 'JSON {criterion_id: points}',
  `private_comment` text DEFAULT NULL,
  `graded_by` int(10) unsigned DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `graded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_class_assignment_student` (`class_assignment_id`,`student_id`),
  KEY `student_id` (`student_id`),
  KEY `graded_by` (`graded_by`),
  CONSTRAINT `class_submissions_ibfk_1` FOREIGN KEY (`class_assignment_id`) REFERENCES `class_assignments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_submissions_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `class_submissions_ibfk_3` FOREIGN KEY (`graded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: class_topics
DROP TABLE IF EXISTS `class_topics`;
CREATE TABLE `class_topics` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_id` int(10) unsigned NOT NULL,
  `title` varchar(150) NOT NULL,
  `sort_order` smallint(5) unsigned DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `class_id` (`class_id`),
  CONSTRAINT `class_topics_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: classes
DROP TABLE IF EXISTS `classes`;
CREATE TABLE `classes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int(10) unsigned DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `section` varchar(80) DEFAULT NULL,
  `subject` varchar(150) DEFAULT NULL,
  `room_number` varchar(50) DEFAULT NULL,
  `join_code` varchar(12) NOT NULL,
  `theme_color` varchar(20) DEFAULT '#0d4f4c',
  `banner_path` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('active','archived') DEFAULT 'active',
  `comments_enabled` tinyint(1) DEFAULT 1,
  `created_by` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `join_code` (`join_code`),
  KEY `module_id` (`module_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_status` (`status`),
  KEY `idx_join_code` (`join_code`),
  CONSTRAINT `classes_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE SET NULL,
  CONSTRAINT `classes_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `classes` (`id`,`module_id`,`name`,`section`,`subject`,`room_number`,`join_code`,`theme_color`,`banner_path`,`description`,`status`,`comments_enabled`,`created_by`,`created_at`,`updated_at`) VALUES (20, 1, 'Seed  Certificate in Hospitality Operations Cohort 2026', 'A', 'Certificate in Hospitality Operations', 'Room 1', 'SEED2601A', '#999999', NULL, 'Recreated seed class', 'active', 1, 8, '2026-05-28 15:47:22', '2026-05-28 15:47:22');
INSERT INTO `classes` (`id`,`module_id`,`name`,`section`,`subject`,`room_number`,`join_code`,`theme_color`,`banner_path`,`description`,`status`,`comments_enabled`,`created_by`,`created_at`,`updated_at`) VALUES (21, 5, 'Seed  Professional Certificate in Culinary Arts Cohort 2026', 'B', 'Professional Certificate in Culinary Arts', 'Room 1', 'SEED2602B', '#999999', NULL, 'Recreated seed class', 'active', 1, 8, '2026-05-28 15:47:22', '2026-05-28 15:47:22');
INSERT INTO `classes` (`id`,`module_id`,`name`,`section`,`subject`,`room_number`,`join_code`,`theme_color`,`banner_path`,`description`,`status`,`comments_enabled`,`created_by`,`created_at`,`updated_at`) VALUES (22, 9, 'Seed  Diploma in Tourism Management Cohort 2026', 'C', 'Diploma in Tourism Management', 'Room 1', 'SEED2603C', '#999999', NULL, 'Recreated seed class', 'active', 1, 8, '2026-05-28 15:47:22', '2026-05-28 15:47:22');
INSERT INTO `classes` (`id`,`module_id`,`name`,`section`,`subject`,`room_number`,`join_code`,`theme_color`,`banner_path`,`description`,`status`,`comments_enabled`,`created_by`,`created_at`,`updated_at`) VALUES (23, 13, 'Seed  Higher National Diploma in Hospitality Management Cohort 2026', 'D', 'Higher National Diploma in Hospitality Management', 'Room 1', 'SEED2604D', '#999999', NULL, 'Recreated seed class', 'active', 1, 8, '2026-05-28 15:47:22', '2026-05-28 15:47:22');
INSERT INTO `classes` (`id`,`module_id`,`name`,`section`,`subject`,`room_number`,`join_code`,`theme_color`,`banner_path`,`description`,`status`,`comments_enabled`,`created_by`,`created_at`,`updated_at`) VALUES (24, 1, 'Seed  Certificate in Hospitality Operations Cohort 2027', 'A', 'Certificate in Hospitality Operations', 'Room 1', 'SEED2701A', '#999999', NULL, 'Recreated seed class', 'active', 1, 8, '2026-05-28 15:47:22', '2026-05-28 15:47:22');
INSERT INTO `classes` (`id`,`module_id`,`name`,`section`,`subject`,`room_number`,`join_code`,`theme_color`,`banner_path`,`description`,`status`,`comments_enabled`,`created_by`,`created_at`,`updated_at`) VALUES (25, 5, 'Seed  Professional Certificate in Culinary Arts Cohort 2027', 'B', 'Professional Certificate in Culinary Arts', 'Room 1', 'SEED2702B', '#999999', NULL, 'Recreated seed class', 'active', 1, 8, '2026-05-28 15:47:22', '2026-05-28 15:47:22');
INSERT INTO `classes` (`id`,`module_id`,`name`,`section`,`subject`,`room_number`,`join_code`,`theme_color`,`banner_path`,`description`,`status`,`comments_enabled`,`created_by`,`created_at`,`updated_at`) VALUES (26, 9, 'Seed  Diploma in Tourism Management Cohort 2027', 'C', 'Diploma in Tourism Management', 'Room 1', 'SEED2703C', '#999999', NULL, 'Recreated seed class', 'active', 1, 8, '2026-05-28 15:47:22', '2026-05-28 15:47:22');
INSERT INTO `classes` (`id`,`module_id`,`name`,`section`,`subject`,`room_number`,`join_code`,`theme_color`,`banner_path`,`description`,`status`,`comments_enabled`,`created_by`,`created_at`,`updated_at`) VALUES (27, 13, 'Seed  Higher National Diploma in Hospitality Management Cohort 2027', 'D', 'Higher National Diploma in Hospitality Management', 'Room 1', 'SEED2704D', '#999999', NULL, 'Recreated seed class', 'active', 1, 8, '2026-05-28 15:47:22', '2026-05-28 15:47:22');

-- Table: exchange_rates
DROP TABLE IF EXISTS `exchange_rates`;
CREATE TABLE `exchange_rates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `from_currency` enum('USD','ZWL') NOT NULL,
  `to_currency` enum('USD','ZWL') NOT NULL,
  `rate` decimal(12,6) NOT NULL,
  `rate_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rate_date` (`from_currency`,`to_currency`,`rate_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: expense_categories
DROP TABLE IF EXISTS `expense_categories`;
CREATE TABLE `expense_categories` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(120) NOT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `expense_categories` (`id`,`code`,`name`,`parent_id`) VALUES (1, 'UTIL', 'Utilities', NULL);
INSERT INTO `expense_categories` (`id`,`code`,`name`,`parent_id`) VALUES (2, 'IT', 'Internet & IT', NULL);
INSERT INTO `expense_categories` (`id`,`code`,`name`,`parent_id`) VALUES (3, 'CAT', 'Catering', NULL);
INSERT INTO `expense_categories` (`id`,`code`,`name`,`parent_id`) VALUES (4, 'MAINT', 'Maintenance', NULL);

-- Table: fee_rules
DROP TABLE IF EXISTS `fee_rules`;
CREATE TABLE `fee_rules` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `rule_type` enum('international','returning','early_payment','custom') NOT NULL,
  `program_id` int(10) unsigned DEFAULT NULL,
  `fee_type` varchar(40) DEFAULT NULL,
  `adjustment_type` enum('percent','fixed') DEFAULT 'percent',
  `adjustment_value` decimal(10,2) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `fee_rules_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: fee_structures
DROP TABLE IF EXISTS `fee_structures`;
CREATE TABLE `fee_structures` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `program_id` int(10) unsigned NOT NULL,
  `intake_id` int(10) unsigned DEFAULT NULL,
  `description` varchar(200) NOT NULL,
  `fee_type` enum('tuition','registration','examination','graduation','practical','accommodation','library','penalty','other') DEFAULT 'tuition',
  `billing_model` enum('once_off','per_module','per_semester','corporate_group') DEFAULT 'per_semester',
  `amount` decimal(12,2) NOT NULL,
  `currency` enum('USD','ZWL') DEFAULT 'USD',
  `semester` tinyint(3) unsigned DEFAULT NULL,
  `allow_installments` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `program_id` (`program_id`),
  KEY `intake_id` (`intake_id`),
  CONSTRAINT `fee_structures_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fee_structures_ibfk_2` FOREIGN KEY (`intake_id`) REFERENCES `intakes` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `fee_structures` (`id`,`program_id`,`intake_id`,`description`,`fee_type`,`billing_model`,`amount`,`currency`,`semester`,`allow_installments`,`is_active`) VALUES (9, 1, NULL, 'Seed tuition 2026 SC-HOSP-101', 'tuition', 'per_semester', '570.00', 'USD', NULL, 1, 1);
INSERT INTO `fee_structures` (`id`,`program_id`,`intake_id`,`description`,`fee_type`,`billing_model`,`amount`,`currency`,`semester`,`allow_installments`,`is_active`) VALUES (10, 2, NULL, 'Seed tuition 2026 PC-CUL-201', 'tuition', 'per_semester', '690.00', 'USD', NULL, 1, 1);
INSERT INTO `fee_structures` (`id`,`program_id`,`intake_id`,`description`,`fee_type`,`billing_model`,`amount`,`currency`,`semester`,`allow_installments`,`is_active`) VALUES (11, 3, NULL, 'Seed tuition 2026 DIP-TOUR-301', 'tuition', 'per_semester', '810.00', 'USD', NULL, 1, 1);
INSERT INTO `fee_structures` (`id`,`program_id`,`intake_id`,`description`,`fee_type`,`billing_model`,`amount`,`currency`,`semester`,`allow_installments`,`is_active`) VALUES (12, 4, NULL, 'Seed tuition 2026 HND-HOSP-401', 'tuition', 'per_semester', '450.00', 'USD', NULL, 1, 1);
INSERT INTO `fee_structures` (`id`,`program_id`,`intake_id`,`description`,`fee_type`,`billing_model`,`amount`,`currency`,`semester`,`allow_installments`,`is_active`) VALUES (13, 1, NULL, 'Seed tuition 2027 SC-HOSP-101', 'tuition', 'per_semester', '610.00', 'USD', NULL, 1, 1);
INSERT INTO `fee_structures` (`id`,`program_id`,`intake_id`,`description`,`fee_type`,`billing_model`,`amount`,`currency`,`semester`,`allow_installments`,`is_active`) VALUES (14, 2, NULL, 'Seed tuition 2027 PC-CUL-201', 'tuition', 'per_semester', '730.00', 'USD', NULL, 1, 1);
INSERT INTO `fee_structures` (`id`,`program_id`,`intake_id`,`description`,`fee_type`,`billing_model`,`amount`,`currency`,`semester`,`allow_installments`,`is_active`) VALUES (15, 3, NULL, 'Seed tuition 2027 DIP-TOUR-301', 'tuition', 'per_semester', '850.00', 'USD', NULL, 1, 1);
INSERT INTO `fee_structures` (`id`,`program_id`,`intake_id`,`description`,`fee_type`,`billing_model`,`amount`,`currency`,`semester`,`allow_installments`,`is_active`) VALUES (16, 4, NULL, 'Seed tuition 2027 HND-HOSP-401', 'tuition', 'per_semester', '490.00', 'USD', NULL, 1, 1);

-- Table: finance_holds
DROP TABLE IF EXISTS `finance_holds`;
CREATE TABLE `finance_holds` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int(10) unsigned NOT NULL,
  `hold_type` enum('exams','registration','results','graduation','general') NOT NULL,
  `reason` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `auto_generated` tinyint(1) DEFAULT 0,
  `created_by` int(10) unsigned DEFAULT NULL,
  `lifted_by` int(10) unsigned DEFAULT NULL,
  `lifted_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `finance_holds_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (11, 1202, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (12, 1214, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (13, 1226, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (14, 1238, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (15, 1250, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (16, 1262, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (17, 1274, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (18, 1286, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (19, 1298, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');
INSERT INTO `finance_holds` (`id`,`student_id`,`hold_type`,`reason`,`is_active`,`auto_generated`,`created_by`,`lifted_by`,`lifted_at`,`created_at`) VALUES (20, 1310, 'results', 'Seed results hold for testing', 1, 1, 7, NULL, NULL, '2026-05-28 15:47:23');

-- Table: finance_sponsors
DROP TABLE IF EXISTS `finance_sponsors`;
CREATE TABLE `finance_sponsors` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(200) NOT NULL,
  `sponsor_type` enum('ngo','government','corporate','other') DEFAULT 'corporate',
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `billing_terms` text DEFAULT NULL,
  `credit_limit` decimal(14,2) DEFAULT 0.00,
  `currency` enum('USD','ZWL') DEFAULT 'USD',
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `finance_sponsors` (`id`,`code`,`name`,`sponsor_type`,`email`,`phone`,`billing_terms`,`credit_limit`,`currency`,`is_active`,`created_at`) VALUES (3, 'SEED-SP-001', 'Seed Hospitality Trust', 'corporate', 'seed-sp-001@example.com', '+263778000000', 'Seed test sponsor', '50000.00', 'USD', 1, '2026-05-28 15:47:22');
INSERT INTO `finance_sponsors` (`id`,`code`,`name`,`sponsor_type`,`email`,`phone`,`billing_terms`,`credit_limit`,`currency`,`is_active`,`created_at`) VALUES (4, 'SEED-SP-002', 'Seed Tourism Partners', 'corporate', 'seed-sp-002@example.com', '+263778000000', 'Seed test sponsor', '50000.00', 'USD', 1, '2026-05-28 15:47:22');

-- Table: financial_periods
DROP TABLE IF EXISTS `financial_periods`;
CREATE TABLE `financial_periods` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_closed` tinyint(1) DEFAULT 0,
  `closed_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `financial_periods` (`id`,`name`,`start_date`,`end_date`,`is_closed`,`closed_at`) VALUES (3, 'Seed FY 2026', '2026-01-01', '2026-12-31', 0, NULL);
INSERT INTO `financial_periods` (`id`,`name`,`start_date`,`end_date`,`is_closed`,`closed_at`) VALUES (4, 'Seed FY 2027', '2027-01-01', '2027-12-31', 0, NULL);

-- Table: forum_topics
DROP TABLE IF EXISTS `forum_topics`;
CREATE TABLE `forum_topics` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `body` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `module_id` (`module_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `forum_topics_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE,
  CONSTRAINT `forum_topics_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: goods_receipts
DROP TABLE IF EXISTS `goods_receipts`;
CREATE TABLE `goods_receipts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `po_id` int(10) unsigned NOT NULL,
  `received_date` date NOT NULL,
  `notes` text DEFAULT NULL,
  `received_by` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `po_id` (`po_id`),
  CONSTRAINT `goods_receipts_ibfk_1` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `goods_receipts` (`id`,`po_id`,`received_date`,`notes`,`received_by`) VALUES (4, 4, '2027-09-15', 'Seed goods receipt', 7);
INSERT INTO `goods_receipts` (`id`,`po_id`,`received_date`,`notes`,`received_by`) VALUES (5, 5, '2027-09-15', 'Seed goods receipt', 7);
INSERT INTO `goods_receipts` (`id`,`po_id`,`received_date`,`notes`,`received_by`) VALUES (6, 6, '2027-09-15', 'Seed goods receipt', 7);

-- Table: graduations
DROP TABLE IF EXISTS `graduations`;
CREATE TABLE `graduations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int(10) unsigned NOT NULL,
  `program_id` int(10) unsigned NOT NULL,
  `graduation_date` date NOT NULL,
  `certificate_number` varchar(50) NOT NULL,
  `qr_verification_code` varchar(64) NOT NULL,
  `gpa` decimal(4,2) DEFAULT NULL,
  `issued_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `certificate_number` (`certificate_number`),
  UNIQUE KEY `qr_verification_code` (`qr_verification_code`),
  KEY `student_id` (`student_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `graduations_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `graduations_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (10, 1202, 1, '2026-12-10', 'SEED-CERT-0001', 'b6374e29e498bc891ed4bd91c5303f4f0d9aa8dbbadac86b7c44ef8a2e81c43f', '3.10', '2026-05-28 15:47:23');
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (11, 1216, 1, '2026-12-10', 'SEED-CERT-0015', '768b93a1acd07c8cf1c6430bf4ba76dc5a64d3c614005a53ad376d963f619a71', '3.50', '2026-05-28 15:47:23');
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (12, 1230, 2, '2026-12-10', 'SEED-CERT-0029', '94ca0d0b727ef3568c996a6224e039d69907f28458f0b8af7aa46e97daa79286', '3.10', '2026-05-28 15:47:23');
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (13, 1244, 3, '2026-12-10', 'SEED-CERT-0043', 'aefdca2b12d27a906757ecef04e1e8bb3813958b2a27f0af737205a4dbd9f62b', '3.50', '2026-05-28 15:47:23');
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (14, 1258, 4, '2026-12-10', 'SEED-CERT-0057', 'fd0bcc40cb69d19cf3e7575b90b56aecc4cf49b0047d8393e828064bf72c993e', '3.10', '2026-05-28 15:47:23');
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (15, 1272, 1, '2027-12-10', 'SEED-CERT-0071', 'a531092d71ad9d48b70b525f3825f99e0bbbd5a3289e25a9b4d53cf5c8f0b068', '3.50', '2026-05-28 15:47:23');
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (16, 1286, 2, '2027-12-10', 'SEED-CERT-0085', 'd813197dfbf75147f18c2c197e393bcdbd319d87bb4cd3cf2a87735bcd516c90', '3.10', '2026-05-28 15:47:23');
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (17, 1300, 3, '2027-12-10', 'SEED-CERT-0099', 'b7f24717efa1183a278c6e53266c761e9f646af94051ba7e460a80008cd672d6', '3.50', '2026-05-28 15:47:23');
INSERT INTO `graduations` (`id`,`student_id`,`program_id`,`graduation_date`,`certificate_number`,`qr_verification_code`,`gpa`,`issued_at`) VALUES (18, 1314, 4, '2027-12-10', 'SEED-CERT-0113', '3d19fd7d9b782ba9dbb18722d2bc74c4a1d8290802d0609bc0e8cf3fe295f334', '3.10', '2026-05-28 15:47:23');

-- Table: guardian_access_tokens
DROP TABLE IF EXISTS `guardian_access_tokens`;
CREATE TABLE `guardian_access_tokens` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `guardian_id` int(10) unsigned NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `guardian_id` (`guardian_id`),
  CONSTRAINT `guardian_access_tokens_ibfk_1` FOREIGN KEY (`guardian_id`) REFERENCES `guardians` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: guardian_summary_logs
DROP TABLE IF EXISTS `guardian_summary_logs`;
CREATE TABLE `guardian_summary_logs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `guardian_id` int(10) unsigned NOT NULL,
  `student_id` int(10) unsigned NOT NULL,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `delivery_status` enum('sent','failed') DEFAULT 'sent',
  PRIMARY KEY (`id`),
  KEY `guardian_id` (`guardian_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `guardian_summary_logs_ibfk_1` FOREIGN KEY (`guardian_id`) REFERENCES `guardians` (`id`) ON DELETE CASCADE,
  CONSTRAINT `guardian_summary_logs_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: guardians
DROP TABLE IF EXISTS `guardians`;
CREATE TABLE `guardians` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `email` varchar(150) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `receive_summaries` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_guardian_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: installment_plans
DROP TABLE IF EXISTS `installment_plans`;
CREATE TABLE `installment_plans` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int(10) unsigned NOT NULL,
  `invoice_id` int(10) unsigned DEFAULT NULL,
  `title` varchar(150) NOT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `down_payment` decimal(12,2) DEFAULT 0.00,
  `currency` enum('USD','ZWL') DEFAULT 'USD',
  `status` enum('pending','approved','active','completed','cancelled') DEFAULT 'pending',
  `created_by` int(10) unsigned DEFAULT NULL,
  `approved_by` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `invoice_id` (`invoice_id`),
  CONSTRAINT `installment_plans_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `installment_plans_ibfk_2` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: installment_schedule
DROP TABLE IF EXISTS `installment_schedule`;
CREATE TABLE `installment_schedule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `plan_id` int(10) unsigned NOT NULL,
  `due_date` date NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `amount_paid` decimal(12,2) DEFAULT 0.00,
  `status` enum('pending','partial','paid','overdue') DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `plan_id` (`plan_id`),
  CONSTRAINT `installment_schedule_ibfk_1` FOREIGN KEY (`plan_id`) REFERENCES `installment_plans` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: intakes
DROP TABLE IF EXISTS `intakes`;
CREATE TABLE `intakes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `academic_year` varchar(20) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('open','closed','archived') DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `intakes` (`id`,`name`,`academic_year`,`start_date`,`end_date`,`status`,`created_at`) VALUES (1, 'January 2026 Intake', '2026', '2026-01-15', '2026-12-15', 'open', '2026-05-21 09:22:06');
INSERT INTO `intakes` (`id`,`name`,`academic_year`,`start_date`,`end_date`,`status`,`created_at`) VALUES (2, 'May 2026 Intake', '2026', '2026-05-01', '2027-04-30', 'open', '2026-05-21 09:22:06');
INSERT INTO `intakes` (`id`,`name`,`academic_year`,`start_date`,`end_date`,`status`,`created_at`) VALUES (15, 'Seed January 2027 Intake', '2027', '2027-01-15', '2027-12-15', 'open', '2026-05-28 15:47:15');
INSERT INTO `intakes` (`id`,`name`,`academic_year`,`start_date`,`end_date`,`status`,`created_at`) VALUES (16, 'Seed May 2027 Intake', '2027', '2027-05-01', '2028-04-30', 'open', '2026-05-28 15:47:15');

-- Table: invoice_lines
DROP TABLE IF EXISTS `invoice_lines`;
CREATE TABLE `invoice_lines` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `invoice_id` int(10) unsigned NOT NULL,
  `description` varchar(200) NOT NULL,
  `quantity` decimal(8,2) DEFAULT 1.00,
  `unit_amount` decimal(12,2) NOT NULL,
  `line_total` decimal(12,2) NOT NULL,
  `fee_type` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `invoice_id` (`invoice_id`),
  CONSTRAINT `invoice_lines_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=481 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (241, 121, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (242, 121, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (243, 122, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (244, 122, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (245, 123, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (246, 123, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (247, 124, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (248, 124, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (249, 125, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (250, 125, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (251, 126, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (252, 126, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (253, 127, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (254, 127, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (255, 128, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (256, 128, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (257, 129, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (258, 129, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (259, 130, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (260, 130, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (261, 131, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (262, 131, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (263, 132, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (264, 132, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (265, 133, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (266, 133, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (267, 134, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (268, 134, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (269, 135, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (270, 135, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (271, 136, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (272, 136, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (273, 137, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (274, 137, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (275, 138, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (276, 138, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (277, 139, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (278, 139, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (279, 140, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (280, 140, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (281, 141, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (282, 141, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (283, 142, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (284, 142, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (285, 143, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (286, 143, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (287, 144, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (288, 144, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (289, 145, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (290, 145, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (291, 146, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (292, 146, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (293, 147, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (294, 147, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (295, 148, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (296, 148, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (297, 149, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (298, 149, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (299, 150, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (300, 150, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (301, 151, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (302, 151, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (303, 152, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (304, 152, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (305, 153, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (306, 153, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (307, 154, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (308, 154, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (309, 155, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (310, 155, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (311, 156, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (312, 156, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (313, 157, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (314, 157, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (315, 158, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (316, 158, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (317, 159, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (318, 159, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (319, 160, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (320, 160, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (321, 161, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (322, 161, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (323, 162, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (324, 162, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (325, 163, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (326, 163, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (327, 164, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (328, 164, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (329, 165, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (330, 165, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (331, 166, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (332, 166, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (333, 167, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (334, 167, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (335, 168, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (336, 168, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (337, 169, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (338, 169, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (339, 170, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (340, 170, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (341, 171, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (342, 171, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (343, 172, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (344, 172, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (345, 173, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (346, 173, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (347, 174, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (348, 174, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (349, 175, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (350, 175, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (351, 176, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (352, 176, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (353, 177, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (354, 177, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (355, 178, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (356, 178, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (357, 179, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (358, 179, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (359, 180, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (360, 180, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (361, 181, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (362, 181, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (363, 182, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (364, 182, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (365, 183, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (366, 183, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (367, 184, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (368, 184, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (369, 185, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (370, 185, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (371, 186, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (372, 186, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (373, 187, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (374, 187, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (375, 188, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (376, 188, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (377, 189, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (378, 189, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (379, 190, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (380, 190, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (381, 191, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (382, 191, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (383, 192, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (384, 192, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (385, 193, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (386, 193, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (387, 194, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (388, 194, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (389, 195, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (390, 195, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (391, 196, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (392, 196, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (393, 197, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (394, 197, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (395, 198, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (396, 198, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (397, 199, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (398, 199, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (399, 200, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (400, 200, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (401, 201, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (402, 201, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (403, 202, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (404, 202, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (405, 203, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (406, 203, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (407, 204, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (408, 204, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (409, 205, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (410, 205, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (411, 206, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (412, 206, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (413, 207, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (414, 207, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (415, 208, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (416, 208, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (417, 209, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (418, 209, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (419, 210, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (420, 210, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (421, 211, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (422, 211, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (423, 212, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (424, 212, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (425, 213, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (426, 213, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (427, 214, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (428, 214, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (429, 215, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (430, 215, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (431, 216, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (432, 216, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (433, 217, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (434, 217, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (435, 218, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (436, 218, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (437, 219, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (438, 219, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (439, 220, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (440, 220, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (441, 221, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (442, 221, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (443, 222, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (444, 222, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (445, 223, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (446, 223, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (447, 224, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (448, 224, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (449, 225, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (450, 225, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (451, 226, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (452, 226, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (453, 227, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (454, 227, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (455, 228, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (456, 228, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (457, 229, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (458, 229, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (459, 230, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (460, 230, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (461, 231, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (462, 231, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (463, 232, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (464, 232, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (465, 233, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (466, 233, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (467, 234, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (468, 234, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (469, 235, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (470, 235, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (471, 236, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (472, 236, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (473, 237, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (474, 237, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (475, 238, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (476, 238, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (477, 239, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (478, 239, 'Registration', '1.00', '150.00', '150.00', 'registration');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (479, 240, 'Tuition', '1.00', '350.00', '350.00', 'tuition');
INSERT INTO `invoice_lines` (`id`,`invoice_id`,`description`,`quantity`,`unit_amount`,`line_total`,`fee_type`) VALUES (480, 240, 'Registration', '1.00', '150.00', '150.00', 'registration');

-- Table: invoices
DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(30) NOT NULL,
  `student_id` int(10) unsigned NOT NULL,
  `fee_structure_id` int(10) unsigned DEFAULT NULL,
  `sponsor_id` int(10) unsigned DEFAULT NULL,
  `total_amount` decimal(12,2) NOT NULL,
  `currency` enum('USD','ZWL') DEFAULT 'USD',
  `invoice_type` enum('invoice','credit_note','debit_note') DEFAULT 'invoice',
  `amount_paid` decimal(12,2) DEFAULT 0.00,
  `status` enum('pending','partial','paid','overdue','cancelled') DEFAULT 'pending',
  `due_date` date NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  KEY `student_id` (`student_id`),
  KEY `idx_inv_status_due` (`status`,`due_date`),
  CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (121, 'SEED-INV-0001', 1202, 9, 3, '500.00', 'USD', 'invoice', '250.00', 'partial', '2026-03-17', 'Seed invoice for testing', '2026-05-28 15:47:22');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (122, 'SEED-INV-0002', 1203, 9, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-03-18', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (123, 'SEED-INV-0003', 1204, 9, NULL, '650.00', 'USD', 'invoice', '350.00', 'partial', '2026-03-19', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (124, 'SEED-INV-0004', 1205, 9, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-03-20', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (125, 'SEED-INV-0005', 1206, 9, NULL, '500.00', 'USD', 'invoice', '300.00', 'partial', '2026-03-21', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (126, 'SEED-INV-0006', 1207, 9, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-03-22', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (127, 'SEED-INV-0007', 1208, 9, NULL, '650.00', 'USD', 'invoice', '250.00', 'partial', '2026-03-23', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (128, 'SEED-INV-0008', 1209, 9, 3, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-03-24', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (129, 'SEED-INV-0009', 1210, 9, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2026-03-25', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (130, 'SEED-INV-0010', 1211, 9, 4, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-03-26', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (131, 'SEED-INV-0011', 1212, 9, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2026-03-27', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (132, 'SEED-INV-0012', 1213, 9, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-03-28', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (133, 'SEED-INV-0013', 1214, 9, NULL, '500.00', 'USD', 'invoice', '250.00', 'partial', '2026-03-29', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (134, 'SEED-INV-0014', 1215, 9, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-03-30', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (135, 'SEED-INV-0015', 1216, 9, 3, '650.00', 'USD', 'invoice', '350.00', 'partial', '2026-03-31', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (136, 'SEED-INV-0016', 1217, 10, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-01', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (137, 'SEED-INV-0017', 1218, 10, NULL, '500.00', 'USD', 'invoice', '300.00', 'partial', '2026-04-02', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (138, 'SEED-INV-0018', 1219, 10, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-03', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (139, 'SEED-INV-0019', 1220, 10, 4, '650.00', 'USD', 'invoice', '250.00', 'partial', '2026-04-04', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (140, 'SEED-INV-0020', 1221, 10, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-05', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (141, 'SEED-INV-0021', 1222, 10, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2026-04-06', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (142, 'SEED-INV-0022', 1223, 10, 3, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-07', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (143, 'SEED-INV-0023', 1224, 10, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2026-04-08', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (144, 'SEED-INV-0024', 1225, 10, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-09', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (145, 'SEED-INV-0025', 1226, 10, NULL, '500.00', 'USD', 'invoice', '250.00', 'partial', '2026-04-10', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (146, 'SEED-INV-0026', 1227, 10, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-11', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (147, 'SEED-INV-0027', 1228, 10, NULL, '650.00', 'USD', 'invoice', '350.00', 'partial', '2026-04-12', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (148, 'SEED-INV-0028', 1229, 10, 4, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-13', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (149, 'SEED-INV-0029', 1230, 10, 3, '500.00', 'USD', 'invoice', '300.00', 'partial', '2026-04-14', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (150, 'SEED-INV-0030', 1231, 10, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-15', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (151, 'SEED-INV-0031', 1232, 11, NULL, '650.00', 'USD', 'invoice', '250.00', 'partial', '2026-04-16', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (152, 'SEED-INV-0032', 1233, 11, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-17', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (153, 'SEED-INV-0033', 1234, 11, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2026-04-18', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (154, 'SEED-INV-0034', 1235, 11, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-19', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (155, 'SEED-INV-0035', 1236, 11, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2026-04-20', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (156, 'SEED-INV-0036', 1237, 11, 3, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-21', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (157, 'SEED-INV-0037', 1238, 11, 4, '500.00', 'USD', 'invoice', '250.00', 'partial', '2026-04-22', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (158, 'SEED-INV-0038', 1239, 11, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-23', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (159, 'SEED-INV-0039', 1240, 11, NULL, '650.00', 'USD', 'invoice', '350.00', 'partial', '2026-04-24', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (160, 'SEED-INV-0040', 1241, 11, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-25', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (161, 'SEED-INV-0041', 1242, 11, NULL, '500.00', 'USD', 'invoice', '300.00', 'partial', '2026-04-26', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (162, 'SEED-INV-0042', 1243, 11, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-27', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (163, 'SEED-INV-0043', 1244, 11, 3, '650.00', 'USD', 'invoice', '250.00', 'partial', '2026-04-28', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (164, 'SEED-INV-0044', 1245, 11, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-04-29', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (165, 'SEED-INV-0045', 1246, 11, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2026-04-30', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (166, 'SEED-INV-0046', 1247, 12, 4, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-05-01', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (167, 'SEED-INV-0047', 1248, 12, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2026-05-02', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (168, 'SEED-INV-0048', 1249, 12, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-05-03', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (169, 'SEED-INV-0049', 1250, 12, NULL, '500.00', 'USD', 'invoice', '250.00', 'partial', '2026-05-04', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (170, 'SEED-INV-0050', 1251, 12, 3, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-05-05', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (171, 'SEED-INV-0051', 1252, 12, NULL, '650.00', 'USD', 'invoice', '350.00', 'partial', '2026-05-06', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (172, 'SEED-INV-0052', 1253, 12, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-05-07', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (173, 'SEED-INV-0053', 1254, 12, NULL, '500.00', 'USD', 'invoice', '300.00', 'partial', '2026-05-08', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (174, 'SEED-INV-0054', 1255, 12, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-05-09', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (175, 'SEED-INV-0055', 1256, 12, 4, '650.00', 'USD', 'invoice', '250.00', 'partial', '2026-05-10', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (176, 'SEED-INV-0056', 1257, 12, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-05-11', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (177, 'SEED-INV-0057', 1258, 12, 3, '500.00', 'USD', 'invoice', '350.00', 'partial', '2026-05-12', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (178, 'SEED-INV-0058', 1259, 12, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2026-05-13', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (179, 'SEED-INV-0059', 1260, 12, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2026-05-14', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (180, 'SEED-INV-0060', 1261, 12, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2026-05-15', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (181, 'SEED-INV-0061', 1262, 13, NULL, '500.00', 'USD', 'invoice', '250.00', 'partial', '2027-05-16', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (182, 'SEED-INV-0062', 1263, 13, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-05-17', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (183, 'SEED-INV-0063', 1264, 13, NULL, '650.00', 'USD', 'invoice', '350.00', 'partial', '2027-05-18', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (184, 'SEED-INV-0064', 1265, 13, 3, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-05-19', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (185, 'SEED-INV-0065', 1266, 13, NULL, '500.00', 'USD', 'invoice', '300.00', 'partial', '2027-05-20', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (186, 'SEED-INV-0066', 1267, 13, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-05-21', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (187, 'SEED-INV-0067', 1268, 13, NULL, '650.00', 'USD', 'invoice', '250.00', 'partial', '2027-05-22', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (188, 'SEED-INV-0068', 1269, 13, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-05-23', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (189, 'SEED-INV-0069', 1270, 13, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2027-05-24', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (190, 'SEED-INV-0070', 1271, 13, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-05-25', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (191, 'SEED-INV-0071', 1272, 13, 3, '650.00', 'USD', 'invoice', '300.00', 'partial', '2027-05-26', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (192, 'SEED-INV-0072', 1273, 13, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-05-27', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (193, 'SEED-INV-0073', 1274, 13, 4, '500.00', 'USD', 'invoice', '250.00', 'partial', '2027-05-28', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (194, 'SEED-INV-0074', 1275, 13, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-05-29', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (195, 'SEED-INV-0075', 1276, 13, NULL, '650.00', 'USD', 'invoice', '350.00', 'partial', '2027-05-30', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (196, 'SEED-INV-0076', 1277, 14, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-05-31', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (197, 'SEED-INV-0077', 1278, 14, NULL, '500.00', 'USD', 'invoice', '300.00', 'partial', '2027-06-01', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (198, 'SEED-INV-0078', 1279, 14, 3, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-06-02', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (199, 'SEED-INV-0079', 1280, 14, NULL, '650.00', 'USD', 'invoice', '250.00', 'partial', '2027-06-03', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (200, 'SEED-INV-0080', 1281, 14, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-03-16', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (201, 'SEED-INV-0081', 1282, 14, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2027-03-17', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (202, 'SEED-INV-0082', 1283, 14, 4, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-03-18', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (203, 'SEED-INV-0083', 1284, 14, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2027-03-19', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (204, 'SEED-INV-0084', 1285, 14, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-03-20', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (205, 'SEED-INV-0085', 1286, 14, 3, '500.00', 'USD', 'invoice', '250.00', 'partial', '2027-03-21', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (206, 'SEED-INV-0086', 1287, 14, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-03-22', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (207, 'SEED-INV-0087', 1288, 14, NULL, '650.00', 'USD', 'invoice', '350.00', 'partial', '2027-03-23', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (208, 'SEED-INV-0088', 1289, 14, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-03-24', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (209, 'SEED-INV-0089', 1290, 14, NULL, '500.00', 'USD', 'invoice', '300.00', 'partial', '2027-03-25', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (210, 'SEED-INV-0090', 1291, 14, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-03-26', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (211, 'SEED-INV-0091', 1292, 15, 4, '650.00', 'USD', 'invoice', '250.00', 'partial', '2027-03-27', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (212, 'SEED-INV-0092', 1293, 15, 3, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-03-28', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (213, 'SEED-INV-0093', 1294, 15, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2027-03-29', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (214, 'SEED-INV-0094', 1295, 15, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-03-30', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (215, 'SEED-INV-0095', 1296, 15, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2027-03-31', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (216, 'SEED-INV-0096', 1297, 15, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-01', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (217, 'SEED-INV-0097', 1298, 15, NULL, '500.00', 'USD', 'invoice', '250.00', 'partial', '2027-04-02', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (218, 'SEED-INV-0098', 1299, 15, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-03', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (219, 'SEED-INV-0099', 1300, 15, 3, '650.00', 'USD', 'invoice', '350.00', 'partial', '2027-04-04', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (220, 'SEED-INV-0100', 1301, 15, 4, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-05', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (221, 'SEED-INV-0101', 1302, 15, NULL, '500.00', 'USD', 'invoice', '300.00', 'partial', '2027-04-06', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (222, 'SEED-INV-0102', 1303, 15, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-07', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (223, 'SEED-INV-0103', 1304, 15, NULL, '650.00', 'USD', 'invoice', '250.00', 'partial', '2027-04-08', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (224, 'SEED-INV-0104', 1305, 15, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-09', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (225, 'SEED-INV-0105', 1306, 15, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2027-04-10', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (226, 'SEED-INV-0106', 1307, 16, 3, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-11', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (227, 'SEED-INV-0107', 1308, 16, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2027-04-12', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (228, 'SEED-INV-0108', 1309, 16, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-13', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (229, 'SEED-INV-0109', 1310, 16, 4, '500.00', 'USD', 'invoice', '250.00', 'partial', '2027-04-14', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (230, 'SEED-INV-0110', 1311, 16, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-15', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (231, 'SEED-INV-0111', 1312, 16, NULL, '650.00', 'USD', 'invoice', '350.00', 'partial', '2027-04-16', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (232, 'SEED-INV-0112', 1313, 16, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-17', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (233, 'SEED-INV-0113', 1314, 16, 3, '500.00', 'USD', 'invoice', '300.00', 'partial', '2027-04-18', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (234, 'SEED-INV-0114', 1315, 16, NULL, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-19', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (235, 'SEED-INV-0115', 1316, 16, NULL, '650.00', 'USD', 'invoice', '250.00', 'partial', '2027-04-20', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (236, 'SEED-INV-0116', 1317, 16, NULL, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-21', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (237, 'SEED-INV-0117', 1318, 16, NULL, '500.00', 'USD', 'invoice', '350.00', 'partial', '2027-04-22', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (238, 'SEED-INV-0118', 1319, 16, 4, '575.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-23', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (239, 'SEED-INV-0119', 1320, 16, NULL, '650.00', 'USD', 'invoice', '300.00', 'partial', '2027-04-24', 'Seed invoice for testing', '2026-05-28 15:47:23');
INSERT INTO `invoices` (`id`,`invoice_number`,`student_id`,`fee_structure_id`,`sponsor_id`,`total_amount`,`currency`,`invoice_type`,`amount_paid`,`status`,`due_date`,`notes`,`created_at`) VALUES (240, 'SEED-INV-0120', 1321, 16, 3, '725.00', 'USD', 'invoice', '0.00', 'pending', '2027-04-25', 'Seed invoice for testing', '2026-05-28 15:47:23');

-- Table: journal_entries
DROP TABLE IF EXISTS `journal_entries`;
CREATE TABLE `journal_entries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `entry_number` varchar(30) NOT NULL,
  `entry_date` date NOT NULL,
  `description` varchar(255) NOT NULL,
  `period_id` int(10) unsigned DEFAULT NULL,
  `source_type` varchar(40) DEFAULT NULL,
  `source_id` int(10) unsigned DEFAULT NULL,
  `created_by` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `entry_number` (`entry_number`),
  KEY `period_id` (`period_id`),
  CONSTRAINT `journal_entries_ibfk_1` FOREIGN KEY (`period_id`) REFERENCES `financial_periods` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `journal_entries` (`id`,`entry_number`,`entry_date`,`description`,`period_id`,`source_type`,`source_id`,`created_by`,`created_at`) VALUES (5, 'SEED-JE-001', '2026-06-30', 'Seed tuition receipt', 3, 'seed', NULL, 7, '2026-05-28 15:47:23');
INSERT INTO `journal_entries` (`id`,`entry_number`,`entry_date`,`description`,`period_id`,`source_type`,`source_id`,`created_by`,`created_at`) VALUES (6, 'SEED-JE-002', '2027-06-30', 'Seed tuition receipt', 4, 'seed', NULL, 7, '2026-05-28 15:47:23');
INSERT INTO `journal_entries` (`id`,`entry_number`,`entry_date`,`description`,`period_id`,`source_type`,`source_id`,`created_by`,`created_at`) VALUES (7, 'SEED-JE-003', '2026-12-31', 'Seed office expense', 3, 'seed', NULL, 7, '2026-05-28 15:47:23');
INSERT INTO `journal_entries` (`id`,`entry_number`,`entry_date`,`description`,`period_id`,`source_type`,`source_id`,`created_by`,`created_at`) VALUES (8, 'SEED-JE-004', '2027-12-31', 'Seed office expense', 4, 'seed', NULL, 7, '2026-05-28 15:47:23');

-- Table: journal_lines
DROP TABLE IF EXISTS `journal_lines`;
CREATE TABLE `journal_lines` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `journal_id` int(10) unsigned NOT NULL,
  `account_id` int(10) unsigned NOT NULL,
  `debit` decimal(14,2) DEFAULT 0.00,
  `credit` decimal(14,2) DEFAULT 0.00,
  `memo` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `journal_id` (`journal_id`),
  KEY `account_id` (`account_id`),
  CONSTRAINT `journal_lines_ibfk_1` FOREIGN KEY (`journal_id`) REFERENCES `journal_entries` (`id`) ON DELETE CASCADE,
  CONSTRAINT `journal_lines_ibfk_2` FOREIGN KEY (`account_id`) REFERENCES `chart_of_accounts` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `journal_lines` (`id`,`journal_id`,`account_id`,`debit`,`credit`,`memo`) VALUES (9, 5, 1, '1200.00', '0.00', 'Seed cash line');
INSERT INTO `journal_lines` (`id`,`journal_id`,`account_id`,`debit`,`credit`,`memo`) VALUES (10, 5, 5, '0.00', '1200.00', 'Seed offset line');
INSERT INTO `journal_lines` (`id`,`journal_id`,`account_id`,`debit`,`credit`,`memo`) VALUES (11, 6, 1, '1400.00', '0.00', 'Seed cash line');
INSERT INTO `journal_lines` (`id`,`journal_id`,`account_id`,`debit`,`credit`,`memo`) VALUES (12, 6, 5, '0.00', '1400.00', 'Seed offset line');
INSERT INTO `journal_lines` (`id`,`journal_id`,`account_id`,`debit`,`credit`,`memo`) VALUES (13, 7, 1, '300.00', '0.00', 'Seed cash line');
INSERT INTO `journal_lines` (`id`,`journal_id`,`account_id`,`debit`,`credit`,`memo`) VALUES (14, 7, 5, '0.00', '300.00', 'Seed offset line');
INSERT INTO `journal_lines` (`id`,`journal_id`,`account_id`,`debit`,`credit`,`memo`) VALUES (15, 8, 1, '450.00', '0.00', 'Seed cash line');
INSERT INTO `journal_lines` (`id`,`journal_id`,`account_id`,`debit`,`credit`,`memo`) VALUES (16, 8, 5, '0.00', '450.00', 'Seed offset line');

-- Table: lecturer_workload
DROP TABLE IF EXISTS `lecturer_workload`;
CREATE TABLE `lecturer_workload` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `lecturer_id` int(10) unsigned NOT NULL,
  `module_id` int(10) unsigned NOT NULL,
  `academic_year` varchar(20) NOT NULL,
  `contact_hours` smallint(5) unsigned DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `lecturer_id` (`lecturer_id`),
  KEY `module_id` (`module_id`),
  CONSTRAINT `lecturer_workload_ibfk_1` FOREIGN KEY (`lecturer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lecturer_workload_ibfk_2` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: library_books
DROP TABLE IF EXISTS `library_books`;
CREATE TABLE `library_books` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `isbn` varchar(20) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `author` varchar(150) DEFAULT NULL,
  `category` varchar(80) DEFAULT NULL,
  `copies_total` smallint(5) unsigned DEFAULT 1,
  `copies_available` smallint(5) unsigned DEFAULT 1,
  `is_digital` tinyint(1) DEFAULT 0,
  `digital_url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: library_borrowings
DROP TABLE IF EXISTS `library_borrowings`;
CREATE TABLE `library_borrowings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `book_id` int(10) unsigned NOT NULL,
  `student_id` int(10) unsigned NOT NULL,
  `borrowed_at` date NOT NULL,
  `due_date` date NOT NULL,
  `returned_at` date DEFAULT NULL,
  `status` enum('borrowed','returned','overdue') DEFAULT 'borrowed',
  PRIMARY KEY (`id`),
  KEY `book_id` (`book_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `library_borrowings_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `library_books` (`id`),
  CONSTRAINT `library_borrowings_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: lms_materials
DROP TABLE IF EXISTS `lms_materials`;
CREATE TABLE `lms_materials` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int(10) unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `external_url` varchar(500) DEFAULT NULL,
  `uploaded_by` int(10) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `module_id` (`module_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `lms_materials_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lms_materials_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: marks
DROP TABLE IF EXISTS `marks`;
CREATE TABLE `marks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `assessment_id` int(10) unsigned NOT NULL,
  `student_id` int(10) unsigned NOT NULL,
  `score` decimal(6,2) NOT NULL,
  `grade` varchar(5) DEFAULT NULL,
  `moderated` tinyint(1) DEFAULT 0,
  `entered_by` int(10) unsigned NOT NULL,
  `entered_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_assessment_student` (`assessment_id`,`student_id`),
  KEY `student_id` (`student_id`),
  KEY `entered_by` (`entered_by`),
  CONSTRAINT `marks_ibfk_1` FOREIGN KEY (`assessment_id`) REFERENCES `assessments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `marks_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `marks_ibfk_3` FOREIGN KEY (`entered_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5761 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4801, 321, 1202, '63.00', 'C', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4802, 322, 1202, '68.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4803, 321, 1203, '64.00', 'C', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4804, 322, 1203, '69.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4805, 321, 1204, '65.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4806, 322, 1204, '70.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4807, 321, 1205, '66.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4808, 322, 1205, '71.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4809, 321, 1206, '67.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4810, 322, 1206, '72.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4811, 321, 1207, '68.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4812, 322, 1207, '73.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4813, 321, 1208, '69.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4814, 322, 1208, '74.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4815, 321, 1209, '70.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4816, 322, 1209, '75.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4817, 321, 1210, '71.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4818, 322, 1210, '76.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4819, 321, 1211, '72.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4820, 322, 1211, '77.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4821, 321, 1212, '73.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4822, 322, 1212, '78.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4823, 321, 1213, '74.00', 'B', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4824, 322, 1213, '79.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4825, 321, 1214, '75.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4826, 322, 1214, '80.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4827, 321, 1215, '76.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4828, 322, 1215, '81.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4829, 321, 1216, '77.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4830, 322, 1216, '82.00', 'A', 0, 10, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4831, 323, 1262, '89.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4832, 324, 1262, '94.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4833, 323, 1263, '55.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4834, 324, 1263, '60.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4835, 323, 1264, '56.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4836, 324, 1264, '61.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4837, 323, 1265, '57.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4838, 324, 1265, '62.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4839, 323, 1266, '58.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4840, 324, 1266, '63.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4841, 323, 1267, '59.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4842, 324, 1267, '64.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4843, 323, 1268, '60.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4844, 324, 1268, '65.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4845, 323, 1269, '61.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4846, 324, 1269, '66.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4847, 323, 1270, '62.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4848, 324, 1270, '67.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4849, 323, 1271, '63.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4850, 324, 1271, '68.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4851, 323, 1272, '64.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4852, 324, 1272, '69.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4853, 323, 1273, '65.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4854, 324, 1273, '70.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4855, 323, 1274, '66.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4856, 324, 1274, '71.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4857, 323, 1275, '67.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4858, 324, 1275, '72.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4859, 323, 1276, '68.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4860, 324, 1276, '73.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4861, 325, 1202, '64.00', 'C', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4862, 326, 1202, '69.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4863, 325, 1203, '65.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4864, 326, 1203, '70.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4865, 325, 1204, '66.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4866, 326, 1204, '71.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4867, 325, 1205, '67.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4868, 326, 1205, '72.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4869, 325, 1206, '68.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4870, 326, 1206, '73.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4871, 325, 1207, '69.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4872, 326, 1207, '74.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4873, 325, 1208, '70.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4874, 326, 1208, '75.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4875, 325, 1209, '71.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4876, 326, 1209, '76.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4877, 325, 1210, '72.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4878, 326, 1210, '77.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4879, 325, 1211, '73.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4880, 326, 1211, '78.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4881, 325, 1212, '74.00', 'B', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4882, 326, 1212, '79.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4883, 325, 1213, '75.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4884, 326, 1213, '80.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4885, 325, 1214, '76.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4886, 326, 1214, '81.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4887, 325, 1215, '77.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4888, 326, 1215, '82.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4889, 325, 1216, '78.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4890, 326, 1216, '83.00', 'A', 0, 11, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4891, 327, 1262, '55.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4892, 328, 1262, '60.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4893, 327, 1263, '56.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4894, 328, 1263, '61.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4895, 327, 1264, '57.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4896, 328, 1264, '62.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4897, 327, 1265, '58.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4898, 328, 1265, '63.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4899, 327, 1266, '59.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4900, 328, 1266, '64.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4901, 327, 1267, '60.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4902, 328, 1267, '65.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4903, 327, 1268, '61.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4904, 328, 1268, '66.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4905, 327, 1269, '62.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4906, 328, 1269, '67.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4907, 327, 1270, '63.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4908, 328, 1270, '68.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4909, 327, 1271, '64.00', 'C', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4910, 328, 1271, '69.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4911, 327, 1272, '65.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4912, 328, 1272, '70.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4913, 327, 1273, '66.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4914, 328, 1273, '71.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4915, 327, 1274, '67.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4916, 328, 1274, '72.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4917, 327, 1275, '68.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4918, 328, 1275, '73.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4919, 327, 1276, '69.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4920, 328, 1276, '74.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4921, 329, 1202, '65.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4922, 330, 1202, '70.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4923, 329, 1203, '66.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4924, 330, 1203, '71.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4925, 329, 1204, '67.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4926, 330, 1204, '72.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4927, 329, 1205, '68.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4928, 330, 1205, '73.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4929, 329, 1206, '69.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4930, 330, 1206, '74.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4931, 329, 1207, '70.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4932, 330, 1207, '75.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4933, 329, 1208, '71.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4934, 330, 1208, '76.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4935, 329, 1209, '72.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4936, 330, 1209, '77.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4937, 329, 1210, '73.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4938, 330, 1210, '78.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4939, 329, 1211, '74.00', 'B', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4940, 330, 1211, '79.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4941, 329, 1212, '75.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4942, 330, 1212, '80.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4943, 329, 1213, '76.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4944, 330, 1213, '81.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4945, 329, 1214, '77.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4946, 330, 1214, '82.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4947, 329, 1215, '78.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4948, 330, 1215, '83.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4949, 329, 1216, '79.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4950, 330, 1216, '84.00', 'A', 0, 8, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4951, 331, 1262, '56.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4952, 332, 1262, '61.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4953, 331, 1263, '57.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4954, 332, 1263, '62.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4955, 331, 1264, '58.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4956, 332, 1264, '63.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4957, 331, 1265, '59.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4958, 332, 1265, '64.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4959, 331, 1266, '60.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4960, 332, 1266, '65.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4961, 331, 1267, '61.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4962, 332, 1267, '66.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4963, 331, 1268, '62.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4964, 332, 1268, '67.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4965, 331, 1269, '63.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4966, 332, 1269, '68.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4967, 331, 1270, '64.00', 'C', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4968, 332, 1270, '69.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4969, 331, 1271, '65.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4970, 332, 1271, '70.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4971, 331, 1272, '66.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4972, 332, 1272, '71.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4973, 331, 1273, '67.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4974, 332, 1273, '72.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4975, 331, 1274, '68.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4976, 332, 1274, '73.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4977, 331, 1275, '69.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4978, 332, 1275, '74.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4979, 331, 1276, '70.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4980, 332, 1276, '75.00', 'A', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4981, 333, 1202, '66.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4982, 334, 1202, '71.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4983, 333, 1203, '67.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4984, 334, 1203, '72.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4985, 333, 1204, '68.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4986, 334, 1204, '73.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4987, 333, 1205, '69.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4988, 334, 1205, '74.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4989, 333, 1206, '70.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4990, 334, 1206, '75.00', 'A', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4991, 333, 1207, '71.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4992, 334, 1207, '76.00', 'A', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4993, 333, 1208, '72.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4994, 334, 1208, '77.00', 'A', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4995, 333, 1209, '73.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4996, 334, 1209, '78.00', 'A', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4997, 333, 1210, '74.00', 'B', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4998, 334, 1210, '79.00', 'A', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (4999, 333, 1211, '75.00', 'A', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5000, 334, 1211, '80.00', 'A', 0, 9, '2026-05-28 15:47:21');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5001, 333, 1212, '76.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5002, 334, 1212, '81.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5003, 333, 1213, '77.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5004, 334, 1213, '82.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5005, 333, 1214, '78.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5006, 334, 1214, '83.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5007, 333, 1215, '79.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5008, 334, 1215, '84.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5009, 333, 1216, '80.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5010, 334, 1216, '85.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5011, 335, 1262, '57.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5012, 336, 1262, '62.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5013, 335, 1263, '58.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5014, 336, 1263, '63.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5015, 335, 1264, '59.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5016, 336, 1264, '64.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5017, 335, 1265, '60.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5018, 336, 1265, '65.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5019, 335, 1266, '61.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5020, 336, 1266, '66.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5021, 335, 1267, '62.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5022, 336, 1267, '67.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5023, 335, 1268, '63.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5024, 336, 1268, '68.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5025, 335, 1269, '64.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5026, 336, 1269, '69.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5027, 335, 1270, '65.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5028, 336, 1270, '70.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5029, 335, 1271, '66.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5030, 336, 1271, '71.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5031, 335, 1272, '67.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5032, 336, 1272, '72.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5033, 335, 1273, '68.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5034, 336, 1273, '73.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5035, 335, 1274, '69.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5036, 336, 1274, '74.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5037, 335, 1275, '70.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5038, 336, 1275, '75.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5039, 335, 1276, '71.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5040, 336, 1276, '76.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5041, 337, 1217, '78.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5042, 338, 1217, '83.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5043, 337, 1218, '79.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5044, 338, 1218, '84.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5045, 337, 1219, '80.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5046, 338, 1219, '85.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5047, 337, 1220, '81.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5048, 338, 1220, '86.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5049, 337, 1221, '82.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5050, 338, 1221, '87.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5051, 337, 1222, '83.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5052, 338, 1222, '88.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5053, 337, 1223, '84.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5054, 338, 1223, '89.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5055, 337, 1224, '85.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5056, 338, 1224, '90.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5057, 337, 1225, '86.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5058, 338, 1225, '91.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5059, 337, 1226, '87.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5060, 338, 1226, '92.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5061, 337, 1227, '88.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5062, 338, 1227, '93.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5063, 337, 1228, '89.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5064, 338, 1228, '94.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5065, 337, 1229, '55.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5066, 338, 1229, '60.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5067, 337, 1230, '56.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5068, 338, 1230, '61.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5069, 337, 1231, '57.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5070, 338, 1231, '62.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5071, 339, 1277, '69.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5072, 340, 1277, '74.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5073, 339, 1278, '70.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5074, 340, 1278, '75.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5075, 339, 1279, '71.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5076, 340, 1279, '76.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5077, 339, 1280, '72.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5078, 340, 1280, '77.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5079, 339, 1281, '73.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5080, 340, 1281, '78.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5081, 339, 1282, '74.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5082, 340, 1282, '79.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5083, 339, 1283, '75.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5084, 340, 1283, '80.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5085, 339, 1284, '76.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5086, 340, 1284, '81.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5087, 339, 1285, '77.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5088, 340, 1285, '82.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5089, 339, 1286, '78.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5090, 340, 1286, '83.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5091, 339, 1287, '79.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5092, 340, 1287, '84.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5093, 339, 1288, '80.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5094, 340, 1288, '85.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5095, 339, 1289, '81.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5096, 340, 1289, '86.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5097, 339, 1290, '82.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5098, 340, 1290, '87.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5099, 339, 1291, '83.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5100, 340, 1291, '88.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5101, 341, 1217, '79.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5102, 342, 1217, '84.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5103, 341, 1218, '80.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5104, 342, 1218, '85.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5105, 341, 1219, '81.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5106, 342, 1219, '86.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5107, 341, 1220, '82.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5108, 342, 1220, '87.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5109, 341, 1221, '83.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5110, 342, 1221, '88.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5111, 341, 1222, '84.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5112, 342, 1222, '89.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5113, 341, 1223, '85.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5114, 342, 1223, '90.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5115, 341, 1224, '86.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5116, 342, 1224, '91.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5117, 341, 1225, '87.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5118, 342, 1225, '92.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5119, 341, 1226, '88.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5120, 342, 1226, '93.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5121, 341, 1227, '89.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5122, 342, 1227, '94.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5123, 341, 1228, '55.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5124, 342, 1228, '60.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5125, 341, 1229, '56.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5126, 342, 1229, '61.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5127, 341, 1230, '57.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5128, 342, 1230, '62.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5129, 341, 1231, '58.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5130, 342, 1231, '63.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5131, 343, 1277, '70.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5132, 344, 1277, '75.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5133, 343, 1278, '71.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5134, 344, 1278, '76.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5135, 343, 1279, '72.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5136, 344, 1279, '77.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5137, 343, 1280, '73.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5138, 344, 1280, '78.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5139, 343, 1281, '74.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5140, 344, 1281, '79.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5141, 343, 1282, '75.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5142, 344, 1282, '80.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5143, 343, 1283, '76.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5144, 344, 1283, '81.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5145, 343, 1284, '77.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5146, 344, 1284, '82.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5147, 343, 1285, '78.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5148, 344, 1285, '83.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5149, 343, 1286, '79.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5150, 344, 1286, '84.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5151, 343, 1287, '80.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5152, 344, 1287, '85.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5153, 343, 1288, '81.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5154, 344, 1288, '86.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5155, 343, 1289, '82.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5156, 344, 1289, '87.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5157, 343, 1290, '83.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5158, 344, 1290, '88.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5159, 343, 1291, '84.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5160, 344, 1291, '89.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5161, 345, 1217, '80.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5162, 346, 1217, '85.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5163, 345, 1218, '81.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5164, 346, 1218, '86.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5165, 345, 1219, '82.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5166, 346, 1219, '87.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5167, 345, 1220, '83.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5168, 346, 1220, '88.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5169, 345, 1221, '84.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5170, 346, 1221, '89.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5171, 345, 1222, '85.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5172, 346, 1222, '90.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5173, 345, 1223, '86.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5174, 346, 1223, '91.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5175, 345, 1224, '87.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5176, 346, 1224, '92.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5177, 345, 1225, '88.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5178, 346, 1225, '93.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5179, 345, 1226, '89.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5180, 346, 1226, '94.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5181, 345, 1227, '55.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5182, 346, 1227, '60.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5183, 345, 1228, '56.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5184, 346, 1228, '61.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5185, 345, 1229, '57.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5186, 346, 1229, '62.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5187, 345, 1230, '58.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5188, 346, 1230, '63.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5189, 345, 1231, '59.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5190, 346, 1231, '64.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5191, 347, 1277, '71.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5192, 348, 1277, '76.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5193, 347, 1278, '72.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5194, 348, 1278, '77.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5195, 347, 1279, '73.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5196, 348, 1279, '78.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5197, 347, 1280, '74.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5198, 348, 1280, '79.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5199, 347, 1281, '75.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5200, 348, 1281, '80.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5201, 347, 1282, '76.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5202, 348, 1282, '81.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5203, 347, 1283, '77.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5204, 348, 1283, '82.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5205, 347, 1284, '78.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5206, 348, 1284, '83.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5207, 347, 1285, '79.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5208, 348, 1285, '84.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5209, 347, 1286, '80.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5210, 348, 1286, '85.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5211, 347, 1287, '81.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5212, 348, 1287, '86.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5213, 347, 1288, '82.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5214, 348, 1288, '87.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5215, 347, 1289, '83.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5216, 348, 1289, '88.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5217, 347, 1290, '84.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5218, 348, 1290, '89.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5219, 347, 1291, '85.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5220, 348, 1291, '90.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5221, 349, 1217, '81.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5222, 350, 1217, '86.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5223, 349, 1218, '82.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5224, 350, 1218, '87.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5225, 349, 1219, '83.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5226, 350, 1219, '88.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5227, 349, 1220, '84.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5228, 350, 1220, '89.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5229, 349, 1221, '85.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5230, 350, 1221, '90.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5231, 349, 1222, '86.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5232, 350, 1222, '91.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5233, 349, 1223, '87.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5234, 350, 1223, '92.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5235, 349, 1224, '88.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5236, 350, 1224, '93.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5237, 349, 1225, '89.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5238, 350, 1225, '94.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5239, 349, 1226, '55.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5240, 350, 1226, '60.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5241, 349, 1227, '56.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5242, 350, 1227, '61.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5243, 349, 1228, '57.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5244, 350, 1228, '62.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5245, 349, 1229, '58.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5246, 350, 1229, '63.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5247, 349, 1230, '59.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5248, 350, 1230, '64.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5249, 349, 1231, '60.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5250, 350, 1231, '65.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5251, 351, 1277, '72.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5252, 352, 1277, '77.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5253, 351, 1278, '73.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5254, 352, 1278, '78.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5255, 351, 1279, '74.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5256, 352, 1279, '79.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5257, 351, 1280, '75.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5258, 352, 1280, '80.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5259, 351, 1281, '76.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5260, 352, 1281, '81.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5261, 351, 1282, '77.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5262, 352, 1282, '82.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5263, 351, 1283, '78.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5264, 352, 1283, '83.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5265, 351, 1284, '79.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5266, 352, 1284, '84.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5267, 351, 1285, '80.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5268, 352, 1285, '85.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5269, 351, 1286, '81.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5270, 352, 1286, '86.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5271, 351, 1287, '82.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5272, 352, 1287, '87.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5273, 351, 1288, '83.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5274, 352, 1288, '88.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5275, 351, 1289, '84.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5276, 352, 1289, '89.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5277, 351, 1290, '85.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5278, 352, 1290, '90.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5279, 351, 1291, '86.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5280, 352, 1291, '91.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5281, 353, 1232, '58.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5282, 354, 1232, '63.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5283, 353, 1233, '59.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5284, 354, 1233, '64.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5285, 353, 1234, '60.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5286, 354, 1234, '65.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5287, 353, 1235, '61.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5288, 354, 1235, '66.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5289, 353, 1236, '62.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5290, 354, 1236, '67.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5291, 353, 1237, '63.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5292, 354, 1237, '68.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5293, 353, 1238, '64.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5294, 354, 1238, '69.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5295, 353, 1239, '65.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5296, 354, 1239, '70.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5297, 353, 1240, '66.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5298, 354, 1240, '71.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5299, 353, 1241, '67.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5300, 354, 1241, '72.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5301, 353, 1242, '68.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5302, 354, 1242, '73.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5303, 353, 1243, '69.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5304, 354, 1243, '74.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5305, 353, 1244, '70.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5306, 354, 1244, '75.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5307, 353, 1245, '71.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5308, 354, 1245, '76.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5309, 353, 1246, '72.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5310, 354, 1246, '77.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5311, 355, 1292, '84.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5312, 356, 1292, '89.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5313, 355, 1293, '85.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5314, 356, 1293, '90.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5315, 355, 1294, '86.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5316, 356, 1294, '91.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5317, 355, 1295, '87.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5318, 356, 1295, '92.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5319, 355, 1296, '88.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5320, 356, 1296, '93.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5321, 355, 1297, '89.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5322, 356, 1297, '94.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5323, 355, 1298, '55.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5324, 356, 1298, '60.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5325, 355, 1299, '56.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5326, 356, 1299, '61.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5327, 355, 1300, '57.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5328, 356, 1300, '62.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5329, 355, 1301, '58.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5330, 356, 1301, '63.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5331, 355, 1302, '59.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5332, 356, 1302, '64.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5333, 355, 1303, '60.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5334, 356, 1303, '65.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5335, 355, 1304, '61.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5336, 356, 1304, '66.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5337, 355, 1305, '62.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5338, 356, 1305, '67.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5339, 355, 1306, '63.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5340, 356, 1306, '68.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5341, 357, 1232, '59.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5342, 358, 1232, '64.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5343, 357, 1233, '60.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5344, 358, 1233, '65.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5345, 357, 1234, '61.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5346, 358, 1234, '66.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5347, 357, 1235, '62.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5348, 358, 1235, '67.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5349, 357, 1236, '63.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5350, 358, 1236, '68.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5351, 357, 1237, '64.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5352, 358, 1237, '69.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5353, 357, 1238, '65.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5354, 358, 1238, '70.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5355, 357, 1239, '66.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5356, 358, 1239, '71.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5357, 357, 1240, '67.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5358, 358, 1240, '72.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5359, 357, 1241, '68.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5360, 358, 1241, '73.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5361, 357, 1242, '69.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5362, 358, 1242, '74.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5363, 357, 1243, '70.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5364, 358, 1243, '75.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5365, 357, 1244, '71.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5366, 358, 1244, '76.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5367, 357, 1245, '72.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5368, 358, 1245, '77.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5369, 357, 1246, '73.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5370, 358, 1246, '78.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5371, 359, 1292, '85.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5372, 360, 1292, '90.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5373, 359, 1293, '86.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5374, 360, 1293, '91.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5375, 359, 1294, '87.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5376, 360, 1294, '92.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5377, 359, 1295, '88.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5378, 360, 1295, '93.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5379, 359, 1296, '89.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5380, 360, 1296, '94.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5381, 359, 1297, '55.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5382, 360, 1297, '60.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5383, 359, 1298, '56.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5384, 360, 1298, '61.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5385, 359, 1299, '57.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5386, 360, 1299, '62.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5387, 359, 1300, '58.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5388, 360, 1300, '63.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5389, 359, 1301, '59.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5390, 360, 1301, '64.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5391, 359, 1302, '60.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5392, 360, 1302, '65.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5393, 359, 1303, '61.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5394, 360, 1303, '66.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5395, 359, 1304, '62.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5396, 360, 1304, '67.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5397, 359, 1305, '63.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5398, 360, 1305, '68.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5399, 359, 1306, '64.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5400, 360, 1306, '69.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5401, 361, 1232, '60.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5402, 362, 1232, '65.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5403, 361, 1233, '61.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5404, 362, 1233, '66.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5405, 361, 1234, '62.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5406, 362, 1234, '67.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5407, 361, 1235, '63.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5408, 362, 1235, '68.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5409, 361, 1236, '64.00', 'C', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5410, 362, 1236, '69.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5411, 361, 1237, '65.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5412, 362, 1237, '70.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5413, 361, 1238, '66.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5414, 362, 1238, '71.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5415, 361, 1239, '67.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5416, 362, 1239, '72.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5417, 361, 1240, '68.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5418, 362, 1240, '73.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5419, 361, 1241, '69.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5420, 362, 1241, '74.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5421, 361, 1242, '70.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5422, 362, 1242, '75.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5423, 361, 1243, '71.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5424, 362, 1243, '76.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5425, 361, 1244, '72.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5426, 362, 1244, '77.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5427, 361, 1245, '73.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5428, 362, 1245, '78.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5429, 361, 1246, '74.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5430, 362, 1246, '79.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5431, 363, 1292, '86.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5432, 364, 1292, '91.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5433, 363, 1293, '87.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5434, 364, 1293, '92.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5435, 363, 1294, '88.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5436, 364, 1294, '93.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5437, 363, 1295, '89.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5438, 364, 1295, '94.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5439, 363, 1296, '55.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5440, 364, 1296, '60.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5441, 363, 1297, '56.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5442, 364, 1297, '61.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5443, 363, 1298, '57.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5444, 364, 1298, '62.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5445, 363, 1299, '58.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5446, 364, 1299, '63.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5447, 363, 1300, '59.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5448, 364, 1300, '64.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5449, 363, 1301, '60.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5450, 364, 1301, '65.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5451, 363, 1302, '61.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5452, 364, 1302, '66.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5453, 363, 1303, '62.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5454, 364, 1303, '67.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5455, 363, 1304, '63.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5456, 364, 1304, '68.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5457, 363, 1305, '64.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5458, 364, 1305, '69.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5459, 363, 1306, '65.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5460, 364, 1306, '70.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5461, 365, 1232, '61.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5462, 366, 1232, '66.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5463, 365, 1233, '62.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5464, 366, 1233, '67.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5465, 365, 1234, '63.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5466, 366, 1234, '68.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5467, 365, 1235, '64.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5468, 366, 1235, '69.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5469, 365, 1236, '65.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5470, 366, 1236, '70.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5471, 365, 1237, '66.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5472, 366, 1237, '71.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5473, 365, 1238, '67.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5474, 366, 1238, '72.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5475, 365, 1239, '68.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5476, 366, 1239, '73.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5477, 365, 1240, '69.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5478, 366, 1240, '74.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5479, 365, 1241, '70.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5480, 366, 1241, '75.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5481, 365, 1242, '71.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5482, 366, 1242, '76.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5483, 365, 1243, '72.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5484, 366, 1243, '77.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5485, 365, 1244, '73.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5486, 366, 1244, '78.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5487, 365, 1245, '74.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5488, 366, 1245, '79.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5489, 365, 1246, '75.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5490, 366, 1246, '80.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5491, 367, 1292, '87.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5492, 368, 1292, '92.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5493, 367, 1293, '88.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5494, 368, 1293, '93.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5495, 367, 1294, '89.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5496, 368, 1294, '94.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5497, 367, 1295, '55.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5498, 368, 1295, '60.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5499, 367, 1296, '56.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5500, 368, 1296, '61.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5501, 367, 1297, '57.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5502, 368, 1297, '62.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5503, 367, 1298, '58.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5504, 368, 1298, '63.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5505, 367, 1299, '59.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5506, 368, 1299, '64.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5507, 367, 1300, '60.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5508, 368, 1300, '65.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5509, 367, 1301, '61.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5510, 368, 1301, '66.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5511, 367, 1302, '62.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5512, 368, 1302, '67.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5513, 367, 1303, '63.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5514, 368, 1303, '68.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5515, 367, 1304, '64.00', 'C', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5516, 368, 1304, '69.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5517, 367, 1305, '65.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5518, 368, 1305, '70.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5519, 367, 1306, '66.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5520, 368, 1306, '71.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5521, 369, 1247, '73.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5522, 370, 1247, '78.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5523, 369, 1248, '74.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5524, 370, 1248, '79.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5525, 369, 1249, '75.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5526, 370, 1249, '80.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5527, 369, 1250, '76.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5528, 370, 1250, '81.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5529, 369, 1251, '77.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5530, 370, 1251, '82.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5531, 369, 1252, '78.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5532, 370, 1252, '83.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5533, 369, 1253, '79.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5534, 370, 1253, '84.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5535, 369, 1254, '80.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5536, 370, 1254, '85.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5537, 369, 1255, '81.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5538, 370, 1255, '86.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5539, 369, 1256, '82.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5540, 370, 1256, '87.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5541, 369, 1257, '83.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5542, 370, 1257, '88.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5543, 369, 1258, '84.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5544, 370, 1258, '89.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5545, 369, 1259, '85.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5546, 370, 1259, '90.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5547, 369, 1260, '86.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5548, 370, 1260, '91.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5549, 369, 1261, '87.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5550, 370, 1261, '92.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5551, 371, 1307, '64.00', 'C', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5552, 372, 1307, '69.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5553, 371, 1308, '65.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5554, 372, 1308, '70.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5555, 371, 1309, '66.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5556, 372, 1309, '71.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5557, 371, 1310, '67.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5558, 372, 1310, '72.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5559, 371, 1311, '68.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5560, 372, 1311, '73.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5561, 371, 1312, '69.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5562, 372, 1312, '74.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5563, 371, 1313, '70.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5564, 372, 1313, '75.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5565, 371, 1314, '71.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5566, 372, 1314, '76.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5567, 371, 1315, '72.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5568, 372, 1315, '77.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5569, 371, 1316, '73.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5570, 372, 1316, '78.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5571, 371, 1317, '74.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5572, 372, 1317, '79.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5573, 371, 1318, '75.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5574, 372, 1318, '80.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5575, 371, 1319, '76.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5576, 372, 1319, '81.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5577, 371, 1320, '77.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5578, 372, 1320, '82.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5579, 371, 1321, '78.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5580, 372, 1321, '83.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5581, 373, 1247, '74.00', 'B', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5582, 374, 1247, '79.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5583, 373, 1248, '75.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5584, 374, 1248, '80.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5585, 373, 1249, '76.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5586, 374, 1249, '81.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5587, 373, 1250, '77.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5588, 374, 1250, '82.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5589, 373, 1251, '78.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5590, 374, 1251, '83.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5591, 373, 1252, '79.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5592, 374, 1252, '84.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5593, 373, 1253, '80.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5594, 374, 1253, '85.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5595, 373, 1254, '81.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5596, 374, 1254, '86.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5597, 373, 1255, '82.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5598, 374, 1255, '87.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5599, 373, 1256, '83.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5600, 374, 1256, '88.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5601, 373, 1257, '84.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5602, 374, 1257, '89.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5603, 373, 1258, '85.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5604, 374, 1258, '90.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5605, 373, 1259, '86.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5606, 374, 1259, '91.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5607, 373, 1260, '87.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5608, 374, 1260, '92.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5609, 373, 1261, '88.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5610, 374, 1261, '93.00', 'A', 0, 11, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5611, 375, 1307, '65.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5612, 376, 1307, '70.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5613, 375, 1308, '66.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5614, 376, 1308, '71.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5615, 375, 1309, '67.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5616, 376, 1309, '72.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5617, 375, 1310, '68.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5618, 376, 1310, '73.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5619, 375, 1311, '69.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5620, 376, 1311, '74.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5621, 375, 1312, '70.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5622, 376, 1312, '75.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5623, 375, 1313, '71.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5624, 376, 1313, '76.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5625, 375, 1314, '72.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5626, 376, 1314, '77.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5627, 375, 1315, '73.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5628, 376, 1315, '78.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5629, 375, 1316, '74.00', 'B', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5630, 376, 1316, '79.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5631, 375, 1317, '75.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5632, 376, 1317, '80.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5633, 375, 1318, '76.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5634, 376, 1318, '81.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5635, 375, 1319, '77.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5636, 376, 1319, '82.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5637, 375, 1320, '78.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5638, 376, 1320, '83.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5639, 375, 1321, '79.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5640, 376, 1321, '84.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5641, 377, 1247, '75.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5642, 378, 1247, '80.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5643, 377, 1248, '76.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5644, 378, 1248, '81.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5645, 377, 1249, '77.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5646, 378, 1249, '82.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5647, 377, 1250, '78.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5648, 378, 1250, '83.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5649, 377, 1251, '79.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5650, 378, 1251, '84.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5651, 377, 1252, '80.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5652, 378, 1252, '85.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5653, 377, 1253, '81.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5654, 378, 1253, '86.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5655, 377, 1254, '82.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5656, 378, 1254, '87.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5657, 377, 1255, '83.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5658, 378, 1255, '88.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5659, 377, 1256, '84.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5660, 378, 1256, '89.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5661, 377, 1257, '85.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5662, 378, 1257, '90.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5663, 377, 1258, '86.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5664, 378, 1258, '91.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5665, 377, 1259, '87.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5666, 378, 1259, '92.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5667, 377, 1260, '88.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5668, 378, 1260, '93.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5669, 377, 1261, '89.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5670, 378, 1261, '94.00', 'A', 0, 8, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5671, 379, 1307, '66.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5672, 380, 1307, '71.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5673, 379, 1308, '67.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5674, 380, 1308, '72.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5675, 379, 1309, '68.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5676, 380, 1309, '73.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5677, 379, 1310, '69.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5678, 380, 1310, '74.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5679, 379, 1311, '70.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5680, 380, 1311, '75.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5681, 379, 1312, '71.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5682, 380, 1312, '76.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5683, 379, 1313, '72.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5684, 380, 1313, '77.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5685, 379, 1314, '73.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5686, 380, 1314, '78.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5687, 379, 1315, '74.00', 'B', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5688, 380, 1315, '79.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5689, 379, 1316, '75.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5690, 380, 1316, '80.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5691, 379, 1317, '76.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5692, 380, 1317, '81.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5693, 379, 1318, '77.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5694, 380, 1318, '82.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5695, 379, 1319, '78.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5696, 380, 1319, '83.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5697, 379, 1320, '79.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5698, 380, 1320, '84.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5699, 379, 1321, '80.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5700, 380, 1321, '85.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5701, 381, 1247, '76.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5702, 382, 1247, '81.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5703, 381, 1248, '77.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5704, 382, 1248, '82.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5705, 381, 1249, '78.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5706, 382, 1249, '83.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5707, 381, 1250, '79.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5708, 382, 1250, '84.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5709, 381, 1251, '80.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5710, 382, 1251, '85.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5711, 381, 1252, '81.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5712, 382, 1252, '86.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5713, 381, 1253, '82.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5714, 382, 1253, '87.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5715, 381, 1254, '83.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5716, 382, 1254, '88.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5717, 381, 1255, '84.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5718, 382, 1255, '89.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5719, 381, 1256, '85.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5720, 382, 1256, '90.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5721, 381, 1257, '86.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5722, 382, 1257, '91.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5723, 381, 1258, '87.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5724, 382, 1258, '92.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5725, 381, 1259, '88.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5726, 382, 1259, '93.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5727, 381, 1260, '89.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5728, 382, 1260, '94.00', 'A', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5729, 381, 1261, '55.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5730, 382, 1261, '60.00', 'C', 0, 9, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5731, 383, 1307, '67.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5732, 384, 1307, '72.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5733, 383, 1308, '68.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5734, 384, 1308, '73.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5735, 383, 1309, '69.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5736, 384, 1309, '74.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5737, 383, 1310, '70.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5738, 384, 1310, '75.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5739, 383, 1311, '71.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5740, 384, 1311, '76.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5741, 383, 1312, '72.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5742, 384, 1312, '77.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5743, 383, 1313, '73.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5744, 384, 1313, '78.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5745, 383, 1314, '74.00', 'B', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5746, 384, 1314, '79.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5747, 383, 1315, '75.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5748, 384, 1315, '80.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5749, 383, 1316, '76.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5750, 384, 1316, '81.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5751, 383, 1317, '77.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5752, 384, 1317, '82.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5753, 383, 1318, '78.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5754, 384, 1318, '83.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5755, 383, 1319, '79.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5756, 384, 1319, '84.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5757, 383, 1320, '80.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5758, 384, 1320, '85.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5759, 383, 1321, '81.00', 'A', 0, 10, '2026-05-28 15:47:22');
INSERT INTO `marks` (`id`,`assessment_id`,`student_id`,`score`,`grade`,`moderated`,`entered_by`,`entered_at`) VALUES (5760, 384, 1321, '86.00', 'A', 0, 10, '2026-05-28 15:47:22');

-- Table: messages
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` int(10) unsigned NOT NULL,
  `recipient_id` int(10) unsigned NOT NULL,
  `subject` varchar(200) NOT NULL,
  `body` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `sender_id` (`sender_id`),
  KEY `recipient_id` (`recipient_id`),
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: module_registrations
DROP TABLE IF EXISTS `module_registrations`;
CREATE TABLE `module_registrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int(10) unsigned NOT NULL,
  `module_id` int(10) unsigned NOT NULL,
  `academic_year` varchar(20) NOT NULL,
  `status` enum('registered','completed','failed','carried') DEFAULT 'registered',
  `grade` varchar(5) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_module_year` (`student_id`,`module_id`,`academic_year`),
  KEY `module_id` (`module_id`),
  CONSTRAINT `module_registrations_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `module_registrations_ibfk_2` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5281 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4801, 1202, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4802, 1202, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4803, 1202, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4804, 1202, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4805, 1203, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4806, 1203, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4807, 1203, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4808, 1203, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4809, 1204, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4810, 1204, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4811, 1204, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4812, 1204, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4813, 1205, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4814, 1205, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4815, 1205, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4816, 1205, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4817, 1206, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4818, 1206, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4819, 1206, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4820, 1206, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4821, 1207, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4822, 1207, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4823, 1207, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4824, 1207, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4825, 1208, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4826, 1208, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4827, 1208, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4828, 1208, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4829, 1209, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4830, 1209, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4831, 1209, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4832, 1209, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4833, 1210, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4834, 1210, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4835, 1210, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4836, 1210, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4837, 1211, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4838, 1211, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4839, 1211, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4840, 1211, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4841, 1212, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4842, 1212, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4843, 1212, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4844, 1212, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4845, 1213, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4846, 1213, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4847, 1213, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4848, 1213, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4849, 1214, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4850, 1214, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4851, 1214, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4852, 1214, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4853, 1215, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4854, 1215, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4855, 1215, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4856, 1215, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4857, 1216, 1, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4858, 1216, 2, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4859, 1216, 3, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4860, 1216, 4, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4861, 1217, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4862, 1217, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4863, 1217, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4864, 1217, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4865, 1218, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4866, 1218, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4867, 1218, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4868, 1218, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4869, 1219, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4870, 1219, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4871, 1219, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4872, 1219, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4873, 1220, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4874, 1220, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4875, 1220, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4876, 1220, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4877, 1221, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4878, 1221, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4879, 1221, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4880, 1221, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4881, 1222, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4882, 1222, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4883, 1222, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4884, 1222, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4885, 1223, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4886, 1223, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4887, 1223, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4888, 1223, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4889, 1224, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4890, 1224, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4891, 1224, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4892, 1224, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4893, 1225, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4894, 1225, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4895, 1225, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4896, 1225, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4897, 1226, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4898, 1226, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4899, 1226, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4900, 1226, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4901, 1227, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4902, 1227, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4903, 1227, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4904, 1227, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4905, 1228, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4906, 1228, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4907, 1228, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4908, 1228, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4909, 1229, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4910, 1229, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4911, 1229, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4912, 1229, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4913, 1230, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4914, 1230, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4915, 1230, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4916, 1230, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4917, 1231, 5, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4918, 1231, 6, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4919, 1231, 7, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4920, 1231, 8, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4921, 1232, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4922, 1232, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4923, 1232, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4924, 1232, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4925, 1233, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4926, 1233, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4927, 1233, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4928, 1233, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4929, 1234, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4930, 1234, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4931, 1234, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4932, 1234, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4933, 1235, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4934, 1235, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4935, 1235, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4936, 1235, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4937, 1236, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4938, 1236, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4939, 1236, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4940, 1236, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4941, 1237, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4942, 1237, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4943, 1237, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4944, 1237, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4945, 1238, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4946, 1238, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4947, 1238, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4948, 1238, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4949, 1239, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4950, 1239, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4951, 1239, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4952, 1239, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4953, 1240, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4954, 1240, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4955, 1240, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4956, 1240, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4957, 1241, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4958, 1241, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4959, 1241, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4960, 1241, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4961, 1242, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4962, 1242, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4963, 1242, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4964, 1242, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4965, 1243, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4966, 1243, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4967, 1243, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4968, 1243, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4969, 1244, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4970, 1244, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4971, 1244, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4972, 1244, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4973, 1245, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4974, 1245, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4975, 1245, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4976, 1245, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4977, 1246, 9, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4978, 1246, 10, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4979, 1246, 11, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4980, 1246, 12, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4981, 1247, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4982, 1247, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4983, 1247, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4984, 1247, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4985, 1248, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4986, 1248, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4987, 1248, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4988, 1248, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4989, 1249, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4990, 1249, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4991, 1249, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4992, 1249, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4993, 1250, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4994, 1250, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4995, 1250, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4996, 1250, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4997, 1251, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4998, 1251, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (4999, 1251, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5000, 1251, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5001, 1252, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5002, 1252, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5003, 1252, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5004, 1252, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5005, 1253, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5006, 1253, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5007, 1253, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5008, 1253, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5009, 1254, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5010, 1254, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5011, 1254, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5012, 1254, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5013, 1255, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5014, 1255, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5015, 1255, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5016, 1255, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5017, 1256, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5018, 1256, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5019, 1256, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5020, 1256, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5021, 1257, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5022, 1257, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5023, 1257, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5024, 1257, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5025, 1258, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5026, 1258, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5027, 1258, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5028, 1258, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5029, 1259, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5030, 1259, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5031, 1259, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5032, 1259, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5033, 1260, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5034, 1260, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5035, 1260, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5036, 1260, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5037, 1261, 13, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5038, 1261, 14, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5039, 1261, 15, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5040, 1261, 16, '2026', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5041, 1262, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5042, 1262, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5043, 1262, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5044, 1262, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5045, 1263, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5046, 1263, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5047, 1263, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5048, 1263, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5049, 1264, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5050, 1264, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5051, 1264, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5052, 1264, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5053, 1265, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5054, 1265, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5055, 1265, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5056, 1265, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5057, 1266, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5058, 1266, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5059, 1266, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5060, 1266, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5061, 1267, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5062, 1267, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5063, 1267, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5064, 1267, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5065, 1268, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5066, 1268, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5067, 1268, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5068, 1268, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5069, 1269, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5070, 1269, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5071, 1269, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5072, 1269, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5073, 1270, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5074, 1270, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5075, 1270, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5076, 1270, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5077, 1271, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5078, 1271, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5079, 1271, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5080, 1271, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5081, 1272, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5082, 1272, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5083, 1272, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5084, 1272, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5085, 1273, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5086, 1273, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5087, 1273, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5088, 1273, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5089, 1274, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5090, 1274, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5091, 1274, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5092, 1274, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5093, 1275, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5094, 1275, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5095, 1275, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5096, 1275, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5097, 1276, 1, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5098, 1276, 2, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5099, 1276, 3, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5100, 1276, 4, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5101, 1277, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5102, 1277, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5103, 1277, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5104, 1277, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5105, 1278, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5106, 1278, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5107, 1278, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5108, 1278, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5109, 1279, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5110, 1279, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5111, 1279, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5112, 1279, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5113, 1280, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5114, 1280, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5115, 1280, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5116, 1280, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5117, 1281, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5118, 1281, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5119, 1281, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5120, 1281, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5121, 1282, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5122, 1282, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5123, 1282, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5124, 1282, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5125, 1283, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5126, 1283, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5127, 1283, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5128, 1283, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5129, 1284, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5130, 1284, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5131, 1284, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5132, 1284, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5133, 1285, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5134, 1285, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5135, 1285, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5136, 1285, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5137, 1286, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5138, 1286, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5139, 1286, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5140, 1286, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5141, 1287, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5142, 1287, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5143, 1287, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5144, 1287, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5145, 1288, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5146, 1288, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5147, 1288, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5148, 1288, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5149, 1289, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5150, 1289, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5151, 1289, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5152, 1289, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5153, 1290, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5154, 1290, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5155, 1290, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5156, 1290, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5157, 1291, 5, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5158, 1291, 6, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5159, 1291, 7, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5160, 1291, 8, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5161, 1292, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5162, 1292, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5163, 1292, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5164, 1292, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5165, 1293, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5166, 1293, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5167, 1293, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5168, 1293, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5169, 1294, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5170, 1294, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5171, 1294, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5172, 1294, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5173, 1295, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5174, 1295, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5175, 1295, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5176, 1295, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5177, 1296, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5178, 1296, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5179, 1296, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5180, 1296, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5181, 1297, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5182, 1297, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5183, 1297, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5184, 1297, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5185, 1298, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5186, 1298, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5187, 1298, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5188, 1298, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5189, 1299, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5190, 1299, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5191, 1299, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5192, 1299, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5193, 1300, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5194, 1300, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5195, 1300, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5196, 1300, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5197, 1301, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5198, 1301, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5199, 1301, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5200, 1301, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5201, 1302, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5202, 1302, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5203, 1302, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5204, 1302, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5205, 1303, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5206, 1303, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5207, 1303, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5208, 1303, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5209, 1304, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5210, 1304, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5211, 1304, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5212, 1304, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5213, 1305, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5214, 1305, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5215, 1305, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5216, 1305, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5217, 1306, 9, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5218, 1306, 10, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5219, 1306, 11, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5220, 1306, 12, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5221, 1307, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5222, 1307, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5223, 1307, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5224, 1307, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5225, 1308, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5226, 1308, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5227, 1308, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5228, 1308, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5229, 1309, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5230, 1309, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5231, 1309, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5232, 1309, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5233, 1310, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5234, 1310, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5235, 1310, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5236, 1310, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5237, 1311, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5238, 1311, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5239, 1311, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5240, 1311, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5241, 1312, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5242, 1312, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5243, 1312, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5244, 1312, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5245, 1313, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5246, 1313, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5247, 1313, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5248, 1313, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5249, 1314, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5250, 1314, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5251, 1314, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5252, 1314, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5253, 1315, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5254, 1315, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5255, 1315, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5256, 1315, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5257, 1316, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5258, 1316, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5259, 1316, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5260, 1316, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5261, 1317, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5262, 1317, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5263, 1317, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5264, 1317, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5265, 1318, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5266, 1318, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5267, 1318, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5268, 1318, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5269, 1319, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5270, 1319, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5271, 1319, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5272, 1319, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5273, 1320, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5274, 1320, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5275, 1320, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5276, 1320, 16, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5277, 1321, 13, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5278, 1321, 14, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5279, 1321, 15, '2027', 'registered', NULL);
INSERT INTO `module_registrations` (`id`,`student_id`,`module_id`,`academic_year`,`status`,`grade`) VALUES (5280, 1321, 16, '2027', 'registered', NULL);

-- Table: modules
DROP TABLE IF EXISTS `modules`;
CREATE TABLE `modules` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `program_id` int(10) unsigned NOT NULL,
  `code` varchar(20) NOT NULL,
  `name` varchar(200) NOT NULL,
  `credits` decimal(4,2) DEFAULT 0.00,
  `semester` tinyint(3) unsigned DEFAULT 1,
  `is_core` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_program_module` (`program_id`,`code`),
  CONSTRAINT `modules_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (1, 1, 'SC-HOSP-101-M1', 'Introduction to Hospitality Operations', '6.00', 1, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (2, 1, 'SC-HOSP-101-M2', 'Core Skills for Hospitality Operations', '6.00', 1, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (3, 1, 'SC-HOSP-101-M3', 'Applied Practice in Hospitality Operations', '6.00', 2, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (4, 1, 'SC-HOSP-101-M4', 'Industry Placement and Review', '6.00', 2, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (5, 2, 'PC-CUL-201-M1', 'Introduction to Culinary Arts', '6.00', 1, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (6, 2, 'PC-CUL-201-M2', 'Core Skills for Culinary Arts', '6.00', 1, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (7, 2, 'PC-CUL-201-M3', 'Applied Practice in Culinary Arts', '6.00', 2, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (8, 2, 'PC-CUL-201-M4', 'Industry Placement and Review', '6.00', 2, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (9, 3, 'DIP-TOUR-301-M1', 'Introduction to Tourism Management', '6.00', 1, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (10, 3, 'DIP-TOUR-301-M2', 'Core Skills for Tourism Management', '6.00', 1, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (11, 3, 'DIP-TOUR-301-M3', 'Applied Practice in Tourism Management', '6.00', 2, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (12, 3, 'DIP-TOUR-301-M4', 'Industry Placement and Review', '6.00', 2, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (13, 4, 'HND-HOSP-401-M1', 'Introduction to Hospitality Management', '6.00', 1, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (14, 4, 'HND-HOSP-401-M2', 'Core Skills for Hospitality Management', '6.00', 1, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (15, 4, 'HND-HOSP-401-M3', 'Applied Practice in Hospitality Management', '6.00', 2, 1);
INSERT INTO `modules` (`id`,`program_id`,`code`,`name`,`credits`,`semester`,`is_core`) VALUES (16, 4, 'HND-HOSP-401-M4', 'Industry Placement and Review', '6.00', 2, 1);

-- Table: notifications
DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `channel` enum('system','email','sms','push') DEFAULT 'system',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: password_resets
DROP TABLE IF EXISTS `password_resets`;
CREATE TABLE `password_resets` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `token` varchar(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `password_resets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: payable_payments
DROP TABLE IF EXISTS `payable_payments`;
CREATE TABLE `payable_payments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `payable_id` int(10) unsigned NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `payment_method` varchar(30) NOT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `paid_by` int(10) unsigned DEFAULT NULL,
  `paid_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `payable_id` (`payable_id`),
  CONSTRAINT `payable_payments_ibfk_1` FOREIGN KEY (`payable_id`) REFERENCES `payables` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `payable_payments` (`id`,`payable_id`,`amount`,`payment_method`,`reference`,`paid_by`,`paid_at`) VALUES (4, 4, '400.00', 'bank', 'SEED-PAYABLE-1', 7, '2026-05-28 15:47:23');
INSERT INTO `payable_payments` (`id`,`payable_id`,`amount`,`payment_method`,`reference`,`paid_by`,`paid_at`) VALUES (5, 5, '400.00', 'bank', 'SEED-PAYABLE-2', 7, '2026-05-28 15:47:23');
INSERT INTO `payable_payments` (`id`,`payable_id`,`amount`,`payment_method`,`reference`,`paid_by`,`paid_at`) VALUES (6, 6, '400.00', 'bank', 'SEED-PAYABLE-3', 7, '2026-05-28 15:47:23');

-- Table: payables
DROP TABLE IF EXISTS `payables`;
CREATE TABLE `payables` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `bill_number` varchar(30) NOT NULL,
  `supplier_id` int(10) unsigned NOT NULL,
  `category_id` int(10) unsigned DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `amount` decimal(14,2) NOT NULL,
  `amount_paid` decimal(14,2) DEFAULT 0.00,
  `currency` enum('USD','ZWL') DEFAULT 'USD',
  `due_date` date NOT NULL,
  `status` enum('pending','partial','paid','cancelled') DEFAULT 'pending',
  `created_by` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `bill_number` (`bill_number`),
  KEY `supplier_id` (`supplier_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `payables_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `payables_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `expense_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `payables` (`id`,`bill_number`,`supplier_id`,`category_id`,`description`,`amount`,`amount_paid`,`currency`,`due_date`,`status`,`created_by`,`created_at`) VALUES (4, 'SEED-BILL-001', 4, NULL, 'Seed supplier bill 1', '1200.00', '0.00', 'USD', '2027-10-15', 'pending', 7, '2026-05-28 15:47:23');
INSERT INTO `payables` (`id`,`bill_number`,`supplier_id`,`category_id`,`description`,`amount`,`amount_paid`,`currency`,`due_date`,`status`,`created_by`,`created_at`) VALUES (5, 'SEED-BILL-002', 5, NULL, 'Seed supplier bill 2', '1600.00', '0.00', 'USD', '2027-10-15', 'pending', 7, '2026-05-28 15:47:23');
INSERT INTO `payables` (`id`,`bill_number`,`supplier_id`,`category_id`,`description`,`amount`,`amount_paid`,`currency`,`due_date`,`status`,`created_by`,`created_at`) VALUES (6, 'SEED-BILL-003', 6, NULL, 'Seed supplier bill 3', '2000.00', '0.00', 'USD', '2027-10-15', 'pending', 7, '2026-05-28 15:47:23');

-- Table: payments
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `receipt_number` varchar(30) DEFAULT NULL,
  `invoice_id` int(10) unsigned NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `currency` enum('USD','ZWL') DEFAULT 'USD',
  `exchange_rate` decimal(12,4) DEFAULT 1.0000,
  `payment_method` enum('cash','bank','mobile','gateway','pos','card') NOT NULL,
  `reference` varchar(100) DEFAULT NULL,
  `pop_file` varchar(255) DEFAULT NULL,
  `status` enum('pending','confirmed','rejected') DEFAULT 'confirmed',
  `received_by` int(10) unsigned DEFAULT NULL,
  `sponsor_id` int(10) unsigned DEFAULT NULL,
  `paid_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `receipt_number` (`receipt_number`),
  KEY `invoice_id` (`invoice_id`),
  KEY `received_by` (`received_by`),
  CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`received_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (61, 'SEED-RCT-0001', 121, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0001', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:22');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (62, 'SEED-RCT-0003', 123, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0003', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (63, 'SEED-RCT-0005', 125, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0005', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (64, 'SEED-RCT-0007', 127, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0007', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (65, 'SEED-RCT-0009', 129, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0009', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (66, 'SEED-RCT-0011', 131, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0011', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (67, 'SEED-RCT-0013', 133, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0013', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (68, 'SEED-RCT-0015', 135, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0015', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (69, 'SEED-RCT-0017', 137, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0017', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (70, 'SEED-RCT-0019', 139, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0019', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (71, 'SEED-RCT-0021', 141, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0021', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (72, 'SEED-RCT-0023', 143, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0023', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (73, 'SEED-RCT-0025', 145, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0025', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (74, 'SEED-RCT-0027', 147, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0027', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (75, 'SEED-RCT-0029', 149, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0029', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (76, 'SEED-RCT-0031', 151, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0031', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (77, 'SEED-RCT-0033', 153, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0033', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (78, 'SEED-RCT-0035', 155, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0035', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (79, 'SEED-RCT-0037', 157, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0037', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (80, 'SEED-RCT-0039', 159, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0039', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (81, 'SEED-RCT-0041', 161, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0041', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (82, 'SEED-RCT-0043', 163, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0043', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (83, 'SEED-RCT-0045', 165, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0045', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (84, 'SEED-RCT-0047', 167, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0047', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (85, 'SEED-RCT-0049', 169, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0049', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (86, 'SEED-RCT-0051', 171, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0051', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (87, 'SEED-RCT-0053', 173, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0053', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (88, 'SEED-RCT-0055', 175, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0055', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (89, 'SEED-RCT-0057', 177, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0057', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (90, 'SEED-RCT-0059', 179, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0059', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (91, 'SEED-RCT-0061', 181, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0061', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (92, 'SEED-RCT-0063', 183, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0063', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (93, 'SEED-RCT-0065', 185, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0065', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (94, 'SEED-RCT-0067', 187, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0067', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (95, 'SEED-RCT-0069', 189, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0069', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (96, 'SEED-RCT-0071', 191, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0071', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (97, 'SEED-RCT-0073', 193, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0073', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (98, 'SEED-RCT-0075', 195, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0075', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (99, 'SEED-RCT-0077', 197, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0077', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (100, 'SEED-RCT-0079', 199, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0079', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (101, 'SEED-RCT-0081', 201, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0081', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (102, 'SEED-RCT-0083', 203, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0083', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (103, 'SEED-RCT-0085', 205, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0085', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (104, 'SEED-RCT-0087', 207, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0087', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (105, 'SEED-RCT-0089', 209, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0089', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (106, 'SEED-RCT-0091', 211, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0091', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (107, 'SEED-RCT-0093', 213, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0093', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (108, 'SEED-RCT-0095', 215, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0095', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (109, 'SEED-RCT-0097', 217, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0097', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (110, 'SEED-RCT-0099', 219, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0099', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (111, 'SEED-RCT-0101', 221, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0101', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (112, 'SEED-RCT-0103', 223, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0103', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (113, 'SEED-RCT-0105', 225, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0105', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (114, 'SEED-RCT-0107', 227, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0107', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (115, 'SEED-RCT-0109', 229, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0109', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (116, 'SEED-RCT-0111', 231, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0111', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (117, 'SEED-RCT-0113', 233, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0113', NULL, 'confirmed', 7, 3, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (118, 'SEED-RCT-0115', 235, '250.00', 'USD', '1.0000', 'cash', 'SEEDPAY0115', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (119, 'SEED-RCT-0117', 237, '350.00', 'USD', '1.0000', 'mobile', 'SEEDPAY0117', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');
INSERT INTO `payments` (`id`,`receipt_number`,`invoice_id`,`amount`,`currency`,`exchange_rate`,`payment_method`,`reference`,`pop_file`,`status`,`received_by`,`sponsor_id`,`paid_at`) VALUES (120, 'SEED-RCT-0119', 239, '300.00', 'USD', '1.0000', 'pos', 'SEEDPAY0119', NULL, 'confirmed', 7, NULL, '2026-05-28 15:47:23');

-- Table: placement_logbooks
DROP TABLE IF EXISTS `placement_logbooks`;
CREATE TABLE `placement_logbooks` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `placement_id` int(10) unsigned NOT NULL,
  `log_date` date NOT NULL,
  `activities` text NOT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `placement_id` (`placement_id`),
  CONSTRAINT `placement_logbooks_ibfk_1` FOREIGN KEY (`placement_id`) REFERENCES `placements` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (16, 16, '2026-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (17, 17, '2026-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (18, 18, '2026-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (19, 19, '2026-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (20, 20, '2026-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (21, 21, '2026-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (22, 22, '2026-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (23, 23, '2026-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (24, 24, '2027-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (25, 25, '2027-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (26, 26, '2027-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (27, 27, '2027-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (28, 28, '2027-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (29, 29, '2027-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');
INSERT INTO `placement_logbooks` (`id`,`placement_id`,`log_date`,`activities`,`submitted_at`) VALUES (30, 30, '2027-06-10', 'Seed logbook entry for testing', '2026-05-28 15:47:23');

-- Table: placements
DROP TABLE IF EXISTS `placements`;
CREATE TABLE `placements` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int(10) unsigned NOT NULL,
  `employer_name` varchar(200) NOT NULL,
  `supervisor_name` varchar(150) DEFAULT NULL,
  `supervisor_contact` varchar(80) DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('pending','active','completed','terminated') DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `placements_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (16, 1202, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2026-06-01', '2026-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (17, 1210, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2026-06-01', '2026-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (18, 1218, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2026-06-01', '2026-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (19, 1226, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2026-06-01', '2026-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (20, 1234, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2026-06-01', '2026-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (21, 1242, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2026-06-01', '2026-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (22, 1250, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2026-06-01', '2026-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (23, 1258, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2026-06-01', '2026-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (24, 1266, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2027-06-01', '2027-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (25, 1274, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2027-06-01', '2027-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (26, 1282, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2027-06-01', '2027-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (27, 1290, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2027-06-01', '2027-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (28, 1298, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2027-06-01', '2027-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (29, 1306, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2027-06-01', '2027-08-31', 'active');
INSERT INTO `placements` (`id`,`student_id`,`employer_name`,`supervisor_name`,`supervisor_contact`,`start_date`,`end_date`,`status`) VALUES (30, 1314, 'Seed Hotel Group', 'Seed Supervisor', '+263780111111', '2027-06-01', '2027-08-31', 'active');

-- Table: programs
DROP TABLE IF EXISTS `programs`;
CREATE TABLE `programs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `name` varchar(200) NOT NULL,
  `program_type` enum('short_course','certificate','diploma','hnd') NOT NULL,
  `duration_months` smallint(5) unsigned DEFAULT 12,
  `total_credits` decimal(6,2) DEFAULT 0.00,
  `description` text DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `programs` (`id`,`code`,`name`,`program_type`,`duration_months`,`total_credits`,`description`,`status`,`created_at`) VALUES (1, 'SC-HOSP-101', 'Certificate in Hospitality Operations', 'short_course', 3, '12.00', 'Short course in hospitality operations', 'active', '2026-05-21 09:22:06');
INSERT INTO `programs` (`id`,`code`,`name`,`program_type`,`duration_months`,`total_credits`,`description`,`status`,`created_at`) VALUES (2, 'PC-CUL-201', 'Professional Certificate in Culinary Arts', 'certificate', 6, '24.00', 'Professional culinary certificate', 'active', '2026-05-21 09:22:06');
INSERT INTO `programs` (`id`,`code`,`name`,`program_type`,`duration_months`,`total_credits`,`description`,`status`,`created_at`) VALUES (3, 'DIP-TOUR-301', 'Diploma in Tourism Management', 'diploma', 24, '120.00', 'Tourism management diploma', 'active', '2026-05-21 09:22:06');
INSERT INTO `programs` (`id`,`code`,`name`,`program_type`,`duration_months`,`total_credits`,`description`,`status`,`created_at`) VALUES (4, 'HND-HOSP-401', 'Higher National Diploma in Hospitality Management', 'hnd', 36, '240.00', 'HND in hospitality management', 'active', '2026-05-21 09:22:06');

-- Table: purchase_orders
DROP TABLE IF EXISTS `purchase_orders`;
CREATE TABLE `purchase_orders` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `po_number` varchar(30) NOT NULL,
  `requisition_id` int(10) unsigned DEFAULT NULL,
  `supplier_id` int(10) unsigned NOT NULL,
  `total_amount` decimal(14,2) NOT NULL,
  `status` enum('draft','sent','partial','received','cancelled') DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `po_number` (`po_number`),
  KEY `requisition_id` (`requisition_id`),
  KEY `supplier_id` (`supplier_id`),
  CONSTRAINT `purchase_orders_ibfk_1` FOREIGN KEY (`requisition_id`) REFERENCES `purchase_requisitions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `purchase_orders_ibfk_2` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `purchase_orders` (`id`,`po_number`,`requisition_id`,`supplier_id`,`total_amount`,`status`,`created_at`) VALUES (4, 'SEED-PO-001', 4, 4, '1200.00', 'received', '2026-05-28 15:47:23');
INSERT INTO `purchase_orders` (`id`,`po_number`,`requisition_id`,`supplier_id`,`total_amount`,`status`,`created_at`) VALUES (5, 'SEED-PO-002', 5, 5, '1600.00', 'received', '2026-05-28 15:47:23');
INSERT INTO `purchase_orders` (`id`,`po_number`,`requisition_id`,`supplier_id`,`total_amount`,`status`,`created_at`) VALUES (6, 'SEED-PO-003', 6, 6, '2000.00', 'received', '2026-05-28 15:47:23');

-- Table: purchase_requisitions
DROP TABLE IF EXISTS `purchase_requisitions`;
CREATE TABLE `purchase_requisitions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `req_number` varchar(30) NOT NULL,
  `department` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `estimated_total` decimal(14,2) NOT NULL,
  `status` enum('draft','hod_approved','finance_approved','procurement_approved','rejected','ordered') DEFAULT 'draft',
  `requested_by` int(10) unsigned DEFAULT NULL,
  `hod_approved_by` int(10) unsigned DEFAULT NULL,
  `finance_approved_by` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `req_number` (`req_number`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `purchase_requisitions` (`id`,`req_number`,`department`,`description`,`estimated_total`,`status`,`requested_by`,`hod_approved_by`,`finance_approved_by`,`created_at`) VALUES (4, 'SEED-REQ-001', 'Operations', 'Seed procurement request 1', '1200.00', 'finance_approved', 6, 6, 7, '2026-05-28 15:47:23');
INSERT INTO `purchase_requisitions` (`id`,`req_number`,`department`,`description`,`estimated_total`,`status`,`requested_by`,`hod_approved_by`,`finance_approved_by`,`created_at`) VALUES (5, 'SEED-REQ-002', 'Operations', 'Seed procurement request 2', '1600.00', 'finance_approved', 6, 6, 7, '2026-05-28 15:47:23');
INSERT INTO `purchase_requisitions` (`id`,`req_number`,`department`,`description`,`estimated_total`,`status`,`requested_by`,`hod_approved_by`,`finance_approved_by`,`created_at`) VALUES (6, 'SEED-REQ-003', 'Operations', 'Seed procurement request 3', '2000.00', 'finance_approved', 6, 6, 7, '2026-05-28 15:47:23');

-- Table: rooms
DROP TABLE IF EXISTS `rooms`;
CREATE TABLE `rooms` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `capacity` smallint(5) unsigned DEFAULT 30,
  `room_type` enum('classroom','lab','hall','online') DEFAULT 'classroom',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `rooms` (`id`,`name`,`capacity`,`room_type`) VALUES (1, 'Lecture Hall A', 80, 'hall');
INSERT INTO `rooms` (`id`,`name`,`capacity`,`room_type`) VALUES (2, 'Computer Lab 1', 30, 'lab');
INSERT INTO `rooms` (`id`,`name`,`capacity`,`room_type`) VALUES (3, 'Training Kitchen', 25, 'lab');
INSERT INTO `rooms` (`id`,`name`,`capacity`,`room_type`) VALUES (4, 'Online Platform', 500, 'online');

-- Table: sponsor_students
DROP TABLE IF EXISTS `sponsor_students`;
CREATE TABLE `sponsor_students` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sponsor_id` int(10) unsigned NOT NULL,
  `student_id` int(10) unsigned NOT NULL,
  `coverage_percent` decimal(5,2) DEFAULT 100.00,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sponsor_student` (`sponsor_id`,`student_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `sponsor_students_ibfk_1` FOREIGN KEY (`sponsor_id`) REFERENCES `finance_sponsors` (`id`) ON DELETE CASCADE,
  CONSTRAINT `sponsor_students_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (13, 3, 1202, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (14, 4, 1212, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (15, 3, 1222, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (16, 4, 1232, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (17, 3, 1242, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (18, 4, 1252, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (19, 3, 1262, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (20, 4, 1272, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (21, 3, 1282, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (22, 4, 1292, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (23, 3, 1302, '100.00');
INSERT INTO `sponsor_students` (`id`,`sponsor_id`,`student_id`,`coverage_percent`) VALUES (24, 4, 1312, '100.00');

-- Table: staff
DROP TABLE IF EXISTS `staff`;
CREATE TABLE `staff` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `staff_number` varchar(30) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `hire_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `staff_number` (`staff_number`),
  CONSTRAINT `staff_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `staff` (`id`,`user_id`,`staff_number`,`department`,`position`,`hire_date`) VALUES (1, 6, 'SR-0001', 'Academic Registry', 'Registrar', '2025-01-15');
INSERT INTO `staff` (`id`,`user_id`,`staff_number`,`department`,`position`,`hire_date`) VALUES (2, 7, 'SF-0001', 'Finance', 'Finance Officer', '2025-01-15');
INSERT INTO `staff` (`id`,`user_id`,`staff_number`,`department`,`position`,`hire_date`) VALUES (3, 8, 'SL-0001', 'Hospitality', 'Lecturer', '2025-01-15');
INSERT INTO `staff` (`id`,`user_id`,`staff_number`,`department`,`position`,`hire_date`) VALUES (4, 9, 'SL-0002', 'Culinary', 'Lecturer', '2025-01-15');
INSERT INTO `staff` (`id`,`user_id`,`staff_number`,`department`,`position`,`hire_date`) VALUES (5, 10, 'SL-0003', 'Tourism', 'Lecturer', '2025-01-15');
INSERT INTO `staff` (`id`,`user_id`,`staff_number`,`department`,`position`,`hire_date`) VALUES (6, 11, 'SL-0004', 'Management', 'Lecturer', '2025-01-15');

-- Table: stream_comments
DROP TABLE IF EXISTS `stream_comments`;
CREATE TABLE `stream_comments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `post_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `parent_id` int(10) unsigned DEFAULT NULL,
  `body` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `stream_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `stream_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stream_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stream_comments_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `stream_comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: stream_posts
DROP TABLE IF EXISTS `stream_posts`;
CREATE TABLE `stream_posts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `class_id` int(10) unsigned NOT NULL,
  `user_id` int(10) unsigned NOT NULL,
  `post_type` enum('announcement','material','assignment') DEFAULT 'announcement',
  `title` varchar(255) DEFAULT NULL,
  `body` text NOT NULL,
  `attachment_path` varchar(255) DEFAULT NULL,
  `external_url` varchar(500) DEFAULT NULL,
  `class_assignment_id` int(10) unsigned DEFAULT NULL,
  `scheduled_at` datetime DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `comments_enabled` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_class_published` (`class_id`,`published_at`),
  KEY `idx_assignment` (`class_assignment_id`),
  CONSTRAINT `stream_posts_ibfk_1` FOREIGN KEY (`class_id`) REFERENCES `classes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stream_posts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `stream_posts` (`id`,`class_id`,`user_id`,`post_type`,`title`,`body`,`attachment_path`,`external_url`,`class_assignment_id`,`scheduled_at`,`published_at`,`comments_enabled`,`created_at`) VALUES (13, 20, 8, 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', NULL, NULL, NULL, NULL, '2026-03-01 00:00:00', 1, '2026-05-28 15:47:22');
INSERT INTO `stream_posts` (`id`,`class_id`,`user_id`,`post_type`,`title`,`body`,`attachment_path`,`external_url`,`class_assignment_id`,`scheduled_at`,`published_at`,`comments_enabled`,`created_at`) VALUES (14, 21, 8, 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', NULL, NULL, NULL, NULL, '2026-03-01 00:00:00', 1, '2026-05-28 15:47:22');
INSERT INTO `stream_posts` (`id`,`class_id`,`user_id`,`post_type`,`title`,`body`,`attachment_path`,`external_url`,`class_assignment_id`,`scheduled_at`,`published_at`,`comments_enabled`,`created_at`) VALUES (15, 22, 8, 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', NULL, NULL, NULL, NULL, '2026-03-01 00:00:00', 1, '2026-05-28 15:47:22');
INSERT INTO `stream_posts` (`id`,`class_id`,`user_id`,`post_type`,`title`,`body`,`attachment_path`,`external_url`,`class_assignment_id`,`scheduled_at`,`published_at`,`comments_enabled`,`created_at`) VALUES (16, 23, 8, 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', NULL, NULL, NULL, NULL, '2026-03-01 00:00:00', 1, '2026-05-28 15:47:22');
INSERT INTO `stream_posts` (`id`,`class_id`,`user_id`,`post_type`,`title`,`body`,`attachment_path`,`external_url`,`class_assignment_id`,`scheduled_at`,`published_at`,`comments_enabled`,`created_at`) VALUES (17, 24, 8, 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', NULL, NULL, NULL, NULL, '2027-03-01 00:00:00', 1, '2026-05-28 15:47:22');
INSERT INTO `stream_posts` (`id`,`class_id`,`user_id`,`post_type`,`title`,`body`,`attachment_path`,`external_url`,`class_assignment_id`,`scheduled_at`,`published_at`,`comments_enabled`,`created_at`) VALUES (18, 25, 8, 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', NULL, NULL, NULL, NULL, '2027-03-01 00:00:00', 1, '2026-05-28 15:47:22');
INSERT INTO `stream_posts` (`id`,`class_id`,`user_id`,`post_type`,`title`,`body`,`attachment_path`,`external_url`,`class_assignment_id`,`scheduled_at`,`published_at`,`comments_enabled`,`created_at`) VALUES (19, 26, 8, 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', NULL, NULL, NULL, NULL, '2027-03-01 00:00:00', 1, '2026-05-28 15:47:22');
INSERT INTO `stream_posts` (`id`,`class_id`,`user_id`,`post_type`,`title`,`body`,`attachment_path`,`external_url`,`class_assignment_id`,`scheduled_at`,`published_at`,`comments_enabled`,`created_at`) VALUES (20, 27, 8, 'announcement', 'Welcome to the seed class', 'This is a seeded announcement for testing the classroom stream.', NULL, NULL, NULL, NULL, '2027-03-01 00:00:00', 1, '2026-05-28 15:47:22');

-- Table: student_documents
DROP TABLE IF EXISTS `student_documents`;
CREATE TABLE `student_documents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int(10) unsigned NOT NULL,
  `title` varchar(150) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `uploaded_by` int(10) unsigned DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `student_id` (`student_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `student_documents_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `student_documents_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: student_guardians
DROP TABLE IF EXISTS `student_guardians`;
CREATE TABLE `student_guardians` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `student_id` int(10) unsigned NOT NULL,
  `guardian_id` int(10) unsigned NOT NULL,
  `relationship` varchar(50) DEFAULT 'parent',
  `is_primary` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_guardian` (`student_id`,`guardian_id`),
  KEY `guardian_id` (`guardian_id`),
  CONSTRAINT `student_guardians_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE,
  CONSTRAINT `student_guardians_ibfk_2` FOREIGN KEY (`guardian_id`) REFERENCES `guardians` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: students
DROP TABLE IF EXISTS `students`;
CREATE TABLE `students` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned DEFAULT NULL,
  `student_number` varchar(30) NOT NULL,
  `application_id` int(10) unsigned DEFAULT NULL,
  `program_id` int(10) unsigned NOT NULL,
  `intake_id` int(10) unsigned NOT NULL,
  `enrollment_status` enum('active','graduated','withdrawn','suspended','deferred') DEFAULT 'active',
  `enrollment_date` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_number` (`student_number`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `application_id` (`application_id`),
  KEY `program_id` (`program_id`),
  KEY `intake_id` (`intake_id`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `students_ibfk_2` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE SET NULL,
  CONSTRAINT `students_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`),
  CONSTRAINT `students_ibfk_4` FOREIGN KEY (`intake_id`) REFERENCES `intakes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1322 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1, 2, 'MSSHT2643032', 1, 1, 1, 'active', '2026-05-27');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1202, 1212, 'SEED-STU-2026-001', 1210, 1, 1, 'active', '2026-01-16');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1203, 1213, 'SEED-STU-2026-002', 1211, 1, 1, 'active', '2026-01-17');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1204, 1214, 'SEED-STU-2026-003', 1212, 1, 1, 'active', '2026-01-18');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1205, 1215, 'SEED-STU-2026-004', 1213, 1, 1, 'active', '2026-01-19');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1206, 1216, 'SEED-STU-2026-005', 1214, 1, 1, 'active', '2026-01-20');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1207, 1217, 'SEED-STU-2026-006', 1215, 1, 1, 'active', '2026-01-21');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1208, 1218, 'SEED-STU-2026-007', 1216, 1, 1, 'active', '2026-01-22');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1209, 1219, 'SEED-STU-2026-008', 1217, 1, 1, 'active', '2026-01-23');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1210, 1220, 'SEED-STU-2026-009', 1218, 1, 2, 'suspended', '2026-01-24');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1211, 1221, 'SEED-STU-2026-010', 1219, 1, 2, 'active', '2026-01-25');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1212, 1222, 'SEED-STU-2026-011', 1220, 1, 2, 'deferred', '2026-01-26');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1213, 1223, 'SEED-STU-2026-012', 1221, 1, 2, 'active', '2026-01-27');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1214, 1224, 'SEED-STU-2026-013', 1222, 1, 2, 'active', '2026-01-28');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1215, 1225, 'SEED-STU-2026-014', 1223, 1, 2, 'active', '2026-01-29');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1216, 1226, 'SEED-STU-2026-015', 1224, 1, 2, 'active', '2026-01-30');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1217, 1227, 'SEED-STU-2026-016', 1225, 2, 1, 'active', '2026-01-31');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1218, 1228, 'SEED-STU-2026-017', 1226, 2, 1, 'active', '2026-02-01');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1219, 1229, 'SEED-STU-2026-018', 1227, 2, 1, 'suspended', '2026-02-02');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1220, 1230, 'SEED-STU-2026-019', 1228, 2, 1, 'active', '2026-02-03');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1221, 1231, 'SEED-STU-2026-020', 1229, 2, 1, 'active', '2026-02-04');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1222, 1232, 'SEED-STU-2026-021', 1230, 2, 1, 'active', '2026-02-05');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1223, 1233, 'SEED-STU-2026-022', 1231, 2, 1, 'deferred', '2026-02-06');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1224, 1234, 'SEED-STU-2026-023', 1232, 2, 1, 'active', '2026-02-07');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1225, 1235, 'SEED-STU-2026-024', 1233, 2, 2, 'active', '2026-02-08');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1226, 1236, 'SEED-STU-2026-025', 1234, 2, 2, 'active', '2026-02-09');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1227, 1237, 'SEED-STU-2026-026', 1235, 2, 2, 'active', '2026-02-10');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1228, 1238, 'SEED-STU-2026-027', 1236, 2, 2, 'suspended', '2026-02-11');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1229, 1239, 'SEED-STU-2026-028', 1237, 2, 2, 'active', '2026-02-12');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1230, 1240, 'SEED-STU-2026-029', 1238, 2, 2, 'active', '2026-02-13');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1231, 1241, 'SEED-STU-2026-030', 1239, 2, 2, 'active', '2026-02-14');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1232, 1242, 'SEED-STU-2026-031', 1240, 3, 1, 'active', '2026-02-15');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1233, 1243, 'SEED-STU-2026-032', 1241, 3, 1, 'active', '2026-02-16');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1234, 1244, 'SEED-STU-2026-033', 1242, 3, 1, 'deferred', '2026-02-17');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1235, 1245, 'SEED-STU-2026-034', 1243, 3, 1, 'active', '2026-02-18');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1236, 1246, 'SEED-STU-2026-035', 1244, 3, 1, 'active', '2026-02-19');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1237, 1247, 'SEED-STU-2026-036', 1245, 3, 1, 'suspended', '2026-02-20');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1238, 1248, 'SEED-STU-2026-037', 1246, 3, 1, 'active', '2026-02-21');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1239, 1249, 'SEED-STU-2026-038', 1247, 3, 1, 'active', '2026-02-22');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1240, 1250, 'SEED-STU-2026-039', 1248, 3, 2, 'active', '2026-02-23');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1241, 1251, 'SEED-STU-2026-040', 1249, 3, 2, 'active', '2026-02-24');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1242, 1252, 'SEED-STU-2026-041', 1250, 3, 2, 'active', '2026-02-25');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1243, 1253, 'SEED-STU-2026-042', 1251, 3, 2, 'active', '2026-02-26');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1244, 1254, 'SEED-STU-2026-043', 1252, 3, 2, 'active', '2026-02-27');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1245, 1255, 'SEED-STU-2026-044', 1253, 3, 2, 'deferred', '2026-02-28');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1246, 1256, 'SEED-STU-2026-045', 1254, 3, 2, 'suspended', '2026-03-01');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1247, 1257, 'SEED-STU-2026-046', 1255, 4, 1, 'active', '2026-03-02');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1248, 1258, 'SEED-STU-2026-047', 1256, 4, 1, 'active', '2026-03-03');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1249, 1259, 'SEED-STU-2026-048', 1257, 4, 1, 'active', '2026-03-04');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1250, 1260, 'SEED-STU-2026-049', 1258, 4, 1, 'active', '2026-03-05');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1251, 1261, 'SEED-STU-2026-050', 1259, 4, 1, 'active', '2026-03-06');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1252, 1262, 'SEED-STU-2026-051', 1260, 4, 1, 'active', '2026-03-07');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1253, 1263, 'SEED-STU-2026-052', 1261, 4, 1, 'active', '2026-03-08');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1254, 1264, 'SEED-STU-2026-053', 1262, 4, 1, 'active', '2026-03-09');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1255, 1265, 'SEED-STU-2026-054', 1263, 4, 2, 'suspended', '2026-03-10');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1256, 1266, 'SEED-STU-2026-055', 1264, 4, 2, 'deferred', '2026-03-11');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1257, 1267, 'SEED-STU-2026-056', 1265, 4, 2, 'active', '2026-03-12');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1258, 1268, 'SEED-STU-2026-057', 1266, 4, 2, 'active', '2026-03-13');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1259, 1269, 'SEED-STU-2026-058', 1267, 4, 2, 'active', '2026-03-14');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1260, 1270, 'SEED-STU-2026-059', 1268, 4, 2, 'active', '2026-03-15');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1261, 1271, 'SEED-STU-2026-060', 1269, 4, 2, 'active', '2026-03-16');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1262, 1272, 'SEED-STU-2027-061', 1270, 1, 15, 'active', '2027-03-17');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1263, 1273, 'SEED-STU-2027-062', 1271, 1, 15, 'active', '2027-03-18');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1264, 1274, 'SEED-STU-2027-063', 1272, 1, 15, 'suspended', '2027-03-19');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1265, 1275, 'SEED-STU-2027-064', 1273, 1, 15, 'active', '2027-03-20');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1266, 1276, 'SEED-STU-2027-065', 1274, 1, 15, 'active', '2027-03-21');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1267, 1277, 'SEED-STU-2027-066', 1275, 1, 15, 'deferred', '2027-03-22');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1268, 1278, 'SEED-STU-2027-067', 1276, 1, 15, 'active', '2027-03-23');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1269, 1279, 'SEED-STU-2027-068', 1277, 1, 15, 'active', '2027-03-24');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1270, 1280, 'SEED-STU-2027-069', 1278, 1, 16, 'active', '2027-03-25');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1271, 1281, 'SEED-STU-2027-070', 1279, 1, 16, 'active', '2027-03-26');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1272, 1282, 'SEED-STU-2027-071', 1280, 1, 16, 'active', '2027-03-27');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1273, 1283, 'SEED-STU-2027-072', 1281, 1, 16, 'suspended', '2027-03-28');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1274, 1284, 'SEED-STU-2027-073', 1282, 1, 16, 'active', '2027-03-29');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1275, 1285, 'SEED-STU-2027-074', 1283, 1, 16, 'active', '2027-03-30');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1276, 1286, 'SEED-STU-2027-075', 1284, 1, 16, 'active', '2027-03-31');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1277, 1287, 'SEED-STU-2027-076', 1285, 2, 15, 'active', '2027-04-01');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1278, 1288, 'SEED-STU-2027-077', 1286, 2, 15, 'deferred', '2027-04-02');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1279, 1289, 'SEED-STU-2027-078', 1287, 2, 15, 'active', '2027-04-03');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1280, 1290, 'SEED-STU-2027-079', 1288, 2, 15, 'active', '2027-04-04');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1281, 1291, 'SEED-STU-2027-080', 1289, 2, 15, 'active', '2027-01-15');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1282, 1292, 'SEED-STU-2027-081', 1290, 2, 15, 'suspended', '2027-01-16');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1283, 1293, 'SEED-STU-2027-082', 1291, 2, 15, 'active', '2027-01-17');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1284, 1294, 'SEED-STU-2027-083', 1292, 2, 15, 'active', '2027-01-18');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1285, 1295, 'SEED-STU-2027-084', 1293, 2, 16, 'active', '2027-01-19');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1286, 1296, 'SEED-STU-2027-085', 1294, 2, 16, 'active', '2027-01-20');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1287, 1297, 'SEED-STU-2027-086', 1295, 2, 16, 'active', '2027-01-21');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1288, 1298, 'SEED-STU-2027-087', 1296, 2, 16, 'active', '2027-01-22');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1289, 1299, 'SEED-STU-2027-088', 1297, 2, 16, 'deferred', '2027-01-23');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1290, 1300, 'SEED-STU-2027-089', 1298, 2, 16, 'active', '2027-01-24');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1291, 1301, 'SEED-STU-2027-090', 1299, 2, 16, 'suspended', '2027-01-25');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1292, 1302, 'SEED-STU-2027-091', 1300, 3, 15, 'active', '2027-01-26');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1293, 1303, 'SEED-STU-2027-092', 1301, 3, 15, 'active', '2027-01-27');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1294, 1304, 'SEED-STU-2027-093', 1302, 3, 15, 'active', '2027-01-28');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1295, 1305, 'SEED-STU-2027-094', 1303, 3, 15, 'active', '2027-01-29');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1296, 1306, 'SEED-STU-2027-095', 1304, 3, 15, 'active', '2027-01-30');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1297, 1307, 'SEED-STU-2027-096', 1305, 3, 15, 'active', '2027-01-31');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1298, 1308, 'SEED-STU-2027-097', 1306, 3, 15, 'active', '2027-02-01');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1299, 1309, 'SEED-STU-2027-098', 1307, 3, 15, 'active', '2027-02-02');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1300, 1310, 'SEED-STU-2027-099', 1308, 3, 16, 'deferred', '2027-02-03');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1301, 1311, 'SEED-STU-2027-100', 1309, 3, 16, 'active', '2027-02-04');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1302, 1312, 'SEED-STU-2027-101', 1310, 3, 16, 'active', '2027-02-05');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1303, 1313, 'SEED-STU-2027-102', 1311, 3, 16, 'active', '2027-02-06');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1304, 1314, 'SEED-STU-2027-103', 1312, 3, 16, 'active', '2027-02-07');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1305, 1315, 'SEED-STU-2027-104', 1313, 3, 16, 'active', '2027-02-08');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1306, 1316, 'SEED-STU-2027-105', 1314, 3, 16, 'active', '2027-02-09');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1307, 1317, 'SEED-STU-2027-106', 1315, 4, 15, 'active', '2027-02-10');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1308, 1318, 'SEED-STU-2027-107', 1316, 4, 15, 'active', '2027-02-11');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1309, 1319, 'SEED-STU-2027-108', 1317, 4, 15, 'suspended', '2027-02-12');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1310, 1320, 'SEED-STU-2027-109', 1318, 4, 15, 'active', '2027-02-13');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1311, 1321, 'SEED-STU-2027-110', 1319, 4, 15, 'deferred', '2027-02-14');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1312, 1322, 'SEED-STU-2027-111', 1320, 4, 15, 'active', '2027-02-15');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1313, 1323, 'SEED-STU-2027-112', 1321, 4, 15, 'active', '2027-02-16');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1314, 1324, 'SEED-STU-2027-113', 1322, 4, 15, 'active', '2027-02-17');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1315, 1325, 'SEED-STU-2027-114', 1323, 4, 16, 'active', '2027-02-18');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1316, 1326, 'SEED-STU-2027-115', 1324, 4, 16, 'active', '2027-02-19');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1317, 1327, 'SEED-STU-2027-116', 1325, 4, 16, 'active', '2027-02-20');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1318, 1328, 'SEED-STU-2027-117', 1326, 4, 16, 'suspended', '2027-02-21');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1319, 1329, 'SEED-STU-2027-118', 1327, 4, 16, 'active', '2027-02-22');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1320, 1330, 'SEED-STU-2027-119', 1328, 4, 16, 'active', '2027-02-23');
INSERT INTO `students` (`id`,`user_id`,`student_number`,`application_id`,`program_id`,`intake_id`,`enrollment_status`,`enrollment_date`) VALUES (1321, 1331, 'SEED-STU-2027-120', 1329, 4, 16, 'active', '2027-02-24');

-- Table: suppliers
DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE `suppliers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(30) NOT NULL,
  `name` varchar(200) NOT NULL,
  `contact_person` varchar(120) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `tax_number` varchar(50) DEFAULT NULL,
  `bank_name` varchar(100) DEFAULT NULL,
  `bank_account` varchar(80) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `suppliers` (`id`,`code`,`name`,`contact_person`,`email`,`phone`,`tax_number`,`bank_name`,`bank_account`,`is_active`,`created_at`) VALUES (4, 'SEED-SUP-001', 'Seed Office Supplies', 'Seed Contact', 'seed-sup-001@example.com', '+263780000000', 'TAX--001', 'Seed Bank', '000198958', 1, '2026-05-28 15:47:23');
INSERT INTO `suppliers` (`id`,`code`,`name`,`contact_person`,`email`,`phone`,`tax_number`,`bank_name`,`bank_account`,`is_active`,`created_at`) VALUES (5, 'SEED-SUP-002', 'Seed Food Services', 'Seed Contact', 'seed-sup-002@example.com', '+263780000000', 'TAX--002', 'Seed Bank', '000371439', 1, '2026-05-28 15:47:23');
INSERT INTO `suppliers` (`id`,`code`,`name`,`contact_person`,`email`,`phone`,`tax_number`,`bank_name`,`bank_account`,`is_active`,`created_at`) VALUES (6, 'SEED-SUP-003', 'Seed ICT Solutions', 'Seed Contact', 'seed-sup-003@example.com', '+263780000000', 'TAX--003', 'Seed Bank', '000444882', 1, '2026-05-28 15:47:23');

-- Table: timetable_slots
DROP TABLE IF EXISTS `timetable_slots`;
CREATE TABLE `timetable_slots` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module_id` int(10) unsigned NOT NULL,
  `lecturer_id` int(10) unsigned NOT NULL,
  `room_id` int(10) unsigned DEFAULT NULL,
  `day_of_week` tinyint(3) unsigned NOT NULL COMMENT '1=Mon .. 7=Sun',
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `delivery_mode` enum('face_to_face','online','hybrid') DEFAULT 'face_to_face',
  `academic_year` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `module_id` (`module_id`),
  KEY `lecturer_id` (`lecturer_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `timetable_slots_ibfk_1` FOREIGN KEY (`module_id`) REFERENCES `modules` (`id`) ON DELETE CASCADE,
  CONSTRAINT `timetable_slots_ibfk_2` FOREIGN KEY (`lecturer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `timetable_slots_ibfk_3` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: user_module_permissions
DROP TABLE IF EXISTS `user_module_permissions`;
CREATE TABLE `user_module_permissions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `module_name` varchar(80) NOT NULL,
  `access` enum('allow','deny') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_module` (`user_id`,`module_name`),
  CONSTRAINT `user_module_permissions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: user_notifications
DROP TABLE IF EXISTS `user_notifications`;
CREATE TABLE `user_notifications` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `type` varchar(50) NOT NULL,
  `title` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `link_url` varchar(500) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_unread` (`user_id`,`is_read`),
  CONSTRAINT `user_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Table: user_profiles
DROP TABLE IF EXISTS `user_profiles`;
CREATE TABLE `user_profiles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `first_name` varchar(80) NOT NULL,
  `last_name` varchar(80) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `gender` enum('male','female','other') DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `national_id` varchar(50) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `user_profiles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1332 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1, 1, 'System', 'Administrator', '+263000000000', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (2, 2, 'Aubrey', 'Zhuwao', '0774164508', 'male', NULL, '', '', NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (3, 3, 'Test', 'Applicant', '0777000000', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (4, 4, 'Charisma', 'Charisma', '', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (5, 5, 'Robert', 'Tungwarara', '', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (6, 6, 'Seed', 'Registrar', '+263770000000', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (7, 7, 'Seed', 'Finance', '+263770000000', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (8, 8, 'Seed', 'Lecturer', '+263770000000', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (9, 9, 'Seed', 'Trainer', '+263770000000', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (10, 10, 'Seed', 'Facilitator', '+263770000000', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (11, 11, 'Seed', 'Advisor', '+263770000000', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1212, 1212, 'Blessing', 'Chirwa', '0777000001', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1213, 1213, 'Chenai', 'Dube', '0777000002', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1214, 1214, 'Derrick', 'Furusa', '0777000003', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1215, 1215, 'Elina', 'Gumbo', '0777000004', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1216, 1216, 'Farai', 'Hove', '0777000005', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1217, 1217, 'Godfrey', 'Jele', '0777000006', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1218, 1218, 'Hilda', 'Kachidza', '0777000007', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1219, 1219, 'Ivy', 'Moyo', '0777000008', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1220, 1220, 'Jared', 'Ncube', '0777000009', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1221, 1221, 'Kudzai', 'Nyasha', '0777000010', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1222, 1222, 'Lerato', 'Phiri', '0777000011', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1223, 1223, 'Moses', 'Sibanda', '0777000012', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1224, 1224, 'Nadia', 'Tafara', '0777000013', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1225, 1225, 'Obert', 'Vengesai', '0777000014', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1226, 1226, 'Precious', 'Zhou', '0777000015', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1227, 1227, 'Tariro', 'Banda', '0777000016', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1228, 1228, 'Unity', 'Chirwa', '0777000017', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1229, 1229, 'Vimbai', 'Dube', '0777000018', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1230, 1230, 'Wellington', 'Furusa', '0777000019', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1231, 1231, 'Amina', 'Gumbo', '0777000020', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1232, 1232, 'Blessing', 'Hove', '0777000021', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1233, 1233, 'Chenai', 'Jele', '0777000022', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1234, 1234, 'Derrick', 'Kachidza', '0777000023', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1235, 1235, 'Elina', 'Moyo', '0777000024', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1236, 1236, 'Farai', 'Ncube', '0777000025', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1237, 1237, 'Godfrey', 'Nyasha', '0777000026', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1238, 1238, 'Hilda', 'Phiri', '0777000027', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1239, 1239, 'Ivy', 'Sibanda', '0777000028', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1240, 1240, 'Jared', 'Tafara', '0777000029', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1241, 1241, 'Kudzai', 'Vengesai', '0777000030', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1242, 1242, 'Lerato', 'Zhou', '0777000031', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1243, 1243, 'Moses', 'Banda', '0777000032', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1244, 1244, 'Nadia', 'Chirwa', '0777000033', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1245, 1245, 'Obert', 'Dube', '0777000034', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1246, 1246, 'Precious', 'Furusa', '0777000035', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1247, 1247, 'Tariro', 'Gumbo', '0777000036', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1248, 1248, 'Unity', 'Hove', '0777000037', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1249, 1249, 'Vimbai', 'Jele', '0777000038', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1250, 1250, 'Wellington', 'Kachidza', '0777000039', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1251, 1251, 'Amina', 'Moyo', '0777000040', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1252, 1252, 'Blessing', 'Ncube', '0777000041', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1253, 1253, 'Chenai', 'Nyasha', '0777000042', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1254, 1254, 'Derrick', 'Phiri', '0777000043', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1255, 1255, 'Elina', 'Sibanda', '0777000044', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1256, 1256, 'Farai', 'Tafara', '0777000045', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1257, 1257, 'Godfrey', 'Vengesai', '0777000046', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1258, 1258, 'Hilda', 'Zhou', '0777000047', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1259, 1259, 'Ivy', 'Banda', '0777000048', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1260, 1260, 'Jared', 'Chirwa', '0777000049', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1261, 1261, 'Kudzai', 'Dube', '0777000050', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1262, 1262, 'Lerato', 'Furusa', '0777000051', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1263, 1263, 'Moses', 'Gumbo', '0777000052', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1264, 1264, 'Nadia', 'Hove', '0777000053', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1265, 1265, 'Obert', 'Jele', '0777000054', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1266, 1266, 'Precious', 'Kachidza', '0777000055', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1267, 1267, 'Tariro', 'Moyo', '0777000056', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1268, 1268, 'Unity', 'Ncube', '0777000057', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1269, 1269, 'Vimbai', 'Nyasha', '0777000058', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1270, 1270, 'Wellington', 'Phiri', '0777000059', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1271, 1271, 'Amina', 'Sibanda', '0777000060', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1272, 1272, 'Blessing', 'Tafara', '0777000061', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1273, 1273, 'Chenai', 'Vengesai', '0777000062', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1274, 1274, 'Derrick', 'Zhou', '0777000063', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1275, 1275, 'Elina', 'Banda', '0777000064', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1276, 1276, 'Farai', 'Chirwa', '0777000065', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1277, 1277, 'Godfrey', 'Dube', '0777000066', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1278, 1278, 'Hilda', 'Furusa', '0777000067', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1279, 1279, 'Ivy', 'Gumbo', '0777000068', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1280, 1280, 'Jared', 'Hove', '0777000069', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1281, 1281, 'Kudzai', 'Jele', '0777000070', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1282, 1282, 'Lerato', 'Kachidza', '0777000071', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1283, 1283, 'Moses', 'Moyo', '0777000072', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1284, 1284, 'Nadia', 'Ncube', '0777000073', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1285, 1285, 'Obert', 'Nyasha', '0777000074', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1286, 1286, 'Precious', 'Phiri', '0777000075', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1287, 1287, 'Tariro', 'Sibanda', '0777000076', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1288, 1288, 'Unity', 'Tafara', '0777000077', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1289, 1289, 'Vimbai', 'Vengesai', '0777000078', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1290, 1290, 'Wellington', 'Zhou', '0777000079', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1291, 1291, 'Amina', 'Banda', '0777000080', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1292, 1292, 'Blessing', 'Chirwa', '0777000081', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1293, 1293, 'Chenai', 'Dube', '0777000082', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1294, 1294, 'Derrick', 'Furusa', '0777000083', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1295, 1295, 'Elina', 'Gumbo', '0777000084', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1296, 1296, 'Farai', 'Hove', '0777000085', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1297, 1297, 'Godfrey', 'Jele', '0777000086', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1298, 1298, 'Hilda', 'Kachidza', '0777000087', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1299, 1299, 'Ivy', 'Moyo', '0777000088', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1300, 1300, 'Jared', 'Ncube', '0777000089', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1301, 1301, 'Kudzai', 'Nyasha', '0777000090', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1302, 1302, 'Lerato', 'Phiri', '0777000091', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1303, 1303, 'Moses', 'Sibanda', '0777000092', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1304, 1304, 'Nadia', 'Tafara', '0777000093', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1305, 1305, 'Obert', 'Vengesai', '0777000094', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1306, 1306, 'Precious', 'Zhou', '0777000095', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1307, 1307, 'Tariro', 'Banda', '0777000096', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1308, 1308, 'Unity', 'Chirwa', '0777000097', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1309, 1309, 'Vimbai', 'Dube', '0777000098', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1310, 1310, 'Wellington', 'Furusa', '0777000099', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1311, 1311, 'Amina', 'Gumbo', '0777000100', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1312, 1312, 'Blessing', 'Hove', '0777000101', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1313, 1313, 'Chenai', 'Jele', '0777000102', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1314, 1314, 'Derrick', 'Kachidza', '0777000103', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1315, 1315, 'Elina', 'Moyo', '0777000104', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1316, 1316, 'Farai', 'Ncube', '0777000105', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1317, 1317, 'Godfrey', 'Nyasha', '0777000106', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1318, 1318, 'Hilda', 'Phiri', '0777000107', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1319, 1319, 'Ivy', 'Sibanda', '0777000108', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1320, 1320, 'Jared', 'Tafara', '0777000109', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1321, 1321, 'Kudzai', 'Vengesai', '0777000110', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1322, 1322, 'Lerato', 'Zhou', '0777000111', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1323, 1323, 'Moses', 'Banda', '0777000112', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1324, 1324, 'Nadia', 'Chirwa', '0777000113', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1325, 1325, 'Obert', 'Dube', '0777000114', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1326, 1326, 'Precious', 'Furusa', '0777000115', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1327, 1327, 'Tariro', 'Gumbo', '0777000116', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1328, 1328, 'Unity', 'Hove', '0777000117', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1329, 1329, 'Vimbai', 'Jele', '0777000118', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1330, 1330, 'Wellington', 'Kachidza', '0777000119', NULL, NULL, NULL, NULL, NULL);
INSERT INTO `user_profiles` (`id`,`user_id`,`first_name`,`last_name`,`phone`,`gender`,`date_of_birth`,`national_id`,`address`,`avatar`) VALUES (1331, 1331, 'Amina', 'Moyo', '0777000120', NULL, NULL, NULL, NULL, NULL);

-- Table: users
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('super_admin','registrar','finance','lecturer','student','hod','librarian','external_examiner') NOT NULL,
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `must_change_password` tinyint(1) NOT NULL DEFAULT 0,
  `last_login` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=1332 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1, 'admin@mssht.ac.zw', '$2y$10$evJtjIdvtv9sBnWqcfx9xuTunp38PE3AwNDyNiVHY/LcsbBpd9kdK', 'super_admin', 'active', 0, '2026-05-27 16:20:39', '2026-05-21 09:22:06', '2026-05-27 16:20:39');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (2, 'amzhuwao@gmail.com', '$2y$10$gkoG6DWtELUzjrB46oQ7Pe8wtCjpYYJ5XqkIK1ATTyZQdwhtcGI0.', 'super_admin', 'active', 0, '2026-05-29 08:42:46', '2026-05-27 13:17:21', '2026-05-29 08:42:46');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (3, 'test.applicant@example.com', '$2y$10$.ds4Vw2IpUGvbc56d7yAk.9k60x2fMtYO0g0XE3BQdMXErKJLtkPa', 'student', 'active', 1, NULL, '2026-05-27 13:27:10', '2026-05-27 13:27:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (4, 'reception@mssht.ac.zw', '$2y$10$32.I9W8wLOQdk5Z.Ofgtu.PTVJcooXks1rJQacka/x/F4KjTpbBgy', 'registrar', 'active', 1, '2026-05-28 10:27:12', '2026-05-27 14:07:22', '2026-05-28 10:27:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (5, 'mssht@manicaskyview.co.zw', '$2y$10$1zYfQBCm5VeEC/UKXvik1OVz9WgP4E7gvGNEnh02ZWvaekcklGLyW', 'registrar', 'active', 1, NULL, '2026-05-27 16:31:25', '2026-05-27 16:31:25');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (6, 'seed.registrar@seed-staff.mssht.test', '$2y$10$eWxi/D1g1p9FIJ2coi8O/uiGmNNTLFjWrvNbRFBP2jjSYYgvEKxKK', 'registrar', 'active', 1, NULL, '2026-05-28 13:53:46', '2026-05-28 13:53:46');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (7, 'seed.finance@seed-staff.mssht.test', '$2y$10$noeadtcr7suP5MmPhkOkcux6cugLGzhslzwpdiiWaEtNTUWR5Cksq', 'finance', 'active', 1, NULL, '2026-05-28 13:58:56', '2026-05-28 13:58:56');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (8, 'seed.lecturer1@seed-staff.mssht.test', '$2y$10$D6T3qA7DN/EYKRaJXer6A.ljHWLtolsb6Gsomw67zmuKotklVl.Si', 'lecturer', 'active', 1, NULL, '2026-05-28 13:58:56', '2026-05-28 13:58:56');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (9, 'seed.lecturer2@seed-staff.mssht.test', '$2y$10$SvXqEZ9gqb9pKIEyarXJ8.JDtleXa6KtbtIMTvYf4aSfi234ygZ96', 'lecturer', 'active', 1, NULL, '2026-05-28 13:58:56', '2026-05-28 13:58:56');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (10, 'seed.lecturer3@seed-staff.mssht.test', '$2y$10$6qu7KmPy./SnTRe7rnWj/Op3BhdE2qN8QZcF3zaogVjVzg7bGNfKq', 'lecturer', 'active', 1, NULL, '2026-05-28 13:58:56', '2026-05-28 13:58:56');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (11, 'seed.lecturer4@seed-staff.mssht.test', '$2y$10$/z/75Nm5.RRgZP7NfyzaMODb865QbkfuS7AzoRQj/T7MiEy5ZjTr.', 'lecturer', 'active', 1, NULL, '2026-05-28 13:58:56', '2026-05-28 13:58:56');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1212, 'student.blessing.chirwa.001@seed.mssht.test', '$2y$10$Ig4xnqxpWLfGVRw3dMwqz.yckcXR4aq7Pd4NivEpanWodUcqiISSG', 'student', 'active', 1, NULL, '2026-05-28 15:47:08', '2026-05-28 15:47:08');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1213, 'student.chenai.dube.002@seed.mssht.test', '$2y$10$02TPEoQ/yMyBlBklUpFl9.d2GhsGtb0H6UrTS1L./BpH6gDp2tjOa', 'student', 'active', 1, NULL, '2026-05-28 15:47:09', '2026-05-28 15:47:09');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1214, 'student.derrick.furusa.003@seed.mssht.test', '$2y$10$FOqAa8w9uw8iWHpeiO0/pO8mws6gg7rQKamaZIpZtBkPAqD6OGvc6', 'student', 'active', 1, NULL, '2026-05-28 15:47:09', '2026-05-28 15:47:09');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1215, 'student.elina.gumbo.004@seed.mssht.test', '$2y$10$oyQYERVh/Wh37sCfRBelGuTp5V6pgHBINjCJno6sW33eks18FYL7u', 'student', 'active', 1, NULL, '2026-05-28 15:47:09', '2026-05-28 15:47:09');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1216, 'student.farai.hove.005@seed.mssht.test', '$2y$10$KJmrc.gOu13qlyFYLmaSLe8TeV9W9nvG1/p/8RA7K6qWs6SPrPpRK', 'student', 'active', 1, NULL, '2026-05-28 15:47:09', '2026-05-28 15:47:09');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1217, 'student.godfrey.jele.006@seed.mssht.test', '$2y$10$jUN0qEaJ2y7HM/DDGoMpXOLlg/bKNW9.FWnPddRaMBTWEW6mywnZi', 'student', 'active', 1, NULL, '2026-05-28 15:47:09', '2026-05-28 15:47:09');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1218, 'student.hilda.kachidza.007@seed.mssht.test', '$2y$10$v6qVwAlmZgfx7Z1apuYw3epSdaZRHfLFeqyr8w89Te0aqJiA91JOm', 'student', 'active', 1, NULL, '2026-05-28 15:47:09', '2026-05-28 15:47:09');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1219, 'student.ivy.moyo.008@seed.mssht.test', '$2y$10$wixAamCDyjX0lZ/Mkn/Agu0hYe2EgE9hMofVbW00hhtf/bbu9Mp1m', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1220, 'student.jared.ncube.009@seed.mssht.test', '$2y$10$UuP.9k.W601AmdNdnvXsUuupyYGWMrfMlfziYqAg0s1objDT3Naci', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1221, 'student.kudzai.nyasha.010@seed.mssht.test', '$2y$10$oXISDr/xfWbIhWpQpZthzOMNc9UVXHkPmXKziNQTF0ggFzearzfBa', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1222, 'student.lerato.phiri.011@seed.mssht.test', '$2y$10$Po3b1.XZt4zJF83oo27dSOx/hapAEDnWwnvi/5jy5.Xan2xBjmApi', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1223, 'student.moses.sibanda.012@seed.mssht.test', '$2y$10$OxI4r3pLICwiTSRdu30iTula4iEGm1AyU13MLna3C15DlSVAvoOZu', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1224, 'student.nadia.tafara.013@seed.mssht.test', '$2y$10$eydqlRhgCeAfW5w8y5tnWeKSC6H9g0m8ULc9MOG.MrStkNc4i1QnS', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1225, 'student.obert.vengesai.014@seed.mssht.test', '$2y$10$OVAghZnfbL2qy7DVtSai7.AtcxxfXR.30ikGZa9K5sviY5DZw/RGK', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1226, 'student.precious.zhou.015@seed.mssht.test', '$2y$10$nqOL.i6D6VcMhYZp6i2HW.HLf9AGExuW2yxH8FJcmuY/zOHQPVzRS', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1227, 'student.tariro.banda.016@seed.mssht.test', '$2y$10$USVzH7fZW6WvfM./M6C8pOke7sWUuaq8jmd08xUr1Y/LlnN94zdjC', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1228, 'student.unity.chirwa.017@seed.mssht.test', '$2y$10$1LznY2IXVK9VPNnqUZenV.zMfiCyC6DUOFksHRAm4sgxaG4Qkxiru', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1229, 'student.vimbai.dube.018@seed.mssht.test', '$2y$10$aXcNuOigKcb6a18nhg0kGO4UMTvhsSDWApud/ntEslyiS281oQzMG', 'student', 'active', 1, NULL, '2026-05-28 15:47:10', '2026-05-28 15:47:10');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1230, 'student.wellington.furusa.019@seed.mssht.test', '$2y$10$VcOB88nTsS8qIrZJ66lWJ.2rpxO80B5bGkxIz59SfubcmxniAUGjO', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1231, 'student.amina.gumbo.020@seed.mssht.test', '$2y$10$WneaYI2znjeKfvj2z0yx5.2TrR8Vti0GPADBaue3wqw5fNTBc014y', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1232, 'student.blessing.hove.021@seed.mssht.test', '$2y$10$wW.quuMJGl5E.4u5G1j0LO/bse.3CMMfRdn.Tite083dr5FLeFMiS', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1233, 'student.chenai.jele.022@seed.mssht.test', '$2y$10$.ediJjg4snPjn8Cxv6SOWurAhIS.OrXuB4Ar1GbUGIkpewLX5OEGS', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1234, 'student.derrick.kachidza.023@seed.mssht.test', '$2y$10$g0nRYD7DHw9.tainiuISwec2RduAkBkpHoKlU6mAOUNT.tAK3Ch.i', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1235, 'student.elina.moyo.024@seed.mssht.test', '$2y$10$UOAyNAXh/Z7uyXEiOTztROy0M8f6LQ0ms1qtHq1FUsocWG96CVL5m', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1236, 'student.farai.ncube.025@seed.mssht.test', '$2y$10$a0PKU1ethOBF4TEJSD1iEOJKJnBDpnKFiqg7a0J4MzXYSv2M/q1/i', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1237, 'student.godfrey.nyasha.026@seed.mssht.test', '$2y$10$q.T/ueqgFchLzFNEOOXoD.ZNUVcK560bfOTiE1jefs6rTxhWAYJP.', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1238, 'student.hilda.phiri.027@seed.mssht.test', '$2y$10$3CM9DR8F5L8ZbwGzjUQ7hudK.c1h0D.xRQffDJnNLWS3p3VOhnzcu', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1239, 'student.ivy.sibanda.028@seed.mssht.test', '$2y$10$IFldPswbNZtik.H5V7ID4.sGP9pPAQNvjNAHGat7raGCL2rbnD3Ie', 'student', 'active', 1, NULL, '2026-05-28 15:47:11', '2026-05-28 15:47:11');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1240, 'student.jared.tafara.029@seed.mssht.test', '$2y$10$MaoRgYzMuMQBCKmnNyrPJei/iCWIOO6pof1tcd87T1bvlQ5bNc9mm', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1241, 'student.kudzai.vengesai.030@seed.mssht.test', '$2y$10$4/xbnehar50SPXa84WzVmup9GHDYWNCh5bGXc8PHka.4aeG6oHNmO', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1242, 'student.lerato.zhou.031@seed.mssht.test', '$2y$10$cJxqy94fZZWYvr7Vb7O.nOSfU/T8CUGZfgh7VZDfIpim5VwapjqU2', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1243, 'student.moses.banda.032@seed.mssht.test', '$2y$10$zFV212x4IjqSu6OL8VAHtOyBq0YZf.YTOjedUrJv4lK2yf4iARlX6', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1244, 'student.nadia.chirwa.033@seed.mssht.test', '$2y$10$as0FKGOqgyaF3ZBZJNPCtOkD1QADEAsAkgU5VgPTzHEfiDg0pj7QO', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1245, 'student.obert.dube.034@seed.mssht.test', '$2y$10$RNzWapUFXh.qq2wAJ5otJOoAKe08HPphyz7xKXwWraHzbCOZX2E4e', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1246, 'student.precious.furusa.035@seed.mssht.test', '$2y$10$inIWshgel.X4adErcrHN..5H2TqVRTHyIxgw8igOq48.N/gu.nYd2', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1247, 'student.tariro.gumbo.036@seed.mssht.test', '$2y$10$KG5rWzaq83UBuTeRTPFrw.M3ELoTXDkvtTfKJlZc4rdyNY7EPskqq', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1248, 'student.unity.hove.037@seed.mssht.test', '$2y$10$8YEYmjrYCvS.ELw92RpcPutjTrn3sBKEEvKd8OkZAUzPBtdgN1oFG', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1249, 'student.vimbai.jele.038@seed.mssht.test', '$2y$10$aktBRuQeFxm8iAt8VroKiulDmUZf5RSjO5s5w4TXor7Bb.e4lFDWK', 'student', 'active', 1, NULL, '2026-05-28 15:47:12', '2026-05-28 15:47:12');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1250, 'student.wellington.kachidza.039@seed.mssht.test', '$2y$10$Zf9uaExYwviBaHG3hZvj0ObPcXDP9F3tEH5RSI1fYd68Gf4HTA/Le', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1251, 'student.amina.moyo.040@seed.mssht.test', '$2y$10$HC/5TD6tpOqz1wQ3HUGKmOseP7Zpjtz5jR7Hnjn4bhwCn9oUtrWIK', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1252, 'student.blessing.ncube.041@seed.mssht.test', '$2y$10$EjAlmsiXayLWhZzdfTomqeVgP42qjtcZvILHKf04CN7FfQK5vm.Pq', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1253, 'student.chenai.nyasha.042@seed.mssht.test', '$2y$10$/XULJ/LBLs72jqvfpmA5g.BRzaC//4DerwhiAY8K0YtN2NjztS6Ra', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1254, 'student.derrick.phiri.043@seed.mssht.test', '$2y$10$KqfSjXzOHmlzEPJa7.1pGOShEF.fknA4/bY2.8NNZXZIRzZqj2wya', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1255, 'student.elina.sibanda.044@seed.mssht.test', '$2y$10$0pKIUkpoJr4yGrbzbzFwuuolxSsfMU5JkyDJkNQKQAQBuniWX69Om', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1256, 'student.farai.tafara.045@seed.mssht.test', '$2y$10$Yzulax34Tai6xHlnzUG9hOrRRMoakqwkp5/kEKSgXatPa/zmak92G', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1257, 'student.godfrey.vengesai.046@seed.mssht.test', '$2y$10$iryoZ1W8oLTJipBtAWO7uOhSW21oiPQB6ZjkR2U.2U5RV8RZKhpHC', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1258, 'student.hilda.zhou.047@seed.mssht.test', '$2y$10$md70jVVquFgCT/nD21U4Z.sw9MbjDygDJdvuTQMzc7pGYFyV/ujTO', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1259, 'student.ivy.banda.048@seed.mssht.test', '$2y$10$IvJGFcWACueGnBIGCXZWqud0oz.pc//2H/17o8EPJ6rIVDQFgj.fW', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1260, 'student.jared.chirwa.049@seed.mssht.test', '$2y$10$D94jqLWExZIVLHCREAlrcu1Z1Sy.XtVuLqk8Ln13AbLBafbXPwxlu', 'student', 'active', 1, NULL, '2026-05-28 15:47:13', '2026-05-28 15:47:13');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1261, 'student.kudzai.dube.050@seed.mssht.test', '$2y$10$w4uuxktPH4mV3EE4gM8PnOYEMyM1436j9WlR3mavL5e8bNSP2tDGi', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1262, 'student.lerato.furusa.051@seed.mssht.test', '$2y$10$mVl5MkJ5DCx3LpneUoQq8uWW/QkWAULvQbKWBoNqGZ8Q4XaxQkcje', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1263, 'student.moses.gumbo.052@seed.mssht.test', '$2y$10$Tzb0rcECiGZiafswGScaCeXYyqPHrhg6tIjj4kDxC6iWxjp0nAlL6', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1264, 'student.nadia.hove.053@seed.mssht.test', '$2y$10$.kwTB.JouwvJCv30F9aS4.3qaKkI/mCvRt7zFCTQi9dwmTj1g.ZFq', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1265, 'student.obert.jele.054@seed.mssht.test', '$2y$10$JS8EQFgC9i6TiKW2zY6TrODGut9.C2twMWSPiQ.CnxTv3NWeUKAZu', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1266, 'student.precious.kachidza.055@seed.mssht.test', '$2y$10$Y3z6H8FwTEHdNT3xxPHr4eaVjTTAdjVWDeNShJgNFHPdo.DQpjvU.', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1267, 'student.tariro.moyo.056@seed.mssht.test', '$2y$10$WxUTd3aiiiPSUJNZzx4SWObLBa4gj1LdSQLwcdSlGNggzmfm2qaNe', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1268, 'student.unity.ncube.057@seed.mssht.test', '$2y$10$XpPemql5Fqlu6CGK.R3WJe4YcEfDG59bMSXfZ7S0fmPC8tZQodOoG', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1269, 'student.vimbai.nyasha.058@seed.mssht.test', '$2y$10$F2c.GbxwUTHerum5Q90pHeiS6tuEBJ1ThOkGv40TnuE.LqQrLIVmW', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1270, 'student.wellington.phiri.059@seed.mssht.test', '$2y$10$zxve6qeaszWzfheyZUEnl.JYmV1JeZBeLYm21mGbD9P8b18xSLsnu', 'student', 'active', 1, NULL, '2026-05-28 15:47:14', '2026-05-28 15:47:14');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1271, 'student.amina.sibanda.060@seed.mssht.test', '$2y$10$SVes3dvhqwk8pc4ycd/OMO1AhfpPB/G2tcYFOSomauSN4.yKQ3p3S', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1272, 'student.blessing.tafara.061@seed.mssht.test', '$2y$10$5VtxrSv7/Lof0mYfMDIsFOuNjxfZ8rNRkgFY3rUZ4m/yrdZEXtqeu', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1273, 'student.chenai.vengesai.062@seed.mssht.test', '$2y$10$EwrG3wgD4FHy6zBmpkSJ8eXFg1YUeMEm4HYZeeQ7g1UmdROfutHcq', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1274, 'student.derrick.zhou.063@seed.mssht.test', '$2y$10$uOPk8W4ca.HDgG8.5DxP.eDP0.pVW0cpKJ/pPLs4fPsJqtaRRiAF.', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1275, 'student.elina.banda.064@seed.mssht.test', '$2y$10$gWCsT558bnsGgVkAZprwFulhJbH8Y54Ue0KKS9BVMuGkTygW2qDwG', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1276, 'student.farai.chirwa.065@seed.mssht.test', '$2y$10$W9rChzmcoMf4DvVYaDR9BOJ2x2XTnQiuHFSvcoio4acm/vw3xI3sS', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1277, 'student.godfrey.dube.066@seed.mssht.test', '$2y$10$m.Ag08maYgC9kxuJ4EVGv.sd6d3s1eR1cBU9vRB3H05ZVFa0VmI5u', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1278, 'student.hilda.furusa.067@seed.mssht.test', '$2y$10$Q.XKdhpj3Sf1Pj0JsJ6WGeo0qt9zOpAub5XcMPQDVtoUpFWJbtz1O', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1279, 'student.ivy.gumbo.068@seed.mssht.test', '$2y$10$Xlfd1AdoEic4zlCuJbFfWOKpptkcv6WRoTckdXRm4X2HoybIVBdwS', 'student', 'active', 1, NULL, '2026-05-28 15:47:15', '2026-05-28 15:47:15');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1280, 'student.jared.hove.069@seed.mssht.test', '$2y$10$bpuJjbahINWfqbg58hKwOejTa.K3.44kOsV4NHa7PFfLwf.4wokRW', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1281, 'student.kudzai.jele.070@seed.mssht.test', '$2y$10$pPZJrFLKPQ8PmW8a1yy0Yu9undzk5LWGaNb/tKH3q6eUFeQ7uNhp6', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1282, 'student.lerato.kachidza.071@seed.mssht.test', '$2y$10$PVHDT21WBFJMdbDFjDMVVOOLoZaGPjUYKK2KtQQMGWNu4LfEgv0hO', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1283, 'student.moses.moyo.072@seed.mssht.test', '$2y$10$fZV0FrzWsomjUTiMOEloKeZg3yRENCpngWcLHv7Ra2kWHZbd4n.6C', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1284, 'student.nadia.ncube.073@seed.mssht.test', '$2y$10$ndUiqdsMFKy4dpqzdKA8tOuq3ruPcHeblvy67.wZU/Q39ePgpgS/W', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1285, 'student.obert.nyasha.074@seed.mssht.test', '$2y$10$yA/8muFvE3jLttd6rU8e1.UOb2Y8RJky/.AeB4cUkXvgB/l7wUOju', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1286, 'student.precious.phiri.075@seed.mssht.test', '$2y$10$or4LsqO.Z09EfMsOxnanKuV5DyUbfIKp6qQTPmRe9ulNQ8aDD6o1e', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1287, 'student.tariro.sibanda.076@seed.mssht.test', '$2y$10$s8JdJeK6SH5YnA2vmGQUcuduS43JnkwYbBZhe5UAgKBTliHVd3p5C', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1288, 'student.unity.tafara.077@seed.mssht.test', '$2y$10$wupK5yqx4r17us0c1nYseO7kl.9bz1UPcrDByzjxNtri4TT/FCleW', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1289, 'student.vimbai.vengesai.078@seed.mssht.test', '$2y$10$dw/v/OkfXevSQHqD29ZKSu.1KSP7eP/idutbWxKOrE7Jm88rhkm0.', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1290, 'student.wellington.zhou.079@seed.mssht.test', '$2y$10$VQbXP54pNjxxfJ7kCYGRte16sm9TlSijubwZDjwBX4d6XrJTL55KC', 'student', 'active', 1, NULL, '2026-05-28 15:47:16', '2026-05-28 15:47:16');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1291, 'student.amina.banda.080@seed.mssht.test', '$2y$10$JsB86TBwgBVXjScZHSiZhuPSJUDY3eb7z2BdbARd3aX7Xr8.lXfre', 'student', 'active', 1, NULL, '2026-05-28 15:47:17', '2026-05-28 15:47:17');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1292, 'student.blessing.chirwa.081@seed.mssht.test', '$2y$10$F57Wa2KTq1/SSXSzFqxtMuiDZbPJVOCBEjyvIhm2aAaXa0wP4l.LS', 'student', 'active', 1, NULL, '2026-05-28 15:47:17', '2026-05-28 15:47:17');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1293, 'student.chenai.dube.082@seed.mssht.test', '$2y$10$U1ysvviM.FBkBQROBmaJpOG7ERjQ8qjZ.5uzfXtRhoZ.t8AlbNj96', 'student', 'active', 1, NULL, '2026-05-28 15:47:17', '2026-05-28 15:47:17');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1294, 'student.derrick.furusa.083@seed.mssht.test', '$2y$10$a2a7GGpfDJqo3KBRqjZqEO61wun9NqHZeGJIhUVKJle1oG9UcuW/y', 'student', 'active', 1, NULL, '2026-05-28 15:47:17', '2026-05-28 15:47:17');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1295, 'student.elina.gumbo.084@seed.mssht.test', '$2y$10$gG71ryYLKiZmaq3VUDArwe10bWB./wFuSlB4qaTo9Z7USuijWogei', 'student', 'active', 1, NULL, '2026-05-28 15:47:17', '2026-05-28 15:47:17');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1296, 'student.farai.hove.085@seed.mssht.test', '$2y$10$P2zaT71IYFoeBv1/q958OeUvce4/MftldbZhxIL6yB7p1eJU9E.0G', 'student', 'active', 1, NULL, '2026-05-28 15:47:17', '2026-05-28 15:47:17');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1297, 'student.godfrey.jele.086@seed.mssht.test', '$2y$10$88DZZAkqAaoooIguTgCt5.XpEec1aD3Qy37g9rsRHEWoBp2Ocdp2a', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1298, 'student.hilda.kachidza.087@seed.mssht.test', '$2y$10$JZNzN.yjswDPQZCvr0CJ1uPf/rfm6XTmQRqLeShNlf2SimK9FdgRq', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1299, 'student.ivy.moyo.088@seed.mssht.test', '$2y$10$OZp95iF8C8GL7z1jADYX9emDo8CkfE.qJyCenxolHS8QERxzzts8W', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1300, 'student.jared.ncube.089@seed.mssht.test', '$2y$10$IrC1iUID5JGKesqklXex3OVo7kDzqVqRXEZbTabwKDJWesgNZjzca', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1301, 'student.kudzai.nyasha.090@seed.mssht.test', '$2y$10$Zytv/pF2kmpeOb2uing56.zUasnPUSos7UHnnl5NuioI4Fu1fmJUS', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1302, 'student.lerato.phiri.091@seed.mssht.test', '$2y$10$.l3B74W.zBBp.0S6p.xvY.G.MCe9z2K2Wvh63KN3dBLf0tPem.na.', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1303, 'student.moses.sibanda.092@seed.mssht.test', '$2y$10$HMC.aV9KYfc8Tm3lClCoG.zpBB4/6LlbdIrmGvwklusqNnTi/i5mu', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1304, 'student.nadia.tafara.093@seed.mssht.test', '$2y$10$tDNHN8N8OQK.KO8vBkzOSeIV2pB33CqLuPNkOm01HV0R0csKD2vBW', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1305, 'student.obert.vengesai.094@seed.mssht.test', '$2y$10$fJU2OhKXuCsXaDuSz3bJ..XmDcbsM.S9vdWEXy06/uYgNQLQInR7O', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1306, 'student.precious.zhou.095@seed.mssht.test', '$2y$10$gMOiI3VgdvriqM6yVIVdw.4mtnDzOu8V6v0IT/1gYJ8aEcZG5BJBa', 'student', 'active', 1, NULL, '2026-05-28 15:47:18', '2026-05-28 15:47:18');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1307, 'student.tariro.banda.096@seed.mssht.test', '$2y$10$WPYaiscbzNdR6Xg/pakuKuDnqa6KRVzjYEE1Jd0A5CN0/zIB4x9.6', 'student', 'active', 1, NULL, '2026-05-28 15:47:19', '2026-05-28 15:47:19');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1308, 'student.unity.chirwa.097@seed.mssht.test', '$2y$10$DjgpVDbN4VOPuKB9C7EMGeOqbjviVYF2RB.Zt5r9Nf8UucA2I5Quu', 'student', 'active', 1, NULL, '2026-05-28 15:47:19', '2026-05-28 15:47:19');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1309, 'student.vimbai.dube.098@seed.mssht.test', '$2y$10$zEG9YWC5tztmSCXD8Cm3h.OooXhDbHkL47SMi5wdmH6RZFl7P7yty', 'student', 'active', 1, NULL, '2026-05-28 15:47:19', '2026-05-28 15:47:19');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1310, 'student.wellington.furusa.099@seed.mssht.test', '$2y$10$RFMoMqOxXjYxuXk41yge4uDNmUSrN2cNW28KmbFaltLZm94LtTuG6', 'student', 'active', 1, NULL, '2026-05-28 15:47:19', '2026-05-28 15:47:19');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1311, 'student.amina.gumbo.100@seed.mssht.test', '$2y$10$iQpjLN1CoTPAcpH9px0FpO6hduxcx0E1cznHbXhtLUNXPzHtYjVoS', 'student', 'active', 1, NULL, '2026-05-28 15:47:19', '2026-05-28 15:47:19');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1312, 'student.blessing.hove.101@seed.mssht.test', '$2y$10$gsEwlxNzEFRwGfgw2.JLZ.7sCxns3c72pjjsFKxO6bIl/pCc5T52O', 'student', 'active', 1, NULL, '2026-05-28 15:47:19', '2026-05-28 15:47:19');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1313, 'student.chenai.jele.102@seed.mssht.test', '$2y$10$qXJS.yFxGaQ0cJ8H18K70el9OShiefV3lfeBim3ebwNNMCWGNi6jS', 'student', 'active', 1, NULL, '2026-05-28 15:47:19', '2026-05-28 15:47:19');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1314, 'student.derrick.kachidza.103@seed.mssht.test', '$2y$10$2DO6hTq/AukOT9NfcwZLB.1C8qpEfv5vGGguYAtNKxvRhlTk9UXFu', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1315, 'student.elina.moyo.104@seed.mssht.test', '$2y$10$mmYN6LMcmuQLQveIWlMDCu.q70AAcojC6odC5De1gksxw4I4rpZFi', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1316, 'student.farai.ncube.105@seed.mssht.test', '$2y$10$cHImUPo9Mj2Moo0DojAFHu5UeTmuJfEaFhfsR44YMR6syTBSCXzNu', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1317, 'student.godfrey.nyasha.106@seed.mssht.test', '$2y$10$jeSMYDxyQVdFWbA46NpfcO0MsCraM2C5wgU/wvgYfJqHBap/zyUQe', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1318, 'student.hilda.phiri.107@seed.mssht.test', '$2y$10$crEtPJ0RlMCT/GrWOTvE9OX5.SkMlqpqGAempVpFE2a0aFys/fEJy', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1319, 'student.ivy.sibanda.108@seed.mssht.test', '$2y$10$qsIXcjFFOtgik/Q3I4IxX.KJFfIdQLDMYjMtbHR/2oZenO5mNHViy', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1320, 'student.jared.tafara.109@seed.mssht.test', '$2y$10$Ghx6YgYDBC5eIpzFgsRHUuUp8/dWqimwLIiMHardT7Iv6paOk6VZO', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1321, 'student.kudzai.vengesai.110@seed.mssht.test', '$2y$10$9K2TueCW28VWqGk74JEHMuxpxyMPsUpocfCZlk8rbjUcOZLVxUB2q', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1322, 'student.lerato.zhou.111@seed.mssht.test', '$2y$10$PTx1hlS0r0P7ZQh1jRKiWe5CGxDSeqpEynWX3L8Y/M0ym4tBlSaMC', 'student', 'active', 1, NULL, '2026-05-28 15:47:20', '2026-05-28 15:47:20');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1323, 'student.moses.banda.112@seed.mssht.test', '$2y$10$31FuTvAqC97ZeEE7Cwz2b.IE18OyBeroU3Mm8wcFY0hcGHG.FSXiC', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1324, 'student.nadia.chirwa.113@seed.mssht.test', '$2y$10$m8VeBhQA0aVqn9YAP10.g.lapmo4/MCarosQk90WP3nL.w6mO15Se', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1325, 'student.obert.dube.114@seed.mssht.test', '$2y$10$eqNBzcTzPW3hTEiMt4Lv..Gp3KZXay2oyYsq592CUR0P.Afq6t88u', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1326, 'student.precious.furusa.115@seed.mssht.test', '$2y$10$vE6Aje0Qc8p/OJnGDEZAPuMHrFS04AvR7CjHP5.9Wp7paVHEM.vjC', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1327, 'student.tariro.gumbo.116@seed.mssht.test', '$2y$10$Ce9RyXDo/OxHCOukM6gevOyNnxVpRxV4EIUjI9KC7x5WwxU8.Y/Dy', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1328, 'student.unity.hove.117@seed.mssht.test', '$2y$10$wTlBEHWnDgjqLL/oqy/QDOS9HbNE6KhvC2XfAdEvDo.Gla.NxuMgy', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1329, 'student.vimbai.jele.118@seed.mssht.test', '$2y$10$YcDpU7J58CRb3ZC2X2L6dOnr72rEG1ion/4salHzpU1jCTJzm9t/2', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1330, 'student.wellington.kachidza.119@seed.mssht.test', '$2y$10$gQ17dhn847.jveekvNT0reXNbfjTydMW0Z68AIefO88XdcXVPxiyK', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');
INSERT INTO `users` (`id`,`email`,`password_hash`,`role`,`status`,`must_change_password`,`last_login`,`created_at`,`updated_at`) VALUES (1331, 'student.amina.moyo.120@seed.mssht.test', '$2y$10$GU9KQMmT5pjkaxIruXLmEOqyZEV6k21ProwW/jFg7Tm6fvxkVhuc.', 'student', 'active', 1, NULL, '2026-05-28 15:47:21', '2026-05-28 15:47:21');

SET FOREIGN_KEY_CHECKS=1;
