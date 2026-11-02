import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/palette.dart';

/// 5x7 dot-matrix glyphs, one string per row, '1' = lit.
const _glyphs = <String, List<String>>{
  '0': ['01110', '10001', '10001', '10001', '10001', '10001', '01110'],
  '1': ['00100', '01100', '00100', '00100', '00100', '00100', '01110'],
  '2': ['01110', '10001', '00001', '00010', '00100', '01000', '11111'],
  '3': ['11111', '00010', '00100', '00010', '00001', '10001', '01110'],
  '4': ['00010', '00110', '01010', '10010', '11111', '00010', '00010'],
  '5': ['11111', '10000', '11110', '00001', '00001', '10001', '01110'],
  '6': ['00110', '01000', '10000', '11110', '10001', '10001', '01110'],
  '7': ['11111', '00001', '00010', '00100', '01000', '01000', '01000'],
  '8': ['01110', '10001', '10001', '01110', '10001', '10001', '01110'],
  '9': ['01110', '10001', '10001', '01111', '00001', '00010', '01100'],
};

/// Dot-matrix digital clock where every digit sits on a split-flap tile.
/// Hours, minutes and seconds flip when they change.
class FlipClock extends StatelessWidget {
  const FlipClock({super.key, required this.now});

  final DateTime now;

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    final hour = use24h ? now.hour : (now.hour % 12 == 0 ? 12 : now.hour % 12);
    final h = _two(hour);
    final m = _two(now.minute);
    final s = _two(now.second);
    final period = now.hour < 12 ? 'AM' : 'PM';

    final dotFont = GoogleFonts.dotGothic16(
      color: p.secondaryLabel,
      letterSpacing: 3,
      fontSize: 15,
    );

    const big = 9.0;
    const small = 3.6;
    final bigH = FlipTile.heightFor(big);

    return Semantics(
      label: 'Time ${DateFormat.jm().format(now)}',
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat('EEEE').format(now).toUpperCase(), style: dotFont),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlipTile(char: h[0], cell: big),
                const SizedBox(width: 6),
                FlipTile(char: h[1], cell: big),
                _Colon(cell: big, height: bigH),
                FlipTile(char: m[0], cell: big),
                const SizedBox(width: 6),
                FlipTile(char: m[1], cell: big),
                const SizedBox(width: 10),
                SizedBox(
                  height: bigH,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 2, top: 2),
                        child: Text(use24h ? '' : period, style: dotFont.copyWith(fontSize: 17)),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FlipTile(char: s[0], cell: small),
                          const SizedBox(width: 3),
                          FlipTile(char: s[1], cell: small),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(DateFormat('MMMM d y').format(now).toUpperCase(), style: dotFont),
          ],
        ),
      ),
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon({required this.cell, required this.height});

  final double cell;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget dot() => Container(
          width: cell * 0.8,
          height: cell * 0.8,
          decoration: BoxDecoration(
            color: p.label,
            borderRadius: BorderRadius.circular(cell * 0.18),
          ),
        );
    return SizedBox(
      width: cell * 2.6,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [dot(), SizedBox(height: cell * 1.6), dot()],
      ),
    );
  }
}

/// One split-flap tile showing a dot-matrix digit. When [char] changes, the
/// old top half falls forward and the new bottom half drops into place.
class FlipTile extends StatefulWidget {
  const FlipTile({super.key, required this.char, required this.cell});

  final String char;

  /// Size of one dot cell; the tile scales from it.
  final double cell;

  static double widthFor(double cell) => cell * 5 + cell * 2.2;
  static double heightFor(double cell) => cell * 7 + cell * 2.2;

  @override
  State<FlipTile> createState() => _FlipTileState();
}

class _FlipTileState extends State<FlipTile> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );
  late String _old = widget.char;
  late String _new = widget.char;

  @override
  void didUpdateWidget(FlipTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.char == _new) return;
    _old = _new;
    _new = widget.char;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _old = _new;
      _c.value = 1;
    } else {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final w = FlipTile.widthFor(widget.cell);
    final h = FlipTile.heightFor(widget.cell);
    final radius = widget.cell * 0.9;

    // Tiles must be opaque so the flap hides what is behind it.
    final surface = Color.alphaBlend(p.glassFillStrong, p.canvas);
    final bg = Color.alphaBlend(
      p.isDark ? Colors.black.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.7),
      surface,
    );

    Widget face(String ch) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: p.glassStroke),
          ),
          child: CustomPaint(
            painter: _DotGlyphPainter(
              rows: _glyphs[ch] ?? _glyphs['0']!,
              cell: widget.cell,
              on: p.label,
              off: p.label.withValues(alpha: p.isDark ? 0.07 : 0.06),
            ),
          ),
        );

    Widget topHalf(Widget child) => ClipRect(
          child: Align(alignment: Alignment.topCenter, heightFactor: 0.5, child: child),
        );
    Widget bottomHalf(Widget child) => ClipRect(
          child: Align(alignment: Alignment.bottomCenter, heightFactor: 0.5, child: child),
        );

    Widget shaded(Widget child, double amount) => Stack(
          children: [
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(color: Colors.black.withValues(alpha: amount)),
              ),
            ),
          ],
        );

    return SizedBox(
      width: w,
      height: h,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          final animating = _c.isAnimating;

          final List<Widget> layers;
          if (!animating) {
            layers = [face(_new)];
          } else {
            // First half: old top flap falls to the hinge.
            // Second half: new bottom flap swings down from the hinge.
            final first = t < 0.5;
            final local = first
                ? Curves.easeInQuad.transform(t / 0.5)
                : Curves.easeOutQuart.transform((t - 0.5) / 0.5);

            final flap = first
                ? Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.004)
                      ..rotateX(-math.pi / 2 * local),
                    child: shaded(topHalf(face(_old)), 0.35 * local),
                  )
                : Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.004)
                      ..rotateX(math.pi / 2 * (1 - local)),
                    child: shaded(bottomHalf(face(_new)), 0.35 * (1 - local)),
                  );

            layers = [
              Column(children: [topHalf(face(_new)), bottomHalf(face(_old))]),
              Column(
                children: first
                    ? [flap, SizedBox(height: h / 2)]
                    : [SizedBox(height: h / 2), flap],
              ),
            ];
          }

          return Stack(
            children: [
              ...layers,
              // The hinge gap between the two flaps.
              Positioned(
                left: 0,
                right: 0,
                top: h / 2 - 0.75,
                child: Container(height: 1.5, color: p.canvas.withValues(alpha: 0.85)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DotGlyphPainter extends CustomPainter {
  _DotGlyphPainter({required this.rows, required this.cell, required this.on, required this.off});

  final List<String> rows;
  final double cell;
  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = cell * 0.8;
    final gridW = cell * 4 + dot;
    final gridH = cell * 6 + dot;
    final ox = (size.width - gridW) / 2;
    final oy = (size.height - gridH) / 2;
    final onPaint = Paint()..color = on;
    final offPaint = Paint()..color = off;
    final r = Radius.circular(cell * 0.18);

    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 5; x++) {
        final lit = rows[y][x] == '1';
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(ox + x * cell, oy + y * cell, dot, dot), r),
          lit ? onPaint : offPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGlyphPainter old) =>
      old.rows != rows || old.on != on || old.off != off || old.cell != cell;
}
