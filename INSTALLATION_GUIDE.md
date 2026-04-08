# SmartHealth Nepal - Installation & Setup Guide

## Prerequisites

- PHP 8.0+
- MySQL/MariaDB 5.7+
- Apache with mod_rewrite enabled
- PDO MySQL extension
- Composer (optional, for future enhancements)

## Installation Steps

### Step 1: Database Setup

1. **Backup Current Database** (Important!)
   ```bash
   cd C:\xampp\htdocs\smarthealth_nepal\database
   # Manually backup smarthealth.sql
   ```

2. **Run Migration Script**
   ```sql
   -- Open phpMyAdmin or use MySQL client
   -- Import: c:\xampp\htdocs\smarthealth_nepal\database\smarthealth_updated.sql
   
   -- OR via command line:
   mysql -u root smarthealth < smarthealth_updated.sql
   ```

3. **Verify Database Changes**
   ```sql
   -- Check new tables exist
   SHOW TABLES;
   
   -- Verify columns added to admins
   DESCRIBE admins;
   
   -- Verify new tables
   DESCRIBE hospital_departments;
   DESCRIBE hospital_staff;
   DESCRIBE assisted_bookings;
   DESCRIBE hospital_statistics;
   ```

### Step 2: Configure Environment

1. **Create/Update .env file** in project root:
   ```
   DB_HOST=localhost
   DB_NAME=smarthealth
   DB_USER=root
   DB_PASSWORD=
   DB_PORT=3306
   ```

2. **Verify Backend Config**
   - File: `admin/backend/config/database.php`
   - Should load environment variables properly

### Step 3: File Structure Verification

Ensure these directories exist:
```
admin/
├── hospital/
│   ├── dashboard/
│   ├── tokens/
│   ├── staff/
│   ├── assisted-bookings/
│   ├── departments/
│   ├── settings/
│   └── reports/
├── backend/
│   ├── controllers/
│   ├── api/
│   └── config/

public/
├── hospitals.php
└── hospital-detail.php
```

Create missing directories:
```bash
cd C:\xampp\htdocs\smarthealth_nepal

# Create directories
mkdir admin\hospital\dashboard
mkdir admin\hospital\tokens
mkdir admin\hospital\staff
mkdir admin\hospital\assisted-bookings
mkdir admin\hospital\departments
mkdir admin\hospital\settings
mkdir admin\hospital\reports
mkdir admin\backend\api
mkdir public
```

### Step 4: Test Database Connection

Create test file: `test_db_connection.php`
```php
<?php
try {
    include 'admin/backend/config/database.php';
    
    $db = new \PDO("mysql:host={$_ENV['DB_HOST']};dbname={$_ENV['DB_NAME']}", 
                  $_ENV['DB_USER'], 
                  $_ENV['DB_PASSWORD']);
    
    echo "✓ Database connection successful!<br>";
    
    // Test new tables
    $tables = ['hospital_departments', 'hospital_staff', 'assisted_bookings', 'hospital_statistics'];
    foreach ($tables as $table) {
        $result = $db->query("SELECT COUNT(*) FROM $table");
        echo "✓ Table '$table' exists<br>";
    }
} catch (Exception $e) {
    echo "✗ Error: " . $e->getMessage();
}
?>
```

### Step 5: Create Admin Accounts

1. **Super Admin Account**
   ```sql
   INSERT INTO admins (username, password_hash, full_name, email, role, is_active, created_at)
   VALUES ('superadmin', '$2y$10$zY1Y9DbKoNV8dJYyHEiO0eytsyG756ZHNsl6STEqW6cGB8BIHRPhq', 
           'System Administrator', 'superadmin@smarthealth.local', 'SuperAdmin', 1, NOW());
   ```

2. **Hospital Admin for Bir Hospital (ID: 12)**
   ```sql
   INSERT INTO admins (username, password_hash, full_name, email, role, hospital_id, 
                       is_hospital_admin, is_active, created_at)
   VALUES ('bir_admin', '$2y$10$WOc2oQ3PD0PdiAisSjL.rOi8dFtxAQ9RnJC4EGRHjPiF3LqWJBrsu',
           'Bir Hospital Admin', 'admin@birhospital.local', 'Admin', 12, 1, 1, NOW());
   ```

   **Default Passwords**: `password` (hash above)
   
   To hash a different password:
   ```php
   <?php echo password_hash('your_password', PASSWORD_BCRYPT); ?>
   ```

3. **Add Hospital Departments**
   ```sql
   -- For Bir Hospital (ID: 12)
   INSERT INTO hospital_departments (hospital_id, department_id, available, max_tokens_per_day, avg_service_time, is_active)
   VALUES 
   (12, 1, 1, 50, 30, 1),    -- General Medicine
   (12, 2, 1, 20, 15, 1),    -- Emergency
   (12, 7, 1, 20, 35, 1),    -- Cardiology
   (12, 5, 1, 35, 25, 1);    -- Pediatrics
   ```

4. **Add Hospital Staff**
   ```sql
   INSERT INTO hospital_staff (hospital_id, name, position, department_id, email, phone, is_active)
   VALUES 
   (12, 'Dr. Prakash Sharma', 'Hospital Administrator', NULL, 'prakash@bir.edu.np', '+977-1-4224881', 1),
   (12, 'Dr. Anil Kumar', 'Doctor', 1, 'anil@bir.edu.np', '+977-1-4224881', 1),
   (12, 'Nurse Mina', 'Nurse', 1, 'mina@bir.edu.np', '+977-1-4224881', 1);
   ```

### Step 6: Test Login

1. **Super Admin Login**
   - URL: `http://localhost/smarthealth_nepal/admin/hospital/login.php`
   - Username: `superadmin`
   - Password: `password`

2. **Hospital Admin Login**
   - URL: `http://localhost/smarthealth_nepal/admin/hospital/login.php`
   - Username: `bir_admin`
   - Password: `password`

### Step 7: Test Public Pages

1. **Hospital Directory**
   - URL: `http://localhost/smarthealth_nepal/public/hospitals.php`
   - Should display all active hospitals

2. **Hospital Detail & Booking**
   - URL: `http://localhost/smarthealth_nepal/public/hospital-detail.php?id=12`
   - Should show Bir Hospital details
   - Should display assisted booking form

## Troubleshooting

### Issue: Database Connection Error
**Solution:**
```php
// Check database.php
var_dump($_ENV);  // Should show DB credentials
// Verify MySQL is running
// Check username/password in .env
```

### Issue: Login Fails
**Solution:**
```sql
-- Check admin exists
SELECT id, username, role, hospital_id FROM admins WHERE username = 'superadmin';

-- Verify password hash
SELECT password_hash FROM admins WHERE username = 'superadmin';

-- Test bcrypt verification in PHP
echo password_verify('password', '$2y$10$zY1Y9...');  // Should return true
```

### Issue: Can't Access Hospital Dashboard
**Solution:**
```sql
-- Verify hospital admin setup
SELECT * FROM admins WHERE is_hospital_admin = 1;

-- Check hospital exists
SELECT * FROM hospital_locations WHERE id = 12;

-- Verify hospital_departments exist
SELECT * FROM hospital_departments WHERE hospital_id = 12;
```

### Issue: No Departments Show in Booking Form
**Solution:**
```sql
-- Ensure hospital_departments entries exist and are active
SELECT * FROM hospital_departments WHERE hospital_id = 12 AND is_active = 1;

-- If empty, insert them:
INSERT INTO hospital_departments (hospital_id, department_id, available, max_tokens_per_day, is_active)
VALUES (12, 1, 1, 50, 1);
```

### Issue: Session Not Persisting
**Solution:**
```php
// Check session.save_path in php.ini
// Ensure tmp directory is writable
chmod /tmp 777

// Check session_start() is called before any output
// Verify no headers sent before session start
```

## Testing Checklist

- [ ] Database migration successful
- [ ] Super Admin can login
- [ ] Hospital Admin can login
- [ ] Hospital Admin sees only their hospital
- [ ] Super Admin sees all hospitals
- [ ] Dashboard loads with correct data
- [ ] Can view today's tokens
- [ ] Can update token status
- [ ] Can create assisted booking
- [ ] Can view assisted bookings
- [ ] Can add staff member
- [ ] Public hospital list displays
- [ ] Can view hospital detail
- [ ] Can submit assisted booking request (public form)
- [ ] Logout works correctly
- [ ] Session expires after 30 min inactivity
- [ ] Can filter tokens by date/status
- [ ] API endpoints return correct data

## Navigation Links

After installation, these links should work:

| Page | URL |
|------|-----|
| Super Admin Login | `/admin/hospital/login.php` |
| Hospital Admin Login | `/admin/hospital/login.php` |
| Hospital Dashboard | `/admin/hospital/dashboard/` |
| Manage Tokens | `/admin/hospital/tokens/` |
| Assisted Bookings | `/admin/hospital/assisted-bookings/` |
| Staff Management | `/admin/hospital/staff/` |
| Hospital Directory | `/public/hospitals.php` |
| Hospital Detail | `/public/hospital-detail.php?id=12` |

## Security Recommendations

1. **Change Default Passwords**
   ```php
   $new_hash = password_hash('strong_password_123', PASSWORD_BCRYPT);
   // UPDATE admins SET password_hash = '$new_hash' WHERE id = 1;
   ```

2. **Enable HTTPS** (in production)
   - Use SSL certificate
   - Redirect all HTTP to HTTPS

3. **Setup Rate Limiting**
   - Limit login attempts to 5 per 15 minutes
   - IP-based blocking after threshold

4. **Add CSRF Protection**
   - Generate CSRF tokens in forms
   - Validate on submission

5. **Enable SQL Logging** (for debugging)
   ```sql
   -- In my.cnf
   general_log = 1
   general_log_file = /var/log/mysql/query.log
   ```

## Performance Optimization

1. **Add Database Indexes**
   ```sql
   CREATE INDEX idx_hospital_date ON tokens(hospital_id, created_at);
   CREATE INDEX idx_assisted_date ON assisted_bookings(hospital_id, booking_date);
   ```

2. **Setup Query Caching**
   ```sql
   SET GLOBAL query_cache_size = 268435456;  -- 256MB
   SET GLOBAL query_cache_type = 1;
   ```

3. **Monitor Slow Queries**
   ```ini
   ; In php.ini
   slow_query_log = 1
   long_query_time = 2
   ```

## Backup Strategy

1. **Daily Backups**
   ```bash
   mysqldump -u root smarthealth > backup_$(date +%Y%m%d).sql
   ```

2. **Scheduled Backup Script**
   ```bash
   # Create backup_db.sh
   #!/bin/bash
   BACKUP_DIR="/backups"
   DATE=$(date +%Y%m%d_%H%M%S)
   mysqldump -u root smarthealth | gzip > $BACKUP_DIR/smarthealth_$DATE.sql.gz
   ```

## Next Steps

1. Create additional hospital accounts for other hospitals
2. Add staff members for each hospital
3. Setup SMS notifications (optional)
4. Configure email notifications (optional)
5. Implement analytics dashboard
6. Setup automated reports
7. Deploy to production server

## Support

For issues:
1. Check error logs: `error_log` in Apache logs
2. Check browser console (F12) for JS errors
3. Verify database with phpMyAdmin
4. Test individual components with curl/Postman
5. Contact system administrator

## Version History

- **v1.0** (2026-02-12)
  - Initial multi-hospital system
  - Hospital admin panel
  - Public hospital directory
  - Assisted booking system
  - Token management
  - Staff management
