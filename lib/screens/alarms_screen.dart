import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';

class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  static const _presets = <(String, int)>[
    ('5 MIN', 5),
    ('15 MIN', 15),
    ('30 MIN', 30),
    ('1 HOUR', 60),
  ];

  void _addCustomAlarm() {
    showDialog<void>(
      context: context,
      builder: (context) {
        TimeOfDay selected = TimeOfDay.now();
        final messageCtrl = TextEditingController();
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('CUSTOM ALARM'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule, color: AppColors.dangerBright),
                    title: Text(
                      selected.format(context),
                      style: const TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    trailing: const Icon(Icons.edit, color: AppColors.textMuted),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selected,
                      );
                      if (picked != null) setState(() => selected = picked);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: messageCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Alarm message (e.g. GET BACK TO WORK)',
                      prefixIcon: Icon(Icons.message_outlined,
                          color: AppColors.textMuted, size: 20),
                    ),
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
                    context.read<AppState>().addAlarm(
                          hour: selected.hour,
                          minute: selected.minute,
                          message: messageCtrl.text.trim().isEmpty
                              ? 'GET BACK TO WORK'
                              : messageCtrl.text.trim().toUpperCase(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('ALARMS')),
      body: Column(
        children: [
          _buildPresets(),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: appState.alarms.isEmpty
                ? const _EmptyAlarms()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appState.alarms.length,
                    itemBuilder: (context, index) {
                      final alarm = appState.alarms[index];
                      return _AlarmCard(
                        alarm: alarm,
                        onToggle: () => appState.toggleAlarm(alarm.id),
                        onDelete: () => appState.removeAlarm(alarm.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomAlarm,
        child: const Icon(Icons.add_alarm),
      ),
    );
  }

  Widget _buildPresets() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ALARMS',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _presets.map((preset) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Alarm in ${preset.$2} minutes. Stay on task.'),
                        ),
                      );
                      // TODO: hook into actual timer/notification
                    },
                    child: Text(preset.$1),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _AlarmCard extends StatelessWidget {
  const _AlarmCard({
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
  });

  final dynamic alarm;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alarm.isActive ? AppColors.danger.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            alarm.isActive ? Icons.notifications_active : Icons.notifications_off,
            color: alarm.isActive ? AppColors.dangerBright : AppColors.textMuted,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.timeLabel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alarm.message,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(value: alarm.isActive, onChanged: (_) => onToggle()),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _EmptyAlarms extends StatelessWidget {
  const _EmptyAlarms();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.alarm_add, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            'No alarms set.\nSet quick alarms to blast yourself\nback into focus.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
