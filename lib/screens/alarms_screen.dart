import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/alarm.dart';
import '../services/app_state.dart';
import '../theme/palette.dart';
import '../widgets/glass.dart';

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({super.key});

  static const _presets = <(String, int)>[
    ('5m', 5),
    ('15m', 15),
    ('30m', 30),
    ('1h', 60),
  ];

  void _addIn(BuildContext context, int minutes) {
    HapticFeedback.mediumImpact();
    final at = DateTime.now().add(Duration(minutes: minutes));
    context.read<AppState>().addAlarm(hour: at.hour, minute: at.minute, message: 'Back to it');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alarm set for ${minutes >= 60 ? '1 hour' : '$minutes minutes'} from now')),
    );
  }

  void _addCustom(BuildContext context) {
    var selected = DateTime.now();
    final messageCtrl = TextEditingController();

    showGlassSheet<void>(
      context,
      title: 'New alarm',
      builder: (sheetContext) {
        final p = sheetContext.palette;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 180,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: p.brightness,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: AppText.title3.copyWith(color: p.label),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selected,
                  onDateTimeChanged: (v) => selected = v,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              style: AppText.body.copyWith(color: p.label),
              decoration: const InputDecoration(hintText: 'Label (optional)'),
            ),
            const SizedBox(height: 16),
            GlassButton(
              label: 'Add alarm',
              expand: true,
              onPressed: () {
                HapticFeedback.mediumImpact();
                final msg = messageCtrl.text.trim();
                context.read<AppState>().addAlarm(
                      hour: selected.hour,
                      minute: selected.minute,
                      message: msg.isEmpty ? 'Back to it' : msg,
                    );
                Navigator.pop(sheetContext);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();

    return GlassScaffold(
      title: 'Alarms',
      actions: [
        GlassIconButton(
          icon: CupertinoIcons.plus,
          tooltip: 'New alarm',
          onPressed: () => _addCustom(context),
        ),
      ],
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'Quick alarm from now',
            style: AppText.footnote.copyWith(color: p.secondaryLabel, fontWeight: FontWeight.w500),
          ),
        ),
        Row(
          children: [
            for (var i = 0; i < _presets.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: GlassButton(
                  label: _presets[i].$1,
                  style: GlassButtonStyle.tinted,
                  expand: true,
                  onPressed: () => _addIn(context, _presets[i].$2),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 28),
        if (appState.alarms.isEmpty)
          const EmptyState(
            icon: CupertinoIcons.alarm,
            title: 'No alarms',
            message: 'Use a quick alarm to pull yourself back in a few minutes, or tap + to pick a time.',
          )
        else
          GlassGroup(
            children: [for (final a in appState.alarms) _AlarmRow(alarm: a)],
          ),
      ],
    );
  }
}

class _AlarmRow extends StatelessWidget {
  const _AlarmRow({required this.alarm});

  final AppAlarm alarm;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.read<AppState>();
    final color = alarm.isActive ? p.label : p.tertiaryLabel;

    return GlassRow(
      title: Text(
        alarm.timeLabel,
        style: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w300,
          letterSpacing: -1,
          color: color,
          fontFeatures: AppText.tabular,
        ),
      ),
      subtitle: Text(alarm.message),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoSwitch(
            value: alarm.isActive,
            activeTrackColor: p.accent,
            onChanged: (_) {
              HapticFeedback.selectionClick();
              appState.toggleAlarm(alarm.id);
            },
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: () {
              HapticFeedback.lightImpact();
              appState.removeAlarm(alarm.id);
            },
            icon: Icon(CupertinoIcons.trash, size: 20, color: p.tertiaryLabel),
          ),
        ],
      ),
    );
  }
}
