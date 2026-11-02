import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/app_state.dart';
import '../services/life_calculator.dart';
import '../theme/palette.dart';
import '../widgets/animated_pressable.dart';
import '../widgets/flash_reminder_overlay.dart';
import '../widgets/flip_clock.dart';
import '../widgets/glass.dart';
import 'alarms_screen.dart';
import 'allocations_screen.dart';
import 'notes_screen.dart';
import 'settings_screen.dart';
import 'tasks_screen.dart';
import 'timer_stopwatch_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  // Quarter-hour check-in banner.
  String? _alertMessage;
  Timer? _alertTimer;
  int _lastAlertMinute = -1;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      if (now.second != _now.second) setState(() => _now = now);
      _checkQuarterHour(now);
    });
  }

  void _checkQuarterHour(DateTime now) {
    final minute = now.minute;
    if (minute % 15 == 0 && minute != _lastAlertMinute) {
      _lastAlertMinute = minute;
      _showCheckIn();
    }
  }

  void _showCheckIn() {
    final calc = context.read<AppState>().lifeCalculator;
    if (calc == null) return;

    final left = formatHm(calc.freeTimeRemaining);
    final messages = calc.isFreeTimeExhausted
        ? ['Free time is spent for today. Wind down well.']
        : [
            'Fifteen minutes passed. $left of free time left today.',
            'Quarter-hour check: is this what you meant to spend it on?',
            'Another 15 minutes gone. Pick the next small step.',
            'Time check: $left free left today.',
          ];

    setState(() => _alertMessage = messages[DateTime.now().second % messages.length]);
    _alertTimer?.cancel();
    _alertTimer = Timer(const Duration(seconds: 5), _dismissCheckIn);
  }

  void _dismissCheckIn() {
    if (mounted) setState(() => _alertMessage = null);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _alertTimer?.cancel();
    super.dispose();
  }

  void _open(Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final calc = appState.lifeCalculator;
    if (calc == null) return const SizedBox.shrink();
    final p = context.palette;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: p.canvas,
        body: Stack(
          children: [
            const Positioned.fill(child: GlassBackdrop()),
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      16, 8, 16, 40 + MediaQuery.paddingOf(context).bottom,
                    ),
                    children: [
                      _TopBar(
                        now: _now,
                        streak: appState.currentStreak,
                        onSettings: () => _open(const SettingsScreen()),
                      ),
                      const SizedBox(height: 20),
                      GlassPanel(
                        radius: 28,
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                        child: Center(child: FlipClock(now: _now)),
                      ),
                      const SizedBox(height: 28),
                      _FreeTimeHero(calc: calc, now: _now),
                      const SizedBox(height: 32),
                      _UpNext(
                        tasks: appState.activeTasks,
                        onToggle: (t) {
                          HapticFeedback.mediumImpact();
                          appState.toggleTaskComplete(t.id);
                        },
                        onOpen: () => _open(const TasksScreen()),
                      ),
                      const SizedBox(height: 16),
                      _Dock(
                        items: [
                          _DockItem(CupertinoIcons.lightbulb, 'Notes', () => _open(const NotesScreen())),
                          _DockItem(CupertinoIcons.timer, 'Timer', () => _open(const TimerStopwatchScreen())),
                          _DockItem(CupertinoIcons.alarm, 'Alarms', () => _open(const AlarmsScreen())),
                          _DockItem(CupertinoIcons.creditcard, 'Wallet', () => _open(const AllocationsScreen())),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _LongView(
                        calc: calc,
                        allocatedHours: appState.totalAllocatedHoursPerDay,
                        onWallet: () => _open(const AllocationsScreen()),
                      ),
                      _Reminders(
                        notes: appState.pinnedNotes
                            .where((n) => n.flashIntervalMinutes != null)
                            .toList(),
                        onOpen: () => _open(const NotesScreen()),
                      ),
                      const SizedBox(height: 36),
                      _Quote(text: appState.todaysQuote, author: appState.todaysQuoteAuthor),
                    ],
                  ),
                ),
              ),
            ),
            if (_alertMessage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: _CheckInBanner(
                    message: _alertMessage!,
                    urgency: urgencyOf(calc),
                    onDismiss: _dismissCheckIn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.now, required this.streak, required this.onSettings});

  final DateTime now;
  final int streak;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Text('Doomsday', style: AppText.title2.copyWith(color: p.label)),
              if (streak > 0) ...[
                const SizedBox(width: 10),
                _StreakPill(streak: streak),
              ],
            ],
          ),
        ),
        GlassIconButton(
          icon: CupertinoIcons.gear_alt,
          tooltip: 'Settings',
          onPressed: onSettings,
        ),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: '$streak day streak',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: p.warning.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.flame_fill, size: 13, color: p.warning),
            const SizedBox(width: 3),
            Text(
              '$streak',
              style: AppText.caption.copyWith(color: p.warning, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// The one number that matters: free time left today.
class _FreeTimeHero extends StatelessWidget {
  const _FreeTimeHero({required this.calc, required this.now});

  final LifeCalculator calc;
  final DateTime now;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final urgency = urgencyOf(calc);
    final exhausted = calc.isFreeTimeExhausted;
    final free = calc.freeTimeRemaining;
    final tint = p.urgencyTint(urgency);
    final barColor = urgency >= 0.85 ? p.danger : (urgency >= 0.6 ? p.warning : p.accent);

    final midnight = DateTime(now.year, now.month, now.day + 1);
    final untilReset = midnight.difference(now);

    final String status;
    if (exhausted) {
      status = 'Today\'s free time is spent. It refills at midnight.';
    } else if (urgency >= 0.85) {
      status = 'Under ${formatHm(free)} left. Pick the one thing that matters.';
    } else {
      status = 'of ${formatHm(calc.freeTimeToday)} free today';
    }

    return Semantics(
      label: 'Free time left today: ${formatHm(free)}',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              'Free time left today',
              style: AppText.subhead.copyWith(color: p.secondaryLabel, fontWeight: FontWeight.w500),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutQuart,
              style: TextStyle(
                fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                fontSize: 72,
                height: 1.1,
                fontWeight: FontWeight.w300,
                letterSpacing: -2,
                color: tint,
                fontFeatures: AppText.tabular,
              ),
              child: Text('${free.inHours}:${_two(free.inMinutes % 60)}'),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: p.fieldFill)),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: calc.freeTimePercentageRemaining.clamp(0.0, 1.0),
                        heightFactor: 1,
                        child: ColoredBox(color: barColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  status,
                  style: AppText.footnote.copyWith(
                    color: urgency >= 0.85 ? tint : p.secondaryLabel,
                    fontWeight: urgency >= 0.85 ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Resets in ${formatHm(untilReset)}',
                style: AppText.footnote.copyWith(
                  color: p.tertiaryLabel,
                  fontFeatures: AppText.tabular,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpNext extends StatelessWidget {
  const _UpNext({required this.tasks, required this.onToggle, required this.onOpen});

  final List<WorkTask> tasks;
  final ValueChanged<WorkTask> onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GlassGroup(
      header: 'Up next',
      trailingHeader: GestureDetector(
        onTap: onOpen,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Text(
            tasks.isEmpty ? 'Add' : 'All tasks',
            style: AppText.footnote.copyWith(color: p.accent, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      children: tasks.isEmpty
          ? [
              GlassRow(
                leading: RowIcon(CupertinoIcons.plus, color: p.accent),
                title: const Text('Add your first task'),
                subtitle: const Text('Keep it to three so the next step is obvious.'),
                onTap: onOpen,
              ),
            ]
          : [
              for (final t in tasks.take(3))
                GlassRow(
                  leading: _CheckCircle(done: t.isCompleted, onTap: () => onToggle(t)),
                  title: Text(t.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: t.allocatedMinutes == null
                      ? null
                      : Text('Budget ${formatHm(Duration(minutes: t.allocatedMinutes!))}'),
                  onTap: onOpen,
                ),
            ],
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done, required this.onTap});

  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      checked: done,
      label: done ? 'Mark as not done' : 'Mark as done',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 30,
          height: 44,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                done ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                key: ValueKey(done),
                size: 26,
                color: done ? p.success : p.tertiaryLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem {
  const _DockItem(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// One glass bar of shortcuts rather than a grid of identical cards.
class _Dock extends StatelessWidget {
  const _Dock({required this.items});
  final List<_DockItem> items;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: Semantics(
                button: true,
                label: item.label,
                excludeSemantics: true,
                child: AnimatedPressable(
                  onTap: item.onTap,
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Icon(item.icon, size: 24, color: p.label),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          style: AppText.caption.copyWith(color: p.secondaryLabel),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LongView extends StatelessWidget {
  const _LongView({required this.calc, required this.allocatedHours, required this.onWallet});

  final LifeCalculator calc;
  final double allocatedHours;
  final VoidCallback onWallet;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = calc.remaining;
    final totalDays = r.inDays;
    final years = totalDays ~/ 365;
    final months = (totalDays % 365) ~/ 30;
    final days = (totalDays % 365) % 30;

    return GlassGroup(
      header: 'The long view',
      children: [
        GlassRow(
          leading: RowIcon(CupertinoIcons.hourglass, color: p.accent),
          title: const Text('Life bank'),
          subtitle: Text('${years}y ${months}m ${days}d left'),
          trailing: Text(
            '${_two(r.inHours % 24)}:${_two(r.inMinutes % 60)}:${_two(r.inSeconds % 60)}',
            style: AppText.body.copyWith(
              color: p.secondaryLabel,
              fontFeatures: AppText.tabular,
            ),
          ),
        ),
        GlassRow(
          leading: RowIcon(CupertinoIcons.creditcard, color: p.warning),
          title: const Text('Time wallet'),
          subtitle: Text('${formatHours(allocatedHours)} a day goes to obligations'),
          showChevron: true,
          onTap: onWallet,
        ),
      ],
    );
  }
}

class _Reminders extends StatelessWidget {
  const _Reminders({required this.notes, required this.onOpen});

  final List notes;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: FlashReminderOverlay(notes: notes.cast(), onOpen: onOpen),
    );
  }
}

class _Quote extends StatelessWidget {
  const _Quote({required this.text, required this.author});

  final String text;
  final String author;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            '“$text”',
            textAlign: TextAlign.center,
            style: AppText.subhead.copyWith(color: p.secondaryLabel, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          Text(author, style: AppText.caption.copyWith(color: p.tertiaryLabel)),
        ],
      ),
    );
  }
}

class _CheckInBanner extends StatelessWidget {
  const _CheckInBanner({required this.message, required this.urgency, required this.onDismiss});

  final String message;
  final double urgency;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tint = urgency >= 0.85 ? p.danger : (urgency >= 0.6 ? p.warning : p.accent);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Semantics(
            liveRegion: true,
            child: GestureDetector(
              onTap: onDismiss,
              child: GlassPanel(
                fill: p.glassFillStrong,
                tint: tint,
                radius: 20,
                padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
                child: Row(
                  children: [
                    RowIcon(CupertinoIcons.clock, color: tint, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(message, style: AppText.subhead.copyWith(color: p.label)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms, curve: Curves.easeOutQuart)
        .slideY(begin: -0.4, end: 0, duration: 320.ms, curve: Curves.easeOutQuart);
  }
}
