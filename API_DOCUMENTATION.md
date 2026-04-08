# SmartHealth Nepal - API Documentation

## Base URL
```
http://localhost/smarthealth_nepal
```

## Authentication

### Hospital Admin Login
**Endpoint:** `POST /admin/backend/api/hospital_login.php`

**Request:**
```json
{
    "username": "bir_admin",
    "password": "password"
}
```

**Response (Success):**
```json
{
    "success": true,
    "message": "Login successful",
    "admin": {
        "id": 7,
        "username": "bir_admin",
        "full_name": "Bir Hospital Admin",
        "email": "admin@birhospital.local",
        "role": "HospitalAdmin",
        "hospital_id": 12,
        "hospital_name": "Bir Hospital",
        "district": "Kathmandu",
        "municipality": "Kathmandu Metropolitan City"
    }
}
```

**Response (Failure):**
```json
{
    "success": false,
    "message": "Invalid username or password"
}
```

### Hospital Admin Logout
**Endpoint:** `GET /admin/backend/api/hospital_logout.php`

**Response:** Redirects to login page and clears session

---

## Hospital Management APIs

### Get All Hospitals
**Endpoint:** `GET /backend/api/get_hospitals.php`

**Query Parameters:**
- `active_only`: boolean (default: true)
- `district`: string (optional)

**Response:**
```json
{
    "success": true,
    "data": [
        {
            "id": 12,
            "hospital_name": "Bir Hospital",
            "district": "Kathmandu",
            "municipality": "Kathmandu Metropolitan City",
            "ward": "Central",
            "latitude": "27.7172",
            "longitude": "85.3240",
            "address": "Kathmandu 44600, Nepal",
            "specialities": ["General Medicine", "Emergency", "Surgery"],
            "phone": "+977-1-4224881",
            "type": "Government",
            "description": "Government general hospital...",
            "is_active": 1
        }
    ]
}
```

### Get Single Hospital
**Endpoint:** `GET /backend/api/get_hospital.php`

**Query Parameters:**
- `id`: hospital_id (required)

**Response:**
```json
{
    "success": true,
    "hospital": {
        "id": 12,
        "hospital_name": "Bir Hospital",
        "district": "Kathmandu",
        ...
    }
}
```

### Get Hospital Departments
**Endpoint:** `GET /backend/api/get_hospital_departments.php`

**Query Parameters:**
- `hospital_id`: int (required)
- `active_only`: boolean (default: true)

**Response:**
```json
{
    "success": true,
    "departments": [
        {
            "id": 1,
            "name_en": "General Medicine",
            "name_ne": "सामान्य चिकित्सा",
            "description_en": "General health consultations",
            "max_capacity": 50,
            "avg_service_time": 30,
            "current_load": 5,
            "is_active": 1
        }
    ]
}
```

---

## Token Management APIs

### Get Token Status
**Endpoint:** `GET /backend/api/get_token_status.php`

**Query Parameters:**
- `token_id`: int (required)

**Response:**
```json
{
    "success": true,
    "token": {
        "id": 1,
        "user_id": 1,
        "token_number": "001",
        "department_id": 1,
        "hospital_id": 12,
        "status": "Pending",
        "priority": "Normal",
        "is_emergency": 0,
        "estimated_wait_time": 15,
        "created_at": "2026-02-12 07:00:00",
        "called_at": null,
        "completed_at": null
    }
}
```

### Call Next Token
**Endpoint:** `POST /backend/api/call_token.php`

**Request:**
```json
{
    "token_id": 1,
    "department_id": 1,
    "hospital_id": 12
}
```

**Response:**
```json
{
    "success": true,
    "message": "Token called successfully",
    "token_number": "001"
}
```

### Complete Token
**Endpoint:** `POST /backend/api/complete_token.php`

**Request:**
```json
{
    "token_id": 1,
    "notes": "Treatment completed",
    "department_id": 1
}
```

**Response:**
```json
{
    "success": true,
    "message": "Token marked as completed"
}
```

### Miss Token
**Endpoint:** `POST /backend/api/miss_token.php`

**Request:**
```json
{
    "token_id": 1,
    "reason": "Patient didn't show up"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Token marked as missed"
}
```

---

## Assisted Booking APIs

### Create Assisted Booking
**Endpoint:** `POST /backend/api/create_assisted_booking.php`

**Request:**
```json
{
    "hospital_id": 12,
    "department_id": 1,
    "patient_name": "Ramesh Kumar",
    "patient_phone": "9803962360",
    "patient_age": 35,
    "patient_gender": "Male",
    "symptoms": "Fever and cough",
    "booking_date": "2026-02-13",
    "booking_time": "10:30",
    "priority": "Normal",
    "registered_by": 7,
    "notes": "Patient has diabetes"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Assisted booking created successfully",
    "booking": {
        "id": 45,
        "token_number": "TOKEN-001",
        "booking_id": "ASB-2026-001",
        "patient_name": "Ramesh Kumar",
        "phone": "9803962360",
        "department": "General Medicine",
        "booking_date": "2026-02-13",
        "booking_time": "10:30"
    }
}
```

### Get Assisted Bookings
**Endpoint:** `GET /backend/api/get_assisted_bookings.php`

**Query Parameters:**
- `hospital_id`: int (required)
- `date`: string (optional, format: YYYY-MM-DD)
- `status`: string (optional, e.g., "Pending")
- `limit`: int (default: 50)

**Response:**
```json
{
    "success": true,
    "bookings": [
        {
            "id": 45,
            "patient_name": "Ramesh Kumar",
            "patient_phone": "9803962360",
            "department_name": "General Medicine",
            "booking_date": "2026-02-13",
            "booking_time": "10:30",
            "priority": "Normal",
            "status": "Pending",
            "token_number": "TOKEN-001",
            "registered_by": "Admin Name",
            "created_at": "2026-02-12 12:00:00"
        }
    ]
}
```

### Update Assisted Booking
**Endpoint:** `PUT /backend/api/update_assisted_booking.php`

**Request:**
```json
{
    "booking_id": 45,
    "status": "Assigned",
    "token_number": "TOKEN-001",
    "notes": "Called to counter"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Booking updated successfully"
}
```

### Cancel Assisted Booking
**Endpoint:** `DELETE /backend/api/delete_assisted_booking.php`

**Request:**
```json
{
    "booking_id": 45,
    "reason": "Patient requested cancellation"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Booking cancelled successfully"
}
```

---

## Patient APIs

### Get Patient Profile
**Endpoint:** `GET /backend/api/get_patient_profile.php`

**Query Parameters:**
- `patient_id`: int (required)

**Response:**
```json
{
    "success": true,
    "patient": {
        "id": 1,
        "phone_number": "9803962360",
        "full_name": "Ramesh Kumar",
        "age": 35,
        "gender": "Male",
        "email": "ramesh@email.com",
        "blood_type": "O+",
        "allergies": "Penicillin",
        "chronic_diseases": ["Diabetes", "Hypertension"],
        "total_bookings": 6,
        "last_booking_date": "2026-02-10 10:30:00"
    }
}
```

### Get Patient Booking History
**Endpoint:** `GET /backend/api/get_patient_bookings.php`

**Query Parameters:**
- `patient_id`: int (required)
- `limit`: int (default: 20)

**Response:**
```json
{
    "success": true,
    "bookings": [
        {
            "id": 6,
            "hospital_name": "Bir Hospital",
            "department_name": "General Medicine",
            "booking_date": "2026-02-10",
            "status": "Completed",
            "doctor_name": "Dr. Anil Kumar",
            "diagnosis": "Routine Check-up",
            "rating": null
        }
    ]
}
```

---

## Hospital Settings APIs

### Get Hospital Settings
**Endpoint:** `GET /backend/api/get_hospital_settings.php`

**Query Parameters:**
- `hospital_id`: int (required)

**Response:**
```json
{
    "success": true,
    "settings": {
        "max_daily_tokens": "100",
        "assisted_booking_enabled": "1",
        "allow_walk_ins": "1",
        "sms_reminder_enabled": "1"
    }
}
```

### Update Hospital Settings
**Endpoint:** `POST /backend/api/update_hospital_settings.php`

**Request:**
```json
{
    "hospital_id": 12,
    "settings": {
        "max_daily_tokens": "120",
        "assisted_booking_enabled": "1",
        "allow_walk_ins": "0",
        "sms_reminder_enabled": "1"
    }
}
```

**Response:**
```json
{
    "success": true,
    "message": "Settings updated successfully"
}
```

---

## Error Responses

All error responses follow this format:

```json
{
    "success": false,
    "message": "Error description",
    "error_code": "ERROR_CODE"
}
```

### Common Error Codes:
- `INVALID_PARAMS`: Missing or invalid parameters
- `NOT_FOUND`: Resource not found
- `UNAUTHORIZED`: User not authorized
- `DATABASE_ERROR`: Database operation failed
- `VALIDATION_ERROR`: Data validation failed

---

## Rate Limiting

- No rate limiting for authorized requests
- Public endpoints limited to 100 requests/hour

---

## Versioning

Current API Version: **1.0**

All API endpoints are versioned. Future versions will use `/v2/`, `/v3/` etc.

---

## Examples

### Example 1: Complete Booking Flow
```bash
# 1. Create assisted booking
curl -X POST http://localhost/smarthealth_nepal/backend/api/create_assisted_booking.php \
  -H "Content-Type: application/json" \
  -d '{
    "hospital_id": 12,
    "department_id": 1,
    "patient_name": "Ramesh",
    "patient_phone": "9803962360",
    "booking_date": "2026-02-13",
    "booking_time": "10:00",
    "registered_by": 7
  }'

# 2. Get booking details
curl http://localhost/smarthealth_nepal/backend/api/get_assisted_bookings.php?hospital_id=12

# 3. Update booking status
curl -X PUT http://localhost/smarthealth_nepal/backend/api/update_assisted_booking.php \
  -H "Content-Type: application/json" \
  -d '{
    "booking_id": 45,
    "status": "Completed"
  }'
```

### Example 2: Token Management
```bash
# 1. Call next token
curl -X POST http://localhost/smarthealth_nepal/backend/api/call_token.php \
  -H "Content-Type: application/json" \
  -d '{
    "token_id": 1,
    "department_id": 1,
    "hospital_id": 12
  }'

# 2. Complete token
curl -X POST http://localhost/smarthealth_nepal/backend/api/complete_token.php \
  -H "Content-Type: application/json" \
  -d '{
    "token_id": 1,
    "notes": "Completed treatment"
  }'
```

---

## Support

For API support or questions, please refer to the main documentation or contact support.
