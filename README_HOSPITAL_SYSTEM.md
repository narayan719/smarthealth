# SmartHealth Nepal - Multi-Hospital Admin System

A complete, production-ready hospital management system for Nepal with multi-hospital support, role-based access control, and public-facing hospital booking features.

## 🎯 Features

### For Hospital Administrators
- **Dedicated Hospital Admin Panel** - Each hospital has its own secure dashboard
- **Token Management** - View, update, and manage patient tokens in real-time
- **Assisted Booking System** - Manage walk-in patient bookings through hospital staff
- **Staff Management** - Add and manage hospital staff members
- **Department Management** - Control available departments and capacity
- **Statistics & Reports** - Track hospital metrics and performance
- **Real-time Dashboard** - Overview of daily operations

### For Super Admin
- **Multi-Hospital Management** - Control all hospitals from one panel
- **Admin Account Management** - Create and manage hospital admins
- **System-wide Reports** - Aggregate analytics across hospitals
- **Hospital Configuration** - Setup new hospitals and departments

### For Public Users
- **Hospital Directory** - Browse all available hospitals by district
- **Hospital Details** - View hospital information, departments, and specialties
- **Assisted Booking** - Request appointment through hospital staff
- **Direct Booking** - Book online with immediate token generation (integrated with existing system)

## 📁 Project Structure

```
smarthealth_nepal/
├── admin/
│   ├── hospital/                    # Hospital admin interface
│   │   ├── login.php               # Admin login page
│   │   ├── logout.php
│   │   ├── dashboard/              # Main dashboard
│   │   ├── tokens/                 # Token management
│   │   ├── assisted-bookings/      # Assisted booking management
│   │   ├── staff/                  # Staff management
│   │   ├── departments/            # Department management
│   │   ├── settings/               # Hospital settings
│   │   └── reports/                # Reports & analytics
│   ├── backend/
│   │   ├── controllers/
│   │   │   ├── HospitalAuthController.php
│   │   │   └── HospitalDashboardController.php
│   │   ├── api/
│   │   │   └── hospital-api.php
│   │   └── config/
│   │       └── database.php
│   └── frontend/
│       └── css/, js/
│
├── public/
│   ├── hospitals.php               # Hospital listing/directory
│   └── hospital-detail.php         # Hospital detail & booking
│
├── database/
│   ├── smarthealth.sql            # Original schema
│   └── smarthealth_updated.sql    # New multi-hospital schema
│
├── setup.php                       # Installation wizard
├── INSTALLATION_GUIDE.md          # Setup instructions
├── HOSPITAL_SYSTEM_DOCUMENTATION.md
└── README.md (this file)
```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)

1. **Visit Setup Wizard**
   ```
   http://localhost/smarthealth_nepal/setup.php
   ```

2. **Follow the wizard** to:
   - Test database connection
   - Run database migration
   - Create admin accounts

3. **Login and start using**
   ```
   Admin Panel: http://localhost/smarthealth_nepal/admin/hospital/login.php
   Public: http://localhost/smarthealth_nepal/public/hospitals.php
   ```

### Option 2: Manual Setup

See [INSTALLATION_GUIDE.md](INSTALLATION_GUIDE.md) for detailed manual setup instructions.

## 🔐 Default Credentials

After setup, use these to login:

| Account | Username | Password |
|---------|----------|----------|
| Super Admin | `superadmin` | `password` |
| Hospital Admin (Bir) | `bir_admin` | `password` |

⚠️ **Change these immediately in production!**

## 💾 Database Schema

### New Tables

- **`hospital_departments`** - Links hospitals with their departments
- **`hospital_staff`** - Hospital staff members management
- **`assisted_bookings`** - Walk-in booking requests
- **`hospital_statistics`** - Daily hospital metrics

### Modified Tables

- **`admins`** - Added hospital_id, is_hospital_admin, permissions
- **`hospital_locations`** - Added contact info, hours, emergency status
- **`tokens`** - Added assisted_booking_id reference
- **`booking_history`** - Added assisted_booking flag

## 👥 User Roles & Access

### Super Admin
```
Access: ALL hospitals
Permissions:
  ✓ View all hospitals
  ✓ Create/manage hospital admins
  ✓ Manage all tokens & bookings
  ✓ System-wide reports
  ✓ System settings
```

### Hospital Admin
```
Access: Their assigned hospital ONLY
Permissions:
  ✓ View own hospital dashboard
  ✓ Manage own hospital tokens
  ✓ Create assisted bookings
  ✓ Manage staff
  ✓ Manage departments
  ✓ View own hospital statistics
```

### Hospital Staff
```
Access: Limited to their hospital
Permissions:
  ✓ View tokens
  ✓ Update booking status
  ✓ Create assisted bookings
  ✓ Basic reports
```

### Public Users
```
Access: Public pages only
Permissions:
  ✓ Browse hospitals
  ✓ View hospital details
  ✓ Submit assisted booking request
  ✓ Book online (if integrated)
```

## 🔄 Assisted Booking Flow

1. **Patient Submits Request**
   - Visits hospital detail page
   - Fills assisted booking form
   - No login required

2. **Hospital Staff Reviews**
   - Sees pending booking in admin panel
   - Contacts patient to confirm
   - Verifies appointment details

3. **Booking Confirmed**
   - Admin creates token with booking reference
   - System links to assisted_bookings
   - Patient arrives at scheduled time

4. **Service Completion**
   - Staff marks as completed
   - Patient receives feedback option
   - Data recorded for analytics

## 📊 API Endpoints

All endpoints require authentication. Base: `/admin/backend/api/hospital-api.php`

```
GET  ?action=get_tokens            - Fetch hospital tokens
POST action=update_token_status    - Update token status
GET  ?action=get_assisted_bookings - Get assisted bookings
GET  ?action=get_departments       - Hospital departments
GET  ?action=get_staff             - Hospital staff
GET  ?action=get_statistics        - Hospital statistics
GET  ?action=get_daily_summary     - Today's summary
```

## 🔒 Security Features

- **Bcrypt password hashing** - Industry standard
- **Prepared SQL statements** - SQL injection prevention
- **Session management** - Automatic timeout
- **Role-based access control** - Hospital isolation
- **HTTPS ready** - Configure in production
- **Error logging** - Secure error handling

## ⚙️ Configuration

### Environment Variables (.env)
```
DB_HOST=localhost
DB_NAME=smarthealth
DB_USER=root
DB_PASSWORD=
DB_PORT=3306
```

### Session Configuration
- Timeout: 30 minutes of inactivity
- Secure: HTTPS in production
- HttpOnly: Prevent JavaScript access
- SameSite: CSRF protection

## 📋 Checklist for Deployment

- [ ] Database migration completed
- [ ] Admin accounts created
- [ ] Super Admin password changed
- [ ] Hospital Admin passwords changed
- [ ] Hospital information updated
- [ ] Departments configured
- [ ] Staff members added
- [ ] HTTPS certificate installed (production)
- [ ] Server firewall configured
- [ ] Database backup scheduled
- [ ] Error logging configured
- [ ] Email notifications tested (optional)

## 🧪 Testing

### Test Checklist

```
Authentication
  ✓ Super admin can login
  ✓ Hospital admin can login
  ✓ Hospital admin can't access other hospitals
  ✓ Logout works
  ✓ Session expires

Admin Functions
  ✓ View dashboard
  ✓ Manage tokens
  ✓ Create assisted bookings
  ✓ Add staff members
  ✓ View reports

Public Functions
  ✓ Browse hospitals
  ✓ View hospital details
  ✓ Submit assisted booking (no login needed)
```

### Sample Test Data

```sql
-- Already included in migration:
-- Super Admin: superadmin / password
-- Hospital Admin: bir_admin / password
-- Hospital: Bir Hospital (ID: 12)
-- Departments: General Medicine, Emergency, Cardiology, Pediatrics
```

## 📈 Performance Optimization

### Recommended Database Indexes
```sql
CREATE INDEX idx_hospital_date ON tokens(hospital_id, created_at);
CREATE INDEX idx_assisted_date ON assisted_bookings(hospital_id, booking_date);
CREATE INDEX idx_admin_hospital ON admins(hospital_id, is_active);
```

### Query Caching
Enable MySQL query cache for faster repeated queries.

### Image Optimization
- Compress hospital logos
- Lazy load images
- CDN for static assets

## 🔔 Future Enhancements

- [ ] SMS notifications for booking confirmation
- [ ] Email notifications
- [ ] Advanced analytics dashboard
- [ ] Mobile app for staff
- [ ] Queue management system
- [ ] Video consultation integration
- [ ] Insurance verification
- [ ] Patient health records integration
- [ ] Multi-language support (already started with Nepali)
- [ ] Referral management between hospitals

## 🆘 Troubleshooting

### Login Issues
```
1. Check database connection: test_db.php
2. Verify admin exists: SELECT * FROM admins
3. Check password hash: password_verify() in PHP
4. Check session creation: error_log
```

### Dashboard Not Loading
```
1. Verify hospital_id in session
2. Check hospital exists in database
3. Verify hospital_departments entries
4. Check browser console for JS errors
```

### Assisted Bookings Not Showing
```
1. Verify booking date is present/future
2. Check database for records: SELECT * FROM assisted_bookings
3. Verify hospital_id matches
4. Check department exists
```

## 📞 Support

For issues or questions:

1. Check browser console (F12) for errors
2. Review error logs in Apache
3. Test database directly in phpMyAdmin
4. Verify file permissions (755 dirs, 644 files)
5. Check logs/error_log file

## 📜 License

This project is proprietary software for SmartHealth Nepal.

## 👨‍💻 Development Team

SmartHealth Nepal Development Team
- 2026-02-12: Initial Multi-Hospital System v1.0

## 🎓 Documentation

- [Installation Guide](INSTALLATION_GUIDE.md) - Detailed setup instructions
- [System Documentation](HOSPITAL_SYSTEM_DOCUMENTATION.md) - Technical details
- [API Reference](#-api-endpoints) - API endpoint documentation
- [User Guide](#-user-roles--access) - Role and permission guide

## 📱 Browser Support

- Chrome/Chromium (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## ⚡ System Requirements

- PHP 8.0 or higher
- MySQL 5.7 / MariaDB 10.2+
- 512 MB RAM minimum
- 100 MB disk space
- Internet connection

## 📊 Database Backup

### Automated Backup
```bash
#!/bin/bash
mysqldump -u root smarthealth | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Manual Backup
```bash
mysqldump -u root smarthealth > smarthealth_backup.sql
```

### Restore
```bash
mysql -u root smarthealth < smarthealth_backup.sql
```

---

**Last Updated:** February 12, 2026  
**Version:** 1.0 - Multi-Hospital System  
**Status:** Production Ready
