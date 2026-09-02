import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DateTime _dateOfBirth = DateTime(2000, 1, 1);
  int _lifeExpectancy = 80;
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              if (_step == 0) _buildIntro()
              else if (_step == 1) _buildDobPicker()
              else if (_step == 2) _buildExpectancyPicker()
              else _buildCurrencyIntro(),
              const Spacer(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      children: [
        const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 64),
        const SizedBox(height: 24),
        Text(
          'DOOMSDAY\nCLOCK',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Like the movie IN TIME, your life is a clock\nthat runs out. And like the movie:\n'
          'your time is the only currency that matters.\n\n'
          'Every second you waste is money you\nwill never earn back.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildDobPicker() {
    return Column(
      children: [
        Text(
          'WHEN WERE YOU BORN?',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${_dateOfBirth.day}/${_dateOfBirth.month}/${_dateOfBirth.year}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dateOfBirth,
              firstDate: DateTime(1900),
              lastDate: DateTime.now().subtract(const Duration(days: 1)),
            );
            if (picked != null) {
              setState(() => _dateOfBirth = picked);
            }
          },
          icon: const Icon(Icons.calendar_today),
          label: const Text('SELECT DATE'),
        ),
        const SizedBox(height: 16),
        Text(
          'Using your birth date, we calculate exactly\nhow much time you have left.',
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

  Widget _buildExpectancyPicker() {
    return Column(
      children: [
        Text(
          'HOW LONG WILL YOU LIVE?',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '$_lifeExpectancy YEARS',
          style: const TextStyle(
            color: AppColors.dangerBright,
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _lifeExpectancy.toDouble(),
          min: 50,
          max: 100,
          divisions: 50,
          label: '$_lifeExpectancy years',
          onChanged: (v) => setState(() => _lifeExpectancy = v.round()),
        ),
        const SizedBox(height: 16),
        Text(
          'This is your estimated lifespan. Every day you\nwatch it drain away. Set it honestly.',
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

  Widget _buildCurrencyIntro() {
    return Column(
      children: [
        const Icon(Icons.account_balance_wallet, color: AppColors.danger, size: 56),
        const SizedBox(height: 24),
        Text(
          'YOUR TIME IS\nYOUR CURRENCY',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Every day, you pay for life with your time.\n\n'
          '8h of sleep. 9h at work. 2h commuting.\nThat money is already gone before you wake.\n\n'
          'We calculate exactly how much FREE TIME\nyou own today.\n'
          'And we watch every second of it drain away.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        if (_step > 0)
          TextButton(
            onPressed: () => setState(() => _step--),
            child: Text(
              'BACK',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                letterSpacing: 2,
              ),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _next,
            child: Text(_step == 3 ? 'BEGIN' : 'CONTINUE'),
          ),
        ),
      ],
    );
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      final appState = context.read<AppState>();
      appState.completeOnboarding(
        dateOfBirth: DateTime(_dateOfBirth.year, _dateOfBirth.month, _dateOfBirth.day),
        lifeExpectancyYears: _lifeExpectancy,
      );
    }
  }
}
