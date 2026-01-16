import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DosageSelector extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const DosageSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const List<String> options = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
    'Morning & Night',
    'Morning, Afternoon & Night',
    'All Times'
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((d) {
        final isSelected = value == d;
        return InkWell(
          onTap: () => onChanged(d),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Text(
              d,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
