import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/database_service.dart';
import 'screens/doctor_home_screen.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAlvssyGOrEwRkmNae_tQx49mljdODbP04',
        authDomain: 'shop-ecosystem-7a30a.firebaseapp.com',
        projectId: 'shop-ecosystem-7a30a',
        storageBucket: 'shop-ecosystem-7a30a.firebasestorage.app',
        messagingSenderId: '741512348656',
        appId: '1:741512348656:web:5fa6a33cdf2019b71ed335',
        measurementId: 'G-2JVY4MGP2D',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const DoctorPrescriptionApp());
}

class DoctorPrescriptionApp extends StatelessWidget {
  final Widget? homeOverride;

  const DoctorPrescriptionApp({super.key, this.homeOverride});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doctor App',
        theme: AppTheme.lightTheme,
        home: homeOverride ?? const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper that checks authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          return const DoctorHomeScreen();
        }

        // User is not signed in
        return const LoginScreen();
      },
    );
  }
}
