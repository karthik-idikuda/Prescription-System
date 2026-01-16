# Shop Doctor - Prescription System

## Overview
Shop Doctor is a digital pharmacy and prescription management system designed to bridge the gap between doctors, pharmacists, and patients. It facilitates digital prescription issuance, inventory management for pharmacies, and easy medication ordering for patients.

## Features
-   **Digital Prescriptions**: Doctors can generate secure, legally compliant e-prescriptions.
-   **Inventory Tracking**: Real-time stock management for pharmacy owners.
-   **Order Processing**: Patients can upload prescriptions and order medicines.
-   **History Log**: Secure records of past medications and treatments.
-   **Notifications**: SMS/Email alerts for order status and refill reminders.

## Technology Stack
-   **Frontend**: React / Vue.js.
-   **Backend**: Django / Express.
-   **Database**: PostgreSQL.
-   **Security**: HIPAA-compliant data handling.

## Usage Flow
1.  **Prescribe**: Doctor creates a digital prescription for a patient.
2.  **Receive**: Patient receives the prescription link/code.
3.  **Order**: Patient forwards the prescription to a participating pharmacy.
4.  **Fulfill**: Pharmacist validates the Rx and dispenses the medication.

## Quick Start
```bash
# Clone the repository
git clone https://github.com/Nytrynox/Prescription-System.git

# Setup backend
cd backend
pip install -r requirements.txt
python manage.py runserver

# Setup frontend
cd frontend
npm install
npm start
```

## License
MIT License

## Author
**Karthik Idikuda**
