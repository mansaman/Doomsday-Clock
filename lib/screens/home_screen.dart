import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/analog_clock/clock_painter.dart';
import '../widgets/life_countdown.dart';
import '../widgets/flash_reminder_overlay.dart';
import 'tasks_screen.dart';
import 'notes_screen.dart';
import 'alarms_screen.dart';
import 'allocations_screen.dart';
import 'timer_stopwatch_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final calc = appState.lifeCalculator;
    if (calc == null) return const SizedBox.shrink();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.screenGradient,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 272,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size.square(272),
                          painter: GlowPainter(),
                        ),
                        AnalogClock(dateTime: _now, size: 252),
                        Positioned(
                          bottom: 26,
                          child: Text(
                            '${_now.hour.toString().padLeft(2, '0')}:'
                            '${_now.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LifeCountdown(calculator: calc, now: _now),
                  const SizedBox(height: 28),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildUrgentReminders(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom, color: AppColors.danger, size: 26),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DOOMSDAY',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
              Text(
                'TIME IS RUNNING OUT',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final appState = context.watch<AppState>();
    final free = appState.lifeCalculator?.freeTimeToday.inHours ?? 0;
    final alloc = appState.totalAllocatedHoursPerDay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllocationsScreen()),
            ),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A1F1F), Color(0xFFB71C1C)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.danger.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Colors.white, size: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR TIME WALLET',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$alloc h/day lost to obligations. '
                          '$free h free. Spend them.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.check_circle_outline,
                  label: 'TASKS',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TasksScreen()),
                  ),
                ),
              ),
              Expanded(
                child: _QuickAction(
                  icon: Icons.lightbulb_outline,
                  label: 'NOTES',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotesScreen()),
                  ),
                ),
              ),
              Expanded(
                child: _QuickAction(
                  icon: Icons.notifications_none,
                  label: 'ALARMS',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlarmsScreen()),
                  ),
                ),
              ),
              Expanded(
                child: _QuickAction(
                  icon: Icons.timer_outlined,
                  label: 'TIMER',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TimerStopwatchScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentReminders(BuildContext context) {
    final appState = context.watch<AppState>();
    final reminders = appState.pinnedNotes.where((n) => n.flashIntervalMinutes != null).toList();
    if (reminders.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            Icon(Icons.bolt_outlined, color: AppColors.textMuted, size: 28),
            const SizedBox(height: 8),
            Text(
              'No urgent reminders yet.\nAdd a pinned note with a flash interval\nto keep yourself on track.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }
    return FlashReminderOverlay(notes: reminders);
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.dangerBright, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.glowStrong,
          AppColors.glow,
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
