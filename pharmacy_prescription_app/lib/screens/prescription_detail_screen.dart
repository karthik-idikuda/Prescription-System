import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/pharmacy_database_service.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final Prescription prescription;
  final Patient? patient;

  const PrescriptionDetailScreen({
    super.key,
    required this.prescription,
    this.patient,
  });

  @override
  State<PrescriptionDetailScreen> createState() => _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  final _noteController = TextEditingController();
  bool _isUpdating = false;
  late Prescription _prescription;

  @override
  void initState() {
    super.initState();
    _prescription = widget.prescription;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _markAsGiven() async {
    await _updateStatus('given');
  }

  Future<void> _markAsPartiallyGiven() async {
    await _updateStatus('partially_given');
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);

    try {
      await context.read<PharmacyDatabaseService>().updatePrescriptionStatus(
        prescriptionId: _prescription.id,
        status: status,
        pharmacistNote: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(status == 'given' ? 'Marked as Given!' : 'Marked as Partially Given'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_prescription.id),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Patient Photo
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: widget.patient?.photoUrl != null
                        ? NetworkImage(widget.patient!.photoUrl!)
                        : null,
                    child: widget.patient?.photoUrl == null
                        ? Text(
                            widget.patient?.name.isNotEmpty == true
                                ? widget.patient!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Patient Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patient?.name ?? 'Unknown Patient',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.patient?.age ?? '?'} yrs • ${widget.patient?.gender ?? ''}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.patient?.id ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _prescription.isPending
                    ? Colors.orange.shade100
                    : _prescription.isGiven
                        ? Colors.green.shade100
                        : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _prescription.isPending
                        ? Icons.pending
                        : _prescription.isGiven
                            ? Icons.check_circle
                            : Icons.hourglass_bottom,
                    size: 20,
                    color: _prescription.isPending
                        ? Colors.orange.shade700
                        : _prescription.isGiven
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _prescription.isPending
                        ? 'Pending'
                        : _prescription.isGiven
                            ? 'Medicines Given'
                            : 'Partially Given',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _prescription.isPending
                          ? Colors.orange.shade700
                          : _prescription.isGiven
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMMM yyyy, hh:mm a').format(_prescription.createdAt),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Medicines List
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medication, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Medicines',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_prescription.medicines.length} items',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._prescription.medicines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final medicine = entry.value;
                    return _buildMedicineItem(index + 1, medicine);
                  }),
                ],
              ),
            ),

            // Doctor Notes
            if (_prescription.notes != null && _prescription.notes!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.yellow.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Doctor Notes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _prescription.notes!,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Pharmacist Note (if pending)
            if (_prescription.isPending) ...[
              const SizedBox(height: 24),
              const Text(
                'Pharmacist Note (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g., Brand given: Dolo 650',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons (only if pending)
            if (_prescription.isPending) ...[
              ElevatedButton(
                onPressed: _isUpdating ? null : _markAsGiven,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 24),
                          SizedBox(width: 10),
                          Text('Medicines Given'),
                        ],
                      ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _isUpdating ? null : _markAsPartiallyGiven,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: const BorderSide(color: Colors.blue, width: 2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.hourglass_bottom, size: 24, color: Colors.blue),
                    SizedBox(width: 10),
                    Text('Partially Given', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineItem(int index, PrescriptionMedicine medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  medicine.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildDetailChip(Icons.schedule, medicine.dosage),
              _buildDetailChip(Icons.restaurant, medicine.timing),
              _buildDetailChip(Icons.calendar_today, '${medicine.days} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
