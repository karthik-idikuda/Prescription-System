# 💊 Pharmacy Prescription App

A Flutter Android app for pharmacies to receive prescriptions from the Doctor App.

## ✨ Features

### 🔐 Simple Login
- PIN-based authentication (4 digits)
- Default PIN: `1234`
- No complex passwords

### 📋 Prescription Management
- Real-time incoming prescriptions
- View patient photo, name, ID
- See all medicines with dosage & timing
- Mark as "Given" or "Partially Given"
- Add pharmacist notes

### 📱 QR Code Scanner
- Scan QR from patient's phone
- Scan QR from printed slip
- Instant prescription lookup
- Camera with torch support

### 🔔 Doctor Alert (Bell Button)
- Receive alerts when doctor calls
- Popup notification: "Doctor is calling you"
- Vibration alert
- One-tap acknowledgment

### 👤 Patient View
- View patient details (read-only)
- See prescription history
- Quick patient search by ID

## 🚀 Setup

### Prerequisites
- Flutter SDK 3.0+
- Same Firebase project as Doctor App

### 1. Install Dependencies

```bash
cd pharmacy_prescription_app
flutter pub get
```

### 2. Firebase Setup

Use the **same Firebase project** as Doctor App.

1. Add Android app with package: `com.clinic.pharmacy_prescription_app`
2. Download `google-services.json`
3. Place in `android/app/google-services.json`

### 3. Run the App

```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry + auth provider
├── models/
│   └── models.dart              # Patient, Prescription, Alert
├── services/
│   ├── pharmacy_database_service.dart   # Firestore operations
│   └── notification_service.dart        # FCM + vibration
└── screens/
    ├── login_screen.dart        # PIN login
    ├── home_screen.dart         # Dashboard
    ├── prescription_list_screen.dart    # All prescriptions
    ├── prescription_detail_screen.dart  # View + actions
    ├── scan_qr_screen.dart      # QR scanner
    └── patient_view_screen.dart # Patient details
```

## 🔗 Connection with Doctor App

Both apps use the **same Firebase database**:

```
Firestore Collections (shared):
├── patients/          # Patient records
├── prescriptions/     # Prescription data
└── pharmacy_alerts/   # Bell button alerts
```

### Data Flow

```
Doctor App → Firestore → Pharmacy App
     ↓                        ↓
  Writes              Reads + Updates
```

## 📱 Screens

| Screen | Purpose |
|--------|---------|
| Login | PIN-based authentication |
| Home | Dashboard with pending count |
| Prescription List | All/pending prescriptions |
| Prescription Detail | View + mark as given |
| Scan QR | Quick prescription lookup |
| Patient View | Patient details + history |

## 🔔 Bell Notification Flow

1. Doctor presses 🔔 in Doctor App
2. Alert saved to `pharmacy_alerts` collection
3. Pharmacy App receives real-time update
4. Popup + vibration on pharmacist's phone
5. Pharmacist taps "Got it!" to acknowledge

## 🎨 Theme

- **Color**: Green (#2E7D32) - Pharmacy theme
- **Design**: Big buttons, minimal text
- **UX**: Optimized for one-hand phone use

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| firebase_core | Firebase initialization |
| cloud_firestore | Real-time database |
| firebase_messaging | Push notifications |
| mobile_scanner | QR code scanning |
| provider | State management |
| vibration | Alert feedback |
| google_fonts | Typography |

## 🔒 Security Notes

- PIN is currently hardcoded (1234) for demo
- Production: Validate PIN against backend
- No patient data is modified, only read
- Prescription status updates are logged

---

**Part of Clinic-Pharmacy Ecosystem**

📱 Doctor App → 💊 Pharmacy App → 📲 Patient WhatsApp
