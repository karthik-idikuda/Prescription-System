import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Empty state widget for when lists have no data
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// No patients yet
  factory EmptyState.patients({VoidCallback? onAddPatient}) {
    return EmptyState(
      icon: Icons.people_outline,
      title: 'No Patients Yet',
      subtitle: 'Start by adding your first patient to create prescriptions.',
      actionLabel: 'Add Patient',
      onAction: onAddPatient,
    );
  }

  /// No prescriptions yet
  factory EmptyState.prescriptions({VoidCallback? onCreatePrescription}) {
    return EmptyState(
      icon: Icons.description_outlined,
      title: 'No Prescriptions',
      subtitle: "You haven't created any prescriptions yet.",
      actionLabel: 'Create Prescription',
      onAction: onCreatePrescription,
    );
  }

  /// No search results
  factory EmptyState.noResults({String? query}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results',
      subtitle: query != null 
          ? 'No results found for "$query"'
          : 'No results found for your search.',
    );
  }

  /// Error state
  factory EmptyState.error({VoidCallback? onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      subtitle: 'We had trouble loading this data. Please try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}
