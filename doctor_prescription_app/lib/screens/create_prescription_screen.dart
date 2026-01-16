import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/patient.dart';
import '../models/prescription.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/dosage_selector.dart';
import '../widgets/medicine_autocomplete.dart';
import '../widgets/timing_selector.dart';

class CreatePrescriptionScreen extends StatefulWidget {
  final Patient patient;

  const CreatePrescriptionScreen({super.key, required this.patient});

  @override
  State<CreatePrescriptionScreen> createState() => _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState extends State<CreatePrescriptionScreen> {
  final _notesController = TextEditingController();
  bool _isSaving = false;

  final List<_MedicineEntry> _entries = [_MedicineEntry()];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final medicines = _entries
        .where((e) => e.name.trim().isNotEmpty)
        .map((e) => PrescriptionMedicine(
              name: e.name.trim(),
              dosage: e.dosage,
              timing: e.timing,
              days: e.days,
            ))
        .toList();

    if (medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one medicine')),
      );
      return;
    }

    if (medicines.any((m) => m.days <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Days must be at least 1')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = context.read<DatabaseService>();
      final uid = FirebaseAuth.instance.currentUser?.uid;

      final created = await db.createPrescription(
        patientId: widget.patient.id,
        medicines: medicines,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        doctorId: uid,
      );

      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('New Prescription'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Patient info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.patient.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Medicines section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medicines',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _entries.add(_MedicineEntry()));
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Medicine entries
          ...List.generate(_entries.length, (index) {
            return _MedicineCard(
              key: ValueKey(_entries[index]),
              entry: _entries[index],
              index: index,
              onRemove: _entries.length > 1
                  ? () => setState(() => _entries.removeAt(index))
                  : null,
              onChanged: () => setState(() {}),
            );
          }),

          const SizedBox(height: 20),

          // Notes
          const Text(
            'Notes (optional)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Additional instructions...',
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Prescription'),
          ),
        ),
      ),
    );
  }
}

class _MedicineEntry {
  String name = '';
  String dosage = '1-0-1';
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with number and remove
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Medicine',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
          const Text('Dosage', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          DosageSelector(
            value: entry.dosage,
            onChanged: (v) {
              entry.dosage = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),

          // Timing
          const Text('Timing', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TimingSelector(
            value: entry.timing,
            onChanged: (v) {
              entry.timing = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),

          // Days
          Row(
            children: [
              const Text('Days:', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: entry.days > 1
                    ? () {
                        entry.days--;
                        onChanged();
                      }
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.days}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  entry.days++;
                  onChanged();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const Spacer(),
              // Quick select
              ...([3, 5, 7, 10].map((d) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: InkWell(
                      onTap: () {
                        entry.days = d;
                        onChanged();
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: entry.days == d ? AppColors.primary : AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$d',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: entry.days == d ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ))),
            ],
          ),
        ],
      ),
    );
  }
}
