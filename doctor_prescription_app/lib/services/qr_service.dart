import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/patient.dart';
import '../models/prescription.dart';

class QRService {
  /// Generate QR data for patient
  static String generatePatientQRData(String patientId) {
    return jsonEncode({
      'type': 'patient',
      'patientId': patientId,
    });
  }

  /// Generate QR data for prescription (simple reference)
  static String generatePrescriptionQRData(
      String patientId, String prescriptionId) {
    return jsonEncode({
      'type': 'prescription',
      'patientId': patientId,
      'prescriptionId': prescriptionId,
    });
  }

  /// Generate FULL digital prescription QR with all details
  static String generateDigitalPrescriptionQR({
    required Patient patient,
    required Prescription prescription,
  }) {
    final data = {
      'type': 'digital_prescription',
      'version': '1.0',
      'prescriptionId': prescription.id,
      'createdAt': prescription.createdAt.toIso8601String(),
      'patient': {
        'id': patient.id,
        'name': patient.name,
        'age': patient.age,
        'gender': patient.gender,
        'phone': patient.phone,
      },
      'medicines': prescription.medicines
          .map((m) => {
                'name': m.name,
                'dosage': m.dosage,
                'timing': m.timing,
                'days': m.days,
              })
          .toList(),
      'notes': prescription.notes,
      'status': prescription.status,
    };
    return jsonEncode(data);
  }

  /// Parse QR data
  static Map<String, dynamic>? parseQRData(String data) {
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      // Try simple pipe-separated format
      if (data.contains('|')) {
        final parts = data.split('|');
        if (parts.length == 2) {
          return {
            'type': 'prescription',
            'patientId': parts[0],
            'prescriptionId': parts[1],
          };
        }
      }
      // Try patient ID only
      if (data.startsWith('PT-')) {
        return {
          'type': 'patient',
          'patientId': data,
        };
      }
      return null;
    }
  }

  /// Build QR code widget
  static Widget buildQRCode({
    required String data,
    double size = 200,
    Color backgroundColor = Colors.white,
    Color foregroundColor = Colors.black,
  }) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: foregroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: foregroundColor,
      ),
    );
  }
}
