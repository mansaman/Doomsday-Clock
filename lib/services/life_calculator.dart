import '../models/time_allocation.dart';

class LifeCalculator {
  LifeCalculator({
    required this.dateOfBirth,
    required this.lifeExpectancyYears,
    List<TimeAllocation>? allocations,
  }) : allocations = allocations ?? [] {
    _normalizeDate();
  }

  final DateTime dateOfBirth;
  final int lifeExpectancyYears;
  final List<TimeAllocation> allocations;

  static const int defaultLifeExpectancy = 80;
  static const int minutesPerDay = 1440;

  void _normalizeDate() {}

  DateTime get deathDate =>
      DateTime(dateOfBirth.year + lifeExpectancyYears, dateOfBirth.month, dateOfBirth.day);

  Duration get totalLifespan => deathDate.difference(dateOfBirth);

  Duration get remaining => deathDate.difference(DateTime.now()).isNegative
      ? Duration.zero
      : deathDate.difference(DateTime.now());

  Duration get lived => DateTime.now().difference(dateOfBirth).isNegative
      ? Duration.zero
      : DateTime.now().difference(dateOfBirth);

  double get percentageLived {
    if (totalLifespan.inMilliseconds == 0) return 0;
    return (lived.inMilliseconds / totalLifespan.inMilliseconds).clamp(0.0, 1.0);
  }

  double get percentageRemaining => 1.0 - percentageLived;

  /// Total hours consumed by active standing allocations per day.
  double get totalAllocatedHoursPerDay =>
      allocations.where((a) => a.isActive).fold(0.0, (sum, a) => sum + a.hoursPerDay);

  /// Free time owned today = total day hours - allocated standing time.
  /// Represents the time you actually control and can spend.
  Duration get freeTimeToday {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final dayTotalMinutes = endOfDay.difference(startOfDay).inMinutes;

    final allocatedMinutes = (totalAllocatedHoursPerDay * 60).round();
    final freeMinutes = (dayTotalMinutes - allocatedMinutes).clamp(0, dayTotalMinutes);
    return Duration(minutes: freeMinutes);
  }

  /// Minutes of free time already consumed today (based on time elapsed vs allocations).
  Duration get freeTimeElapsed {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final elapsedMinutes = now.difference(startOfDay).inMinutes;

    final allocatedMinutes = (totalAllocatedHoursPerDay * 60).round();
    // Elapsed free = elapsed total - allocated (clamped so it never counts sleep hours as spent free time before they're actually needed)
    // Simple model: free time consumed = max(0, elapsed - allocated)
    final freeElapsed = (elapsedMinutes - allocatedMinutes).clamp(0, 1440);
    return Duration(minutes: freeElapsed);
  }

  /// Remaining free time today (the urgent number).
  Duration get freeTimeRemaining {
    final remaining = freeTimeToday - freeTimeElapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get freeTimePercentageRemaining {
    final total = freeTimeToday.inMinutes;
    if (total == 0) return 0;
    final remaining = freeTimeRemaining.inMinutes.clamp(0, total);
    return remaining / total;
  }

  bool get isFreeTimeExhausted =>
      freeTimeRemaining == Duration.zero && freeTimeToday > Duration.zero;

  /// The percentage of remaining LIFE that a given number of minutes represents.
  double lifeCostPercentage(int minutes) {
    if (remaining.inMinutes == 0) return 0;
    return (minutes / remaining.inMinutes * 100).clamp(0.0, 100.0);
  }

  String get remainingFormatted {
    final r = remaining;
    final totalDays = r.inDays;
    final years = totalDays ~/ 365;
    final months = (totalDays % 365) ~/ 30;
    final days = (totalDays % 365) % 30;
    final hours = r.inHours % 24;
    final minutes = r.inMinutes % 60;
    final seconds = r.inSeconds % 60;

    return '${years}y  ${months}m  ${days}d\n${_pad(hours)}h  ${_pad(minutes)}m  ${_pad(seconds)}s';
  }

  String get yearsLeft => (remaining.inDays / 365).toStringAsFixed(1);

  String get daysLeft => remaining.inDays.toString();

  String _pad(int n) => n.toString().padLeft(2, '0');
}
