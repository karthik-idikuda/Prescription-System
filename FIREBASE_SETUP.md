# 🔥 Firebase Setup Guide

## Step 0: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Create Project**
3. Project name: `clinic-pharmacy-system`
4. **Disable** Google Analytics (not needed)
5. Click **Create project**

---

## Step 1: Enable Firebase Services

### 1.1 Enable Authentication
1. Go to **Authentication** → **Get Started**
2. Click **Sign-in method**
3. Enable **Phone** authentication
4. Save

### 1.2 Enable Firestore
1. Go to **Firestore Database**
2. Click **Create database**
3. Select **Production mode**
4. Choose location: **asia-south1 (Mumbai)**
5. Click **Create**

### 1.3 Enable Storage
1. Go to **Storage**
2. Click **Get Started**
3. Select **Production mode**
4. Same region as Firestore
5. Click **Done**

---

## Step 2: Add Apps to Firebase

### Add Doctor App
1. Click **⚙️ Project Settings**
2. Click **Add app** → **Android**
3. Package name: `com.clinic.doctor_prescription_app`
4. App nickname: `Doctor App`
5. Download `google-services.json`
6. Place in: `doctor_prescription_app/android/app/`

### Add Pharmacy App
1. Click **Add app** → **Android**
2. Package name: `com.clinic.pharmacy_prescription_app`
3. App nickname: `Pharmacy App`
4. Download `google-services.json`
5. Place in: `pharmacy_prescription_app/android/app/`

---

## Step 3: Deploy Security Rules

### Firestore Rules
1. Go to **Firestore Database** → **Rules**
2. Copy content from `firebase/firestore.rules`
3. Paste and click **Publish**

### Storage Rules
1. Go to **Storage** → **Rules**
2. Copy content from `firebase/storage.rules`
3. Paste and click **Publish**

---

## Database Structure (Auto-Created)

Collections are created automatically when first data is written:

```
Firestore Collections:
├── users/              # Doctor & Pharmacist profiles
├── clinics/            # Clinic information
├── patients/           # Patient records
├── prescriptions/      # Prescription data
├── medicines/          # Medicine master list
└── alerts/             # Bell button alerts

Storage Structure:
├── patients/{patientId}/photo.jpg
└── prescriptions/{prescriptionId}/qr.png
```

---

## Data Flow (Real Life Only)

```
1. Doctor logs in → users document created
2. Doctor adds patient → patients document created
3. Doctor writes prescription → prescriptions created
4. QR generated → image stored in Storage
5. Pharmacy scans QR → reads Firestore
6. Bell pressed → alerts document created
```

---

## Important Notes

❌ **Do NOT create sample/test data**
❌ **Do NOT seed fake prescriptions**
❌ **Do NOT upload fake photos**

✅ **Only real patients during actual clinic use**
✅ **Firebase auto-creates collections on first write**
✅ **No data exists until real usage starts**

---

## Quick Commands

```bash
# Doctor App
cd doctor_prescription_app
flutter pub get
flutter run

# Pharmacy App
cd pharmacy_prescription_app
flutter pub get
flutter run
```

---

## Security Summary

| Role | Can Do |
|------|--------|
| Doctor | Create patients, write prescriptions, send alerts |
| Pharmacist | Read prescriptions, update status, receive alerts |
| Both | Read patient data, view prescription history |
| Public | No access |
