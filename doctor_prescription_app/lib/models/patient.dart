import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String? photoUrl;
  final String qrCode;
  final DateTime createdAt;
  final String? allergies;
  final String? bloodGroup;
  final bool photoConsent;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    this.photoUrl,
    required this.qrCode,
    required this.createdAt,
    this.allergies,
    this.bloodGroup,
    this.photoConsent = false,
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
      qrCode: data['qrCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      allergies: data['allergies'],
      bloodGroup: data['bloodGroup'],
      photoConsent: data['photoConsent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'photoUrl': photoUrl,
      'qrCode': qrCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'allergies': allergies,
      'bloodGroup': bloodGroup,
      'photoConsent': photoConsent,
    };
  }

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? photoUrl,
    String? qrCode,
    DateTime? createdAt,
    String? allergies,
    String? bloodGroup,
    bool? photoConsent,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
      allergies: allergies ?? this.allergies,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoConsent: photoConsent ?? this.photoConsent,
    );
  }
}
