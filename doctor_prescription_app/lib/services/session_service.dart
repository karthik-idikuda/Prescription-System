import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to handle session timeout
/// Logs out user after 30 minutes of inactivity
class SessionService with WidgetsBindingObserver {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  Timer? _inactivityTimer;
  final Duration _sessionTimeout = const Duration(minutes: 30);
  VoidCallback? _onSessionExpired;

  void initialize({VoidCallback? onSessionExpired}) {
    _onSessionExpired = onSessionExpired;
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  void dispose() {
    _inactivityTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Call this on any user interaction
  void recordActivity() {
    _resetTimer();
  }

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_sessionTimeout, _handleTimeout);
  }

  void _handleTimeout() async {
    debugPrint('Session expired due to inactivity');
    await FirebaseAuth.instance.signOut();
    _onSessionExpired?.call();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // User came back to app
      _resetTimer();
    } else if (state == AppLifecycleState.paused) {
      // App went to background - start a shorter timer
      _inactivityTimer?.cancel();
      _inactivityTimer = Timer(const Duration(minutes: 5), _handleTimeout);
    }
  }
}
