import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color card = Color(0xFF1C1C1E);
  static const Color cardHighlight = Color(0xFF242426);

  static const Color clockFace = Color(0xFF101012);
  static const Color clockRing = Color(0xFF333333);
  static const Color tickMark = Color(0xFF555555);

  static const Color danger = Color(0xFFE53935);
  static const Color dangerBright = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFF9800);

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF6E6E6E);
  static const Color textDanger = Color(0xFFFF6B6B);

  static const Color glow = Color(0x33E53935);
  static const Color glowStrong = Color(0x66E53935);

  static const Color hourHand = Color(0xFFD32F2F);
  static const Color minuteHand = Color(0xFFB71C1C);
  static const Color secondHand = Color(0xFFFF5252);

  static const Color success = Color(0xFF4CAF50);
  static const Color border = Color(0xFF2A2A2A);

  static const Gradient screenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D0D0F),
      Color(0xFF0A0A0A),
    ],
  );

  static const Gradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE53935),
      Color(0xFFD32F2F),
    ],
  );
}
