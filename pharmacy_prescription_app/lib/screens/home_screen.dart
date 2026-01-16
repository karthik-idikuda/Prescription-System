import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/models.dart';
import '../services/pharmacy_database_service.dart';
import '../services/notification_service.dart';
import 'prescription_list_screen.dart';
import 'scan_qr_screen.dart';
import 'patient_view_screen.dart';

class PharmacyHomeScreen extends StatefulWidget {
  const PharmacyHomeScreen({super.key});

  @override
  State<PharmacyHomeScreen> createState() => _PharmacyHomeScreenState();
}

class _PharmacyHomeScreenState extends State<PharmacyHomeScreen> {
  int _unreadAlerts = 0;

  @override
  void initState() {
    super.initState();
    _setupAlertListener();
  }

  void _setupAlertListener() {
    // Listen for doctor alerts
    PharmacyNotificationService().setAlertCallback((title, body) {
      _showAlertDialog(body);
    });

    // Listen for Firestore alerts
    context.read<PharmacyDatabaseService>().getUnreadAlerts().listen((alerts) {
      if (mounted) {
        setState(() => _unreadAlerts = alerts.length);
        
        // Show dialog for new alerts
        for (final alert in alerts) {
          if (!alert.isRead) {
            _showAlertDialog(alert.message);
            context.read<PharmacyDatabaseService>().markAlertAsRead(alert.id);
          }
        }
      }
    });
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DoctorAlertDialog(
        message: message,
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Pharmacy',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Alert indicator
          if (_unreadAlerts > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Badge(
                label: Text('$_unreadAlerts'),
                child: IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.orange),
                  onPressed: () {
                    context.read<PharmacyDatabaseService>().markAllAlertsAsRead();
                  },
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Prescriptions Count
              StreamBuilder<List<Prescription>>(
                stream: context.read<PharmacyDatabaseService>().getPendingPrescriptions(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long, color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Pending Prescriptions',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Action Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.qr_code_scanner,
                      title: 'Scan QR',
                      subtitle: 'Quick lookup',
                      color: const Color(0xFF2196F3),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ScanQRScreen()),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.list_alt,
                      title: 'Prescriptions',
                      subtitle: 'View all',
                      color: const Color(0xFF4CAF50),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrescriptionListScreen()),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.pending_actions,
                      title: 'Pending',
                      subtitle: 'To dispense',
                      color: const Color(0xFFFF9800),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrescriptionListScreen(showPendingOnly: true),
                        ),
                      ),
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.person_search,
                      title: 'Patient',
                      subtitle: 'Search patient',
                      color: const Color(0xFF9C27B0),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PatientSearchScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple patient search screen
class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final _controller = TextEditingController();
  Patient? _patient;
  bool _isLoading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _patient = null;
    });

    try {
      final patient = await context.read<PharmacyDatabaseService>().getPatient(query);
      setState(() {
        _patient = patient;
        if (patient == null) {
          _error = 'Patient not found';
        }
      });
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Find Patient'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter Patient ID (e.g., PT-1023)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_patient != null)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientViewScreen(patient: _patient!),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _patient!.photoUrl != null
                              ? NetworkImage(_patient!.photoUrl!)
                              : null,
                          child: _patient!.photoUrl == null
                              ? Text(
                                  _patient!.name.isNotEmpty
                                      ? _patient!.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _patient!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _patient!.id,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientViewScreen(patient: _patient!),
                              ),
                            );
                          },
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
