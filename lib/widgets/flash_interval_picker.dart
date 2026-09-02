import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A horizontal row of selectable chips to pick a flash interval (in minutes).
/// Null value means no flashing.
class FlashIntervalPicker extends StatelessWidget {
  const FlashIntervalPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  static const _options = <int?>[null, 5, 15, 30, 60];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((option) {
        final selected = value == option;
        final label = option == null ? 'OFF' : '${option}m';
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: ChoiceChip(
            label: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            onSelected: (_) => onChanged(option),
            selectedColor: AppColors.danger,
            backgroundColor: AppColors.cardHighlight,
            showCheckmark: false,
            side: BorderSide(
              color: selected ? AppColors.danger : AppColors.border,
            ),
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }
}
