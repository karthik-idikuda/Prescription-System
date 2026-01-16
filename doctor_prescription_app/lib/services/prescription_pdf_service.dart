import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/prescription.dart';
import '../models/patient.dart';

class PrescriptionPdfService {
  /// Generate prescription PDF
  static Future<Uint8List> generatePdf({
    required Prescription prescription,
    required Patient patient,
    String? doctorName,
    String? clinicName,
    String? clinicAddress,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        clinicName ?? 'Doctor Clinic',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo,
                        ),
                      ),
                      if (clinicAddress != null)
                        pw.Text(
                          clinicAddress,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.indigo, width: 2),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'Rx',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 20),

              // Patient Info
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PATIENT',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          patient.name,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '${patient.age} years • ${patient.gender}',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'DATE',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          dateFormat.format(prescription.createdAt),
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'ID: ${prescription.id}',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Medicines Header
              pw.Text(
                'MEDICINES',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 12),

              // Medicines List
              ...prescription.medicines.asMap().entries.map((entry) {
                final index = entry.key;
                final med = entry.value;
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 12),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 28,
                        height: 28,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.indigo,
                          borderRadius: pw.BorderRadius.circular(14),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            '${index + 1}',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              med.name,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '${med.dosage} • ${med.timing} • ${med.days} days',
                              style: const pw.TextStyle(
                                fontSize: 11,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Notes
              if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text(
                  'NOTES',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber50,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Text(prescription.notes!),
                ),
              ],

              pw.Spacer(),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        doctorName ?? 'Doctor',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Medical Practitioner',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Generated by Doctor App',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey500,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Print prescription
  static Future<void> printPrescription({
    required Prescription prescription,
    required Patient patient,
  }) async {
    final pdfData = await generatePdf(
      prescription: prescription,
      patient: patient,
    );

    await Printing.layoutPdf(
      onLayout: (_) => pdfData,
      name: 'Prescription_${prescription.id}',
    );
  }

  /// Share prescription as PDF
  static Future<void> sharePdf({
    required Prescription prescription,
    required Patient patient,
  }) async {
    final pdfData = await generatePdf(
      prescription: prescription,
      patient: patient,
    );

    await Printing.sharePdf(
      bytes: pdfData,
      filename: 'Prescription_${prescription.id}.pdf',
    );
  }

  /// Share via WhatsApp
  static Future<void> shareViaWhatsApp({
    required Prescription prescription,
    required Patient patient,
    String? phoneNumber,
  }) async {
    final medicines = prescription.medicines
        .map((m) => '• ${m.name} - ${m.dosage}, ${m.timing}, ${m.days} days')
        .join('\n');

    final message = '''
🏥 *Prescription*
Date: ${DateFormat('dd MMM yyyy').format(prescription.createdAt)}
ID: ${prescription.id}

👤 *Patient:* ${patient.name}
Age: ${patient.age} years

💊 *Medicines:*
$medicines

${prescription.notes != null ? '📝 Notes: ${prescription.notes}' : ''}

_Sent from Doctor App_
''';

    final encodedMessage = Uri.encodeComponent(message);
    final phone = phoneNumber?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    
    final whatsappUrl = phone.isNotEmpty
        ? 'https://wa.me/$phone?text=$encodedMessage'
        : 'https://wa.me/?text=$encodedMessage';

    final uri = Uri.parse(whatsappUrl);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to share dialog
      await Share.share(message);
    }
  }
}
