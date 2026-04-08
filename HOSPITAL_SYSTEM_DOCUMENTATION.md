# SmartHealth Nepal - Multi-Hospital Admin System Documentation

## System Overview

The SmartHealth Nepal platform now supports a complete multi-hospital management system with role-based access control. Each hospital can have its own admin panel where hospital administrators can manage departments, staff, tokens, and assisted bookings.

## Architecture

### User Roles

1. **Super Admin**
   - Full system access
   - Can manage all hospitals
   - Can create hospital admins
   - Access to all reports and analytics
   - Can manage system settings

2. **Hospital Admin**
   - Limited to their assigned hospital only
   - Can manage hospital staff and departments
   - Can view and manage tokens
   - Can manage assisted bookings
   - Can view hospital-specific reports

3. **Hospital Staff**
   - Basic access to hospital operations
   - Can view tokens and assisted bookings
   - Can update booking status
   - Limited report access

## Database Schema Changes

### New Tables

#### `hospital_departments`
Links hospitals with their available departments and manages capacity:
```
- id: Primary key
- hospital_id: FK to hospital_locations
- department_id: FK to departments
- available: Boolean (1/0)
- max_tokens_per_day: Integer
- current_daily_tokens: Integer
- avg_service_time: Integer (minutes)
- is_active: Boolean
```

#### `hospital_staff`
Manages hospital staff members:
```
- id: Primary key
- hospital_id: FK to hospital_locations
- name: String
- position: String (Doctor, Nurse, Receptionist, etc.)
- department_id: FK to departments
- email: String
- phone: String
- admin_id: FK to admins (if staff has admin account)
- status: Enum (Active, Inactive, Leave)
- is_active: Boolean
```

#### `assisted_bookings`
Manages assisted bookings made through hospital staff:
```
- id: Primary key
- hospital_id: FK to hospital_locations
- department_id: FK to departments
- patient_name: String
- patient_phone: String
- patient_age: Integer
- patient_gender: Enum
- symptoms: Text
- priority: Enum (Normal, Priority, Emergency)
- booking_date: Date
- booking_time: Time
- token_number: String (assigned later)
- status: Enum (Pending, Assigned, Completed, Cancelled)
- registered_by: FK to admins
- notes: Text
- created_at, updated_at: Timestamps
```

#### `hospital_statistics`
Tracks daily hospital statistics:
```
- id: Primary key
- hospital_id: FK to hospital_locations
- date: Date
- total_tokens_today: Integer
- completed_tokens: Integer
- pending_tokens: Integer
- avg_wait_time: Integer (minutes)
- assisted_bookings: Integer
- online_bookings: Integer
- customer_rating: Decimal
- created_at, updated_at: Timestamps
```

### Modified Tables

#### `admins` Table
Added fields:
```
- hospital_id: FK to hospital_locations (NULL for SuperAdmin)
- is_hospital_admin: Boolean (1 = hospital admin, 0 = system admin)
- permissions: JSON (for future granular permissions)
```

#### `hospital_locations` Table
Added fields:
```
- contact_person: String
- contact_email: String
- opening_time: Time
- closing_time: Time
- emergency_24_7: Boolean
- total_departments: Integer
- total_staff: Integer
- current_tokens: Integer
```

#### `tokens` Table
Added field:
```
- assisted_booking_id: FK to assisted_bookings
```

#### `booking_history` Table
Added field:
```
- assisted_booking: Boolean (1 = assisted, 0 = online)
```

## File Structure

```
admin/
├── hospital/
│   ├── login.php                          # Hospital admin login
│   ├── logout.php                         # Logout handler
│   ├── dashboard/
│   │   └── index.php                      # Dashboard
│   ├── assisted-bookings/
│   │   └── index.php                      # Manage assisted bookings
│   ├── departments/
│   │   └── index.php                      # Manage departments
│   ├── staff/
│   │   └── index.php                      # Manage staff
│   ├── tokens/
│   │   └── index.php                      # Token management
│   ├── settings/
│   │   └── index.php                      # Hospital settings
│   └── reports/
│       └── index.php                      # Reports
├── backend/
│   ├── controllers/
│   │   ├── HospitalAuthController.php     # Authentication
│   │   └── HospitalDashboardController.php # Dashboard logic
│   └── api/
│       └── hospital-api.php               # API endpoints

public/
├── hospitals.php                          # Hospital listing page
└── hospital-detail.php                    # Hospital detail & booking
```

## Authentication Flow

1. Hospital admin visits `/admin/hospital/login.php`
2. Enters username and password
3. System validates credentials via `HospitalAuthController::login()`
4. Sets session variables:
   - `admin_id`
   - `hospital_id` (if hospital admin)
   - `access_type` ('super' or 'hospital')
5. Redirects to dashboard

## Access Control

- **Super Admin**: Session has `access_type = 'super'`, can access any hospital
- **Hospital Admin**: Session has `access_type = 'hospital'` and specific `hospital_id`, restricted to their hospital
- Authorization checked on every page via `hasHospitalAccess()`

## API Endpoints

All endpoints require authentication. Base URL: `/admin/backend/api/hospital-api.php`

### Get Tokens
```
GET ?action=get_tokens&hospital_id=12
Response: { success, tokens[] }
```

### Update Token Status
```
POST action=update_token_status
Data: { token_id, status, hospital_id }
Response: { success, message }
```

### Get Assisted Bookings
```
GET ?action=get_assisted_bookings&hospital_id=12&date=2026-02-12
Response: { success, bookings[] }
```

### Get Statistics
```
GET ?action=get_statistics&hospital_id=12&start_date=2026-01-01&end_date=2026-02-12
Response: { success, statistics[] }
```

### Get Departments
```
GET ?action=get_departments&hospital_id=12
Response: { success, departments[] }
```

### Get Staff
```
GET ?action=get_staff&hospital_id=12
Response: { success, staff[] }
```

### Get Daily Summary
```
GET ?action=get_daily_summary&hospital_id=12
Response: { success, summary: {total_tokens, completed, assisted_today, staff_count} }
```

## Public-Facing Features

### Hospital Directory (`/public/hospitals.php`)
- Lists all active hospitals
- Filter by district
- Display hospital details, departments, specialties
- Direct link to booking or assisted booking request

### Hospital Detail Page (`/public/hospital-detail.php?id=12`)
- Full hospital information
- Available departments with current load
- Contact information and hours
- **Assisted Booking Form**:
  - Patient name, phone, age, gender
  - Select department
  - Select preferred date/time
  - Specify symptoms and priority
  - Submit request (no login required)
  - Hospital staff can contact patient to confirm

## Assisted Booking System

### Flow
1. Patient visits hospital detail page
2. Fills assisted booking form anonymously
3. Submission creates entry in `assisted_bookings` table
4. Hospital admin sees pending booking on dashboard
5. Admin contacts patient via phone/SMS
6. Once confirmed, admin creates token with `assisted_booking_id` reference
7. Patient visits hospital at appointment time
8. Staff marks as completed

### Benefits
- Helps patients who can't use online booking
- Reduces no-shows (staff confirms)
- Better for emergency/priority cases
- Supports older patients with less tech literacy

## Default Test Accounts

### Super Admin
- Username: `superadmin`
- Password: `password`
- Access: All hospitals

### Hospital Admin (Bir Hospital)
- Username: `bir_admin`
- Password: `password` (set by super admin)
- Access: Bir Hospital only

## Security Measures

1. **Session Timeouts**: Empty sessions automatically redirect to login
2. **SQL Injection Prevention**: All queries use prepared statements
3. **CSRF Protection**: Can be added with tokens
4.  **Password Hashing**: bcrypt with cost 10
5. **Access Control**: Every page checks user role and hospital assignment
6. **Rate Limiting**: Can be added for API endpoints

## Deployment Checklist

- [ ] Run database migration script (`smarthealth_updated.sql`)
- [ ] Create hospital directories if not exist
- [ ] Set proper file permissions (755 for dirs, 644 for files)
- [ ] Configure database credentials in `.env`
- [ ] Create Super Admin account
- [ ] Create Hospital Admin accounts for each hospital
- [ ] Update hospital details in `hospital_locations`
- [ ] Add departments for each hospital via `hospital_departments`
- [ ] Add staff members for each hospital via `hospital_staff`
- [ ] Test authentication from each access level
- [ ] Test assisted booking flow end-to-end
- [ ] Configure email/SMS notifications (optional)

## Troubleshooting

### Login Not Working
- Check database connection
- Verify admin record exists in `admins` table
- Verify password hash is valid (bcrypt format)
- Check session permissions

### Can't Access Hospital Dashboard
- Verify `hospital_id` is set in session
- Verify user has `is_hospital_admin = 1`
- Check if hospital exists in `hospital_locations`
- Check access control logic in page header

### Assisted Bookings Not Showing
- Verify booking date is current or future
- Check `hospital_departments` has entries
- Verify departments are marked `is_active = 1`
- Check database for records via phpMyAdmin

## Future Enhancements

1. **SMS Notifications**: Auto-notify patients when bookings are confirmed
2. **Email Notifications**: Send confirmation emails
3. **Queue Management**: Real-time token queue visualization
4. **Staff Availability**: Track staff schedules
5. **Analytics Dashboard**: Charts and graphs for hospital metrics
6. **Referral System**: Inter-hospital referrals
7. **Patient History**: Linked to assisted bookings
8. **Ratings & Reviews**: After completing assisted bookings
9. **Integration with SMS gateway**: Two-way communication
10. **Mobile App**: Native app for hospital staff

## Support

For issues or questions:
1. Check database schema against provided SQL
2. Review error logs in browser console
3. Verify file permissions
4. Check database connectivity
5. Contact system administrator
