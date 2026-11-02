import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/palette.dart';
import 'widgets/glass.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const DoomsdayClockApp());
}

class DoomsdayClockApp extends StatelessWidget {
  const DoomsdayClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          ThemeData theme;
          switch (appState.themeMode) {
            case 1:
              theme = AppTheme.light();
              break;
            case 2:
              theme = AppTheme.black();
              break;
            default:
              theme = AppTheme.dark();
          }
          return MaterialApp(
            title: 'Doomsday Clock',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: const RootGate(),
          );
        },
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
      return const _CinematicSplash();
    }
    final profile = appState.profile;
    if (profile == null || !profile.isOnboarded) {
      return const OnboardingScreen();
    }
    return const HomeScreen();
  }
}

class _CinematicSplash extends StatelessWidget {
  const _CinematicSplash();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      backgroundColor: p.canvas,
      body: Stack(
        children: [
          const Positioned.fill(child: GlassBackdrop(urgencyOverride: 0)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.hourglass, color: p.label, size: 44),
                const SizedBox(height: 16),
                Text('Doomsday Clock', style: AppText.title2.copyWith(color: p.label)),
                const SizedBox(height: 4),
                Text(
                  'Your time is your currency',
                  style: AppText.subhead.copyWith(color: p.secondaryLabel),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms, curve: Curves.easeOutQuart),
          ),
        ],
      ),
    );
  }
}
