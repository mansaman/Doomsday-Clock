import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final calc = appState.lifeCalculator;
    final profile = appState.profile;

    if (profile == null || calc == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('YOUR DOOM'),
          _SettingsCard(
            children: [
              _Row(
                label: 'Date of birth',
                value: '${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year}',
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: profile.dateOfBirth,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    appState.updateProfile(profile.copyWith(
                      dateOfBirth: DateTime(picked.year, picked.month, picked.day),
                    ));
                  }
                },
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Life expectancy'),
                subtitle: Text(
                  '${profile.lifeExpectancyYears} years',
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                onTap: () => _editExpectancy(appState, profile),
              ),
              const Divider(color: AppColors.border, height: 1),
              const _Row(
                label: 'Days remaining',
                value: '',
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Days remaining'),
                trailing: Text(
                  calc.daysLeft,
                  style: const TextStyle(
                    color: AppColors.dangerBright,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle('REALITY CHECK'),
          _SettingsCard(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.percent, color: AppColors.dangerBright),
                title: const Text('Life lived'),
                trailing: Text(
                  '${(calc.percentageLived * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: calc.percentageLived,
                    minHeight: 8,
                    backgroundColor: AppColors.cardHighlight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.danger),
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.hourglass_empty, color: AppColors.warning),
                title: const Text('Time already spent'),
                trailing: Text(
                  _formatDuration(calc.lived),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle('TIME WALLET'),
          _SettingsCard(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.account_balance_wallet,
                    color: AppColors.warning),
                title: const Text('Free time today'),
                trailing: Text(
                  _formatDuration(calc.freeTimeToday),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_clock, color: AppColors.dangerBright),
                title: const Text('Lost to obligations'),
                trailing: Text(
                  '${calc.totalAllocatedHoursPerDay.toStringAsFixed(calc.totalAllocatedHoursPerDay % 1 == 0 ? 0 : 1)}h/day',
                  style: const TextStyle(
                    color: AppColors.dangerBright,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bolt, color: AppColors.warning),
                title: const Text('Free time remaining'),
                trailing: Text(
                  _formatDuration(calc.freeTimeRemaining),
                  style: TextStyle(
                    color: calc.isFreeTimeExhausted
                        ? AppColors.dangerBright
                        : AppColors.success,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle('DATA'),
          _SettingsCard(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cloud_off, color: AppColors.textMuted),
                title: const Text('Storage'),
                subtitle: const Text('Data is stored locally on this device'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.sync_disabled, color: AppColors.textMuted),
                title: const Text('Cloud sync'),
                subtitle: const Text('Coming soon'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('RESET EVERYTHING'),
                  content: const Text(
                    'This permanently deletes your profile and starts fresh.\nThe clock does not care either way.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('RESET'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await LocalStorage.clearProfile();
                if (context.mounted) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerBright,
              side: const BorderSide(color: AppColors.danger, width: 1.5),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('RESET EVERYTHING'),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'DOOMSDAY CLOCK v1.0',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _editExpectancy(AppState appState, profile) {
    int current = profile.lifeExpectancyYears;
    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('LIFE EXPECTANCY'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$current YEARS',
                    style: const TextStyle(
                      color: AppColors.dangerBright,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Slider(
                    value: current.toDouble(),
                    min: 50,
                    max: 100,
                    divisions: 50,
                    label: '$current',
                    onChanged: (v) => setState(() => current = v.round()),
                  ),
                  const Text(
                    'Warning: lowering this makes your doom\nmore dramatic. Raising it is denial.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4),
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
                    appState.updateProfile(profile.copyWith(lifeExpectancyYears: current));
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

  String _formatDuration(Duration d) {
    final totalDays = d.inDays;
    final years = totalDays ~/ 365;
    final months = (totalDays % 365) ~/ 30;
    final days = (totalDays % 365) % 30;
    final parts = <String>[
      if (years > 0) '${years}y',
      if (months > 0) '${months}m',
      if (days > 0) '${days}d',
    ];
    return parts.isEmpty ? '0d' : parts.join(' ');
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: value.isEmpty
          ? null
          : Text(value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              )),
      onTap: onTap,
    );
  }
}
