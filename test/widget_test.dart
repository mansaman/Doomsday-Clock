import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:doomsday_clock/main.dart';
import 'package:doomsday_clock/services/app_state.dart';
import 'package:doomsday_clock/services/life_calculator.dart';

void main() {
  test('LifeCalculator computes remaining time correctly', () {
    final dob = DateTime(1990, 1, 1);
    final calculator = LifeCalculator(
      dateOfBirth: dob,
      lifeExpectancyYears: 80,
    );

    expect(calculator.deathDate, DateTime(2070, 1, 1));
    expect(calculator.percentageLived, greaterThan(0.0));
    expect(calculator.percentageLived, lessThan(1.0));
  });

  testWidgets('Shows onboarding splash first', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: const RootGate(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Doomsday Clock'), findsOneWidget);

    // Unmount so the splash fade and backdrop refresh timers are disposed.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
