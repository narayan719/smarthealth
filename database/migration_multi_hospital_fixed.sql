-- ==========================================
-- SMARTHEALTH MULTI-HOSPITAL SYSTEM
-- Creates missing tables for hospital management
-- ==========================================

-- Update admin roles to include HospitalAdmin if not exists
ALTER TABLE `admins` MODIFY `role` enum('SuperAdmin','HospitalAdmin','Admin','Officer','Staff') DEFAULT 'Staff';

-- Create assisted_bookings table
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

-- Create hospital_staff table
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

-- Create hospital_settings table
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

-- Insert sample hospital admins (passwords are 'password' hashed with bcrypt)
INSERT IGNORE INTO `admins` (`username`, `password_hash`, `full_name`, `email`, `role`, `hospital_id`, `is_active`, `created_at`) 
VALUES 
  ('bir_admin', '$2y$10$zY1Y9DbKoNV8dJYyHEiO0eytsyG756ZHNsl6STEqW6cGB8BIHRPhq', 'Bir Hospital Admin', 'admin@birhospital.local', 'HospitalAdmin', 12, 1, NOW()),
  ('kantipur_admin', '$2y$10$zY1Y9DbKoNV8dJYyHEiO0eytsyG756ZHNsl6STEqW6cGB8BIHRPhq', 'Kantipur Hospital Admin', 'admin@kantipurhospital.local', 'HospitalAdmin', 16, 1, NOW());

-- Insert sample hospital settings
INSERT IGNORE INTO `hospital_settings` (`hospital_id`, `setting_key`, `setting_value`, `setting_type`) 
VALUES 
  (12, 'max_daily_tokens', '100', 'number'),
  (12, 'assisted_booking_enabled', '1', 'boolean'),
  (12, 'allow_walk_ins', '1', 'boolean'),
  (16, 'max_daily_tokens', '80', 'number'),
  (16, 'assisted_booking_enabled', '1', 'boolean'),
  (16, 'allow_walk_ins', '1', 'boolean');

COMMIT;
