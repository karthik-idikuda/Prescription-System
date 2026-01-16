import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';
import 'doctor_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptedTerms = false;

  Future<void> _signInWithGoogle() async {
    if (!_acceptedTerms) {
      setState(() => _errorMessage = 'Please accept the Terms and Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      UserCredential userCredential;

      // Use Firebase Auth's built-in Google Sign-In for both web and mobile
      // This is the simplest approach that works across all platforms
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');
      
      if (kIsWeb) {
        // Web: Use popup
        userCredential = await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        // Mobile: Use redirect (or popup if available)
        // For mobile, we use signInWithProvider which handles the flow natively
        userCredential = await FirebaseAuth.instance.signInWithProvider(provider);
      }

      // Create/update user profile
      await _createDoctorProfile(userCredential.user!);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DoctorHomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sign in failed. Please try again.';
      });
      debugPrint('Google Sign-In Error: $e');
    }
  }

  Future<void> _createDoctorProfile(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'userId': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'role': 'doctor',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'termsAcceptedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            '''Privacy Policy for Doctor Prescription App

Last updated: December 31, 2025

1. DATA COLLECTION
We collect: Name, Email, Phone Number, Patient Records, Prescription Data.

2. DATA USAGE
Your data is used to:
- Provide prescription management services
- Communicate with pharmacies
- Maintain medical records

3. DATA STORAGE
Data is stored securely on Firebase (Google Cloud) servers with encryption at rest and in transit.

4. DATA SHARING
We DO NOT sell your data. Data is shared only with:
- Linked pharmacy for prescription fulfillment
- As required by law

5. YOUR RIGHTS (DPDP Act 2023)
You have the right to:
- Access your data
- Correct inaccuracies
- Delete your account
- Data portability

6. CONTACT
For data concerns, contact: support@doctorapp.com

By using this app, you consent to this policy.''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            '''Terms of Service for Doctor Prescription App

1. ELIGIBILITY
This app is for licensed medical practitioners only.

2. MEDICAL RESPONSIBILITY
You are solely responsible for all prescriptions issued through this app.

3. DATA ACCURACY
You must ensure all patient data entered is accurate and complete.

4. COMPLIANCE
You agree to comply with:
- Indian Medical Council regulations
- Telemedicine Guidelines 2020
- DPDP Act 2023

5. LIMITATION OF LIABILITY
This app is a tool. We are not liable for medical decisions or outcomes.

6. TERMINATION
We may terminate access for policy violations.

By using this app, you agree to these terms.''',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withOpacity(0.8),
              const Color(0xFF1A237E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      size: 72,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Doctor App',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prescription Management System',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Login Card
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to access your clinic dashboard',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Terms Checkbox
                        CheckboxListTile(
                          value: _acceptedTerms,
                          onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          title: Wrap(
                            children: [
                              const Text('I accept the ', style: TextStyle(fontSize: 13)),
                              GestureDetector(
                                onTap: _showTerms,
                                child: const Text(
                                  'Terms',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const Text(' and ', style: TextStyle(fontSize: 13)),
                              GestureDetector(
                                onTap: _showPrivacyPolicy,
                                child: const Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Google Sign-In Button
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://www.google.com/favicon.ico',
                                        width: 24,
                                        height: 24,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.g_mobiledata,
                                          size: 28,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    '© 2025 Doctor App. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
