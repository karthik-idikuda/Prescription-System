import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class PharmacyDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections (same as Doctor App - shared database)
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _patients => _firestore.collection('patients');
  CollectionReference get _prescriptions => _firestore.collection('prescriptions');
  CollectionReference get _alerts => _firestore.collection('alerts');
  CollectionReference get _pharmacyAlerts => _firestore.collection('pharmacy_alerts');

  // ==================== USER MANAGEMENT ====================

  /// Create pharmacist user
  Future<void> createPharmacist({
    required String userId,
    required String name,
    required String phone,
    String? clinicId,
  }) async {
    await _users.doc(userId).set({
      'userId': userId,
      'name': name,
      'phone': phone,
      'role': 'pharmacist',
      'clinicId': clinicId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ==================== PRESCRIPTION OPERATIONS ====================

  /// Get all pending prescriptions (real-time)
  Stream<List<Prescription>> getPendingPrescriptions() {
    return _prescriptions
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Prescription.fromFirestore(doc)).toList());
  }

  /// Get all prescriptions (real-time)
  Stream<List<Prescription>> getAllPrescriptions() {
    return _prescriptions
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Prescription.fromFirestore(doc)).toList());
  }

  /// Get prescription by ID
  Future<Prescription?> getPrescription(String prescriptionId) async {
    final doc = await _prescriptions.doc(prescriptionId).get();
    if (doc.exists) {
      return Prescription.fromFirestore(doc);
    }
    return null;
  }

  /// Get prescription by QR code data (patientId|prescriptionId)
  Future<Prescription?> getPrescriptionByQR(String qrData) async {
    String? prescriptionId;

    if (qrData.contains('|')) {
      final parts = qrData.split('|');
      if (parts.length >= 2) {
        prescriptionId = parts[1];
      }
    } else if (qrData.startsWith('RX-')) {
      prescriptionId = qrData;
    }

    if (prescriptionId != null) {
      return await getPrescription(prescriptionId);
    }
    return null;
  }

  /// Update prescription status
  Future<void> updatePrescriptionStatus({
    required String prescriptionId,
    required String status, // 'pending', 'completed', 'partially_given'
    String? pharmacistNote,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (pharmacistNote != null) {
      updates['pharmacistNote'] = pharmacistNote;
    }

    await _prescriptions.doc(prescriptionId).update(updates);
  }

  /// Mark prescription as given (completed)
  Future<void> markAsGiven(String prescriptionId, {String? note}) async {
    await updatePrescriptionStatus(
      prescriptionId: prescriptionId,
      status: 'completed',
      pharmacistNote: note,
    );
  }

  /// Mark prescription as partially given
  Future<void> markAsPartiallyGiven(String prescriptionId, {String? note}) async {
    await updatePrescriptionStatus(
      prescriptionId: prescriptionId,
      status: 'partially_given',
      pharmacistNote: note,
    );
  }

  // ==================== PATIENT OPERATIONS ====================

  /// Get patient by ID
  Future<Patient?> getPatient(String patientId) async {
    final doc = await _patients.doc(patientId).get();
    if (doc.exists) {
      return Patient.fromFirestore(doc);
    }
    return null;
  }

  /// Get patient prescriptions
  Stream<List<Prescription>> getPatientPrescriptions(String patientId) {
    return _prescriptions
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Prescription.fromFirestore(doc)).toList());
  }

  // ==================== ALERT OPERATIONS ====================

  /// Get unread alerts (real-time) - from new alerts collection
  Stream<List<PharmacyAlert>> getUnreadAlerts() {
    return _alerts
        .where('read', isEqualTo: false)
        .where('type', isEqualTo: 'bell')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return PharmacyAlert(
                id: doc.id,
                message: data['message'] ?? '',
                sentAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                isRead: data['read'] ?? false,
              );
            }).toList());
  }

  /// Get legacy pharmacy alerts
  Stream<List<PharmacyAlert>> getLegacyAlerts() {
    return _pharmacyAlerts
        .where('isRead', isEqualTo: false)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PharmacyAlert.fromFirestore(doc)).toList());
  }

  /// Mark alert as read
  Future<void> markAlertAsRead(String alertId) async {
    // Try new alerts collection first
    try {
      await _alerts.doc(alertId).update({
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Fall back to legacy
      await _pharmacyAlerts.doc(alertId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Mark all alerts as read
  Future<void> markAllAlertsAsRead() async {
    // New alerts
    final unread = await _alerts.where('read', isEqualTo: false).get();
    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true, 'readAt': FieldValue.serverTimestamp()});
    }

    // Legacy alerts
    final legacyUnread = await _pharmacyAlerts.where('isRead', isEqualTo: false).get();
    for (final doc in legacyUnread.docs) {
      batch.update(doc.reference, {'isRead': true, 'readAt': FieldValue.serverTimestamp()});
    }

    await batch.commit();
  }
}
