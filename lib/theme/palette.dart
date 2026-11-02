import 'package:flutter/material.dart';

/// Semantic color tokens for the glass design system.
///
/// Screens read colors through `context.palette` so dark, light and black
/// modes stay consistent. Neutrals are tinted slightly toward indigo.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.brightness,
    required this.canvas,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassStroke,
    required this.glassHighlight,
    required this.fieldFill,
    required this.separator,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.accent,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.backdropAlpha,
  });

  final Brightness brightness;

  /// Base color behind the backdrop blobs.
  final Color canvas;

  /// Default panel fill. Opaque enough to hold AA contrast over any blob.
  final Color glassFill;

  /// Fill for sheets and banners that sit above other glass.
  final Color glassFillStrong;

  /// Hairline border around panels.
  final Color glassStroke;

  /// Top edge sheen on panels.
  final Color glassHighlight;

  final Color fieldFill;
  final Color separator;

  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;

  final Color accent;
  final Color onAccent;
  final Color success;
  final Color warning;
  final Color danger;

  /// Strength of the colored backdrop blobs.
  final double backdropAlpha;

  bool get isDark => brightness == Brightness.dark;

  static const dark = Palette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0C0C14),
    glassFill: Color(0x8C1C1C28),
    glassFillStrong: Color(0xD91E1E2A),
    glassStroke: Color(0x1FFFFFFF),
    glassHighlight: Color(0x14FFFFFF),
    fieldFill: Color(0x14F2F2FA),
    separator: Color(0x1FEBEBF5),
    label: Color(0xFFF4F4FA),
    secondaryLabel: Color(0xB3EBEBF5),
    tertiaryLabel: Color(0x73EBEBF5),
    accent: Color(0xFF8E8CF7),
    onAccent: Color(0xFF0C0C14),
    success: Color(0xFF4CD787),
    warning: Color(0xFFFFB340),
    danger: Color(0xFFFF6961),
    backdropAlpha: 0.55,
  );

  static const light = Palette(
    brightness: Brightness.light,
    canvas: Color(0xFFF1F0F7),
    glassFill: Color(0xA6FFFFFF),
    glassFillStrong: Color(0xE6FBFBFE),
    glassStroke: Color(0x0F1C1C3A),
    glassHighlight: Color(0x99FFFFFF),
    fieldFill: Color(0x0F1C1C3A),
    separator: Color(0x1F3C3C5A),
    label: Color(0xFF15151F),
    secondaryLabel: Color(0x993C3C50),
    tertiaryLabel: Color(0x663C3C50),
    accent: Color(0xFF5552D9),
    onAccent: Color(0xFFFAFAFF),
    success: Color(0xFF1F9D55),
    warning: Color(0xFFC77800),
    danger: Color(0xFFD7372E),
    backdropAlpha: 0.38,
  );

  /// Pure black canvas for OLED screens; the backdrop is dimmed so the
  /// screen stays mostly off.
  static final black = dark.copyWith(
    canvas: const Color(0xFF000000),
    glassFill: const Color(0xB3121218),
    glassFillStrong: const Color(0xE6141419),
    backdropAlpha: 0.28,
  );

  /// Backdrop blob colors for a given urgency (0 = the day is wide open,
  /// 1 = free time is spent). Calm indigo/teal drifts toward amber, then red.
  List<Color> backdropFor(double urgency) {
    const calm = [Color(0xFF5E5CE6), Color(0xFF2FB5C9), Color(0xFF9A6BEB)];
    const tense = [Color(0xFFF2994A), Color(0xFFE8618C), Color(0xFF9A6BEB)];
    const spent = [Color(0xFFE5483F), Color(0xFFB8325A), Color(0xFF7A3E9D)];

    final u = urgency.clamp(0.0, 1.0);
    final List<Color> from;
    final List<Color> to;
    final double t;
    if (u < 0.6) {
      from = calm;
      to = tense;
      t = Curves.easeIn.transform(u / 0.6);
    } else {
      from = tense;
      to = spent;
      t = (u - 0.6) / 0.4;
    }
    return List.generate(
      3,
      (i) => Color.lerp(from[i], to[i], t)!.withValues(alpha: backdropAlpha),
    );
  }

  /// Text/indicator color for the free-time readout at a given urgency.
  Color urgencyTint(double urgency) {
    if (urgency >= 0.85) return danger;
    if (urgency >= 0.6) return warning;
    return label;
  }

  @override
  Palette copyWith({
    Brightness? brightness,
    Color? canvas,
    Color? glassFill,
    Color? glassFillStrong,
    Color? glassStroke,
    Color? glassHighlight,
    Color? fieldFill,
    Color? separator,
    Color? label,
    Color? secondaryLabel,
    Color? tertiaryLabel,
    Color? accent,
    Color? onAccent,
    Color? success,
    Color? warning,
    Color? danger,
    double? backdropAlpha,
  }) {
    return Palette(
      brightness: brightness ?? this.brightness,
      canvas: canvas ?? this.canvas,
      glassFill: glassFill ?? this.glassFill,
      glassFillStrong: glassFillStrong ?? this.glassFillStrong,
      glassStroke: glassStroke ?? this.glassStroke,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      fieldFill: fieldFill ?? this.fieldFill,
      separator: separator ?? this.separator,
      label: label ?? this.label,
      secondaryLabel: secondaryLabel ?? this.secondaryLabel,
      tertiaryLabel: tertiaryLabel ?? this.tertiaryLabel,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      backdropAlpha: backdropAlpha ?? this.backdropAlpha,
    );
  }

  @override
  Palette lerp(Palette? other, double t) {
    if (other == null) return this;
    return Palette(
      brightness: t < 0.5 ? brightness : other.brightness,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassFillStrong: Color.lerp(glassFillStrong, other.glassFillStrong, t)!,
      glassStroke: Color.lerp(glassStroke, other.glassStroke, t)!,
      glassHighlight: Color.lerp(glassHighlight, other.glassHighlight, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      label: Color.lerp(label, other.label, t)!,
      secondaryLabel: Color.lerp(secondaryLabel, other.secondaryLabel, t)!,
      tertiaryLabel: Color.lerp(tertiaryLabel, other.tertiaryLabel, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      backdropAlpha: backdropAlpha + (other.backdropAlpha - backdropAlpha) * t,
    );
  }
}

extension PaletteContext on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>() ?? Palette.dark;
}

/// Type scale modeled on Apple's text styles.
class AppText {
  AppText._();

  static const largeTitle = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.8, height: 1.15);
  static const title2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4, height: 1.2);
  static const title3 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3, height: 1.25);
  static const headline = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3);
  static const body = TextStyle(fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: -0.2, height: 1.35);
  static const callout = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -0.15, height: 1.35);
  static const subhead = TextStyle(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.1, height: 1.35);
  static const footnote = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 1.35);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.3);

  static const tabular = [FontFeature.tabularFigures()];
}
