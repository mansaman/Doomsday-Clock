import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/life_calculator.dart';
import '../theme/palette.dart';
import 'animated_pressable.dart';

/// 0 when the day's free time is untouched, 1 when it is spent.
double urgencyOf(LifeCalculator? calc) {
  if (calc == null) return 0;
  if (calc.isFreeTimeExhausted) return 1;
  return (1 - calc.freeTimePercentageRemaining).clamp(0.0, 1.0);
}

/// Static color field behind every screen. Its hue carries the day's state:
/// calm indigo/teal with plenty of free time, amber then red as it runs out.
/// It never loops; it only eases to a new color when urgency changes.
class GlassBackdrop extends StatefulWidget {
  const GlassBackdrop({super.key, this.urgencyOverride});

  /// Forces a specific urgency (onboarding uses 0).
  final double? urgencyOverride;

  @override
  State<GlassBackdrop> createState() => _GlassBackdropState();
}

class _GlassBackdropState extends State<GlassBackdrop> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Urgency moves slowly; re-read it twice a minute.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final urgency = widget.urgencyOverride ??
        urgencyOf(context.select<AppState, LifeCalculator?>((s) => s.lifeCalculator));
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: urgency),
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 1200),
        curve: Curves.easeOutQuart,
        builder: (context, u, _) => CustomPaint(
          size: Size.infinite,
          painter: _BackdropPainter(canvas: p.canvas, blobs: p.backdropFor(u)),
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({required this.canvas, required this.blobs});

  final Color canvas;
  final List<Color> blobs;

  @override
  void paint(Canvas c, Size size) {
    c.drawRect(Offset.zero & size, Paint()..color = canvas);
    final s = size.longestSide;
    _blob(c, Offset(size.width * 0.05, size.height * 0.08), s * 0.62, blobs[0]);
    _blob(c, Offset(size.width * 1.0, size.height * 0.42), s * 0.55, blobs[1]);
    _blob(c, Offset(size.width * 0.2, size.height * 0.95), s * 0.6, blobs[2]);
  }

  void _blob(Canvas c, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [color, color.withValues(alpha: color.a * 0.35), color.withValues(alpha: 0)],
        const [0.0, 0.45, 1.0],
      );
    c.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.canvas != canvas || !listEquals(old.blobs, blobs);
}

/// Frosted panel: background blur, translucent fill, hairline stroke and a
/// faint top sheen.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.fill,
    this.tint,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? fill;

  /// Optional color washed into the fill (used for urgent banners).
  final Color? tint;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final br = borderRadius ?? BorderRadius.circular(radius);
    var base = fill ?? p.glassFill;
    if (tint != null) base = Color.alphaBlend(tint!.withValues(alpha: 0.16), base);
    final sheen = Color.alphaBlend(p.glassHighlight, base);

    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: br,
            border: Border.all(color: p.glassStroke, width: 1),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [sheen, base],
              stops: const [0, 0.45],
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// iOS-style inset grouped list: optional header and footer around one glass
/// panel whose rows are split by inset hairlines.
class GlassGroup extends StatelessWidget {
  const GlassGroup({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.trailingHeader,
  });

  final List<Widget> children;
  final String? header;
  final Widget? trailingHeader;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        rows.add(Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(height: 0.5, color: p.separator),
        ));
      }
      rows.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null || trailingHeader != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 12, 8),
            child: Row(
              children: [
                if (header != null)
                  Expanded(
                    child: Text(header!, style: AppText.footnote.copyWith(
                      color: p.secondaryLabel,
                      fontWeight: FontWeight.w500,
                    )),
                  ),
                if (trailingHeader != null) trailingHeader!,
              ],
            ),
          ),
        GlassPanel(
          padding: EdgeInsets.zero,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(footer!, style: AppText.footnote.copyWith(color: p.secondaryLabel)),
          ),
      ],
    );
  }
}

/// A row inside a [GlassGroup].
class GlassRow extends StatefulWidget {
  const GlassRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = false,
    this.titleStyle,
    this.semanticsLabel,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final TextStyle? titleStyle;
  final String? semanticsLabel;

  @override
  State<GlassRow> createState() => _GlassRowState();
}

class _GlassRowState extends State<GlassRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final interactive = widget.onTap != null;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      color: _pressed ? p.fieldFill : Colors.transparent,
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: (widget.titleStyle ?? AppText.body).copyWith(color: p.label),
                  child: widget.title,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: AppText.footnote.copyWith(color: p.secondaryLabel),
                    child: widget.subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 12),
            DefaultTextStyle.merge(
              style: AppText.body.copyWith(color: p.secondaryLabel),
              child: widget.trailing!,
            ),
          ],
          if (widget.showChevron) ...[
            const SizedBox(width: 6),
            Icon(CupertinoIcons.chevron_forward, size: 16, color: p.tertiaryLabel),
          ],
        ],
      ),
    );

    if (!interactive) return content;
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap!();
        },
        child: content,
      ),
    );
  }
}

/// Rounded-square tinted icon, like iOS Settings.
class RowIcon extends StatelessWidget {
  const RowIcon(this.icon, {super.key, required this.color, this.size = 30});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(size * 0.27),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.58, color: color),
    );
  }
}

/// Circular glass button for toolbars (back, settings, add).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: AnimatedPressable(
          onTap: onPressed,
          child: SizedBox(
            width: 44,
            height: 44,
            child: GlassPanel(
              radius: 22,
              padding: EdgeInsets.zero,
              child: Center(child: Icon(icon, size: 20, color: color ?? p.label)),
            ),
          ),
        ),
      ),
    );
  }
}

enum GlassButtonStyle { filled, tinted, plain }

class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = GlassButtonStyle.filled,
    this.color,
    this.expand = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GlassButtonStyle style;

  /// Overrides the accent (e.g. danger for destructive actions).
  final Color? color;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.accent;
    final enabled = onPressed != null;

    final (Color bg, Color fg) = switch (style) {
      GlassButtonStyle.filled => (c, color == null ? p.onAccent : Colors.white),
      GlassButtonStyle.tinted => (c.withValues(alpha: p.isDark ? 0.2 : 0.12), c),
      GlassButtonStyle.plain => (Colors.transparent, c),
    };

    final child = AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: enabled ? 1 : 0.4,
      child: Container(
        height: compact ? 38 : 50,
        padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 22),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(compact ? 19 : 25),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 16 : 18, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: (compact ? AppText.subhead : AppText.headline).copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: enabled ? AnimatedPressable(onTap: onPressed!, child: child) : child,
    );
  }
}

/// Native sliding segmented control tinted to the palette.
class SegmentedPicker<T extends Object> extends StatelessWidget {
  const SegmentedPicker({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return SizedBox(
      width: double.infinity,
      child: CupertinoSlidingSegmentedControl<T>(
        groupValue: value,
        backgroundColor: p.fieldFill,
        thumbColor: p.isDark ? const Color(0xFF5A5A6E) : const Color(0xFFFFFFFF),
        padding: const EdgeInsets.all(3),
        onValueChanged: (v) {
          if (v == null) return;
          HapticFeedback.selectionClick();
          onChanged(v);
        },
        children: {
          for (final e in options.entries)
            e.key: Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text(
                e.value,
                style: AppText.footnote.copyWith(
                  color: p.label,
                  fontWeight: e.key == value ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
        },
      ),
    );
  }
}

/// Page shell: color backdrop, glass toolbar buttons, large title and a
/// scrolling body.
class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.title,
    required this.children,
    this.actions = const [],
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 40),
    this.floating,
  });

  final String title;
  final Widget? subtitle;
  final List<Widget> actions;
  final List<Widget> children;
  final EdgeInsets padding;

  /// Pinned bottom widget (e.g. a primary action).
  final Widget? floating;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final canPop = Navigator.of(context).canPop();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: p.canvas,
        body: Stack(
          children: [
            const Positioned.fill(child: GlassBackdrop()),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        if (canPop)
                          GlassIconButton(
                            icon: CupertinoIcons.chevron_back,
                            tooltip: 'Back',
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        const Spacer(),
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          actions[i],
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: ListView(
                          padding: padding.copyWith(
                            bottom: padding.bottom + MediaQuery.paddingOf(context).bottom,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(4, 12, 4, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Semantics(
                                    header: true,
                                    child: Text(title, style: AppText.largeTitle.copyWith(color: p.label)),
                                  ),
                                  if (subtitle != null) ...[
                                    const SizedBox(height: 4),
                                    DefaultTextStyle.merge(
                                      style: AppText.subhead.copyWith(color: p.secondaryLabel),
                                      child: subtitle!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            ...children,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (floating != null)
              Positioned(
                right: 16,
                bottom: 16 + MediaQuery.paddingOf(context).bottom,
                child: floating!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet on strong glass with a grabber. Used instead of dialogs.
Future<T?> showGlassSheet<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (sheetContext) {
      final p = sheetContext.palette;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: GlassPanel(
              fill: p.glassFillStrong,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              padding: EdgeInsets.fromLTRB(
                20, 8, 20, 20 + MediaQuery.paddingOf(sheetContext).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: p.tertiaryLabel,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: AppText.title3.copyWith(color: p.label)),
                  const SizedBox(height: 16),
                  builder(sheetContext),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Teaching empty state: what this space is for and how to fill it.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 36, color: p.tertiaryLabel),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: AppText.headline.copyWith(color: p.label)),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.subhead.copyWith(color: p.secondaryLabel),
          ),
        ],
      ),
    );
  }
}

/// Text field + submit button row on glass, used by quick-capture screens.
class CaptureField extends StatelessWidget {
  const CaptureField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmit,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmit;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: maxLines,
      maxLength: maxLength,
      style: AppText.body.copyWith(color: p.label),
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(hintText: hint, counterText: ''),
      onSubmitted: (_) => onSubmit(),
    );
  }
}

String formatHm(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h == 0) return '${m}m';
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}

String formatHours(double h) => '${h.toStringAsFixed(h % 1 == 0 ? 0 : 1)}h';
