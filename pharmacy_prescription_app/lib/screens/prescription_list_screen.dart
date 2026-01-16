import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/pharmacy_database_service.dart';
import 'prescription_detail_screen.dart';

class PrescriptionListScreen extends StatelessWidget {
  final bool showPendingOnly;

  const PrescriptionListScreen({
    super.key,
    this.showPendingOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final dbService = context.read<PharmacyDatabaseService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(showPendingOnly ? 'Pending Prescriptions' : 'All Prescriptions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<Prescription>>(
        stream: showPendingOnly
            ? dbService.getPendingPrescriptions()
            : dbService.getAllPrescriptions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final prescriptions = snapshot.data ?? [];

          if (prescriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showPendingOnly ? Icons.check_circle : Icons.receipt_long,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    showPendingOnly ? 'No pending prescriptions' : 'No prescriptions yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final prescription = prescriptions[index];
              return _buildPrescriptionCard(context, prescription);
            },
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, Prescription prescription) {
    final statusColor = prescription.isPending
        ? Colors.orange
        : prescription.isGiven
            ? Colors.green
            : Colors.blue;

    final statusText = prescription.isPending
        ? 'PENDING'
        : prescription.isGiven
            ? 'GIVEN'
            : 'PARTIAL';

    return FutureBuilder<Patient?>(
      future: context.read<PharmacyDatabaseService>().getPatient(prescription.patientId),
      builder: (context, snapshot) {
        final patient = snapshot.data;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PrescriptionDetailScreen(
                  prescription: prescription,
                  patient: patient,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: prescription.isPending
                  ? Border.all(color: Colors.orange.shade200, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Patient Photo
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: patient?.photoUrl != null
                      ? NetworkImage(patient!.photoUrl!)
                      : null,
                  child: patient?.photoUrl == null
                      ? Text(
                          patient?.name.isNotEmpty == true
                              ? patient!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Prescription Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              patient?.name ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              prescription.id,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.medication, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${prescription.medicines.length} medicine(s)',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(prescription.createdAt),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}
