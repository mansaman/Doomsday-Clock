import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedPressable extends StatefulWidget {
  const AnimatedPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.enableHaptic = true,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool enableHaptic;

  @override
  State<AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<AnimatedPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        if (widget.enableHaptic) {
          HapticFeedback.selectionClick();
        }
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.75).animate(_controller),
          child: widget.child,
        ),
      ),
    );
  }
}
