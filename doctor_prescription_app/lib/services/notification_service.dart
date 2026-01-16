import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize FCM
  Future<void> initialize() async {
    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM authorized');
    }

    // Subscribe to pharmacy topic (for receiving alerts if needed)
    await _fcm.subscribeToTopic('pharmacy');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message while in foreground!');
      debugPrint('Message data: ${message.data}');
      if (message.notification != null) {
        debugPrint('Message notification: ${message.notification}');
      }
    });

    // Get FCM token for debugging
    final token = await _fcm.getToken();
    debugPrint('FCM Token: $token');
  }

  /// Send notification to pharmacy topic
  /// Note: In production, this should be done via Cloud Functions
  /// For demo, we'll use Firestore trigger or direct FCM API
  Future<void> sendPharmacyNotification({
    required String title,
    required String body,
  }) async {
    // This is handled by Cloud Function triggered by Firestore write
    // The notification is sent when we add to pharmacy_alerts collection
    debugPrint('Pharmacy notification triggered: $title - $body');
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
