import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DoomsdayClockApp());
}

class DoomsdayClockApp extends StatelessWidget {
  const DoomsdayClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Doomsday Clock',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const RootGate(),
      ),
    );
  }
}

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isReady) {
      // While profile loads
      return const _SplashScreen();
    }
    final profile = appState.profile;
    if (profile == null || !profile.isOnboarded) {
      return const OnboardingScreen();
    }
    return const HomeScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_bottom, color: Colors.redAccent, size: 56),
            SizedBox(height: 16),
            Text(
              'DOOMSDAY CLOCK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
