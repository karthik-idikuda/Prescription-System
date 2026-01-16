import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/pharmacy_database_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with web options
  if (kIsWeb) {
    try {
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
    } catch (e) {
      debugPrint('Firebase web init failed: $e');
    }
  } else {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }
  }

  // No-auth UI: silently sign in so Firestore rules (request.auth != null) allow access.
  await _ensureAnonymousAuthAndRole(role: 'pharmacist');

  runApp(const PharmacyApp());
}

Future<void> _ensureAnonymousAuthAndRole({required String role}) async {
  try {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }

    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    // Create/merge the user's role doc. Required by role-based Firestore rules.
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
      {
        'userId': uid,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  } catch (e) {
    debugPrint('Anonymous auth bootstrap failed: $e');
  }
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PharmacyDatabaseService>(
            create: (_) => PharmacyDatabaseService()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Pharmacy Prescription App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) {
              return const PharmacyHomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}

/// Simple auth provider for PIN-based login
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _pharmacistName = '';

  bool get isLoggedIn => _isLoggedIn;
  String get pharmacistName => _pharmacistName;

  Future<bool> login(String pin) async {
    if (pin == '1234' || pin == '0000') {
      _isLoggedIn = true;
      _pharmacistName = 'Pharmacist';
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _pharmacistName = '';
    notifyListeners();
  }
}
