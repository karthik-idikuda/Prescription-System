import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/patient.dart';
import '../models/prescription.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/bell_button.dart';
import 'create_prescription_screen.dart';
import 'prescription_qr_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  final bool requirePhotoOnOpen;

  const PatientDetailScreen({
    super.key,
    required this.patient,
    this.requirePhotoOnOpen = false,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Patient _patient;
  bool _isUploadingPhoto = false;
  bool _hasShownMandatoryPrompt = false;

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (!widget.requirePhotoOnOpen) return;
      if ((_patient.photoUrl ?? '').trim().isNotEmpty) return;
      _showMandatoryPhotoPrompt();
    });
  }

  Future<void> _showMandatoryPhotoPrompt() async {
    if (_hasShownMandatoryPrompt) return;
    _hasShownMandatoryPrompt = true;

    while (mounted && (_patient.photoUrl ?? '').trim().isEmpty) {
      final shouldCapture = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Photo Required'),
          content:
              const Text('Please capture a photo of the patient to continue.'),
          actions: [
            FilledButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
          ],
        ),
      );

      if (shouldCapture != true) continue;

      final captured = await _captureAndUploadPhoto();
      if (!captured && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo is required for new patient.')),
        );
      }
    }
  }

  Future<bool> _captureAndUploadPhoto() async {
    if (_isUploadingPhoto) return false;
    setState(() => _isUploadingPhoto = true);

    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1080,
      );

      if (file == null) return false;
      if (!context.mounted) return false;

      final storage = StorageService();
      final db = context.read<DatabaseService>();

      final url = await storage.uploadPatientPhoto(_patient.id, file);
      final updated = _patient.copyWith(photoUrl: url);
      await db.updatePatient(updated);

      if (!context.mounted) return false;
      setState(() => _patient = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo updated')),
      );
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_patient.name),
        actions: const [
          BellButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Patient info card
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _captureAndUploadPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: _patient.photoUrl != null
                            ? NetworkImage(_patient.photoUrl!)
                            : null,
                        child: _patient.photoUrl == null
                            ? Text(
                                _patient.name.isNotEmpty
                                    ? _patient.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      if (_isUploadingPhoto)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patient.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_patient.phone} • ${_patient.age}y ${_patient.gender}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prescriptions',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _createPrescription(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                ),
              ],
            ),
          ),

          // Prescriptions list
          Expanded(
            child: StreamBuilder<List<Prescription>>(
              stream: db.getPatientPrescriptions(_patient.id),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading prescriptions',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final prescriptions = snapshot.data!;

                if (prescriptions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No prescriptions yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: prescriptions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final rx = prescriptions[index];
                    return _PrescriptionTile(
                      prescription: rx,
                      patient: _patient,
                      onTap: () => _openQR(rx),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createPrescription(context),
        icon: const Icon(Icons.add),
        label: const Text('Prescription'),
      ),
    );
  }

  Future<void> _createPrescription(BuildContext context) async {
    final result = await Navigator.of(context).push<Prescription>(
      MaterialPageRoute(
        builder: (_) => CreatePrescriptionScreen(patient: _patient),
      ),
    );

    if (result != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PrescriptionQrScreen(
            prescription: result,
            patient: _patient,
          ),
        ),
      );
    }
  }

  void _openQR(Prescription rx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrescriptionQrScreen(
          prescription: rx,
          patient: _patient,
        ),
      ),
    );
  }
}

class _PrescriptionTile extends StatelessWidget {
  final Prescription prescription;
  final Patient patient;
  final VoidCallback onTap;

  const _PrescriptionTile({
    required this.prescription,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM d, yyyy').format(prescription.createdAt);
    final medicineCount = prescription.medicines.length;
    final status = prescription.status;

    Color statusColor;
    String statusText;
    switch (status) {
      case 'given':
        statusColor = AppColors.success;
        statusText = 'Given';
        break;
      case 'partial':
        statusColor = AppColors.warning;
        statusText = 'Partial';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Pending';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          '$medicineCount medicine${medicineCount > 1 ? 's' : ''}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          date,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.qr_code, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
