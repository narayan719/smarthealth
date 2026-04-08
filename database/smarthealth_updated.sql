-- Database Update for Multi-Hospital Admin System
-- Run this after existing database

-- ==========================================
-- 1. MODIFY ADMINS TABLE FOR HOSPITAL SUPPORT
-- ==========================================

ALTER TABLE `admins` ADD COLUMN `hospital_id` INT(11) DEFAULT NULL AFTER `department_id`;
ALTER TABLE `admins` ADD COLUMN `is_hospital_admin` TINYINT(1) DEFAULT 0 AFTER `hospital_id`;
ALTER TABLE `admins` ADD COLUMN `permissions` LONGTEXT DEFAULT NULL AFTER `is_hospital_admin`;
ALTER TABLE `admins` ADD KEY `idx_hospital_id` (`hospital_id`);
ALTER TABLE `admins` ADD FOREIGN KEY (`hospital_id`) REFERENCES `hospital_locations` (`id`) ON DELETE SET NULL;

-- ==========================================
-- 2. UPDATE HOSPITAL_LOCATIONS TABLE
-- ==========================================

ALTER TABLE `hospital_locations` ADD COLUMN `contact_person` VARCHAR(100) DEFAULT NULL AFTER `phone`;
ALTER TABLE `hospital_locations` ADD COLUMN `contact_email` VARCHAR(100) DEFAULT NULL AFTER `contact_person`;
ALTER TABLE `hospital_locations` ADD COLUMN `opening_time` TIME DEFAULT '08:00:00' AFTER `contact_email`;
ALTER TABLE `hospital_locations` ADD COLUMN `closing_time` TIME DEFAULT '18:00:00' AFTER `opening_time`;
ALTER TABLE `hospital_locations` ADD COLUMN `emergency_24_7` TINYINT(1) DEFAULT 1 AFTER `closing_time`;
ALTER TABLE `hospital_locations` ADD COLUMN `total_departments` INT(11) DEFAULT 0 AFTER `emergency_24_7`;
ALTER TABLE `hospital_locations` ADD COLUMN `total_staff` INT(11) DEFAULT 0 AFTER `total_departments`;
ALTER TABLE `hospital_locations` ADD COLUMN `current_tokens` INT(11) DEFAULT 0 AFTER `total_staff`;

-- ==========================================
-- 3. CREATE HOSPITAL_DEPARTMENTS TABLE
-- ==========================================

CREATE TABLE IF NOT EXISTS `hospital_departments` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `hospital_id` INT(11) NOT NULL,
  `department_id` INT(11) NOT NULL,
  `available` TINYINT(1) DEFAULT 1,
  `max_tokens_per_day` INT(11) DEFAULT 50,
  `current_daily_tokens` INT(11) DEFAULT 0,
  `avg_service_time` INT(11) DEFAULT 30,
  `description` TEXT DEFAULT NULL,
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`hospital_id`) REFERENCES `hospital_locations` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_hospital_dept` (`hospital_id`, `department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 4. CREATE HOSPITAL_STAFF TABLE
-- ==========================================

CREATE TABLE IF NOT EXISTS `hospital_staff` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `hospital_id` INT(11) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `position` VARCHAR(50) NOT NULL,
  `department_id` INT(11) DEFAULT NULL,
  `email` VARCHAR(100) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `admin_id` INT(11) DEFAULT NULL,
  `status` ENUM('Active','Inactive','Leave') DEFAULT 'Active',
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`hospital_id`) REFERENCES `hospital_locations` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  FOREIGN KEY (`admin_id`) REFERENCES `admins` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 5. CREATE ASSISTED_BOOKINGS TABLE
-- ==========================================

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
  `registered_by` INT(11) DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`hospital_id`) REFERENCES `hospital_locations` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  FOREIGN KEY (`registered_by`) REFERENCES `admins` (`id`) ON DELETE SET NULL,
  KEY `idx_hospital_booking_date` (`hospital_id`, `booking_date`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 6. CREATE HOSPITAL_STATISTICS TABLE
-- ==========================================

CREATE TABLE IF NOT EXISTS `hospital_statistics` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `hospital_id` INT(11) NOT NULL,
  `date` DATE NOT NULL,
  `total_tokens_today` INT(11) DEFAULT 0,
  `completed_tokens` INT(11) DEFAULT 0,
  `pending_tokens` INT(11) DEFAULT 0,
  `avg_wait_time` INT(11) DEFAULT 0,
  `assisted_bookings` INT(11) DEFAULT 0,
  `online_bookings` INT(11) DEFAULT 0,
  `customer_rating` DECIMAL(3,2) DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`hospital_id`) REFERENCES `hospital_locations` (`id`) ON DELETE CASCADE,
  UNIQUE KEY `unique_hospital_date` (`hospital_id`, `date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==========================================
-- 7. UPDATE PERMISSIONS STRUCTURE
-- ==========================================

-- Insert default SuperAdmin with full permissions
INSERT INTO `admins` (`username`, `password_hash`, `full_name`, `email`, `role`, `is_active`, `created_at`) 
VALUES ('superadmin', '$2y$10$zY1Y9DbKoNV8dJYyHEiO0eytsyG756ZHNsl6STEqW6cGB8BIHRPhq', 'System Administrator', 'superadmin@smarthealth.local', 'SuperAdmin', 1, NOW())
ON DUPLICATE KEY UPDATE `id` = `id`;

-- Sample hospital admin (Bir Hospital)
INSERT INTO `admins` (`username`, `password_hash`, `full_name`, `email`, `role`, `hospital_id`, `is_hospital_admin`, `is_active`, `created_at`) 
VALUES ('bir_admin', '$2y$10$WOc2oQ3PD0PdiAisSjL.rOi8dFtxAQ9RnJC4EGRHjPiF3LqWJBrsu', 'Bir Hospital Admin', 'admin@birhospital.local', 'Admin', 12, 1, 1, NOW())
ON DUPLICATE KEY UPDATE `id` = `id`;

-- Sample hospital staff
INSERT INTO `hospital_staff` (`hospital_id`, `name`, `position`, `department_id`, `email`, `phone`, `admin_id`, `is_active`) 
VALUES (12, 'Dr. Anil Kumar', 'Doctor', 1, 'anil@birhospital.local', '+977-1-4224881', 7, 1)
ON DUPLICATE KEY UPDATE `id` = `id`;

-- ==========================================
-- 8. SAMPLE DATA
-- ==========================================

-- Add hospital departments for Bir Hospital (ID: 12)
INSERT INTO `hospital_departments` (`hospital_id`, `department_id`, `available`, `max_tokens_per_day`, `avg_service_time`, `is_active`) 
VALUES 
(12, 1, 1, 50, 30, 1),
(12, 2, 1, 20, 15, 1),
(12, 7, 1, 20, 35, 1),
(12, 5, 1, 35, 25, 1)
ON DUPLICATE KEY UPDATE `id` = `id`;

-- Update hospital locations with additional info
UPDATE `hospital_locations` SET 
  `contact_person` = 'Dr. Prakash Sharma',
  `contact_email` = 'admin@birhospital.local',
  `opening_time` = '08:00:00',
  `closing_time` = '18:00:00',
  `emergency_24_7` = 1,
  `total_departments` = 4,
  `total_staff` = 15
WHERE `id` = 12;

-- ==========================================
-- 9. ALTER TOKENS TABLE (if needed)
-- ==========================================

-- Add assisted booking reference
ALTER TABLE `tokens` ADD COLUMN `assisted_booking_id` INT(11) DEFAULT NULL AFTER `hospital_id`;
ALTER TABLE `tokens` ADD FOREIGN KEY (`assisted_booking_id`) REFERENCES `assisted_bookings` (`id`) ON DELETE SET NULL;

-- ==========================================
-- 10. UPDATE BOOKING_HISTORY TABLE
-- ==========================================

ALTER TABLE `booking_history` ADD COLUMN `assisted_booking` TINYINT(1) DEFAULT 0 AFTER `hospital_id`;

COMMIT;
