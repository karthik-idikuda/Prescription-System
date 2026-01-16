import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TimingSelector extends StatelessWidget {
  final String value;
  final Function(String) onChanged;

  const TimingSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const List<String> options = ['Before Food', 'After Food', 'With Food'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((t) {
        final isSelected = value == t;
        return InkWell(
          onTap: () => onChanged(t),
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
              t,
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
