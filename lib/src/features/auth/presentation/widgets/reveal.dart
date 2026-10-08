import 'package:flutter/material.dart';

class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required this.animation,
    required this.begin,
    required this.end,
    required this.child,
    this.dy = 24,
    this.fromScale = 1.0,
  });

  final Animation<double> animation;
  final double begin;
  final double end;
  final double dy;
  final double fromScale;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curve = Interval(begin, end, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = curve.transform(animation.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * dy),
            child: Transform.scale(
              scale: fromScale + (1 - fromScale) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}