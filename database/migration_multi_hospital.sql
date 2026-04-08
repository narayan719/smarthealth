-- ==========================================
-- SMARTHEALTH MULTI-HOSPITAL SYSTEM MIGRATION
-- Alters existing tables and creates new ones
-- ==========================================

-- Step 1: Add hospital_id to admins table (for hospital-specific admins)
ALTER TABLE `admins` ADD COLUMN `hospital_id` INT(11) DEFAULT NULL AFTER `department_id`;
ALTER TABLE `admins` ADD INDEX `idx_hospital_id` (`hospital_id`);

-- Step 2: Update admin roles to include HospitalAdmin
ALTER TABLE `admins` MODIFY `role` enum('SuperAdmin','HospitalAdmin','Admin','Officer','Staff') DEFAULT 'Staff';

-- Step 3: Create assisted_bookings table
CREATE TABLE IF NOT EXISTS `assisted_bookings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `hospital_id` INT(11) NOT NULL,
  `department_id` INT(11) NOT NULL,
  `patient_name` VARCHAR(100) NOT NULL,
  `patient_phone` VARCHAR(20) NOT NULL,
  `patient_age` INT(11) DEFAULT NULL,
  `patient_gender` ENUM('Male','Female','Other') DEFAULT NULL,
  `symptoms` LONGTEXT DEFAULT NULL,
  `priority` ENUM('Normal','Priority','Emergency') DEFAULT 'Normal',
  `booking_date` DATE NOT NULL,
  `booking_time` TIME NOT NULL,
  `token_number` VARCHAR(20) DEFAULT NULL,
  `status` ENUM('Pending','Assigned','Completed','Cancelled') DEFAULT 'Pending',
  `registered_by` INT(11) DEFAULT NULL COMMENT 'Admin ID who created this booking',
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_hospital_id` (`hospital_id`),
  INDEX `idx_department_id` (`department_id`),
  INDEX `idx_booking_date` (`booking_date`),
  INDEX `idx_status` (`status`),
  INDEX `idx_registered_by` (`registered_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 4: Create hospital_staff table (to track staff working in each hospital)
CREATE TABLE IF NOT EXISTS `hospital_staff` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `admin_id` INT(11) NOT NULL COMMENT 'Reference to admins table',
  `hospital_id` INT(11) NOT NULL,
  `department_id` INT(11) DEFAULT NULL,
  `position` VARCHAR(100) DEFAULT NULL,
  `joined_date` DATE DEFAULT NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_staff` (`admin_id`, `hospital_id`),
  INDEX `idx_hospital_id` (`hospital_id`),
  INDEX `idx_department_id` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 5: Create hospital_settings table (for customization per hospital)
CREATE TABLE IF NOT EXISTS `hospital_settings` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `hospital_id` INT(11) NOT NULL,
  `setting_key` VARCHAR(100) NOT NULL,
  `setting_value` LONGTEXT DEFAULT NULL,
  `setting_type` ENUM('text','number','boolean','json') DEFAULT 'text',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_setting` (`hospital_id`, `setting_key`),
  INDEX `idx_hospital_id` (`hospital_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 6: Add hospital_id to tokens table (if not exists)
-- Check first if column exists before adding
ALTER TABLE `tokens` ADD COLUMN `hospital_id_check` INT(11) DEFAULT NULL;
-- If no error above, remove the check column and add the proper one if hospital_id doesn't exist
ALTER TABLE `tokens` DROP COLUMN `hospital_id_check`;

-- Step 7: Create view for hospital admin dashboard data
CREATE OR REPLACE VIEW `hospital_dashboard_summary` AS
SELECT 
  h.`id` as hospital_id,
  h.`hospital_name`,
  h.`district`,
  h.`municipality`,
  COUNT(DISTINCT t.`id`) as total_tokens_today,
  COUNT(DISTINCT CASE WHEN t.`status` = 'Pending' THEN t.`id` END) as pending_tokens,
  COUNT(DISTINCT CASE WHEN t.`status` = 'Called' THEN t.`id` END) as called_tokens,
  COUNT(DISTINCT CASE WHEN t.`status` = 'Completed' THEN t.`id` END) as completed_tokens,
  COUNT(DISTINCT ab.`id`) as assisted_bookings_today
FROM `hospital_locations` h
LEFT JOIN `tokens` t ON h.`id` = t.`hospital_id` AND DATE(t.`created_at`) = CURDATE()
LEFT JOIN `assisted_bookings` ab ON h.`id` = ab.`hospital_id` AND DATE(ab.`created_at`) = CURDATE()
WHERE h.`is_active` = 1
GROUP BY h.`id`, h.`hospital_name`, h.`district`, h.`municipality`;

-- ==========================================
-- INSERT SAMPLE HOSPITAL ADMINS
-- ==========================================

-- Hospital Admin for Bir Hospital (ID: 12)
INSERT INTO `admins` (`username`, `password_hash`, `full_name`, `email`, `role`, `hospital_id`, `is_active`, `created_at`) 
VALUES ('bir_admin', '$2y$10$zY1Y9DbKoNV8dJYyHEiO0eytsyG756ZHNsl6STEqW6cGB8BIHRPhq', 'Bir Hospital Admin', 'admin@birhospital.local', 'HospitalAdmin', 12, 1, NOW());

-- Hospital Admin for Kantipur Hospital (ID: 16)
INSERT INTO `admins` (`username`, `password_hash`, `full_name`, `email`, `role`, `hospital_id`, `is_active`, `created_at`) 
VALUES ('kantipur_admin', '$2y$10$zY1Y9DbKoNV8dJYyHEiO0eytsyG756ZHNsl6STEqW6cGB8BIHRPhq', 'Kantipur Hospital Admin', 'admin@kantipurhospital.local', 'HospitalAdmin', 16, 1, NOW());

-- ==========================================
-- INSERT SAMPLE HOSPITAL SETTINGS
-- ==========================================

INSERT INTO `hospital_settings` (`hospital_id`, `setting_key`, `setting_value`, `setting_type`) 
VALUES 
  (12, 'max_daily_tokens', '100', 'number'),
  (12, 'assisted_booking_enabled', '1', 'boolean'),
  (12, 'allow_walk_ins', '1', 'boolean'),
  (16, 'max_daily_tokens', '80', 'number'),
  (16, 'assisted_booking_enabled', '1', 'boolean'),
  (16, 'allow_walk_ins', '1', 'boolean');

-- ==========================================
-- COMMIT MIGRATION
-- ==========================================
COMMIT;
