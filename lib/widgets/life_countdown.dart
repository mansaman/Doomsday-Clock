import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/life_calculator.dart';

class LifeCountdown extends StatelessWidget {
  const LifeCountdown({super.key, required this.calculator, required this.now});

  final LifeCalculator calculator;
  final DateTime now;

  String _pad(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final remaining = calculator.remaining;
    final totalDays = remaining.inDays;
    final years = totalDays ~/ 365;
    final months = (totalDays % 365) ~/ 30;
    final days = (totalDays % 365) % 30;
    final hours = remaining.inHours % 24;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    final free = calculator.freeTimeRemaining;
    final freeHours = free.inHours;
    final freeMinutes = free.inMinutes % 60;
    final freeSeconds = free.inSeconds % 60;

    final exhausted = calculator.isFreeTimeExhausted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // THE TIME CURRENCY — your free time balance today
        _CurrencyPanel(
          freeHours: freeHours,
          freeMinutes: freeMinutes,
          freeSeconds: freeSeconds,
          exhausted: exhausted,
          percentage: calculator.freeTimePercentageRemaining,
          allocatedHours: calculator.totalAllocatedHoursPerDay,
        ),
        const SizedBox(height: 24),
        // Life countdown (smaller, secondary)
        Text(
          'YOUR LIFE BANK',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${years}y  ${months}m  ${days}d',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_pad(hours)}:${_pad(minutes)}:${_pad(seconds)}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _CurrencyPanel extends StatefulWidget {
  const _CurrencyPanel({
    required this.freeHours,
    required this.freeMinutes,
    required this.freeSeconds,
    required this.exhausted,
    required this.percentage,
    required this.allocatedHours,
  });

  final int freeHours;
  final int freeMinutes;
  final int freeSeconds;
  final bool exhausted;
  final double percentage;
  final double allocatedHours;

  @override
  State<_CurrencyPanel> createState() => _CurrencyPanelState();
}

class _CurrencyPanelState extends State<_CurrencyPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.6,
      upperBound: 1.0,
    );
    if (widget.exhausted) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_CurrencyPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.exhausted && !oldWidget.exhausted) {
      _pulse.repeat(reverse: true);
    } else if (!widget.exhausted && oldWidget.exhausted) {
      _pulse.stop();
      _pulse.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urgent = widget.freeMinutes < 30 && !widget.exhausted && widget.freeHours == 0;

    return FadeTransition(
      opacity: _pulse,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.exhausted
              ? AppColors.danger.withValues(alpha: 0.15)
              : AppColors.card.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.exhausted
                ? AppColors.danger
                : urgent
                    ? AppColors.warning
                    : AppColors.border,
            width: widget.exhausted ? 2 : 1,
          ),
          boxShadow: widget.exhausted
              ? [
                  BoxShadow(
                    color: AppColors.danger.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.exhausted
                      ? Icons.battery_alert
                      : urgent
                          ? Icons.battery_3_bar
                          : Icons.battery_full,
                  color: widget.exhausted
                      ? AppColors.dangerBright
                      : urgent
                          ? AppColors.warning
                          : AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.exhausted ? 'YOUR TIME IS UP TODAY' : 'FREE TIME TODAY',
                  style: TextStyle(
                    color: widget.exhausted
                        ? AppColors.dangerBright
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (widget.exhausted)
              const Text(
                'TODAY IS DONE. THE CLOCK STOPPED.\nYOU LET IT HAPPEN.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.dangerBright,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              )
            else
              Text(
                '${widget.freeHours}h ${widget.freeMinutes.toString().padLeft(2, '0')}m '
                '${widget.freeSeconds.toString().padLeft(2, '0')}s',
                style: TextStyle(
                  color: urgent ? AppColors.dangerBright : AppColors.textPrimary,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  shadows: urgent
                      ? [
                          Shadow(
                            color: AppColors.danger.withValues(alpha: 0.5),
                            blurRadius: 18,
                          ),
                        ]
                      : null,
                ),
              ),
            if (!widget.exhausted) ...[
              const SizedBox(height: 8),
              Text(
                '${widget.allocatedHours.toStringAsFixed(widget.allocatedHours % 1 == 0 ? 0 : 1)}h/day '
                'already spent on obligations',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: widget.percentage,
                  minHeight: 6,
                  backgroundColor: AppColors.cardHighlight,
                  valueColor: AlwaysStoppedAnimation(
                    urgent ? AppColors.danger : AppColors.warning,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
