import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/app_state.dart';
import '../services/local_storage_service.dart';
import '../theme/palette.dart';
import '../widgets/glass.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();
    final calc = appState.lifeCalculator;
    final profile = appState.profile;

    if (profile == null || calc == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    Text value(String v, {Color? color}) => Text(
          v,
          style: TextStyle(color: color ?? p.secondaryLabel, fontFeatures: AppText.tabular),
        );

    return GlassScaffold(
      title: 'Settings',
      children: [
        GlassGroup(
          header: 'Appearance',
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SegmentedPicker<int>(
                value: appState.themeMode,
                options: const {0: 'Dark', 1: 'Light', 2: 'Black'},
                onChanged: appState.setThemeMode,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        GlassGroup(
          header: 'Lifespan',
          footer: 'An estimate, not a promise. Set it to whatever feels honest.',
          children: [
            GlassRow(
              leading: RowIcon(CupertinoIcons.gift, color: p.accent),
              title: const Text('Date of birth'),
              trailing: value(DateFormat('d MMM y').format(profile.dateOfBirth)),
              showChevron: true,
              onTap: () => _editBirthday(context, appState, profile),
            ),
            GlassRow(
              leading: RowIcon(CupertinoIcons.heart, color: p.danger),
              title: const Text('Life expectancy'),
              trailing: value('${profile.lifeExpectancyYears} years'),
              showChevron: true,
              onTap: () => _editExpectancy(context, appState, profile),
            ),
            GlassRow(
              leading: RowIcon(CupertinoIcons.hourglass, color: p.warning),
              title: const Text('Days remaining'),
              trailing: value(NumberFormat.decimalPattern().format(int.parse(calc.daysLeft)), color: p.label),
            ),
          ],
        ),
        const SizedBox(height: 28),
        GlassGroup(
          header: 'Life so far',
          children: [
            GlassRow(
              title: const Text('Lived'),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: calc.percentageLived,
                    minHeight: 6,
                    backgroundColor: p.fieldFill,
                    valueColor: AlwaysStoppedAnimation(p.accent),
                  ),
                ),
              ),
              trailing: value('${(calc.percentageLived * 100).toStringAsFixed(1)}%', color: p.label),
            ),
            GlassRow(
              title: const Text('Time already spent'),
              trailing: value(_formatSpan(calc.lived)),
            ),
          ],
        ),
        const SizedBox(height: 28),
        GlassGroup(
          header: 'Today',
          children: [
            GlassRow(
              title: const Text('Free time today'),
              trailing: value(formatHm(calc.freeTimeToday)),
            ),
            GlassRow(
              title: const Text('Committed'),
              trailing: value('${formatHours(calc.totalAllocatedHoursPerDay)} a day'),
            ),
            GlassRow(
              title: const Text('Free time left'),
              trailing: value(
                formatHm(calc.freeTimeRemaining),
                color: calc.isFreeTimeExhausted ? p.danger : p.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        GlassGroup(
          header: 'Streaks',
          children: [
            GlassRow(
              leading: RowIcon(CupertinoIcons.flame_fill, color: p.warning),
              title: const Text('Current'),
              trailing: value('${appState.currentStreak} days'),
            ),
            GlassRow(
              leading: RowIcon(CupertinoIcons.rosette, color: p.warning),
              title: const Text('Longest'),
              trailing: value('${appState.longestStreak} days'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        GlassGroup(
          header: 'Data',
          footer: 'Everything is stored on this device. Cloud sync is coming.',
          children: [
            GlassRow(
              title: Text('Reset everything', style: TextStyle(color: p.danger)),
              onTap: () => _confirmReset(context),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Center(
          child: Text('Doomsday Clock 2.0', style: AppText.caption.copyWith(color: p.tertiaryLabel)),
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Reset everything?'),
        content: const Text('This deletes your profile and starts onboarding again.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
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
  }

  void _editBirthday(BuildContext context, AppState appState, UserProfile profile) {
    var picked = profile.dateOfBirth;
    showGlassSheet<void>(
      context,
      title: 'Date of birth',
      builder: (sheetContext) {
        final p = sheetContext.palette;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: p.brightness,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: AppText.title3.copyWith(color: p.label),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: profile.dateOfBirth,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (v) => picked = v,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassButton(
              label: 'Save',
              expand: true,
              onPressed: () {
                appState.updateProfile(profile.copyWith(
                  dateOfBirth: DateTime(picked.year, picked.month, picked.day),
                ));
                Navigator.pop(sheetContext);
              },
            ),
          ],
        );
      },
    );
  }

  void _editExpectancy(BuildContext context, AppState appState, UserProfile profile) {
    var current = profile.lifeExpectancyYears;
    showGlassSheet<void>(
      context,
      title: 'Life expectancy',
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          final p = sheetContext.palette;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  '$current years',
                  style: AppText.largeTitle.copyWith(
                    color: p.label,
                    fontWeight: FontWeight.w300,
                    fontFeatures: AppText.tabular,
                  ),
                ),
              ),
              Slider(
                value: current.toDouble(),
                min: 50,
                max: 100,
                divisions: 50,
                label: '$current',
                onChanged: (v) => setSheet(() => current = v.round()),
              ),
              const SizedBox(height: 16),
              GlassButton(
                label: 'Save',
                expand: true,
                onPressed: () {
                  appState.updateProfile(profile.copyWith(lifeExpectancyYears: current));
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatSpan(Duration d) {
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
