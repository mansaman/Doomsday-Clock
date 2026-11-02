import 'package:flutter/material.dart';
import 'glass.dart';

/// Segmented control to pick a flash interval (in minutes).
/// Null value means no flashing.
class FlashIntervalPicker extends StatelessWidget {
  const FlashIntervalPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    // Segmented controls need non-null keys; 0 stands in for "off".
    return SegmentedPicker<int>(
      value: value ?? 0,
      options: const {0: 'Off', 5: '5m', 15: '15m', 30: '30m', 60: '1h'},
      onChanged: (v) => onChanged(v == 0 ? null : v),
    );
  }
}
