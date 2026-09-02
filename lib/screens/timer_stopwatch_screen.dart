import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TimerStopwatchScreen extends StatefulWidget {
  const TimerStopwatchScreen({super.key});

  @override
  State<TimerStopwatchScreen> createState() => _TimerStopwatchScreenState();
}

class _TimerStopwatchScreenState extends State<TimerStopwatchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TIMER & STOPWATCH'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.danger,
          labelColor: AppColors.dangerBright,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2),
          tabs: const [
            Tab(text: 'TIMER'),
            Tab(text: 'STOPWATCH'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _CountdownTimer(),
          _Stopwatch(),
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
  Duration _remaining = const Duration(minutes: 25);
  bool _running = false;

  static const _presets = <(String, int)>[
    ('5', 5),
    ('15', 15),
    ('25', 25),
    ('45', 45),
    ('60', 60),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _running = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 1) {
        _stop();
        _onComplete();
        return;
      }
      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _remaining = const Duration(minutes: 25);
      _running = false;
    });
  }

  void _onComplete() {
    setState(() => _remaining = Duration.zero);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('TIME IS UP. GET BACK TO WORK.'),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  void _setPreset(int minutes) {
    _timer?.cancel();
    setState(() {
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
    final urgent = _remaining.inMinutes < 5;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _presets.map((p) {
              return ChoiceChip(
                label: Text('${p.$2}m',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    )),
                selected: false,
                onSelected: (_) => _setPreset(p.$2),
                backgroundColor: AppColors.card,
                selectedColor: AppColors.danger,
                showCheckmark: false,
                side: const BorderSide(color: AppColors.border),
              );
            }).toList(),
          ),
          const Spacer(),
          Text(
            _display,
            style: TextStyle(
              color: urgent ? AppColors.dangerBright : AppColors.textPrimary,
              fontSize: 86,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              shadows: urgent
                  ? [
                      Shadow(
                        color: AppColors.danger.withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ]
                  : null,
            ),
          ),
          Text(
            _running
                ? (_remaining.inMinutes < 5 ? 'TIME IS BLEEDING OUT' : 'FOCUS. GO.')
                : (_remaining.inMinutes < 5 && !_running ? 'RESTART. NOW.' : 'READY WHEN YOU ARE'),
            style: TextStyle(
              color: urgent ? AppColors.dangerBright : AppColors.textMuted,
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('RESET'),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: _running ? _stop : _start,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'PAUSE' : 'START'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
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
  final List<String> _laps = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
        setState(() {});
      });
    }
    setState(() {});
  }

  void _reset() {
    _stopwatch
      ..stop()
      ..reset();
    _timer?.cancel();
    setState(() => _laps.clear());
  }

  void _lap() {
    setState(() => _laps.insert(0, _format(_stopwatch.elapsed)));
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds % 1000) ~/ 10;
    final msS = ms.toString().padLeft(2, '0');
    return '$m:$s.$msS';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Text(
            _format(_stopwatch.elapsed),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 76,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _reset,
                child: const Text('RESET'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _toggle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(_stopwatch.isRunning ? 'STOP' : 'START'),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: _stopwatch.isRunning ? _lap : null,
                child: const Text('LAP'),
              ),
            ],
          ),
          const Spacer(),
          if (_laps.isNotEmpty) ...[
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _laps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LAP ${_laps.length - index}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          _laps[index],
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else
            const Spacer(),
        ],
      ),
    );
  }
}
