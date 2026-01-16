import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. '
          'This action cannot be undone.\n\n'
          'As per DPDP Act 2023, your data will be removed within 30 days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Mark user for deletion (actual deletion can be handled by Cloud Function)
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'deletionRequested': true,
            'deletionRequestedAt': FieldValue.serverTimestamp(),
          });

          // Sign out
          await FirebaseAuth.instance.signOut();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account deletion requested. Your data will be removed within 30 days.'),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
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

  void _showTerms(BuildContext context) {
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user?.photoURL != null 
                        ? NetworkImage(user!.photoURL!) 
                        : null,
                    child: user?.photoURL == null 
                        ? const Icon(Icons.person, size: 32, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Doctor',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Legal Section
          const Text(
            'LEGAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTerms(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Section
          const Text(
            'ACCOUNT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _signOut(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever, color: AppColors.error),
                  title: Text('Delete My Account', style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Remove all your data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _deleteAccount(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Info
          Center(
            child: Text(
              'Doctor App v1.0.0\n© 2025 All rights reserved',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
