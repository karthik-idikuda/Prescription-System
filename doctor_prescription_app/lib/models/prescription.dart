import 'package:cloud_firestore/cloud_firestore.dart';

class PrescriptionMedicine {
  final String name;
  final String dosage;
  final String timing;
  final int days;

  const PrescriptionMedicine({
    required this.name,
    required this.dosage,
    required this.timing,
    required this.days,
  });

  factory PrescriptionMedicine.fromMap(Map<String, dynamic> map) {
    return PrescriptionMedicine(
      name: (map['name'] ?? map['medicineName'] ?? '').toString(),
      dosage: (map['dosage'] ?? '').toString(),
      timing: (map['timing'] ?? '').toString(),
      days: (map['days'] is int) ? map['days'] as int : int.tryParse('${map['days']}') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'timing': timing,
      'days': days,
    };
  }
}

class Prescription {
  final String id;
  final String patientId;
  final List<PrescriptionMedicine> medicines;
  final String? notes;
  final String qrCode;
  final DateTime createdAt;
  final String status;
  final DateTime? nextVisitDate;
  final String? pharmacistNote;

  const Prescription({
    required this.id,
    required this.patientId,
    required this.medicines,
    this.notes,
    required this.qrCode,
    required this.createdAt,
    this.status = 'pending',
    this.nextVisitDate,
    this.pharmacistNote,
  });

  factory Prescription.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final medicinesList = (data['medicines'] as List<dynamic>?)
            ?.map((m) => PrescriptionMedicine.fromMap(m as Map<String, dynamic>))
            .toList() ??
        const <PrescriptionMedicine>[];

    return Prescription(
      id: doc.id,
      patientId: (data['patientId'] ?? '').toString(),
      medicines: medicinesList,
      notes: data['notes']?.toString(),
      qrCode: (data['qrCode'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: (data['status'] ?? 'pending').toString(),
      nextVisitDate: (data['nextVisitDate'] as Timestamp?)?.toDate(),
      pharmacistNote: data['pharmacistNote']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'medicines': medicines.map((m) => m.toMap()).toList(),
      'notes': notes,
      'qrCode': qrCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'nextVisitDate': nextVisitDate != null ? Timestamp.fromDate(nextVisitDate!) : null,
      'pharmacistNote': pharmacistNote,
    };
  }
}
