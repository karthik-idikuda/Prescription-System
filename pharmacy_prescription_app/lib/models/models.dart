import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String? photoUrl;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.photoUrl,
    required this.createdAt,
  });

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class PrescriptionMedicine {
  final String name;
  final String dosage;
  final String timing;
  final int days;

  PrescriptionMedicine({
    required this.name,
    required this.dosage,
    required this.timing,
    required this.days,
  });

  factory PrescriptionMedicine.fromMap(Map<String, dynamic> map) {
    return PrescriptionMedicine(
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      timing: map['timing'] ?? '',
      days: map['days'] ?? 0,
    );
  }
}

class Prescription {
  final String id;
  final String patientId;
  final List<PrescriptionMedicine> medicines;
  final String? notes;
  final String qrCode;
  final DateTime createdAt;
  final String status; // pending, given, partially_given
  final String? pharmacistNote;

  Prescription({
    required this.id,
    required this.patientId,
    required this.medicines,
    this.notes,
    required this.qrCode,
    required this.createdAt,
    this.status = 'pending',
    this.pharmacistNote,
  });

  factory Prescription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final medicinesList = (data['medicines'] as List<dynamic>?)
            ?.map((m) => PrescriptionMedicine.fromMap(m as Map<String, dynamic>))
            .toList() ??
        [];
    
    return Prescription(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      medicines: medicinesList,
      notes: data['notes'],
      qrCode: data['qrCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
      pharmacistNote: data['pharmacistNote'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isGiven => status == 'given';
  bool get isPartiallyGiven => status == 'partially_given';
}

class PharmacyAlert {
  final String id;
  final String message;
  final DateTime sentAt;
  final bool isRead;

  PharmacyAlert({
    required this.id,
    required this.message,
    required this.sentAt,
    required this.isRead,
  });

  factory PharmacyAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PharmacyAlert(
      id: doc.id,
      message: data['message'] ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
