import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() => _build(Palette.dark);
  static ThemeData light() => _build(Palette.light);
  static ThemeData black() => _build(Palette.black);

  static ThemeData _build(Palette p) {
    final base = p.isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: p.label,
      displayColor: p.label,
    );
    final fieldRadius = BorderRadius.circular(14);

    return base.copyWith(
      extensions: [p],
      scaffoldBackgroundColor: p.canvas,
      canvasColor: p.canvas,
      primaryColor: p.accent,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textTheme: textTheme,
      colorScheme: ColorScheme(
        brightness: p.brightness,
        primary: p.accent,
        onPrimary: p.onAccent,
        secondary: p.accent,
        onSecondary: p.onAccent,
        error: p.danger,
        onError: p.onAccent,
        surface: p.canvas,
        onSurface: p.label,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: p.brightness,
        primaryColor: p.accent,
        textTheme: CupertinoTextThemeData(
          dateTimePickerTextStyle: TextStyle(
            color: p.label,
            fontSize: 21,
            fontFamily: textTheme.bodyMedium?.fontFamily,
          ),
        ),
      ),
      dividerColor: p.separator,
      iconTheme: IconThemeData(color: p.secondaryLabel),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: 0.3),
        selectionHandleColor: p.accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.fieldFill,
        hintStyle: AppText.body.copyWith(color: p.tertiaryLabel),
        border: OutlineInputBorder(borderRadius: fieldRadius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: fieldRadius, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: p.accent.withValues(alpha: 0.6), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: AppText.headline,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.glassFillStrong.withValues(alpha: 1),
        contentTextStyle: AppText.subhead.copyWith(color: p.label),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.glassStroke),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: p.accent,
        inactiveTrackColor: p.fieldFill,
        thumbColor: p.isDark ? p.label : Colors.white,
        overlayColor: p.accent.withValues(alpha: 0.12),
        trackHeight: 4,
        valueIndicatorColor: p.accent,
        valueIndicatorTextStyle: AppText.footnote.copyWith(color: p.onAccent),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 2),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
