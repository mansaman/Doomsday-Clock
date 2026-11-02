import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/palette.dart';
import '../widgets/glass.dart';

class TimerStopwatchScreen extends StatefulWidget {
  const TimerStopwatchScreen({super.key});

  @override
  State<TimerStopwatchScreen> createState() => _TimerStopwatchScreenState();
}

class _TimerStopwatchScreenState extends State<TimerStopwatchScreen> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: _mode == 0 ? 'Timer' : 'Stopwatch',
      children: [
        SegmentedPicker<int>(
          value: _mode,
          options: const {0: 'Timer', 1: 'Stopwatch'},
          onChanged: (v) => setState(() => _mode = v),
        ),
        const SizedBox(height: 20),
        // IndexedStack keeps a running timer alive while the stopwatch is shown.
        IndexedStack(
          index: _mode,
          children: const [_CountdownTimer(), _Stopwatch()],
        ),
      ],
    );
  }
}

class _BigReadout extends StatelessWidget {
  const _BigReadout({required this.text, required this.caption, this.color});

  final String text;
  final String caption;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GlassPanel(
      radius: 28,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuart,
              style: TextStyle(
                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                fontSize: 88,
                fontWeight: FontWeight.w200,
                letterSpacing: -3,
                height: 1.05,
                color: color ?? p.label,
                fontFeatures: AppText.tabular,
              ),
              child: Text(text),
            ),
          ),
          const SizedBox(height: 8),
          Text(caption, style: AppText.subhead.copyWith(color: color ?? p.secondaryLabel)),
        ],
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  const _CountdownTimer();

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Timer? _timer;
  int _presetMinutes = 25;
  Duration _remaining = const Duration(minutes: 25);
  bool _running = false;

  static const _presets = {5: '5m', 15: '15m', 25: '25m', 45: '45m', 60: '1h'};

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    HapticFeedback.mediumImpact();
    if (_remaining == Duration.zero) _remaining = Duration(minutes: _presetMinutes);
    setState(() => _running = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _pause(haptic: false);
        _onComplete();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _pause({bool haptic = true}) {
    if (haptic) HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _remaining = Duration(minutes: _presetMinutes);
      _running = false;
    });
  }

  void _onComplete() {
    HapticFeedback.heavyImpact();
    setState(() => _remaining = Duration.zero);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Time\'s up. Take a breath, then pick the next thing.')),
    );
  }

  void _setPreset(int minutes) {
    _timer?.cancel();
    setState(() {
      _presetMinutes = minutes;
      _remaining = Duration(minutes: minutes);
      _running = false;
    });
  }

  String get _display {
    final m = _remaining.inMinutes.toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final done = _remaining == Duration.zero;
    final closing = _running && _remaining.inSeconds <= 60;
    final caption = done
        ? 'Done'
        : _running
            ? (closing ? 'Final minute' : 'Focus')
            : 'Ready when you are';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedPicker<int>(
          value: _presetMinutes,
          options: _presets,
          onChanged: _setPreset,
        ),
        const SizedBox(height: 16),
        _BigReadout(
          text: _display,
          caption: caption,
          color: done || closing ? p.warning : null,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: 'Reset',
                style: GlassButtonStyle.tinted,
                color: p.secondaryLabel,
                expand: true,
                onPressed: _reset,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GlassButton(
                label: _running ? 'Pause' : 'Start',
                icon: _running ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                expand: true,
                onPressed: _running ? _pause : _start,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stopwatch extends StatefulWidget {
  const _Stopwatch();

  @override
  State<_Stopwatch> createState() => _StopwatchState();
}

class _StopwatchState extends State<_Stopwatch> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final List<Duration> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_stopwatch.isRunning) {
      HapticFeedback.lightImpact();
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      HapticFeedback.mediumImpact();
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
    setState(() {});
  }

  void _reset() {
    HapticFeedback.lightImpact();
    _stopwatch
      ..stop()
      ..reset();
    _timer?.cancel();
    setState(() => _laps.clear());
  }

  void _lap() {
    HapticFeedback.selectionClick();
    setState(() => _laps.insert(0, _stopwatch.elapsed));
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final cs = ((d.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$m:$s.$cs';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final running = _stopwatch.isRunning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BigReadout(
          text: _format(_stopwatch.elapsed),
          caption: running ? 'Running' : (_stopwatch.elapsed == Duration.zero ? 'Ready' : 'Paused'),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                label: running ? 'Lap' : 'Reset',
                style: GlassButtonStyle.tinted,
                color: p.secondaryLabel,
                expand: true,
                onPressed: running ? _lap : (_stopwatch.elapsed == Duration.zero ? null : _reset),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GlassButton(
                label: running ? 'Stop' : 'Start',
                icon: running ? CupertinoIcons.stop_fill : CupertinoIcons.play_fill,
                expand: true,
                onPressed: _toggle,
              ),
            ),
          ],
        ),
        if (_laps.isNotEmpty) ...[
          const SizedBox(height: 28),
          GlassGroup(
            header: 'Laps',
            children: [
              for (var i = 0; i < _laps.length; i++)
                GlassRow(
                  title: Text('Lap ${_laps.length - i}'),
                  trailing: Text(
                    _format(_laps[i]),
                    style: TextStyle(color: p.label, fontFeatures: AppText.tabular),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
