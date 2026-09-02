import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/app_colors.dart';

/// Shows pinned notes as flashing overlays that appear at their configured
/// flash intervals. Designed to be placed on the home screen.
class FlashReminderOverlay extends StatefulWidget {
  const FlashReminderOverlay({super.key, required this.notes});

  final List<QuickNote> notes;

  @override
  State<FlashReminderOverlay> createState() => _FlashReminderOverlayState();
}

class _FlashReminderOverlayState extends State<FlashReminderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _visible = false;
  QuickNote? _currentNote;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
      final timer = Timer.periodic(
        Duration(minutes: interval),
        (_) => _showFlash(note),
      );
      _timers.add(timer);
    }
  }

  void _showFlash(QuickNote note) {
    if (!mounted || _visible) return;
    setState(() {
      _currentNote = note;
      _visible = true;
    });
    _controller.forward(from: 0);
    Timer(const Duration(seconds: 5), () {
      if (mounted) _hideFlash();
    });
  }

  void _hideFlash() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _visible = false);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible || _currentNote == null) {
      return Column(
        children: [
          Icon(Icons.notifications_active_outlined, color: AppColors.textMuted, size: 26),
          const SizedBox(height: 8),
          Text(
            '${widget.notes.length} reminder${widget.notes.length == 1 ? '' : 's'} armed\nflashing on screen at intervals',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      );
    }

    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.dangerBright, size: 30),
            const SizedBox(height: 10),
            Text(
              'REMINDER',
              style: TextStyle(
                color: AppColors.dangerBright,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentNote!.content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
