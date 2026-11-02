import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/palette.dart';
import '../widgets/glass.dart';
import '../services/app_state.dart';
import '../services/life_expectancy_predictor.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DateTime _dateOfBirth = DateTime(2000, 1, 1);
  int _lifeExpectancy = 80;

  // Predictor inputs
  String _gender = 'unknown';
  bool _smoker = false;
  bool _exercisesRegularly = true;
  bool _healthyDiet = true;
  bool _managesStress = false;

  int _step = 0;

  void _next() {
    if (_step < 4) {
      setState(() => _step++);
    } else {
      final appState = context.read<AppState>();
      appState.completeOnboarding(
        dateOfBirth: DateTime(_dateOfBirth.year, _dateOfBirth.month, _dateOfBirth.day),
        lifeExpectancyYears: _lifeExpectancy,
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  void _recalculate() {
    final now = DateTime.now();
    final age = now.year - _dateOfBirth.year -
        (now.month < _dateOfBirth.month || (now.month == _dateOfBirth.month && now.day < _dateOfBirth.day) ? 1 : 0);
    _lifeExpectancy = LifeExpectancyPredictor.predict(
      age: age,
      gender: _gender,
      smoker: _smoker,
      exercisesRegularly: _exercisesRegularly,
      healthyDiet: _healthyDiet,
      managesStress: _managesStress,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.canvas,
      body: Stack(
        children: [
          const Positioned.fill(child: GlassBackdrop(urgencyOverride: 0)),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProgress(p),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutQuart,
                              switchOutCurve: Curves.easeOutQuart,
                              transitionBuilder: (child, animation) => FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.04, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                              child: KeyedSubtree(
                                key: ValueKey<int>(_step),
                                child: _buildStepContent(p),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _buildFooter(p),
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

  Widget _buildProgress(Palette p) {
    return Semantics(
      label: 'Step ${_step + 1} of 5',
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutQuart,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration: BoxDecoration(
                color: index <= _step ? p.label : p.fieldFill,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(Palette p) {
    switch (_step) {
      case 0: return _buildIntro(p);
      case 1: return _buildDobPicker(p);
      case 2: return _buildGenderPicker(p);
      case 3: return _buildLifestylePicker(p);
      default: return _buildResult(p);
    }
  }

  Widget _title(Palette p, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.largeTitle.copyWith(color: p.label)),
          const SizedBox(height: 8),
          Text(subtitle, style: AppText.callout.copyWith(color: p.secondaryLabel)),
        ],
      ),
    );
  }

  Widget _buildIntro(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 20),
          child: Icon(CupertinoIcons.hourglass, size: 48, color: p.label),
        ),
        _title(
          p,
          'Your time is\nyour currency',
          'Sleep, work and the commute are paid before you wake. '
              'Doomsday Clock shows the free time you actually own today, '
              'so you can choose what to spend it on.',
        ),
      ],
    );
  }

  Widget _buildDobPicker(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(p, 'When were you born?', 'Used to estimate your life bank. It stays on this device.'),
        GlassPanel(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            height: 200,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: p.brightness,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: AppText.title3.copyWith(color: p.label),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _dateOfBirth,
                minimumDate: DateTime(1900),
                maximumDate: DateTime.now(),
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    _dateOfBirth = newDate;
                    _recalculate();
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPicker(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(p, 'Biological sex', 'Life expectancy tables differ by sex. Skip it if you prefer.'),
        GlassGroup(
          children: [
            _genderOption(p, 'female', 'Female'),
            _genderOption(p, 'male', 'Male'),
            _genderOption(p, 'unknown', 'Prefer not to say'),
          ],
        ),
      ],
    );
  }

  Widget _genderOption(Palette p, String value, String label) {
    final selected = _gender == value;
    return GlassRow(
      title: Text(label),
      trailing: selected
          ? Icon(CupertinoIcons.checkmark_alt, color: p.accent, size: 22)
          : const SizedBox(width: 22),
      onTap: () {
        setState(() {
          _gender = value;
          _recalculate();
        });
      },
    );
  }

  Widget _buildLifestylePicker(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(p, 'Your habits', 'A rough adjustment. You can change the result later.'),
        GlassGroup(
          children: [
            _lifestyleToggle(p, 'Smoke', _smoker, (v) => _smoker = v),
            _lifestyleToggle(p, 'Exercise 3+ times a week', _exercisesRegularly, (v) => _exercisesRegularly = v),
            _lifestyleToggle(p, 'Eat mostly healthy', _healthyDiet, (v) => _healthyDiet = v),
            _lifestyleToggle(p, 'Manage stress well', _managesStress, (v) => _managesStress = v),
          ],
        ),
      ],
    );
  }

  Widget _lifestyleToggle(Palette p, String label, bool value, ValueChanged<bool> set) {
    return GlassRow(
      title: Text(label),
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: p.accent,
        onChanged: (v) => setState(() {
          set(v);
          _recalculate();
        }),
      ),
    );
  }

  Widget _buildResult(Palette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(p, 'Your life bank', _lifeSummary()),
        GlassPanel(
          radius: 28,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Column(
            children: [
              Text(
                '$_lifeExpectancy',
                style: TextStyle(
                  fontFamily: DefaultTextStyle.of(context).style.fontFamily,
                  fontSize: 88,
                  fontWeight: FontWeight.w200,
                  letterSpacing: -3,
                  height: 1.05,
                  color: p.label,
                  fontFeatures: AppText.tabular,
                ),
              ),
              Text('estimated years', style: AppText.subhead.copyWith(color: p.secondaryLabel)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GlassButton(
            label: 'Adjust habits',
            style: GlassButtonStyle.plain,
            compact: true,
            onPressed: () => setState(() => _step = 3),
          ),
        ),
      ],
    );
  }

  String _lifeSummary() {
    final now = DateTime.now();
    final age = now.year - _dateOfBirth.year -
        (now.month < _dateOfBirth.month || (now.month == _dateOfBirth.month && now.day < _dateOfBirth.day) ? 1 : 0);
    final yearsLeft = _lifeExpectancy - age;
    if (yearsLeft <= 0) return 'By this estimate you are living on bonus time. Make it count.';
    final daysLeft = yearsLeft * 365;
    return 'Roughly ${NumberFormat.decimalPattern().format(daysLeft)} days left. You can adjust this in Settings.';
  }

  Widget _buildFooter(Palette p) {
    return Row(
      children: [
        if (_step > 0) ...[
          GlassButton(
            label: 'Back',
            style: GlassButtonStyle.tinted,
            color: p.secondaryLabel,
            onPressed: _back,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: GlassButton(
            label: _step == 4 ? 'Start' : 'Continue',
            expand: true,
            onPressed: _next,
          ),
        ),
      ],
    );
  }
}
