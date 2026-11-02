import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../models/note.dart';
import '../theme/palette.dart';
import 'glass.dart';

/// Shows how many pinned reminders are armed, and swaps to a highlighted
/// glass card when one of them comes due.
class FlashReminderOverlay extends StatefulWidget {
  const FlashReminderOverlay({super.key, required this.notes, this.onOpen});

  final List<QuickNote> notes;
  final VoidCallback? onOpen;

  @override
  State<FlashReminderOverlay> createState() => _FlashReminderOverlayState();
}

class _FlashReminderOverlayState extends State<FlashReminderOverlay> {
  QuickNote? _currentNote;
  final List<Timer> _timers = [];
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleFlashing();
  }

  @override
  void didUpdateWidget(FlashReminderOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notes.length != widget.notes.length) {
      _cancelTimers();
      _scheduleFlashing();
    }
  }

  void _scheduleFlashing() {
    for (final note in widget.notes) {
      final interval = note.flashIntervalMinutes;
      if (interval == null || interval <= 0) continue;
      _timers.add(Timer.periodic(Duration(minutes: interval), (_) => _showFlash(note)));
    }
  }

  void _showFlash(QuickNote note) {
    if (!mounted || _currentNote != null) return;
    setState(() => _currentNote = note);
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _currentNote = null);
    });
  }

  void _cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  @override
  void dispose() {
    _cancelTimers();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final note = _currentNote;
    final count = widget.notes.length;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeOutQuart,
      child: note == null
          ? GlassGroup(
              key: const ValueKey('idle'),
              children: [
                GlassRow(
                  leading: RowIcon(CupertinoIcons.bolt_fill, color: p.warning),
                  title: Text('$count reminder${count == 1 ? '' : 's'} armed'),
                  subtitle: const Text('Pinned notes resurface at their interval'),
                  showChevron: widget.onOpen != null,
                  onTap: widget.onOpen,
                ),
              ],
            )
          : Semantics(
              key: ValueKey(note.id),
              liveRegion: true,
              child: GlassPanel(
                tint: p.warning,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RowIcon(CupertinoIcons.bolt_fill, color: p.warning, size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminder',
                            style: AppText.footnote.copyWith(
                              color: p.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(note.content, style: AppText.headline.copyWith(color: p.label)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
