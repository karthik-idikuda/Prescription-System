import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../models/prescription.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dosage_selector.dart';
import '../widgets/medicine_autocomplete.dart';
import '../widgets/timing_selector.dart';
import 'prescription_qr_screen.dart';

class AddPatientPrescriptionScreen extends StatefulWidget {
  const AddPatientPrescriptionScreen({super.key});

  @override
  State<AddPatientPrescriptionScreen> createState() =>
      _AddPatientPrescriptionScreenState();
}

class _AddPatientPrescriptionScreenState
    extends State<AddPatientPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Patient details
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  XFile? _photo;
  Uint8List? _photoBytes;

  // Prescription
  final _notesController = TextEditingController();
  final List<_MedicineEntry> _medicines = [_MedicineEntry()];

  bool _isSaving = false;
  int _currentStep = 0; // 0 = patient, 1 = prescription

  @override
  void initState() {
    super.initState();
    // Auto-open camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickPhoto();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _photo = picked;
        _photoBytes = bytes;
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    // Validate photo is mandatory
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient photo is required')),
      );
      setState(() => _currentStep = 0);
      return;
    }

    // Validate patient
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter patient name')),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    if (age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid age')),
      );
      return;
    }

    // Get medicines (optional)
    final medicines = _medicines
        .where((e) => e.name.trim().isNotEmpty)
        .map((e) => PrescriptionMedicine(
              name: e.name.trim(),
              dosage: e.dosage,
              timing: e.timing,
              days: e.days,
            ))
        .toList();

    setState(() => _isSaving = true);

    try {
      final db = context.read<DatabaseService>();
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // 1. Create patient
      Patient patient = await db.addPatient(
        name: _nameController.text.trim(),
        age: age,
        gender: _gender,
        phone: _phoneController.text.trim(),
      );

      // 2. Upload photo if taken
      if (_photo != null) {
        final storage = StorageService();
        final photoUrl = await storage.uploadPatientPhoto(patient.id, _photo!);
        patient = patient.copyWith(photoUrl: photoUrl);
        await db.updatePatient(patient);
      }

      // 3. Create prescription
      final prescription = await db.createPrescription(
        patientId: patient.id,
        medicines: medicines,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        doctorId: uid,
      );

      // 4. Auto-send to pharmacy
      await db.sendToPharmacy(
        patientId: patient.id,
        patientName: patient.name,
        prescriptionId: prescription.id,
        medicines: medicines.map((m) => m.name).toList(),
      );

      if (!mounted) return;

      // 5. Go to QR screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PrescriptionQrScreen(
            prescription: prescription,
            patient: patient,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_currentStep == 0 ? 'New Patient' : 'Add Prescription'),
        actions: [
          if (_currentStep == 1)
            TextButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Done'),
            ),
        ],
      ),
      body: _currentStep == 0 ? _buildPatientStep() : _buildPrescriptionStep(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _currentStep == 0
              ? FilledButton(
                  onPressed: () {
                    if (_photo == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Patient photo is required')),
                      );
                      return;
                    }
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter patient name')),
                      );
                      return;
                    }
                    setState(() => _currentStep = 1);
                  },
                  child: const Text('Next: Add Prescription'),
                )
              : FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...'),
                          ],
                        )
                      : const Text('Save & Generate QR'),
                ),
        ),
      ),
    );
  }

  Widget _buildPatientStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Photo
        Center(
          child: GestureDetector(
            onTap: _pickPhoto,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider, width: 2),
                image: _photoBytes != null
                    ? DecorationImage(
                        image: MemoryImage(_photoBytes!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _photoBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt,
                            size: 32, color: AppColors.textSecondary),
                        SizedBox(height: 4),
                        Text(
                          'Add Photo *',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        Text(
                          'Required',
                          style: TextStyle(fontSize: 10, color: Colors.red),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Name
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        const SizedBox(height: 16),

        // Phone
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        // Age & Gender
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age *',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.wc_outlined),
                ),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Info card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'After patient details, you\'ll add prescription medicines.',
                  style: TextStyle(fontSize: 13, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Patient summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                backgroundImage:
                    _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                child: _photoBytes == null
                    ? Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      '${_ageController.text}y $_gender • ${_phoneController.text}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('Edit'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Medicines header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Medicines',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _medicines.add(_MedicineEntry())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Medicine entries
        ...List.generate(_medicines.length, (index) {
          return _MedicineCard(
            key: ValueKey(_medicines[index]),
            entry: _medicines[index],
            index: index,
            onRemove: _medicines.length > 1
                ? () => setState(() => _medicines.removeAt(index))
                : null,
            onChanged: () => setState(() {}),
          );
        }),

        const SizedBox(height: 16),

        // Notes
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'Additional instructions...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _MedicineEntry {
  String name = '';
  String dosage = 'Morning & Night';
  String timing = 'After Food';
  int days = 5;
}

class _MedicineCard extends StatelessWidget {
  final _MedicineEntry entry;
  final int index;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _MedicineCard({
    super.key,
    required this.entry,
    required this.index,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                  child: Text('Medicine',
                      style: TextStyle(fontWeight: FontWeight.w500))),
              if (onRemove != null)
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.close,
                      size: 20, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Medicine name
          MedicineAutocomplete(
            initialValue: entry.name,
            onSelected: (v) {
              entry.name = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),

          // Dosage
          const Text('Dosage',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          DosageSelector(
            value: entry.dosage,
            onChanged: (v) {
              entry.dosage = v;
              onChanged();
            },
          ),
          const SizedBox(height: 10),

          // Timing
          const Text('Timing',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          TimingSelector(
            value: entry.timing,
            onChanged: (v) {
              entry.timing = v;
              onChanged();
            },
          ),
          const SizedBox(height: 10),

          // Days
          Row(
            children: [
              const Text('Days:', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: entry.days > 1
                    ? () {
                        entry.days--;
                        onChanged();
                      }
                    : null,
                child: Icon(
                  Icons.remove_circle_outline,
                  color: entry.days > 1
                      ? AppColors.textPrimary
                      : AppColors.divider,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Text('${entry.days}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  entry.days++;
                  onChanged();
                },
                child: const Icon(Icons.add_circle_outline, size: 22),
              ),
              const Spacer(),
              ...[3, 5, 7].map((d) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GestureDetector(
                      onTap: () {
                        entry.days = d;
                        onChanged();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: entry.days == d
                              ? AppColors.primary
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$d',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: entry.days == d
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
