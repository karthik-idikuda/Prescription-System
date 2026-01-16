import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class PharmacyNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final PharmacyNotificationService _instance = PharmacyNotificationService._internal();
  
  // Callback for showing alerts
  Function(String title, String body)? onAlertReceived;

  factory PharmacyNotificationService() => _instance;
  PharmacyNotificationService._internal();

  /// Initialize FCM for pharmacy
  Future<void> initialize() async {
    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM authorized for Pharmacy App');
    }

    // Subscribe to pharmacy topic
    await _fcm.subscribeToTopic('pharmacy');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Get FCM token for debugging
    final token = await _fcm.getToken();
    debugPrint('Pharmacy FCM Token: $token');
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Pharmacy received foreground message!');
    
    final title = message.notification?.title ?? 'Alert';
    final body = message.notification?.body ?? message.data['message'] ?? '';
    
    // Vibrate to alert pharmacist
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 1000, amplitude: 255);
    }
    
    // Trigger callback if set
    if (onAlertReceived != null) {
      onAlertReceived!(title, body);
    }
  }

  /// Set alert callback
  void setAlertCallback(Function(String title, String body) callback) {
    onAlertReceived = callback;
  }
}

/// Handle background messages (top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  debugPrint('Pharmacy handling background message: ${message.messageId}');
}

/// Alert dialog widget for doctor calls
class DoctorAlertDialog extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const DoctorAlertDialog({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.orange.shade50,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(
            'Doctor Alert',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medical_services, size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Please go to the clinic now',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onDismiss,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Got it!'),
          ),
        ),
      ],
    );
  }
}
