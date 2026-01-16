# 🏥 Doctor Prescription App

A Flutter Android app for doctors in small clinics to manage patients, create prescriptions with QR codes, and communicate with pharmacists.

## ✨ Features

### 👤 Patient Management
- Add new patients with name, age, gender, phone number
- Capture patient photo using phone camera
- Auto-generated unique patient ID (PT-1023 format)
- QR code for each patient
- Search patients by name, phone, or ID

### 💊 Prescription Creation
- Medicine auto-suggest with spelling correction (50+ common medicines)
- Visual dosage selector (1-0-1, 1-1-1, etc.)
- Timing selector (Before/After/With food)
- Duration selector (days)
- Optional notes

### 📱 QR Code Integration
- Each prescription includes patient photo, IDs, and QR code
- QR contains: `patientId|prescriptionId`
- Scannable by pharmacy app

### 🔔 Bell Button (Pharmacy Alert)
- One-tap alert to pharmacy
- Message: "Doctor calling pharmacist – please come"
- Push notification via Firebase Cloud Messaging

### 📜 History
- Patient visit history
- Past prescriptions with dates and QR codes

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK 3.0+
- Android Studio / VS Code with Flutter extension
- Firebase account

### 1. Clone & Install Dependencies

```bash
cd doctor_prescription_app
flutter pub get
```

### 2. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add Android app with package name: `com.clinic.doctor_prescription_app`
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`

### 3. Enable Firebase Services

In Firebase Console, enable:
- **Firestore Database** (Start in test mode)
- **Storage** (Start in test mode)
- **Cloud Messaging**

### 4. Deploy Cloud Functions (Optional - for notifications)

```bash
cd firebase
npm install -g firebase-tools
firebase login
firebase init functions
cd functions && npm install
firebase deploy --only functions
```

### 5. Run the App

```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── patient.dart            # Patient model
│   ├── prescription.dart       # Prescription model
│   └── medicine.dart           # Medicine model (50+ pre-populated)
├── services/
│   ├── database_service.dart   # Firestore CRUD operations
│   ├── storage_service.dart    # Photo upload
│   ├── notification_service.dart # FCM setup
│   └── qr_service.dart         # QR generation/parsing
├── screens/
│   ├── home_screen.dart        # Dashboard
│   ├── add_patient_screen.dart # New patient form
│   ├── patient_list_screen.dart # Patient list with search
│   ├── patient_detail_screen.dart # Patient profile + prescriptions
│   ├── create_prescription_screen.dart # New prescription
│   ├── prescription_view_screen.dart # View with QR
│   └── history_screen.dart     # All prescriptions
└── widgets/
    ├── medicine_autocomplete.dart # Fuzzy search input
    ├── dosage_selector.dart    # 1-0-1 selector
    ├── timing_selector.dart    # Before/After food
    └── bell_button.dart        # Pharmacy alert
```

## 🗃️ Database Schema (Firestore)

### patients/
```json
{
  "id": "PT-1023",
  "name": "John Doe",
  "age": 35,
  "gender": "Male",
  "phone": "9876543210",
  "photoUrl": "https://...",
  "qrCode": "PT-1023",
  "createdAt": "2024-01-01T10:00:00Z"
}
```

### prescriptions/
```json
{
  "id": "RX-5001",
  "patientId": "PT-1023",
  "medicines": [
    {
      "name": "Paracetamol 500mg",
      "dosage": "1-0-1",
      "timing": "After Food",
      "days": 5
    }
  ],
  "notes": "Drink plenty of water",
  "qrCode": "PT-1023|RX-5001",
  "createdAt": "2024-01-01T10:30:00Z"
}
```

### medicines/
```json
{
  "id": "med_001",
  "name": "Paracetamol 500mg",
  "searchTerms": ["paracetamol", "parcetamol", "dolo"],
  "category": "Analgesic"
}
```

## 🔐 Security (Production)

Update `firebase/firestore.rules` to require authentication:

```javascript
match /patients/{patientId} {
  allow read, write: if request.auth != null;
}
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| firebase_core | Firebase initialization |
| cloud_firestore | Database |
| firebase_storage | Photo storage |
| firebase_messaging | Push notifications |
| qr_flutter | QR code generation |
| mobile_scanner | QR scanning |
| image_picker | Camera/gallery |
| provider | State management |
| google_fonts | Typography |

## 📱 Screenshots

The app features:
- Clean, medical-themed blue UI
- Large, thumb-friendly buttons
- Minimal typing with smart selectors
- Visual dosage and timing pickers

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Open Pull Request

## 📄 License

MIT License - Free for personal and commercial use.

---

Built with ❤️ using Flutter
