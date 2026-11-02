import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/time_allocation.dart';
import '../services/app_state.dart';
import '../theme/palette.dart';
import '../widgets/glass.dart';

class AllocationsScreen extends StatelessWidget {
  const AllocationsScreen({super.key});

  static const _icons = ['S', 'J', 'C', 'R', 'E', 'M', 'W', 'H', 'G', 'P'];

  void _openEditor(BuildContext context, {TimeAllocation? existing}) {
    final appState = context.read<AppState>();
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    var hours = existing?.hoursPerDay ?? 2.0;
    var icon = existing?.icon ?? _icons.first;

    showGlassSheet<void>(
      context,
      title: existing == null ? 'New obligation' : 'Edit obligation',
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          final p = sheetContext.palette;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: existing == null,
                style: AppText.body.copyWith(color: p.label),
                decoration: const InputDecoration(hintText: 'Sleep, work, commute, gym'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Per day', style: AppText.subhead.copyWith(color: p.secondaryLabel)),
                  const Spacer(),
                  Text(
                    formatHours(hours),
                    style: AppText.title3.copyWith(color: p.label, fontFeatures: AppText.tabular),
                  ),
                ],
              ),
              Slider(
                value: hours,
                min: 0.5,
                max: 12,
                divisions: 23,
                label: formatHours(hours),
                onChanged: (v) => setSheet(() => hours = v),
              ),
              const SizedBox(height: 4),
              Text('Badge', style: AppText.subhead.copyWith(color: p.secondaryLabel)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final i in _icons)
                    Semantics(
                      button: true,
                      selected: i == icon,
                      label: 'Badge $i',
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheet(() => icon = i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: i == icon ? p.accent : p.fieldFill,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            i,
                            style: AppText.headline.copyWith(
                              color: i == icon ? p.onAccent : p.label,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              GlassButton(
                label: existing == null ? 'Add' : 'Save',
                expand: true,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  final name = nameCtrl.text.trim();
                  if (existing == null) {
                    appState.addAllocation(
                      name: name.isEmpty ? 'Obligation' : name,
                      hoursPerDay: hours,
                      icon: icon,
                    );
                  } else {
                    appState.updateAllocation(TimeAllocation(
                      id: existing.id,
                      name: name.isEmpty ? existing.name : name,
                      hoursPerDay: hours,
                      icon: icon,
                      isActive: existing.isActive,
                    ));
                  }
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final appState = context.watch<AppState>();
    final total = appState.totalAllocatedHoursPerDay;
    final free = 24 - total;
    final over = free < 0;

    return GlassScaffold(
      title: 'Time wallet',
      subtitle: const Text('What every day costs before it starts'),
      actions: [
        GlassIconButton(
          icon: CupertinoIcons.plus,
          tooltip: 'New obligation',
          onPressed: () => _openEditor(context),
        ),
      ],
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _Stat(label: 'Committed', value: formatHours(total), color: p.warning)),
                  Expanded(
                    child: _Stat(
                      label: 'Yours',
                      value: formatHours(free < 0 ? 0 : free),
                      color: over ? p.danger : p.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      if (total > 0)
                        Expanded(
                          flex: (total.clamp(0, 24) * 10).round().clamp(1, 240),
                          child: ColoredBox(color: over ? p.danger : p.warning),
                        ),
                      if (free > 0)
                        Expanded(
                          flex: (free * 10).round().clamp(1, 240),
                          child: ColoredBox(color: p.accent),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                over
                    ? 'These add up to more than 24 hours. Trim one to balance the day.'
                    : 'Out of 24 hours. Turn an obligation off to see what you would get back.',
                style: AppText.footnote.copyWith(color: over ? p.danger : p.secondaryLabel),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (appState.allocations.isEmpty)
          const EmptyState(
            icon: CupertinoIcons.creditcard,
            title: 'No obligations yet',
            message: 'Add sleep, work and commute so your free time is honest.',
          )
        else
          GlassGroup(
            header: 'Obligations',
            children: [
              for (final a in appState.allocations)
                GlassRow(
                  leading: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (a.isActive ? p.warning : p.tertiaryLabel).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      a.icon,
                      style: AppText.headline.copyWith(color: a.isActive ? p.warning : p.tertiaryLabel),
                    ),
                  ),
                  title: Text(
                    a.name,
                    style: a.isActive ? null : TextStyle(color: p.tertiaryLabel),
                  ),
                  subtitle: Text('${formatHours(a.hoursPerDay)} a day'),
                  onTap: () => _openEditor(context, existing: a),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CupertinoSwitch(
                        value: a.isActive,
                        activeTrackColor: p.accent,
                        onChanged: (_) {
                          HapticFeedback.selectionClick();
                          appState.updateAllocation(a.copyWith(isActive: !a.isActive));
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          appState.removeAllocation(a.id);
                        },
                        icon: Icon(CupertinoIcons.trash, size: 20, color: p.tertiaryLabel),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppText.footnote.copyWith(color: p.secondaryLabel)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppText.largeTitle.copyWith(
            color: p.label,
            fontWeight: FontWeight.w300,
            fontFeatures: AppText.tabular,
          ),
        ),
      ],
    );
  }
}
