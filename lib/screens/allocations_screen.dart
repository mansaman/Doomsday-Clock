import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_allocation.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';

class AllocationsScreen extends StatefulWidget {
  const AllocationsScreen({super.key});

  @override
  State<AllocationsScreen> createState() => _AllocationsScreenState();
}

class _AllocationsScreenState extends State<AllocationsScreen> {
  static const _icons = ['😴', '💼', '🚗', '📚', '🍳', '💪', '🧘', '📱', '🎮', '📺'];

  void _addAllocation() {
    final nameCtrl = TextEditingController();
    double hours = 2;
    String icon = '⏳';

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('ADD LIFE DEBT'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Gym, Gaming, Meditation',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1)} hours/day',
                    style: const TextStyle(
                      color: AppColors.dangerBright,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: hours,
                    min: 0.5,
                    max: 12,
                    divisions: 46,
                    label: '${hours.toStringAsFixed(1)}h',
                    onChanged: (v) => setState(() => hours = v),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _icons.map((i) {
                      final selected = i == icon;
                      return ChoiceChip(
                        label: Text(i, style: const TextStyle(fontSize: 20)),
                        selected: selected,
                        onSelected: (_) => setState(() => icon = i),
                        selectedColor: AppColors.danger,
                        backgroundColor: AppColors.cardHighlight,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim().isEmpty
                        ? 'Allocation'
                        : nameCtrl.text.trim();
                    context.read<AppState>().addAllocation(
                          name: name,
                          hoursPerDay: hours,
                          icon: icon,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('ADD'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final total = appState.totalAllocatedHoursPerDay;
    final remainingFree = 24 - total;
    final overBudget = remainingFree < 0;

    return Scaffold(
      appBar: AppBar(title: const Text('LIFE ALLOCATIONS')),
      body: Column(
        children: [
          _buildSummary(total, remainingFree, overBudget),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: appState.allocations.isEmpty
                ? const Center(
                    child: Text(
                      'No allocations. Everything is free time.\nIs that really true?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appState.allocations.length,
                    itemBuilder: (context, index) {
                      final allocation = appState.allocations[index];
                      return _AllocationCard(
                        allocation: allocation,
                        onToggle: () => appState.updateAllocation(
                          allocation.copyWith(isActive: !allocation.isActive),
                        ),
                        onDelete: () => appState.removeAllocation(allocation.id),
                        onEdit: () => _editAllocation(appState, allocation),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAllocation,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary(double total, double free, bool overBudget) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: overBudget ? AppColors.danger : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryStat(
                  label: 'OBLIGATIONS',
                  value: '${total.toStringAsFixed(total % 1 == 0 ? 0 : 1)}h',
                ),
                _SummaryStat(
                  label: 'FREE / DAY',
                  value: '${free.toStringAsFixed(free % 1 == 0 ? 0 : 1)}h',
                  valueColor: overBudget ? AppColors.dangerBright : AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (overBudget)
              Text(
                'OVERSPENT! Your obligations exceed 24 hours.\nThis is physically impossible. Cut something.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.dangerBright,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                'These obligations silently eat your free time\nevery single day. The real cost of living.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _editAllocation(AppState appState, TimeAllocation allocation) {
    final nameCtrl = TextEditingController(text: allocation.name);
    var hours = allocation.hoursPerDay;
    var icon = allocation.icon;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('EDIT'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${hours.toStringAsFixed(hours % 1 == 0 ? 0 : 1)} hours/day',
                    style: const TextStyle(
                      color: AppColors.dangerBright,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: hours,
                    min: 0.5,
                    max: 12,
                    divisions: 46,
                    label: '${hours.toStringAsFixed(1)}h',
                    onChanged: (v) => setState(() => hours = v),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _icons.map((i) {
                      final selected = i == icon;
                      return ChoiceChip(
                        label: Text(i, style: const TextStyle(fontSize: 20)),
                        selected: selected,
                        onSelected: (_) => setState(() => icon = i),
                        selectedColor: AppColors.danger,
                        backgroundColor: AppColors.cardHighlight,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    appState.updateAllocation(TimeAllocation(
                      id: allocation.id,
                      name: nameCtrl.text.trim().isEmpty
                          ? allocation.name
                          : nameCtrl.text.trim(),
                      hoursPerDay: hours,
                      icon: icon,
                      isActive: allocation.isActive,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AllocationCard extends StatelessWidget {
  const _AllocationCard({
    required this.allocation,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  final TimeAllocation allocation;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: allocation.isActive ? AppColors.border : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Text(allocation.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allocation.name,
                  style: TextStyle(
                    color: allocation.isActive
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: allocation.isActive ? null : TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  "${allocation.hoursPerDay.toStringAsFixed(allocation.hoursPerDay % 1 == 0 ? 0 : 1)}h of your life, daily",
                  style: TextStyle(
                    color: allocation.isActive ? AppColors.warning : AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.textMuted),
          ),
          Switch(value: allocation.isActive, onChanged: (_) => onToggle()),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 1),
        ),
      ],
    );
  }
}
