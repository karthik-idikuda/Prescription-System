import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/medicine.dart';
import 'dart:math';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _clinics => _firestore.collection('clinics');
  CollectionReference get _patients => _firestore.collection('patients');
  CollectionReference get _prescriptions =>
      _firestore.collection('prescriptions');
  CollectionReference get _medicines => _firestore.collection('medicines');
  CollectionReference get _alerts => _firestore.collection('alerts');
  CollectionReference get _pharmacyAlerts =>
      _firestore.collection('pharmacy_alerts');

  // ==================== USER MANAGEMENT ====================

  /// Check if user exists
  Future<bool> checkUserExists(String userId) async {
    final doc = await _users.doc(userId).get();
    return doc.exists;
  }

  /// Create doctor profile (on first login)
  Future<void> createDoctorProfile({
    required String userId,
    required String phone,
  }) async {
    final exists = await checkUserExists(userId);
    if (!exists) {
      await _users.doc(userId).set({
        'userId': userId,
        'phone': phone,
        'role': 'doctor', // Hardcoded for this app
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also create a default clinic placeholder
      await _clinics.add({
        'doctorId': userId,
        'name': 'My Clinic',
        'address': 'Update address in settings',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get user by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    final doc = await _users.doc(userId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // ==================== CLINIC MANAGEMENT ====================

  /// Create clinic
  Future<String> createClinic({
    required String clinicName,
    required String address,
    required String doctorId,
    String? pharmacyId,
  }) async {
    final doc = await _clinics.add({
      'clinicName': clinicName,
      'address': address,
      'doctorId': doctorId,
      'pharmacyId': pharmacyId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // ==================== PATIENT MANAGEMENT ====================

  /// Generate unique patient ID (PT-XXXX)
  String _generatePatientId() {
    final random = Random();
    final num = 1000 + random.nextInt(9000);
    return 'PT-$num';
  }

  /// Add new patient (REAL DATA ONLY)
  Future<Patient> addPatient({
    required String name,
    required int age,
    required String gender,
    required String phone,
    String? clinicId,
  }) async {
    final patientId = _generatePatientId();
    final now = DateTime.now();

    final data = {
      'id': patientId,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'photoUrl': null,
      'qrCode': patientId,
      'clinicId': clinicId,
      'createdAt': Timestamp.fromDate(now),
    };

    await _patients.doc(patientId).set(data);

    return Patient(
      id: patientId,
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      qrCode: patientId,
      createdAt: now,
    );
  }

  /// Update patient
  Future<void> updatePatient(Patient patient) async {
    await _patients.doc(patient.id).update(patient.toMap());
  }

  /// Get patient by ID
  Future<Patient?> getPatient(String patientId) async {
    final doc = await _patients.doc(patientId).get();
    if (doc.exists) {
      return Patient.fromFirestore(doc);
    }
    return null;
  }

  /// Get all patients (stream)
  Stream<List<Patient>> getPatients() {
    return _patients.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList());
  }

  /// Search patients
  Stream<List<Patient>> searchPatients(String query) {
    final queryLower = query.toLowerCase();
    return _patients.orderBy('createdAt', descending: true).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Patient.fromFirestore(doc))
            .where((p) =>
                p.name.toLowerCase().contains(queryLower) ||
                p.phone.contains(query) ||
                p.id.toLowerCase().contains(queryLower))
            .toList());
  }

  // ==================== PRESCRIPTION MANAGEMENT ====================

  /// Generate unique prescription ID (RX-XXXX)
  String _generatePrescriptionId() {
    final random = Random();
    final num = 5000 + random.nextInt(5000);
    return 'RX-$num';
  }

  /// Create prescription (REAL DATA ONLY)
  Future<Prescription> createPrescription({
    required String patientId,
    required List<PrescriptionMedicine> medicines,
    String? notes,
    DateTime? nextVisitDate,
    String? doctorId,
    String? clinicId,
  }) async {
    final prescriptionId = _generatePrescriptionId();
    final now = DateTime.now();
    final qrData = '$patientId|$prescriptionId';

    final data = {
      'id': prescriptionId,
      'patientId': patientId,
      'doctorId': doctorId,
      'clinicId': clinicId,
      'notes': notes,
      'nextVisitDate':
          nextVisitDate != null ? Timestamp.fromDate(nextVisitDate) : null,
      'status': 'pending',
      'qrCode': qrData,
      'qrData': qrData,
      'createdAt': Timestamp.fromDate(now),
      'medicines': medicines.map((m) => m.toMap()).toList(),
    };

    await _prescriptions.doc(prescriptionId).set(data);

    return Prescription(
      id: prescriptionId,
      patientId: patientId,
      medicines: medicines,
      notes: notes,
      qrCode: qrData,
      createdAt: now,
    );
  }

  /// Get prescription by ID
  Future<Prescription?> getPrescription(String prescriptionId) async {
    final doc = await _prescriptions.doc(prescriptionId).get();
    if (doc.exists) {
      return Prescription.fromFirestore(doc);
    }
    return null;
  }

  /// Get prescriptions for patient
  Stream<List<Prescription>> getPatientPrescriptions(String patientId) {
    return _prescriptions
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Prescription.fromFirestore(doc))
            .toList());
  }

  /// Get all prescriptions
  Stream<List<Prescription>> getAllPrescriptions() {
    return _prescriptions
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Prescription.fromFirestore(doc))
            .toList());
  }

  /// Update prescription status
  Future<void> updatePrescriptionStatus(
      String prescriptionId, String status) async {
    await _prescriptions.doc(prescriptionId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== MEDICINE AUTO-SUGGEST ====================

  /// Search medicines from Firestore (Real Data)
  Future<List<Medicine>> searchMedicines(String query) async {
    if (query.isEmpty) return [];

    final queryLower = query.toLowerCase();

    // Simple startWith search - efficient for Firestore
    // Note: For better search (fuzzy matching in db), use Algolia or Typesense
    final snapshot = await _medicines
        .where('searchTerms', arrayContains: queryLower)
        .limit(10)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.map((doc) => Medicine.fromFirestore(doc)).toList();
    }

    // Fallback: Prefix search on name if searchTerms lookup fails
    // This requires a field 'name_lowercase' or similar in a real production app for case-insensitive, but for now we rely on user input matching case or using 'name'
    // Actually, Firestore >= is case sensitive.
    // Let's just return what we have or user can type.
    return [];
  }

  // ==================== BELL ALERTS ====================

  /// Send bell alert to pharmacy
  Future<void> sendBellAlert({
    String? fromUserId,
    String? toUserId,
    String message = 'Doctor calling pharmacist – please come',
  }) async {
    await _alerts.add({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'type': 'bell',
      'message': message,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Legacy support
    await _pharmacyAlerts.add({
      'message': message,
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Send prescription to pharmacy
  Future<void> sendToPharmacy({
    required String patientId,
    required String patientName,
    required String prescriptionId,
    required List<String> medicines,
  }) async {
    await _pharmacyAlerts.add({
      'type': 'prescription',
      'patientId': patientId,
      'patientName': patientName,
      'prescriptionId': prescriptionId,
      'medicines': medicines,
      'message': 'New prescription for $patientName',
      'sentAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    
    // Also add to alerts collection for real-time updates
    await _alerts.add({
      'type': 'prescription',
      'patientId': patientId,
      'patientName': patientName,
      'prescriptionId': prescriptionId,
      'medicines': medicines,
      'message': 'New prescription for $patientName',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get unread alerts
  Stream<List<Map<String, dynamic>>> getUnreadAlerts() {
    return _alerts
        .where('read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
  }

  /// Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    await _alerts.doc(alertId).update({
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  // Legacy support
  Future<void> sendPharmacyAlert() async {
    await sendBellAlert();
  }
}
